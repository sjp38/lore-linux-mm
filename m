Message-ID: <4020BE94.1040001@cyberone.com.au>
Date: Wed, 04 Feb 2004 20:42:44 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [PATCH 5/5] mm improvements
References: <4020BDCB.8030707@cyberone.com.au>
In-Reply-To: <4020BDCB.8030707@cyberone.com.au>
Content-Type: multipart/mixed;
 boundary="------------060708010600020102010505"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060708010600020102010505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

> 5/5: vm-tune-throttle.patch
>     Try to allocate a bit harder before giving up / throttling on
>     writeout.
>



--------------060708010600020102010505
Content-Type: text/plain;
 name="vm-tune-throttle.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-tune-throttle.patch"


This patch causes try_to_free_pages to wakeup_bdflush even if it has
reclaimed the required # of pages on the first scan.

It allows two scans at the two lowest priorities before breaking out or
doing a blk_congestion_wait, for both try_to_free_pages and balance_pgdat.


 linux-2.6-npiggin/mm/vmscan.c |   38 +++++++++++++++++++++-----------------
 1 files changed, 21 insertions(+), 17 deletions(-)

diff -puN mm/vmscan.c~vm-tune-throttle mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-tune-throttle	2004-02-04 14:09:46.000000000 +1100
+++ linux-2.6-npiggin/mm/vmscan.c	2004-02-04 14:09:46.000000000 +1100
@@ -930,22 +930,33 @@ int try_to_free_pages(struct zone **zone
 
 		if (nr_reclaimed >= nr_pages) {
 			ret = 1;
+			if (gfp_mask & __GFP_FS)
+				wakeup_bdflush(total_scanned);
 			goto out;
 		}
+
+		/* Don't stall on the first run - it might be bad luck */
+		if (likely(priority == DEF_PRIORITY))
+			continue;
+
+		/* Let the caller handle it */
 		if (!(gfp_mask & __GFP_FS))
-			break;		/* Let the caller handle it */
+			goto out;
+
 		/*
-		 * Try to write back as many pages as we just scanned.  Not
-		 * sure if that makes sense, but it's an attempt to avoid
-		 * creating IO storms unnecessarily
+		 * Try to write back as many pages as we just scanned.
+		 * Not sure if that makes sense, but it's an attempt
+		 * to avoid creating IO storms unnecessarily
 		 */
 		wakeup_bdflush(total_scanned);
 
 		/* Take a nap, wait for some writeback to complete */
 		blk_congestion_wait(WRITE, HZ/10);
 	}
-	if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY))
+
+	if (!(gfp_mask & __GFP_NORETRY))
 		out_of_memory();
+
 out:
 	for (i = 0; zones[i] != 0; i++)
 		zones[i]->prev_priority = zones[i]->temp_priority;
@@ -1004,6 +1015,7 @@ static int balance_pgdat(pg_data_t *pgda
 				if (to_reclaim <= 0)
 					continue;
 			}
+			all_zones_ok = 0;
 			zone->temp_priority = priority;
 			reclaimed = shrink_zone(zone, GFP_KERNEL,
 					to_reclaim, &nr_scanned, ps, priority);
@@ -1017,16 +1029,6 @@ static int balance_pgdat(pg_data_t *pgda
 				continue;
 			if (zone->pages_scanned > zone->present_pages * 2)
 				zone->all_unreclaimable = 1;
-			/*
-			 * If this scan failed to reclaim `to_reclaim' or more
-			 * pages, we're getting into trouble.  Need to scan
-			 * some more, and throttle kswapd.   Note that this zone
-			 * may now have sufficient free pages due to freeing
-			 * activity by some other process.   That's OK - we'll
-			 * pick that info up on the next pass through the loop.
-			 */
-			if (reclaimed < to_reclaim)
-				all_zones_ok = 0;
 		}
 		if (nr_pages && to_free > 0)
 			continue;	/* swsusp: need to do more work */
@@ -1034,9 +1036,11 @@ static int balance_pgdat(pg_data_t *pgda
 			break;		/* kswapd: all done */
 		/*
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
-		 * another pass across the zones.
+		 * another pass across the zones. Don't stall on the first
+		 * pass.
 		 */
-		blk_congestion_wait(WRITE, HZ/10);
+		if (priority < DEF_PRIORITY)
+			blk_congestion_wait(WRITE, HZ/10);
 	}
 
 	for (i = 0; i < pgdat->nr_zones; i++) {

_

--------------060708010600020102010505--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
