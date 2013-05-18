Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id D4DA86B0036
	for <linux-mm@kvack.org>; Sat, 18 May 2013 19:27:11 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 1/5] ACPI: Drop removal_type field from struct acpi_device
Date: Sun, 19 May 2013 01:30:51 +0200
Message-ID: <9407764.8eTBrx1MOj@vostro.rjw.lan>
In-Reply-To: <2250271.rGYN6WlBxf@vostro.rjw.lan>
References: <2250271.rGYN6WlBxf@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ACPI Devel Maling List <linux-acpi@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <liuj97@gmail.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-mm@kvack.org

From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

The ACPI processor driver was the only user of the removal_type
field in struct acpi_device, but it doesn't use that field any more
after recent changes.  Thus, removal_type has no more users, so drop
it along with the associated data type.

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---
 drivers/acpi/scan.c     |    2 --
 include/acpi/acpi_bus.h |    8 --------
 2 files changed, 10 deletions(-)

Index: linux-pm/include/acpi/acpi_bus.h
===================================================================
--- linux-pm.orig/include/acpi/acpi_bus.h
+++ linux-pm/include/acpi/acpi_bus.h
@@ -63,13 +63,6 @@ acpi_get_physical_device_location(acpi_h
 #define ACPI_BUS_FILE_ROOT	"acpi"
 extern struct proc_dir_entry *acpi_root_dir;
 
-enum acpi_bus_removal_type {
-	ACPI_BUS_REMOVAL_NORMAL = 0,
-	ACPI_BUS_REMOVAL_EJECT,
-	ACPI_BUS_REMOVAL_SUPRISE,
-	ACPI_BUS_REMOVAL_TYPE_COUNT
-};
-
 enum acpi_bus_device_type {
 	ACPI_BUS_TYPE_DEVICE = 0,
 	ACPI_BUS_TYPE_POWER,
@@ -311,7 +304,6 @@ struct acpi_device {
 	struct acpi_driver *driver;
 	void *driver_data;
 	struct device dev;
-	enum acpi_bus_removal_type removal_type;	/* indicate for different removal type */
 	u8 physical_node_count;
 	struct list_head physical_node_list;
 	struct mutex physical_node_lock;
Index: linux-pm/drivers/acpi/scan.c
===================================================================
--- linux-pm.orig/drivers/acpi/scan.c
+++ linux-pm/drivers/acpi/scan.c
@@ -1036,7 +1036,6 @@ int acpi_device_add(struct acpi_device *
 		printk(KERN_ERR PREFIX "Error creating sysfs interface for device %s\n",
 		       dev_name(&device->dev));
 
-	device->removal_type = ACPI_BUS_REMOVAL_NORMAL;
 	return 0;
 
  err:
@@ -2026,7 +2025,6 @@ static acpi_status acpi_bus_device_detac
 	if (!acpi_bus_get_device(handle, &device)) {
 		struct acpi_scan_handler *dev_handler = device->handler;
 
-		device->removal_type = ACPI_BUS_REMOVAL_EJECT;
 		if (dev_handler) {
 			if (dev_handler->detach)
 				dev_handler->detach(device);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
