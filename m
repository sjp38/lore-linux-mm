Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DAF596B0098
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:46:35 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 6/6] mm: kswapd: Use the classzone idx that kswapd was using for sleeping_prematurely()
Date: Fri, 10 Dec 2010 15:46:25 +0000
Message-Id: <1291995985-5913-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When kswapd is woken up for a high-order allocation, it takes account of
the highest usable zone by the caller (the classzone idx). During
allocation, this index is used to select the lowmem_reserve[] that
should be applied to the watermark calculation in zone_watermark_ok().

When balancing a node, kswapd considers the highest unbalanced zone to be the
classzone index. This will always be at least be the callers classzone_idx
and can be higher. However, sleeping_prematurely() always considers the
lowest zone (e.g. ZONE_DMA) to be the classzone index. This means that
sleeping_prematurely() can consider a zone to be balanced that is unusable
by the allocation request that originally woke kswapd. This patch changes
sleeping_prematurely() to use a classzone_idx matching the value it used
in balance_pgdat().

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5995121..cf03a11 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2220,7 +2220,8 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
 }
 
 /* is kswapd sleeping prematurely? */
-static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
+static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
+					int classzone_idx)
 {
 	int i;
 	unsigned long balanced = 0;
@@ -2228,7 +2229,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
-		return 1;
+		return true;
 
 	/* Check the watermark levels */
 	for (i = 0; i < pgdat->nr_zones; i++) {
@@ -2249,7 +2250,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 		}
 
 		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
-								0, 0))
+							classzone_idx, 0))
 			all_zones_ok = false;
 		else
 			balanced += zone->present_pages;
@@ -2261,7 +2262,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 	 * must be balanced
 	 */
 	if (order)
-		return pgdat_balanced(pgdat, balanced, 0);
+		return pgdat_balanced(pgdat, balanced, classzone_idx);
 	else
 		return !all_zones_ok;
 }
@@ -2288,7 +2289,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
  * of pages is balanced across the zones.
  */
 static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
-							int classzone_idx)
+							int *classzone_idx)
 {
 	int all_zones_ok;
 	unsigned long balanced;
@@ -2351,6 +2352,7 @@ loop_again:
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone), 0, 0)) {
 				end_zone = i;
+				*classzone_idx = i;
 				break;
 			}
 		}
@@ -2444,12 +2446,12 @@ loop_again:
 				 * spectulatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
-				if (i <= classzone_idx)
+				if (i <= *classzone_idx)
 					balanced += zone->present_pages;
 			}
 
 		}
-		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, classzone_idx)))
+		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
 			break;		/* kswapd: all done */
 		/*
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
@@ -2478,7 +2480,7 @@ out:
 	 * high-order: Balanced zones must make up at least 25% of the node
 	 *             for the node to be balanced
 	 */
-	if (!(all_zones_ok || (order && pgdat_balanced(pgdat, balanced, classzone_idx)))) {
+	if (!(all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))) {
 		cond_resched();
 
 		try_to_freeze();
@@ -2539,10 +2541,11 @@ out:
 	 * if another caller entered the allocator slow path while kswapd
 	 * was awake, order will remain at the higher level
 	 */
+	*classzone_idx = end_zone;
 	return order;
 }
 
-static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
+static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 {
 	long remaining = 0;
 	DEFINE_WAIT(wait);
@@ -2553,7 +2556,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
 	/* Try to sleep for a short interval */
-	if (!sleeping_prematurely(pgdat, order, remaining)) {
+	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
 		remaining = schedule_timeout(HZ/10);
 		finish_wait(&pgdat->kswapd_wait, &wait);
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
@@ -2563,7 +2566,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
 	 * After a short sleep, check if it was a premature sleep. If not, then
 	 * go fully to sleep until explicitly woken up.
 	 */
-	if (!sleeping_prematurely(pgdat, order, remaining)) {
+	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
 		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 
 		/*
@@ -2651,7 +2654,7 @@ static int kswapd(void *p)
 			order = new_order;
 			classzone_idx = new_classzone_idx;
 		} else {
-			kswapd_try_to_sleep(pgdat, order);
+			kswapd_try_to_sleep(pgdat, order, classzone_idx);
 			order = pgdat->kswapd_max_order;
 			classzone_idx = pgdat->classzone_idx;
 			pgdat->kswapd_max_order = 0;
@@ -2668,7 +2671,7 @@ static int kswapd(void *p)
 		 */
 		if (!ret) {
 			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			order = balance_pgdat(pgdat, order, classzone_idx);
+			order = balance_pgdat(pgdat, order, &classzone_idx);
 		}
 	}
 	return 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
