Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6A91E900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:57 -0400 (EDT)
Received: by wgv5 with SMTP id 5so104172142wgv.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bf3si5354134wjb.13.2015.06.08.06.56.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:53 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/25] mm, vmscan: Clear congestion, dirty and need for compaction on a per-node basis
Date: Mon,  8 Jun 2015 14:56:15 +0100
Message-Id: <1433771791-30567-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Congested and dirty tracking of a node and whether reclaim should stall
is still based on zone activity. This patch considers whether the kernel
should stall based on node-based reclaim activity.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 54 ++++++++++++++++++++++++------------------------------
 1 file changed, 24 insertions(+), 30 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 50aa650ac206..e069decbcfa1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2921,16 +2921,30 @@ static void age_active_anon(struct pglist_data *pgdat,
 }
 
 static bool zone_balanced(struct zone *zone, int order,
-			  unsigned long balance_gap, int classzone_idx)
+			  unsigned long balance_gap, int classzone_idx,
+			  bool *pgdat_needs_compaction)
 {
 	if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone) +
 				    balance_gap, classzone_idx, 0))
 		return false;
 
+	/*
+	 * If any eligible zone is balanced then the node is not considered
+	 * to be congested or dirty
+	 */
+	clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
+	clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
+
 	if (IS_ENABLED(CONFIG_COMPACTION) && order && compaction_suitable(zone,
 				order, 0, classzone_idx) == COMPACT_SKIPPED)
 		return false;
 
+	/*
+	 * If a zone is balanced and compaction can start then there is no
+	 * need for kswapd to call compact_pgdat
+	 */
+	*pgdat_needs_compaction = false;
+
 	return true;
 }
 
@@ -2944,6 +2958,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 					int classzone_idx)
 {
 	int i;
+	bool dummy;
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
@@ -2968,7 +2983,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 	for (i = 0; i <= classzone_idx; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
-		if (zone_balanced(zone, order, 0, classzone_idx))
+		if (zone_balanced(zone, order, 0, classzone_idx, &dummy))
 			return true;
 	}
 
@@ -3099,29 +3114,10 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				break;
 			}
 
-			if (!zone_balanced(zone, order, 0, 0)) {
+			if (!zone_balanced(zone, order, 0, 0,
+						&pgdat_needs_compaction)) {
 				end_zone = i;
 				break;
-			} else {
-				/*
-				 * If any eligible zone is balanced then the
-				 * node is not considered congested or dirty.
-				 */
-				clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
-				clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
-
-				/*
-				 * If any zone is currently balanced then kswapd will
-				 * not call compaction as it is expected that the
-				 * necessary pages are already available.
-				 */
-				if (pgdat_needs_compaction &&
-						zone_watermark_ok(zone, order,
-							low_wmark_pages(zone),
-							*classzone_idx, 0)) {
-					pgdat_needs_compaction = false;
-				}
-
 			}
 		}
 
@@ -3182,12 +3178,9 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		 */
 		for (i = 0; i <= *classzone_idx; i++) {
 			zone = pgdat->node_zones + i;
-
-			if (zone_balanced(zone, sc.order, 0, *classzone_idx)) {
-				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
-				clear_bit(PGDAT_DIRTY, &pgdat->flags);
-				break;
-			}
+			if (zone_balanced(zone, sc.order, 0, *classzone_idx,
+						&pgdat_needs_compaction))
+				goto out;
 		}
 
 		/*
@@ -3379,6 +3372,7 @@ static int kswapd(void *p)
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
+	bool dummy;
 
 	if (!populated_zone(zone))
 		return;
@@ -3392,7 +3386,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	}
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
-	if (zone_balanced(zone, order, 0, 0))
+	if (zone_balanced(zone, order, 0, 0, &dummy))
 		return;
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
