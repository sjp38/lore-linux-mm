Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id F2ED86B005D
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 15:03:10 -0500 (EST)
Date: Thu, 26 Jan 2012 14:59:14 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH v3 -mm 1/3] mm: reclaim at order 0 when compaction is
 enabled
Message-ID: <20120126145914.58619765@cuia.bos.redhat.com>
In-Reply-To: <20120126145450.2d3d2f4c@cuia.bos.redhat.com>
References: <20120126145450.2d3d2f4c@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

When built with CONFIG_COMPACTION, kswapd should not try to free
contiguous pages, because it is not trying hard enough to have
a real chance at being successful, but still disrupts the LRU
enough to break other things.

Do not do higher order page isolation unless we really are in
lumpy reclaim mode.

Stop reclaiming pages once we have enough free pages that
compaction can deal with things, and we hit the normal order 0
watermarks used by kswapd.

Also remove a line of code that increments balanced right before
exiting the function.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
-v4: further cleanups suggested by Mel Gorman
 mm/vmscan.c |   43 +++++++++++++++++++++++++++++--------------
 1 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2880396..2e2e43d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1139,7 +1139,7 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
  * @mz:		The mem_cgroup_zone to pull pages from.
  * @dst:	The temp list to put pages on to.
  * @nr_scanned:	The number of pages that were scanned.
- * @order:	The caller's attempted allocation order
+ * @sc:		The scan_control struct for this reclaim session
  * @mode:	One of the LRU isolation modes
  * @active:	True [1] if isolating active pages
  * @file:	True [1] if isolating file [!anon] pages
@@ -1148,8 +1148,8 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct mem_cgroup_zone *mz, struct list_head *dst,
-		unsigned long *nr_scanned, int order, isolate_mode_t mode,
-		int active, int file)
+		unsigned long *nr_scanned, struct scan_control *sc,
+		isolate_mode_t mode, int active, int file)
 {
 	struct lruvec *lruvec;
 	struct list_head *src;
@@ -1195,7 +1195,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			BUG();
 		}
 
-		if (!order)
+		if (!sc->order || !(sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM))
 			continue;
 
 		/*
@@ -1209,8 +1209,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		 */
 		zone_id = page_zone_id(page);
 		page_pfn = page_to_pfn(page);
-		pfn = page_pfn & ~((1 << order) - 1);
-		end_pfn = pfn + (1 << order);
+		pfn = page_pfn & ~((1 << sc->order) - 1);
+		end_pfn = pfn + (1 << sc->order);
 		for (; pfn < end_pfn; pfn++) {
 			struct page *cursor_page;
 
@@ -1276,7 +1276,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 	*nr_scanned = scan;
 
-	trace_mm_vmscan_lru_isolate(order,
+	trace_mm_vmscan_lru_isolate(sc->order,
 			nr_to_scan, scan,
 			nr_taken,
 			nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
@@ -1535,7 +1535,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	spin_lock_irq(&zone->lru_lock);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, mz, &page_list,
-				     &nr_scanned, sc->order,
+				     &nr_scanned, sc,
 				     reclaim_mode, 0, file);
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
@@ -1713,7 +1713,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	spin_lock_irq(&zone->lru_lock);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, mz, &l_hold,
-				     &nr_scanned, sc->order,
+				     &nr_scanned, sc,
 				     reclaim_mode, 1, file);
 	if (global_reclaim(sc))
 		zone->pages_scanned += nr_scanned;
@@ -2754,7 +2754,7 @@ loop_again:
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			int nr_slab;
+			int nr_slab, testorder;
 			unsigned long balance_gap;
 
 			if (!populated_zone(zone))
@@ -2787,7 +2787,20 @@ loop_again:
 				(zone->present_pages +
 					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
 				KSWAPD_ZONE_BALANCE_GAP_RATIO);
-			if (!zone_watermark_ok_safe(zone, order,
+			/*
+			 * Kswapd reclaims only single pages with compaction
+			 * enabled. Trying too hard to reclaim until contiguous
+			 * free pages have become available can hurt performance
+			 * by evicting too much useful data from memory.
+			 * Do not reclaim more than needed for compaction.
+			 */
+			testorder = order;
+			if (COMPACTION_BUILD && order &&
+					compaction_suitable(zone, order) !=
+						COMPACT_SKIPPED)
+				testorder = 0;
+
+			if (!zone_watermark_ok_safe(zone, testorder,
 					high_wmark_pages(zone) + balance_gap,
 					end_zone, 0)) {
 				shrink_zone(priority, zone, &sc);
@@ -2816,7 +2829,7 @@ loop_again:
 				continue;
 			}
 
-			if (!zone_watermark_ok_safe(zone, order,
+			if (!zone_watermark_ok_safe(zone, testorder,
 					high_wmark_pages(zone), end_zone, 0)) {
 				all_zones_ok = 0;
 				/*
@@ -2913,6 +2926,10 @@ out:
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;
 
+			/* Would compaction fail due to lack of free memory? */
+			if (compaction_suitable(zone, order) == COMPACT_SKIPPED)
+				goto loop_again;
+
 			/* Confirm the zone is balanced for order-0 */
 			if (!zone_watermark_ok(zone, 0,
 					high_wmark_pages(zone), 0, 0)) {
@@ -2922,8 +2939,6 @@ out:
 
 			/* If balanced, clear the congested flag */
 			zone_clear_flag(zone, ZONE_CONGESTED);
-			if (i <= *classzone_idx)
-				balanced += zone->present_pages;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
