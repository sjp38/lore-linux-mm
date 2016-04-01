Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 76CDC6B007E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 03:59:14 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id zm5so85354911pac.0
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 00:59:14 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d3si19725613pas.116.2016.04.01.00.59.12
        for <linux-mm@kvack.org>;
        Fri, 01 Apr 2016 00:59:13 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: vmscan: reclaim highmem zone if buffer_heads is over limit
Date: Fri,  1 Apr 2016 17:00:58 +0900
Message-Id: <1459497658-22203-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

We have been reclaimed highmem zone if buffer_heads is over limit
but [1] changed the behavior so it doesn't reclaim highmem zone
although buffer_heads is over the limit.
This patch restores the logic.

As well, [2] removed classzone_idx so we don't need code related to
it. This patch cleans it up.

[1] commit 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")
[2] commit 5acbd3bfc93b ("mm, oom: rework oom detection")

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c7696a2e11c7..6e67de2a61ed 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2550,17 +2550,9 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		sc->gfp_mask |= __GFP_HIGHMEM;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-					requested_highidx, sc->nodemask) {
-		enum zone_type classzone_idx;
-
+					gfp_zone(sc->gfp_mask), sc->nodemask) {
 		if (!populated_zone(zone))
 			continue;
-
-		classzone_idx = requested_highidx;
-		while (!populated_zone(zone->zone_pgdat->node_zones +
-							classzone_idx))
-			classzone_idx--;
-
 		/*
 		 * Take care memory controller reclaiming has small influence
 		 * to global LRU.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
