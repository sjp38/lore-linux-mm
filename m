Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id D408A6B0074
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:51:04 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH v2 08/12] ACPI: Update processor driver for hotplug framework
Date: Thu, 10 Jan 2013 16:40:26 -0700
Message-Id: <1357861230-29549-9-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Added acpi_processor_resource() for the .resource() interface,
which sets CPU information to a hotplug request.

Changed acpi_processor_hotplug_notify() to request a hotplug
operation by calling shp_submit_req().  It no longer initiates
hot-add or hot-delete operation by calling acpi_bus_add() or
acpi_bus_hot_remove_device() directly.

acpi_processor_handle_eject() is changed not to call cpu_down()
since .add() / .remove() may not online / offline a device.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 drivers/acpi/processor_driver.c |  150 ++++++++++++++++++---------------------
 1 file changed, 70 insertions(+), 80 deletions(-)

diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
index e83311b..f630c2c 100644
--- a/drivers/acpi/processor_driver.c
+++ b/drivers/acpi/processor_driver.c
@@ -57,6 +57,7 @@
 #include <acpi/acpi_bus.h>
 #include <acpi/acpi_drivers.h>
 #include <acpi/processor.h>
+#include <acpi/sys_hotplug.h>
 
 #define PREFIX "ACPI: "
 
@@ -83,6 +84,8 @@ MODULE_LICENSE("GPL");
 static int acpi_processor_add(struct acpi_device *device);
 static int acpi_processor_remove(struct acpi_device *device, int type);
 static void acpi_processor_notify(struct acpi_device *device, u32 event);
+static int acpi_processor_resource(struct acpi_device *device,
+		struct shp_request *shp_req);
 static acpi_status acpi_processor_hotadd_init(struct acpi_processor *pr);
 static int acpi_processor_handle_eject(struct acpi_processor *pr);
 static int acpi_processor_start(struct acpi_processor *pr);
@@ -105,6 +108,7 @@ static struct acpi_driver acpi_processor_driver = {
 		.add = acpi_processor_add,
 		.remove = acpi_processor_remove,
 		.notify = acpi_processor_notify,
+		.resource = acpi_processor_resource,
 		},
 	.drv.pm = &acpi_processor_pm,
 };
@@ -649,6 +653,33 @@ free:
 	return 0;
 }
 
+static int
+acpi_processor_resource(struct acpi_device *device, struct shp_request *shp_req)
+{
+	struct acpi_processor *pr;
+	struct shp_device *shp_dev;
+
+	pr = acpi_driver_data(device);
+	if (!pr) {
+		dev_err(&device->dev, "Driver data missing\n");
+		return -EINVAL;
+	}
+
+	shp_dev = kzalloc(sizeof(*shp_dev), GFP_KERNEL);
+	if (!shp_dev) {
+		dev_err(&device->dev, "Failed to allocate shp_dev\n");
+		return -EINVAL;
+	}
+
+	shp_dev->device = &device->dev;
+	shp_dev->class = SHP_CLS_CPU;
+	shp_dev->info.cpu.cpu_id = pr->id;
+
+	shp_add_dev_info(shp_req, shp_dev);
+
+	return 0;
+}
+
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 /****************************************************************************
  * 	Acpi processor hotplug support 				       	    *
@@ -677,97 +708,68 @@ static int is_processor_present(acpi_handle handle)
 	return 0;
 }
 
-static
-int acpi_processor_device_add(acpi_handle handle, struct acpi_device **device)
-{
-	acpi_handle phandle;
-	struct acpi_device *pdev;
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
-	if (acpi_bus_add(device, pdev, handle, ACPI_BUS_TYPE_PROCESSOR)) {
-		return -ENODEV;
-	}
-
-	return 0;
-}
-
 static void acpi_processor_hotplug_notify(acpi_handle handle,
 					  u32 event, void *data)
 {
 	struct acpi_device *device = NULL;
-	struct acpi_eject_event *ej_event = NULL;
+	struct shp_request *shp_req;
+	enum shp_operation shp_op;
 	u32 ost_code = ACPI_OST_SC_NON_SPECIFIC_FAILURE; /* default */
-	int result;
 
 	switch (event) {
 	case ACPI_NOTIFY_BUS_CHECK:
 	case ACPI_NOTIFY_DEVICE_CHECK:
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-		"Processor driver received %s event\n",
-		       (event == ACPI_NOTIFY_BUS_CHECK) ?
-		       "ACPI_NOTIFY_BUS_CHECK" : "ACPI_NOTIFY_DEVICE_CHECK"));
-
-		if (!is_processor_present(handle))
-			break;
-
-		if (!acpi_bus_get_device(handle, &device))
-			break;
+		if (!is_processor_present(handle)) {
+			acpi_handle_err(handle, "Device not enabled\n");
+			goto err;
+		}
 
-		result = acpi_processor_device_add(handle, &device);
-		if (result) {
-			acpi_handle_err(handle, "Unable to add the device\n");
-			break;
+		if (!acpi_bus_get_device(handle, &device)) {
+			acpi_handle_err(handle, "Device added already\n");
+			goto err;
 		}
 
-		ost_code = ACPI_OST_SC_SUCCESS;
+		shp_op = SHP_HOTPLUG_ADD;
 		break;
 
 	case ACPI_NOTIFY_EJECT_REQUEST:
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-				  "received ACPI_NOTIFY_EJECT_REQUEST\n"));
-
 		if (acpi_bus_get_device(handle, &device)) {
-			acpi_handle_err(handle,
-				"Device don't exist, dropping EJECT\n");
-			break;
+			acpi_handle_err(handle, "Device not added yet\n");
+			goto err;
 		}
 		if (!acpi_driver_data(device)) {
-			acpi_handle_err(handle,
-				"Driver data is NULL, dropping EJECT\n");
-			break;
+			acpi_handle_err(handle, "Driver data missing\n");
+			goto err;
 		}
 
-		ej_event = kmalloc(sizeof(*ej_event), GFP_KERNEL);
-		if (!ej_event) {
-			acpi_handle_err(handle, "No memory, dropping EJECT\n");
-			break;
-		}
-
-		ej_event->handle = handle;
-		ej_event->event = ACPI_NOTIFY_EJECT_REQUEST;
-		acpi_os_hotplug_execute(acpi_bus_hot_remove_device,
-					(void *)ej_event);
-
-		/* eject is performed asynchronously */
-		return;
+		shp_op = SHP_HOTPLUG_DEL;
+		break;
 
 	default:
 		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
 				  "Unsupported event [0x%x]\n", event));
-
-		/* non-hotplug event; possibly handled by other handler */
 		return;
 	}
 
-	/* Inform firmware that the hotplug operation has completed */
+	shp_req = shp_alloc_request(shp_op);
+	if (!shp_req) {
+		acpi_handle_err(handle, "No memory to request hotplug\n");
+		goto err;
+	}
+
+	shp_req->handle = (void *)handle;
+	shp_req->event = event;
+
+	if (shp_submit_req(shp_req)) {
+		acpi_handle_err(handle, "Failed to request hotplug\n");
+		kfree(shp_req);
+		goto err;
+	}
+
+	return;
+
+err:
+	/* Inform firmware that the hotplug operation completed w/ error */
 	(void) acpi_evaluate_hotplug_ost(handle, event, ost_code, NULL);
 	return;
 }
@@ -865,25 +867,13 @@ static acpi_status acpi_processor_hotadd_init(struct acpi_processor *pr)
 
 static int acpi_processor_handle_eject(struct acpi_processor *pr)
 {
-	if (cpu_online(pr->id))
-		cpu_down(pr->id);
-
-	get_online_cpus();
-	/*
-	 * The cpu might become online again at this point. So we check whether
-	 * the cpu has been onlined or not. If the cpu became online, it means
-	 * that someone wants to use the cpu. So acpi_processor_handle_eject()
-	 * returns -EAGAIN.
-	 */
-	if (unlikely(cpu_online(pr->id))) {
-		put_online_cpus();
-		pr_warn("Failed to remove CPU %d, because other task "
-			"brought the CPU back online\n", pr->id);
-		return -EAGAIN;
+	if (cpu_online(pr->id)) {
+		pr_err("ACPI: cpu %d not off-lined\n", pr->id);
+		return -EINVAL;
 	}
+
 	arch_unregister_cpu(pr->id);
 	acpi_unmap_lsapic(pr->id);
-	put_online_cpus();
 	return (0);
 }
 #else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
