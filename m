Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6E1B828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:05:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so25637968wmr.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 13:05:47 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id ld9si5051584wjc.53.2016.07.01.13.05.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 13:05:46 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 48EA91C224D
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 21:05:46 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 23/31] mm, vmscan: Avoid passing in classzone_idx unnecessarily to shrink_node
Date: Fri,  1 Jul 2016 21:01:31 +0100
Message-Id: <1467403299-25786-24-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

shrink_node receives all information it needs about classzone_idx
from sc->reclaim_idx so remove the aliases.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a6b30fe1de89..6534fbe1b96f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2426,8 +2426,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	return true;
 }
 
-static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
-			enum zone_type classzone_idx)
+static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
@@ -2653,7 +2652,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		shrink_node(zone->zone_pgdat, sc, classzone_idx);
+		shrink_node(zone->zone_pgdat, sc);
 	}
 
 	/*
@@ -3077,7 +3076,6 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
  * This is used to determine if the scanning priority needs to be raised.
  */
 static bool kswapd_shrink_node(pg_data_t *pgdat,
-			       int classzone_idx,
 			       struct scan_control *sc)
 {
 	struct zone *zone;
@@ -3085,7 +3083,7 @@ static bool kswapd_shrink_node(pg_data_t *pgdat,
 
 	/* Reclaim a number of pages proportional to the number of zones */
 	sc->nr_to_reclaim = 0;
-	for (z = 0; z <= classzone_idx; z++) {
+	for (z = 0; z <= sc->reclaim_idx; z++) {
 		zone = pgdat->node_zones + z;
 		if (!populated_zone(zone))
 			continue;
@@ -3097,7 +3095,7 @@ static bool kswapd_shrink_node(pg_data_t *pgdat,
 	 * Historically care was taken to put equal pressure on all zones but
 	 * now pressure is applied based on node LRU order.
 	 */
-	shrink_node(pgdat, sc, classzone_idx);
+	shrink_node(pgdat, sc);
 
 	/*
 	 * Fragmentation may mean that the system cannot be rebalanced for
@@ -3159,7 +3157,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 				if (!populated_zone(zone))
 					continue;
 
-				classzone_idx = i;
+				sc.reclaim_idx = i;
 				break;
 			}
 		}
@@ -3169,12 +3167,12 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * high to low zone to avoid prematurely clearing pgdat
 		 * congested state.
 		 */
-		for (i = classzone_idx; i >= 0; i--) {
+		for (i = sc.reclaim_idx; i >= 0; i--) {
 			zone = pgdat->node_zones + i;
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone_balanced(zone, sc.order, classzone_idx))
+			if (zone_balanced(zone, sc.order, sc.reclaim_idx))
 				goto out;
 		}
 
@@ -3205,7 +3203,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * enough pages are already being scanned that that high
 		 * watermark would be met at 100% efficiency.
 		 */
-		if (kswapd_shrink_node(pgdat, classzone_idx, &sc))
+		if (kswapd_shrink_node(pgdat, &sc))
 			raise_priority = false;
 
 		/*
@@ -3677,7 +3675,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		 * priorities until we have enough memory freed.
 		 */
 		do {
-			shrink_node(pgdat, &sc, classzone_idx);
+			shrink_node(pgdat, &sc);
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
