Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 66FE46B00E6
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 08:05:39 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id wz7so2034430pbc.38
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 05:05:39 -0700 (PDT)
Received: from psmtp.com ([74.125.245.167])
        by mx.google.com with SMTP id sw1si791051pbc.252.2013.10.24.05.05.37
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 05:05:38 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 09/15] memcg,list_lru: add per-memcg LRU list infrastructure
Date: Thu, 24 Oct 2013 16:05:00 +0400
Message-ID: <53724b1c74b4f4e844180809d32bdc6c5e94bf65.1382603434.git.vdavydov@parallels.com>
In-Reply-To: <cover.1382603434.git.vdavydov@parallels.com>
References: <cover.1382603434.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: glommer@openvz.org, khorenko@parallels.com, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

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
Cc: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/list_lru.h |   56 +++++++++++
 mm/memcontrol.c          |  251 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 301 insertions(+), 6 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 3ce5417..b3b3b86 100644
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
@@ -31,6 +33,27 @@ struct list_lru {
 	nodemask_t		active_nodes;
 };
 
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
 
@@ -128,4 +151,37 @@ list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
 	}
 	return isolated;
 }
+
+#ifdef CONFIG_MEMCG_KMEM
+int memcg_list_lru_init(struct memcg_list_lru *lru);
+void memcg_list_lru_destroy(struct memcg_list_lru *lru);
+
+struct list_lru *
+mem_cgroup_list_lru(struct memcg_list_lru *lru, struct mem_cgroup *memcg);
+struct list_lru *
+mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru, void *ptr);
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
index 2f5a777..39e4772 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -54,6 +54,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/list_lru.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -3233,6 +3234,8 @@ void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
 	mutex_unlock(&memcg->slab_caches_mutex);
 }
 
+static int memcg_update_all_lrus(int num_groups);
+
 /*
  * This ends up being protected by the set_limit mutex, during normal
  * operation, because that is its main call site.
@@ -3257,15 +3260,28 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	 */
 	memcg_kmem_set_activated(memcg);
 
-	ret = memcg_update_all_caches(num+1);
-	if (ret) {
-		ida_simple_remove(&kmem_limited_groups, num);
-		memcg_kmem_clear_activated(memcg);
-		return ret;
-	}
+	/*
+	 * We need to update the memcg lru lists before we update the caches.
+	 * Once the caches are updated, they will be able to start hosting
+	 * objects. If a cache is created very quickly and an element is used
+	 * and disposed to the lru quickly as well, we can end up with a NULL
+	 * pointer dereference while trying to add a new element to a memcg
+	 * lru.
+	 */
+	ret = memcg_update_all_lrus(num + 1);
+	if (ret)
+		goto out;
+
+	ret = memcg_update_all_caches(num + 1);
+	if (ret)
+		goto out;
 
 	memcg->kmemcg_id = num;
 	return 0;
+out:
+	ida_simple_remove(&kmem_limited_groups, num);
+	memcg_kmem_clear_activated(memcg);
+	return ret;
 }
 
 static size_t memcg_caches_array_size(int num_groups)
@@ -3865,6 +3881,228 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	VM_BUG_ON(mem_cgroup_is_root(memcg));
 	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
 }
+
+static LIST_HEAD(memcg_lrus_list);
+
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
+static void free_memcg_lru(struct memcg_list_lru *lru, int memcg_id)
+{
+	struct list_lru *memcg_lru = NULL;
+
+	swap(lru->memcg_lrus[memcg_id], memcg_lru);
+	if (memcg_lru) {
+		list_lru_destroy(memcg_lru);
+		kfree(memcg_lru);
+	}
+}
+
+static int memcg_list_lru_grow(struct memcg_list_lru *lru, int num_groups)
+{
+	struct list_lru **new_lrus;
+
+	new_lrus = kcalloc(memcg_caches_array_size(num_groups),
+			   sizeof(*new_lrus), GFP_KERNEL);
+	if (!new_lrus)
+		return -ENOMEM;
+
+	if (lru->memcg_lrus) {
+		int i;
+
+		for (i = 0; i < memcg_limited_groups_array_size; i++) {
+			if (lru->memcg_lrus[i])
+				new_lrus[i] = lru->memcg_lrus[i];
+		}
+	}
+
+	lru->old_lrus = lru->memcg_lrus;
+	rcu_assign_pointer(lru->memcg_lrus, new_lrus);
+	return 0;
+}
+
+static void __memcg_destroy_all_lrus(int memcg_id)
+{
+	struct memcg_list_lru *lru;
+
+	list_for_each_entry(lru, &memcg_lrus_list, list)
+		free_memcg_lru(lru, memcg_id);
+}
+
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
+static int memcg_update_all_lrus(int num_groups)
+{
+	int err = 0;
+	struct memcg_list_lru *lru;
+	int new_memcg_id = num_groups - 1;
+	int grow = (num_groups > memcg_limited_groups_array_size);
+
+	memcg_stop_kmem_account();
+	if (grow) {
+		list_for_each_entry(lru, &memcg_lrus_list, list) {
+			err = memcg_list_lru_grow(lru, num_groups);
+			if (err)
+				goto out;
+		}
+	}
+	list_for_each_entry(lru, &memcg_lrus_list, list) {
+		err = alloc_memcg_lru(lru, new_memcg_id);
+		if (err)
+			goto out;
+	}
+out:
+	if (grow) {
+		/* free previous versions of memcg_lrus arrays */
+		synchronize_rcu();
+		list_for_each_entry(lru, &memcg_lrus_list, list) {
+			kfree(lru->old_lrus);
+			lru->old_lrus = NULL;
+		}
+	}
+	if (err)
+		__memcg_destroy_all_lrus(new_memcg_id);
+	memcg_resume_kmem_account();
+	return err;
+}
+
+static void __memcg_list_lru_destroy(struct memcg_list_lru *lru)
+{
+	int i;
+
+	if (lru->memcg_lrus) {
+		for (i = 0; i < memcg_limited_groups_array_size; i++)
+			free_memcg_lru(lru, i);
+	}
+}
+
+static int __memcg_list_lru_init(struct memcg_list_lru *lru)
+{
+	int err = 0;
+	struct mem_cgroup *memcg;
+
+	if (!memcg_kmem_enabled())
+		return 0;
+
+	memcg_stop_kmem_account();
+	lru->memcg_lrus = kcalloc(memcg_limited_groups_array_size,
+				  sizeof(*lru->memcg_lrus), GFP_KERNEL);
+	if (!lru->memcg_lrus)
+		return -ENOMEM;
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
+			mem_cgroup_iter_break(root_mem_cgroup, memcg);
+			goto out;
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
+	memset(lru, 0, sizeof(*lru));
+
+	err = list_lru_init(&lru->global_lru);
+	if (err)
+		return err;
+
+	mutex_lock(&memcg_create_mutex);
+	err = __memcg_list_lru_init(lru);
+	if (!err)
+		list_add(&lru->list, &memcg_lrus_list);
+	mutex_unlock(&memcg_create_mutex);
+
+	if (err)
+		list_lru_destroy(&lru->global_lru);
+	return err;
+}
+
+void memcg_list_lru_destroy(struct memcg_list_lru *lru)
+{
+	list_lru_destroy(&lru->global_lru);
+
+	mutex_lock(&memcg_create_mutex);
+	__memcg_list_lru_destroy(lru);
+	list_del(&lru->list);
+	mutex_unlock(&memcg_create_mutex);
+}
+
+struct list_lru *
+mem_cgroup_list_lru(struct memcg_list_lru *lru, struct mem_cgroup *memcg)
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
+struct list_lru *
+mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru, void *ptr)
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
 #else
 static inline void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 {
@@ -6044,6 +6282,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
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
