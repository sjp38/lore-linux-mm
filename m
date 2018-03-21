Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 057D26B002A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:21:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v14so2413175pgq.11
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:21:51 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0138.outbound.protection.outlook.com. [104.47.2.138])
        by mx.google.com with ESMTPS id h8si2763136pgq.665.2018.03.21.06.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 06:21:50 -0700 (PDT)
Subject: [PATCH 03/10] mm: Assign memcg-aware shrinkers bitmap to memcg
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 21 Mar 2018 16:21:40 +0300
Message-ID: <152163850081.21546.6969747084834474733.stgit@localhost.localdomain>
In-Reply-To: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, ktkhai@virtuozzo.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

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
 include/linux/memcontrol.h |   20 ++++++++
 mm/memcontrol.c            |    5 ++
 mm/vmscan.c                |  117 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 142 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4525b4404a9e..ad88a9697fb9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -151,6 +151,11 @@ struct mem_cgroup_thresholds {
 	struct mem_cgroup_threshold_ary *spare;
 };
 
+struct shrinkers_map {
+	struct rcu_head rcu;
+	unsigned long *map[0];
+};
+
 enum memcg_kmem_state {
 	KMEM_NONE,
 	KMEM_ALLOCATED,
@@ -182,6 +187,9 @@ struct mem_cgroup {
 	unsigned long low;
 	unsigned long high;
 
+	/* Bitmap of shrinker ids suitable to call for this memcg */
+	struct shrinkers_map __rcu *shrinkers_map;
+
 	/* Range enforcement for interrupt charges */
 	struct work_struct high_work;
 
@@ -1219,6 +1227,9 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return memcg ? memcg->kmemcg_id : -1;
 }
 
+int alloc_shrinker_maps(struct mem_cgroup *memcg);
+void free_shrinker_maps(struct mem_cgroup *memcg);
+
 #else
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
@@ -1241,6 +1252,15 @@ static inline void memcg_put_cache_ids(void)
 {
 }
 
+static inline int alloc_shrinker_maps(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+
+static inline void free_shrinker_maps(struct mem_cgroup *memcg)
+{
+}
+
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3801ac1fcfbc..2324577c62dc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4476,6 +4476,9 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
+	if (alloc_shrinker_maps(memcg))
+		return -ENOMEM;
+
 	/* Online state pins memcg ID, memcg ID pins CSS */
 	atomic_set(&memcg->id.ref, 1);
 	css_get(css);
@@ -4487,6 +4490,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_event *event, *tmp;
 
+	free_shrinker_maps(memcg);
+
 	/*
 	 * Unregister events and notify userspace.
 	 * Notify userspace about cgroup removing only after rmdir of cgroup
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 97ce4f342fab..9d1df5d90eca 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -165,6 +165,10 @@ static DECLARE_RWSEM(bitmap_rwsem);
 static int bitmap_id_start;
 static int bitmap_nr_ids;
 static struct shrinker **mcg_shrinkers;
+struct shrinkers_map *__rcu root_shrinkers_map;
+
+#define SHRINKERS_MAP(memcg) \
+	(memcg == root_mem_cgroup || !memcg ? root_shrinkers_map : memcg->shrinkers_map)
 
 static int expand_shrinkers_array(int old_nr, int nr)
 {
@@ -188,6 +192,116 @@ static int expand_shrinkers_array(int old_nr, int nr)
 	return 0;
 }
 
+static void kvfree_map_rcu(struct rcu_head *head)
+{
+	struct shrinkers_map *map;
+	int i = nr_node_ids;
+
+	map = container_of(head, struct shrinkers_map, rcu);
+	while (--i >= 0)
+		kvfree(map->map[i]);
+	kvfree(map);
+}
+
+static int memcg_expand_maps(struct mem_cgroup *memcg, int size, int old_size)
+{
+	struct shrinkers_map *new, *old;
+	int i;
+
+	new = kvmalloc(sizeof(*new) + nr_node_ids * sizeof(new->map[0]),
+			GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+
+	for (i = 0; i < nr_node_ids; i++) {
+		new->map[i] = kvmalloc_node(size, GFP_KERNEL, i);
+		if (!new->map[i]) {
+			while (--i >= 0)
+				kvfree(new->map[i]);
+			kvfree(new);
+			return -ENOMEM;
+		}
+
+		/* Set all old bits, clear all new bits */
+		memset(new->map[i], (int)0xff, old_size);
+		memset((void *)new->map[i] + old_size, 0, size - old_size);
+	}
+
+	lockdep_assert_held(&bitmap_rwsem);
+	old = rcu_dereference_protected(SHRINKERS_MAP(memcg), true);
+
+	/*
+	 * We don't want to use rcu_read_lock() in shrink_slab().
+	 * Since expansion happens rare, we may just take the lock
+	 * here.
+	 */
+	if (old)
+		down_write(&shrinker_rwsem);
+
+	if (memcg)
+		rcu_assign_pointer(memcg->shrinkers_map, new);
+	else
+		rcu_assign_pointer(root_shrinkers_map, new);
+
+	if (old) {
+		up_write(&shrinker_rwsem);
+		call_rcu(&old->rcu, kvfree_map_rcu);
+	}
+
+	return 0;
+}
+
+int alloc_shrinker_maps(struct mem_cgroup *memcg)
+{
+	int ret;
+
+	if (memcg == root_mem_cgroup)
+		return 0;
+
+	down_read(&bitmap_rwsem);
+	ret = memcg_expand_maps(memcg, bitmap_nr_ids/BITS_PER_BYTE, 0);
+	up_read(&bitmap_rwsem);
+	return ret;
+}
+
+void free_shrinker_maps(struct mem_cgroup *memcg)
+{
+	struct shrinkers_map *map;
+
+	if (memcg == root_mem_cgroup)
+		return;
+
+	down_read(&bitmap_rwsem);
+	map = rcu_dereference_protected(memcg->shrinkers_map, true);
+	rcu_assign_pointer(memcg->shrinkers_map, NULL);
+	up_read(&bitmap_rwsem);
+
+	if (map)
+		kvfree_map_rcu(&map->rcu);
+}
+
+static int expand_shrinker_maps(int old_id, int id)
+{
+	struct mem_cgroup *memcg = NULL, *root_memcg = root_mem_cgroup;
+	int size, old_size, ret;
+
+	size = id / BITS_PER_BYTE;
+	old_size = old_id / BITS_PER_BYTE;
+
+	if (root_memcg)
+		memcg = mem_cgroup_iter(root_memcg, NULL, NULL);
+	do {
+		ret = memcg_expand_maps(memcg == root_memcg ? NULL : memcg,
+					size, old_size);
+		if (ret || !root_memcg) {
+			mem_cgroup_iter_break(root_memcg, memcg);
+			break;
+		}
+	} while (!!(memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
+
+	return ret;
+}
+
 static int expand_shrinker_id(int id)
 {
 	if (likely(id < bitmap_nr_ids))
@@ -200,6 +314,9 @@ static int expand_shrinker_id(int id)
 	if (expand_shrinkers_array(bitmap_nr_ids, id))
 		return -ENOMEM;
 
+	if (expand_shrinker_maps(bitmap_nr_ids, id))
+		return -ENOMEM;
+
 	bitmap_nr_ids = id;
 	return 0;
 }
