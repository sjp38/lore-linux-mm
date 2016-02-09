Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7230E6B0257
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 08:56:30 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id hb3so77750811igb.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 05:56:30 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id v19si4960442igd.92.2016.02.09.05.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 05:56:29 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 6/6] mm: workingset: make shadow node shrinker memcg aware
Date: Tue, 9 Feb 2016 16:55:54 +0300
Message-ID: <958fc0b9f99f5cabbc3c1f6133a615239d9c05ff.1455025246.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1455025246.git.vdavydov@virtuozzo.com>
References: <cover.1455025246.git.vdavydov@virtuozzo.com>
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
 mm/workingset.c            | 10 +++++++---
 3 files changed, 19 insertions(+), 6 deletions(-)

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
index 68e8cd94ebe4..8a75f8d2916a 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -349,8 +349,12 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
 	local_irq_enable();
 
-	pages = node_page_state(sc->nid, NR_ACTIVE_FILE) +
-		node_page_state(sc->nid, NR_INACTIVE_FILE);
+	if (memcg_kmem_enabled())
+		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
+						     LRU_ALL_FILE);
+	else
+		pages = node_page_state(sc->nid, NR_ACTIVE_FILE) +
+			node_page_state(sc->nid, NR_INACTIVE_FILE);
 
 	/*
 	 * Active cache pages are limited to 50% of memory, and shadow
@@ -460,7 +464,7 @@ static struct shrinker workingset_shadow_shrinker = {
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
