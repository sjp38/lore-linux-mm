Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0C6B6B05DD
	for <linux-mm@kvack.org>; Thu, 10 May 2018 05:52:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q15-v6so905364pff.17
        for <linux-mm@kvack.org>; Thu, 10 May 2018 02:52:51 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0133.outbound.protection.outlook.com. [104.47.2.133])
        by mx.google.com with ESMTPS id e90-v6si414199pfb.355.2018.05.10.02.52.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 May 2018 02:52:50 -0700 (PDT)
Subject: [PATCH v5 03/13] mm: Assign memcg-aware shrinkers bitmap to memcg
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Thu, 10 May 2018 12:52:36 +0300
Message-ID: <152594595644.22949.8473969450800431565.stgit@localhost.localdomain>
In-Reply-To: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
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
 include/linux/memcontrol.h |   21 ++++++++
 mm/memcontrol.c            |  116 ++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |   16 ++++++
 3 files changed, 152 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6cbea2f25a87..e5e7e0fc7158 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -105,6 +105,17 @@ struct lruvec_stat {
 	long count[NR_VM_NODE_STAT_ITEMS];
 };
 
+#ifdef CONFIG_MEMCG_SHRINKER
+/*
+ * Bitmap of shrinker::id corresponding to memcg-aware shrinkers,
+ * which have elements charged to this memcg.
+ */
+struct memcg_shrinker_map {
+	struct rcu_head rcu;
+	unsigned long map[0];
+};
+#endif /* CONFIG_MEMCG_SHRINKER */
+
 /*
  * per-zone information in memory controller.
  */
@@ -118,6 +129,9 @@ struct mem_cgroup_per_node {
 
 	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
 
+#ifdef CONFIG_MEMCG_SHRINKER
+	struct memcg_shrinker_map __rcu	*shrinker_map;
+#endif
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long		usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
@@ -1255,4 +1269,11 @@ static inline void memcg_put_cache_ids(void)
 
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
+#ifdef CONFIG_MEMCG_SHRINKER
+#define MEMCG_SHRINKER_MAP(memcg, nid) (memcg->nodeinfo[nid]->shrinker_map)
+
+extern int memcg_shrinker_nr_max;
+extern int memcg_expand_shrinker_maps(int old_id, int id);
+#endif /* CONFIG_MEMCG_SHRINKER */
+
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3df3efa7ff40..18e0fdf302a9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -322,6 +322,116 @@ struct workqueue_struct *memcg_kmem_cache_wq;
 
 #endif /* !CONFIG_SLOB */
 
+#ifdef CONFIG_MEMCG_SHRINKER
+int memcg_shrinker_nr_max;
+static DEFINE_MUTEX(shrinkers_nr_max_mutex);
+
+static void memcg_free_shrinker_map_rcu(struct rcu_head *head)
+{
+	kvfree(container_of(head, struct memcg_shrinker_map, rcu));
+}
+
+static int memcg_expand_one_shrinker_map(struct mem_cgroup *memcg,
+					 int size, int old_size)
+{
+	struct memcg_shrinker_map *new, *old;
+	int nid;
+
+	lockdep_assert_held(&shrinkers_nr_max_mutex);
+
+	for_each_node(nid) {
+		old = rcu_dereference_protected(MEMCG_SHRINKER_MAP(memcg, nid), true);
+		/* Not yet online memcg */
+		if (old_size && !old)
+			return 0;
+
+		new = kvmalloc(sizeof(*new) + size, GFP_KERNEL);
+		if (!new)
+			return -ENOMEM;
+
+		/* Set all old bits, clear all new bits */
+		memset(new->map, (int)0xff, old_size);
+		memset((void *)new->map + old_size, 0, size - old_size);
+
+		rcu_assign_pointer(memcg->nodeinfo[nid]->shrinker_map, new);
+		if (old)
+			call_rcu(&old->rcu, memcg_free_shrinker_map_rcu);
+	}
+
+	return 0;
+}
+
+static void memcg_free_shrinker_maps(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup_per_node *pn;
+	struct memcg_shrinker_map *map;
+	int nid;
+
+	if (memcg == root_mem_cgroup)
+		return;
+
+	mutex_lock(&shrinkers_nr_max_mutex);
+	for_each_node(nid) {
+		pn = mem_cgroup_nodeinfo(memcg, nid);
+		map = rcu_dereference_protected(pn->shrinker_map, true);
+		if (map)
+			call_rcu(&map->rcu, memcg_free_shrinker_map_rcu);
+		rcu_assign_pointer(pn->shrinker_map, NULL);
+	}
+	mutex_unlock(&shrinkers_nr_max_mutex);
+}
+
+static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg)
+{
+	int ret, size = memcg_shrinker_nr_max/BITS_PER_BYTE;
+
+	if (memcg == root_mem_cgroup)
+		return 0;
+
+	mutex_lock(&shrinkers_nr_max_mutex);
+	ret = memcg_expand_one_shrinker_map(memcg, size, 0);
+	mutex_unlock(&shrinkers_nr_max_mutex);
+
+	if (ret)
+		memcg_free_shrinker_maps(memcg);
+
+	return ret;
+}
+
+static struct idr mem_cgroup_idr;
+
+int memcg_expand_shrinker_maps(int old_nr, int nr)
+{
+	int size, old_size, ret = 0;
+	struct mem_cgroup *memcg;
+
+	old_size = old_nr / BITS_PER_BYTE;
+	size = nr / BITS_PER_BYTE;
+
+	mutex_lock(&shrinkers_nr_max_mutex);
+
+	if (!root_mem_cgroup)
+		goto unlock;
+
+	for_each_mem_cgroup(memcg) {
+		if (memcg == root_mem_cgroup)
+			continue;
+		ret = memcg_expand_one_shrinker_map(memcg, size, old_size);
+		if (ret)
+			goto unlock;
+	}
+unlock:
+	mutex_unlock(&shrinkers_nr_max_mutex);
+	return ret;
+}
+#else /* CONFIG_MEMCG_SHRINKER */
+static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+static void memcg_free_shrinker_maps(struct mem_cgroup *memcg) { }
+#endif /* CONFIG_MEMCG_SHRINKER */
+
 /**
  * mem_cgroup_css_from_page - css of the memcg associated with a page
  * @page: page of interest
@@ -4471,6 +4581,11 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
+	if (memcg_alloc_shrinker_maps(memcg)) {
+		mem_cgroup_id_remove(memcg);
+		return -ENOMEM;
+	}
+
 	/* Online state pins memcg ID, memcg ID pins CSS */
 	atomic_set(&memcg->id.ref, 1);
 	css_get(css);
@@ -4522,6 +4637,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	vmpressure_cleanup(&memcg->vmpressure);
 	cancel_work_sync(&memcg->high_work);
 	mem_cgroup_remove_from_trees(memcg);
+	memcg_free_shrinker_maps(memcg);
 	memcg_free_kmem(memcg);
 	mem_cgroup_free(memcg);
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d691beac1048..d8a2870710e0 100644
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
