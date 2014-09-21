Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id F38E66B0044
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 11:15:43 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id y10so2889430pdj.3
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 08:15:43 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rc5si12004165pbc.60.2014.09.21.08.15.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Sep 2014 08:15:43 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 08/14] memcg: release memcg_cache_id on css offline
Date: Sun, 21 Sep 2014 19:14:40 +0400
Message-ID: <f9e1e0befe41f243d8685ab3a578cd9fd84843d6.1411301245.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411301245.git.vdavydov@parallels.com>
References: <cover.1411301245.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

The memcg_cache_id (mem_cgroup->kmemcg_id) is used as the index in root
cache's memcg_cache_params->memcg_caches array. Whenever a new kmem
active cgroup is created we must allocate an id for it. As a result, the
array size must always be greater than or equal to the number of memory
cgroups that have memcg_cache_id assigned to them.

Currently we release the id only on css free. This is bad, because css
can be zombieing around for quite a long time after css offline due to
pending charges, occupying an array slot and making the arrays grow
larger and larger. Although the number of arrays is limited - only root
kmem caches have them - we can still experience problems while creating
new kmem active cgroups, because they might require arrays relocation
and each array relocation will require costly high-order page
allocations if there are a lot of ids allocated. The situation will
become even worse when per-memcg list_lru's are introduced, because each
super block has a list_lru, and the number of super blocks is
practically unlimited.

This patch makes memcg release memcg_cache_id on css offline. The id of
a dead memcg is set to its parent cgroup's id. Currently ids are not
used after cgroup death so we could set it to -1, however, once per
memcg list_lru is introduced, we will have to deal with list_lru entries
accounted to the memcg somehow. I'm planning to move those entries to
parent cgroup's list_lru, so we have to set kmemcg_id appropriately.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   64 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 56 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9ae2627bd3b1..d665d715090b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -646,14 +646,10 @@ int memcg_limited_groups_array_size;
 struct static_key memcg_kmem_enabled_key;
 EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
-static void memcg_free_cache_id(int id);
-
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
 {
-	if (memcg_kmem_is_active(memcg)) {
+	if (memcg_kmem_is_active(memcg))
 		static_key_slow_dec(&memcg_kmem_enabled_key);
-		memcg_free_cache_id(memcg->kmemcg_id);
-	}
 	/*
 	 * This check can't live in kmem destruction function,
 	 * since the charges will outlive the cgroup
@@ -2988,6 +2984,12 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 	lockdep_assert_held(&memcg_slab_mutex);
 
 	id = memcg_cache_id(memcg);
+	/*
+	 * This might happen if the cgroup was taken offline while the create
+	 * work was pending.
+	 */
+	if (id < 0)
+		return;
 
 	/*
 	 * Since per-memcg caches are created asynchronously on first
@@ -3036,8 +3038,15 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	memcg = cachep->memcg_params->memcg;
 	id = memcg_cache_id(memcg);
 
-	BUG_ON(cache_from_memcg_idx(root_cache, id) != cachep);
-	cache_install_at_memcg_idx(root_cache, id, NULL);
+	/*
+	 * This function can be called both after and before css offline. If
+	 * it's called before css offline, which happens on the root cache
+	 * destruction, we should clear the slot corresponding to the cache in
+	 * memcg_caches array. Otherwise the slot must have already been
+	 * cleared in memcg_unregister_all_caches.
+	 */
+	if (id >= 0 && cache_from_memcg_idx(root_cache, id) == cachep)
+		cache_install_at_memcg_idx(root_cache, id, NULL);
 
 	list_del(&cachep->memcg_params->list);
 
@@ -3093,19 +3102,49 @@ void __memcg_cleanup_cache_params(struct kmem_cache *s)
 static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
 	struct memcg_cache_params *params, *tmp;
+	int id = memcg_cache_id(memcg);
+	struct cgroup_subsys_state *iter;
+	struct mem_cgroup *parent;
+	int parent_id;
 
 	if (!memcg_kmem_is_active(memcg))
 		return;
 
+	/*
+	 * Clear the slots corresponding to this cgroup in all root caches'
+	 * memcg_params->memcg_caches arrays. If a cache is empty, remove it.
+	 */
 	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		struct kmem_cache *cachep = params->cachep;
+		struct kmem_cache *root_cache = params->root_cache;
+
+		BUG_ON(cache_from_memcg_idx(root_cache, id) != cachep);
+		cache_install_at_memcg_idx(root_cache, id, NULL);
 
 		kmem_cache_shrink(cachep);
 		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
 			memcg_unregister_cache(cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
+
+	/*
+	 * Change kmemcg_id of this cgroup and all its descendants (which are
+	 * already dead) to the parent cgroup's id.
+	 */
+	parent = parent_mem_cgroup(memcg);
+	if (parent && !mem_cgroup_is_root(parent)) {
+		BUG_ON(!memcg_kmem_is_active(parent));
+		parent_id = parent->kmemcg_id;
+	} else
+		parent_id = -1;
+
+	/* Safe, because we are holding the cgroup_mutex */
+	css_for_each_descendant_post(iter, &memcg->css)
+		mem_cgroup_from_css(iter)->kmemcg_id = parent_id;
+
+	/* The id is not used anymore, free it so that it could be reused. */
+	memcg_free_cache_id(id);
 }
 
 struct memcg_register_cache_work {
@@ -3204,6 +3243,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
+	int id;
 
 	VM_BUG_ON(!cachep->memcg_params);
 	VM_BUG_ON(!cachep->memcg_params->is_root_cache);
@@ -3217,7 +3257,15 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	if (!memcg_can_account_kmem(memcg))
 		goto out;
 
-	memcg_cachep = cache_from_memcg_idx(cachep, memcg_cache_id(memcg));
+	id = memcg_cache_id(memcg);
+	/*
+	 * This might happen if current was migrated to another cgroup and this
+	 * cgroup was taken offline after we issued mem_cgroup_from_task above.
+	 */
+	if (unlikely(id < 0))
+		goto out;
+
+	memcg_cachep = cache_from_memcg_idx(cachep, id);
 	if (likely(memcg_cachep)) {
 		cachep = memcg_cachep;
 		goto out;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
