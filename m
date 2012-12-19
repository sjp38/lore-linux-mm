Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id CF2046B0074
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 18:25:18 -0500 (EST)
Date: Thu, 20 Dec 2012 00:25:13 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <50D24AF3.1050809@iskon.hr>
In-Reply-To: <50D24AF3.1050809@iskon.hr>
Message-ID: <50D24CD9.8070507@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] mm: do not sleep in balance_pgdat if there's no i/o congestion
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On a 4GB RAM machine, where Normal zone is much smaller than
DMA32 zone, the Normal zone gets fragmented in time. This requires
relatively more pressure in balance_pgdat to get the zone above the
required watermark. Unfortunately, the congestion_wait() call in there
slows it down for a completely wrong reason, expecting that there's
a lot of writeback/swapout, even when there's none (much more common).
After a few days, when fragmentation progresses, this flawed logic
translates to a very high CPU iowait times, even though there's no
I/O congestion at all. If THP is enabled, the problem occurs sooner,
but I was able to see it even on !THP kernels, just by giving it a bit
more time to occur.

The proper way to deal with this is to not wait, unless there's
congestion. Thanks to Mel Gorman, we already have the function that
perfectly fits the job. The patch was tested on a machine which
nicely revealed the problem after only 1 day of uptime, and it's been
working great.

Signed-off-by: Zlatko Calusic <zlatko.calusic@iskon.hr>
---
 mm/vmscan.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b7ed376..4588d1d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2546,7 +2546,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 							int *classzone_idx)
 {
-	int all_zones_ok;
+	struct zone *unbalanced_zone;
 	unsigned long balanced;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
@@ -2580,7 +2580,7 @@ loop_again:
 		unsigned long lru_pages = 0;
 		int has_under_min_watermark_zone = 0;
 
-		all_zones_ok = 1;
+		unbalanced_zone = NULL;
 		balanced = 0;
 
 		/*
@@ -2719,7 +2719,7 @@ loop_again:
 			}
 
 			if (!zone_balanced(zone, testorder, 0, end_zone)) {
-				all_zones_ok = 0;
+				unbalanced_zone = zone;
 				/*
 				 * We are still under min water mark.  This
 				 * means that we have a GFP_ATOMIC allocation
@@ -2752,7 +2752,7 @@ loop_again:
 				pfmemalloc_watermark_ok(pgdat))
 			wake_up(&pgdat->pfmemalloc_wait);
 
-		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
+		if (!unbalanced_zone || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
 			break;		/* kswapd: all done */
 		/*
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
@@ -2762,7 +2762,7 @@ loop_again:
 			if (has_under_min_watermark_zone)
 				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
 			else
-				congestion_wait(BLK_RW_ASYNC, HZ/10);
+				wait_iff_congested(unbalanced_zone, BLK_RW_ASYNC, HZ/10);
 		}
 
 		/*
@@ -2781,7 +2781,7 @@ out:
 	 * high-order: Balanced zones must make up at least 25% of the node
 	 *             for the node to be balanced
 	 */
-	if (!(all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))) {
+	if (unbalanced_zone && (!order || !pgdat_balanced(pgdat, balanced, *classzone_idx))) {
 		cond_resched();
 
 		try_to_freeze();
-- 1.7.10.4

-- 
Zlatko (this time with proper Signed-off-by line)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
