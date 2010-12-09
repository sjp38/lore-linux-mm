Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C4C866B008A
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 06:18:25 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/6] mm: kswapd: Use the order that kswapd was reclaiming at for sleeping_prematurely()
Date: Thu,  9 Dec 2010 11:18:17 +0000
Message-Id: <1291893500-12342-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Before kswapd goes to sleep, it uses sleeping_prematurely() to check if
there was a race pushing a zone below its watermark. If the race
happened, it stays awake. However, balance_pgdat() can decide to reclaim
at a lower order if it decides that high-order reclaim is not working as
expected. This information is not passed back to sleeping_prematurely().
The impact is that kswapd remains awake reclaiming pages long after it
should have gone to sleep. This patch passes the adjusted order to
sleeping_prematurely and uses the same logic as balance_pgdat to decide
if it's ok to go to sleep.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b4472a1..52e229e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2132,7 +2132,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced)
 }
 
 /* is kswapd sleeping prematurely? */
-static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
+static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 {
 	int i;
 	unsigned long balanced = 0;
@@ -2142,7 +2142,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 	if (remaining)
 		return 1;
 
-	/* If after HZ/10, a zone is below the high mark, it's premature */
+	/* Check the watermark levels */
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
@@ -2427,7 +2427,13 @@ out:
 		}
 	}
 
-	return sc.nr_reclaimed;
+	/*
+	 * Return the order we were reclaiming at so sleeping_prematurely()
+	 * makes a decision on the order we were last reclaiming at. However,
+	 * if another caller entered the allocator slow path while kswapd
+	 * was awake, order will remain at the higher level
+	 */
+	return order;
 }
 
 /*
@@ -2537,7 +2543,7 @@ static int kswapd(void *p)
 		 */
 		if (!ret) {
 			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			balance_pgdat(pgdat, order, classzone_idx);
+			order = balance_pgdat(pgdat, order, classzone_idx);
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
