Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 6E27C6B007D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:51:05 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH v2 09/12] ACPI: Update memory driver for hotplug framework
Date: Thu, 10 Jan 2013 16:40:27 -0700
Message-Id: <1357861230-29549-10-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Changed acpi_memory_device_notify() to request a hotplug operation
by calling shp_submit_req().  It no longer initiates hot-add or
hot-delete operation by calling add_memory() or remove_memory()
directly.  Removed the enabled and failed flags from acpi_memory_info
since they are no longer used.

Changed acpi_memory_device_add() to not call add_memory() to online
a memory device.  Similarly, changed acpi_memory_device_remove()
to not call remove_memory() to offline a memory device.

Added acpi_memory_resource() to set memory information to a hotplug
request.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 drivers/acpi/acpi_memhotplug.c |  271 +++++++++++++---------------------------
 1 file changed, 89 insertions(+), 182 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index b679bf8..67868f5 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -33,6 +33,7 @@
 #include <linux/slab.h>
 #include <linux/acpi.h>
 #include <acpi/acpi_drivers.h>
+#include <acpi/sys_hotplug.h>
 
 #define ACPI_MEMORY_DEVICE_CLASS		"memory"
 #define ACPI_MEMORY_DEVICE_HID			"PNP0C80"
@@ -55,6 +56,8 @@ MODULE_LICENSE("GPL");
 
 static int acpi_memory_device_add(struct acpi_device *device);
 static int acpi_memory_device_remove(struct acpi_device *device, int type);
+static int acpi_memory_device_resource(struct acpi_device *device,
+		struct shp_request *shp_req);
 
 static const struct acpi_device_id memory_device_ids[] = {
 	{ACPI_MEMORY_DEVICE_HID, 0},
@@ -69,6 +72,7 @@ static struct acpi_driver acpi_memory_device_driver = {
 	.ops = {
 		.add = acpi_memory_device_add,
 		.remove = acpi_memory_device_remove,
+		.resource = acpi_memory_device_resource,
 		},
 };
 
@@ -153,59 +157,12 @@ acpi_memory_get_device_resources(struct acpi_memory_device *mem_device)
 	return 0;
 }
 
-static int
-acpi_memory_get_device(acpi_handle handle,
-		       struct acpi_memory_device **mem_device)
-{
-	acpi_status status;
-	acpi_handle phandle;
-	struct acpi_device *device = NULL;
-	struct acpi_device *pdevice = NULL;
-	int result;
-
-
-	if (!acpi_bus_get_device(handle, &device) && device)
-		goto end;
-
-	status = acpi_get_parent(handle, &phandle);
-	if (ACPI_FAILURE(status)) {
-		ACPI_EXCEPTION((AE_INFO, status, "Cannot find acpi parent"));
-		return -EINVAL;
-	}
-
-	/* Get the parent device */
-	result = acpi_bus_get_device(phandle, &pdevice);
-	if (result) {
-		acpi_handle_warn(phandle, "Cannot get acpi bus device\n");
-		return -EINVAL;
-	}
-
-	/*
-	 * Now add the notified device.  This creates the acpi_device
-	 * and invokes .add function
-	 */
-	result = acpi_bus_add(&device, pdevice, handle, ACPI_BUS_TYPE_DEVICE);
-	if (result) {
-		acpi_handle_warn(handle, "Cannot add acpi bus\n");
-		return -EINVAL;
-	}
-
-      end:
-	*mem_device = acpi_driver_data(device);
-	if (!(*mem_device)) {
-		dev_err(&device->dev, "driver data not found\n");
-		return -ENODEV;
-	}
-
-	return 0;
-}
-
-static int acpi_memory_check_device(struct acpi_memory_device *mem_device)
+static int acpi_memory_check_device(acpi_handle handle)
 {
 	unsigned long long current_status;
 
 	/* Get device present/absent information from the _STA */
-	if (ACPI_FAILURE(acpi_evaluate_integer(mem_device->device->handle, "_STA",
+	if (ACPI_FAILURE(acpi_evaluate_integer(handle, "_STA",
 					       NULL, &current_status)))
 		return -ENODEV;
 	/*
@@ -220,148 +177,46 @@ static int acpi_memory_check_device(struct acpi_memory_device *mem_device)
 	return 0;
 }
 
-static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
-{
-	int result, num_enabled = 0;
-	struct acpi_memory_info *info;
-	int node;
-
-	node = acpi_get_node(mem_device->device->handle);
-	/*
-	 * Tell the VM there is more memory here...
-	 * Note: Assume that this function returns zero on success
-	 * We don't have memory-hot-add rollback function,now.
-	 * (i.e. memory-hot-remove function)
-	 */
-	list_for_each_entry(info, &mem_device->res_list, list) {
-		if (info->enabled) { /* just sanity check...*/
-			num_enabled++;
-			continue;
-		}
-		/*
-		 * If the memory block size is zero, please ignore it.
-		 * Don't try to do the following memory hotplug flowchart.
-		 */
-		if (!info->length)
-			continue;
-		if (node < 0)
-			node = memory_add_physaddr_to_nid(info->start_addr);
-
-		result = add_memory(node, info->start_addr, info->length);
-
-		/*
-		 * If the memory block has been used by the kernel, add_memory()
-		 * returns -EEXIST. If add_memory() returns the other error, it
-		 * means that this memory block is not used by the kernel.
-		 */
-		if (result && result != -EEXIST) {
-			info->failed = 1;
-			continue;
-		}
-
-		if (!result)
-			info->enabled = 1;
-		/*
-		 * Add num_enable even if add_memory() returns -EEXIST, so the
-		 * device is bound to this driver.
-		 */
-		num_enabled++;
-	}
-	if (!num_enabled) {
-		dev_err(&mem_device->device->dev, "add_memory failed\n");
-		mem_device->state = MEMORY_INVALID_STATE;
-		return -EINVAL;
-	}
-	/*
-	 * Sometimes the memory device will contain several memory blocks.
-	 * When one memory block is hot-added to the system memory, it will
-	 * be regarded as a success.
-	 * Otherwise if the last memory block can't be hot-added to the system
-	 * memory, it will be failure and the memory device can't be bound with
-	 * driver.
-	 */
-	return 0;
-}
-
-static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
-{
-	int result = 0;
-	struct acpi_memory_info *info, *n;
-
-	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
-		if (info->failed)
-			/* The kernel does not use this memory block */
-			continue;
-
-		if (!info->enabled)
-			/*
-			 * The kernel uses this memory block, but it may be not
-			 * managed by us.
-			 */
-			return -EBUSY;
-
-		result = remove_memory(info->start_addr, info->length);
-		if (result)
-			return result;
-
-		list_del(&info->list);
-		kfree(info);
-	}
-
-	return result;
-}
-
 static void acpi_memory_device_notify(acpi_handle handle, u32 event, void *data)
 {
 	struct acpi_memory_device *mem_device;
 	struct acpi_device *device;
-	struct acpi_eject_event *ej_event = NULL;
+	struct shp_request *shp_req;
+	enum shp_operation shp_op;
 	u32 ost_code = ACPI_OST_SC_NON_SPECIFIC_FAILURE; /* default */
 
 	switch (event) {
 	case ACPI_NOTIFY_BUS_CHECK:
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-				  "\nReceived BUS CHECK notification for device\n"));
 		/* Fall Through */
 	case ACPI_NOTIFY_DEVICE_CHECK:
-		if (event == ACPI_NOTIFY_DEVICE_CHECK)
-			ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-					  "\nReceived DEVICE CHECK notification for device\n"));
-		if (acpi_memory_get_device(handle, &mem_device)) {
-			acpi_handle_err(handle, "Cannot find driver data\n");
-			break;
+		if (acpi_memory_check_device(handle)) {
+			acpi_handle_err(handle, "Device not enabled\n");
+			goto err;
+		}
+
+		if (!acpi_bus_get_device(handle, &device)) {
+			acpi_handle_err(handle, "Device added already\n");
+			goto err;
 		}
 
-		ost_code = ACPI_OST_SC_SUCCESS;
+		shp_op = SHP_HOTPLUG_ADD;
 		break;
 
 	case ACPI_NOTIFY_EJECT_REQUEST:
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-				  "\nReceived EJECT REQUEST notification for device\n"));
-
 		if (acpi_bus_get_device(handle, &device)) {
 			acpi_handle_err(handle, "Device doesn't exist\n");
-			break;
+			goto err;
 		}
+
 		mem_device = acpi_driver_data(device);
 		if (!mem_device) {
 			acpi_handle_err(handle, "Driver Data is NULL\n");
-			break;
+			goto err;
 		}
 
-		ej_event = kmalloc(sizeof(*ej_event), GFP_KERNEL);
-		if (!ej_event) {
-			pr_err(PREFIX "No memory, dropping EJECT\n");
-			break;
-		}
-
-		ej_event->handle = handle;
-		ej_event->event = ACPI_NOTIFY_EJECT_REQUEST;
-		acpi_os_hotplug_execute(acpi_bus_hot_remove_device,
-					(void *)ej_event);
+		shp_op = SHP_HOTPLUG_DEL;
+		break;
 
-		/* eject is performed asynchronously */
-		return;
 	default:
 		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
 				  "Unsupported event [0x%x]\n", event));
@@ -370,7 +225,25 @@ static void acpi_memory_device_notify(acpi_handle handle, u32 event, void *data)
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
@@ -414,38 +287,72 @@ static int acpi_memory_device_add(struct acpi_device *device)
 	mem_device->state = MEMORY_POWER_ON_STATE;
 
 	pr_debug("%s\n", acpi_device_name(device));
-
-	if (!acpi_memory_check_device(mem_device)) {
-		/* call add_memory func */
-		result = acpi_memory_enable_device(mem_device);
-		if (result) {
-			dev_err(&device->dev,
-				"Error in acpi_memory_enable_device\n");
-			acpi_memory_device_free(mem_device);
-		}
-	}
 	return result;
 }
 
 static int acpi_memory_device_remove(struct acpi_device *device, int type)
 {
 	struct acpi_memory_device *mem_device = NULL;
-	int result;
+	struct acpi_memory_info *info, *n;
 
 	if (!device || !acpi_driver_data(device))
 		return -EINVAL;
 
 	mem_device = acpi_driver_data(device);
 
-	result = acpi_memory_remove_memory(mem_device);
-	if (result)
-		return result;
+	/* remove the memory_info list of this mem_device */
+	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
+		list_del(&info->list);
+		kfree(info);
+	}
 
 	acpi_memory_device_free(mem_device);
 
 	return 0;
 }
 
+static int acpi_memory_device_resource(struct acpi_device *device,
+				struct shp_request *shp_req)
+{
+	struct acpi_memory_device *mem_device = NULL;
+	struct acpi_memory_info *info, *n;
+	struct shp_device *shp_dev;
+	int node;
+
+	mem_device = acpi_driver_data(device);
+	if (!mem_device) {
+		dev_err(&device->dev, "Invalid device\n");
+		return -EINVAL;
+	}
+
+	node = acpi_get_node(mem_device->device->handle);
+
+	/*
+	 * Set resource info of the device
+	 */
+	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
+
+		if (!info->length)
+			continue;
+
+		shp_dev = kzalloc(sizeof(*shp_dev), GFP_KERNEL);
+		if (!shp_dev) {
+			dev_err(&device->dev, "Failed to allocate shp_dev\n");
+			return -EINVAL;
+		}
+
+		shp_dev->device = &device->dev;
+		shp_dev->class = SHP_CLS_MEMORY;
+		shp_dev->info.mem.node = node;
+		shp_dev->info.mem.start_addr = info->start_addr;
+		shp_dev->info.mem.length = info->length;
+
+		shp_add_dev_info(shp_req, shp_dev);
+	}
+
+	return 0;
+}
+
 /*
  * Helper function to check for memory device
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
