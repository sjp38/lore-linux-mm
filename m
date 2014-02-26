Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id C7F9E6B00B1
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:05:43 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id s7so718528lbd.29
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:05:43 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id w9si1818141laj.103.2014.02.26.07.05.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 07:05:42 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 11/12] memcg: reparent slab on css offline
Date: Wed, 26 Feb 2014 19:05:16 +0400
Message-ID: <20e062a78ca90aac93ea108bae074e49f37e9b52.1393423762.git.vdavydov@parallels.com>
In-Reply-To: <cover.1393423762.git.vdavydov@parallels.com>
References: <cover.1393423762.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Currently we take a css reference per each memcg cache. This is simple,
but extremely ugly - a memcg will hang around after its death until it
has any charges. Moreover, there are some clashes with the design
principles the cgroup subsystems implies.

However, there is nothing that prevents us from reparenting kmem charges
just like we do with user pages. Moreover, it is much easier to
implement: we already keep all memcg caches on a list, so all we have to
do is walk over the list and move the caches to the parent cgroup's list
changing the memcg ptr in the meanwhile. If somebody frees an object to
a cache being reparented, he might see a pointer to the old memcg, but
that's OK, we only need to use RCU to protect against use-after-free.
Let's just do it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
---
 mm/memcontrol.c |  306 ++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 189 insertions(+), 117 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index dad455a911d5..05bde78e14f0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -383,11 +383,20 @@ struct mem_cgroup {
 /* internal only representation about the status of kmem accounting. */
 enum {
 	KMEM_ACCOUNTED_ACTIVE, /* accounted by this cgroup itself */
-	KMEM_ACCOUNTED_DEAD, /* dead memcg with pending kmem charges */
+	KMEM_ACCOUNTED_REPARENTED, /* has reparented caches */
 };
 
 #ifdef CONFIG_MEMCG_KMEM
-static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
+/*
+ * mem_cgroup::slab_caches_mutex nesting subclasses:
+ */
+enum memcg_slab_mutex_class
+{
+	MEMCG_SLAB_MUTEX_PARENT,
+	MEMCG_SLAB_MUTEX_CHILD,
+};
+
+static void memcg_kmem_set_active(struct mem_cgroup *memcg)
 {
 	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
@@ -397,21 +406,14 @@ static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
 
-static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
+static void memcg_kmem_set_reparented(struct mem_cgroup *memcg)
 {
-	/*
-	 * Our caller must use css_get() first, because memcg_uncharge_kmem()
-	 * will call css_put() if it sees the memcg is dead.
-	 */
-	smp_wmb();
-	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags))
-		set_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_account_flags);
+	set_bit(KMEM_ACCOUNTED_REPARENTED, &memcg->kmem_account_flags);
 }
 
-static bool memcg_kmem_test_and_clear_dead(struct mem_cgroup *memcg)
+static bool memcg_kmem_is_reparented(struct mem_cgroup *memcg)
 {
-	return test_and_clear_bit(KMEM_ACCOUNTED_DEAD,
-				  &memcg->kmem_account_flags);
+	return test_bit(KMEM_ACCOUNTED_REPARENTED, &memcg->kmem_account_flags);
 }
 #endif
 
@@ -656,11 +658,6 @@ static void disarm_kmem_keys(struct mem_cgroup *memcg)
 		static_key_slow_dec(&memcg_kmem_enabled_key);
 		ida_simple_remove(&kmem_limited_groups, memcg->kmemcg_id);
 	}
-	/*
-	 * This check can't live in kmem destruction function,
-	 * since the charges will outlive the cgroup
-	 */
-	WARN_ON(res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0);
 }
 #else
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
@@ -3040,36 +3037,48 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 	res_counter_uncharge(&memcg->res, size);
 	if (do_swap_account)
 		res_counter_uncharge(&memcg->memsw, size);
+	res_counter_uncharge(&memcg->kmem, size);
+}
 
-	/* Not down to 0 */
-	if (res_counter_uncharge(&memcg->kmem, size))
-		return;
+static struct mem_cgroup *try_get_mem_cgroup_from_slab(struct kmem_cache *s)
+{
+	struct mem_cgroup *memcg;
 
-	/*
-	 * Releases a reference taken in kmem_cgroup_css_offline in case
-	 * this last uncharge is racing with the offlining code or it is
-	 * outliving the memcg existence.
-	 *
-	 * The memory barrier imposed by test&clear is paired with the
-	 * explicit one in memcg_kmem_mark_dead().
-	 */
-	if (memcg_kmem_test_and_clear_dead(memcg))
-		css_put(&memcg->css);
+	if (is_root_cache(s))
+		return NULL;
+
+	rcu_read_lock();
+	do {
+		memcg = s->memcg_params->memcg;
+		if (!memcg)
+			break;
+	} while (!css_tryget(&memcg->css));
+	rcu_read_unlock();
+	return memcg;
 }
 
 int __memcg_kmem_charge_slab(struct kmem_cache *s, gfp_t gfp, int nr_pages)
 {
-	if (is_root_cache(s))
-		return 0;
-	return memcg_charge_kmem(s->memcg_params->memcg,
-				 gfp, nr_pages << PAGE_SHIFT);
+	struct mem_cgroup *memcg;
+	int ret = 0;
+
+	memcg = try_get_mem_cgroup_from_slab(s);
+	if (memcg) {
+		ret = memcg_charge_kmem(memcg, gfp, nr_pages << PAGE_SHIFT);
+		css_put(&memcg->css);
+	}
+	return ret;
 }
 
 void __memcg_kmem_uncharge_slab(struct kmem_cache *s, int nr_pages)
 {
-	if (is_root_cache(s))
-		return;
-	memcg_uncharge_kmem(s->memcg_params->memcg, nr_pages << PAGE_SHIFT);
+	struct mem_cgroup *memcg;
+
+	memcg = try_get_mem_cgroup_from_slab(s);
+	if (memcg) {
+		memcg_uncharge_kmem(memcg, nr_pages << PAGE_SHIFT);
+		css_put(&memcg->css);
+	}
 }
 
 /*
@@ -3214,7 +3223,6 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 		INIT_WORK(&s->memcg_params->destroy,
 				kmem_cache_destroy_work_func);
 		atomic_set(&s->memcg_params->refcount, 1);
-		css_get(&memcg->css);
 	} else {
 		s->memcg_params->is_root_cache = true;
 		INIT_LIST_HEAD(&s->memcg_params->children);
@@ -3225,19 +3233,36 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 
 void memcg_free_cache_params(struct kmem_cache *s)
 {
-	if (!s->memcg_params)
-		return;
-	if (!s->memcg_params->is_root_cache)
-		css_put(&s->memcg_params->memcg->css);
 	kfree(s->memcg_params);
 }
 
-void memcg_register_cache(struct kmem_cache *s)
+static void __memcg_register_cache(struct kmem_cache *s, struct kmem_cache *root)
 {
-	struct kmem_cache *root;
 	struct mem_cgroup *memcg;
 	int id;
 
+	memcg = s->memcg_params->memcg;
+	/*
+	 * Special case: re-registering the cache on __kmem_cache_shutdown()
+	 * failure (see __kmem_cache_destroy()).
+	 */
+	if (!memcg)
+		return;
+
+	id = memcg_cache_id(memcg);
+	BUG_ON(id < 0);
+
+	mutex_lock(&memcg->slab_caches_mutex);
+	BUG_ON(root->memcg_params->memcg_caches[id]);
+	root->memcg_params->memcg_caches[id] = s;
+	list_add(&s->memcg_params->list, &memcg->memcg_slab_caches);
+	mutex_unlock(&memcg->slab_caches_mutex);
+}
+
+void memcg_register_cache(struct kmem_cache *s)
+{
+	struct kmem_cache *root;
+
 	if (is_root_cache(s))
 		return;
 
@@ -3247,10 +3272,6 @@ void memcg_register_cache(struct kmem_cache *s)
 	 */
 	lockdep_assert_held(&slab_mutex);
 
-	root = s->memcg_params->root_cache;
-	memcg = s->memcg_params->memcg;
-	id = memcg_cache_id(memcg);
-
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
 	 * barrier here to ensure nobody will see the kmem_cache partially
@@ -3258,21 +3279,61 @@ void memcg_register_cache(struct kmem_cache *s)
 	 */
 	smp_wmb();
 
+	root = s->memcg_params->root_cache;
 	list_add(&s->memcg_params->siblings, &root->memcg_params->children);
+	__memcg_register_cache(s, root);
 
-	VM_BUG_ON(root->memcg_params->memcg_caches[id]);
-	root->memcg_params->memcg_caches[id] = s;
+	static_key_slow_inc(&memcg_kmem_enabled_key);
+}
+
+static void __memcg_unregister_cache(struct kmem_cache *s, struct kmem_cache *root)
+{
+	struct mem_cgroup *memcg;
+	int id;
+
+retry:
+	memcg = try_get_mem_cgroup_from_slab(s);
+
+	/*
+	 * This can happen if the cache's memcg was turned offline and it was
+	 * reparented to the root cgroup. In this case the cache must have
+	 * already been properly unregistered so we have nothing to do.
+	 */
+	if (!memcg)
+		return;
 
+	id = memcg_cache_id(memcg);
+
+	/*
+	 * To delete a cache from memcg_slab_caches list, we need to take the
+	 * correpsonding slab_caches_mutex. Since nothing prevents the cache
+	 * from being reparented while we are here, we recheck the cache's
+	 * memcg after taking the mutex and retry if it changed.
+	 */
 	mutex_lock(&memcg->slab_caches_mutex);
-	list_add(&s->memcg_params->list, &memcg->memcg_slab_caches);
+	if (memcg != s->memcg_params->memcg) {
+		mutex_unlock(&memcg->slab_caches_mutex);
+		css_put(&memcg->css);
+		goto retry;
+	}
+
+	list_del(&s->memcg_params->list);
+	s->memcg_params->memcg = NULL;
+
+	/*
+	 * Clear the slot in the memcg_caches array only if the cache hasn't
+	 * been reparented before.
+	 */
+	if (id >= 0 && root->memcg_params->memcg_caches[id] == s)
+		root->memcg_params->memcg_caches[id] = NULL;
+
 	mutex_unlock(&memcg->slab_caches_mutex);
+	css_put(&memcg->css);
 }
 
 void memcg_unregister_cache(struct kmem_cache *s)
 {
 	struct kmem_cache *root;
-	struct mem_cgroup *memcg;
-	int id;
 
 	if (is_root_cache(s))
 		return;
@@ -3284,17 +3345,10 @@ void memcg_unregister_cache(struct kmem_cache *s)
 	lockdep_assert_held(&slab_mutex);
 
 	root = s->memcg_params->root_cache;
-	memcg = s->memcg_params->memcg;
-	id = memcg_cache_id(memcg);
-
 	list_del(&s->memcg_params->siblings);
+	__memcg_unregister_cache(s, root);
 
-	mutex_lock(&memcg->slab_caches_mutex);
-	list_del(&s->memcg_params->list);
-	mutex_unlock(&memcg->slab_caches_mutex);
-
-	VM_BUG_ON(root->memcg_params->memcg_caches[id] != s);
-	root->memcg_params->memcg_caches[id] = NULL;
+	static_key_slow_dec(&memcg_kmem_enabled_key);
 }
 
 /*
@@ -3338,7 +3392,7 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 
 	if (atomic_read(&params->refcount) != 0) {
 		/*
-		 * We were scheduled from mem_cgroup_destroy_all_caches().
+		 * We were scheduled from mem_cgroup_reparent_slab().
 		 * Shrink the cache and drop the reference taken by memcg.
 		 */
 		kmem_cache_shrink(cachep);
@@ -3381,11 +3435,56 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	mutex_unlock(&activate_kmem_mutex);
 }
 
-static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
+static void mem_cgroup_reparent_one_slab(struct kmem_cache *cachep,
+		struct mem_cgroup *from, struct mem_cgroup *to)
 {
+	struct kmem_cache *root;
+	int id;
+
+	root = cachep->memcg_params->root_cache;
+
+	if (to)
+		list_move(&cachep->memcg_params->list, &to->memcg_slab_caches);
+	else
+		list_del(&cachep->memcg_params->list);
+
+	BUG_ON(cachep->memcg_params->memcg != from);
+	cachep->memcg_params->memcg = to;
+
+	/*
+	 * We may access the cachep->memcg_params->memcg ptr lock-free so we
+	 * have to make sure readers will see the new value before the final
+	 * css put.
+	 */
+	smp_wmb();
+
+	/*
+	 * If the cache has already been reparented we are done here. Otherwise
+	 * we clear the reference to it in the memcg_caches array and schedule
+	 * shrink work.
+	 */
+	id = memcg_cache_id(from);
+	if (id < 0 || root->memcg_params->memcg_caches[id] != cachep)
+		return;
+
+	root->memcg_params->memcg_caches[id] = NULL;
+
+	/*
+	 * The work could not be scheduled from memcg_release_pages(), because
+	 * we haven't dropped cachep->memcg_params->refcount yet. That's why we
+	 * cannot fail here.
+	 */
+	if (!schedule_work(&cachep->memcg_params->destroy))
+		BUG();
+}
+
+static void mem_cgroup_reparent_slab(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *parent;
 	struct memcg_cache_params *params;
 
-	if (!memcg_kmem_is_active(memcg))
+	if (!memcg_kmem_is_active(memcg) &&
+	    !memcg_kmem_is_reparented(memcg))
 		return;
 
 	/*
@@ -3397,17 +3496,30 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 	 */
 	flush_workqueue(memcg_cache_create_wq);
 
-	mutex_lock(&memcg->slab_caches_mutex);
-	list_for_each_entry(params, &memcg->memcg_slab_caches, list) {
-		/*
-		 * Since we still hold the reference to the cache params from
-		 * the memcg, the work could not have been scheduled from
-		 * memcg_release_pages(), and this cannot fail.
-		 */
-		if (!schedule_work(&params->destroy))
-			BUG();
+	/*
+	 * We are going to modify memcg_caches arrays, so we have to protect
+	 * them against relocating.
+	 */
+	mutex_lock(&activate_kmem_mutex);
+
+	parent = parent_mem_cgroup(memcg);
+	if (parent)
+		mutex_lock_nested(&parent->slab_caches_mutex,
+				  MEMCG_SLAB_MUTEX_PARENT);
+	mutex_lock_nested(&memcg->slab_caches_mutex, MEMCG_SLAB_MUTEX_CHILD);
+	while (!list_empty(&memcg->memcg_slab_caches)) {
+		params = list_first_entry(&memcg->memcg_slab_caches,
+					  struct memcg_cache_params, list);
+		mem_cgroup_reparent_one_slab(params->cachep, memcg, parent);
 	}
 	mutex_unlock(&memcg->slab_caches_mutex);
+	if (parent)
+		mutex_unlock(&parent->slab_caches_mutex);
+
+	mutex_unlock(&activate_kmem_mutex);
+
+	if (parent)
+		memcg_kmem_set_reparented(parent);
 }
 
 struct create_work {
@@ -3538,7 +3650,7 @@ static void __init memcg_kmem_init(void)
 	BUG_ON(!memcg_cache_create_wq);
 }
 #else
-static inline void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
+static void mem_cgroup_reparent_slab(struct mem_cgroup *memcg)
 {
 }
 
@@ -5752,40 +5864,6 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
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
-	 * css_offline() when the referencemight have dropped down to 0
-	 * and shouldn't be incremented anymore (css_tryget would fail)
-	 * we do not have other options because of the kmem allocations
-	 * lifetime.
-	 */
-	css_get(&memcg->css);
-
-	memcg_kmem_mark_dead(memcg);
-
-	if (res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0)
-		return;
-
-	if (memcg_kmem_test_and_clear_dead(memcg))
-		css_put(&memcg->css);
-}
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
@@ -5795,10 +5873,6 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 }
-
-static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
-{
-}
 #endif
 
 /*
@@ -6406,8 +6480,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
-	kmem_cgroup_css_offline(memcg);
-
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 
 	/*
@@ -6417,7 +6489,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	css_for_each_descendant_post(iter, css)
 		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
 
-	mem_cgroup_destroy_all_caches(memcg);
+	mem_cgroup_reparent_slab(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
