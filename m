Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C93996B0267
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 14:06:37 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so25631340wme.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 11:06:37 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id t19si9816089wmt.106.2016.06.09.11.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 11:06:36 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 4AF2A1C18B7
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 19:06:36 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 10/27] mm, vmscan: Clear congestion, dirty and need for compaction on a per-node basis
Date: Thu,  9 Jun 2016 19:04:26 +0100
Message-Id: <1465495483-11855-11-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Congested and dirty tracking of a node and whether reclaim should stall
is still based on zone activity. This patch considers whether the kernel
should stall based on node-based reclaim activity.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dd68e3154732..e4f3e068b7a0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2966,7 +2966,17 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
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
@@ -3112,13 +3122,6 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
 
@@ -3177,11 +3180,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
