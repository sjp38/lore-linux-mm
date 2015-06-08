Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 641356B0073
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:51 -0400 (EDT)
Received: by wiga1 with SMTP id a1so87440777wig.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx12si5266359wjc.192.2015.06.08.06.56.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:50 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/25] mm, vmscan: Avoid a second search through zones checking if compaction is required
Date: Mon,  8 Jun 2015 14:56:12 +0100
Message-Id: <1433771791-30567-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch removes an unnecessary loop.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 31 +++++++++++++------------------
 1 file changed, 13 insertions(+), 18 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f0eed2e6883c..975c315f1bf5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3182,30 +3182,25 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				 */
 				clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
 				clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
+
+				/*
+				 * If any zone is currently balanced then kswapd will
+				 * not call compaction as it is expected that the
+				 * necessary pages are already available.
+				 */
+				if (pgdat_needs_compaction &&
+						zone_watermark_ok(zone, order,
+							low_wmark_pages(zone),
+							*classzone_idx, 0)) {
+					pgdat_needs_compaction = false;
+				}
+
 			}
 		}
 
 		if (i < 0)
 			goto out;
 
-		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
-
-			if (!populated_zone(zone))
-				continue;
-
-			/*
-			 * If any zone is currently balanced then kswapd will
-			 * not call compaction as it is expected that the
-			 * necessary pages are already available.
-			 */
-			if (pgdat_needs_compaction &&
-					zone_watermark_ok(zone, order,
-						low_wmark_pages(zone),
-						*classzone_idx, 0))
-				pgdat_needs_compaction = false;
-		}
-
 		/*
 		 * If we're getting trouble reclaiming, start doing writepage
 		 * even in laptop mode.
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
