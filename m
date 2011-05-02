Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB9F6B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 17:49:46 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1581921Ab1EBVtV (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 2 May 2011 23:49:21 +0200
Date: Mon, 2 May 2011 23:49:21 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH V2 2/2] mm: Extend memory hotplug API to allow memory hotplug in virtual machines
Message-ID: <20110502214921.GH4623@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch contains online_page_callback and apropriate functions for
registering/unregistering online page callbacks. It allows to do some
machine specific tasks during online page stage which is required
to implement memory hotplug in virtual machines. Additionally,
__online_page_set_limits(), __online_page_increment_counters() and
__online_page_free() function was added to ease generic
hotplug operation.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 include/linux/memory_hotplug.h |   11 +++++-
 mm/memory_hotplug.c            |   68 ++++++++++++++++++++++++++++++++++++++--
 2 files changed, 74 insertions(+), 5 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 8122018..014bd96 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -68,12 +68,19 @@ static inline void zone_seqlock_init(struct zone *zone)
 extern int zone_grow_free_lists(struct zone *zone, unsigned long new_nr_pages);
 extern int zone_grow_waitqueues(struct zone *zone, unsigned long nr_pages);
 extern int add_one_highpage(struct page *page, int pfn, int bad_ppro);
-/* need some defines for these for archs that don't support it */
-extern void online_page(struct page *page);
 /* VM interface that may be used by firmware interface */
 extern int online_pages(unsigned long, unsigned long);
 extern void __offline_isolated_pages(unsigned long, unsigned long);
 
+typedef void (*online_page_callback_t)(struct page *page);
+
+extern int register_online_page_callback(online_page_callback_t callback);
+extern int unregister_online_page_callback(online_page_callback_t callback);
+
+extern void __online_page_set_limits(struct page *page);
+extern void __online_page_increment_counters(struct page *page);
+extern void __online_page_free(struct page *page);
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a807ccb..6bf78be 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -34,6 +34,17 @@
 
 #include "internal.h"
 
+/*
+ * online_page_callback contains pointer to current page onlining function.
+ * Initially it is generic_online_page(). If it is required it could be
+ * changed by calling register_online_page_callback() for callback registration
+ * and unregister_online_page_callback() for callback unregistration.
+ */
+
+static void generic_online_page(struct page *page);
+
+static online_page_callback_t online_page_callback = generic_online_page;
+
 DEFINE_MUTEX(mem_hotplug_mutex);
 
 void lock_memory_hotplug(void)
@@ -361,23 +372,74 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 }
 EXPORT_SYMBOL_GPL(__remove_pages);
 
-void online_page(struct page *page)
+int register_online_page_callback(online_page_callback_t callback)
+{
+	int rc = -EPERM;
+
+	lock_memory_hotplug();
+
+	if (online_page_callback == generic_online_page) {
+		online_page_callback = callback;
+		rc = 0;
+	}
+
+	unlock_memory_hotplug();
+
+	return rc;
+}
+EXPORT_SYMBOL_GPL(register_online_page_callback);
+
+int unregister_online_page_callback(online_page_callback_t callback)
+{
+	int rc = -EPERM;
+
+	lock_memory_hotplug();
+
+	if (online_page_callback == callback) {
+		online_page_callback = generic_online_page;
+		rc = 0;
+	}
+
+	unlock_memory_hotplug();
+
+	return rc;
+}
+EXPORT_SYMBOL_GPL(unregister_online_page_callback);
+
+void __online_page_set_limits(struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
 
-	totalram_pages++;
 	if (pfn >= num_physpages)
 		num_physpages = pfn + 1;
+}
+EXPORT_SYMBOL_GPL(__online_page_set_limits);
+
+void __online_page_increment_counters(struct page *page)
+{
+	totalram_pages++;
 
 #ifdef CONFIG_HIGHMEM
 	if (PageHighMem(page))
 		totalhigh_pages++;
 #endif
+}
+EXPORT_SYMBOL_GPL(__online_page_increment_counters);
 
+void __online_page_free(struct page *page)
+{
 	ClearPageReserved(page);
 	init_page_count(page);
 	__free_page(page);
 }
+EXPORT_SYMBOL_GPL(__online_page_free);
+
+static void generic_online_page(struct page *page)
+{
+	__online_page_set_limits(page);
+	__online_page_increment_counters(page);
+	__online_page_free(page);
+}
 
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 			void *arg)
@@ -388,7 +450,7 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	if (PageReserved(pfn_to_page(start_pfn)))
 		for (i = 0; i < nr_pages; i++) {
 			page = pfn_to_page(start_pfn + i);
-			online_page(page);
+			online_page_callback(page);
 			onlined_pages++;
 		}
 	*(unsigned long *)arg = onlined_pages;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
