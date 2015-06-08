Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 60CDC6B0072
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:48 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so86276696wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lk1si1335686wic.42.2015.06.08.06.56.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:47 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/25] mm, vmscan: Have kswapd only scan based on the highest requested zone
Date: Mon,  8 Jun 2015 14:56:11 +0100
Message-Id: <1433771791-30567-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

kswapd checks all eligible zones to see if they need balancing even if it was
woken for a lower zone. This made sense when we reclaimed on a per-zone basis
because we wanted to shrink zones fairly so avoid age-inversion problems.
Ideally this is completely unnecessary when reclaiming on a per-node basis.
In theory, there may still be anomalies when all requests are for lower
zones and very old pages are preserved in higher zones but this should be
the exceptional case.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index acdded211bd8..f0eed2e6883c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3142,11 +3142,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 
 		sc.nr_reclaimed = 0;
 
-		/*
-		 * Scan in the highmem->dma direction for the highest
-		 * zone which needs scanning
-		 */
-		for (i = pgdat->nr_zones - 1; i >= 0; i--) {
+		/* Scan from the highest requested zone to dma */
+		for (i = *classzone_idx; i >= 0; i--) {
 			struct zone *zone = pgdat->node_zones + i;
 
 			if (!populated_zone(zone))
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
