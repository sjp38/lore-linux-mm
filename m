Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3BE828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:18:00 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so13633400lfg.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:18:00 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id y184si4098499wmy.117.2016.06.21.07.17.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 07:17:59 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 321389853A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:17:59 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 10/27] mm, vmscan: Remove duplicate logic clearing node congestion and dirty state
Date: Tue, 21 Jun 2016 15:15:49 +0100
Message-Id: <1466518566-30034-11-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Reclaim may stall if there is too much dirty or congested data on a node.
This was previously based on zone flags and the logic for clearing the
flags is in two places. As congestion/dirty tracking is now tracked on
a per-node basis, we can remove some duplicate logic.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2dafaa06884b..8347406c75fa 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2996,7 +2996,17 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
 {
 	unsigned long mark = high_wmark_pages(zone);
 
-	return zone_watermark_ok_safe(zone, order, mark, classzone_idx);
+	if (!zone_watermark_ok_safe(zone, order, mark, classzone_idx))
+		return false;
+
+	/*
+	 * If any eligible zone is balanced then the node is not considered
+	 * to be congested or dirty
+	 */
+	clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
+	clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
+
+	return true;
 }
 
 /*
@@ -3142,13 +3152,6 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			if (!zone_balanced(zone, order, 0)) {
 				classzone_idx = i;
 				break;
-			} else {
-				/*
-				 * If any eligible zone is balanced then the
-				 * node is not considered congested or dirty.
-				 */
-				clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
-				clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
 			}
 		}
 
@@ -3207,11 +3210,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone_balanced(zone, sc.order, classzone_idx)) {
-				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
-				clear_bit(PGDAT_DIRTY, &pgdat->flags);
+			if (zone_balanced(zone, sc.order, classzone_idx))
 				goto out;
-			}
 		}
 
 		/*
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
