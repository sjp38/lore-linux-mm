Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5D31482F65
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 14:13:39 -0400 (EDT)
Received: by lffy185 with SMTP id y185so116869330lff.2
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 11:13:38 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gq4si23901531wib.52.2015.10.19.11.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 11:13:38 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: vmscan: count slab shrinking results after each shrink_slab()
Date: Mon, 19 Oct 2015 14:13:35 -0400
Message-Id: <1445278415-21138-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

cb731d6 ("vmscan: per memory cgroup slab shrinkers") sought to
optimize accumulating slab reclaim results in sc->nr_reclaimed only
once per zone, but the memcg hierarchy walk itself uses
sc->nr_reclaimed as an exit condition. This can lead to overreclaim.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 27d580b..a02654e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2441,11 +2441,18 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
 			zone_lru_pages += lru_pages;
 
-			if (memcg && is_classzone)
+			if (memcg && is_classzone) {
 				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
 
+				if (reclaim_state) {
+					sc->nr_reclaimed +=
+						reclaim_state->reclaimed_slab;
+					reclaim_state->reclaimed_slab = 0;
+				}
+			}
+
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
 			 * cgroups to fulfill the overall scan target for the
@@ -2467,14 +2474,16 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		 * Shrink the slab caches in the same proportion that
 		 * the eligible LRU pages were scanned.
 		 */
-		if (global_reclaim(sc) && is_classzone)
+		if (global_reclaim(sc) && is_classzone) {
 			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
 				    sc->nr_scanned - nr_scanned,
 				    zone_lru_pages);
 
-		if (reclaim_state) {
-			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
+			if (reclaim_state) {
+				sc->nr_reclaimed +=
+					reclaim_state->reclaimed_slab;
+				reclaim_state->reclaimed_slab = 0;
+			}
 		}
 
 		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
