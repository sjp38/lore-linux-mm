Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 53CD46B005A
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 05:58:58 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 1/7] acpi,memory-hotplug: introduce a mutex lock to protect the list in acpi_memory_device
Date: Thu, 8 Nov 2012 19:04:47 +0800
Message-Id: <1352372693-32411-2-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352372693-32411-1-git-send-email-wency@cn.fujitsu.com>
References: <1352372693-32411-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

The memory device can be removed by 2 ways:
1. send eject request by SCI
2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject

This 2 events may happen at the same time, so we may touch
acpi_memory_device.res_list at the same time. This patch
introduce a lock to protect this list.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Rafael J. Wysocki <rjw@sisk.pl>
CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 The commit in pm tree is 85fcb375
 drivers/acpi/acpi_memhotplug.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 1e90e8f..4c18ee3 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -83,7 +83,8 @@ struct acpi_memory_info {
 struct acpi_memory_device {
 	struct acpi_device * device;
 	unsigned int state;	/* State of the memory device */
-	struct list_head res_list;
+	struct mutex list_lock;
+	struct list_head res_list;	/* protected by list_lock */
 };
 
 static int acpi_hotmem_initialized;
@@ -101,19 +102,23 @@ acpi_memory_get_resource(struct acpi_resource *resource, void *context)
 	    (address64.resource_type != ACPI_MEMORY_RANGE))
 		return AE_OK;
 
+	mutex_lock(&mem_device->list_lock);
 	list_for_each_entry(info, &mem_device->res_list, list) {
 		/* Can we combine the resource range information? */
 		if ((info->caching == address64.info.mem.caching) &&
 		    (info->write_protect == address64.info.mem.write_protect) &&
 		    (info->start_addr + info->length == address64.minimum)) {
 			info->length += address64.address_length;
+			mutex_unlock(&mem_device->list_lock);
 			return AE_OK;
 		}
 	}
 
 	new = kzalloc(sizeof(struct acpi_memory_info), GFP_KERNEL);
-	if (!new)
+	if (!new) {
+		mutex_unlock(&mem_device->list_lock);
 		return AE_ERROR;
+	}
 
 	INIT_LIST_HEAD(&new->list);
 	new->caching = address64.info.mem.caching;
@@ -121,6 +126,7 @@ acpi_memory_get_resource(struct acpi_resource *resource, void *context)
 	new->start_addr = address64.minimum;
 	new->length = address64.address_length;
 	list_add_tail(&new->list, &mem_device->res_list);
+	mutex_unlock(&mem_device->list_lock);
 
 	return AE_OK;
 }
@@ -138,9 +144,11 @@ acpi_memory_get_device_resources(struct acpi_memory_device *mem_device)
 	status = acpi_walk_resources(mem_device->device->handle, METHOD_NAME__CRS,
 				     acpi_memory_get_resource, mem_device);
 	if (ACPI_FAILURE(status)) {
+		mutex_lock(&mem_device->list_lock);
 		list_for_each_entry_safe(info, n, &mem_device->res_list, list)
 			kfree(info);
 		INIT_LIST_HEAD(&mem_device->res_list);
+		mutex_unlock(&mem_device->list_lock);
 		return -EINVAL;
 	}
 
@@ -236,6 +244,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 	 * We don't have memory-hot-add rollback function,now.
 	 * (i.e. memory-hot-remove function)
 	 */
+	mutex_lock(&mem_device->list_lock);
 	list_for_each_entry(info, &mem_device->res_list, list) {
 		if (info->enabled) { /* just sanity check...*/
 			num_enabled++;
@@ -256,6 +265,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 		info->enabled = 1;
 		num_enabled++;
 	}
+	mutex_unlock(&mem_device->list_lock);
 	if (!num_enabled) {
 		printk(KERN_ERR PREFIX "add_memory failed\n");
 		mem_device->state = MEMORY_INVALID_STATE;
@@ -316,14 +326,18 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
 	 * Ask the VM to offline this memory range.
 	 * Note: Assume that this function returns zero on success
 	 */
+	mutex_lock(&mem_device->list_lock);
 	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
 		if (info->enabled) {
 			result = remove_memory(info->start_addr, info->length);
-			if (result)
+			if (result) {
+				mutex_unlock(&mem_device->list_lock);
 				return result;
+			}
 		}
 		kfree(info);
 	}
+	mutex_unlock(&mem_device->list_lock);
 
 	/* Power-off and eject the device */
 	result = acpi_memory_powerdown_device(mem_device);
@@ -438,6 +452,7 @@ static int acpi_memory_device_add(struct acpi_device *device)
 	mem_device->device = device;
 	sprintf(acpi_device_name(device), "%s", ACPI_MEMORY_DEVICE_NAME);
 	sprintf(acpi_device_class(device), "%s", ACPI_MEMORY_DEVICE_CLASS);
+	mutex_init(&mem_device->list_lock);
 	device->driver_data = mem_device;
 
 	/* Get the range from the _CRS */
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
