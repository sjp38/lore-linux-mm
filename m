Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id CFB5D828E8
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:27:03 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id u206so21742043wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:27:03 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id qg18si2509843wjb.19.2016.04.12.03.27.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:27:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 80EEF1C2217
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:27:02 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 11/28] mm, vmscan: Clear congestion, dirty and need for compaction on a per-node basis
Date: Tue, 12 Apr 2016 11:26:06 +0100
Message-Id: <1460456783-30996-12-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
References: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
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
index f0bb2412fc01..5701f570e4f6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3000,7 +3000,17 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
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
@@ -3146,13 +3156,6 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
 
@@ -3211,11 +3214,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
