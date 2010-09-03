Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7D44D6B009F
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 06:35:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o83AYvdD005341
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Sep 2010 19:34:58 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6626B45DE55
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 19:34:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 20BA045DE4F
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 19:34:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0772C1DB8038
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 19:34:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A3491DB803C
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 19:34:56 +0900 (JST)
Date: Fri, 3 Sep 2010 19:29:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-Id: <20100903192943.f4f74136.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100902175424.5849c197.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	<1282310110.2605.976.camel@laptop>
	<20100825155814.25c783c7.akpm@linux-foundation.org>
	<20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
	<op.vh0wektv7p4s8u@localhost>
	<20100826115017.04f6f707.kamezawa.hiroyu@jp.fujitsu.com>
	<20100826124434.6089630d.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=T1y+sQuqVTYgOkYvqrxdYB1bZmCpKafN5jPqi@mail.gmail.com>
	<20100826133028.39d731da.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimB+s0tO=wrODAU4qCaZnCBoLZ2A9pGjR_jheOj@mail.gmail.com>
	<20100827171639.83c8642c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100902175424.5849c197.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, =?UTF-8?B?TWljaGHFgg==?= Nazarewicz <m.nazarewicz@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Sep 2010 17:54:24 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Here is a rough code for this.

here is a _tested_ one. 
If I tested correctly, I allocated 40MB of contigous pages by the new funciton.
I'm grad this can be some hints for people.

Thanks,
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch as a memory allocator for contiguous memory larger than MAX_ORDER.

  alloc_contig_pages(hint, size, list);

  This function allocates 'size' of contigoues pages, whose physical address
  is higher than 'hint'. size is specicied in byte unit.
  Allocated pages are all linked into the list and all of their page_count()
  are set to 1. Return value is the top page. 

 free_contig_pages(list)
 returns all pages in the list.

This patch does
  - find an area which can be ISOLATED.
  - migrate remaining pages in the area.
  - steal chunk of pages from allocator.

Limitation is:
  - retruned pages will be aligend to MAX_ORDER.
  - returned length of page will be aligned to MAX_ORDER.
    (so, the caller may have to return tails of pages by itself.)
  - may allocate contiguous pages which overlap node/zones.

This is fully experimental and written as example.
(Maybe need more patches to make this complete.)

This patch moves some amount of codes from memory_hotplug.c to
page_isolation.c and based on page-offline technique used by
memory_hotplug.c 

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page-isolation.h |   10 +
 mm/memory_hotplug.c            |   84 --------------
 mm/page_alloc.c                |   32 +++++
 mm/page_isolation.c            |  244 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 287 insertions(+), 83 deletions(-)

Index: mmotm-0827/mm/page_isolation.c
===================================================================
--- mmotm-0827.orig/mm/page_isolation.c
+++ mmotm-0827/mm/page_isolation.c
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
@@ -140,3 +143,244 @@ int test_pages_isolated(unsigned long st
 	spin_unlock_irqrestore(&zone->lock, flags);
 	return ret ? 0 : -EBUSY;
 }
+
+#define CONTIG_ALLOC_MIGRATION_RETRY	(5)
+
+/*
+ * Scanning pfn is much easier than scanning lru list.
+ * Scan pfn from start to end and Find LRU page.
+ */
+unsigned long scan_lru_pages(unsigned long start, unsigned long end)
+{
+	unsigned long pfn;
+	struct page *page;
+	for (pfn = start; pfn < end; pfn++) {
+		if (pfn_valid(pfn)) {
+			page = pfn_to_page(pfn);
+			if (PageLRU(page))
+				return pfn;
+		}
+	}
+	return 0;
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
+int __get_contig_block(unsigned long pfn, unsigned long nr_pages, void *arg)
+{
+	struct page_range *blockinfo = arg;
+	unsigned long end;
+
+	end = pfn + nr_pages;
+	pfn = ALIGN(pfn, MAX_ORDER_NR_PAGES);
+	end = end & ~(MAX_ORDER_NR_PAGES - 1);
+	if (end < pfn)
+		return 0;
+	if (end - pfn > blockinfo->pages) {
+		blockinfo->base = pfn;
+		blockinfo->end = end;
+		return 1;
+	}
+	return 0;
+}
+
+
+unsigned long __find_contig_block(unsigned long base,
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
+	ret = walk_system_ram_range(base, end - base, &blockinfo,
+		__get_contig_block);
+	if (!ret)
+		return 0;
+	/* Ok, we gound contiguous memory chunk of size. Isolate it.*/
+	for (pfn = blockinfo.base;
+	     pfn + pages < blockinfo.end;
+	     pfn += MAX_ORDER_NR_PAGES) {
+		/*
+		 * Now, we know [base,end) of a contiguous chunk.
+		 * Don't need to take care of memory holes.
+		 */
+		if (!start_isolate_page_range(pfn, pfn + pages))
+			return pfn;
+	}
+	/* failed ? */
+	if (blockinfo.end + pages < end) {
+		/* Move base address and find the next block of RAM. */
+		base = blockinfo.end;
+		goto retry;
+	}
+	return 0;
+}
+
+struct page *alloc_contig_pages(unsigned long long hint,
+		unsigned long size, struct list_head *list)
+{
+	unsigned long base, found, end, pages, start;
+	struct page *ret = NULL;
+	int nid, retry;
+
+	if (hint)
+		hint = ALIGN(hint, MAX_ORDER_NR_PAGES);
+	/* request size should be aligned to pageblock */
+	size >>= PAGE_SHIFT;
+	pages = ALIGN(size, MAX_ORDER_NR_PAGES);
+	found = 0;
+retry:
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		unsigned long node_end;
+		pg_data_t *node = NODE_DATA(nid);
+
+		node_end = node->node_start_pfn + node->node_spanned_pages;
+		/* does this node have proper range of memory ? */
+		if (node_end < hint + pages)
+			continue;
+		base = hint;
+		if (base < node->node_start_pfn)
+			base = node->node_start_pfn;
+
+		base = ALIGN(base, MAX_ORDER_NR_PAGES);
+		found = 0;
+		end = node_end & ~(MAX_ORDER_NR_PAGES -1);
+		/* Maybe we can use this Node */
+		if (base + pages < end)
+			found = __find_contig_block(base, end, pages);
+		if (found) /* Found ? */
+			break;
+		base = hint;
+	}
+	if (!found)
+		goto out;
+	/*
+	 * Ok, here, we have contiguous pageblock marked as "isolated"
+	 * try migration.
+ 	 */
+	retry = CONTIG_ALLOC_MIGRATION_RETRY;
+	end = found + pages;
+	for (start = scan_lru_pages(found, end); start < end;) {
+
+		if (do_migrate_range(found, end)) {
+			/* migration failure ... */
+			if (retry-- < 0)
+				break;
+			/* take a rest and synchronize LRU etc. */
+			lru_add_drain_all();
+			flush_scheduled_work();
+			cond_resched();
+			drain_all_pages();
+		}
+		start = scan_lru_pages(start, end);
+		if (!start)
+			break;
+	}
+	lru_add_drain_all();
+	flush_scheduled_work();
+	drain_all_pages();
+	if (test_pages_isolated(found, found+pages))
+		goto retry; /* goto next chunk */
+	/*
+	 * Ok, here, [found...found+pages) memory are isolated.
+	 * All pages in the range will be moved into the list with
+	 * page_count(page)=1.
+	 */
+	alloc_contig_freed_pages(found, found + pages, list);
+	/* unset ISOLATE */
+	undo_isolate_page_range(found, pages);
+	ret = pfn_to_page(found);
+out:
+	return ret;
+}
+
+
+void free_contig_pages(struct list_head *list)
+{
+	struct page *page, *tmp;
+
+	list_for_each_entry_safe(page, tmp, list, lru)
+		__free_page(page);
+	return;
+}
+
+EXPORT_SYMBOL_GPL(alloc_contig_pages);
+EXPORT_SYMBOL_GPL(free_contig_pages);
Index: mmotm-0827/include/linux/page-isolation.h
===================================================================
--- mmotm-0827.orig/include/linux/page-isolation.h
+++ mmotm-0827/include/linux/page-isolation.h
@@ -33,5 +33,15 @@ test_pages_isolated(unsigned long start_
 extern int set_migratetype_isolate(struct page *page);
 extern void unset_migratetype_isolate(struct page *page);
 
+/* For contiguous memory alloc */
+extern int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn);
+extern void alloc_contig_freed_pages(unsigned long pfn,  unsigned long end,
+        struct list_head *list);
+extern unsigned long scan_lru_pages(unsigned long start, unsigned long end);
+
+
+extern struct page *alloc_contig_pages(unsigned long long hint,
+			unsigned long size, struct list_head *list);
+extern void free_contig_pages(struct list_head *list);
 
 #endif
Index: mmotm-0827/mm/memory_hotplug.c
===================================================================
--- mmotm-0827.orig/mm/memory_hotplug.c
+++ mmotm-0827/mm/memory_hotplug.c
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
Index: mmotm-0827/mm/page_alloc.c
===================================================================
--- mmotm-0827.orig/mm/page_alloc.c
+++ mmotm-0827/mm/page_alloc.c
@@ -5393,6 +5393,38 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+void alloc_contig_freed_pages(unsigned long pfn,  unsigned long end,
+	struct list_head *list)
+{
+	struct page *page;
+	struct zone *zone;
+	int i, order;
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
+		for (i = 0;i < (1 << order); i++) {
+			struct page *x = page + i;
+			list_add(&x->lru, list);
+		}
+		page += 1 << order;
+	}
+	spin_unlock_irq(&zone->lock);
+
+	/*After this, pages on the list can be freed one be one */
+	list_for_each_entry(page, list, lru)
+		prep_new_page(page, 0, 0);
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
