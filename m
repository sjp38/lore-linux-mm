Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 67C136B0055
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 07:47:42 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so8924327pdj.8
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 04:47:42 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rc15si7014782pdb.233.2014.07.21.04.47.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 04:47:40 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 6/6] memcg: release memcg_cache_id on css offline
Date: Mon, 21 Jul 2014 15:47:16 +0400
Message-ID: <f6e8486422992239e76b0e7a8ee6880194d92d1c.1405941342.git.vdavydov@parallels.com>
In-Reply-To: <cover.1405941342.git.vdavydov@parallels.com>
References: <cover.1405941342.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The memcg_cache_id (mem_cgroup->kmemcg_id) is used as the index in root
cache's memcg_cache_params->memcg_caches array. Whenever a new kmem
active cgroup is created we must allocate an id for it. As a result, the
array size must always be greater than or equal to the number of memory
cgroups that have memcg_cache_id assigned to them.

Currently we release the id only on css free. This is bad, because css
can be zombieing around for quite a long time after css offline,
occupying an array slot and making the arrays grow larger and larger.
Although the number of arrays is limited - only root kmem caches have
them - we can still experience problems while creating new kmem active
cgroups, because they might require arrays relocation and each array
relocation will require costly high-order page allocations if there are
a lot of ids allocated. The situation will become even worse when
per-memcg list_lru's are introduced, because each super block has a
list_lru, and the number of super blocks is practically unlimited.

So let's release memcg_cache_id on css offline - there's nothing that
prevents us from doing so.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   42 ++++++++++++++++++++++++++++++++++++------
 1 file changed, 36 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3ee37189e57e..edd951e1e185 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -648,10 +648,8 @@ EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
 {
-	if (memcg_kmem_is_active(memcg)) {
+	if (memcg_kmem_is_active(memcg))
 		static_key_slow_dec(&memcg_kmem_enabled_key);
-		ida_simple_remove(&kmem_limited_groups, memcg->kmemcg_id);
-	}
 	/*
 	 * This check can't live in kmem destruction function,
 	 * since the charges will outlive the cgroup
@@ -3003,6 +3001,12 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 	lockdep_assert_held(&memcg_slab_mutex);
 
 	id = memcg_cache_id(memcg);
+	/*
+	 * The cgroup was taken offline while the create work was pending,
+	 * nothing to do then.
+	 */
+	if (id < 0)
+		return;
 
 	/*
 	 * Since per-memcg caches are created asynchronously on first
@@ -3057,8 +3061,17 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	memcg = cachep->memcg_params->memcg;
 	id = memcg_cache_id(memcg);
 
-	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
-	root_cache->memcg_params->memcg_caches[id] = NULL;
+	/*
+	 * This function can be called both after and before css offline. If
+	 * it's called before css offline, which happens on the root cache
+	 * destruction, we should clear the slot corresponding to the cache in
+	 * memcg_caches array. Otherwise the slot must have already been
+	 * cleared in memcg_unregister_all_caches.
+	 */
+	if (id >= 0) {
+		BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
+		root_cache->memcg_params->memcg_caches[id] = NULL;
+	}
 
 	list_del(&cachep->memcg_params->list);
 
@@ -3110,19 +3123,27 @@ void __memcg_cleanup_cache_params(struct kmem_cache *s)
 static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
 	struct memcg_cache_params *params, *tmp;
+	int id = memcg_cache_id(memcg);
 
 	if (!memcg_kmem_is_active(memcg))
 		return;
 
 	mutex_lock(&memcg_slab_mutex);
+	memcg->kmemcg_id = -1;
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		struct kmem_cache *cachep = params->cachep;
+		struct kmem_cache *root_cache = params->root_cache;
+
+		BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
+		root_cache->memcg_params->memcg_caches[id] = NULL;
 
 		kmem_cache_shrink(cachep);
 		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
 			memcg_unregister_cache(cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
+
+	ida_simple_remove(&kmem_limited_groups, id);
 }
 
 struct memcg_register_cache_work {
@@ -3221,6 +3242,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
+	int id;
 
 	VM_BUG_ON(!cachep->memcg_params);
 	VM_BUG_ON(!cachep->memcg_params->is_root_cache);
@@ -3234,7 +3256,15 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	if (!memcg_can_account_kmem(memcg))
 		goto out;
 
-	memcg_cachep = cache_from_memcg_idx(cachep, memcg_cache_id(memcg));
+	id = memcg_cache_id(memcg);
+	/*
+	 * This can happen if current was migrated to another cgroup and this
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
