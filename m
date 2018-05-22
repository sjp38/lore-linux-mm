Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE8896B0276
	for <linux-mm@kvack.org>; Tue, 22 May 2018 06:09:59 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n33-v6so17498909qte.23
        for <linux-mm@kvack.org>; Tue, 22 May 2018 03:09:59 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30119.outbound.protection.outlook.com. [40.107.3.119])
        by mx.google.com with ESMTPS id i1-v6si6567409qvf.174.2018.05.22.03.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 03:09:59 -0700 (PDT)
Subject: [PATCH v7 15/17] mm: Generalize shrink_slab() calls in shrink_node()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 22 May 2018 13:09:53 +0300
Message-ID: <152698379298.3393.3040399931339145602.stgit@localhost.localdomain>
In-Reply-To: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
References: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

From: Vladimir Davydov <vdavydov.dev@gmail.com>

The patch makes shrink_slab() be called for root_mem_cgroup
in the same way as it's called for the rest of cgroups.
This simplifies the logic and improves the readability.

Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
ktkhai: Description written.
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f26ca1e00efb..6dbc659db120 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -628,10 +628,8 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
  * @nid is passed along to shrinkers with SHRINKER_NUMA_AWARE set,
  * unaware shrinkers will receive a node id of 0 instead.
  *
- * @memcg specifies the memory cgroup to target. If it is not NULL,
- * only shrinkers with SHRINKER_MEMCG_AWARE set will be called to scan
- * objects from the memory cgroup specified. Otherwise, only unaware
- * shrinkers are called.
+ * @memcg specifies the memory cgroup to target. Unaware shrinkers
+ * are called only if it is the root cgroup.
  *
  * @priority is sc->priority, we take the number of objects and >> by priority
  * in order to get the scan target.
@@ -645,7 +643,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
-	if (memcg && !mem_cgroup_is_root(memcg))
+	if (!mem_cgroup_is_root(memcg))
 		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
 
 	if (!down_read_trylock(&shrinker_rwsem))
@@ -658,9 +656,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 			.memcg = memcg,
 		};
 
-		if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
-			continue;
-
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
@@ -690,6 +685,7 @@ void drop_slab_node(int nid)
 		struct mem_cgroup *memcg = NULL;
 
 		freed = 0;
+		memcg = mem_cgroup_iter(NULL, NULL, NULL);
 		do {
 			freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
@@ -2709,9 +2705,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
-			if (memcg)
-				shrink_slab(sc->gfp_mask, pgdat->node_id,
-					    memcg, sc->priority);
+			shrink_slab(sc->gfp_mask, pgdat->node_id,
+				    memcg, sc->priority);
 
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
@@ -2735,10 +2730,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			}
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
-		if (global_reclaim(sc))
-			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
-				    sc->priority);
-
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
