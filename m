Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF6236B0262
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 14:05:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r5so25651368wmr.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 11:05:46 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id j131si9871819wmg.37.2016.06.09.11.05.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 11:05:45 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 3E4B22F8053
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 18:05:45 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 05/27] mm, vmscan: Have kswapd only scan based on the highest requested zone
Date: Thu,  9 Jun 2016 19:04:21 +0100
Message-Id: <1465495483-11855-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
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
index ab1b28e7e20a..0a619241c576 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3171,11 +3171,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
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
