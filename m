Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 52B2F6B00E4
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 23:23:49 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D3NltG032117
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Oct 2010 12:23:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A901E45DE51
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:23:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 87E8645DE4F
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:23:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B2BAE38001
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:23:47 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F6A91DB8038
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:23:47 +0900 (JST)
Date: Wed, 13 Oct 2010 12:18:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/3] alloc contig pages with migration.
Message-Id: <20101013121829.c3320944.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Add an function to allocate contigous memory larger than MAX_ORDER.
The main difference between usual page allocater is that this uses
memory offline techiqueue (Isoalte pages and migrate remaining pages.).

I think this is not 100% solution because we can't avoid fragmentation,
but we have kernelcore= boot option and can create MOVABLE zone. That
helps us to allow allocate a contigous range on demand.

Maybe drivers can alloc contig pages by bootmem or hiding some memory
from the kernel at boot. But if contig pages are necessary only in some
situation, kernelcore= boot option and using page migration is a choice.

Anyway, to allocate a contiguous chunk larger than MAX_ORDER, we need to
add an overlay allocator on buddy allocator. This can be a 1st step.

Note:
This function is heavy if there are tons of memory requesters. So, maybe
not good for 1GB pages for x86's usual use. It will requires some other
tricks than migration.

TODO:
 - allows the caller to specify the migration target pages.
 - reduce the number of lru_add_drain_all()..etc...system wide heavy calls.
 - Pass gfp_t for some purpose...

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page-isolation.h |    8 ++
 mm/page_alloc.c                |   29 ++++++++
 mm/page_isolation.c            |  136 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 173 insertions(+)

Index: mmotm-1008/mm/page_isolation.c
===================================================================
--- mmotm-1008.orig/mm/page_isolation.c
+++ mmotm-1008/mm/page_isolation.c
@@ -7,6 +7,7 @@
 #include <linux/mm.h>
 #include <linux/page-isolation.h>
 #include <linux/pageblock-flags.h>
+#include <linux/swap.h>
 #include <linux/memcontrol.h>
 #include <linux/migrate.h>
 #include <linux/memory_hotplug.h>
@@ -384,3 +385,138 @@ retry:
 	}
 	return 0;
 }
+
+/**
+ * alloc_contig_pages - allocate a contigous physical pages
+ * @hint:	the base address of searching free space(in pfn)
+ * @size:	size of requested area (in # of pages)
+ * @node:       the node from which memory is allocated. "-1" means anywhere.
+ * @no_search:	if true, "hint" is not a hint, requirement.
+ *
+ * Search an area of @size in the physical memory map and checks wheter
+ * we can create a contigous free space. If it seems possible, try to
+ * create contigous space with page migration. If no_search==true, we just try
+ * to allocate [hint, hint+size) range of pages as contigous block.
+ *
+ * Returns a page of the beginning of contiguous block. At failure, NULL
+ * is returned. Each page in the area is set to page_count() = 1. Because
+ * this function does page migration, this function is very heavy and
+ * sleeps some time. Caller must be aware that "NULL returned" is not a
+ * special case.
+ *
+ * Now, returned range is aligned to MAX_ORDER. (So "hint" must be aligned
+ * if no_search==true.)
+ */
+
+#define MIGRATION_RETRY	(5)
+struct page *alloc_contig_pages(unsigned long hint, unsigned long size,
+				int node, bool no_search)
+{
+	unsigned long base, found, end, pages, start;
+	struct page *ret = NULL;
+	int migration_failed;
+	struct zone *zone;
+
+	hint = MAX_ORDER_ALIGN(hint);
+	/*
+	 * request size should be aligned to pageblock_order..but use
+	 * MAX_ORDER here for avoiding messy checks.
+	 */
+	pages = MAX_ORDER_ALIGN(size);
+	found = 0;
+retry:
+	for_each_populated_zone(zone) {
+		unsigned long zone_end_pfn;
+
+		if (node >= 0 && node != zone_to_nid(zone))
+			continue;
+		if (zone->present_pages < pages)
+			continue;
+		base = MAX_ORDER_ALIGN(zone->zone_start_pfn);
+		base = max(base, hint);
+		zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+		if (base + pages > zone_end_pfn)
+			continue;
+		found = find_contig_block(base, zone_end_pfn, pages, no_search);
+		/* Next try will see the next block. */
+		hint = base + MAX_ORDER_NR_PAGES;
+		if (found)
+			break;
+	}
+
+	if (!found)
+		return NULL;
+
+	if (no_search && found != hint)
+		return NULL;
+
+	/*
+	 * Ok, here, we have contiguous pageblock marked as "isolated"
+	 * try migration.
+	 *
+	 * FIXME: permanent migration_failure detection logic is required.
+ 	 */
+	lru_add_drain_all();
+	flush_scheduled_work();
+	drain_all_pages();
+
+	end = found + pages;
+	/*
+	 * scan_lru_pages() finds the next PG_lru page in the range
+	 * scan_lru_pages() returns 0 when it reaches the end.
+	 */
+	for (start = scan_lru_pages(found, end), migration_failed = 0;
+	     start && start < end;
+	     start = scan_lru_pages(start, end)) {
+		if (do_migrate_range(start, end)) {
+			/* it's better to try another block ? */
+			if (++migration_failed >= MIGRATION_RETRY)
+				break;
+			/* take a rest and synchronize LRU etc. */
+			lru_add_drain_all();
+			flush_scheduled_work();
+			cond_resched();
+			drain_all_pages();
+		} else /* reset migration_failure counter */
+			migration_failed = 0;
+	}
+
+	lru_add_drain_all();
+	flush_scheduled_work();
+	drain_all_pages();
+	/* Check all pages are isolated */
+	if (test_pages_isolated(found, end)) {
+		undo_isolate_page_range(found, pages);
+		/*
+		 * We failed at [start...end) migration.
+		 * FIXME: there may be better restaring point.
+		 */
+		hint = MAX_ORDER_ALIGN(end + 1);
+		goto retry; /* goto next chunk */
+	}
+	/*
+	 * Ok, here, [found...found+pages) memory are isolated.
+	 * All pages in the range will be moved into the list with
+	 * page_count(page)=1.
+	 */
+	ret = pfn_to_page(found);
+	alloc_contig_freed_pages(found, found + pages);
+	/* unset ISOLATE */
+	undo_isolate_page_range(found, pages);
+	/* Free unnecessary pages in tail */
+	for (start = found + size; start < found + pages; start++)
+		__free_page(pfn_to_page(start));
+	return ret;
+
+}
+
+
+void free_contig_pages(struct page *page, int nr_pages)
+{
+	int i;
+	for (i = 0; i < nr_pages; i++)
+		__free_page(page + i);
+}
+
+EXPORT_SYMBOL_GPL(alloc_contig_pages);
+EXPORT_SYMBOL_GPL(free_contig_pages);
Index: mmotm-1008/include/linux/page-isolation.h
===================================================================
--- mmotm-1008.orig/include/linux/page-isolation.h
+++ mmotm-1008/include/linux/page-isolation.h
@@ -32,6 +32,7 @@ test_pages_isolated(unsigned long start_
  */
 extern int set_migratetype_isolate(struct page *page);
 extern void unset_migratetype_isolate(struct page *page);
+extern void alloc_contig_freed_pages(unsigned long pfn, unsigned long pages);
 
 /*
  * For migration.
@@ -41,4 +42,11 @@ int test_pages_in_a_zone(unsigned long s
 int scan_lru_pages(unsigned long start, unsigned long end);
 int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn);
 
+/*
+ * For large alloc.
+ */
+struct page *alloc_contig_pages(unsigned long hint, unsigned long size,
+				int node, bool no_search);
+void free_contig_pages(struct page *page, int nr_pages);
+
 #endif
Index: mmotm-1008/mm/page_alloc.c
===================================================================
--- mmotm-1008.orig/mm/page_alloc.c
+++ mmotm-1008/mm/page_alloc.c
@@ -5430,6 +5430,35 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+
+void alloc_contig_freed_pages(unsigned long pfn,  unsigned long end)
+{
+	struct page *page;
+	struct zone *zone;
+	int order;
+	unsigned long start = pfn;
+
+	zone = page_zone(pfn_to_page(pfn));
+	spin_lock_irq(&zone->lock);
+	while (pfn < end) {
+		VM_BUG_ON(!pfn_valid(pfn));
+		page = pfn_to_page(pfn);
+		VM_BUG_ON(page_count(page));
+		VM_BUG_ON(!PageBuddy(page));
+		list_del(&page->lru);
+		order = page_order(page);
+		zone->free_area[order].nr_free--;
+		rmv_page_order(page);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, - (1UL << order));
+		pfn += 1 << order;
+	}
+	spin_unlock_irq(&zone->lock);
+
+	/*After this, pages in the range can be freed one be one */
+	for (pfn = start; pfn < end; pfn++)
+		prep_new_page(pfn_to_page(pfn), 0, 0);
+}
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * All pages in the range must be isolated before calling this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
