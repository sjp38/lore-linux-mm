Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id DC13D6B0080
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:20:13 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id n7so8388290lam.30
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:20:13 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ww4si17214444lbb.147.2013.12.02.03.20.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:20:12 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 10/18] memcg,list_lru: add per-memcg LRU list infrastructure
Date: Mon, 2 Dec 2013 15:19:45 +0400
Message-ID: <73d7942f31ac80dfa53bbdd0f957ce5e9a301958.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
References: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

FS-shrinkers, which shrink dcaches and icaches, keep dentries and inodes
in list_lru structures in order to evict least recently used objects.
With per-memcg kmem shrinking infrastructure introduced, we have to make
those LRU lists per-memcg in order to allow shrinking FS caches that
belong to different memory cgroups independently.

This patch addresses the issue by introducing struct memcg_list_lru.
This struct aggregates list_lru objects for each kmem-active memcg, and
keeps it uptodate whenever a memcg is created or destroyed. Its
interface is very simple: it only allows to get the pointer to the
appropriate list_lru object from a memcg or a kmem ptr, which should be
further operated with conventional list_lru methods.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/list_lru.h |   62 ++++++++++
 mm/memcontrol.c          |  299 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 356 insertions(+), 5 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 3ce5417..2ad0bc6 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -10,6 +10,8 @@
 #include <linux/list.h>
 #include <linux/nodemask.h>
 
+struct mem_cgroup;
+
 /* list_lru_walk_cb has to always return one of those */
 enum lru_status {
 	LRU_REMOVED,		/* item removed from list */
@@ -31,6 +33,33 @@ struct list_lru {
 	nodemask_t		active_nodes;
 };
 
+/*
+ * The following structure can be used to reclaim kmem objects accounted to
+ * different memory cgroups independently. It aggregates a set of list_lru
+ * objects, one for each kmem-enabled memcg, and provides the method to get
+ * the lru corresponding to a memcg.
+ */
+struct memcg_list_lru {
+	struct list_lru global_lru;
+
+#ifdef CONFIG_MEMCG_KMEM
+	struct list_lru **memcg_lrus;	/* rcu-protected array of per-memcg
+					   lrus, indexed by memcg_cache_id() */
+
+	struct list_head list;		/* list of all memcg-aware lrus */
+
+	/*
+	 * The memcg_lrus array is rcu protected, so we can only free it after
+	 * a call to synchronize_rcu(). To avoid multiple calls to
+	 * synchronize_rcu() when many lrus get updated at the same time, which
+	 * is a typical scenario, we will store the pointer to the previous
+	 * version of the array in the old_lrus variable for each lru, and then
+	 * free them all at once after a single call to synchronize_rcu().
+	 */
+	void *old_lrus;
+#endif
+};
+
 void list_lru_destroy(struct list_lru *lru);
 int list_lru_init(struct list_lru *lru);
 
@@ -128,4 +157,37 @@ list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
 	}
 	return isolated;
 }
+
+#ifdef CONFIG_MEMCG_KMEM
+int memcg_list_lru_init(struct memcg_list_lru *lru);
+void memcg_list_lru_destroy(struct memcg_list_lru *lru);
+
+struct list_lru *mem_cgroup_list_lru(struct memcg_list_lru *lru,
+				     struct mem_cgroup *memcg);
+struct list_lru *mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru,
+					  void *ptr);
+#else
+static inline int memcg_list_lru_init(struct memcg_list_lru *lru)
+{
+	return list_lru_init(&lru->global_lru);
+}
+
+static inline void memcg_list_lru_destroy(struct memcg_list_lru *lru)
+{
+	list_lru_destroy(&lru->global_lru);
+}
+
+static inline struct list_lru *
+mem_cgroup_list_lru(struct memcg_list_lru *lru, struct mem_cgroup *memcg)
+{
+	return &lru->global_lru;
+}
+
+static inline struct list_lru *
+mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru, void *ptr)
+{
+	return &lru->global_lru;
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
 #endif /* _LRU_LIST_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3f12cec..253e01e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -55,6 +55,7 @@
 #include <linux/cpu.h>
 #include <linux/oom.h>
 #include <linux/lockdep.h>
+#include <linux/list_lru.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -3065,6 +3066,280 @@ static inline void memcg_resume_kmem_account(void)
 }
 
 /*
+ * The list of all memcg_list_lru objects. Protected by memcg_create_mutex.
+ * Needed for updating all per-memcg lrus whenever a new kmem-enabled memcg
+ * is created or destroyed.
+ */
+static LIST_HEAD(all_per_memcg_lrus);
+
+/* helper to allocate a list_lru for a memcg in a per-memcg lru */
+static int alloc_memcg_lru(struct memcg_list_lru *lru, int memcg_id)
+{
+	int err;
+	struct list_lru *memcg_lru;
+
+	memcg_lru = kmalloc(sizeof(*memcg_lru), GFP_KERNEL);
+	if (!memcg_lru)
+		return -ENOMEM;
+
+	err = list_lru_init(memcg_lru);
+	if (err) {
+		kfree(memcg_lru);
+		return err;
+	}
+
+	VM_BUG_ON(lru->memcg_lrus[memcg_id]);
+	lru->memcg_lrus[memcg_id] = memcg_lru;
+	return 0;
+}
+
+/* helper to free the memcg list_lru in a per-memcg lru */
+static void free_memcg_lru(struct memcg_list_lru *lru, int memcg_id)
+{
+	struct list_lru *memcg_lru;
+
+	memcg_lru = lru->memcg_lrus[memcg_id];
+	if (memcg_lru) {
+		list_lru_destroy(memcg_lru);
+		kfree(memcg_lru);
+		lru->memcg_lrus[memcg_id] = NULL;
+	}
+}
+
+/*
+ * Grows a per-memcg lru to acommodate list_lrus for new_num_memcg memory
+ * cgroups. Is called for each per-memcg lru whenever a new kmem-enabled memcg
+ * is added and we need to update the caches array. It will keep the old array
+ * of pointers to per-memcg lrus in old_lrus to be freed after a call to
+ * synchronize_rcu().
+ */
+static int memcg_list_lru_grow(struct memcg_list_lru *lru, int new_num_memcgs)
+{
+	struct list_lru **new_lrus;
+
+	new_lrus = kcalloc(memcg_caches_array_size(new_num_memcgs),
+			   sizeof(*new_lrus), GFP_KERNEL);
+	if (!new_lrus)
+		return -ENOMEM;
+
+	if (lru->memcg_lrus) {
+		int i;
+
+		for_each_memcg_cache_index(i) {
+			if (lru->memcg_lrus[i])
+				new_lrus[i] = lru->memcg_lrus[i];
+		}
+	}
+
+	VM_BUG_ON(lru->old_lrus);
+	lru->old_lrus = lru->memcg_lrus;
+	rcu_assign_pointer(lru->memcg_lrus, new_lrus);
+	return 0;
+}
+
+static void __memcg_destroy_all_lrus(int memcg_id)
+{
+	struct memcg_list_lru *lru;
+
+	list_for_each_entry(lru, &all_per_memcg_lrus, list)
+		free_memcg_lru(lru, memcg_id);
+}
+
+/*
+ * Frees list_lrus corresponding to a memcg in all per-memcg lrus. Is called
+ * when a memcg is destroyed.
+ */
+static void memcg_destroy_all_lrus(struct mem_cgroup *memcg)
+{
+	int memcg_id;
+
+	memcg_id = memcg_cache_id(memcg);
+	if (memcg_id >= 0) {
+		mutex_lock(&memcg_create_mutex);
+		__memcg_destroy_all_lrus(memcg_id);
+		mutex_unlock(&memcg_create_mutex);
+	}
+}
+
+/*
+ * This function is called when a new kmem-enabled memcg is added. It
+ * initializes list_lrus corresponding to the memcg in all per-memcg lrus
+ * growing them if necessary.
+ */
+static int memcg_init_all_lrus(int new_memcg_id)
+{
+	int err = 0;
+	struct memcg_list_lru *lru;
+	int num_memcgs = new_memcg_id + 1;
+	int grow = (num_memcgs > memcg_limited_groups_array_size);
+
+	memcg_stop_kmem_account();
+	if (grow) {
+		list_for_each_entry(lru, &all_per_memcg_lrus, list) {
+			err = memcg_list_lru_grow(lru, num_memcgs);
+			if (err)
+				goto free_old_lrus;
+		}
+	}
+	list_for_each_entry(lru, &all_per_memcg_lrus, list) {
+		err = alloc_memcg_lru(lru, new_memcg_id);
+		if (err) {
+			__memcg_destroy_all_lrus(new_memcg_id);
+			break;
+		}
+	}
+free_old_lrus:
+	if (grow) {
+		/* free previous versions of memcg_lrus arrays */
+		synchronize_rcu();
+		list_for_each_entry(lru, &all_per_memcg_lrus, list) {
+			kfree(lru->old_lrus);
+			lru->old_lrus = NULL;
+		}
+	}
+	memcg_resume_kmem_account();
+	return err;
+}
+
+static void __memcg_list_lru_destroy(struct memcg_list_lru *lru)
+{
+	int i;
+
+	if (lru->memcg_lrus) {
+		for_each_memcg_cache_index(i)
+			free_memcg_lru(lru, i);
+	}
+}
+
+static int __memcg_list_lru_init(struct memcg_list_lru *lru)
+{
+	int err = 0;
+	struct mem_cgroup *memcg;
+
+	lru->memcg_lrus = NULL;
+	lru->old_lrus = NULL;
+
+	if (!memcg_kmem_enabled())
+		return 0;
+
+	memcg_stop_kmem_account();
+	lru->memcg_lrus = kcalloc(memcg_limited_groups_array_size,
+				  sizeof(*lru->memcg_lrus), GFP_KERNEL);
+	if (!lru->memcg_lrus) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	for_each_mem_cgroup(memcg) {
+		int memcg_id;
+
+		memcg_id = memcg_cache_id(memcg);
+		if (memcg_id < 0)
+			continue;
+
+		err = alloc_memcg_lru(lru, memcg_id);
+		if (err) {
+			mem_cgroup_iter_break(NULL, memcg);
+			break;
+		}
+	}
+out:
+	if (err)
+		__memcg_list_lru_destroy(lru);
+	memcg_resume_kmem_account();
+	return err;
+}
+
+int memcg_list_lru_init(struct memcg_list_lru *lru)
+{
+	int err;
+
+	err = list_lru_init(&lru->global_lru);
+	if (err)
+		return err;
+
+	mutex_lock(&memcg_create_mutex);
+	err = __memcg_list_lru_init(lru);
+	if (!err)
+		list_add(&lru->list, &all_per_memcg_lrus);
+	mutex_unlock(&memcg_create_mutex);
+
+	if (err)
+		list_lru_destroy(&lru->global_lru);
+	return err;
+}
+
+void memcg_list_lru_destroy(struct memcg_list_lru *lru)
+{
+	mutex_lock(&memcg_create_mutex);
+	__memcg_list_lru_destroy(lru);
+	list_del(&lru->list);
+	mutex_unlock(&memcg_create_mutex);
+
+	list_lru_destroy(&lru->global_lru);
+}
+
+/**
+ * mem_cgroup_list_lru - get the lru list for a memcg
+ * @lru: per-memcg lru
+ * @memcg: memcg of the wanted lru list
+ *
+ * Returns the lru list corresponding to the given @memcg in the per-memcg
+ * @lru. If @memcg is NULL, the lru corresponding to the root is returned.
+ *
+ * For each kmem-active memcg, there is a dedicated lru list while all
+ * kmem-inactive memcgs (including the root cgroup) share the same lru list
+ * in each per-memcg lru.
+ */
+struct list_lru *mem_cgroup_list_lru(struct memcg_list_lru *lru,
+				     struct mem_cgroup *memcg)
+{
+	struct list_lru **memcg_lrus;
+	struct list_lru *memcg_lru;
+	int memcg_id;
+
+	memcg_id = memcg_cache_id(memcg);
+	if (memcg_id < 0)
+		return &lru->global_lru;
+
+	rcu_read_lock();
+	memcg_lrus = rcu_dereference(lru->memcg_lrus);
+	memcg_lru = memcg_lrus[memcg_id];
+	rcu_read_unlock();
+
+	return memcg_lru;
+}
+
+/**
+ * mem_cgroup_kmem_list_lru - get the lru list to store a kmem object
+ * @lru: per-memcg lru
+ * @ptr: pointer to the kmem object
+ *
+ * Returns the lru list corresponding to the memcg the given kmem object @ptr
+ * is accounted to in the per-memcg @lru.
+ *
+ * For each kmem-active memcg, there is a dedicated lru list while all
+ * kmem-inactive memcgs (including the root cgroup) share the same lru list
+ * in each per-memcg lru.
+ */
+struct list_lru *mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru,
+					  void *ptr)
+{
+	struct page *page = virt_to_page(ptr);
+	struct mem_cgroup *memcg = NULL;
+	struct page_cgroup *pc;
+
+	pc = lookup_page_cgroup(compound_head(page));
+	if (PageCgroupUsed(pc)) {
+		lock_page_cgroup(pc);
+		if (PageCgroupUsed(pc))
+			memcg = pc->mem_cgroup;
+		unlock_page_cgroup(pc);
+	}
+	return mem_cgroup_list_lru(lru, memcg);
+}
+
+/*
  * This is a bit cumbersome, but it is rarely used and avoids a backpointer
  * in the memcg_cache_params struct.
  */
@@ -3195,15 +3470,28 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	 */
 	memcg_kmem_set_activated(memcg);
 
+	/*
+	 * We need to init the memcg lru lists before we update the caches.
+	 * Once the caches are updated, they will be able to start hosting
+	 * objects. If a cache is created very quickly and an element is used
+	 * and disposed to the lru quickly as well, we can end up with a NULL
+	 * pointer dereference while trying to add a new element to a memcg
+	 * lru.
+	 */
+	ret = memcg_init_all_lrus(num);
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
 	return 0;
+out:
+	ida_simple_remove(&kmem_limited_groups, num);
+	memcg_kmem_clear_activated(memcg);
+	return ret;
 }
 
 /*
@@ -5955,6 +6243,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 	mem_cgroup_sockets_destroy(memcg);
+	memcg_destroy_all_lrus(memcg);
 }
 
 static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
