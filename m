Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id C120C6B003B
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:18 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id v1so3123462lbd.4
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:16 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 05/16] memcg,list_lru: duplicate LRUs upon kmemcg creation
Date: Sun,  7 Jul 2013 11:56:45 -0400
Message-Id: <1373212616-11713-6-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>

When a new memcg is created, we need to open up room for its descriptors
in all of the list_lrus that are marked per-memcg. The process is quite
similar to the one we are using for the kmem caches: we initialize the
new structures in an array indexed by kmemcg_id, and grow the array if
needed. Key data like the size of the array will be shared between the
kmem cache code and the list_lru code (they basically describe the same
thing)

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/list_lru.h   |  53 ++++++++++++++-
 include/linux/memcontrol.h |  11 ++++
 mm/list_lru.c              | 117 ++++++++++++++++++++++++++++++---
 mm/memcontrol.c            | 157 +++++++++++++++++++++++++++++++++++++++++++--
 mm/slab_common.c           |   1 -
 5 files changed, 323 insertions(+), 16 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 3ce5417..24a6d58 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -26,13 +26,64 @@ struct list_lru_node {
 	long			nr_items;
 } ____cacheline_aligned_in_smp;
 
+/*
+ * This is supposed to be M x N matrix, where M is kmem-limited memcg, and N is
+ * the number of nodes. Both dimensions are likely to be very small, but are
+ * potentially very big. Therefore we will allocate or grow them dynamically.
+ *
+ * The value of M will increase as new memcgs appear and can be 0 if no memcgs
+ * are being used. This is done in mm/memcontrol.c in a way quite similar to
+ * the way we use for the slab cache management.
+ *
+ * The value of N can't be determined at compile time, but won't increase once
+ * we determine it. It is nr_node_ids, the firmware-provided maximum number of
+ * nodes in a system.
+ */
+struct list_lru_array {
+	struct list_lru_node node[1];
+};
+
 struct list_lru {
 	struct list_lru_node	*node;
 	nodemask_t		active_nodes;
+#ifdef CONFIG_MEMCG_KMEM
+	/* All memcg-aware LRUs will be chained in the lrus list */
+	struct list_head	lrus;
+	/* M x N matrix as described above */
+	struct list_lru_array	**memcg_lrus;
+#endif
 };
 
+struct mem_cgroup;
+/* memcg functions
+ *
+ * This is the list_lru-side of the memcg update routines. They live here to avoid
+ * exposing too much of the internal structures and keeping things logically
+ * grouped. Those functions are not supposed to be called outside memcg core.
+ *
+ * They are called in two situations: when a memcg becomes kmem limited and
+ * when a new lru appears. A memcg becomes limited through a write to a cgroup
+ * file, and a new lru tends to appear when filesystems - or other future users
+ * - appear. Both situations tend to lead to predictable GFP_KERNEL allocations
+ *   so we won't pass flags here. If you ever need to register lrus from
+ *   contexts that are not GFP_KERNEL-safe, you may have to change this.
+ */
+int memcg_update_all_lrus(unsigned long num);
+struct list_lru_array *lru_alloc_memcg_array(void);
+void memcg_list_lru_register(struct list_lru *lru);
+void memcg_destroy_all_lrus(struct mem_cgroup *memcg);
 void list_lru_destroy(struct list_lru *lru);
-int list_lru_init(struct list_lru *lru);
+
+int __list_lru_init(struct list_lru *lru, bool memcg_enabled);
+static inline int list_lru_init(struct list_lru *lru)
+{
+	return __list_lru_init(lru, false);
+}
+
+static inline int list_lru_init_memcg(struct list_lru *lru)
+{
+	return __list_lru_init(lru, true);
+}
 
 /**
  * list_lru_add: add an element to the lru list's tail
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 489c6d7..0015ba4 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -23,6 +23,7 @@
 #include <linux/vm_event_item.h>
 #include <linux/hardirq.h>
 #include <linux/jump_label.h>
+#include <linux/list_lru.h>
 
 struct mem_cgroup;
 struct page_cgroup;
@@ -470,6 +471,11 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
+int memcg_init_lru(struct list_lru *lru, bool memcg_enabled);
+
+int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
+			       bool new_lru);
+
 void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
 void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
@@ -633,6 +639,11 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 static inline void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 }
+
+static inline int memcg_init_lru(struct list_lru *lru, bool memcg_enabled)
+{
+	return 0;
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
index dc71659..96b0c1e 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -9,6 +9,7 @@
 #include <linux/mm.h>
 #include <linux/list_lru.h>
 #include <linux/slab.h>
+#include <linux/memcontrol.h>
 
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
@@ -118,7 +119,97 @@ restart:
 }
 EXPORT_SYMBOL_GPL(list_lru_walk_node);
 
-int list_lru_init(struct list_lru *lru)
+/*
+ * Each list_lru that is memcg-aware is inserted into the all_memcgs_lrus,
+ * which is in turn protected by the all_memcgs_lru_mutex. A caller can test
+ * for whether or not the list_lru by verifying if the list_lru's list pointer
+ * is empty.
+ */
+static DEFINE_MUTEX(all_memcg_lrus_mutex);
+static LIST_HEAD(all_memcg_lrus);
+
+static void list_lru_init_one(struct list_lru_node *lru)
+{
+	spin_lock_init(&lru->lock);
+	INIT_LIST_HEAD(&lru->list);
+	lru->nr_items = 0;
+}
+
+#ifdef CONFIG_MEMCG_KMEM
+struct list_lru_array *lru_alloc_memcg_array(void)
+{
+	struct list_lru_array *lru_array;
+	int i;
+
+	lru_array = kcalloc(nr_node_ids, sizeof(struct list_lru_node),
+			    GFP_KERNEL);
+	if (!lru_array)
+		return NULL;
+
+	for (i = 0; i < nr_node_ids; i++)
+		list_lru_init_one(&lru_array->node[i]);
+
+	return lru_array;
+}
+
+void memcg_list_lru_register(struct list_lru *lru)
+{
+	mutex_lock(&all_memcg_lrus_mutex);
+	list_add(&lru->lrus, &all_memcg_lrus);
+	mutex_unlock(&all_memcg_lrus_mutex);
+}
+
+int memcg_update_all_lrus(unsigned long num)
+{
+	int ret = 0;
+	struct list_lru *lru;
+
+	mutex_lock(&all_memcg_lrus_mutex);
+	list_for_each_entry(lru, &all_memcg_lrus, lrus) {
+		ret = memcg_kmem_update_lru_size(lru, num, false);
+		if (ret)
+			goto out;
+	}
+out:
+	mutex_unlock(&all_memcg_lrus_mutex);
+	return ret;
+}
+
+static void memcg_list_lru_destroy(struct list_lru *lru)
+{
+	if (list_empty(&lru->lrus))
+		return;
+
+	mutex_lock(&all_memcg_lrus_mutex);
+	list_del(&lru->lrus);
+	mutex_unlock(&all_memcg_lrus_mutex);
+}
+
+void memcg_destroy_all_lrus(struct mem_cgroup *memcg)
+{
+	struct list_lru *lru;
+	int memcg_id = memcg_cache_id(memcg);
+
+	if (WARN_ON(memcg_id < 0))
+		return;
+
+	mutex_lock(&all_memcg_lrus_mutex);
+	list_for_each_entry(lru, &all_memcg_lrus, lrus) {
+		struct list_lru_array *memcg_lru = lru->memcg_lrus[memcg_id];
+		lru->memcg_lrus[memcg_id] = NULL;
+		/* everybody must be aware that this memcg is no longer valid */
+		wmb();
+		kfree(memcg_lru);
+	}
+	mutex_unlock(&all_memcg_lrus_mutex);
+}
+#else
+static void memcg_list_lru_destroy(struct list_lru *lru)
+{
+}
+#endif
+
+int __list_lru_init(struct list_lru *lru, bool memcg_enabled)
 {
 	int i;
 	size_t size = sizeof(*lru->node) * nr_node_ids;
@@ -128,17 +219,27 @@ int list_lru_init(struct list_lru *lru)
 		return -ENOMEM;
 
 	nodes_clear(lru->active_nodes);
-	for (i = 0; i < nr_node_ids; i++) {
-		spin_lock_init(&lru->node[i].lock);
-		INIT_LIST_HEAD(&lru->node[i].list);
-		lru->node[i].nr_items = 0;
-	}
-	return 0;
+	for (i = 0; i < nr_node_ids; i++)
+		list_lru_init_one(&lru->node[i]);
+
+	/*
+	 * We need the memcg_create_mutex and the all_memcgs_lrus_mutex held
+	 * here, but the memcg mutex needs to come first.  This complicates the
+	 * flow a little bit, but since the memcg_create_mutex is held through
+	 * the whole duration of memcg creation process (during which we can
+	 * call memcg_update_all_lrus), we need to hold it before we hold the
+	 * all_memcg_lrus_mutex in the case of a new list_lru creation as well.
+	 *
+	 * Do this by calling into memcg, that will hold the memcg_create_mutex
+	 * and then call back into list_lru.c's memcg_list_lru_register.
+	 */
+	return memcg_init_lru(lru, memcg_enabled);
 }
-EXPORT_SYMBOL_GPL(list_lru_init);
+EXPORT_SYMBOL_GPL(__list_lru_init);
 
 void list_lru_destroy(struct list_lru *lru)
 {
 	kfree(lru->node);
+	memcg_list_lru_destroy(lru);
 }
 EXPORT_SYMBOL_GPL(list_lru_destroy);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a5581ef..9d71e60 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3110,8 +3110,10 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 	 * The memory barrier imposed by test&clear is paired with the
 	 * explicit one in memcg_kmem_mark_dead().
 	 */
-	if (memcg_kmem_test_and_clear_dead(memcg))
+	if (memcg_kmem_test_and_clear_dead(memcg)) {
+		memcg_destroy_all_lrus(memcg);
 		css_put(&memcg->css);
+	}
 }
 
 void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
@@ -3148,17 +3150,37 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	 */
 	memcg_kmem_set_activated(memcg);
 
+	/*
+	 * We should make sure that the array size is not updated until we are
+	 * done; otherwise we have no easy way to know whether or not we should
+	 * grow the array.
+	 *
+	 * Also, we need to update the list_lrus before we update the caches.
+	 * Once the caches are updated, they will be able to start hosting
+	 * objects. If a cache is created very quickly and an element is used
+	 * and disposed to the LRU quickly as well, we may end up with a NULL
+	 * pointer in list_lru_add because the lists are not yet ready.
+	 */
+	ret = memcg_update_all_lrus(num + 1);
+	if (ret)
+		goto out;
+
 	ret = memcg_update_all_caches(num+1);
-	if (ret) {
-		ida_simple_remove(&kmem_limited_groups, num);
-		memcg_kmem_clear_activated(memcg);
-		return ret;
-	}
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
@@ -3240,6 +3262,129 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
+/**
+ * memcg_kmem_update_lru_size - fill in kmemcg info into a list_lru
+ *
+ * @lru: the lru we are operating with
+ * @num_groups: how many kmem-limited cgroups we have
+ * @new_lru: true if this is a new_lru being created, false if this
+ * was triggered from the memcg side
+ *
+ * Returns 0 on success, and an error code otherwise.
+ *
+ * This function can be called either when a new kmem-limited memcg appears, or
+ * when a new list_lru is created. The work is roughly the same in both cases,
+ * but in the latter we never have to expand the array size.
+ *
+ * This is always protected by the all_lrus_mutex from the list_lru side.  But
+ * a race can still exist if a new memcg becomes kmem limited at the same time
+ * that we are registering a new memcg. Creation is protected by the
+ * memcg_create_mutex, so the creation of a new lru has to be protected by that
+ * as well.
+ *
+ * The lock ordering is that the memcg_create_mutex needs to be acquired before
+ * the all_memcgs_lru_mutex (list_lru.c).
+ */
+int memcg_kmem_update_lru_size(struct list_lru *lru, int num_groups,
+			       bool new_lru)
+{
+	struct list_lru_array **new_lru_array;
+	struct list_lru_array *lru_array;
+
+	lru_array = lru_alloc_memcg_array();
+	if (!lru_array)
+		return -ENOMEM;
+
+	/*
+	 * Note that we need to update the arrays not only when a memcg becomes
+	 * kmem limited, but also when a new lru appears (therefore the "||
+	 * new_lru" test bellow.
+	 */
+	if ((num_groups > memcg_limited_groups_array_size) || new_lru) {
+		int i;
+		struct list_lru_array **old_array;
+		size_t size = memcg_caches_array_size(num_groups);
+		int num_memcgs = memcg_limited_groups_array_size;
+
+		/*
+		 * The GFP_KERNEL allocation means that we cannot take neither
+		 * the memcg_create_mutex nor the all_memcgs_lru_mutex in the
+		 * direct reclaim path. It should be fine, since they are both
+		 * only used at registration time.
+		 */
+		new_lru_array = kcalloc(size, sizeof(void *), GFP_KERNEL);
+		if (!new_lru_array) {
+			kfree(lru_array);
+			return -ENOMEM;
+		}
+
+		for (i = 0; lru->memcg_lrus && (i < num_memcgs); i++) {
+			if (lru->memcg_lrus && !lru->memcg_lrus[i])
+				continue;
+			new_lru_array[i] =  lru->memcg_lrus[i];
+		}
+
+		old_array = lru->memcg_lrus;
+		lru->memcg_lrus = new_lru_array;
+		/*
+		 * We don't need a barrier here because we are just copying
+		 * information over. Anybody operating on memcg_lrus will
+		 * either follow the new array or the old one and they contain
+		 * exactly the same information. The new space at the end is
+		 * always empty anyway.
+		 */
+		if (lru->memcg_lrus)
+			kfree(old_array);
+	}
+
+	if (lru->memcg_lrus) {
+		lru->memcg_lrus[num_groups - 1] = lru_array;
+		/*
+		 * Here we do need the barrier, because of the state transition
+		 * implied by the assignment of the array. All users should be
+		 * able to see it.
+		 */
+		wmb();
+	}
+	return 0;
+}
+
+static int memcg_new_lru(struct list_lru *lru)
+{
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup(iter) {
+		int ret;
+		int memcg_id = memcg_cache_id(iter);
+		if (memcg_id < 0)
+			continue;
+
+		memcg_stop_kmem_account();
+		ret = memcg_kmem_update_lru_size(lru, memcg_id + 1, true);
+		memcg_resume_kmem_account();
+		if (ret) {
+			mem_cgroup_iter_break(root_mem_cgroup, iter);
+			return ret;
+		}
+	}
+	return 0;
+}
+
+int memcg_init_lru(struct list_lru *lru, bool memcg_enabled)
+{
+	int ret;
+
+	INIT_LIST_HEAD(&lru->lrus);
+	if (!memcg_enabled || !memcg_kmem_enabled())
+		return 0;
+
+	mutex_lock(&memcg_create_mutex);
+	memcg_list_lru_register(lru);
+	ret = memcg_new_lru(lru);
+	mutex_unlock(&memcg_create_mutex);
+	return ret;
+}
+
 int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
 			 struct kmem_cache *root_cache)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2d41450..731b872 100644
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
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
