Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id C21346B005A
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 21:34:33 -0500 (EST)
Date: Mon, 9 Jan 2012 21:33:13 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 1/2] mm: kswapd test order 0 watermarks when compaction
 is enabled
Message-ID: <20120109213313.22841ef5@annuminas.surriel.com>
In-Reply-To: <20120109213156.0ff47ee5@annuminas.surriel.com>
References: <20120109213156.0ff47ee5@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, aarcange@redhat.com

When built with CONFIG_COMPACTION, kswapd does not try to free
contiguous pages.  Because it is not trying, it should also not
test whether it succeeded, because that can result in continuous
page reclaim, until a large fraction of memory is free and large
fractions of the working set have been evicted.

Also remove a line of code that increments balanced right before
exiting the function.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f54a05b..c3eec6b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2608,7 +2608,7 @@ loop_again:
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			int nr_slab;
+			int nr_slab, testorder;
 			unsigned long balance_gap;
 
 			if (!populated_zone(zone))
@@ -2637,11 +2637,25 @@ loop_again:
 			 * gap is either the low watermark or 1%
 			 * of the zone, whichever is smaller.
 			 */
+			testorder = order;
 			balance_gap = min(low_wmark_pages(zone),
 				(zone->present_pages +
 					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
 				KSWAPD_ZONE_BALANCE_GAP_RATIO);
-			if (!zone_watermark_ok_safe(zone, order,
+			/*
+			 * Kswapd reclaims only single pages when
+			 * COMPACTION_BUILD. Trying too hard to get
+			 * contiguous free pages can result in excessive
+			 * amounts of free memory, and useful things
+			 * getting kicked out of memory.
+			 * Limit the amount of reclaim to something sane,
+			 * plus space for compaction to do its thing.
+			 */
+			if (COMPACTION_BUILD) {
+				testorder = 0;
+				balance_gap += 2<<order;
+			}
+			if (!zone_watermark_ok_safe(zone, testorder,
 					high_wmark_pages(zone) + balance_gap,
 					end_zone, 0)) {
 				shrink_zone(priority, zone, &sc);
@@ -2670,7 +2684,7 @@ loop_again:
 				continue;
 			}
 
-			if (!zone_watermark_ok_safe(zone, order,
+			if (!zone_watermark_ok_safe(zone, testorder,
 					high_wmark_pages(zone), end_zone, 0)) {
 				all_zones_ok = 0;
 				/*
@@ -2776,8 +2790,6 @@ out:
 
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
