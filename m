Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id EEFDB8309E
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 12:28:05 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id uo6so62372712pac.1
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 09:28:05 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rf10si11387183pab.213.2016.02.07.09.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 09:28:05 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 5/5] mm: workingset: make shadow node shrinker memcg aware
Date: Sun, 7 Feb 2016 20:27:35 +0300
Message-ID: <934ce4e1cfe42b57e8114c72a447656fe5a01267.1454864628.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1454864628.git.vdavydov@virtuozzo.com>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Workingset code was recently made memcg aware, but shadow node shrinker
is still global. As a result, one small cgroup can consume all memory
available for shadow nodes, possibly hurting other cgroups by reclaiming
their shadow nodes, even though reclaim distances stored in its shadow
nodes have no effect. To avoid this, we need to make shadow node
shrinker memcg aware.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/memcontrol.h | 10 ++++++++++
 mm/memcontrol.c            |  5 ++---
 mm/workingset.c            | 11 ++++++++---
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bc8e4e22f58f..1191d79aa495 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -403,6 +403,9 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 		int nr_pages);
 
+unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+					   int nid, unsigned int lru_mask);
+
 static inline
 unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 {
@@ -661,6 +664,13 @@ mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 {
 }
 
+static inline unsigned long
+mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+			     int nid, unsigned int lru_mask)
+{
+	return 0;
+}
+
 static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 341bf86d26c2..ae8b81c55685 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -638,9 +638,8 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
 }
 
-static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
-						  int nid,
-						  unsigned int lru_mask)
+unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+					   int nid, unsigned int lru_mask)
 {
 	unsigned long nr = 0;
 	int zid;
diff --git a/mm/workingset.c b/mm/workingset.c
index 6130ba0b2641..8c07cd8af15e 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -349,7 +349,12 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
 	local_irq_enable();
 
-	pages = node_present_pages(sc->nid);
+	if (memcg_kmem_enabled())
+		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
+						     BIT(LRU_ACTIVE_FILE));
+	else
+		pages = node_page_state(sc->nid, NR_ACTIVE_FILE);
+
 	/*
 	 * Active cache pages are limited to 50% of memory, and shadow
 	 * entries that represent a refault distance bigger than that
@@ -364,7 +369,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	 *
 	 * PAGE_SIZE / radix_tree_nodes / node_entries / PAGE_SIZE
 	 */
-	max_nodes = pages >> (1 + RADIX_TREE_MAP_SHIFT - 3);
+	max_nodes = pages >> (RADIX_TREE_MAP_SHIFT - 3);
 
 	if (shadow_nodes <= max_nodes)
 		return 0;
@@ -458,7 +463,7 @@ static struct shrinker workingset_shadow_shrinker = {
 	.count_objects = count_shadow_nodes,
 	.scan_objects = scan_shadow_nodes,
 	.seeks = DEFAULT_SEEKS,
-	.flags = SHRINKER_NUMA_AWARE,
+	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE,
 };
 
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
