Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id C67D66B0069
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 05:58:27 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH v2 2/3] acpi,memory-hotplug: introduce a mutex lock to protect the list in acpi_memory_device
Date: Fri, 19 Oct 2012 18:03:59 +0800
Message-Id: <1350641040-19434-3-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1350641040-19434-1-git-send-email-wency@cn.fujitsu.com>
References: <1350641040-19434-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: liuj97@gmail.com, len.brown@intel.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, muneda.takahiro@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>

From: Wen Congyang <wency@cn.fujitsu.com>

The memory device can be removed by 2 ways:
1. send eject request by SCI
2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject

This 2 events may happen at the same time, so we may touch
acpi_memory_device.res_list at the same time. This patch
introduce a lock to protect this list.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/acpi/acpi_memhotplug.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 1e90e8f..8ff2976 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -83,7 +83,8 @@ struct acpi_memory_info {
 struct acpi_memory_device {
 	struct acpi_device * device;
 	unsigned int state;	/* State of the memory device */
-	struct list_head res_list;
+	struct mutex lock;
+	struct list_head res_list;	/* protected by lock */
 };
 
 static int acpi_hotmem_initialized;
@@ -101,19 +102,23 @@ acpi_memory_get_resource(struct acpi_resource *resource, void *context)
 	    (address64.resource_type != ACPI_MEMORY_RANGE))
 		return AE_OK;
 
+	mutex_lock(&mem_device->lock);
 	list_for_each_entry(info, &mem_device->res_list, list) {
 		/* Can we combine the resource range information? */
 		if ((info->caching == address64.info.mem.caching) &&
 		    (info->write_protect == address64.info.mem.write_protect) &&
 		    (info->start_addr + info->length == address64.minimum)) {
 			info->length += address64.address_length;
+			mutex_unlock(&mem_device->lock);
 			return AE_OK;
 		}
 	}
 
 	new = kzalloc(sizeof(struct acpi_memory_info), GFP_KERNEL);
-	if (!new)
+	if (!new) {
+		mutex_unlock(&mem_device->lock);
 		return AE_ERROR;
+	}
 
 	INIT_LIST_HEAD(&new->list);
 	new->caching = address64.info.mem.caching;
@@ -121,6 +126,7 @@ acpi_memory_get_resource(struct acpi_resource *resource, void *context)
 	new->start_addr = address64.minimum;
 	new->length = address64.address_length;
 	list_add_tail(&new->list, &mem_device->res_list);
+	mutex_unlock(&mem_device->lock);
 
 	return AE_OK;
 }
@@ -138,9 +144,11 @@ acpi_memory_get_device_resources(struct acpi_memory_device *mem_device)
 	status = acpi_walk_resources(mem_device->device->handle, METHOD_NAME__CRS,
 				     acpi_memory_get_resource, mem_device);
 	if (ACPI_FAILURE(status)) {
+		mutex_lock(&mem_device->lock);
 		list_for_each_entry_safe(info, n, &mem_device->res_list, list)
 			kfree(info);
 		INIT_LIST_HEAD(&mem_device->res_list);
+		mutex_unlock(&mem_device->lock);
 		return -EINVAL;
 	}
 
@@ -236,6 +244,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 	 * We don't have memory-hot-add rollback function,now.
 	 * (i.e. memory-hot-remove function)
 	 */
+	mutex_lock(&mem_device->lock);
 	list_for_each_entry(info, &mem_device->res_list, list) {
 		if (info->enabled) { /* just sanity check...*/
 			num_enabled++;
@@ -256,6 +265,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 		info->enabled = 1;
 		num_enabled++;
 	}
+	mutex_unlock(&mem_device->lock);
 	if (!num_enabled) {
 		printk(KERN_ERR PREFIX "add_memory failed\n");
 		mem_device->state = MEMORY_INVALID_STATE;
@@ -316,6 +326,7 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
 	 * Ask the VM to offline this memory range.
 	 * Note: Assume that this function returns zero on success
 	 */
+	mutex_lock(&mem_device->lock);
 	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
 		if (info->enabled) {
 			result = remove_memory(info->start_addr, info->length);
@@ -324,6 +335,7 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
 		}
 		kfree(info);
 	}
+	mutex_unlock(&mem_device->lock);
 
 	/* Power-off and eject the device */
 	result = acpi_memory_powerdown_device(mem_device);
@@ -438,6 +450,7 @@ static int acpi_memory_device_add(struct acpi_device *device)
 	mem_device->device = device;
 	sprintf(acpi_device_name(device), "%s", ACPI_MEMORY_DEVICE_NAME);
 	sprintf(acpi_device_class(device), "%s", ACPI_MEMORY_DEVICE_CLASS);
+	mutex_init(&mem_device->lock);
 	device->driver_data = mem_device;
 
 	/* Get the range from the _CRS */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
