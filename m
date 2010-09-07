Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5947B6B004A
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 22:50:20 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o872o9Do016861
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Sep 2010 11:50:09 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C9A3445DE4D
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 11:50:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 99FA345DE4F
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 11:50:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AC44E08003
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 11:50:07 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B7431DB8050
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 11:50:06 +0900 (JST)
Date: Tue, 7 Sep 2010 11:45:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] big continuous memory allocator v2
Message-Id: <20100907114505.fc40ea3d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This is a page allcoator based on memory migration/hotplug code.
passed some small tests, and maybe easier to read than previous one.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch as a memory allocator for contiguous memory larger than MAX_ORDER.

  alloc_contig_pages(hint, size, node);

  This function allocates 'size' of contigoues pages, whose physical address
  is higher than 'hint' and on "node". size and hint are specified in pfn.
  Allocated pages's page_count() are set to 1.
  Return value is the top page. 

 free_contig_pages(start, size)
 free all pages in the range.

This patch does
  - find an area which can be ISOLATED with skipping memory holes.
  - migrate LRU pages in the area.
  - steal chunk of pages from allocator.

Most of codes are for "deteciting candidate of range for allocating memory".
migration/isolation reuses memory hotplug codes.

This is fully experimental and written as example.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page-isolation.h |    9 +
 mm/memory_hotplug.c            |   86 -----------
 mm/page_alloc.c                |   28 +++
 mm/page_isolation.c            |  301 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 340 insertions(+), 84 deletions(-)

Index: kametest/mm/page_isolation.c
===================================================================
--- kametest.orig/mm/page_isolation.c
+++ kametest/mm/page_isolation.c
@@ -3,8 +3,11 @@
  */
 
 #include <linux/mm.h>
+#include <linux/swap.h>
 #include <linux/page-isolation.h>
 #include <linux/pageblock-flags.h>
+#include <linux/mm_inline.h>
+#include <linux/migrate.h>
 #include "internal.h"
 
 static inline struct page *
@@ -140,3 +143,301 @@ int test_pages_isolated(unsigned long st
 	spin_unlock_irqrestore(&zone->lock, flags);
 	return ret ? 0 : -EBUSY;
 }
+
+#define MIGRATION_RETRY	(5)
+
+/*
+ * Scanning pfn is much easier than scanning lru list.
+ * Scan pfn from start to end and Find LRU page.
+ */
+unsigned long scan_lru_pages(unsigned long start, unsigned long end)
+{
+	unsigned long pfn;
+	struct page *page;
+
+	for (pfn = start; pfn < end; pfn++) {
+		if (pfn_valid(pfn)) {
+			page = pfn_to_page(pfn);
+			if (PageLRU(page))
+				return pfn;
+		}
+	}
+	return pfn;
+}
+
+/* Migrate all LRU pages in the range to somewhere else */
+static struct page *
+hotremove_migrate_alloc(struct page *page, unsigned long private, int **x)
+{
+	/* This should be improooooved!! */
+	return alloc_page(GFP_HIGHUSER_MOVABLE);
+}
+
+#define NR_MOVE_AT_ONCE_PAGES	(256)
+int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+	struct page *page;
+	int move_pages = NR_MOVE_AT_ONCE_PAGES;
+	int not_managed = 0;
+	int ret = 0;
+	LIST_HEAD(source);
+
+	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+		if (!page_count(page))
+			continue;
+		/*
+		 * We can skip free pages. And we can only deal with pages on
+		 * LRU.
+		 */
+		ret = isolate_lru_page(page);
+		if (!ret) { /* Success */
+			list_add_tail(&page->lru, &source);
+			move_pages--;
+			inc_zone_page_state(page, NR_ISOLATED_ANON +
+					    page_is_file_cache(page));
+
+		} else {
+			/* Becasue we don't have big zone->lock. we should
+			   check this again here. */
+			if (page_count(page))
+				not_managed++;
+#ifdef CONFIG_DEBUG_VM
+			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
+			       pfn);
+			dump_page(page);
+#endif
+		}
+	}
+	ret = -EBUSY;
+	if (not_managed) {
+		if (!list_empty(&source))
+			putback_lru_pages(&source);
+		goto out;
+	}
+	ret = 0;
+	if (list_empty(&source))
+		goto out;
+	/* this function returns # of failed pages */
+	ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
+
+out:
+	return ret;
+}
+
+
+/*
+ * An interface to isolate pages in specified size and range.
+ * Purpose is to return contigous free pages larger than MAX_ORDER.
+ * Below codes are very slow and sleeps, please never call this under
+ * performance critical codes.
+ */
+
+struct page_range {
+	unsigned long base, end, pages;
+};
+
+static inline unsigned long  MAX_O_ALIGN(unsigned long x) {
+	return ALIGN(x, MAX_ORDER_NR_PAGES);
+}
+
+static inline unsigned long MAX_O_BASE(unsigned long x) {
+	return (x & ~(MAX_ORDER_NR_PAGES - 1));
+}
+
+int __get_contig_block(unsigned long pfn, unsigned long nr_pages, void *arg)
+{
+	struct page_range *blockinfo = arg;
+	unsigned long end;
+
+	end = pfn + nr_pages;
+	pfn = MAX_O_ALIGN(pfn);
+	end = MAX_O_BASE(end);
+	if (end < pfn)
+		return 0;
+	if (end - pfn >= blockinfo->pages) {
+		blockinfo->base = pfn;
+		blockinfo->end = end;
+		return 1;
+	}
+	return 0;
+}
+
+static void __trim_zone(struct page_range *range)
+{
+	struct zone *zone;
+	unsigned long pfn;
+	/*
+	 * In most case, each zone's [start_pfn, end_pfn) has no
+	 * overlap between each other. But some arch allows it and
+	 * we need to check it here.
+	 */
+	for (pfn = range->base, zone = page_zone(pfn_to_page(pfn));
+	     pfn < range->end;
+	     pfn += MAX_ORDER_NR_PAGES) {
+
+		if (zone != page_zone(pfn_to_page(pfn)))
+			break;
+	}
+	range->end = min(pfn, range->end);
+	return;
+}
+static unsigned long __find_contig_block(unsigned long base,
+		unsigned long end, unsigned long pages)
+{
+	unsigned long pfn;
+	struct page_range blockinfo;
+	int ret;
+
+	/* Skip memory holes */
+retry:
+	blockinfo.base = base;
+	blockinfo.end = end;
+	blockinfo.pages = pages;
+	/*
+	 * retruns a contiguous page range within [base, end) which is
+	 * larger than pages.
+	 */
+	ret = walk_system_ram_range(base, end - base, &blockinfo,
+		__get_contig_block);
+	if (!ret)
+		return 0;
+
+	__trim_zone(&blockinfo);
+	/* Ok, we found contiguous memory chunk of size. Isolate it.*/
+	for (pfn = blockinfo.base; pfn + pages < blockinfo.end;
+	     pfn += MAX_ORDER_NR_PAGES) {
+		/*
+		 * Now, we know [base,end) of a contiguous chunk.
+		 * Don't need to take care of memory holes.
+		 */
+		if (!start_isolate_page_range(pfn, pfn + pages))
+			return pfn;
+	}
+	/* failed */
+	if (blockinfo.end + pages < end) {
+		/* Move base address and find the next block of RAM. */
+		base = blockinfo.end;
+		goto retry;
+	}
+	return 0;
+}
+
+/**
+ *	alloc_contig_pages - allocate a contigous physical pages
+ *	@hint:		the base address of searching free space(in pfn)
+ *	@size:		size of requested area (in # of pages)
+ *	@node:		the node where memory allocated from. If -1, ignored.
+ *
+ *	Search an area of @size in the physical memory map and checks wheter
+ *	we can create a contigous free space. If it seems possible, try to
+ *	create contigous space with page migration.
+ *
+ *	Returns a page of the beginning of contiguous block. At failure, NULL
+ *	is returned. Each page in the area is set to page_count() = 1. Because
+ *	this function does page	migration, this function is very heavy and
+ *	sleeps some time. Caller must be aware that "NULL returned" is not a
+ *	special case.
+ *
+ *	Now, returned range is aligned to MAX_ORDER.
+ */
+
+struct page *alloc_contig_pages(unsigned long hint,
+				unsigned long size, int node)
+{
+	unsigned long base, found, end, pages, start;
+	struct page *ret = NULL;
+	int migration_failed;
+	struct zone *zone;
+
+	hint = MAX_O_ALIGN(hint);
+	/* request size should be aligned to pageblock */
+	pages = MAX_O_ALIGN(size);
+	found = 0;
+retry:
+	for_each_populated_zone(zone) {
+		unsigned long zone_end_pfn;
+
+		if (node >= 0 && node != zone_to_nid(zone))
+			continue;
+		if (zone->present_pages < pages)
+			continue;
+		base = MAX_O_ALIGN(zone->zone_start_pfn);
+		base = max(base, hint);
+		zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+		if (base + pages > zone_end_pfn)
+			continue;
+		found = __find_contig_block(base, zone_end_pfn, pages);
+		/* Next try will see the next block. */
+		hint = base + MAX_ORDER_NR_PAGES;
+		if (found)
+			break;
+	}
+
+	if (!found)
+		goto out;
+	/*
+	 * Ok, here, we have contiguous pageblock marked as "isolated"
+	 * try migration.
+	 *
+	 * FIXME: permanent migration_failure detection logic seems not very
+	 * precise.
+ 	 */
+	end = found + pages;
+	/* scan_lru_pages() finds the next PG_lru page in the range */
+	for (start = scan_lru_pages(found, end), migration_failed = 0;
+	     start < end;
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
+		/* We failed at [start...???) migration. */
+		hint = MAX_O_ALIGN(start + 1);
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
+out:
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
Index: kametest/include/linux/page-isolation.h
===================================================================
--- kametest.orig/include/linux/page-isolation.h
+++ kametest/include/linux/page-isolation.h
@@ -33,5 +33,14 @@ test_pages_isolated(unsigned long start_
 extern int set_migratetype_isolate(struct page *page);
 extern void unset_migratetype_isolate(struct page *page);
 
+/* For contiguous memory alloc */
+extern int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn);
+extern void alloc_contig_freed_pages(unsigned long pfn,  unsigned long end);
+extern unsigned long scan_lru_pages(unsigned long start, unsigned long end);
+
+
+extern struct page *alloc_contig_pages(unsigned long hint,
+			unsigned long size, int node);
+extern void free_contig_pages(struct page *page, int nr_pages);
 
 #endif
Index: kametest/mm/memory_hotplug.c
===================================================================
--- kametest.orig/mm/memory_hotplug.c
+++ kametest/mm/memory_hotplug.c
@@ -568,7 +568,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(add_memory);
 
-#ifdef CONFIG_MEMORY_HOTREMOVE
+#if defined(CONFIG_MEMORY_HOTREMOVE) || defined(CONFIG_CONTIG_ALLOC)
 /*
  * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy
  * set and the size of the free page is given by page_order(). Using this,
@@ -643,87 +643,6 @@ static int test_pages_in_a_zone(unsigned
 }
 
 /*
- * Scanning pfn is much easier than scanning lru list.
- * Scan pfn from start to end and Find LRU page.
- */
-int scan_lru_pages(unsigned long start, unsigned long end)
-{
-	unsigned long pfn;
-	struct page *page;
-	for (pfn = start; pfn < end; pfn++) {
-		if (pfn_valid(pfn)) {
-			page = pfn_to_page(pfn);
-			if (PageLRU(page))
-				return pfn;
-		}
-	}
-	return 0;
-}
-
-static struct page *
-hotremove_migrate_alloc(struct page *page, unsigned long private, int **x)
-{
-	/* This should be improooooved!! */
-	return alloc_page(GFP_HIGHUSER_MOVABLE);
-}
-
-#define NR_OFFLINE_AT_ONCE_PAGES	(256)
-static int
-do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
-{
-	unsigned long pfn;
-	struct page *page;
-	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
-	int not_managed = 0;
-	int ret = 0;
-	LIST_HEAD(source);
-
-	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
-		if (!pfn_valid(pfn))
-			continue;
-		page = pfn_to_page(pfn);
-		if (!page_count(page))
-			continue;
-		/*
-		 * We can skip free pages. And we can only deal with pages on
-		 * LRU.
-		 */
-		ret = isolate_lru_page(page);
-		if (!ret) { /* Success */
-			list_add_tail(&page->lru, &source);
-			move_pages--;
-			inc_zone_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
-
-		} else {
-			/* Becasue we don't have big zone->lock. we should
-			   check this again here. */
-			if (page_count(page))
-				not_managed++;
-#ifdef CONFIG_DEBUG_VM
-			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
-			       pfn);
-			dump_page(page);
-#endif
-		}
-	}
-	ret = -EBUSY;
-	if (not_managed) {
-		if (!list_empty(&source))
-			putback_lru_pages(&source);
-		goto out;
-	}
-	ret = 0;
-	if (list_empty(&source))
-		goto out;
-	/* this function returns # of failed pages */
-	ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
-
-out:
-	return ret;
-}
-
-/*
  * remove from free_area[] and mark all as Reserved.
  */
 static int
@@ -740,7 +659,6 @@ offline_isolated_pages(unsigned long sta
 	walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
 				offline_isolated_pages_cb);
 }
-
 /*
  * Check all pages in range, recoreded as memory resource, are isolated.
  */
@@ -833,7 +751,7 @@ repeat:
 	}
 
 	pfn = scan_lru_pages(start_pfn, end_pfn);
-	if (pfn) { /* We have page on LRU */
+	if (pfn != end_pfn) { /* We have page on LRU */
 		ret = do_migrate_range(pfn, end_pfn);
 		if (!ret) {
 			drain = 1;
Index: kametest/mm/page_alloc.c
===================================================================
--- kametest.orig/mm/page_alloc.c
+++ kametest/mm/page_alloc.c
@@ -5401,6 +5401,34 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
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
