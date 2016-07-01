Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC1336B0262
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:38:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a66so21730084wme.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:38:49 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id v129si4585496wme.91.2016.07.01.08.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 08:38:48 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 516D41C2263
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:38:48 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 05/31] mm, vmscan: have kswapd only scan based on the highest requested zone
Date: Fri,  1 Jul 2016 16:37:20 +0100
Message-Id: <1467387466-10022-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
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

Link: http://lkml.kernel.org/r/1466518566-30034-6-git-send-email-mgorman@techsingularity.net
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@surriel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
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
