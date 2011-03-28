Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14EEC8D0047
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:25:10 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1578893Ab1C1JZH (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 28 Mar 2011 11:25:07 +0200
Date: Mon, 28 Mar 2011 11:25:07 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 3/3] mm: Extend memory hotplug API to allow memory hotplug in virtual machines
Message-ID: <20110328092507.GD13826@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch contains online_page_chain and apropriate functions
for registering/unregistering online page notifiers. It allows
to do some machine specific tasks during online page stage which
is required to implement memory hotplug in virtual machines.
Additionally, __online_page_increment_counters() and
__online_page_free() function was add to ease generic
hotplug operation.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 include/linux/memory_hotplug.h |   11 ++++-
 mm/memory_hotplug.c            |   82 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 88 insertions(+), 5 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 8122018..d8cc963 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -12,6 +12,9 @@ struct mem_section;
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 
+#define OP_DO_NOT_INCREMENT_TOTAL_COUNTERS	0
+#define OP_INCREMENT_TOTAL_COUNTERS		1
+
 /*
  * Types for free bootmem stored in page->lru.next. These have to be in
  * some random range in unsigned long space for debugging purposes.
@@ -68,12 +71,16 @@ static inline void zone_seqlock_init(struct zone *zone)
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
+void __online_page_increment_counters(struct page *page, int inc_total);
+void __online_page_free(struct page *page);
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f0651ae..2f62e26 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -29,11 +29,23 @@
 #include <linux/suspend.h>
 #include <linux/mm_inline.h>
 #include <linux/firmware-map.h>
+#include <linux/notifier.h>
 
 #include <asm/tlbflush.h>
 
 #include "internal.h"
 
+/*
+ * online_page_chain contains chain of notifiers called when page is onlined.
+ * When kernel is booting generic_online_page_notifier() is registered with
+ * priority 0 as default notifier. Custom notifier should be registered with
+ * priority > 0. It could be terminal (it should return NOTIFY_STOP on success)
+ * or not (it should return NOTIFY_DONE or NOTIFY_OK on success; for full list
+ * of return codes look into include/linux/notifier.h).
+ */
+
+static RAW_NOTIFIER_HEAD(online_page_chain);
+
 DEFINE_MUTEX(mem_hotplug_mutex);
 
 void lock_memory_hotplug(void)
@@ -361,27 +373,91 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
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
+void __online_page_increment_counters(struct page *page, int inc_total)
 {
 	unsigned long pfn = page_to_pfn(page);
 
-	totalram_pages++;
+	if (inc_total == OP_INCREMENT_TOTAL_COUNTERS)
+		totalram_pages++;
+
 	if (pfn >= num_physpages)
 		num_physpages = pfn + 1;
 
 #ifdef CONFIG_HIGHMEM
-	if (PageHighMem(page))
+	if (inc_total == OP_INCREMENT_TOTAL_COUNTERS && PageHighMem(page))
 		totalhigh_pages++;
 #endif
 
 #ifdef CONFIG_FLATMEM
 	max_mapnr = max(pfn, max_mapnr);
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
+static int generic_online_page_notifier(struct notifier_block *nb, unsigned long val, void *v)
+{
+	struct page *page = v;
+
+	__online_page_increment_counters(page, OP_INCREMENT_TOTAL_COUNTERS);
+	__online_page_free(page);
+
+	return NOTIFY_OK;
+}
+
+/*
+ * 0 priority makes this the fallthrough default. All
+ * architectures wanting to override this should set
+ * a higher priority and return NOTIFY_STOP to keep
+ * this from running.
+ */
+
+static struct notifier_block generic_online_page_nb = {
+	.notifier_call = generic_online_page_notifier,
+	.priority = 0
+};
+
+static int __init init_online_page_chain(void)
+{
+	return register_online_page_notifier(&generic_online_page_nb);
+}
+pure_initcall(init_online_page_chain);
+
+static void online_page(struct page *page)
+{
+	raw_notifier_call_chain(&online_page_chain, 0, page);
+}
 
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 			void *arg)
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
