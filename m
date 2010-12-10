Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 566F56B0093
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:46:30 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/6] mm: kswapd: Keep kswapd awake for high-order allocations until a percentage of the node is balanced
Date: Fri, 10 Dec 2010 15:46:21 +0000
Message-Id: <1291995985-5913-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When reclaiming for high-orders, kswapd is responsible for balancing a
node but it should not reclaim excessively. It avoids excessive reclaim by
considering if any zone in a node is balanced then the node is balanced. In
the cases where there are imbalanced zone sizes (e.g. ZONE_DMA with both
ZONE_DMA32 and ZONE_NORMAL), kswapd can go to sleep prematurely as just
one small zone was balanced.

This alters the sleep logic of kswapd slightly. It counts the number of pages
that make up the balanced zones. If the total number of balanced pages is
more than a quarter of the zone, kswapd will go back to sleep. This should
keep a node balanced without reclaiming an excessive number of pages.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 49 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 625dfba..6723101 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2191,10 +2191,40 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 }
 #endif
 
+/*
+ * pgdat_balanced is used when checking if a node is balanced for high-order
+ * allocations. Only zones that meet watermarks and are in a zone allowed
+ * by the callers classzone_idx are added to balanced_pages. The total of
+ * balanced pages must be at least 25% of the zones allowed by classzone_idx
+ * for the node to be considered balanced. Forcing all zones to be balanced
+ * for high orders can cause excessive reclaim when there are imbalanced zones.
+ * The choice of 25% is due to
+ *   o a 16M DMA zone that is balanced will not balance a zone on any
+ *     reasonable sized machine
+ *   o On all other machines, the top zone must be at least a reasonable
+ *     precentage of the middle zones. For example, on 32-bit x86, highmem
+ *     would need to be at least 256M for it to be balance a whole node.
+ *     Similarly, on x86-64 the Normal zone would need to be at least 1G
+ *     to balance a node on its own. These seemed like reasonable ratios.
+ */
+static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
+						int classzone_idx)
+{
+	unsigned long present_pages = 0;
+	int i;
+
+	for (i = 0; i <= classzone_idx; i++)
+		present_pages += pgdat->node_zones[i].present_pages;
+
+	return balanced_pages > (present_pages >> 2);
+}
+
 /* is kswapd sleeping prematurely? */
 static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 {
 	int i;
+	unsigned long balanced = 0;
+	bool all_zones_ok = true;
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
@@ -2212,10 +2242,20 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 
 		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
 								0, 0))
-			return 1;
+			all_zones_ok = false;
+		else
+			balanced += zone->present_pages;
 	}
 
-	return 0;
+	/*
+	 * For high-order requests, the balanced zones must contain at least
+	 * 25% of the nodes pages for kswapd to sleep. For order-0, all zones
+	 * must be balanced
+	 */
+	if (order)
+		return pgdat_balanced(pgdat, balanced, 0);
+	else
+		return !all_zones_ok;
 }
 
 /*
@@ -2243,7 +2283,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 							int classzone_idx)
 {
 	int all_zones_ok;
-	int any_zone_ok;
+	unsigned long balanced;
 	int priority;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
@@ -2277,7 +2317,7 @@ loop_again:
 			disable_swap_token();
 
 		all_zones_ok = 1;
-		any_zone_ok = 0;
+		balanced = 0;
 
 		/*
 		 * Scan in the highmem->dma direction for the highest
@@ -2397,11 +2437,11 @@ loop_again:
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
 				if (i <= classzone_idx)
-					any_zone_ok = 1;
+					balanced += zone->present_pages;
 			}
 
 		}
-		if (all_zones_ok || (order && any_zone_ok))
+		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, classzone_idx)))
 			break;		/* kswapd: all done */
 		/*
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
@@ -2427,10 +2467,10 @@ out:
 
 	/*
 	 * order-0: All zones must meet high watermark for a balanced node
-	 * high-order: Any zone below pgdats classzone_idx must meet the high
-	 *             watermark for a balanced node
+	 * high-order: Balanced zones must make up at least 25% of the node
+	 *             for the node to be balanced
 	 */
-	if (!(all_zones_ok || (order && any_zone_ok))) {
+	if (!(all_zones_ok || (order && pgdat_balanced(pgdat, balanced, classzone_idx)))) {
 		cond_resched();
 
 		try_to_freeze();
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
