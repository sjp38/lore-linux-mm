Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id A09E16B004D
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 10:08:46 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3705177pad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 07:08:46 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part3 1/2] ACPIHP: enhance ACPI container driver to support new hotplug framework
Date: Sun,  4 Nov 2012 23:08:17 +0800
Message-Id: <1352041698-6243-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352041698-6243-1-git-send-email-jiang.liu@huawei.com>
References: <1352041698-6243-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

With the new ACPI system device hotplug framework, ACPI device driver
doesn't need to handle hotplug events any more and only need to provide
callbacks for the framework to configure/unconfigure system devices.

So this patch makes following changes to the ACPI container driver:
1) Remove code to handle ACPI hotplug event from the container driver.
2) Add callbacks to configure/unconfigure container device. Actually
   all callbacks are NOOP because ACPI container devices are just
   container to host really ACPI devices.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 drivers/acpi/Kconfig     |    7 +-
 drivers/acpi/container.c |  224 ++++++----------------------------------------
 include/acpi/container.h |   12 ---
 3 files changed, 30 insertions(+), 213 deletions(-)
 delete mode 100644 include/acpi/container.h

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 185ab1d..05f0a22 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -380,13 +380,14 @@ config ACPI_HOTPLUG_DRIVER
 
 config ACPI_CONTAINER
 	tristate "Container and Module Devices (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
-	default (ACPI_HOTPLUG_MEMORY || ACPI_HOTPLUG_CPU || ACPI_HOTPLUG_IO)
+	depends on ACPI_HOTPLUG
+	default y
 	help
 	  This driver supports ACPI Container and Module devices (IDs
 	  ACPI0004, PNP0A05, and PNP0A06).
 
-	  This helps support hotplug of nodes, CPUs, and memory.
+	  This helps support hotplug of nodes, CPUs, memory and PCI host
+	  bridges.
 
 	  To compile this driver as a module, choose M here:
 	  the module will be called container.
diff --git a/drivers/acpi/container.c b/drivers/acpi/container.c
index 1f9f7d7..ed1e59f 100644
--- a/drivers/acpi/container.c
+++ b/drivers/acpi/container.c
@@ -7,6 +7,7 @@
  * Copyright (C) 2004 Motoyuki Ito (motoyuki@soft.fujitsu.com)
  * Copyright (C) 2004 Intel Corp.
  * Copyright (C) 2004 FUJITSU LIMITED
+ * Copyright (C) 2012 Jiang Liu (jiang.liu@huawei.com)
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  *
@@ -34,16 +35,13 @@
 #include <linux/acpi.h>
 #include <acpi/acpi_bus.h>
 #include <acpi/acpi_drivers.h>
-#include <acpi/container.h>
+#include <acpi/acpi_hotplug.h>
 
 #define PREFIX "ACPI: "
 
 #define ACPI_CONTAINER_DEVICE_NAME	"ACPI container device"
 #define ACPI_CONTAINER_CLASS		"container"
 
-#define INSTALL_NOTIFY_HANDLER		1
-#define UNINSTALL_NOTIFY_HANDLER	2
-
 #define _COMPONENT			ACPI_CONTAINER_COMPONENT
 ACPI_MODULE_NAME("container");
 
@@ -54,6 +52,18 @@ MODULE_LICENSE("GPL");
 static int acpi_container_add(struct acpi_device *device);
 static int acpi_container_remove(struct acpi_device *device, int type);
 
+static int acpihp_container_get_devinfo(struct acpi_device *device,
+					struct acpihp_dev_info *info);
+static int acpihp_container_configure(struct acpi_device *device,
+				      struct acpihp_cancel_context *argp);
+static void acpihp_container_unconfigure(struct acpi_device *device);
+
+struct acpihp_dev_ops acpihp_container_ops = {
+	.get_info = acpihp_container_get_devinfo,
+	.configure = acpihp_container_configure,
+	.unconfigure = acpihp_container_unconfigure,
+};
+
 static const struct acpi_device_id container_device_ids[] = {
 	{"ACPI0004", 0},
 	{"PNP0A05", 0},
@@ -69,49 +79,19 @@ static struct acpi_driver acpi_container_driver = {
 	.ops = {
 		.add = acpi_container_add,
 		.remove = acpi_container_remove,
-		},
+		.hp_ops = &acpihp_container_ops,
+	},
 };
 
-/*******************************************************************/
-
-static int is_device_present(acpi_handle handle)
-{
-	acpi_handle temp;
-	acpi_status status;
-	unsigned long long sta;
-
-
-	status = acpi_get_handle(handle, "_STA", &temp);
-	if (ACPI_FAILURE(status))
-		return 1;	/* _STA not found, assume device present */
-
-	status = acpi_evaluate_integer(handle, "_STA", NULL, &sta);
-	if (ACPI_FAILURE(status))
-		return 0;	/* Firmware error */
-
-	return ((sta & ACPI_STA_DEVICE_PRESENT) == ACPI_STA_DEVICE_PRESENT);
-}
-
-/*******************************************************************/
 static int acpi_container_add(struct acpi_device *device)
 {
-	struct acpi_container *container;
-
-
 	if (!device) {
 		printk(KERN_ERR PREFIX "device is NULL\n");
 		return -EINVAL;
 	}
 
-	container = kzalloc(sizeof(struct acpi_container), GFP_KERNEL);
-	if (!container)
-		return -ENOMEM;
-
-	container->handle = device->handle;
 	strcpy(acpi_device_name(device), ACPI_CONTAINER_DEVICE_NAME);
 	strcpy(acpi_device_class(device), ACPI_CONTAINER_CLASS);
-	device->driver_data = container;
-
 	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Device <%s> bid <%s>\n",
 			  acpi_device_name(device), acpi_device_bid(device)));
 
@@ -120,177 +100,25 @@ static int acpi_container_add(struct acpi_device *device)
 
 static int acpi_container_remove(struct acpi_device *device, int type)
 {
-	acpi_status status = AE_OK;
-	struct acpi_container *pc = NULL;
-
-	pc = acpi_driver_data(device);
-	kfree(pc);
-	return status;
-}
-
-static int container_device_add(struct acpi_device **device, acpi_handle handle)
-{
-	acpi_handle phandle;
-	struct acpi_device *pdev;
-	int result;
-
-
-	if (acpi_get_parent(handle, &phandle)) {
-		return -ENODEV;
-	}
-
-	if (acpi_bus_get_device(phandle, &pdev)) {
-		return -ENODEV;
-	}
-
-	if (acpi_bus_add(device, pdev, handle, ACPI_BUS_TYPE_DEVICE)) {
-		return -ENODEV;
-	}
-
-	result = acpi_bus_start(*device);
-
-	return result;
-}
-
-static void container_notify_cb(acpi_handle handle, u32 type, void *context)
-{
-	struct acpi_device *device = NULL;
-	int result;
-	int present;
-	acpi_status status;
-	u32 ost_code = ACPI_OST_SC_NON_SPECIFIC_FAILURE; /* default */
-
-	switch (type) {
-	case ACPI_NOTIFY_BUS_CHECK:
-		/* Fall through */
-	case ACPI_NOTIFY_DEVICE_CHECK:
-		printk(KERN_WARNING "Container driver received %s event\n",
-		       (type == ACPI_NOTIFY_BUS_CHECK) ?
-		       "ACPI_NOTIFY_BUS_CHECK" : "ACPI_NOTIFY_DEVICE_CHECK");
-
-		present = is_device_present(handle);
-		status = acpi_bus_get_device(handle, &device);
-		if (!present) {
-			if (ACPI_SUCCESS(status)) {
-				/* device exist and this is a remove request */
-				device->flags.eject_pending = 1;
-				kobject_uevent(&device->dev.kobj, KOBJ_OFFLINE);
-				return;
-			}
-			break;
-		}
-
-		if (!ACPI_FAILURE(status) || device)
-			break;
-
-		result = container_device_add(&device, handle);
-		if (result) {
-			printk(KERN_WARNING "Failed to add container\n");
-			break;
-		}
-
-		kobject_uevent(&device->dev.kobj, KOBJ_ONLINE);
-		ost_code = ACPI_OST_SC_SUCCESS;
-		break;
-
-	case ACPI_NOTIFY_EJECT_REQUEST:
-		if (!acpi_bus_get_device(handle, &device) && device) {
-			device->flags.eject_pending = 1;
-			kobject_uevent(&device->dev.kobj, KOBJ_OFFLINE);
-			return;
-		}
-		break;
-
-	default:
-		/* non-hotplug event; possibly handled by other handler */
-		return;
-	}
-
-	/* Inform firmware that the hotplug operation has completed */
-	(void) acpi_evaluate_hotplug_ost(handle, type, ost_code, NULL);
-	return;
+	return AE_OK;
 }
 
-static acpi_status
-container_walk_namespace_cb(acpi_handle handle,
-			    u32 lvl, void *context, void **rv)
+static int acpihp_container_get_devinfo(struct acpi_device *device,
+					struct acpihp_dev_info *info)
 {
-	char *hid = NULL;
-	struct acpi_device_info *info;
-	acpi_status status;
-	int *action = context;
-
-	status = acpi_get_object_info(handle, &info);
-	if (ACPI_FAILURE(status)) {
-		return AE_OK;
-	}
+	info->type = ACPIHP_DEV_TYPE_CONTAINER;
 
-	if (info->valid & ACPI_VALID_HID)
-		hid = info->hardware_id.string;
-
-	if (hid == NULL) {
-		goto end;
-	}
-
-	if (strcmp(hid, "ACPI0004") && strcmp(hid, "PNP0A05") &&
-	    strcmp(hid, "PNP0A06")) {
-		goto end;
-	}
-
-	switch (*action) {
-	case INSTALL_NOTIFY_HANDLER:
-		acpi_install_notify_handler(handle,
-					    ACPI_SYSTEM_NOTIFY,
-					    container_notify_cb, NULL);
-		break;
-	case UNINSTALL_NOTIFY_HANDLER:
-		acpi_remove_notify_handler(handle,
-					   ACPI_SYSTEM_NOTIFY,
-					   container_notify_cb);
-		break;
-	default:
-		break;
-	}
-
-      end:
-	kfree(info);
-
-	return AE_OK;
+	return 0;
 }
 
-static int __init acpi_container_init(void)
+static int acpihp_container_configure(struct acpi_device *device,
+				      struct acpihp_cancel_context *argp)
 {
-	int result = 0;
-	int action = INSTALL_NOTIFY_HANDLER;
-
-	result = acpi_bus_register_driver(&acpi_container_driver);
-	if (result < 0) {
-		return (result);
-	}
-
-	/* register notify handler to every container device */
-	acpi_walk_namespace(ACPI_TYPE_DEVICE,
-			    ACPI_ROOT_OBJECT,
-			    ACPI_UINT32_MAX,
-			    container_walk_namespace_cb, NULL, &action, NULL);
-
-	return (0);
+	return 0;
 }
 
-static void __exit acpi_container_exit(void)
+static void acpihp_container_unconfigure(struct acpi_device *device)
 {
-	int action = UNINSTALL_NOTIFY_HANDLER;
-
-
-	acpi_walk_namespace(ACPI_TYPE_DEVICE,
-			    ACPI_ROOT_OBJECT,
-			    ACPI_UINT32_MAX,
-			    container_walk_namespace_cb, NULL, &action, NULL);
-
-	acpi_bus_unregister_driver(&acpi_container_driver);
-
-	return;
 }
 
-module_init(acpi_container_init);
-module_exit(acpi_container_exit);
+module_acpi_driver(acpi_container_driver);
diff --git a/include/acpi/container.h b/include/acpi/container.h
deleted file mode 100644
index a703f14..0000000
--- a/include/acpi/container.h
+++ /dev/null
@@ -1,12 +0,0 @@
-#ifndef __ACPI_CONTAINER_H
-#define __ACPI_CONTAINER_H
-
-#include <linux/kernel.h>
-
-struct acpi_container {
-	acpi_handle handle;
-	unsigned long sun;
-	int state;
-};
-
-#endif				/* __ACPI_CONTAINER_H */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
