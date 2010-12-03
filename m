Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 99B4A6B0088
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 06:45:38 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/5] mm: kswapd: Use the classzone idx that kswapd was using for sleeping_prematurely()
Date: Fri,  3 Dec 2010 11:45:32 +0000
Message-Id: <1291376734-30202-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1291376734-30202-1-git-send-email-mel@csn.ul.ie>
References: <1291376734-30202-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
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
---
 mm/vmscan.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 193feeb..6ae1873 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2118,7 +2118,8 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 #endif
 
 /* is kswapd sleeping prematurely? */
-static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
+static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
+					int classzone_idx)
 {
 	int i;
 	bool all_zones_ok = true;
@@ -2139,7 +2140,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 			continue;
 
 		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
-								0, 0))
+							classzone_idx, 0))
 			all_zones_ok = false;
 		else
 			any_zone_ok = true;
@@ -2177,7 +2178,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
  * of pages is balanced across the zones.
  */
 static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
-							int classzone_idx)
+							int *classzone_idx)
 {
 	int all_zones_ok;
 	int any_zone_ok;
@@ -2240,6 +2241,7 @@ loop_again:
 			if (!zone_watermark_ok(zone, order,
 					high_wmark_pages(zone), 0, 0)) {
 				end_zone = i;
+				*classzone_idx = i;
 				break;
 			}
 		}
@@ -2324,7 +2326,7 @@ loop_again:
 				 * spectulatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
-				if (i <= classzone_idx)
+				if (i <= *classzone_idx)
 					any_zone_ok = 1;
 			}
 
@@ -2408,6 +2410,7 @@ out:
 	 * if another caller entered the allocator slow path while kswapd
 	 * was awake, order will remain at the higher level
 	 */
+	*classzone_idx = end_zone;
 	return order;
 }
 
@@ -2466,8 +2469,8 @@ static int kswapd(void *p)
 
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 		new_order = pgdat->kswapd_max_order;
-		new_classzone_idx = pgdat->classzone_idx;
 		pgdat->kswapd_max_order = 0;
+		new_classzone_idx = pgdat->classzone_idx;
 		pgdat->classzone_idx = MAX_NR_ZONES - 1;
 		if (order < new_order || classzone_idx > new_classzone_idx) {
 			/*
@@ -2481,7 +2484,7 @@ static int kswapd(void *p)
 				long remaining = 0;
 
 				/* Try to sleep for a short interval */
-				if (!sleeping_prematurely(pgdat, order, remaining)) {
+				if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
 					remaining = schedule_timeout(HZ/10);
 					finish_wait(&pgdat->kswapd_wait, &wait);
 					prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
@@ -2492,7 +2495,7 @@ static int kswapd(void *p)
 				 * premature sleep. If not, then go fully
 				 * to sleep until explicitly woken up
 				 */
-				if (!sleeping_prematurely(pgdat, order, remaining)) {
+				if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
 					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 					schedule();
 				} else {
@@ -2518,7 +2521,7 @@ static int kswapd(void *p)
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
