Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id D30E46B0037
	for <linux-mm@kvack.org>; Mon, 19 May 2014 11:24:56 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id s7so4210424lbd.0
        for <linux-mm@kvack.org>; Mon, 19 May 2014 08:24:55 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id am5si890338lac.2.2014.05.19.08.24.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 May 2014 08:24:54 -0700 (PDT)
Date: Mon, 19 May 2014 19:24:39 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
Message-ID: <20140519152437.GB25889@esperanza>
References: <cover.1399982635.git.vdavydov@parallels.com>
 <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405141119320.16512@gentwo.org>
 <20140515071650.GB32113@esperanza>
 <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
 <20140516132234.GF32113@esperanza>
 <alpine.DEB.2.10.1405160957100.32249@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405160957100.32249@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 16, 2014 at 10:03:22AM -0500, Christoph Lameter wrote:
> On Fri, 16 May 2014, Vladimir Davydov wrote:
> 
> > > Do we even know that all objects in that slab belong to a certain cgroup?
> > > AFAICT the fastpath currently do not allow to make that distinction.
> >
> > All allocations from a memcg's cache are accounted to the owner memcg,
> > so that all objects on the same slab belong to the same memcg, a pointer
> > to which can be obtained from the page->slab_cache->memcg_params. At
> > least, this is true since commit faebbfe10ec1 ("sl[au]b: charge slabs to
> > kmemcg explicitly").
> 
> I doubt that. The accounting occurs when a new cpu slab page is allocated.
> But the individual allocations in the fastpath are not accounted to a
> specific group. Thus allocation in a slab page can belong to various
> cgroups.

On each kmalloc, we pick the cache that belongs to the current memcg,
and allocate objects from that cache (see memcg_kmem_get_cache()). And
all slab pages allocated for a per memcg cache are accounted to the
memcg the cache belongs to (see memcg_charge_slab). So currently, each
kmem cache, i.e. each slab of it, can only have objects of one cgroup,
namely its owner.

> > > I wish you would find some other way to do this.
> >
> > The only practical alternative to re-parenting I see right now is
> > periodic reaping, but Johannes isn't very fond of it, and his opinion is
> > quite justified, because having caches that will never be allocated from
> > hanging around indefinitely, only because they have a couple of active
> > objects to be freed, doesn't look very good.
> 
> If all objects in the cache are in use then the slab page needs to hang
> around since the objects presence is required. You may not know exactly
> which cgroups these object belong to. The only thing that you may now (if
> you keep a list of full slabs) is which cgroup was in use then the
> slab page was initially allocated.
> 
> Isnt it sufficient to add a counter of full slabs to a cgroup? When you
> allocate a new slab page add to the counter. When an object in a slab page
> is freed and the slab page goes on a partial list decrement the counter.
> 
> That way you can avoid tracking full slabs.

The idea was to destroy all memcg's caches on css offline no matter
whether there are active objects on them or not. For that, we have to
migrate *all* slabs to the parent cache, which means, at least, changing
page->slab_cache ptr on them. For the latter, we have to walk through
all slabs (including full ones), which means we have to track them all.

Anyway, you said we shouldn't track full slabs, because it neglects
cpu-partial/frozen lists optimization. Actually, I agree with you at
this point: I did some testing and found that contended kfrees to the
same NUMA node on a 2-node machine are slowed down up to 25% due to full
slabs tracking - not an option obviously.

OK, it seems we have no choice but keeping dead caches left after memcg
offline until they have active slabs. How can we get rid of them then?
Simply counting slabs on cache and destroying cache when the count goes
to 0 isn't enough, because slub may keep some free slabs by default (if
they are frozen e.g.) Reaping them periodically doesn't look nice.

What if we modify __slab_free so that it won't keep empty slabs for dead
caches? That way we would only have to count slabs allocated to a cache,
and destroy caches as soon as the counter drops to 0. No
periodic/vmpressure reaping would be necessary. I attached the patch
that does the trick below. The changes it introduces to __slab_free do
not look very intrusive to me. Could you please take a look at it (to
diff slub.c primarily) when you have time, and say if, in your opinion,
the changes to __slab_free are acceptable or not?

Thank you.

--
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1d9abb7d22a0..9ad536a756ea 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -526,7 +526,8 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
- * @nr_pages: number of pages that belongs to this cache.
+ * @count: the ref count; the cache is destroyed as soon as it reaches 0
+ * @unregister_work: the cache destruction work
  */
 struct memcg_cache_params {
 	bool is_root_cache;
@@ -539,11 +540,32 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
-			atomic_t nr_pages;
+			atomic_t count;
+			struct work_struct unregister_work;
 		};
 	};
 };
 
+/*
+ * Each active slab increments the cache's memcg_params->count, and the owner
+ * memcg, while it's online, adds MEMCG_PARAMS_COUNT_BIAS to the count so that
+ * the cache is dead (i.e. belongs to a memcg that was turned offline) iff
+ * memcg_params->count < MEMCG_PARAMS_COUNT_BIAS.
+ */
+#define MEMCG_PARAMS_COUNT_BIAS		(1U << 31)
+
+/* Returns true if the cache belongs to a memcg that was turned offline. */
+static inline bool memcg_cache_dead(struct kmem_cache *s)
+{
+	bool ret = false;
+
+#ifdef CONFIG_MEMCG_KMEM
+	if (atomic_read(&s->memcg_params->count) < MEMCG_PARAMS_COUNT_BIAS)
+		ret = true;
+#endif
+	return ret;
+}
+
 int memcg_update_all_caches(int num_memcgs);
 
 struct seq_file;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0fb108e5b905..2b076f17eae7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3090,6 +3090,8 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
+static void memcg_unregister_cache_func(struct work_struct *w);
+
 int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 			     struct kmem_cache *root_cache)
 {
@@ -3111,6 +3113,9 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 	if (memcg) {
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
+		atomic_set(&s->memcg_params->count, MEMCG_PARAMS_COUNT_BIAS);
+		INIT_WORK(&s->memcg_params->unregister_work,
+			  memcg_unregister_cache_func);
 		css_get(&memcg->css);
 	} else
 		s->memcg_params->is_root_cache = true;
@@ -3192,6 +3197,17 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	kmem_cache_destroy(cachep);
 }
 
+static void memcg_unregister_cache_func(struct work_struct *w)
+{
+	struct memcg_cache_params *params =
+		container_of(w, struct memcg_cache_params, unregister_work);
+	struct kmem_cache *cachep = memcg_params_to_cache(params);
+
+	mutex_lock(&memcg_slab_mutex);
+	memcg_unregister_cache(cachep);
+	mutex_unlock(&memcg_slab_mutex);
+}
+
 /*
  * During the creation a new cache, we need to disable our accounting mechanism
  * altogether. This is true even if we are not creating, but rather just
@@ -3254,8 +3270,21 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
+
+		/* mark the cache as dead while still holding a ref to it */
+		atomic_sub(MEMCG_PARAMS_COUNT_BIAS - 1, &params->count);
+
+		/*
+		 * Make sure that all ongoing free's see the cache as dead and
+		 * won't do unnecessary slab caching (freezing in case of
+		 * slub, see comment to __slab_free).
+		 */
+		synchronize_sched();
+
 		kmem_cache_shrink(cachep);
-		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
+
+		/* if nobody except us uses the cache, destroy it immediately */
+		if (atomic_dec_and_test(&params->count))
 			memcg_unregister_cache(cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
@@ -3329,14 +3358,15 @@ int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp,
 				PAGE_SIZE << order);
 	if (!res)
-		atomic_add(1 << order, &cachep->memcg_params->nr_pages);
+		atomic_inc(&cachep->memcg_params->count);
 	return res;
 }
 
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 {
 	memcg_uncharge_kmem(cachep->memcg_params->memcg, PAGE_SIZE << order);
-	atomic_sub(1 << order, &cachep->memcg_params->nr_pages);
+	if (atomic_dec_and_test(&cachep->memcg_params->count))
+		schedule_work(&cachep->memcg_params->unregister_work);
 }
 
 /*
diff --git a/mm/slub.c b/mm/slub.c
index fdf0fe4da9a9..da7a3edde2cd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2550,6 +2550,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	unsigned long counters;
 	struct kmem_cache_node *n = NULL;
 	unsigned long uninitialized_var(flags);
+	int cache_dead = 0;
 
 	stat(s, FREE_SLOWPATH);
 
@@ -2557,6 +2558,32 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		!(n = free_debug_processing(s, page, x, addr, &flags)))
 		return;
 
+	if (!is_root_cache(s)) {
+		/*
+		 * We must not keep free slabs after the memcg the cache
+		 * belongs to is turned offline, otherwise the cache will be
+		 * hanging around for ever. For the slub implementation that
+		 * means we must not freeze slabs and we must ignore the
+		 * min_partial limit for dead caches.
+		 *
+		 * There is one subtle thing, however. If we get preempted
+		 * after we see the cache alive and before we try to
+		 * cmpxchg-free the object to it, the cache may be killed in
+		 * between and we may occasionally freeze a slab for a dead
+		 * cache.
+		 *
+		 * We avoid this by disabling preemption before the check if
+		 * the cache is dead and re-enabling it after cmpxchg-free,
+		 * where we can freeze a slab. Then, to assure a dead cache
+		 * won't have got frozen slabs it's enough to
+		 * synchronize_sched() after marking the cache dead and before
+		 * shrinking it (see memcg_unregister_all_caches()).
+		 */
+		preempt_disable();
+		if (memcg_cache_dead(s))
+			cache_dead = 1;
+	}
+
 	do {
 		if (unlikely(n)) {
 			spin_unlock_irqrestore(&n->list_lock, flags);
@@ -2570,7 +2597,8 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		new.inuse--;
 		if ((!new.inuse || !prior) && !was_frozen) {
 
-			if (kmem_cache_has_cpu_partial(s) && !prior) {
+			if (kmem_cache_has_cpu_partial(s) && !prior &&
+			    !cache_dead) {
 
 				/*
 				 * Slab was on no list before and will be
@@ -2601,6 +2629,9 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		object, new.counters,
 		"__slab_free"));
 
+	if (!is_root_cache(s))
+		preempt_enable();
+
 	if (likely(!n)) {
 
 		/*
@@ -2620,14 +2651,16 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
                 return;
         }
 
-	if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
+	if (unlikely(!new.inuse &&
+		     (n->nr_partial > s->min_partial || cache_dead)))
 		goto slab_empty;
 
 	/*
 	 * Objects left in the slab. If it was not on the partial list before
 	 * then add it.
 	 */
-	if (!kmem_cache_has_cpu_partial(s) && unlikely(!prior)) {
+	if ((!kmem_cache_has_cpu_partial(s) || cache_dead) &&
+	    unlikely(!prior)) {
 		if (kmem_cache_debug(s))
 			remove_full(s, n, page);
 		add_partial(n, page, DEACTIVATE_TO_TAIL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
