Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1193B6B0263
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:21:18 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id n3so58338177wmn.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:21:18 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id om5si2717184wjc.58.2016.04.06.04.21.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 04:21:17 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 837ED1C1C89
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 12:21:16 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 06/27] mm, vmscan: Have kswapd only scan based on the highest requested zone
Date: Wed,  6 Apr 2016 12:20:05 +0100
Message-Id: <1459941626-3290-7-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
References: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

kswapd checks all eligible zones to see if they need balancing even if it was
woken for a lower zone. This made sense when we reclaimed on a per-zone basis
because we wanted to shrink zones fairly so avoid age-inversion problems.
Ideally this is completely unnecessary when reclaiming on a per-node basis.
In theory, there may still be anomalies when all requests are for lower
zones and very old pages are preserved in higher zones but this should be
the exceptional case.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0f8dc3488f9d..f2534e8f8527 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3208,11 +3208,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
 		sc.nr_reclaimed = 0;
 
-		/*
-		 * Scan in the highmem->dma direction for the highest
-		 * zone which needs scanning
-		 */
-		for (i = pgdat->nr_zones - 1; i >= 0; i--) {
+		/* Scan from the highest requested zone to dma */
+		for (i = classzone_idx; i >= 0; i--) {
 			struct zone *zone = pgdat->node_zones + i;
 
 			if (!populated_zone(zone))
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
