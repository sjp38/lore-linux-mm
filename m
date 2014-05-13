Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0246B003C
	for <linux-mm@kvack.org>; Tue, 13 May 2014 09:49:00 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id b8so291738lan.37
        for <linux-mm@kvack.org>; Tue, 13 May 2014 06:48:59 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id yp3si6254270lbb.16.2014.05.13.06.48.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 06:48:57 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg offline
Date: Tue, 13 May 2014 17:48:53 +0400
Message-ID: <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com>
In-Reply-To: <cover.1399982635.git.vdavydov@parallels.com>
References: <cover.1399982635.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

As there won't be any allocations from kmem caches that belong to a dead
memcg, it's better to move their slab pages to the parent cache on css
offline instead of having them hanging around for indefinite time and
bothering about reaping them periodically or on vmpressure.

A tricky thing about it is that there still may be free's to those
caches, so we should synchronize with them somehow. This is difficult,
because slub implementation is mostly lockless, and there is no magic
lock that can be used for this.

This patch solves this problem by switching all free's to dead caches to
the "slow" mode while we are migrating their slab pages. The "slow" mode
uses the PG_locked bit of the slab for synchronization. Under this lock
it just puts the object being freed to the page's freelist not bothering
about per cpu/node slab lists, which will be handled by the reparenting
procedure. This gives us a clear synchronization point between kfree's
and the reparenting procedure - it's the PG_locked bit spin lock, which
we take for both freeing an object and changing a slab's slab_cache ptr
on reparenting. Although the "slow" mode free is really slow, there
shouldn't be lot of them, because they can only happen while reparenting
is in progress, which shouldn't take long.

Since the "slow" and the "normal" free's can't coexist at the same time,
we must assure all conventional free's have finished before switching
all further free's to the "slow" mode and starting reparenting. To
achieve that, a percpu refcounter is used. It is taken and held during
each "normal" free. The refcounter is killed on memcg offline, and the
cache's pages migration is initiated from the refcounter's release
function. If we fail to take a ref on kfree, it means all "normal"
free's have been completed and the cache is being reparented right now,
so we should free the object using the "slow" mode.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    4 +-
 include/linux/slab.h       |    7 +-
 mm/memcontrol.c            |   54 +++++++-----
 mm/slab.h                  |    5 +-
 mm/slub.c                  |  208 +++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 246 insertions(+), 32 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index aa429de275cc..ce6bb47d59e5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -511,8 +511,8 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
-int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
-void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
+int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size);
+void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size);
 
 int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 86e5b26fbdab..ce2189ac4899 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -14,6 +14,8 @@
 #include <linux/gfp.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
+#include <linux/rcupdate.h>
+#include <linux/percpu-refcount.h>
 
 
 /*
@@ -526,7 +528,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
- * @nr_pages: number of pages that belongs to this cache.
  */
 struct memcg_cache_params {
 	bool is_root_cache;
@@ -539,7 +540,9 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
-			atomic_t nr_pages;
+
+			struct percpu_ref refcnt;
+			struct work_struct destroy_work;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f5ea266f4d9a..4156010ee5a1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2942,7 +2942,7 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 }
 #endif
 
-static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
+int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 {
 	struct res_counter *fail_res;
 	int ret = 0;
@@ -2980,7 +2980,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 	return ret;
 }
 
-static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
+void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 {
 	res_counter_uncharge(&memcg->res, size);
 	if (do_swap_account)
@@ -3090,9 +3090,12 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
+static void memcg_kmem_cache_release_func(struct percpu_ref *ref);
+
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache)
 {
+	int err;
 	size_t size;
 
 	if (!memcg_kmem_enabled())
@@ -3109,6 +3112,12 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 		return -ENOMEM;
 
 	if (memcg) {
+		err = percpu_ref_init(&s->memcg_params->refcnt,
+				      memcg_kmem_cache_release_func);
+		if (err) {
+			kfree(s->memcg_params);
+			return err;
+		}
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
 		css_get(&memcg->css);
@@ -3192,6 +3201,26 @@ static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
 	kmem_cache_destroy(cachep);
 }
 
+static void memcg_kmem_cache_destroy_func(struct work_struct *work)
+{
+	struct memcg_cache_params *params =
+		container_of(work, struct memcg_cache_params, destroy_work);
+	struct kmem_cache *cachep = memcg_params_to_cache(params);
+
+	mutex_lock(&memcg_slab_mutex);
+	memcg_kmem_destroy_cache(cachep);
+	mutex_unlock(&memcg_slab_mutex);
+}
+
+static void memcg_kmem_cache_release_func(struct percpu_ref *ref)
+{
+	struct memcg_cache_params *params =
+		container_of(ref, struct memcg_cache_params, refcnt);
+
+	INIT_WORK(&params->destroy_work, memcg_kmem_cache_destroy_func);
+	schedule_work(&params->destroy_work);
+}
+
 /*
  * During the creation a new cache, we need to disable our accounting mechanism
  * altogether. This is true even if we are not creating, but rather just
@@ -3254,9 +3283,7 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
-		kmem_cache_shrink(cachep);
-		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
-			memcg_kmem_destroy_cache(cachep);
+		percpu_ref_kill(&cachep->memcg_params->refcnt);
 	}
 	mutex_unlock(&memcg_slab_mutex);
 }
@@ -3321,23 +3348,6 @@ static void memcg_create_cache_enqueue(struct mem_cgroup *memcg,
 	memcg_resume_kmem_account();
 }
 
-int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
-{
-	int res;
-
-	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp,
-				PAGE_SIZE << order);
-	if (!res)
-		atomic_add(1 << order, &cachep->memcg_params->nr_pages);
-	return res;
-}
-
-void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
-{
-	memcg_uncharge_kmem(cachep->memcg_params->memcg, PAGE_SIZE << order);
-	atomic_sub(1 << order, &cachep->memcg_params->nr_pages);
-}
-
 /*
  * Return the kmem_cache we're supposed to use for a slab allocation.
  * We try to use the current memcg's version of the cache.
diff --git a/mm/slab.h b/mm/slab.h
index 0eca922ed7a0..c084935a1c29 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -186,7 +186,8 @@ static __always_inline int memcg_charge_slab(struct kmem_cache *s,
 		return 0;
 	if (is_root_cache(s))
 		return 0;
-	return __memcg_charge_slab(s, gfp, order);
+	return memcg_charge_kmem(s->memcg_params->memcg, gfp,
+				 PAGE_SIZE << order);
 }
 
 static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
@@ -195,7 +196,7 @@ static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
 		return;
 	if (is_root_cache(s))
 		return;
-	__memcg_uncharge_slab(s, order);
+	memcg_uncharge_kmem(s->memcg_params->memcg, PAGE_SIZE << order);
 }
 #else
 static inline bool is_root_cache(struct kmem_cache *s)
diff --git a/mm/slub.c b/mm/slub.c
index 6019c315a2f9..dfe7d3695a9e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2700,7 +2700,7 @@ slab_empty:
  * If fastpath is not possible then fall back to __slab_free where we deal
  * with all sorts of special processing.
  */
-static __always_inline void slab_free(struct kmem_cache *s,
+static __always_inline void do_slab_free(struct kmem_cache *s,
 			struct page *page, void *x, unsigned long addr)
 {
 	void **object = (void *)x;
@@ -2736,19 +2736,218 @@ redo:
 		stat(s, FREE_FASTPATH);
 	} else
 		__slab_free(s, page, x, addr);
+}
+
+#ifdef CONFIG_MEMCG_KMEM
+static __always_inline void slab_free(struct kmem_cache *s,
+			struct page *page, void *x, unsigned long addr)
+{
+	void **object = (void *)x;
+	unsigned long flags;
+
+	if (!memcg_kmem_enabled())
+		return do_slab_free(s, page, x, addr);
+
+retry:
+	/* page->slab_cache is RCU-protected */
+	rcu_read_lock_sched();
+
+	s = ACCESS_ONCE(page->slab_cache);
+	if (is_root_cache(s)) {
+		rcu_read_unlock_sched();
+		return do_slab_free(s, page, x, addr);
+	}
+
+	/*
+	 * Usual percpu_ref_tryget() will fail after percpu_ref_kill() is
+	 * called, even if refcnt != 0, which means there may be free's
+	 * operating in the "normal" mode in flight. To avoid races with them,
+	 * switch to the "slow" mode only if refcnt == 0.
+	 */
+	if (__percpu_ref_tryget(&s->memcg_params->refcnt, true)) {
+		rcu_read_unlock_sched();
+		do_slab_free(s, page, x, addr);
+		percpu_ref_put(&s->memcg_params->refcnt);
+		return;
+	}
+
+	/*
+	 * This is the "slow" mode, which locks the slab to avoid races with
+	 * slab_reparent(). Note, there is no need bothering about per cpu/node
+	 * list consistency, because this will be handled by slab_reparent().
+	 */
+	local_irq_save(flags);
+	slab_lock(page);
+
+	if (unlikely(s != page->slab_cache)) {
+		/* the slab was reparented while we were trying to lock it */
+		slab_unlock(page);
+		local_irq_restore(flags);
+		rcu_read_unlock_sched();
+		goto retry;
+	}
+
+	slab_free_hook(s, x);
+
+	set_freepointer(s, object, page->freelist);
+	page->freelist = object;
+	page->inuse--;
 
+	slab_unlock(page);
+	local_irq_restore(flags);
+	rcu_read_unlock_sched();
 }
+#else
+static __always_inline void slab_free(struct kmem_cache *s,
+			struct page *page, void *x, unsigned long addr)
+{
+	do_slab_free(s, page, x, addr);
+}
+#endif /* CONFIG_MEMCG_KMEM */
 
 void kmem_cache_free(struct kmem_cache *s, void *x)
 {
-	s = cache_from_obj(s, x);
-	if (!s)
-		return;
 	slab_free(s, virt_to_head_page(x), x, _RET_IP_);
 	trace_kmem_cache_free(_RET_IP_, x);
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
+#ifdef CONFIG_MEMCG_KMEM
+static void __slab_reparent(struct kmem_cache *from, struct kmem_cache *to,
+			    u64 *size)
+{
+	int node, cpu;
+	struct page *page;
+	LIST_HEAD(slabs);
+	LIST_HEAD(slabs_tofree);
+
+	*size = 0;
+
+	/*
+	 * All free's to the @from cache are now operating in the "slow" mode,
+	 * which means we only need to take the slab lock to safely modify per
+	 * slab data.
+	 */
+
+	for_each_possible_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(from->cpu_slab, cpu);
+
+		page = c->page;
+		if (page) {
+			void *lastfree = NULL, *freelist = c->freelist;
+			int nr_objects = 0;
+
+			/* drain per-cpu freelist */
+			while (freelist) {
+				nr_objects++;
+				lastfree = freelist;
+				freelist = get_freepointer(from, freelist);
+			}
+
+			if (lastfree) {
+				local_irq_disable();
+				slab_lock(page);
+
+				set_freepointer(from, lastfree, page->freelist);
+				page->freelist = c->freelist;
+				VM_BUG_ON(page->inuse < nr_objects);
+				page->inuse -= nr_objects;
+
+				slab_unlock(page);
+				local_irq_enable();
+			}
+
+			list_add(&page->lru, &slabs);
+			c->page = NULL;
+			c->freelist = NULL;
+		}
+
+		/* drain per-cpu list of partial slabs */
+		while ((page = c->partial) != NULL) {
+			c->partial = page->next;
+			list_add(&page->lru, &slabs);
+		}
+	}
+
+	for_each_node_state(node, N_POSSIBLE) {
+		struct kmem_cache_node *n = get_node(from, node);
+
+		if (!n)
+			continue;
+
+		list_splice_init(&n->partial, &slabs);
+		list_splice_init(&n->full, &slabs);
+		n->nr_partial = 0;
+
+#ifdef CONFIG_SLUB_DEBUG
+		atomic_long_set(&n->nr_slabs, 0);
+		atomic_long_set(&n->total_objects, 0);
+#endif
+	}
+
+	/* insert @from's slabs to the @to cache */
+	while (!list_empty(&slabs)) {
+		struct kmem_cache_node *n;
+
+		page = list_first_entry(&slabs, struct page, lru);
+		list_del(&page->lru);
+
+		node = page_to_nid(page);
+		n = get_node(to, node);
+		spin_lock_irq(&n->list_lock);
+
+		slab_lock(page);
+		page->frozen = 0;
+		if (!page->inuse) {
+			list_add(&page->lru, &slabs_tofree);
+		} else {
+			page->slab_cache = to;
+			inc_slabs_node(to, node, page->objects);
+			if (!page->freelist)
+				add_full(to, n, page);
+			else
+				add_partial(n, page, DEACTIVATE_TO_TAIL);
+			*size += PAGE_SIZE << compound_order(page);
+		}
+		slab_unlock(page);
+
+		spin_unlock_irq(&n->list_lock);
+	}
+
+	while (!list_empty(&slabs_tofree)) {
+		page = list_first_entry(&slabs_tofree, struct page, lru);
+		list_del(&page->lru);
+		free_slab(from, page);
+	}
+
+	/*
+	 * The @from cache can be safely destroyed now, because no free can see
+	 * the slab_cache == from after this point.
+	 */
+	synchronize_sched();
+}
+
+static void slab_reparent(struct kmem_cache *cachep)
+{
+	struct kmem_cache *root_cache;
+	struct mem_cgroup *memcg;
+	u64 size;
+
+	if (is_root_cache(cachep))
+		return;
+
+	root_cache = cachep->memcg_params->root_cache;
+	memcg = cachep->memcg_params->memcg;
+
+	__slab_reparent(cachep, root_cache, &size);
+	memcg_uncharge_kmem(memcg, size);
+}
+#else
+static void slab_reparent(struct kmem_cache *cachep)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
 /*
  * Object placement in a slab is made very easy because we always start at
  * offset 0. If we tune the size of the object to the alignment then we can
@@ -3275,6 +3474,7 @@ static inline int kmem_cache_close(struct kmem_cache *s)
 
 int __kmem_cache_shutdown(struct kmem_cache *s)
 {
+	slab_reparent(s);
 	return kmem_cache_close(s);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
