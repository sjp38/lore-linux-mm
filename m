Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B0F1D8D0003
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 07:10:34 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v5 13/14] memory-hotplug: remove sysfs file of node
Date: Mon, 24 Dec 2012 20:09:23 +0800
Message-Id: <1356350964-13437-14-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

This patch introduces a new function try_offline_node() to
remove sysfs file of node when all memory sections of this
node are removed. If some memory sections of this node are
not removed, this function does nothing.

Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 drivers/acpi/acpi_memhotplug.c |    8 ++++-
 include/linux/memory_hotplug.h |    2 +-
 mm/memory_hotplug.c            |   58 ++++++++++++++++++++++++++++++++++++++-
 3 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index eb30e5a..9c53cc6 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -295,9 +295,11 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 
 static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
 {
-	int result = 0;
+	int result = 0, nid;
 	struct acpi_memory_info *info, *n;
 
+	nid = acpi_get_node(mem_device->device->handle);
+
 	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
 		if (info->failed)
 			/* The kernel does not use this memory block */
@@ -310,7 +312,9 @@ static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
 			 */
 			return -EBUSY;
 
-		result = remove_memory(info->start_addr, info->length);
+		if (nid < 0)
+			nid = memory_add_physaddr_to_nid(info->start_addr);
+		result = remove_memory(nid, info->start_addr, info->length);
 		if (result)
 			return result;
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 2441f36..f60e728 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -242,7 +242,7 @@ extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern int offline_memory_block(struct memory_block *mem);
 extern bool is_memblock_offlined(struct memory_block *mem);
-extern int remove_memory(u64 start, u64 size);
+extern int remove_memory(int nid, u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a1b0632..f8a1d2f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -29,6 +29,7 @@
 #include <linux/suspend.h>
 #include <linux/mm_inline.h>
 #include <linux/firmware-map.h>
+#include <linux/stop_machine.h>
 
 #include <asm/tlbflush.h>
 
@@ -1659,7 +1660,58 @@ static int is_memblock_offlined_cb(struct memory_block *mem, void *arg)
 	return ret;
 }
 
-int __ref remove_memory(u64 start, u64 size)
+static int check_cpu_on_node(void *data)
+{
+	struct pglist_data *pgdat = data;
+	int cpu;
+
+	for_each_present_cpu(cpu) {
+		if (cpu_to_node(cpu) == pgdat->node_id)
+			/*
+			 * the cpu on this node isn't removed, and we can't
+			 * offline this node.
+			 */
+			return -EBUSY;
+	}
+
+	return 0;
+}
+
+/* offline the node if all memory sections of this node are removed */
+static void try_offline_node(int nid)
+{
+	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
+	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
+	unsigned long pfn;
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		unsigned long section_nr = pfn_to_section_nr(pfn);
+
+		if (!present_section_nr(section_nr))
+			continue;
+
+		if (pfn_to_nid(pfn) != nid)
+			continue;
+
+		/*
+		 * some memory sections of this node are not removed, and we
+		 * can't offline node now.
+		 */
+		return;
+	}
+
+	if (stop_machine(check_cpu_on_node, NODE_DATA(nid), NULL))
+		return;
+
+	/*
+	 * all memory/cpu of this node are removed, we can offline this
+	 * node now.
+	 */
+	node_set_offline(nid);
+	unregister_one_node(nid);
+}
+
+int __ref remove_memory(int nid, u64 start, u64 size)
 {
 	unsigned long start_pfn, end_pfn;
 	int ret = 0;
@@ -1706,6 +1758,8 @@ repeat:
 
 	arch_remove_memory(start, size);
 
+	try_offline_node(nid);
+
 	unlock_memory_hotplug();
 
 	return 0;
@@ -1715,7 +1769,7 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
 	return -EINVAL;
 }
-int remove_memory(u64 start, u64 size)
+int remove_memory(int nid, u64 start, u64 size)
 {
 	return -EINVAL;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
