Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 666616B0264
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:17:30 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a4so13584560lfa.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:17:30 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id y1si36509532wjm.132.2016.06.21.07.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 07:17:29 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 8F7841C19A3
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 15:17:28 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 07/27] mm, vmscan: Remove balance gap
Date: Tue, 21 Jun 2016 15:15:46 +0100
Message-Id: <1466518566-30034-8-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The balance gap was introduced to apply equal pressure to all zones when
reclaiming for a higher zone. With node-based LRU, the need for the balance
gap is removed and the code is dead so remove it.

[vbabka@suse.cz: Also remove KSWAPD_ZONE_BALANCE_GAP_RATIO]
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/swap.h |  9 ---------
 mm/vmscan.c          | 19 ++++++++-----------
 2 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c82f916008b7..916e2eddecd6 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -157,15 +157,6 @@ enum {
 #define SWAP_CLUSTER_MAX 32UL
 #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
 
-/*
- * Ratio between zone->managed_pages and the "gap" that above the per-zone
- * "high_wmark". While balancing nodes, We allow kswapd to shrink zones that
- * do not meet the (high_wmark + gap) watermark, even which already met the
- * high_wmark, in order to provide better per-zone lru behavior. We are ok to
- * spend not more than 1% of the memory for this zone balancing "gap".
- */
-#define KSWAPD_ZONE_BALANCE_GAP_RATIO 100
-
 #define SWAP_MAP_MAX	0x3e	/* Max duplication count, in first swap_map */
 #define SWAP_MAP_BAD	0x3f	/* Note pageblock is bad, in first swap_map */
 #define SWAP_HAS_CACHE	0x40	/* Flag page is cached, in first swap_map */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5873f5003078..2c83dff0650e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2512,7 +2512,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
  */
 static inline bool compaction_ready(struct zone *zone, int order, int classzone_idx)
 {
-	unsigned long balance_gap, watermark;
+	unsigned long watermark;
 	bool watermark_ok;
 
 	/*
@@ -2521,9 +2521,7 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
 	 * there is a buffer of free pages available to give compaction
 	 * a reasonable chance of completing and allocating the page
 	 */
-	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
-			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
-	watermark = high_wmark_pages(zone) + balance_gap + (2UL << order);
+	watermark = high_wmark_pages(zone) + (2UL << order);
 	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, classzone_idx);
 
 	/*
@@ -2992,10 +2990,9 @@ static void age_active_anon(struct pglist_data *pgdat,
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
@@ -3037,7 +3034,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 		if (!populated_zone(zone))
 			continue;
 
-		if (zone_balanced(zone, order, 0, classzone_idx))
+		if (zone_balanced(zone, order, classzone_idx))
 			return true;
 	}
 
@@ -3140,7 +3137,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 				break;
 			}
 
-			if (!zone_balanced(zone, order, 0, 0)) {
+			if (!zone_balanced(zone, order, 0)) {
 				classzone_idx = i;
 				break;
 			} else {
@@ -3208,7 +3205,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone_balanced(zone, sc.order, 0, classzone_idx)) {
+			if (zone_balanced(zone, sc.order, classzone_idx)) {
 				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
 				clear_bit(PGDAT_DIRTY, &pgdat->flags);
 				goto out;
@@ -3419,7 +3416,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
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
