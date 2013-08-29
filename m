Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A17776B0038
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 17:08:10 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 1/3] ACPI / scan: Change ordering of locks for device hotplug
Date: Thu, 29 Aug 2013 23:15:56 +0200
Message-ID: <1752041.76DW3TEE1A@vostro.rjw.lan>
In-Reply-To: <9589253.Co8jZpnWdd@vostro.rjw.lan>
References: <9589253.Co8jZpnWdd@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ACPI Devel Maling List <linux-acpi@vger.kernel.org>
Cc: Toshi Kani <toshi.kani@hp.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org

From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Change the ordering of device hotplug locks in scan.c so that
acpi_scan_lock is always acquired after device_hotplug_lock.

This will make it possible to use device_hotplug_lock around some
code paths that acquire acpi_scan_lock safely (most importantly
system suspend and hibernation).  Apart from that, acpi_scan_lock
is platform-specific and device_hotplug_lock is general, so the
new ordering appears to be more appropriate from the overall
design viewpoint.

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---
 drivers/acpi/scan.c |   15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

Index: linux-pm/drivers/acpi/scan.c
===================================================================
--- linux-pm.orig/drivers/acpi/scan.c
+++ linux-pm/drivers/acpi/scan.c
@@ -204,8 +204,6 @@ static int acpi_scan_hot_remove(struct a
 		return -EINVAL;
 	}
 
-	lock_device_hotplug();
-
 	/*
 	 * Carry out two passes here and ignore errors in the first pass,
 	 * because if the devices in question are memory blocks and
@@ -236,9 +234,6 @@ static int acpi_scan_hot_remove(struct a
 					    ACPI_UINT32_MAX,
 					    acpi_bus_online_companions, NULL,
 					    NULL, NULL);
-
-			unlock_device_hotplug();
-
 			put_device(&device->dev);
 			return -EBUSY;
 		}
@@ -249,8 +244,6 @@ static int acpi_scan_hot_remove(struct a
 
 	acpi_bus_trim(device);
 
-	unlock_device_hotplug();
-
 	/* Device node has been unregistered. */
 	put_device(&device->dev);
 	device = NULL;
@@ -289,6 +282,7 @@ static void acpi_bus_device_eject(void *
 	u32 ost_code = ACPI_OST_SC_NON_SPECIFIC_FAILURE;
 	int error;
 
+	lock_device_hotplug();
 	mutex_lock(&acpi_scan_lock);
 
 	acpi_bus_get_device(handle, &device);
@@ -312,6 +306,7 @@ static void acpi_bus_device_eject(void *
 
  out:
 	mutex_unlock(&acpi_scan_lock);
+	unlock_device_hotplug();
 	return;
 
  err_out:
@@ -326,8 +321,8 @@ static void acpi_scan_bus_device_check(a
 	u32 ost_code = ACPI_OST_SC_NON_SPECIFIC_FAILURE;
 	int error;
 
-	mutex_lock(&acpi_scan_lock);
 	lock_device_hotplug();
+	mutex_lock(&acpi_scan_lock);
 
 	if (ost_source != ACPI_NOTIFY_BUS_CHECK) {
 		acpi_bus_get_device(handle, &device);
@@ -353,9 +348,9 @@ static void acpi_scan_bus_device_check(a
 		kobject_uevent(&device->dev.kobj, KOBJ_ONLINE);
 
  out:
-	unlock_device_hotplug();
 	acpi_evaluate_hotplug_ost(handle, ost_source, ost_code, NULL);
 	mutex_unlock(&acpi_scan_lock);
+	unlock_device_hotplug();
 }
 
 static void acpi_scan_bus_check(void *context)
@@ -446,6 +441,7 @@ void acpi_bus_hot_remove_device(void *co
 	acpi_handle handle = device->handle;
 	int error;
 
+	lock_device_hotplug();
 	mutex_lock(&acpi_scan_lock);
 
 	error = acpi_scan_hot_remove(device);
@@ -455,6 +451,7 @@ void acpi_bus_hot_remove_device(void *co
 					  NULL);
 
 	mutex_unlock(&acpi_scan_lock);
+	unlock_device_hotplug();
 	kfree(context);
 }
 EXPORT_SYMBOL(acpi_bus_hot_remove_device);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
