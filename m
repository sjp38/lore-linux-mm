Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 67C266B0005
	for <linux-mm@kvack.org>; Sun,  3 Apr 2016 19:46:08 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id n1so26366983pfn.2
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 16:46:08 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id y19si22532078pfa.62.2016.04.03.16.46.06
        for <linux-mm@kvack.org>;
        Sun, 03 Apr 2016 16:46:07 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: vmscan: reclaim highmem zone if buffer_heads is over limit
Date: Mon,  4 Apr 2016 08:46:09 +0900
Message-Id: <1459727169-5698-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, stable@vger.kernel.org

We have been reclaimed highmem zone if buffer_heads is over limit
but [1] changed the behavior so it doesn't reclaim highmem zone
although buffer_heads is over the limit.
This patch restores the logic.

[1] commit 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: stable@vger.kernel.org
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c7696a2e11c7..d84efa03c8a8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2550,7 +2550,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		sc->gfp_mask |= __GFP_HIGHMEM;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-					requested_highidx, sc->nodemask) {
+					gfp_zone(sc->gfp_mask), sc->nodemask) {
 		enum zone_type classzone_idx;
 
 		if (!populated_zone(zone))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
