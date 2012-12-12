Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id C156F6B009C
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:27:39 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 11/11] ACPI: Update sysfs eject for hotplug framework
Date: Wed, 12 Dec 2012 16:17:23 -0700
Message-Id: <1355354243-18657-12-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Changed acpi_eject_store() to request a hot-delete operation by
calling hp_submit_req().  It no longer initiates a hot-delete
operation by calling acpi_bus_hot_remove_device().

Deleted acpi_bus_hot_remove_device() since it no longer has any
caller and should not be called for hot-delete.

Deleted eject_pending bit from acpi_device_flags since the ACPI
container driver no longer sets it for hot-delete, and sysfs
eject no longer checks it in acpi_bus_hot_remove_device().

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 drivers/acpi/scan.c     | 122 +++++++++---------------------------------------
 include/acpi/acpi_bus.h |   4 +-
 2 files changed, 23 insertions(+), 103 deletions(-)

diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index 53502d1..a8f6803 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -11,6 +11,7 @@
 #include <linux/kthread.h>
 #include <linux/dmi.h>
 #include <linux/nls.h>
+#include <linux/hotplug.h>
 
 #include <acpi/acpi_drivers.h>
 
@@ -105,85 +106,6 @@ acpi_device_modalias_show(struct device *dev, struct device_attribute *attr, cha
 }
 static DEVICE_ATTR(modalias, 0444, acpi_device_modalias_show, NULL);
 
-/**
- * acpi_bus_hot_remove_device: hot-remove a device and its children
- * @context: struct acpi_eject_event pointer (freed in this func)
- *
- * Hot-remove a device and its children. This function frees up the
- * memory space passed by arg context, so that the caller may call
- * this function asynchronously through acpi_os_hotplug_execute().
- */
-void acpi_bus_hot_remove_device(void *context)
-{
-	struct acpi_eject_event *ej_event = (struct acpi_eject_event *) context;
-	struct acpi_device *device;
-	acpi_handle handle = ej_event->handle;
-	acpi_handle temp;
-	struct acpi_object_list arg_list;
-	union acpi_object arg;
-	acpi_status status = AE_OK;
-	u32 ost_code = ACPI_OST_SC_NON_SPECIFIC_FAILURE; /* default */
-
-	if (acpi_bus_get_device(handle, &device))
-		goto err_out;
-
-	if (!device)
-		goto err_out;
-
-	ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-		"Hot-removing device %s...\n", dev_name(&device->dev)));
-
-	if (acpi_bus_trim(device, 1)) {
-		printk(KERN_ERR PREFIX
-				"Removing device failed\n");
-		goto err_out;
-	}
-
-	/* device has been freed */
-	device = NULL;
-
-	/* power off device */
-	status = acpi_evaluate_object(handle, "_PS3", NULL, NULL);
-	if (ACPI_FAILURE(status) && status != AE_NOT_FOUND)
-		printk(KERN_WARNING PREFIX
-				"Power-off device failed\n");
-
-	if (ACPI_SUCCESS(acpi_get_handle(handle, "_LCK", &temp))) {
-		arg_list.count = 1;
-		arg_list.pointer = &arg;
-		arg.type = ACPI_TYPE_INTEGER;
-		arg.integer.value = 0;
-		acpi_evaluate_object(handle, "_LCK", &arg_list, NULL);
-	}
-
-	arg_list.count = 1;
-	arg_list.pointer = &arg;
-	arg.type = ACPI_TYPE_INTEGER;
-	arg.integer.value = 1;
-
-	/*
-	 * TBD: _EJD support.
-	 */
-	status = acpi_evaluate_object(handle, "_EJ0", &arg_list, NULL);
-	if (ACPI_FAILURE(status)) {
-		if (status != AE_NOT_FOUND)
-			printk(KERN_WARNING PREFIX
-					"Eject device failed\n");
-		goto err_out;
-	}
-
-	kfree(context);
-	return;
-
-err_out:
-	/* Inform firmware the hot-remove operation has completed w/ error */
-	(void) acpi_evaluate_hotplug_ost(handle,
-				ej_event->event, ost_code, NULL);
-	kfree(context);
-	return;
-}
-EXPORT_SYMBOL(acpi_bus_hot_remove_device);
-
 static ssize_t
 acpi_eject_store(struct device *d, struct device_attribute *attr,
 		const char *buf, size_t count)
@@ -192,44 +114,44 @@ acpi_eject_store(struct device *d, struct device_attribute *attr,
 	acpi_status status;
 	acpi_object_type type = 0;
 	struct acpi_device *acpi_device = to_acpi_device(d);
-	struct acpi_eject_event *ej_event;
+	struct hp_request *hp_req;
 
 	if ((!count) || (buf[0] != '1')) {
 		return -EINVAL;
 	}
 #ifndef FORCE_EJECT
 	if (acpi_device->driver == NULL) {
-		ret = -ENODEV;
-		goto err;
+		return -ENODEV;
 	}
 #endif
 	status = acpi_get_type(acpi_device->handle, &type);
 	if (ACPI_FAILURE(status) || (!acpi_device->flags.ejectable)) {
-		ret = -ENODEV;
-		goto err;
+		return -ENODEV;
 	}
 
-	ej_event = kmalloc(sizeof(*ej_event), GFP_KERNEL);
-	if (!ej_event) {
-		ret = -ENOMEM;
+	hp_req = hp_alloc_request(HP_HOTPLUG_DEL);
+	if (!hp_req)
+		return -ENOMEM;
+
+	hp_req->handle = (void *) acpi_device->handle;
+
+	/* event originated from user */
+	hp_req->event = ACPI_OST_EC_OSPM_EJECT;
+	(void) acpi_evaluate_hotplug_ost(hp_req->handle,
+			hp_req->event, ACPI_OST_SC_EJECT_IN_PROGRESS, NULL);
+
+	if (hp_submit_req(hp_req)) {
+		kfree(hp_req);
 		goto err;
 	}
 
-	ej_event->handle = acpi_device->handle;
-	if (acpi_device->flags.eject_pending) {
-		/* event originated from ACPI eject notification */
-		ej_event->event = ACPI_NOTIFY_EJECT_REQUEST;
-		acpi_device->flags.eject_pending = 0;
-	} else {
-		/* event originated from user */
-		ej_event->event = ACPI_OST_EC_OSPM_EJECT;
-		(void) acpi_evaluate_hotplug_ost(ej_event->handle,
-			ej_event->event, ACPI_OST_SC_EJECT_IN_PROGRESS, NULL);
-	}
+	return ret;
 
-	acpi_os_hotplug_execute(acpi_bus_hot_remove_device, (void *)ej_event);
 err:
-	return ret;
+	/* Inform firmware that the hotplug operation completed w/ error */
+	(void) acpi_evaluate_hotplug_ost(hp_req->handle,
+			hp_req->event, ACPI_OST_SC_NON_SPECIFIC_FAILURE, NULL);
+	return -EINVAL;
 }
 
 static DEVICE_ATTR(eject, 0200, NULL, acpi_eject_store);
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 10031a8..1ef71eb 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -151,8 +151,7 @@ struct acpi_device_flags {
 	u32 suprise_removal_ok:1;
 	u32 power_manageable:1;
 	u32 performance_manageable:1;
-	u32 eject_pending:1;
-	u32 reserved:24;
+	u32 reserved:25;
 };
 
 /* File System */
@@ -362,7 +361,6 @@ int acpi_bus_register_driver(struct acpi_driver *driver);
 void acpi_bus_unregister_driver(struct acpi_driver *driver);
 int acpi_bus_add(struct acpi_device **child, struct acpi_device *parent,
 		 acpi_handle handle, int type);
-void acpi_bus_hot_remove_device(void *context);
 int acpi_bus_trim(struct acpi_device *start, int rmdevice);
 int acpi_bus_start(struct acpi_device *device);
 acpi_status acpi_bus_get_ejd(acpi_handle handle, acpi_handle * ejd);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
