Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3650D6B0078
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:20:12 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id ep20so8054569lab.20
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:20:11 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id p10si19805051lag.136.2013.12.02.03.20.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:20:10 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 13/18] memcg: per-memcg kmem shrinking
Date: Mon, 2 Dec 2013 15:19:48 +0400
Message-ID: <6a255c838dd290844d6ea437612e9671a88e6f31.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
References: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

If a memory cgroup's kmem limit is less than its user memory limit, we
can run into a situation where our allocation fail, but freeing user
pages will buy us nothing. In such scenarios we would like to call a
specialized reclaimer that only frees kernel memory. This patch adds it.
All the magic lies behind the previous patches that made slab shrinkers
memcg-aware, this patch only employs the shrink_slab() facility to scan
slab objects accounted to a specific memory cgroup, however, there is
one thing that is worth noticing.

The point is that since all memcg-aware shrinkers are FS-dependent, we
have no option rather than failing all GFP_NOFS allocations when we are
close to the kmem limit. The best thing we can do in such a situation is
to spawn the reclaimer in a background process hoping next allocations
will succeed.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    2 ++
 mm/memcontrol.c      |   51 +++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c          |   38 ++++++++++++++++++++++++++++++++++++-
 3 files changed, 89 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 46ba0c6..367a773 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -309,6 +309,8 @@ extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap);
+extern unsigned long try_to_free_mem_cgroup_kmem(struct mem_cgroup *mem,
+						 gfp_t gfp_mask);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index da06f91..3679acb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -323,6 +323,8 @@ struct mem_cgroup {
 	struct mutex slab_caches_mutex;
         /* Index in the kmem_cache->memcg_params->memcg_caches array */
 	int kmemcg_id;
+	/* when kmem shrinkers cannot proceed due to context */
+	struct work_struct kmem_shrink_work;
 #endif
 
 	int last_scanned_node;
@@ -3431,13 +3433,57 @@ static int mem_cgroup_slabinfo_read(struct cgroup_subsys_state *css,
 }
 #endif
 
+static void kmem_shrink_work_func(struct work_struct *w)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = container_of(w, struct mem_cgroup, kmem_shrink_work);
+	try_to_free_mem_cgroup_kmem(memcg, GFP_KERNEL);
+}
+
+static int memcg_try_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
+{
+	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct mem_cgroup *mem_over_limit;
+	struct res_counter *fail_res;
+	int ret;
+
+	do {
+		ret = res_counter_charge(&memcg->kmem, size, &fail_res);
+		if (!ret)
+			break;
+
+		mem_over_limit = mem_cgroup_from_res_counter(fail_res, kmem);
+
+		/*
+		 * Now we are going to shrink kernel memory present in caches.
+		 * If we cannot wait, we will have no option rather than fail
+		 * the current allocation and make room in the background
+		 * hoping the next one will succeed.
+		 *
+		 * If we are in FS context, then although we can wait, we
+		 * cannot call the shrinkers, because most FS shrinkers will
+		 * not run without __GFP_FS to avoid deadlock.
+		 */
+		if (!(gfp & __GFP_WAIT) || !(gfp & __GFP_FS)) {
+			schedule_work(&mem_over_limit->kmem_shrink_work);
+			break;
+		}
+
+		if (!try_to_free_mem_cgroup_kmem(mem_over_limit, gfp))
+			break;
+	} while (--nr_retries > 0);
+
+	return ret;
+}
+
 static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 {
 	struct res_counter *fail_res;
 	struct mem_cgroup *_memcg;
 	int ret = 0;
 
-	ret = res_counter_charge(&memcg->kmem, size, &fail_res);
+	ret = memcg_try_charge_kmem(memcg, gfp, size);
 	if (ret)
 		return ret;
 
@@ -6289,6 +6335,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	int ret;
 
 	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
+	INIT_WORK(&memcg->kmem_shrink_work, kmem_shrink_work_func);
 	mutex_init(&memcg->slab_caches_mutex);
 	memcg->kmemcg_id = -1;
 	ret = memcg_propagate_kmem(memcg);
@@ -6309,6 +6356,8 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 	if (!memcg_kmem_is_active(memcg))
 		return;
 
+	cancel_work_sync(&memcg->kmem_shrink_work);
+
 	/*
 	 * kmem charges can outlive the cgroup. In the case of slab
 	 * pages, for instance, a page contain objects from various
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 04df967..10e6b2f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2729,7 +2729,43 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	return nr_reclaimed;
 }
-#endif
+
+#ifdef CONFIG_MEMCG_KMEM
+unsigned long try_to_free_mem_cgroup_kmem(struct mem_cgroup *memcg,
+					  gfp_t gfp_mask)
+{
+	struct reclaim_state reclaim_state;
+	struct shrink_control shrink = {
+		.gfp_mask = gfp_mask,
+		.target_mem_cgroup = memcg,
+	};
+	int priority = DEF_PRIORITY;
+	unsigned long nr_to_reclaim = SWAP_CLUSTER_MAX;
+	unsigned long freed, total_freed = 0;
+
+	nodes_setall(shrink.nodes_to_scan);
+
+	lockdep_set_current_reclaim_state(sc.gfp_mask);
+	reclaim_state.reclaimed_slab = 0;
+	current->reclaim_state = &reclaim_state;
+
+	do {
+		freed = shrink_slab(&shrink, 1000, 1000 << priority);
+		if (!freed)
+			congestion_wait(BLK_RW_ASYNC, HZ/10);
+		total_freed += freed;
+		if (current->reclaim_state->reclaimed_slab >= nr_to_reclaim)
+			break;
+	} while (--priority >= 0);
+
+	current->reclaim_state = NULL;
+	lockdep_clear_current_reclaim_state();
+
+	return total_freed;
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
+#endif /* CONFIG_MEMCG */
 
 static void age_active_anon(struct zone *zone, struct scan_control *sc)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
