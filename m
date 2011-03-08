Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D34908D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 16:50:22 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1578060Ab1CHVuD (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 8 Mar 2011 22:50:03 +0100
Date: Tue, 8 Mar 2011 22:50:03 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R4 6/7] mm: Extend memory hotplug API to allow memory hotplug in virtual guests
Message-ID: <20110308215003.GG27331@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch extends memory hotplug API to allow easy memory hotplug
in virtual guests. It contains:
  - generic section aligment macro,
  - online_page_chain and apropriate functions for registering/unregistering
    online page notifiers,
  - add_virtual_memory(u64 *size) function which adds memory region
    of size >= *size above max_pfn; new region is section aligned
    and size is modified to be multiple of section size.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 include/linux/memory_hotplug.h |    6 ++-
 include/linux/mmzone.h         |    2 +
 mm/memory_hotplug.c            |   91 +++++++++++++++++++++++++++++++++++++++-
 3 files changed, 95 insertions(+), 4 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 8122018..4cfc5a0 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -68,12 +68,13 @@ static inline void zone_seqlock_init(struct zone *zone)
 extern int zone_grow_free_lists(struct zone *zone, unsigned long new_nr_pages);
 extern int zone_grow_waitqueues(struct zone *zone, unsigned long nr_pages);
 extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
-/* need some defines for these for archs that don't support it */
-extern void online_page(struct page *page);
 /* VM interface that may be used by firmware interface */
 extern int online_pages(unsigned long, unsigned long);
 extern void __offline_isolated_pages(unsigned long, unsigned long);
 
+extern int register_online_page_notifier(struct notifier_block *nb);
+extern int unregister_online_page_notifier(struct notifier_block *nb);
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
@@ -224,6 +225,7 @@ static inline int is_mem_section_removable(unsigned long pfn,
 
 extern int mem_online_node(int nid);
 extern int add_memory(int nid, u64 start, u64 size);
+extern int add_virtual_memory(u64 *size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int remove_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 02ecb01..76a7cbd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -931,6 +931,8 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
 #define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
 
+#define SECTION_ALIGN(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
+
 #ifdef CONFIG_SPARSEMEM
 
 /*
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 321fc74..3b38d89 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -29,11 +29,25 @@
 #include <linux/suspend.h>
 #include <linux/mm_inline.h>
 #include <linux/firmware-map.h>
+#include <linux/notifier.h>
 
 #include <asm/tlbflush.h>
 
 #include "internal.h"
 
+/*
+ * online_page_chain contains chain of notifiers called when page is onlined.
+ * When kernel is booting native_online_page_notifier() is registered with
+ * priority 0 as default notifier. Custom notifier should be registered with
+ * pririty > 0. It could be terminal (it should return NOTIFY_STOP on success)
+ * or not (it should return NOTIFY_DONE or NOTIFY_OK on success; for full list
+ * of return codes look into include/linux/notifier.h).
+ *
+ * Working example of usage: drivers/xen/balloon.c
+ */
+
+static RAW_NOTIFIER_HEAD(online_page_chain);
+
 DEFINE_MUTEX(mem_hotplug_mutex);
 
 void lock_memory_hotplug(void)
@@ -361,8 +375,33 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 }
 EXPORT_SYMBOL_GPL(__remove_pages);
 
-void online_page(struct page *page)
+int register_online_page_notifier(struct notifier_block *nb)
+{
+	int rc;
+
+	lock_memory_hotplug();
+	rc = raw_notifier_chain_register(&online_page_chain, nb);
+	unlock_memory_hotplug();
+
+	return rc;
+}
+EXPORT_SYMBOL_GPL(register_online_page_notifier);
+
+int unregister_online_page_notifier(struct notifier_block *nb)
+{
+	int rc;
+
+	lock_memory_hotplug();
+	rc = raw_notifier_chain_unregister(&online_page_chain, nb);
+	unlock_memory_hotplug();
+
+	return rc;
+}
+EXPORT_SYMBOL_GPL(unregister_online_page_notifier);
+
+static int native_online_page_notifier(struct notifier_block *nb, unsigned long val, void *v)
 {
+	struct page *page = v;
 	unsigned long pfn = page_to_pfn(page);
 
 	totalram_pages++;
@@ -375,12 +414,30 @@ void online_page(struct page *page)
 #endif
 
 #ifdef CONFIG_FLATMEM
-	max_mapnr = max(page_to_pfn(page), max_mapnr);
+	max_mapnr = max(pfn, max_mapnr);
 #endif
 
 	ClearPageReserved(page);
 	init_page_count(page);
 	__free_page(page);
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block native_online_page_nb = {
+	.notifier_call = native_online_page_notifier,
+	.priority = 0
+};
+
+static int __init init_online_page_chain(void)
+{
+	return register_online_page_notifier(&native_online_page_nb);
+}
+pure_initcall(init_online_page_chain);
+
+static void online_page(struct page *page)
+{
+	raw_notifier_call_chain(&online_page_chain, 0, page);
 }
 
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
@@ -591,6 +648,36 @@ out:
 }
 EXPORT_SYMBOL_GPL(add_memory);
 
+/*
+ * add_virtual_memory() adds memory region of size >= *size above max_pfn.
+ * New region is section aligned and size is modified to be multiple of
+ * section size. Those features allow optimal use of address space and
+ * establish proper aligment when this function is called first time after
+ * boot (last section not fully populated at boot time may contains unused
+ * memory pages with PG_reserved bit not set; online_pages() does not allow
+ * page onlining in whole section if first page does not have PG_reserved
+ * bit set). Real size of added memory should be established at page onlining
+ * stage.
+ *
+ * This function is often used in virtual guests because mainly they do not
+ * care about new memory region address.
+ *
+ * Working example of usage: drivers/xen/balloon.c
+ */
+
+int add_virtual_memory(u64 *size)
+{
+	int nid;
+	u64 start;
+
+	start = PFN_PHYS(SECTION_ALIGN(max_pfn));
+	*size = (((*size >> PAGE_SHIFT) & PAGE_SECTION_MASK) + PAGES_PER_SECTION) << PAGE_SHIFT;
+	nid = memory_add_physaddr_to_nid(start);
+
+	return add_memory(nid, start, *size);
+}
+EXPORT_SYMBOL_GPL(add_virtual_memory);
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
