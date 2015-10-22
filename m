Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9C96582F65
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 00:22:13 -0400 (EDT)
Received: by wikq8 with SMTP id q8so12983542wik.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:22:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lg10si15970101wjb.109.2015.10.21.21.22.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 21:22:12 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 6/8] mm: vmscan: simplify memcg vs. global shrinker invocation
Date: Thu, 22 Oct 2015 00:21:34 -0400
Message-Id: <1445487696-21545-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Letting shrink_slab() handle the root_mem_cgroup, and implicitely the
!CONFIG_MEMCG case, allows shrink_zone() to invoke the shrinkers
unconditionally from within the memcg iteration loop.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  2 ++
 mm/vmscan.c                | 31 ++++++++++++++++---------------
 2 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6f1e0f8..d66ae18 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -482,6 +482,8 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
+#define root_mem_cgroup NULL
+
 static inline void mem_cgroup_events(struct mem_cgroup *memcg,
 				     enum mem_cgroup_events_index idx,
 				     unsigned int nr)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9b52ecf..ecc2125 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -411,6 +411,10 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
+	/* Global shrinker mode */
+	if (memcg == root_mem_cgroup)
+		memcg = NULL;
+
 	if (memcg && !memcg_kmem_is_active(memcg))
 		return 0;
 
@@ -2417,11 +2421,22 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
 			zone_lru_pages += lru_pages;
 
-			if (memcg && is_classzone)
+			/*
+			 * Shrink the slab caches in the same proportion that
+			 * the eligible LRU pages were scanned.
+			 */
+			if (is_classzone) {
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
@@ -2439,20 +2454,6 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			}
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
-		/*
-		 * Shrink the slab caches in the same proportion that
-		 * the eligible LRU pages were scanned.
-		 */
-		if (global_reclaim(sc) && is_classzone)
-			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
-				    sc->nr_scanned - nr_scanned,
-				    zone_lru_pages);
-
-		if (reclaim_state) {
-			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
-		}
-
 		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
 			   sc->nr_scanned - nr_scanned,
 			   sc->nr_reclaimed - nr_reclaimed);
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
