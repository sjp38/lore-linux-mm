Message-ID: <41131158.3090404@yahoo.com.au>
Date: Fri, 06 Aug 2004 15:04:24 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH] 4/4: incremental min aware kswapd
References: <41130FB1.5020001@yahoo.com.au> <41130FD2.5070608@yahoo.com.au> <41131105.8040108@yahoo.com.au>
In-Reply-To: <41131105.8040108@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------040604090006060706050804"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Shantanu Goel <sgoel01@yahoo.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040604090006060706050804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

4/4

--------------040604090006060706050804
Content-Type: text/x-patch;
 name="vm-kswapd-incmin.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-kswapd-incmin.patch"



Explicitly teach kswapd about the incremental min logic instead of just scanning
all zones under the first low zone. This should keep more even pressure applied
on the zones.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/mm/vmscan.c |   98 +++++++++++++++++-------------------------
 1 files changed, 40 insertions(+), 58 deletions(-)

diff -puN mm/vmscan.c~vm-kswapd-incmin mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-kswapd-incmin	2004-08-06 14:49:48.000000000 +1000
+++ linux-2.6-npiggin/mm/vmscan.c	2004-08-06 14:49:48.000000000 +1000
@@ -1011,80 +1011,63 @@ static int balance_pgdat(pg_data_t *pgda
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		int all_zones_ok = 1;
-		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
+		int first_low = 0;
 
-		if (nr_pages == 0) {
-			/*
-			 * Scan in the highmem->dma direction for the highest
-			 * zone which needs scanning
-			 */
-			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
-				struct zone *zone = pgdat->node_zones + i;
+		sc.nr_scanned = 0;
+		sc.nr_reclaimed = 0;
 
-				if (zone->all_unreclaimable &&
-						priority != DEF_PRIORITY)
-					continue;
-
-				if (zone->free_pages <= zone->pages_high) {
-					end_zone = i;
-					goto scan;
-				}
-			}
-			goto out;
-		} else {
-			end_zone = pgdat->nr_zones - 1;
-		}
-scan:
-		for (i = 0; i <= end_zone; i++) {
+		/* Scan in the highmem->dma direction */
+		for (i = pgdat->nr_zones - 1; i >= 0; i--) {
 			struct zone *zone = pgdat->node_zones + i;
 
-			lru_pages += zone->nr_active + zone->nr_inactive;
-		}
+			if (nr_pages == 0) {	/* Not software suspend */
+				unsigned long pgfree = zone->free_pages;
+				unsigned long pghigh = zone->pages_high;
 
-		/*
-		 * Now scan the zone in the dma->highmem direction, stopping
-		 * at the last zone which needs scanning.
-		 *
-		 * We do this because the page allocator works in the opposite
-		 * direction.  This prevents the page allocator from allocating
-		 * pages behind kswapd's direction of progress, which would
-		 * cause too much scanning of the lower zones.
-		 */
-		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
+				/*
+				 * This satisfies the "incremental min" or
+				 * lower zone protection logic in the allocator
+				 */
+				if (first_low > i)
+					pghigh += zone->protection[first_low];
+				if (pgfree >= pghigh)
+					continue;
+				if (first_low < i)
+					first_low = i;
+
+				all_zones_ok = 0;
+				sc.nr_to_reclaim = pghigh - pgfree;
+			} else
+				sc.nr_to_reclaim = INT_MAX; /* Software susp */
 
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;
-
-			if (nr_pages == 0) {	/* Not software suspend */
-				if (zone->free_pages <= zone->pages_high)
-					all_zones_ok = 0;
-			}
 			zone->temp_priority = priority;
 			if (zone->prev_priority > priority)
 				zone->prev_priority = priority;
-			sc.nr_scanned = 0;
-			sc.nr_reclaimed = 0;
 			sc.priority = priority;
+			lru_pages += zone->nr_active + zone->nr_inactive;
 			shrink_zone(zone, &sc);
-			reclaim_state->reclaimed_slab = 0;
-			shrink_slab(sc.nr_scanned, GFP_KERNEL, lru_pages);
-			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-			total_reclaimed += sc.nr_reclaimed;
-			if (zone->all_unreclaimable)
-				continue;
 			if (zone->pages_scanned > zone->present_pages * 2)
 				zone->all_unreclaimable = 1;
-			/*
-			 * If we've done a decent amount of scanning and
-			 * the reclaim ratio is low, start doing writepage
-			 * even in laptop mode
-			 */
-			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
-			    total_scanned > total_reclaimed+total_reclaimed/2)
-				sc.may_writepage = 1;
 		}
+		reclaim_state->reclaimed_slab = 0;
+		shrink_slab(sc.nr_scanned, GFP_KERNEL, lru_pages);
+		sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+
+		total_reclaimed += sc.nr_reclaimed;
+		total_scanned += sc.nr_scanned;
+
+		/*
+		 * If we've done a decent amount of scanning and
+		 * the reclaim ratio is low, start doing writepage
+		 * even in laptop mode
+		 */
+		if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
+		    total_scanned > total_reclaimed+total_reclaimed/2)
+			sc.may_writepage = 1;
+
 		if (nr_pages && to_free > total_reclaimed)
 			continue;	/* swsusp: need to do more work */
 		if (all_zones_ok)
@@ -1096,7 +1079,6 @@ scan:
 		if (total_scanned && priority < DEF_PRIORITY - 2)
 			blk_congestion_wait(WRITE, HZ/10);
 	}
-out:
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 

_

--------------040604090006060706050804--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
