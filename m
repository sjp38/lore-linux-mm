Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 94A446B025A
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:45:34 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id b205so200259938wmb.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:45:34 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id f10si44767101wjq.212.2016.02.23.05.45.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 05:45:18 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 27E6C1C136D
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:45:18 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 07/27] mm, vmscan: Have kswapd only scan based on the highest requested zone
Date: Tue, 23 Feb 2016 13:44:56 +0000
Message-Id: <1456235116-32385-8-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
References: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
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
index 3e423993d374..1decaa31c4c6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3193,11 +3193,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
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
