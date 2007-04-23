From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070423064942.5458.14746.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 11/16] Variable Page Cache Size: Fix up reclaim counters
Date: Sun, 22 Apr 2007 23:49:42 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, David Chinner <dgc@sgi.com>, Badari Pulavarty <pbadari@gmail.com>, Adam Litke <aglitke@gmail.com>, Christoph Lameter <clameter@sgi.com>, Avi Kivity <avi@argo.co.il>, Mel Gorman <mel@skynet.ie>, Dave Hansen <hansendc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Variable Page Cache Size: Fix up reclaim counters

We can now reclaim larger pages. Adjust the VM counters
to deal with it.

Note that this does currently not make things work.
For some reason we keep loosing pages off the active lists
and reclaim stalls at some point attempting to remove
active pages from an empty active list.
It seems that the removal from the active lists happens
outside of reclaim ?!?

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmscan.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

Index: linux-2.6.21-rc7/mm/vmscan.c
===================================================================
--- linux-2.6.21-rc7.orig/mm/vmscan.c	2007-04-22 06:50:03.000000000 -0700
+++ linux-2.6.21-rc7/mm/vmscan.c	2007-04-22 17:19:35.000000000 -0700
@@ -471,14 +471,14 @@ static unsigned long shrink_page_list(st
 
 		VM_BUG_ON(PageActive(page));
 
-		sc->nr_scanned++;
+		sc->nr_scanned += base_pages(page);
 
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
 
 		/* Double the slab pressure for mapped and swapcache pages */
 		if (page_mapped(page) || PageSwapCache(page))
-			sc->nr_scanned++;
+			sc->nr_scanned += base_pages(page);
 
 		if (PageWriteback(page))
 			goto keep_locked;
@@ -581,7 +581,7 @@ static unsigned long shrink_page_list(st
 
 free_it:
 		unlock_page(page);
-		nr_reclaimed++;
+		nr_reclaimed += base_pages(page);
 		if (!pagevec_add(&freed_pvec, page))
 			__pagevec_release_nonlru(&freed_pvec);
 		continue;
@@ -627,7 +627,7 @@ static unsigned long isolate_lru_pages(u
 	struct page *page;
 	unsigned long scan;
 
-	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
+	for (scan = 0; scan < nr_to_scan && !list_empty(src); ) {
 		struct list_head *target;
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
@@ -644,10 +644,11 @@ static unsigned long isolate_lru_pages(u
 			 */
 			ClearPageLRU(page);
 			target = dst;
-			nr_taken++;
+			nr_taken += base_pages(page);
 		} /* else it is being freed elsewhere */
 
 		list_add(&page->lru, target);
+		scan += base_pages(page);
 	}
 
 	*scanned = scan;
@@ -856,7 +857,7 @@ force_reclaim_mapped:
 		ClearPageActive(page);
 
 		list_move(&page->lru, &zone->inactive_list);
-		pgmoved++;
+		pgmoved += base_pages(page);
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
 			spin_unlock_irq(&zone->lru_lock);
@@ -884,7 +885,7 @@ force_reclaim_mapped:
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
 		list_move(&page->lru, &zone->active_list);
-		pgmoved++;
+		pgmoved += base_pages(page);
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
 			pgmoved = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
