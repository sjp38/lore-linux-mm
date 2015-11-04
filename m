Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 54BEC82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 17:22:37 -0500 (EST)
Received: by wmnn186 with SMTP id n186so3679681wmn.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:22:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q141si6203273wmg.85.2015.11.04.14.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 14:22:36 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/8] mm: vmscan: simplify memcg vs. global shrinker invocation
Date: Wed,  4 Nov 2015 17:22:08 -0500
Message-Id: <1446675734-25671-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
References: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Letting shrink_slab() handle the root_mem_cgroup, and implicitely the
!CONFIG_MEMCG case, allows shrink_zone() to invoke the shrinkers
unconditionally from within the memcg iteration loop.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/memcontrol.h |  2 ++
 mm/vmscan.c                | 31 ++++++++++++++++---------------
 2 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 19ff87b..8929685 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -502,6 +502,8 @@ void mem_cgroup_split_huge_fixup(struct page *head);
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
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
