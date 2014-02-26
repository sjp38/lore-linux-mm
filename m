Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC3C6B00A6
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:05:26 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id hr17so717621lab.32
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:05:25 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id k3si1818512lam.101.2014.02.26.07.05.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 07:05:24 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 02/12] memcg: fix race in memcg cache destruction path
Date: Wed, 26 Feb 2014 19:05:07 +0400
Message-ID: <aaa6d90592e14192f7eecd639d834e82f34ad457.1393423762.git.vdavydov@parallels.com>
In-Reply-To: <cover.1393423762.git.vdavydov@parallels.com>
References: <cover.1393423762.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

We schedule memcg cache shrink+destruction work (memcg_params::destroy)
from two places: when we turn memcg offline
(mem_cgroup_destroy_all_caches) and when the last page of the cache is
freed (memcg_params::nr_pages reachs zero, see memcg_release_pages,
mem_cgroup_destroy_cache). Since the latter can happen while the work
scheduled from mem_cgroup_destroy_all_caches is in progress or still
pending, we need to be cautious to avoid races there - we should
accurately bail out in one of those functions if we see that the other
is in progress. Currently we only check if memcg_params::nr_pages is 0
in the destruction work handler and do not destroy the cache if so. But
that's not enough. An example of race we can get is shown below:

  CPU0					CPU1
  ----					----
  kmem_cache_destroy_work_func:		memcg_release_pages:
					  atomic_sub_and_test(1<<order, &s->
							memcg_params->nr_pages)
					  /* reached 0 => schedule destroy */

    atomic_read(&cachep->memcg_params->nr_pages)
    /* 0 => going to destroy the cache */
    kmem_cache_destroy(cachep);

					  mem_cgroup_destroy_cache(s):
					    /* the cache was destroyed on CPU0
					       - use after free */

An obvious way to fix this would be substituting the nr_pages counter
with a reference counter and make memcg take a reference. The cache
destruction would be then scheduled from that thread which decremented
the refcount to 0. Generally, this is what this patch does, but there is
one subtle thing here - the work handler serves not only for cache
destruction, it also shrinks the cache if it's still in use (we can't
call shrink directly from mem_cgroup_destroy_all_caches due to locking
dependencies). We handle this by noting that we should only issue shrink
if called from mem_cgroup_destroy_all_caches, because the cache is
already empty when we release its last page. And if we drop the
reference taken by memcg in the work handler, we can detect who exactly
scheduled the worker - mem_cgroup_destroy_all_caches or
memcg_release_pages.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
---
 include/linux/memcontrol.h |    1 -
 include/linux/slab.h       |    7 ++--
 mm/memcontrol.c            |   86 +++++++++++++-------------------------------
 mm/slab.h                  |   17 +++++++--
 4 files changed, 42 insertions(+), 69 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index af63e6004c62..e54fb469a908 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -512,7 +512,6 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
-void mem_cgroup_destroy_cache(struct kmem_cache *cachep);
 int __kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
 /**
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3dd389aa91c7..3ed53de256ea 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -522,8 +522,8 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
- * @dead: set to true after the memcg dies; the cache may still be around.
- * @nr_pages: number of pages that belongs to this cache.
+ * @refcount: the reference counter; cache destruction will be scheduled when
+ *            it reaches zero
  * @destroy: worker to be called whenever we are ready, or believe we may be
  *           ready, to destroy this cache.
  */
@@ -538,8 +538,7 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
-			bool dead;
-			atomic_t nr_pages;
+			atomic_t refcount;
 			struct work_struct destroy;
 		};
 	};
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b61b6e9381e8..416da5dc3d2a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3206,6 +3206,7 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 		s->memcg_params->root_cache = root_cache;
 		INIT_WORK(&s->memcg_params->destroy,
 				kmem_cache_destroy_work_func);
+		atomic_set(&s->memcg_params->refcount, 1);
 		css_get(&memcg->css);
 	} else
 		s->memcg_params->is_root_cache = true;
@@ -3327,64 +3328,24 @@ static inline void memcg_resume_kmem_account(void)
 static void kmem_cache_destroy_work_func(struct work_struct *w)
 {
 	struct kmem_cache *cachep;
-	struct memcg_cache_params *p;
-
-	p = container_of(w, struct memcg_cache_params, destroy);
+	struct memcg_cache_params *params;
 
-	cachep = memcg_params_to_cache(p);
+	params = container_of(w, struct memcg_cache_params, destroy);
+	cachep = memcg_params_to_cache(params);
 
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
+	if (atomic_read(&params->refcount) != 0) {
+		/*
+		 * We were scheduled from mem_cgroup_destroy_all_caches().
+		 * Shrink the cache and drop the reference taken by memcg.
+		 */
 		kmem_cache_shrink(cachep);
-	else
-		kmem_cache_destroy(cachep);
-}
 
-void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
-{
-	if (!cachep->memcg_params->dead)
-		return;
+		/* cache is still in use? */
+		if (!atomic_dec_and_test(&params->refcount))
+			return;
+	}
 
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
+	kmem_cache_destroy(cachep);
 }
 
 int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
@@ -3425,12 +3386,12 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		 * kmem_cache_destroy() will call kmem_cache_shrink internally,
 		 * and that could spawn the workers again: it is likely that
 		 * the cache still have active pages until this very moment.
-		 * This would lead us back to mem_cgroup_destroy_cache.
+		 * This would lead us back to memcg_release_pages().
 		 *
-		 * But that will not execute at all if the "dead" flag is not
-		 * set, so flip it down to guarantee we are in control.
+		 * But that will not execute at all if the refcount is > 0, so
+		 * increment it to guarantee we are in control.
 		 */
-		c->memcg_params->dead = false;
+		atomic_inc(&c->memcg_params->refcount);
 		cancel_work_sync(&c->memcg_params->destroy);
 		kmem_cache_destroy(c);
 
@@ -3443,7 +3404,6 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 
 static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 {
-	struct kmem_cache *cachep;
 	struct memcg_cache_params *params;
 
 	if (!memcg_kmem_is_active(memcg))
@@ -3460,9 +3420,13 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 
 	mutex_lock(&memcg->slab_caches_mutex);
 	list_for_each_entry(params, &memcg->memcg_slab_caches, list) {
-		cachep = memcg_params_to_cache(params);
-		cachep->memcg_params->dead = true;
-		schedule_work(&cachep->memcg_params->destroy);
+		/*
+		 * Since we still hold the reference to the cache params from
+		 * the memcg, the work could not have been scheduled from
+		 * memcg_release_pages(), and this cannot fail.
+		 */
+		if (!schedule_work(&params->destroy))
+			BUG();
 	}
 	mutex_unlock(&memcg->slab_caches_mutex);
 }
diff --git a/mm/slab.h b/mm/slab.h
index 3045316b7c9d..b8caee243b88 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -122,7 +122,7 @@ static inline bool is_root_cache(struct kmem_cache *s)
 static inline void memcg_bind_pages(struct kmem_cache *s, int order)
 {
 	if (!is_root_cache(s))
-		atomic_add(1 << order, &s->memcg_params->nr_pages);
+		atomic_add(1 << order, &s->memcg_params->refcount);
 }
 
 static inline void memcg_release_pages(struct kmem_cache *s, int order)
@@ -130,8 +130,19 @@ static inline void memcg_release_pages(struct kmem_cache *s, int order)
 	if (is_root_cache(s))
 		return;
 
-	if (atomic_sub_and_test((1 << order), &s->memcg_params->nr_pages))
-		mem_cgroup_destroy_cache(s);
+	if (atomic_sub_and_test((1 << order), &s->memcg_params->refcount)) {
+		/*
+		 * We have to defer the actual destroying to a workqueue,
+		 * because we might currently be in a context that cannot
+		 * sleep.
+		 *
+		 * Note we cannot fail here, because if the work scheduled from
+		 * mem_cgroup_destroy_all_caches() were still pending, the
+		 * cache refcount wouldn't reach zero.
+		 */
+		if (!schedule_work(&s->memcg_params->destroy))
+			BUG();
+	}
 }
 
 static inline bool slab_equal_or_root(struct kmem_cache *s,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
