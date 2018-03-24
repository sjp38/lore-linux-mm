Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA936B0025
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 12:09:40 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id j8so5907415ywa.0
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 09:09:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6-v6sor4281526ybj.55.2018.03.24.09.09.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 09:09:39 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/3] mm: memcontrol: Remove lruvec_stat
Date: Sat, 24 Mar 2018 09:09:01 -0700
Message-Id: <20180324160901.512135-4-tj@kernel.org>
In-Reply-To: <20180324160901.512135-1-tj@kernel.org>
References: <20180324160901.512135-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

lruvec_stat doesn't have any consumer.  Remove it.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memcontrol.h | 40 ----------------------------------------
 mm/memcontrol.c            | 36 ++----------------------------------
 2 files changed, 2 insertions(+), 74 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0cf6d5a..85a8f00 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -103,19 +103,12 @@ struct mem_cgroup_reclaim_iter {
 	unsigned int generation;
 };
 
-struct lruvec_stat {
-	long count[NR_VM_NODE_STAT_ITEMS];
-};
-
 /*
  * per-zone information in memory controller.
  */
 struct mem_cgroup_per_node {
 	struct lruvec		lruvec;
 
-	struct lruvec_stat __percpu *lruvec_stat_cpu;
-	atomic_long_t		lruvec_stat[NR_VM_NODE_STAT_ITEMS];
-
 	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
 
 	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
@@ -602,29 +595,10 @@ static inline void mod_memcg_page_state(struct page *page,
 		mod_memcg_state(page->mem_cgroup, idx, val);
 }
 
-static inline unsigned long lruvec_page_state(struct lruvec *lruvec,
-					      enum node_stat_item idx)
-{
-	struct mem_cgroup_per_node *pn;
-	long x;
-
-	if (mem_cgroup_disabled())
-		return node_page_state(lruvec_pgdat(lruvec), idx);
-
-	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
-	x = atomic_long_read(&pn->lruvec_stat[idx]);
-#ifdef CONFIG_SMP
-	if (x < 0)
-		x = 0;
-#endif
-	return x;
-}
-
 static inline void __mod_lruvec_state(struct lruvec *lruvec,
 				      enum node_stat_item idx, int val)
 {
 	struct mem_cgroup_per_node *pn;
-	long x;
 
 	/* Update node */
 	__mod_node_page_state(lruvec_pgdat(lruvec), idx, val);
@@ -636,14 +610,6 @@ static inline void __mod_lruvec_state(struct lruvec *lruvec,
 
 	/* Update memcg */
 	__mod_memcg_state(pn->memcg, idx, val);
-
-	/* Update lruvec */
-	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
-	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &pn->lruvec_stat[idx]);
-		x = 0;
-	}
-	__this_cpu_write(pn->lruvec_stat_cpu->count[idx], x);
 }
 
 static inline void mod_lruvec_state(struct lruvec *lruvec,
@@ -967,12 +933,6 @@ static inline void mod_memcg_page_state(struct page *page,
 {
 }
 
-static inline unsigned long lruvec_page_state(struct lruvec *lruvec,
-					      enum node_stat_item idx)
-{
-	return node_page_state(lruvec_pgdat(lruvec), idx);
-}
-
 static inline void __mod_lruvec_state(struct lruvec *lruvec,
 				      enum node_stat_item idx, int val)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 03d1b30..d5bf01d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1815,30 +1815,7 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
 
 static int memcg_hotplug_cpu_dead(unsigned int cpu)
 {
-	struct memcg_stock_pcp *stock;
-	struct mem_cgroup *memcg;
-
-	stock = &per_cpu(memcg_stock, cpu);
-	drain_stock(stock);
-
-	for_each_mem_cgroup(memcg) {
-		int i;
-
-		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
-			int nid;
-			long x;
-
-			for_each_node(nid) {
-				struct mem_cgroup_per_node *pn;
-
-				pn = mem_cgroup_nodeinfo(memcg, nid);
-				x = this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
-				if (x)
-					atomic_long_add(x, &pn->lruvec_stat[i]);
-			}
-		}
-	}
-
+	drain_stock(&per_cpu(memcg_stock, cpu));
 	return 0;
 }
 
@@ -4056,12 +4033,6 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return 1;
 
-	pn->lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
-	if (!pn->lruvec_stat_cpu) {
-		kfree(pn);
-		return 1;
-	}
-
 	lruvec_init(&pn->lruvec);
 	pn->usage_in_excess = 0;
 	pn->on_tree = false;
@@ -4073,10 +4044,7 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 
 static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 {
-	struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
-
-	free_percpu(pn->lruvec_stat_cpu);
-	kfree(pn);
+	kfree(memcg->nodeinfo[node]);
 }
 
 static void __mem_cgroup_free(struct mem_cgroup *memcg)
-- 
2.9.5
