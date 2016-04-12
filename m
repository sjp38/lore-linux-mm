Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 40081828E8
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:26:54 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id a140so47580312wma.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:26:54 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id r123si23161850wmb.8.2016.04.12.03.26.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 03:26:53 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id E4C1998EEB
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:26:52 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 08/28] mm, vmscan: Remove balance gap
Date: Tue, 12 Apr 2016 11:26:03 +0100
Message-Id: <1460456783-30996-9-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
References: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
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
index c23d8f9722ad..6aa05cf28a0b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2511,7 +2511,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
  */
 static inline bool compaction_ready(struct zone *zone, int order)
 {
-	unsigned long balance_gap, watermark;
+	unsigned long watermark;
 	bool watermark_ok;
 
 	/*
@@ -2520,9 +2520,7 @@ static inline bool compaction_ready(struct zone *zone, int order)
 	 * there is a buffer of free pages available to give compaction
 	 * a reasonable chance of completing and allocating the page
 	 */
-	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
-			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
-	watermark = high_wmark_pages(zone) + balance_gap + (2UL << order);
+	watermark = high_wmark_pages(zone) + (2UL << order);
 	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0);
 
 	/*
@@ -2999,10 +2997,9 @@ static void age_active_anon(struct pglist_data *pgdat,
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
@@ -3044,7 +3041,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 		if (!populated_zone(zone))
 			continue;
 
-		if (zone_balanced(zone, order, 0, classzone_idx))
+		if (zone_balanced(zone, order, classzone_idx))
 			return true;
 	}
 
@@ -3147,7 +3144,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 				break;
 			}
 
-			if (!zone_balanced(zone, order, 0, 0)) {
+			if (!zone_balanced(zone, order, 0)) {
 				classzone_idx = i;
 				break;
 			} else {
@@ -3215,7 +3212,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone_balanced(zone, sc.order, 0, classzone_idx)) {
+			if (zone_balanced(zone, sc.order, classzone_idx)) {
 				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
 				clear_bit(PGDAT_DIRTY, &pgdat->flags);
 				goto out;
@@ -3426,7 +3423,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
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
