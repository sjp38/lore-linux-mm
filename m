Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 129AE6B006C
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 10:29:29 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so5357702pdi.30
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 07:29:28 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id v3si60414689pdo.232.2014.12.08.07.29.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Dec 2014 07:29:27 -0800 (PST)
Date: Mon, 8 Dec 2014 18:29:05 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm] memcg: fix possible use-after-free in
 memcg_kmem_get_cache
Message-ID: <20141208152905.GA25542@esperanza>
References: <1417969947-4072-1-git-send-email-vdavydov@parallels.com>
 <alpine.DEB.2.11.1412080848240.21299@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1412080848240.21299@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 08, 2014 at 08:49:31AM -0600, Christoph Lameter wrote:
> On Sun, 7 Dec 2014, Vladimir Davydov wrote:
> 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 95d214255663..7ddf01e2a465 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2450,6 +2450,7 @@ redo:
> >
> >  	slab_post_alloc_hook(s, gfpflags, object);
> >
> > +	memcg_kmem_put_cache(s);
> >  	return object;
> >  }
> 
> The function should be added to slab_post_alloc().
> 
> Also move the memcg_kmem_get_cache() into slab_pre_alloc_hook().

Sounds reasonable, thanks. The updated patch is below.
---
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2] memcg: fix possible use-after-free in
 memcg_kmem_get_cache

Suppose task @t that belongs to a memory cgroup @memcg is going to
allocate an object from a kmem cache @c. The copy of @c corresponding to
@memcg, @mc, is empty. Then if kmem_cache_alloc races with the memory
cgroup destruction we can access the memory cgroup's copy of the cache
after it was destroyed:

CPU0				CPU1
----				----
[ current=@t
  @mc->memcg_params->nr_pages=0 ]

kmem_cache_alloc(@c):
  call memcg_kmem_get_cache(@c);
  proceed to allocation from @mc:
    alloc a page for @mc:
      ...

				move @t from @memcg
				destroy @memcg:
				  mem_cgroup_css_offline(@memcg):
				    memcg_unregister_all_caches(@memcg):
				      kmem_cache_destroy(@mc)

    add page to @mc

We could fix this issue by taking a reference to a per-memcg cache, but
that would require adding a per-cpu reference counter to per-memcg
caches, which would look cumbersome.

Instead, let's take a reference to a memory cgroup, which already has a
per-cpu reference counter, in the beginning of kmem_cache_alloc to be
dropped in the end, and move per memcg caches destruction from css
offline to css free. As a side effect, per-memcg caches will be
destroyed not one by one, but all at once when the last page accounted
to the memory cgroup is freed. This doesn't sound as a high price for
code readability though.

Note, this patch does add some overhead to the kmem_cache_alloc hot
path, but it is pretty negligible - it's just a function call plus a per
cpu counter decrement, which is comparable to what we already have in
memcg_kmem_get_cache. Besides, it's only relevant if there are memory
cgroups with kmem accounting enabled. I don't think we can find a way to
handle this race w/o it, because alloc_page called from kmem_cache_alloc
may sleep so we can't flush all pending kmallocs w/o reference counting.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
Changes in v2:
 - move memcg_kmem_{get,put}_cache to slab_{pre,post}_alloc_hook (Christoph)

 include/linux/memcontrol.h |   14 ++++++++++--
 include/linux/slab.h       |    2 --
 mm/memcontrol.c            |   51 ++++++++++++++------------------------------
 mm/slab.c                  |    2 ++
 mm/slub.c                  |   14 +++++++-----
 5 files changed, 39 insertions(+), 44 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b74942a9e22f..7c95af8d552c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -400,8 +400,8 @@ int memcg_cache_id(struct mem_cgroup *memcg);
 
 void memcg_update_array_size(int num_groups);
 
-struct kmem_cache *
-__memcg_kmem_get_cache(struct kmem_cache *cachep);
+struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep);
+void __memcg_kmem_put_cache(struct kmem_cache *cachep);
 
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
@@ -494,6 +494,12 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 
 	return __memcg_kmem_get_cache(cachep);
 }
+
+static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
+{
+	if (memcg_kmem_enabled())
+		__memcg_kmem_put_cache(cachep);
+}
 #else
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
@@ -528,6 +534,10 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	return cachep;
 }
+
+static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
+{
+}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 8a2457d42fc8..9a139b637069 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -493,7 +493,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
- * @nr_pages: number of pages that belongs to this cache.
  */
 struct memcg_cache_params {
 	bool is_root_cache;
@@ -506,7 +505,6 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
-			atomic_t nr_pages;
 		};
 	};
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c6ac50e7d1c2..09c4838b24f0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2634,7 +2634,6 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 	if (!cachep)
 		return;
 
-	css_get(&memcg->css);
 	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
 
 	/*
@@ -2668,9 +2667,6 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	list_del(&cachep->memcg_params->list);
 
 	kmem_cache_destroy(cachep);
-
-	/* drop the reference taken in memcg_register_cache */
-	css_put(&memcg->css);
 }
 
 int __memcg_cleanup_cache_params(struct kmem_cache *s)
@@ -2704,9 +2700,7 @@ static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
 	mutex_lock(&memcg_slab_mutex);
 	list_for_each_entry_safe(params, tmp, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
-		kmem_cache_shrink(cachep);
-		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
-			memcg_unregister_cache(cachep);
+		memcg_unregister_cache(cachep);
 	}
 	mutex_unlock(&memcg_slab_mutex);
 }
@@ -2741,10 +2735,10 @@ static void __memcg_schedule_register_cache(struct mem_cgroup *memcg,
 	struct memcg_register_cache_work *cw;
 
 	cw = kmalloc(sizeof(*cw), GFP_NOWAIT);
-	if (cw == NULL) {
-		css_put(&memcg->css);
+	if (!cw)
 		return;
-	}
+
+	css_get(&memcg->css);
 
 	cw->memcg = memcg;
 	cw->cachep = cachep;
@@ -2775,12 +2769,8 @@ static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 {
 	unsigned int nr_pages = 1 << order;
-	int res;
 
-	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp, nr_pages);
-	if (!res)
-		atomic_add(nr_pages, &cachep->memcg_params->nr_pages);
-	return res;
+	return memcg_charge_kmem(cachep->memcg_params->memcg, gfp, nr_pages);
 }
 
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
@@ -2788,7 +2778,6 @@ void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 	unsigned int nr_pages = 1 << order;
 
 	memcg_uncharge_kmem(cachep->memcg_params->memcg, nr_pages);
-	atomic_sub(nr_pages, &cachep->memcg_params->nr_pages);
 }
 
 /*
@@ -2815,22 +2804,13 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
 	if (current->memcg_kmem_skip_account)
 		return cachep;
 
-	rcu_read_lock();
-	memcg = mem_cgroup_from_task(rcu_dereference(current->mm->owner));
-
+	memcg = get_mem_cgroup_from_mm(current->mm);
 	if (!memcg_kmem_is_active(memcg))
 		goto out;
 
 	memcg_cachep = cache_from_memcg_idx(cachep, memcg_cache_id(memcg));
-	if (likely(memcg_cachep)) {
-		cachep = memcg_cachep;
-		goto out;
-	}
-
-	/* The corresponding put will be done in the workqueue. */
-	if (!css_tryget_online(&memcg->css))
-		goto out;
-	rcu_read_unlock();
+	if (likely(memcg_cachep))
+		return memcg_cachep;
 
 	/*
 	 * If we are in a safe context (can wait, and not in interrupt
@@ -2845,12 +2825,17 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
 	 * defer everything.
 	 */
 	memcg_schedule_register_cache(memcg, cachep);
-	return cachep;
 out:
-	rcu_read_unlock();
+	css_put(&memcg->css);
 	return cachep;
 }
 
+void __memcg_kmem_put_cache(struct kmem_cache *cachep)
+{
+	if (!is_root_cache(cachep))
+		css_put(&cachep->memcg_params->memcg->css);
+}
+
 /*
  * We need to verify if the allocation against current->mm->owner's memcg is
  * possible for the given order. But the page is not allocated yet, so we'll
@@ -2913,10 +2898,6 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	memcg_uncharge_kmem(memcg, 1 << order);
 	page->mem_cgroup = NULL;
 }
-#else
-static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
-{
-}
 #endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -4187,6 +4168,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
+	memcg_unregister_all_caches(memcg);
 	mem_cgroup_sockets_destroy(memcg);
 }
 #else
@@ -4796,7 +4778,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
-	memcg_unregister_all_caches(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
diff --git a/mm/slab.c b/mm/slab.c
index 37727f074e16..65b5dcb6f671 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3182,6 +3182,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 			memset(ptr, 0, cachep->object_size);
 	}
 
+	memcg_kmem_put_cache(cachep);
 	return ptr;
 }
 
@@ -3247,6 +3248,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 			memset(objp, 0, cachep->object_size);
 	}
 
+	memcg_kmem_put_cache(cachep);
 	return objp;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 95d214255663..fe376fe1f4fe 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1233,13 +1233,17 @@ static inline void kfree_hook(const void *x)
 	kmemleak_free(x);
 }
 
-static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
+static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
+						     gfp_t flags)
 {
 	flags &= gfp_allowed_mask;
 	lockdep_trace_alloc(flags);
 	might_sleep_if(flags & __GFP_WAIT);
 
-	return should_failslab(s->object_size, flags, s->flags);
+	if (should_failslab(s->object_size, flags, s->flags))
+		return NULL;
+
+	return memcg_kmem_get_cache(s, flags);
 }
 
 static inline void slab_post_alloc_hook(struct kmem_cache *s,
@@ -1248,6 +1252,7 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s,
 	flags &= gfp_allowed_mask;
 	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
 	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
+	memcg_kmem_put_cache(s);
 }
 
 static inline void slab_free_hook(struct kmem_cache *s, void *x)
@@ -2383,10 +2388,9 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 	struct page *page;
 	unsigned long tid;
 
-	if (slab_pre_alloc_hook(s, gfpflags))
+	s = slab_pre_alloc_hook(s, gfpflags);
+	if (!s)
 		return NULL;
-
-	s = memcg_kmem_get_cache(s, gfpflags);
 redo:
 	/*
 	 * Must read kmem_cache cpu data via this cpu ptr. Preemption is
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
