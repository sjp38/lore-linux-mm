Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 647486B0009
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:12:46 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id y131-v6so11299873itc.5
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:12:46 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0098.outbound.protection.outlook.com. [104.47.1.98])
        by mx.google.com with ESMTPS id r20-v6si9058450itb.97.2018.04.24.05.12.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 05:12:45 -0700 (PDT)
Subject: [PATCH v3 04/14] mm: Assign memcg-aware shrinkers bitmap to memcg
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 24 Apr 2018 15:12:30 +0300
Message-ID: <152457195067.22533.15993784850619081817.stgit@localhost.localdomain>
In-Reply-To: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
References: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

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
 include/linux/memcontrol.h |   16 ++++++
 mm/memcontrol.c            |  118 ++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |   16 ++++++
 3 files changed, 148 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ab60ff55bdb3..44c5da330c0f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -105,6 +105,15 @@ struct lruvec_stat {
 	long count[NR_VM_NODE_STAT_ITEMS];
 };
 
+/*
+ * Bitmap of shrinker::id corresponding to memcg-aware shrinkers,
+ * which have elements charged to this memcg.
+ */
+struct memcg_shrinker_map {
+	struct rcu_head rcu;
+	unsigned long map[0];
+};
+
 /*
  * per-zone information in memory controller.
  */
@@ -117,6 +126,7 @@ struct mem_cgroup_per_node {
 	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
 
 	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
+	struct memcg_shrinker_map __rcu	*shrinker_map;
 
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long		usage_in_excess;/* Set to the value by which */
@@ -1204,6 +1214,8 @@ extern int memcg_nr_cache_ids;
 void memcg_get_cache_ids(void);
 void memcg_put_cache_ids(void);
 
+extern int memcg_shrinker_nr_max;
+
 /*
  * Helper macro to loop through all memcg-specific caches. Callers must still
  * check if the cache is valid (it is either valid or NULL).
@@ -1227,6 +1239,10 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
+#define MEMCG_SHRINKER_MAP(memcg, nid) (memcg->nodeinfo[nid]->shrinker_map)
+
+extern int memcg_expand_shrinker_maps(int old_id, int id);
+
 #else
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 38523c8ea7c9..76fe156066ce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -305,6 +305,108 @@ EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
 struct workqueue_struct *memcg_kmem_cache_wq;
 
+int memcg_shrinker_nr_max;
+static DEFINE_MUTEX(shrinkers_nr_max_mutex);
+
+static void lock_shrinkers_max_nr(void)
+{
+	mutex_lock(&shrinkers_nr_max_mutex);
+}
+
+static void unlock_shrinkers_max_nr(void)
+{
+	mutex_unlock(&shrinkers_nr_max_mutex);
+}
+
+static void memcg_free_shrinker_map_rcu(struct rcu_head *head)
+{
+	kvfree(container_of(head, struct memcg_shrinker_map, rcu));
+}
+
+static int memcg_expand_one_shrinker_map(struct mem_cgroup *memcg, int nid,
+					 int size, int old_size)
+{
+	struct memcg_shrinker_map *new, *old;
+
+	lockdep_assert_held(&shrinkers_nr_max_mutex);
+
+	new = kvmalloc(sizeof(*new) + size, GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+
+	/* Set all old bits, clear all new bits */
+	memset(new->map, (int)0xff, old_size);
+	memset((void *)new->map + old_size, 0, size - old_size);
+
+	old = rcu_dereference_protected(MEMCG_SHRINKER_MAP(memcg, nid), true);
+	rcu_assign_pointer(memcg->nodeinfo[nid]->shrinker_map, new);
+	if (old)
+		call_rcu(&old->rcu, memcg_free_shrinker_map_rcu);
+
+	return 0;
+}
+
+static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg, int nid)
+{
+	int size = memcg_shrinker_nr_max/BITS_PER_BYTE;
+
+	/* Skip allocation, when we're initializing root_mem_cgroup */
+	if (!root_mem_cgroup)
+		return 0;
+
+	return memcg_expand_one_shrinker_map(memcg, nid, size, 0);
+}
+
+static void memcg_free_shrinker_maps(struct mem_cgroup *memcg,
+				     struct mem_cgroup_per_node *pn)
+{
+	struct memcg_shrinker_map *map;
+
+	if (memcg == root_mem_cgroup)
+		return;
+
+	/* IDR unhashed long ago, and memcg_expand_shrinker_maps can't race with us */
+	map = rcu_dereference_protected(pn->shrinker_map, true);
+	memcg_free_shrinker_map_rcu(&map->rcu);
+}
+
+static struct idr mem_cgroup_idr;
+
+int memcg_expand_shrinker_maps(int old_nr, int nr)
+{
+	int id, size, old_size, node, ret = 0;
+	struct mem_cgroup *memcg;
+
+	old_size = old_nr / BITS_PER_BYTE;
+	size = nr / BITS_PER_BYTE;
+
+	lock_shrinkers_max_nr();
+	for_each_node(node) {
+		idr_for_each_entry(&mem_cgroup_idr, memcg, id) {
+			/* Skip root_mem_cgroup */
+			if (id == 1)
+				continue;
+			ret = memcg_expand_one_shrinker_map(memcg, node,
+							    size, old_size);
+			if (ret)
+				goto unlock;
+		}
+	}
+unlock:
+	unlock_shrinkers_max_nr();
+	return ret;
+}
+#else /* CONFIG_SLOB */
+static void lock_shrinkers_max_nr(void) { }
+static void unlock_shrinkers_max_nr(void) { }
+
+static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg, int nid)
+{
+	return 0;
+}
+static void memcg_free_shrinker_maps(struct mem_cgroup *memcg,
+				     struct mem_cgroup_per_node *pn) { }
+
 #endif /* !CONFIG_SLOB */
 
 /**
@@ -4265,7 +4367,10 @@ static DEFINE_IDR(mem_cgroup_idr);
 static void mem_cgroup_id_remove(struct mem_cgroup *memcg)
 {
 	if (memcg->id.id > 0) {
+		/* Removing IDR must be visible for memcg_expand_shrinker_maps() */
+		lock_shrinkers_max_nr();
 		idr_remove(&mem_cgroup_idr, memcg->id.id);
+		unlock_shrinkers_max_nr();
 		memcg->id.id = 0;
 	}
 }
@@ -4332,12 +4437,17 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn->lruvec_stat_cpu)
 		goto err_pcpu;
 
+	if (memcg_alloc_shrinker_maps(memcg, node))
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
@@ -4351,6 +4461,7 @@ static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return;
 
+	memcg_free_shrinker_maps(memcg, pn);
 	free_percpu(pn->lruvec_stat_cpu);
 	kfree(pn);
 }
@@ -4406,13 +4517,18 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+
+	lock_shrinkers_max_nr();
 	for_each_node(node)
-		if (alloc_mem_cgroup_per_node_info(memcg, node))
+		if (alloc_mem_cgroup_per_node_info(memcg, node)) {
+			unlock_shrinkers_max_nr();
 			goto fail;
+		}
 
 	memcg->id.id = idr_alloc(&mem_cgroup_idr, memcg,
 				 1, MEM_CGROUP_ID_MAX,
 				 GFP_KERNEL);
+	unlock_shrinkers_max_nr();
 	if (memcg->id.id < 0)
 		goto fail;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6c986c07dd75..5f30e33faed2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -174,12 +174,26 @@ static DEFINE_IDR(shrinker_idr);
 
 static int prealloc_memcg_shrinker(struct shrinker *shrinker)
 {
-	int id, ret;
+	int id, nr, ret;
 
 	down_write(&shrinker_rwsem);
 	ret = id = idr_alloc(&shrinker_idr, shrinker, 0, 0, GFP_KERNEL);
 	if (ret < 0)
 		goto unlock;
+
+	if (id >= memcg_shrinker_nr_max) {
+		nr = memcg_shrinker_nr_max * 2;
+		if (nr == 0)
+			nr = BITS_PER_BYTE;
+		BUG_ON(id >= nr);
+
+		if (memcg_expand_shrinker_maps(memcg_shrinker_nr_max, nr)) {
+			idr_remove(&shrinker_idr, id);
+			goto unlock;
+		}
+		memcg_shrinker_nr_max = nr;
+	}
+
 	shrinker->id = id;
 	ret = 0;
 unlock:
