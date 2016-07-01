Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B3D4D6B0261
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:02:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so25852725wma.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 13:02:43 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id b131si389909wmd.118.2016.07.01.13.02.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 13:02:42 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 5C95E98A4D
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 20:02:42 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 05/31] mm, vmscan: have kswapd only scan based on the highest requested zone
Date: Fri,  1 Jul 2016 21:01:13 +0100
Message-Id: <1467403299-25786-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

kswapd checks all eligible zones to see if they need balancing even if it
was woken for a lower zone.  This made sense when we reclaimed on a
per-zone basis because we wanted to shrink zones fairly so avoid
age-inversion problems.  Ideally this is completely unnecessary when
reclaiming on a per-node basis.  In theory, there may still be anomalies
when all requests are for lower zones and very old pages are preserved in
higher zones but this should be the exceptional case.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 766b36bec829..c6e61dae382b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3209,11 +3209,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
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
