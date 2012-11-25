Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id A51676B005A
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 13:29:59 -0500 (EST)
Date: Sun, 25 Nov 2012 13:29:50 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] mm,vmscan: free pages if compaction_suitable tells us to
Message-ID: <20121125132950.11b15e38@annuminas.surriel.com>
In-Reply-To: <20121125175728.3db4ac6a@fem.tu-ilmenau.de>
References: <20121119202152.4B0E420004E@hpza10.eem.corp.google.com>
	<20121125175728.3db4ac6a@fem.tu-ilmenau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Cc: akpm@linux-foundation.org, mgorman@suse.de, Valdis.Kletnieks@vt.edu, jirislaby@gmail.com, jslaby@suse.cz, zkabelac@redhat.com, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Sun, 25 Nov 2012 17:57:28 +0100
Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de> wrote:

> With kernel 3.7-rc6 I've still problems with kswapd0 on my laptop

> And this is most of the time. I've only observed this behavior on the
> laptop. Other systems don't show this.

This suggests it may have something to do with small memory zones,
where we end up with the "funny" situation that the high watermark
(+ balance gap) for a particular zone is less than the low watermark
+ 2<<order pages, which is the number of free pages required to keep
compaction_suitable happy.

Could you try this patch?

---8<---
Subject: mm,vmscan: free pages if compaction_suitable tells us to

For small zones, it is possible for the low watermark + 2<<order pages
to exceed the high watermark + balance_gap. This could send kswapd into
an infinite loop.

The solution is to always free pages if compaction_suitable indicates
we need to do so.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 48550c6..b99ecba 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2614,7 +2614,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			int nr_slab, testorder;
+			int nr_slab, force_reclaim = 0;
 			unsigned long balance_gap;
 
 			if (!populated_zone(zone))
@@ -2648,21 +2648,21 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				(zone->present_pages +
 					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
 				KSWAPD_ZONE_BALANCE_GAP_RATIO);
+
 			/*
 			 * Kswapd reclaims only single pages with compaction
-			 * enabled. Trying too hard to reclaim until contiguous
-			 * free pages have become available can hurt performance
-			 * by evicting too much useful data from memory.
-			 * Do not reclaim more than needed for compaction.
+			 * enabled. We reclaim memory if this zone is below
+			 * the normal reclaim watermark, or if there is not
+			 * enough memory available for compaction.
 			 */
-			testorder = order;
 			if (COMPACTION_BUILD && order &&
-					compaction_suitable(zone, order) !=
+					compaction_suitable(zone, order) ==
 						COMPACT_SKIPPED)
-				testorder = 0;
+				force_reclaim = 1;
 
 			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
-				    !zone_watermark_ok_safe(zone, testorder,
+				    force_reclaim ||
+				    !zone_watermark_ok_safe(zone, 0,
 					high_wmark_pages(zone) + balance_gap,
 					end_zone, 0)) {
 				shrink_zone(zone, &sc);
@@ -2691,7 +2691,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				continue;
 			}
 
-			if (!zone_watermark_ok_safe(zone, testorder,
+			if (!zone_watermark_ok_safe(zone, 0,
 					high_wmark_pages(zone), end_zone, 0)) {
 				all_zones_ok = 0;
 				/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
