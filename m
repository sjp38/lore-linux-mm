Message-ID: <400CB3BD.4020601@cyberone.com.au>
Date: Tue, 20 Jan 2004 15:51:09 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Memory management in 2.6
Content-Type: multipart/mixed;
 boundary="------------060301050200030401030506"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060301050200030401030506
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,
In the interest of helping improve 2.6 VM performance when
under heavy swapping load, I'm putting together a few regression
tests.

If anyone has any suggestions of workloads I could use, I will
try to include them, or code them up if you want a simple concept
tested. Also, any suggestions of what information I should gather?

loads should be runnable on about 64MB, preferably give decently
repeatable results in under an hour.

I'll be happy to test patches. Here is one (results are a bit
wild because it was only 1 run).

Nick


--------------060301050200030401030506
Content-Type: text/plain;
 name="vm-akpm-balance-pgdat.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-akpm-balance-pgdat.patch"

 linux-2.6-npiggin/mm/vmscan.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff -puN mm/vmscan.c~vm-akpm-balance-pgdat mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-akpm-balance-pgdat	2004-01-17 20:35:39.000000000 +1100
+++ linux-2.6-npiggin/mm/vmscan.c	2004-01-17 20:35:42.000000000 +1100
@@ -941,11 +941,12 @@ static int balance_pgdat(pg_data_t *pgda
 			int nr_mapped = 0;
 			int max_scan;
 			int to_reclaim;
+			int reclaimed;
 
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;
 
-			if (nr_pages && to_free > 0) {	/* Software suspend */
+			if (nr_pages && nr_pages > 0) {	/* Software suspend */
 				to_reclaim = min(to_free, SWAP_CLUSTER_MAX*8);
 			} else {			/* Zone balancing */
 				to_reclaim = zone->pages_high-zone->free_pages;
@@ -953,28 +954,43 @@ static int balance_pgdat(pg_data_t *pgda
 					continue;
 			}
 			zone->temp_priority = priority;
-			all_zones_ok = 0;
 			max_scan = zone->nr_inactive >> priority;
 			if (max_scan < to_reclaim * 2)
 				max_scan = to_reclaim * 2;
 			if (max_scan < SWAP_CLUSTER_MAX)
 				max_scan = SWAP_CLUSTER_MAX;
-			to_free -= shrink_zone(zone, max_scan, GFP_KERNEL,
+			reclaimed = shrink_zone(zone, max_scan, GFP_KERNEL,
 					to_reclaim, &nr_mapped, ps, priority);
 			if (i < ZONE_HIGHMEM) {
 				reclaim_state->reclaimed_slab = 0;
 				shrink_slab(max_scan + nr_mapped, GFP_KERNEL);
-				to_free -= reclaim_state->reclaimed_slab;
+				reclaimed += reclaim_state->reclaimed_slab;
 			}
+			to_free -= reclaimed;
 			if (zone->all_unreclaimable)
 				continue;
 			if (zone->pages_scanned > zone->present_pages * 2)
 				zone->all_unreclaimable = 1;
+			/*
+			 * If this scan failed to reclaim `to_reclaim' or more
+			 * pages, we're getting into trouble.  Need to scan
+			 * some more, and throttle kswapd.   Note that this zone
+			 * may now have sufficient free pages due to freeing
+			 * activity by some other process.   That's OK - we'll
+			 * pick that info up on the next pass through the loop.
+			 */
+			if (reclaimed < to_reclaim)
+				all_zones_ok = 0;
 		}
-		if (all_zones_ok)
-			break;
 		if (to_free > 0)
-			blk_congestion_wait(WRITE, HZ/10);
+			continue;	/* swsusp: need to do more work */
+		if (all_zones_ok)
+			break;		/* kswapd: all done */
+		/*
+		 * OK, kswapd is getting into trouble.  Take a nap, then take
+		 * another pass across the zones.
+		 */
+		blk_congestion_wait(WRITE, HZ/10);
 	}
 
 	for (i = 0; i < pgdat->nr_zones; i++) {

_

--------------060301050200030401030506--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
