Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BAF57828E4
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:15:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so64086908lfg.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:15:27 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id fo20si49538432wjc.21.2016.04.15.02.15.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:15:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 37511CF51
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:15:26 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 10/27] mm, vmscan: Clear congestion, dirty and need for compaction on a per-node basis
Date: Fri, 15 Apr 2016 10:13:16 +0100
Message-Id: <1460711613-2761-11-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
References: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
