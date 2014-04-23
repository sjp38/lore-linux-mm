Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 02EA06B0073
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 03:13:25 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id 10so429692lbg.11
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 00:13:25 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h4si68996lae.67.2014.04.23.00.13.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Apr 2014 00:13:24 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 1/3] memcg, slab: do not schedule cache destruction when last page goes away
Date: Wed, 23 Apr 2014 11:13:13 +0400
Message-ID: <7740d66b62befa271d368a7b7c5d881fef3ebc90.1398235153.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398235153.git.vdavydov@parallels.com>
References: <cover.1398235153.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

After a memcg is offlined, we mark its kmem caches that cannot be
deleted right now due to pending objects as dead by setting the
memcg_cache_params::dead flag, so that memcg_release_pages will schedule
cache destruction (memcg_cache_params::destroy) as soon as the last slab
of the cache is freed (memcg_cache_params::nr_pages drops to zero).

I guess the idea was to destroy the caches as soon as possible, i.e.
immediately after freeing the last object. However, it just doesn't work
that way, because kmem caches always preserve some pages for the sake of
performance, so that nr_pages never gets to zero unless the cache is
shrunk explicitly using kmem_cache_shrink. Of course, we could account
the total number of objects on the cache or check if all the slabs
allocated for the cache are empty on kmem_cache_free and schedule
destruction if so, but that would be too costly.

Thus we have a piece of code that works only when we explicitly call
kmem_cache_shrink, but complicates the whole picture a lot. Moreover,
it's racy in fact. For instance, kmem_cache_shrink may free the last
slab and thus schedule cache destruction before it finishes checking
that the cache is empty, which can lead to use-after-free.

So I propose to remove this async cache destruction from
memcg_release_pages, and check if the cache is empty explicitly after
calling kmem_cache_shrink instead. This will simplify things a lot w/o
introducing any functional changes.

And regarding dead memcg caches (i.e. those that are left hanging around
after memcg offline for they have objects), I suppose we should reap
them either periodically or on vmpressure as Glauber suggested
initially. I'm going to implement this later.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |    1 -
 include/linux/slab.h       |    2 --
 mm/memcontrol.c            |   63 ++------------------------------------------
 mm/slab.h                  |    7 ++---
 4 files changed, 4 insertions(+), 69 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5155d09e749d..087a45314181 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -509,7 +509,6 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size);
 void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size);
 
-void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
 int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
 /**
diff --git a/include/linux/slab.h b/include/linux/slab.h
index a6aab2c0dfc5..905541dd3778 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -524,7 +524,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
- * @dead: set to true after the memcg dies; the cache may still be around.
  * @nr_pages: number of pages that belongs to this cache.
  * @destroy: worker to be called whenever we are ready, or believe we may be
  *           ready, to destroy this cache.
@@ -540,7 +539,6 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
-			bool dead;
 			atomic_t nr_pages;
 			struct work_struct destroy;
 		};
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index efc233f8b529..4c9b0cbd06ed 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3274,60 +3274,11 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 
 	cachep = memcg_params_to_cache(p);
 
-	/*
-	 * If we get down to 0 after shrink, we could delete right away.
-	 * However, memcg_release_pages() already puts us back in the workqueue
-	 * in that case. If we proceed deleting, we'll get a dangling
-	 * reference, and removing the object from the workqueue in that case
-	 * is unnecessary complication. We are not a fast path.
-	 *
-	 * Note that this case is fundamentally different from racing with
-	 * shrink_slab(): if memcg_cgroup_destroy_cache() is called in
-	 * kmem_cache_shrink, not only we would be reinserting a dead cache
-	 * into the queue, but doing so from inside the worker racing to
-	 * destroy it.
-	 *
-	 * So if we aren't down to zero, we'll just schedule a worker and try
-	 * again
-	 */
-	if (atomic_read(&cachep->memcg_params->nr_pages) != 0)
-		kmem_cache_shrink(cachep);
-	else
+	kmem_cache_shrink(cachep);
+	if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
 		kmem_cache_destroy(cachep);
 }
 
-void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
-{
-	if (!cachep->memcg_params->dead)
-		return;
-
-	/*
-	 * There are many ways in which we can get here.
-	 *
-	 * We can get to a memory-pressure situation while the delayed work is
-	 * still pending to run. The vmscan shrinkers can then release all
-	 * cache memory and get us to destruction. If this is the case, we'll
-	 * be executed twice, which is a bug (the second time will execute over
-	 * bogus data). In this case, cancelling the work should be fine.
-	 *
-	 * But we can also get here from the worker itself, if
-	 * kmem_cache_shrink is enough to shake all the remaining objects and
-	 * get the page count to 0. In this case, we'll deadlock if we try to
-	 * cancel the work (the worker runs with an internal lock held, which
-	 * is the same lock we would hold for cancel_work_sync().)
-	 *
-	 * Since we can't possibly know who got us here, just refrain from
-	 * running if there is already work pending
-	 */
-	if (work_pending(&cachep->memcg_params->destroy))
-		return;
-	/*
-	 * We have to defer the actual destroying to a workqueue, because
-	 * we might currently be in a context that cannot sleep.
-	 */
-	schedule_work(&cachep->memcg_params->destroy);
-}
-
 int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
 	struct kmem_cache *c;
@@ -3353,16 +3304,7 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		 * We will now manually delete the caches, so to avoid races
 		 * we need to cancel all pending destruction workers and
 		 * proceed with destruction ourselves.
-		 *
-		 * kmem_cache_destroy() will call kmem_cache_shrink internally,
-		 * and that could spawn the workers again: it is likely that
-		 * the cache still have active pages until this very moment.
-		 * This would lead us back to mem_cgroup_destroy_cache.
-		 *
-		 * But that will not execute at all if the "dead" flag is not
-		 * set, so flip it down to guarantee we are in control.
 		 */
-		c->memcg_params->dead = false;
 		cancel_work_sync(&c->memcg_params->destroy);
 		kmem_cache_destroy(c);
 
@@ -3384,7 +3326,6 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 	mutex_lock(&memcg->slab_caches_mutex);
 	list_for_each_entry(params, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
-		cachep->memcg_params->dead = true;
 		schedule_work(&cachep->memcg_params->destroy);
 	}
 	mutex_unlock(&memcg->slab_caches_mutex);
diff --git a/mm/slab.h b/mm/slab.h
index 6fc2f0050db6..b60c0a30f75f 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -128,11 +128,8 @@ static inline void memcg_bind_pages(struct kmem_cache *s, int order)
 
 static inline void memcg_release_pages(struct kmem_cache *s, int order)
 {
-	if (is_root_cache(s))
-		return;
-
-	if (atomic_sub_and_test((1 << order), &s->memcg_params->nr_pages))
-		mem_cgroup_destroy_cache(s);
+	if (!is_root_cache(s))
+		atomic_sub(1 << order, &s->memcg_params->nr_pages);
 }
 
 static inline bool slab_equal_or_root(struct kmem_cache *s,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
