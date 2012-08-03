Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 6D7C66B005A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 03:44:57 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC PATCH V6 01/19] memory-hotplug: rename remove_memory() to offline_memory()/offline_pages()
Date: Fri, 3 Aug 2012 15:49:03 +0800
Message-Id: <1343980161-14254-2-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1343980161-14254-1-git-send-email-wency@cn.fujitsu.com>
References: <1343980161-14254-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

remove_memory() only try to offline pages. It is called in two cases:
1. hot remove a memory device
2. echo offline >/sys/devices/system/memory/memoryXX/state

In the 1st case, we should also change memory block's state, and notify
the userspace that the memory block's state is changed after offlining
pages.

So rename remove_memory() to offline_memory()/offline_pages(). And in
the 1st case, offline_memory() will be used. The function offline_memory()
is not implemented. In the 2nd case, offline_pages() will be used.

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
 drivers/acpi/acpi_memhotplug.c |    2 +-
 drivers/base/memory.c          |    9 +++------
 include/linux/memory_hotplug.h |    3 ++-
 mm/memory_hotplug.c            |   22 ++++++++++++++--------
 4 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 81a9def..8957ed9 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -318,7 +318,7 @@ static int acpi_memory_disable_device(struct acpi_memory_device *mem_device)
 	 */
 	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
 		if (info->enabled) {
-			result = remove_memory(info->start_addr, info->length);
+			result = offline_memory(info->start_addr, info->length);
 			if (result)
 				return result;
 		}
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 7dda4f7..44e7de6 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -248,26 +248,23 @@ static bool pages_correctly_reserved(unsigned long start_pfn,
 static int
 memory_block_action(unsigned long phys_index, unsigned long action)
 {
-	unsigned long start_pfn, start_paddr;
+	unsigned long start_pfn;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 	struct page *first_page;
 	int ret;
 
 	first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
+	start_pfn = page_to_pfn(first_page);
 
 	switch (action) {
 		case MEM_ONLINE:
-			start_pfn = page_to_pfn(first_page);
-
 			if (!pages_correctly_reserved(start_pfn, nr_pages))
 				return -EBUSY;
 
 			ret = online_pages(start_pfn, nr_pages);
 			break;
 		case MEM_OFFLINE:
-			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
-			ret = remove_memory(start_paddr,
-					    nr_pages << PAGE_SHIFT);
+			ret = offline_pages(start_pfn, nr_pages);
 			break;
 		default:
 			WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 910550f..c183f39 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -233,7 +233,8 @@ static inline int is_mem_section_removable(unsigned long pfn,
 extern int mem_online_node(int nid);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
-extern int remove_memory(u64 start, u64 size);
+extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
+extern int offline_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3ad25f9..c182c76 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -866,7 +866,7 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	return offlined;
 }
 
-static int __ref offline_pages(unsigned long start_pfn,
+static int __ref __offline_pages(unsigned long start_pfn,
 		  unsigned long end_pfn, unsigned long timeout)
 {
 	unsigned long pfn, nr_pages, expire;
@@ -994,18 +994,24 @@ out:
 	return ret;
 }
 
-int remove_memory(u64 start, u64 size)
+int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
-	unsigned long start_pfn, end_pfn;
+	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);
+}
 
-	start_pfn = PFN_DOWN(start);
-	end_pfn = start_pfn + PFN_DOWN(size);
-	return offline_pages(start_pfn, end_pfn, 120 * HZ);
+int offline_memory(u64 start, u64 size)
+{
+	return -EINVAL;
 }
 #else
-int remove_memory(u64 start, u64 size)
+int offline_pages(u64 start, u64 size)
+{
+	return -EINVAL;
+}
+
+int offline_memory(u64 start, u64 size)
 {
 	return -EINVAL;
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
-EXPORT_SYMBOL_GPL(remove_memory);
+EXPORT_SYMBOL_GPL(offline_memory);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
