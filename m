Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 777636B0009
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:53:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j18so3886154pgv.18
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:53:58 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0099.outbound.protection.outlook.com. [104.47.0.99])
        by mx.google.com with ESMTPS id g1-v6si14460344pld.549.2018.04.17.08.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:53:56 -0700 (PDT)
Subject: [PATCH v2 04/12] mm: Assign memcg-aware shrinkers bitmap to memcg
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 17 Apr 2018 21:53:31 +0300
Message-ID: <152399121146.3456.5459546288565589098.stgit@localhost.localdomain>
In-Reply-To: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Imagine a big node with many cpus, memory cgroups and containers.
Let we have 200 containers, every container has 10 mounts,
and 10 cgroups. All container tasks don't touch foreign
containers mounts. If there is intensive pages write,
and global reclaim happens, a writing task has to iterate
over all memcgs to shrink slab, before it's able to go
to shrink_page_list().

Iteration over all the memcg slabs is very expensive:
the task has to visit 200 * 10 = 2000 shrinkers
for every memcg, and since there are 2000 memcgs,
the total calls are 2000 * 2000 = 4000000.

So, the shrinker makes 4 million do_shrink_slab() calls
just to try to isolate SWAP_CLUSTER_MAX pages in one
of the actively writing memcg via shrink_page_list().
I've observed a node spending almost 100% in kernel,
making useless iteration over already shrinked slab.

This patch adds bitmap of memcg-aware shrinkers to memcg.
The size of the bitmap depends on bitmap_nr_ids, and during
memcg life it's maintained to be enough to fit bitmap_nr_ids
shrinkers. Every bit in the map is related to corresponding
shrinker id.

Next patches will maintain set bit only for really charged
memcg. This will allow shrink_slab() to increase its
performance in significant way. See the last patch for
the numbers.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/memcontrol.h |   15 +++++
 mm/memcontrol.c            |  125 ++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |   21 +++++++
 3 files changed, 160 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index af9eed2e3e04..2ec96ab46b01 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -115,6 +115,7 @@ struct mem_cgroup_per_node {
 	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
 
 	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
+	struct memcg_shrinker_map __rcu	*shrinkers_map;
 
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long		usage_in_excess;/* Set to the value by which */
@@ -153,6 +154,11 @@ struct mem_cgroup_thresholds {
 	struct mem_cgroup_threshold_ary *spare;
 };
 
+struct memcg_shrinker_map {
+	struct rcu_head rcu;
+	unsigned long map[0];
+};
+
 enum memcg_kmem_state {
 	KMEM_NONE,
 	KMEM_ALLOCATED,
@@ -1200,6 +1206,8 @@ extern int memcg_nr_cache_ids;
 void memcg_get_cache_ids(void);
 void memcg_put_cache_ids(void);
 
+extern int shrinkers_max_nr;
+
 /*
  * Helper macro to loop through all memcg-specific caches. Callers must still
  * check if the cache is valid (it is either valid or NULL).
@@ -1223,6 +1231,13 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
+extern struct memcg_shrinker_map __rcu *root_shrinkers_map[];
+#define SHRINKERS_MAP(memcg, nid)					\
+	(memcg == root_mem_cgroup || !memcg ?				\
+	 root_shrinkers_map[nid] : memcg->nodeinfo[nid]->shrinkers_map)
+
+extern int expand_shrinker_maps(int old_id, int id);
+
 #else
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2959a454a072..562dfb1be9ef 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -305,6 +305,113 @@ EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
 struct workqueue_struct *memcg_kmem_cache_wq;
 
+static DECLARE_RWSEM(shrinkers_max_nr_rwsem);
+struct memcg_shrinker_map __rcu *root_shrinkers_map[MAX_NUMNODES] = { 0 };
+
+static void get_shrinkers_max_nr(void)
+{
+	down_read(&shrinkers_max_nr_rwsem);
+}
+
+static void put_shrinkers_max_nr(void)
+{
+	up_read(&shrinkers_max_nr_rwsem);
+}
+
+static void kvfree_map_rcu(struct rcu_head *head)
+{
+	kvfree(container_of(head, struct memcg_shrinker_map, rcu));
+}
+
+static int memcg_expand_maps(struct mem_cgroup *memcg, int nid,
+			     int size, int old_size)
+{
+	struct memcg_shrinker_map *new, *old;
+
+	lockdep_assert_held(&shrinkers_max_nr_rwsem);
+
+	new = kvmalloc(sizeof(*new) + size, GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+
+	/* Set all old bits, clear all new bits */
+	memset(new->map, (int)0xff, old_size);
+	memset((void *)new->map + old_size, 0, size - old_size);
+
+	old = rcu_dereference_protected(SHRINKERS_MAP(memcg, nid), true);
+
+	if (memcg)
+		rcu_assign_pointer(memcg->nodeinfo[nid]->shrinkers_map, new);
+	else
+		rcu_assign_pointer(root_shrinkers_map[nid], new);
+
+	if (old)
+		call_rcu(&old->rcu, kvfree_map_rcu);
+
+	return 0;
+}
+
+static int alloc_shrinker_maps(struct mem_cgroup *memcg, int nid)
+{
+	/* Skip allocation, when we're initializing root_mem_cgroup */
+	if (!root_mem_cgroup)
+		return 0;
+
+	return memcg_expand_maps(memcg, nid, shrinkers_max_nr/BITS_PER_BYTE, 0);
+}
+
+static void free_shrinker_maps(struct mem_cgroup *memcg,
+			       struct mem_cgroup_per_node *pn)
+{
+	struct memcg_shrinker_map *map;
+
+	if (memcg == root_mem_cgroup)
+		return;
+
+	/* IDR unhashed long ago, and expand_shrinker_maps can't race with us */
+	map = rcu_dereference_protected(pn->shrinkers_map, true);
+	kvfree_map_rcu(&map->rcu);
+}
+
+static struct idr mem_cgroup_idr;
+
+int expand_shrinker_maps(int old_nr, int nr)
+{
+	int id, size, old_size, node, ret;
+	struct mem_cgroup *memcg;
+
+	old_size = old_nr / BITS_PER_BYTE;
+	size = nr / BITS_PER_BYTE;
+
+	down_write(&shrinkers_max_nr_rwsem);
+	for_each_node(node) {
+		idr_for_each_entry(&mem_cgroup_idr, memcg, id) {
+			if (id == 1)
+				memcg = NULL;
+			ret = memcg_expand_maps(memcg, node, size, old_size);
+			if (ret)
+				goto unlock;
+		}
+
+		/* root_mem_cgroup is not initialized yet */
+		if (id == 0)
+			ret = memcg_expand_maps(NULL, node, size, old_size);
+	}
+unlock:
+	up_write(&shrinkers_max_nr_rwsem);
+	return ret;
+}
+#else /* CONFIG_SLOB */
+static void get_shrinkers_max_nr(void) { }
+static void put_shrinkers_max_nr(void) { }
+
+static int alloc_shrinker_maps(struct mem_cgroup *memcg, int nid)
+{
+	return 0;
+}
+static void free_shrinker_maps(struct mem_cgroup *memcg,
+			       struct mem_cgroup_per_node *pn) { }
+
 #endif /* !CONFIG_SLOB */
 
 /**
@@ -3002,6 +3109,8 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 }
 
 #ifndef CONFIG_SLOB
+int shrinkers_max_nr;
+
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
 	int memcg_id;
@@ -4266,7 +4375,10 @@ static DEFINE_IDR(mem_cgroup_idr);
 static void mem_cgroup_id_remove(struct mem_cgroup *memcg)
 {
 	if (memcg->id.id > 0) {
+		/* Removing IDR must be visible for expand_shrinker_maps() */
+		get_shrinkers_max_nr();
 		idr_remove(&mem_cgroup_idr, memcg->id.id);
+		put_shrinkers_max_nr();
 		memcg->id.id = 0;
 	}
 }
@@ -4333,12 +4445,17 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn->lruvec_stat_cpu)
 		goto err_pcpu;
 
+	if (alloc_shrinker_maps(memcg, node))
+		goto err_maps;
+
 	lruvec_init(&pn->lruvec);
 	pn->usage_in_excess = 0;
 	pn->on_tree = false;
 	pn->memcg = memcg;
 	return 0;
 
+err_maps:
+	free_percpu(pn->lruvec_stat_cpu);
 err_pcpu:
 	memcg->nodeinfo[node] = NULL;
 	kfree(pn);
@@ -4352,6 +4469,7 @@ static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return;
 
+	free_shrinker_maps(memcg, pn);
 	free_percpu(pn->lruvec_stat_cpu);
 	kfree(pn);
 }
@@ -4407,13 +4525,18 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+
+	get_shrinkers_max_nr();
 	for_each_node(node)
-		if (alloc_mem_cgroup_per_node_info(memcg, node))
+		if (alloc_mem_cgroup_per_node_info(memcg, node)) {
+			put_shrinkers_max_nr();
 			goto fail;
+		}
 
 	memcg->id.id = idr_alloc(&mem_cgroup_idr, memcg,
 				 1, MEM_CGROUP_ID_MAX,
 				 GFP_KERNEL);
+	put_shrinkers_max_nr();
 	if (memcg->id.id < 0)
 		goto fail;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4f02fe83537e..f63eb5596c35 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -172,6 +172,22 @@ static DECLARE_RWSEM(shrinker_rwsem);
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 static DEFINE_IDR(shrinkers_id_idr);
 
+static int expand_shrinker_id(int id)
+{
+	if (likely(id < shrinkers_max_nr))
+		return 0;
+
+	id = shrinkers_max_nr * 2;
+	if (id == 0)
+		id = BITS_PER_BYTE;
+
+	if (expand_shrinker_maps(shrinkers_max_nr, id))
+		return -ENOMEM;
+
+	shrinkers_max_nr = id;
+	return 0;
+}
+
 static int add_memcg_shrinker(struct shrinker *shrinker)
 {
 	int id, ret;
@@ -180,6 +196,11 @@ static int add_memcg_shrinker(struct shrinker *shrinker)
 	ret = id = idr_alloc(&shrinkers_id_idr, shrinker, 0, 0, GFP_KERNEL);
 	if (ret < 0)
 		goto unlock;
+	ret = expand_shrinker_id(id);
+	if (ret < 0) {
+		idr_remove(&shrinkers_id_idr, id);
+		goto unlock;
+	}
 	shrinker->id = id;
 	ret = 0;
 unlock:
