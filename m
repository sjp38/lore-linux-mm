Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE3AB6B027C
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:39:59 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so27057523lfg.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:39:59 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id gh5si3777078wjd.127.2016.07.08.02.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 02:39:58 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 2AB401C2477
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 10:39:58 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 27/34] mm, vmscan: Have kswapd reclaim from all zones if reclaiming and buffer_heads_over_limit
Date: Fri,  8 Jul 2016 10:35:03 +0100
Message-Id: <1467970510-21195-28-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The buffer_heads_over_limit limit in kswapd is inconsistent with direct
reclaim behaviour. It may force an an attempt to reclaim from all zones and
then not reclaim at all because higher zones were balanced than required
by the original request.

This patch will causes kswapd to consider reclaiming from all zones if
buffer_heads_over_limit.  However, if there are eligible zones for the
allocation request that woke kswapd then no reclaim will occur even if
buffer_heads_over_limit. This avoids kswapd over-reclaiming just because
buffer_heads_over_limit.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8a67aa53aa7b..97d0f7997fe7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3122,7 +3122,6 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = 1,
-		.reclaim_idx = classzone_idx,
 	};
 	count_vm_event(PAGEOUTRUN);
 
@@ -3130,12 +3129,16 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		bool raise_priority = true;
 
 		sc.nr_reclaimed = 0;
+		sc.reclaim_idx = classzone_idx;
 
 		/*
-		 * If the number of buffer_heads in the machine exceeds the
-		 * maximum allowed level then reclaim from all zones. This is
-		 * not specific to highmem as highmem may not exist but it is
-		 * it is expected that buffer_heads are stripped in writeback.
+		 * If the number of buffer_heads exceeds the maximum allowed
+		 * then consider reclaiming from all zones. This is not
+		 * specific to highmem which may not exist but it is it is
+		 * expected that buffer_heads are stripped in writeback.
+		 * Reclaim may still not go ahead if all eligible zones
+		 * for the original allocation request are balanced to
+		 * avoid excessive reclaim from kswapd.
 		 */
 		if (buffer_heads_over_limit) {
 			for (i = MAX_NR_ZONES - 1; i >= 0; i--) {
@@ -3154,14 +3157,16 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * Scanning from low to high zone would allow congestion to be
 		 * cleared during a very small window when a small low
 		 * zone was balanced even under extreme pressure when the
-		 * overall node may be congested.
+		 * overall node may be congested. Note that sc.reclaim_idx
+		 * is not used as buffer_heads_over_limit may have adjusted
+		 * it.
 		 */
-		for (i = sc.reclaim_idx; i >= 0; i--) {
+		for (i = classzone_idx; i >= 0; i--) {
 			zone = pgdat->node_zones + i;
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone_balanced(zone, sc.order, sc.reclaim_idx))
+			if (zone_balanced(zone, sc.order, classzone_idx))
 				goto out;
 		}
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
