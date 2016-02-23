Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id C5EB66B025E
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:45:43 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id c200so221134724wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:45:43 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id v80si39715460wmv.94.2016.02.23.05.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 05:45:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 0A99B1C1DE9
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:45:19 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 11/27] mm, vmscan: Clear congestion, dirty and need for compaction on a per-node basis
Date: Tue, 23 Feb 2016 13:45:00 +0000
Message-Id: <1456235116-32385-12-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
References: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Congested and dirty tracking of a node and whether reclaim should stall
is still based on zone activity. This patch considers whether the kernel
should stall based on node-based reclaim activity.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fe004cb11b71..1f5d3829d35e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2988,7 +2988,17 @@ static bool zone_balanced(struct zone *zone, int order,
 {
 	unsigned long mark = high_wmark_pages(zone) + balance_gap;
 
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
@@ -3133,13 +3143,6 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			if (!zone_balanced(zone, order, 0, 0)) {
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
 
@@ -3199,11 +3202,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone_balanced(zone, sc.order, 0, classzone_idx)) {
-				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
-				clear_bit(PGDAT_DIRTY, &pgdat->flags);
+			if (zone_balanced(zone, sc.order, 0, classzone_idx))
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
