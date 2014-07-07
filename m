Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 38129900002
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 08:00:45 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id pn19so2818814lab.1
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 05:00:44 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id du4si1577823lac.17.2014.07.07.05.00.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 05:00:44 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 8/8] memcg: reparent kmem context on memcg offline
Date: Mon, 7 Jul 2014 16:00:13 +0400
Message-ID: <b7d676cd8a4995e921c2e17d6d39b47f9cc61380.1404733721.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404733720.git.vdavydov@parallels.com>
References: <cover.1404733720.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, mem_cgroup_kmem_context holds a reference to the owner memcg,
so a memcg will be hanging around after offline until the last kmem
object charged to it is freed. This is bad, because the mem_cgroup
struct is huge, and we actually don't need most of its fields to
uncharge kmem after css offline.

This patch introduces kmem charges reparenting. The implementation is
tivial: we simply make mem_cgroup_kmem_context point to the parent memcg
when its owner is taken offline. Ongoing kmem uncharges can still go to
the old mem cgroup for some time, but by the time css free is called all
kmem uncharges paths must have been switched to the parent memcg.

Note the difference between mem/memsw charges reparenting, where we walk
over all charged pages and fix their page cgroups, and kmem reparenting,
where we only switch memcg pointer in kmem context. As a result, if
everything goes right, on css free we will have mem res counter usage
equal to 0, but kmem res counter usage can still be positive, because we
don't uncharge kmem from the dead memcg. In this regard, kmem
reparenting doesn't look like "real" reparenting - we don't actually
move charges and we don't release kmem context (and kmem cache) until
the last object is released. However, introducing "real" kmem
reparenting would require tracking of all charged pages, which is not
done currently (slub doesn't track full slabs; pages allocated with
alloc_kmem_pages aren't tracked), and changing this would impact
performance. So we prefer to go with re-parenting of kmem contexts
instead of dealing with individual charges - fortunately kmem context
struct is tiny and having it pending after memcg death is no big deal.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |  161 +++++++++++++++++++++++++++++++++----------------------
 1 file changed, 96 insertions(+), 65 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 21cf15184ad8..e2f8dd669063 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -269,17 +269,29 @@ struct mem_cgroup_event {
 };
 
 struct mem_cgroup_kmem_context {
-	struct mem_cgroup *memcg;
+	/*
+	 * the memcg pointer is updated on css offline under memcg_slab_mutex,
+	 * so it is safe to access it inside an RCU critical section or with
+	 * the memcg_slab_mutex held
+	 */
+	struct mem_cgroup __rcu *memcg;
 	atomic_long_t refcnt;
 	/*
 	 * true if accounting is enabled
 	 */
 	bool active;
 	/*
+	 * list of contexts re-parented to the memcg; protected by
+	 * memcg_slab_mutex
+	 */
+	struct list_head list;
+	/*
 	 * analogous to slab_common's slab_caches list, but per-memcg;
 	 * protected by memcg_slab_mutex
 	 */
 	struct list_head slab_caches;
+
+	struct work_struct destroy_work;
 };
 
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
@@ -447,10 +459,11 @@ memcg_get_kmem_context(struct mem_cgroup *memcg)
 static inline void memcg_put_kmem_context(struct mem_cgroup_kmem_context *ctx)
 {
 	if (unlikely(atomic_long_dec_and_test(&ctx->refcnt)))
-		css_put(&ctx->memcg->css);	/* drop the reference taken in
-						 * kmem_cgroup_css_offline */
+		schedule_work(&ctx->destroy_work);
 }
 
+static void memcg_kmem_context_destroy_func(struct work_struct *work);
+
 static int memcg_alloc_kmem_context(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup_kmem_context *ctx;
@@ -462,7 +475,9 @@ static int memcg_alloc_kmem_context(struct mem_cgroup *memcg)
 	ctx->memcg = memcg;
 	atomic_long_set(&ctx->refcnt, 1);
 	ctx->active = false;
+	INIT_LIST_HEAD(&ctx->list);
 	INIT_LIST_HEAD(&ctx->slab_caches);
+	INIT_WORK(&ctx->destroy_work, memcg_kmem_context_destroy_func);
 
 	memcg->kmem_ctx = ctx;
 	return 0;
@@ -470,20 +485,9 @@ static int memcg_alloc_kmem_context(struct mem_cgroup *memcg)
 
 static void memcg_release_kmem_context(struct mem_cgroup *memcg)
 {
-	kfree(memcg->kmem_ctx);
-}
-
-static void disarm_kmem_keys(struct mem_cgroup *memcg)
-{
-	if (memcg_kmem_is_active(memcg)) {
-		static_key_slow_dec(&memcg_kmem_enabled_key);
+	if (memcg_kmem_is_active(memcg))
 		ida_simple_remove(&kmem_limited_groups, memcg->kmemcg_id);
-	}
-	/*
-	 * This check can't live in kmem destruction function,
-	 * since the charges will outlive the cgroup
-	 */
-	WARN_ON(res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0);
+	memcg_put_kmem_context(memcg->kmem_ctx);
 }
 #else
 static int memcg_alloc_kmem_context(struct mem_cgroup *memcg)
@@ -494,10 +498,6 @@ static int memcg_alloc_kmem_context(struct mem_cgroup *memcg)
 static void memcg_release_kmem_context(struct mem_cgroup *memcg)
 {
 }
-
-static void disarm_kmem_keys(struct mem_cgroup *memcg)
-{
-}
 #endif /* CONFIG_MEMCG_KMEM */
 
 /* Stuffs for move charges at task migration. */
@@ -692,12 +692,6 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
 }
 #endif
 
-static void disarm_static_keys(struct mem_cgroup *memcg)
-{
-	disarm_sock_keys(memcg);
-	disarm_kmem_keys(memcg);
-}
-
 static void drain_all_stock_async(struct mem_cgroup *memcg);
 
 static struct mem_cgroup_per_zone *
@@ -2809,6 +2803,25 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 		memcg_kmem_is_active(memcg);
 }
 
+static void memcg_kmem_context_destroy_func(struct work_struct *work)
+{
+	struct mem_cgroup_kmem_context *ctx = container_of(work,
+			struct mem_cgroup_kmem_context, destroy_work);
+
+	if (ctx->active)
+		static_key_slow_dec(&memcg_kmem_enabled_key);
+
+	mutex_lock(&memcg_slab_mutex);
+	BUG_ON(!list_empty(&ctx->slab_caches));
+	if (!list_empty(&ctx->list)) {
+		BUG_ON(ctx->memcg->kmem_ctx == ctx);
+		list_del(&ctx->list);
+	}
+	mutex_unlock(&memcg_slab_mutex);
+
+	kfree(ctx);
+}
+
 #ifdef CONFIG_SLABINFO
 static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 {
@@ -3067,8 +3080,14 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	memcg = cachep->memcg_params->ctx->memcg;
 	id = memcg_cache_id(memcg);
 
-	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
-	root_cache->memcg_params->memcg_caches[id] = NULL;
+	/*
+	 * If the cache being unregistered is active (i.e. its initial owner is
+	 * alive), we have to clear its slot in the root cache's array.
+	 * Otherwise, the slot has already been cleared by
+	 * memcg_unregister_all_caches.
+	 */
+	if (root_cache->memcg_params->memcg_caches[id] == cachep)
+		root_cache->memcg_params->memcg_caches[id] = NULL;
 
 	list_del(&cachep->memcg_params->list);
 
@@ -3139,6 +3158,7 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
 	struct memcg_cache_params *params, *tmp;
 	LIST_HEAD(empty_caches);
+	int id = memcg_cache_id(memcg);
 
 	if (!memcg_kmem_is_active(memcg))
 		return;
@@ -3147,10 +3167,14 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 	list_for_each_entry_safe(params, tmp,
 				 &memcg->kmem_ctx->slab_caches, list) {
 		struct kmem_cache *cachep = params->cachep;
+		struct kmem_cache *root_cache = params->root_cache;
 
 		memcg_cache_mark_dead(cachep);
 		kmem_cache_shrink(cachep);
 
+		BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
+		root_cache->memcg_params->memcg_caches[id] = NULL;
+
 		if (atomic_long_dec_and_test(&cachep->memcg_params->refcnt))
 			list_move(&cachep->memcg_params->list, &empty_caches);
 	}
@@ -3239,18 +3263,28 @@ static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 {
 	int res;
+	struct mem_cgroup *memcg;
+
+	rcu_read_lock();
+	do {
+		memcg = cachep->memcg_params->ctx->memcg;
+	} while (!css_tryget(&memcg->css));
+	rcu_read_unlock();
 
-	res = memcg_charge_kmem(cachep->memcg_params->ctx->memcg, gfp,
-				PAGE_SIZE << order);
+	res = memcg_charge_kmem(memcg, gfp, PAGE_SIZE << order);
 	if (!res)
 		atomic_long_inc(&cachep->memcg_params->refcnt);
+
+	css_put(&memcg->css);
 	return res;
 }
 
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 {
+	rcu_read_lock();
 	memcg_uncharge_kmem(cachep->memcg_params->ctx->memcg,
 			    PAGE_SIZE << order);
+	rcu_read_unlock();
 
 	if (unlikely(atomic_long_dec_and_test(&cachep->memcg_params->refcnt)))
 		/* see memcg_unregister_all_caches */
@@ -3369,13 +3403,43 @@ int __memcg_charge_kmem_pages(gfp_t gfp, int order,
 
 void __memcg_uncharge_kmem_pages(struct mem_cgroup_kmem_context *ctx, int order)
 {
+	rcu_read_lock();
 	memcg_uncharge_kmem(ctx->memcg, PAGE_SIZE << order);
+	rcu_read_unlock();
+
 	memcg_put_kmem_context(ctx);
 }
+
+static inline void memcg_reparent_kmem(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
+	struct mem_cgroup_kmem_context *ctx = memcg->kmem_ctx;
+	struct mem_cgroup_kmem_context *p;
+
+	mutex_lock(&memcg_slab_mutex);
+
+	/* first reparent all ctxs that were reparented to this ctx earlier */
+	list_for_each_entry(p, &ctx->list, list) {
+		BUG_ON(p->memcg != memcg);
+		p->memcg = parent;
+	}
+	list_splice(&ctx->list, &parent->kmem_ctx->list);
+
+	/* now reparent this ctx itself */
+	BUG_ON(ctx->memcg != memcg);
+	ctx->memcg = parent;
+	list_add(&ctx->list, &parent->kmem_ctx->list);
+
+	mutex_unlock(&memcg_slab_mutex);
+}
 #else
 static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 {
 }
+
+static inline void memcg_reparent_kmem(struct mem_cgroup *memcg)
+{
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -4947,34 +5011,6 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 	mem_cgroup_sockets_destroy(memcg);
 }
-
-static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
-{
-	if (!memcg_kmem_is_active(memcg))
-		return;
-
-	/*
-	 * kmem charges can outlive the cgroup. In the case of slab
-	 * pages, for instance, a page contain objects from various
-	 * processes. As we prevent from taking a reference for every
-	 * such allocation we have to be careful when doing uncharge
-	 * (see memcg_uncharge_kmem) and here during offlining.
-	 *
-	 * The idea is that that only the _last_ uncharge which sees
-	 * the dead memcg will drop the last reference. An additional
-	 * reference is taken here before the group is marked dead
-	 * which is then paired with css_put during uncharge resp. here.
-	 *
-	 * Although this might sound strange as this path is called from
-	 * css_offline() when the referencemight have dropped down to 0 and
-	 * shouldn't be incremented anymore (css_tryget_online() would
-	 * fail) we do not have other options because of the kmem
-	 * allocations lifetime.
-	 */
-	css_get(&memcg->css);
-
-	memcg_put_kmem_context(memcg->kmem_ctx);
-}
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
@@ -4984,10 +5020,6 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 }
-
-static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
-{
-}
 #endif
 
 /*
@@ -5442,7 +5474,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	 * to move this code around, and make sure it is outside
 	 * the cgroup_lock.
 	 */
-	disarm_static_keys(memcg);
+	disarm_sock_keys(memcg);
 
 	memcg_release_kmem_context(memcg);
 	kfree(memcg);
@@ -5604,8 +5636,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
-	kmem_cgroup_css_offline(memcg);
-
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 
 	/*
@@ -5616,6 +5646,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
 
 	memcg_unregister_all_caches(memcg);
+	memcg_reparent_kmem(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
