Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id A08B56B0009
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 08:07:40 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/7] memcg,list_lru: duplicate LRUs upon kmemcg creation
Date: Fri,  8 Feb 2013 17:07:32 +0400
Message-Id: <1360328857-28070-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1360328857-28070-1-git-send-email-glommer@parallels.com>
References: <1360328857-28070-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Glauber Costa <glommer@parallels.com>, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

When a new memcg is created, we need to open up room for its descriptors
in all of the list_lrus that are marked per-memcg. The process is quite
similar to the one we are using for the kmem caches: we initialize the
new structures in an array indexed by kmemcg_id, and grow the array if
needed. Key data like the size of the array will be shared between the
kmem cache code and the list_lru code (they basically describe the same
thing)

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/list_lru.h   |  47 +++++++++++++++++
 include/linux/memcontrol.h |   6 +++
 lib/list_lru.c             | 115 +++++++++++++++++++++++++++++++++++++---
 mm/memcontrol.c            | 128 ++++++++++++++++++++++++++++++++++++++++++---
 mm/slab_common.c           |   1 -
 5 files changed, 283 insertions(+), 14 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 02796da..370b989 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -16,11 +16,58 @@ struct list_lru_node {
 	long			nr_items;
 } ____cacheline_aligned_in_smp;
 
+struct list_lru_array {
+	struct list_lru_node node[1];
+};
+
 struct list_lru {
+	struct list_head	lrus;
 	struct list_lru_node	node[MAX_NUMNODES];
 	nodemask_t		active_nodes;
+#ifdef CONFIG_MEMCG_KMEM
+	struct list_lru_array	**memcg_lrus;
+#endif
 };
 
+struct mem_cgroup;
+#ifdef CONFIG_MEMCG_KMEM
+/*
+ * We will reuse the last bit of the pointer to tell the lru subsystem that
+ * this particular lru should be replicated when a memcg comes in.
+ */
+static inline void lru_memcg_enable(struct list_lru *lru)
+{
+	lru->memcg_lrus = (void *)0x1ULL;
+}
+
+/*
+ * This will return true if we have already allocated and assignment a memcg
+ * pointer set to the LRU. Therefore, we need to mask the first bit out
+ */
+static inline bool lru_memcg_is_assigned(struct list_lru *lru)
+{
+	return (unsigned long)lru->memcg_lrus & ~0x1ULL;
+}
+
+struct list_lru_array *lru_alloc_array(void);
+int memcg_update_all_lrus(unsigned long num);
+void list_lru_destroy(struct list_lru *lru);
+void list_lru_destroy_memcg(struct mem_cgroup *memcg);
+#else
+static inline void lru_memcg_enable(struct list_lru *lru)
+{
+}
+
+static inline bool lru_memcg_is_assigned(struct list_lru *lru)
+{
+	return false;
+}
+
+static inline void list_lru_destroy(struct list_lru *lru)
+{
+}
+#endif
+
 int list_lru_init(struct list_lru *lru);
 int list_lru_add(struct list_lru *lru, struct list_head *item);
 int list_lru_del(struct list_lru *lru, struct list_head *item);
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b7de557..f9558d0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -23,6 +23,7 @@
 #include <linux/vm_event_item.h>
 #include <linux/hardirq.h>
 #include <linux/jump_label.h>
+#include <linux/list_lru.h>
 
 struct mem_cgroup;
 struct page_cgroup;
@@ -475,6 +476,11 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
+int memcg_new_lru(struct list_lru *lru);
+
+int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
+			       bool new_lru);
+
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
 void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
diff --git a/lib/list_lru.c b/lib/list_lru.c
index 0f08ed6..3b0e89d 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -8,6 +8,7 @@
 #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/list_lru.h>
+#include <linux/memcontrol.h>
 
 int
 list_lru_add(
@@ -184,18 +185,118 @@ list_lru_dispose_all(
 	return total;
 }
 
-int
-list_lru_init(
-	struct list_lru	*lru)
+/*
+ * This protects the list of all LRU in the system. One only needs
+ * to take when registering an LRU, or when duplicating the list of lrus.
+ * Transversing an LRU can and should be done outside the lock
+ */
+static DEFINE_MUTEX(all_lrus_mutex);
+static LIST_HEAD(all_lrus);
+
+static void list_lru_init_one(struct list_lru_node *lru)
+{
+	spin_lock_init(&lru->lock);
+	INIT_LIST_HEAD(&lru->list);
+	lru->nr_items = 0;
+}
+
+struct list_lru_array *lru_alloc_array(void)
+{
+	struct list_lru_array *lru_array;
+	int i;
+
+	lru_array = kzalloc(nr_node_ids * sizeof(struct list_lru_node),
+				GFP_KERNEL);
+	if (!lru_array)
+		return NULL;
+
+	for (i = 0; i < nr_node_ids ; i++)
+		list_lru_init_one(&lru_array->node[i]);
+
+	return lru_array;
+}
+
+int __list_lru_init(struct list_lru *lru)
 {
 	int i;
 
 	nodes_clear(lru->active_nodes);
-	for (i = 0; i < MAX_NUMNODES; i++) {
-		spin_lock_init(&lru->node[i].lock);
-		INIT_LIST_HEAD(&lru->node[i].list);
-		lru->node[i].nr_items = 0;
+	for (i = 0; i < MAX_NUMNODES; i++)
+		list_lru_init_one(&lru->node[i]);
+
+	return 0;
+}
+
+#ifdef CONFIG_MEMCG_KMEM
+static int memcg_init_lru(struct list_lru *lru)
+{
+	int ret;
+
+	if (!lru->memcg_lrus)
+		return 0;
+
+	INIT_LIST_HEAD(&lru->lrus);
+	mutex_lock(&all_lrus_mutex);
+	list_add(&lru->lrus, &all_lrus);
+	ret = memcg_new_lru(lru);
+	mutex_unlock(&all_lrus_mutex);
+	return ret;
+}
+
+int memcg_update_all_lrus(unsigned long num)
+{
+	int ret = 0;
+	struct list_lru *lru;
+
+	mutex_lock(&all_lrus_mutex);
+	list_for_each_entry(lru, &all_lrus, lrus) {
+		if (!lru->memcg_lrus)
+			continue;
+
+		ret = memcg_kmem_update_lru_size(lru, num, false);
+		if (ret)
+			goto out;
+	}
+out:
+	mutex_unlock(&all_lrus_mutex);
+	return ret;
+}
+
+void list_lru_destroy(struct list_lru *lru)
+{
+	if (!lru->memcg_lrus)
+		return;
+
+	mutex_lock(&all_lrus_mutex);
+	list_del(&lru->lrus);
+	mutex_unlock(&all_lrus_mutex);
+}
+
+void list_lru_destroy_memcg(struct mem_cgroup *memcg)
+{
+	struct list_lru *lru;
+	mutex_lock(&all_lrus_mutex);
+	list_for_each_entry(lru, &all_lrus, lrus) {
+		lru->memcg_lrus[memcg_cache_id(memcg)] = NULL;
+		/* everybody must beaware that this memcg is no longer valid */
+		wmb();
 	}
+	mutex_unlock(&all_lrus_mutex);
+}
+#else
+static int memcg_init_lru(struct list_lru *lru)
+{
 	return 0;
 }
+#endif
+
+int list_lru_init(struct list_lru *lru)
+{
+	int ret;
+	ret = __list_lru_init(lru);
+	if (ret)
+		return ret;
+
+	return memcg_init_lru(lru);
+}
 EXPORT_SYMBOL_GPL(list_lru_init);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b1d4dfa..b9e1941 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3032,16 +3032,30 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	memcg_kmem_set_activated(memcg);
 
 	ret = memcg_update_all_caches(num+1);
-	if (ret) {
-		ida_simple_remove(&kmem_limited_groups, num);
-		memcg_kmem_clear_activated(memcg);
-		return ret;
-	}
+	if (ret)
+		goto out;
+
+	/*
+	 * We should make sure that the array size is not updated until we are
+	 * done; otherwise we have no easy way to know whether or not we should
+	 * grow the array.
+	 */
+	ret = memcg_update_all_lrus(num + 1);
+	if (ret)
+		goto out;
 
 	memcg->kmemcg_id = num;
+
+	memcg_update_array_size(num + 1);
+
 	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
 	mutex_init(&memcg->slab_caches_mutex);
+
 	return 0;
+out:
+	ida_simple_remove(&kmem_limited_groups, num);
+	memcg_kmem_clear_activated(memcg);
+	return ret;
 }
 
 static size_t memcg_caches_array_size(int num_groups)
@@ -3121,6 +3135,106 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
+/*
+ * memcg_kmem_update_lru_size - fill in kmemcg info into a list_lru
+ *
+ * @lru: the lru we are operating with
+ * @num_groups: how many kmem-limited cgroups we have
+ * @new_lru: true if this is a new_lru being created, false if this
+ * was triggered from the memcg side
+ *
+ * Returns 0 on success, and an error code otherwise.
+ *
+ * This function can be called either when a new kmem-limited memcg appears,
+ * or when a new list_lru is created. The work is roughly the same in two cases,
+ * but in the later we never have to expand the array size.
+ *
+ * This is always protected by the all_lrus_mutex from the list_lru side.
+ */
+int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
+			       bool new_lru)
+{
+	struct list_lru_array **new_lru_array;
+	struct list_lru_array *lru_array;
+
+	lru_array = lru_alloc_array();
+	if (!lru_array)
+		return -ENOMEM;
+
+	/* need some fucked up locking around the list acquisition */
+	if ((num_groups > memcg_limited_groups_array_size) || new_lru) {
+		int i;
+		struct list_lru_array **old_array;
+		size_t size = memcg_caches_array_size(num_groups);
+
+		new_lru_array = kzalloc(size * sizeof(void *), GFP_KERNEL);
+		if (!new_lru_array) {
+			kfree(lru_array);
+			return -ENOMEM;
+		}
+
+		for (i = 0; i < memcg_limited_groups_array_size; i++) {
+			if (!lru_memcg_is_assigned(lru) || lru->memcg_lrus[i])
+				continue;
+			new_lru_array[i] =  lru->memcg_lrus[i];
+		}
+
+		old_array = lru->memcg_lrus;
+		lru->memcg_lrus = new_lru_array;
+		/*
+		 * We don't need a barrier here because we are just copying
+		 * information over. Anybody operating in memcg_lrus will
+		 * either follow the new array or the old one and they contain
+		 * exactly the same information. The new space in the end is
+		 * always empty anyway.
+		 *
+		 * We do have to make sure that no more users of the old
+		 * memcg_lrus array exist before we free, and this is achieved
+		 * by the synchronize_lru below.
+		 */
+		if (lru_memcg_is_assigned(lru)) {
+			synchronize_rcu();
+			kfree(old_array);
+		}
+
+	}
+
+	if (lru_memcg_is_assigned(lru)) {
+		lru->memcg_lrus[num_groups - 1] = lru_array;
+		/*
+		 * Here we do need the barrier, because of the state transition
+		 * implied by the assignment of the array. All users should be
+		 * able to see it
+		 */
+		wmb();
+	}
+
+	return 0;
+
+}
+
+int memcg_new_lru(struct list_lru *lru)
+{
+	struct mem_cgroup *iter;
+
+	if (!memcg_kmem_enabled())
+		return 0;
+
+	for_each_mem_cgroup(iter) {
+		int ret;
+		int memcg_id = memcg_cache_id(iter);
+		if (memcg_id < 0)
+			continue;
+
+		ret = memcg_kmem_update_lru_size(lru, memcg_id + 1, true);
+		if (ret) {
+			mem_cgroup_iter_break(root_mem_cgroup, iter);
+			return ret;
+		}
+	}
+	return 0;
+}
+
 int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
 			 struct kmem_cache *root_cache)
 {
@@ -5914,8 +6028,10 @@ static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
 	 * possible that the charges went down to 0 between mark_dead and the
 	 * res_counter read, so in that case, we don't need the put
 	 */
-	if (memcg_kmem_test_and_clear_dead(memcg))
+	if (memcg_kmem_test_and_clear_dead(memcg)) {
+		list_lru_destroy_memcg(memcg);
 		mem_cgroup_put(memcg);
+	}
 }
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3f3cd97..2470d11 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -102,7 +102,6 @@ int memcg_update_all_caches(int num_memcgs)
 			goto out;
 	}
 
-	memcg_update_array_size(num_memcgs);
 out:
 	mutex_unlock(&slab_mutex);
 	return ret;
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
