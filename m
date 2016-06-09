Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40B516B0264
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 14:06:07 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u74so20883650lff.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 11:06:07 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id 198si39521295wmw.2.2016.06.09.11.06.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 11:06:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id A967298E9F
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 18:06:05 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 07/27] mm, vmscan: Remove balance gap
Date: Thu,  9 Jun 2016 19:04:23 +0100
Message-Id: <1465495483-11855-8-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The balance gap was introduced to apply equal pressure to all zones when
reclaiming for a higher zone. With node-based LRU, the need for the balance
gap is removed and the code is dead so remove it.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9368af4cfb06..96bf841f9352 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2488,7 +2488,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
  */
 static inline bool compaction_ready(struct zone *zone, int order, int classzone_idx)
 {
-	unsigned long balance_gap, watermark;
+	unsigned long watermark;
 	bool watermark_ok;
 
 	/*
@@ -2497,9 +2497,7 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
 	 * there is a buffer of free pages available to give compaction
 	 * a reasonable chance of completing and allocating the page
 	 */
-	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
-			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
-	watermark = high_wmark_pages(zone) + balance_gap + (2UL << order);
+	watermark = high_wmark_pages(zone) + (2UL << order);
 	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, classzone_idx);
 
 	/*
@@ -2962,10 +2960,9 @@ static void age_active_anon(struct pglist_data *pgdat,
 	} while (memcg);
 }
 
-static bool zone_balanced(struct zone *zone, int order,
-			unsigned long balance_gap, int classzone_idx)
+static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
 {
-	unsigned long mark = high_wmark_pages(zone) + balance_gap;
+	unsigned long mark = high_wmark_pages(zone);
 
 	return zone_watermark_ok_safe(zone, order, mark, classzone_idx);
 }
@@ -3007,7 +3004,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 		if (!populated_zone(zone))
 			continue;
 
-		if (zone_balanced(zone, order, 0, classzone_idx))
+		if (zone_balanced(zone, order, classzone_idx))
 			return true;
 	}
 
@@ -3110,7 +3107,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 				break;
 			}
 
-			if (!zone_balanced(zone, order, 0, 0)) {
+			if (!zone_balanced(zone, order, 0)) {
 				classzone_idx = i;
 				break;
 			} else {
@@ -3178,7 +3175,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone_balanced(zone, sc.order, 0, classzone_idx)) {
+			if (zone_balanced(zone, sc.order, classzone_idx)) {
 				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
 				clear_bit(PGDAT_DIRTY, &pgdat->flags);
 				goto out;
@@ -3389,7 +3386,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	}
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
-	if (zone_balanced(zone, order, 0, 0))
+	if (zone_balanced(zone, order, 0))
 		return;
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
