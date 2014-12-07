Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id EFA416B0032
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 07:40:31 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so3486707pdb.4
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 04:40:31 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id z13si55620003pbv.45.2014.12.07.04.40.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Dec 2014 04:40:30 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] mm: vmscan: shrink_zones: assure class zone is populated
Date: Sun, 7 Dec 2014 15:40:21 +0300
Message-ID: <1417956021-27298-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit 5df87d36a45e ("mm: vmscan: invoke slab shrinkers from
shrink_zone()") slab shrinkers are invoked from shrink_zone. Since slab
shrinkers lack the notion of memory zones, we only call slab shrinkers
after scanning the highest zone suitable for allocation (class zone).
However, class zone can be empty. E.g. if an x86_64 host has less than
4G of RAM, it will have only ZONE_DMA and ZONE_DMA32 populated while the
class zone for most allocations, ZONE_NORMAL, will be empty. As a
result, slab caches will not be scanned at all from the direct reclaim
path, which may result in premature OOM killer invocations.

Let's take the highest *populated* zone suitable for allocation for the
class zone to fix this issue.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/vmscan.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9130cf67bac1..5e8772b2b9ef 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2454,8 +2454,16 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					requested_highidx, sc->nodemask) {
+		enum zone_type classzone_idx;
+
 		if (!populated_zone(zone))
 			continue;
+
+		classzone_idx = requested_highidx;
+		while (!populated_zone(zone->zone_pgdat->node_zones +
+							classzone_idx))
+			classzone_idx--;
+
 		/*
 		 * Take care memory controller reclaiming has small influence
 		 * to global LRU.
@@ -2503,7 +2511,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		if (shrink_zone(zone, sc, zone_idx(zone) == requested_highidx))
+		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
 			reclaimable = true;
 
 		if (global_reclaim(sc) &&
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
