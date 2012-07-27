Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 713886B005D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:22:46 -0400 (EDT)
Message-ID: <50126D22.4020003@cn.fujitsu.com>
Date: Fri, 27 Jul 2012 18:27:46 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v5 04/19] memory-hotplug: offline and remove memory when
 removing the memory device
References: <50126B83.3050201@cn.fujitsu.com>
In-Reply-To: <50126B83.3050201@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

We should offline and remove memory when removing the memory device.
The memory device can be removed by 2 ways:
1. send eject request by SCI
2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject

In the 1st case, acpi_memory_disable_device() will be called. In the 2nd
case, acpi_memory_device_remove() will be called. acpi_memory_device_remove()
will also be called when we unbind the memory device from the driver
acpi_memhotplug. If the type is ACPI_BUS_REMOVAL_EJECT, it means
that the user wants to eject the memory device, and we should offline
and remove memory in acpi_memory_device_remove().

The function remove_memory() is not implemeted now. It only check whether
all memory has been offllined now.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/acpi/acpi_memhotplug.c |   42 +++++++++++++++++++++++++++++++++------
 drivers/base/memory.c          |   39 +++++++++++++++++++++++++++++++++++++
 include/linux/memory.h         |    5 ++++
 include/linux/memory_hotplug.h |    5 ++++
 mm/memory_hotplug.c            |   22 ++++++++++++++++++++
 5 files changed, 106 insertions(+), 7 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 293d718..ed37fc2 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -29,6 +29,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/types.h>
+#include <linux/memory.h>
 #include <linux/memory_hotplug.h>
 #include <linux/slab.h>
 #include <acpi/acpi_drivers.h>
@@ -310,26 +311,42 @@ static int acpi_memory_powerdown_device(struct acpi_memory_device *mem_device)
 	return 0;
 }
 
-static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
+static int
+acpi_memory_device_remove_memory(struct acpi_memory_device *mem_device)
 {
 	int result;
 	struct acpi_memory_info *info, *n;
+	int node = mem_device->nid;
 
-
-	/*
-	 * Ask the VM to offline this memory range.
-	 * Note: Assume that this function returns zero on success
-	 */
 	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
 		if (info->enabled) {
 			result = offline_memory(info->start_addr, info->length);
 			if (result)
 				return result;
+
+			result = remove_memory(node, info->start_addr,
+					       info->length);
+			if (result)
+				return result;
 		}
+
 		list_del(&info->list);
 		kfree(info);
 	}
 
+	return 0;
+}
+
+static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
+{
+	int result;
+
+	/*
+	 * Ask the VM to offline this memory range.
+	 * Note: Assume that this function returns zero on success
+	 */
+	result = acpi_memory_device_remove_memory(mem_device);
+
 	/* Power-off and eject the device */
 	result = acpi_memory_powerdown_device(mem_device);
 	if (result) {
@@ -478,12 +495,23 @@ static int acpi_memory_device_add(struct acpi_device *device)
 static int acpi_memory_device_remove(struct acpi_device *device, int type)
 {
 	struct acpi_memory_device *mem_device = NULL;
-
+	int result;
 
 	if (!device || !acpi_driver_data(device))
 		return -EINVAL;
 
 	mem_device = acpi_driver_data(device);
+
+	if (type == ACPI_BUS_REMOVAL_EJECT) {
+		/*
+		 * offline and remove memory only when the memory device is
+		 * ejected.
+		 */
+		result = acpi_memory_device_remove_memory(mem_device);
+		if (result)
+			return result;
+	}
+
 	kfree(mem_device);
 
 	return 0;
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 86c8821..038be73 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -70,6 +70,45 @@ void unregister_memory_isolate_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL(unregister_memory_isolate_notifier);
 
+bool is_memblk_offline(unsigned long start, unsigned long size)
+{
+	struct memory_block *mem = NULL;
+	struct mem_section *section;
+	unsigned long start_pfn, end_pfn;
+	unsigned long pfn, section_nr;
+
+	start_pfn = PFN_DOWN(start);
+	end_pfn = PFN_UP(start + size);
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		section_nr = pfn_to_section_nr(pfn);
+		if (!present_section_nr(section_nr))
+			continue;
+
+		section = __nr_to_section(section_nr);
+		/* same memblock? */
+		if (mem)
+			if ((section_nr >= mem->start_section_nr) &&
+			    (section_nr <= mem->end_section_nr))
+				continue;
+
+		mem = find_memory_block_hinted(section, mem);
+		if (!mem)
+			continue;
+		if (mem->state == MEM_OFFLINE)
+			continue;
+
+		kobject_put(&mem->dev.kobj);
+		return false;
+	}
+
+	if (mem)
+		kobject_put(&mem->dev.kobj);
+
+	return true;
+}
+EXPORT_SYMBOL(is_memblk_offline);
+
 /*
  * register_memory - Setup a sysfs device for a memory block
  */
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 1ac7f6e..7c66126 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -106,6 +106,10 @@ static inline int memory_isolate_notify(unsigned long val, void *v)
 {
 	return 0;
 }
+static inline bool is_memblk_offline(unsigned long start, unsigned long size)
+{
+	return false;
+}
 #else
 extern int register_memory_notifier(struct notifier_block *nb);
 extern void unregister_memory_notifier(struct notifier_block *nb);
@@ -120,6 +124,7 @@ extern int memory_isolate_notify(unsigned long val, void *v);
 extern struct memory_block *find_memory_block_hinted(struct mem_section *,
 							struct memory_block *);
 extern struct memory_block *find_memory_block(struct mem_section *);
+extern bool is_memblk_offline(unsigned long start, unsigned long size);
 #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
 enum mem_add_context { BOOT, HOTPLUG };
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 0b040bb..fd84ea9 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -222,6 +222,7 @@ static inline void unlock_memory_hotplug(void) {}
 #ifdef CONFIG_MEMORY_HOTREMOVE
 
 extern int is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
+extern int remove_memory(int nid, u64 start, u64 size);
 
 #else
 static inline int is_mem_section_removable(unsigned long pfn,
@@ -229,6 +230,10 @@ static inline int is_mem_section_removable(unsigned long pfn,
 {
 	return 0;
 }
+static inline int remove_memory(int nid, u64 start, u64 size)
+{
+	return -EBUSY;
+}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 extern int mem_online_node(int nid);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 992454a..5af0a9f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1034,6 +1034,28 @@ int offline_memory(u64 start, u64 size)
 
 	return 0;
 }
+
+int remove_memory(int nid, u64 start, u64 size)
+{
+	int ret = -EBUSY;
+	lock_memory_hotplug();
+	/*
+	 * The memory might become online by other task, even if you offine it.
+	 * So we check whether the cpu has been onlined or not.
+	 */
+	if (!is_memblk_offline(start, size)) {
+		pr_warn("memory removing [mem %#010llx-%#010llx] failed, "
+			"because the memmory range is online\n",
+			start, start + size);
+		ret = -EAGAIN;
+	}
+
+	unlock_memory_hotplug();
+	return ret;
+
+}
+EXPORT_SYMBOL_GPL(remove_memory);
+
 #else
 int offline_pages(u64 start, u64 size)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
