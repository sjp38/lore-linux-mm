Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id AC9AB6B005A
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:27:33 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 09/11] ACPI: Update container driver for hotplug framework
Date: Wed, 12 Dec 2012 16:17:21 -0700
Message-Id: <1355354243-18657-10-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Changed container_notify_cb() to request a hotplug operation by
calling hp_submit_req().  It no longer initiates hot-add by calling
acpi_bus_add().  Also, it no longer sets device->flags.eject_pending
and generates KOBJ_OFFLINE event for hot-delete.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 drivers/acpi/container.c | 95 +++++++++++++++++++-----------------------------
 1 file changed, 37 insertions(+), 58 deletions(-)

diff --git a/drivers/acpi/container.c b/drivers/acpi/container.c
index 811910b..fb9e875 100644
--- a/drivers/acpi/container.c
+++ b/drivers/acpi/container.c
@@ -31,6 +31,7 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/types.h>
+#include <linux/hotplug.h>
 #include <linux/acpi.h>
 #include <acpi/acpi_bus.h>
 #include <acpi/acpi_drivers.h>
@@ -135,77 +136,37 @@ static int acpi_container_remove(struct acpi_device *device, int type)
 	return status;
 }
 
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
+static void container_notify_cb(acpi_handle handle, u32 event, void *context)
 {
 	struct acpi_device *device = NULL;
-	int result;
-	int present;
-	acpi_status status;
+	struct hp_request *hp_req;
+	enum hp_operation hp_op;
 	u32 ost_code = ACPI_OST_SC_NON_SPECIFIC_FAILURE; /* default */
 
-	switch (type) {
+	switch (event) {
 	case ACPI_NOTIFY_BUS_CHECK:
 		/* Fall through */
 	case ACPI_NOTIFY_DEVICE_CHECK:
-		pr_debug("Container driver received %s event\n",
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
+		if (!is_device_present(handle)) {
+			acpi_handle_err(handle, "Device not enabled\n");
+			goto err;
 		}
 
-		if (!ACPI_FAILURE(status) || device)
-			break;
-
-		result = container_device_add(&device, handle);
-		if (result) {
-			acpi_handle_warn(handle, "Failed to add container\n");
-			break;
+		if (!acpi_bus_get_device(handle, &device)) {
+			acpi_handle_err(handle, "Device added already\n");
+			goto err;
 		}
 
-		kobject_uevent(&device->dev.kobj, KOBJ_ONLINE);
-		ost_code = ACPI_OST_SC_SUCCESS;
+		hp_op = HP_HOTPLUG_ADD;
 		break;
 
 	case ACPI_NOTIFY_EJECT_REQUEST:
-		if (!acpi_bus_get_device(handle, &device) && device) {
-			device->flags.eject_pending = 1;
-			kobject_uevent(&device->dev.kobj, KOBJ_OFFLINE);
-			return;
+		if (acpi_bus_get_device(handle, &device)) {
+			acpi_handle_err(handle, "Device not added yet\n");
+			goto err;
 		}
+
+		hp_op = HP_HOTPLUG_DEL;
 		break;
 
 	default:
@@ -213,8 +174,26 @@ static void container_notify_cb(acpi_handle handle, u32 type, void *context)
 		return;
 	}
 
-	/* Inform firmware that the hotplug operation has completed */
-	(void) acpi_evaluate_hotplug_ost(handle, type, ost_code, NULL);
+	hp_req = hp_alloc_request(hp_op);
+	if (!hp_req) {
+		acpi_handle_err(handle, "No memory to request hotplug\n");
+		goto err;
+	}
+
+	hp_req->handle = (void *)handle;
+	hp_req->event = event;
+
+	if (hp_submit_req(hp_req)) {
+		acpi_handle_err(handle, "Failed to request hotplug\n");
+		kfree(hp_req);
+		goto err;
+	}
+
+	return;
+
+err:
+	/* Inform firmware that the hotplug operation completed w/ error */
+	(void) acpi_evaluate_hotplug_ost(handle, event, ost_code, NULL);
 	return;
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
