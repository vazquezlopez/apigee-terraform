##########################################################
# Copyright 2021 Google LLC.
# This software is provided as-is, without warranty or
# representation for any use or purpose.
# Your use of it is subject to your agreement with Google.
#
# Sample Terraform script to set up an Apigee X instance 
##########################################################

#######################################################################
### Create an Apigee instance, environment and environment group
#######################################################################

resource "google_compute_network" "apigee_network" {
  project    = var.project_id
  name       = "apigee-network"
  auto_create_subnetworks = false
}

resource "google_compute_global_address" "apigee_range" {
  name          = "apigee-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.apigee_network.id
}

resource "google_service_networking_connection" "apigee_vpc_connection" {
  network                 = google_compute_network.apigee_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee_range.name]
}

resource "google_apigee_organization" "org" {
  analytics_region   = "us-west1"
  display_name                         = "apigee-x-project"
  description                          = "Terraform-provisioned Apigee X Org."    
  project_id         = var.project_id
  authorized_network = google_compute_network.apigee_network.id
}

resource "google_apigee_instance" "apigee_instance" {
  name     = "tf-test"
  location = "us-west1-a"
  org_id   = google_apigee_organization.org.id
}