Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1660A6B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:15:42 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/3] mm: kswapd: Keep kswapd awake for high-order allocations until a percentage of the node is balanced
Date: Tue, 30 Nov 2010 17:15:39 +0000
Message-Id: <1291137339-6323-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1291137339-6323-1-git-send-email-mel@csn.ul.ie>
References: <1291137339-6323-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When reclaiming for high-orders, kswapd is responsible for balancing a
node but it should not reclaim excessively. It avoids excessive reclaim
by considering if any zone in a node is balanced then the node is
balanced. In the cases where there are imbalanced zone sizes (e.g.
ZONE_DMA with both ZONE_DMA32 and ZONE_NORMAL), kswapd can go to sleep
prematurely as just one small zone was balanced.

This alters the sleep logic of kswapd slightly. It counts the number of pages
that make up the balanced zones. If the total number of balanced pages is
more than a quarter of the zone, kswapd will go back to sleep.  This should
keep a node balanced without reclaiming an excessive number of pages.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   30 ++++++++++++++++++++++--------
 1 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9891efd..77c511f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2117,12 +2117,26 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 }
 #endif
 
+/*
+ * pgdat_balanced is used when checking if a node is balanced for high-order
+ * allocations. Only zones that meet watermarks make up "balanced".
+ * The total of balanced pages must be at least 25% of the node for the
+ * node to be considered balanced. Forcing all zones to be balanced for high
+ * orders can cause excessive reclaim when there are imbalanced zones.
+ * Similarly, we do not want kswapd to go to sleep because ZONE_DMA happens
+ * to be balanced when ZONE_DMA32 is huge in comparison and unbalanced
+ */
+static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced)
+{
+	return balanced > pgdat->node_present_pages / 4;
+}
+
 /* is kswapd sleeping prematurely? */
 static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 {
 	int i;
+	unsigned long balanced = 0;
 	bool all_zones_ok = true;
-	bool any_zone_ok = false;
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
@@ -2142,7 +2156,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 								0, 0))
 			all_zones_ok = false;
 		else
-			any_zone_ok = true;
+			balanced += zone->present_pages;
 	}
 
 	/*
@@ -2151,7 +2165,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 	 * For order-0, all zones must be balanced
 	 */
 	if (order)
-		return !any_zone_ok;
+		return pgdat_balanced(pgdat, balanced);
 	else
 		return !all_zones_ok;
 }
@@ -2181,7 +2195,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 							int high_zoneidx)
 {
 	int all_zones_ok;
-	int any_zone_ok;
+	unsigned long balanced;
 	int priority;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
@@ -2215,7 +2229,7 @@ loop_again:
 			disable_swap_token();
 
 		all_zones_ok = 1;
-		any_zone_ok = 0;
+		balanced = 0;
 
 		/*
 		 * Scan in the highmem->dma direction for the highest
@@ -2326,11 +2340,11 @@ loop_again:
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
 				if (i <= high_zoneidx)
-					any_zone_ok = 1;
+					balanced += zone->present_pages;
 			}
 
 		}
-		if (all_zones_ok || (order && any_zone_ok))
+		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced)))
 			break;		/* kswapd: all done */
 		/*
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
@@ -2353,7 +2367,7 @@ loop_again:
 			break;
 	}
 out:
-	if (!(all_zones_ok || (order && any_zone_ok))) {
+	if (!(all_zones_ok || (order && pgdat_balanced(pgdat, balanced)))) {
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
