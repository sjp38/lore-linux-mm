Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A06CA6B00E8
	for <linux-mm@kvack.org>; Wed, 23 May 2012 03:23:26 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: Text/Plain; charset=us-ascii
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M4G00DGHSJEZ880@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 23 May 2012 08:23:39 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4G00KNSSJ0MD@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 23 May 2012 08:23:24 +0100 (BST)
Date: Wed, 23 May 2012 09:22:00 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] cma: cached pageblock type fixup
Message-id: <201205230922.00530.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] cma: cached pageblock type fixup

CMA pages added to per-cpu pages lists in free_hot_cold_page()
have private field set to MIGRATE_CMA pageblock type .  If this
happes just before start_isolate_page_range() in alloc_contig_range()
changes pageblock type of the page to MIGRATE_ISOLATE it may result
in the cached pageblock type being stale in free_pcppages_bulk()
(which may be triggered by drain_all_pages() in alloc_contig_range()),
page being added to MIGRATE_CMA free list instead of MIGRATE_ISOLATE
one in __free_one_page() and (if the page is reused just before
test_pages_isolated() check) causing alloc_contig_range() failure.

Fix such situation by checking whether pageblock type of the page
changed to MIGRATE_ISOLATE for MIGRATE_CMA type pages in
free_pcppages_bulk() and if so fixup the pageblock type to
MIGRATE_ISOLATE (so the page will be added to MIGRATE_ISOLATE free
list in __free_one_page() and won't be used).

Similar situation can happen if rmqueue_bulk() sets cached pageblock
of the page to MIGRATE_CMA and start_isolate_page_range() is called
before buffered_rmqueue() completes (so the page may used by
get_page_from_freelist() and cause test_pages_isolated() check
failure in alloc_contig_range()).  Fix it in buffered_rmqueue() by
changing the pageblock type of the affected page if needed, freeing
page back to buddy allocator and retrying the allocation.

Please note that even with this patch applied some page allocation
vs alloc_contig_range() races are still possible and may result in
rare test_pages_isolated() failures.

Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/page_alloc.c |   38 ++++++++++++++++++++++++++++++++++++--
 1 file changed, 36 insertions(+), 2 deletions(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2012-05-14 16:19:10.052973990 +0200
+++ b/mm/page_alloc.c	2012-05-15 12:40:54.199127705 +0200
@@ -664,12 +664,24 @@
 			batch_free = to_free;
 
 		do {
+			int mt;
+
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
+
+			mt = page_private(page);
+			/*
+			 * cached MIGRATE_CMA pageblock type may have changed
+			 * during isolation
+			 */
+			if (is_migrate_cma(mt) &&
+			    get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
+				mt = MIGRATE_ISOLATE;
+
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
-			__free_one_page(page, zone, 0, page_private(page));
-			trace_mm_page_pcpu_drain(page, 0, page_private(page));
+			__free_one_page(page, zone, 0, mt);
+			trace_mm_page_pcpu_drain(page, 0, mt);
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
@@ -1440,6 +1452,7 @@
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
 		struct list_head *list;
+		int mt;
 
 		local_irq_save(flags);
 		pcp = &this_cpu_ptr(zone->pageset)->pcp;
@@ -1459,6 +1472,27 @@
 
 		list_del(&page->lru);
 		pcp->count--;
+
+		spin_lock(&zone->lock);
+		mt = page_private(page);
+		/*
+		 * cached MIGRATE_CMA pageblock type may have changed
+		 * during isolation
+		 */
+		if ((is_migrate_cma(mt) &&
+		     get_pageblock_migratetype(page) == MIGRATE_ISOLATE) ||
+		    mt == MIGRATE_ISOLATE) {
+			mt = MIGRATE_ISOLATE;
+
+			zone->all_unreclaimable = 0;
+			zone->pages_scanned = 0;
+
+			__free_one_page(page, zone, 0, mt);
+			__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
+			spin_unlock(&zone->lock);
+			goto again;
+		} else
+			spin_unlock(&zone->lock);
 	} else {
 		if (unlikely(gfp_flags & __GFP_NOFAIL)) {
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
