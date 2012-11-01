Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id A69CA6B008A
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:09:12 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 27/29] slab: propagate tunables values
Date: Thu,  1 Nov 2012 16:07:43 +0400
Message-Id: <1351771665-11076-28-git-send-email-glommer@parallels.com>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

SLAB allows us to tune a particular cache behavior with tunables.
When creating a new memcg cache copy, we'd like to preserve any tunables
the parent cache already had.

This could be done by an explicit call to do_tune_cpucache() after the
cache is created. But this is not very convenient now that the caches are
created from common code, since this function is SLAB-specific.

Another method of doing that is taking advantage of the fact that
do_tune_cpucache() is always called from enable_cpucache(), which is
called at cache initialization. We can just preset the values, and
then things work as expected.

It can also happen that a root cache has its tunables updated during
normal system operation. In this case, we will propagate the change to
all caches that are already active.

This change will require us to move the assignment of root_cache in
memcg_params a bit earlier. We need this to be already set - which
memcg_kmem_register_cache will do - when we reach __kmem_cache_create()

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |  8 +++++---
 include/linux/slab.h       |  2 +-
 mm/memcontrol.c            | 10 ++++++----
 mm/slab.c                  | 44 +++++++++++++++++++++++++++++++++++++++++---
 mm/slab.h                  | 12 ++++++++++++
 mm/slab_common.c           |  7 ++++---
 6 files changed, 69 insertions(+), 14 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c780dd6..c91e3c1 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -441,7 +441,8 @@ void __memcg_kmem_commit_charge(struct page *page,
 void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
-int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s);
+int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
+			 struct kmem_cache *root_cache);
 void memcg_release_cache(struct kmem_cache *cachep);
 void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep);
 
@@ -583,8 +584,9 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return -1;
 }
 
-static inline int memcg_register_cache(struct mem_cgroup *memcg,
-				       struct kmem_cache *s)
+static inline int
+memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
+		     struct kmem_cache *root_cache)
 {
 	return 0;
 }
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 1232c7f..81ee767 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -128,7 +128,7 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			void (*)(void *));
 struct kmem_cache *
 kmem_cache_create_memcg(struct mem_cgroup *, const char *, size_t, size_t,
-			unsigned long, void (*)(void *));
+			unsigned long, void (*)(void *), struct kmem_cache *);
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 35f5cb3..7d14fbd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2981,7 +2981,8 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
-int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s)
+int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
+			 struct kmem_cache *root_cache)
 {
 	size_t size = sizeof(struct memcg_cache_params);
 
@@ -2995,8 +2996,10 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s)
 	if (!s->memcg_params)
 		return -ENOMEM;
 
-	if (memcg)
+	if (memcg) {
 		s->memcg_params->memcg = memcg;
+		s->memcg_params->root_cache = root_cache;
+	}
 	return 0;
 }
 
@@ -3162,7 +3165,7 @@ static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
 		return NULL;
 
 	new = kmem_cache_create_memcg(memcg, name, s->object_size, s->align,
-				      (s->flags & ~SLAB_PANIC), s->ctor);
+				      (s->flags & ~SLAB_PANIC), s->ctor, s);
 
 	if (new)
 		new->allocflags |= __GFP_KMEMCG;
@@ -3206,7 +3209,6 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	}
 
 	mem_cgroup_get(memcg);
-	new_cachep->memcg_params->root_cache = cachep;
 	atomic_set(&new_cachep->memcg_params->nr_pages , 0);
 
 	cachep->memcg_params->memcg_caches[idx] = new_cachep;
diff --git a/mm/slab.c b/mm/slab.c
index 15bb502..628a88e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4110,7 +4110,7 @@ static void do_ccupdate_local(void *info)
 }
 
 /* Always called with the slab_mutex held */
-static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
+static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 				int batchcount, int shared, gfp_t gfp)
 {
 	struct ccupdate_struct *new;
@@ -4153,12 +4153,48 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 	return alloc_kmemlist(cachep, gfp);
 }
 
+static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
+				int batchcount, int shared, gfp_t gfp)
+{
+	int ret;
+	struct kmem_cache *c = NULL;
+	int i = 0;
+
+	ret = __do_tune_cpucache(cachep, limit, batchcount, shared, gfp);
+
+	if (slab_state < FULL)
+		return ret;
+
+	if ((ret < 0) || !is_root_cache(cachep))
+		return ret;
+
+	for_each_memcg_cache_index(i) {
+		c = cache_from_memcg(cachep, i);
+		if (c)
+			/* return value determined by the parent cache only */
+			__do_tune_cpucache(c, limit, batchcount, shared, gfp);
+	}
+
+	return ret;
+}
+
 /* Called with slab_mutex held always */
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	int err;
-	int limit, shared;
+	int limit = 0;
+	int shared = 0;
+	int batchcount = 0;
+
+	if (!is_root_cache(cachep)) {
+		struct kmem_cache *root = memcg_root_cache(cachep);
+		limit = root->limit;
+		shared = root->shared;
+		batchcount = root->batchcount;
+	}
 
+	if (limit && shared && batchcount)
+		goto skip_setup;
 	/*
 	 * The head array serves three purposes:
 	 * - create a LIFO ordering, i.e. return objects that are cache-warm
@@ -4200,7 +4236,9 @@ static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
 	if (limit > 32)
 		limit = 32;
 #endif
-	err = do_tune_cpucache(cachep, limit, (limit + 1) / 2, shared, gfp);
+	batchcount = (limit + 1) / 2;
+skip_setup:
+	err = do_tune_cpucache(cachep, limit, batchcount, shared, gfp);
 	if (err)
 		printk(KERN_ERR "enable_cpucache failed for %s, error %d.\n",
 		       cachep->name, -err);
diff --git a/mm/slab.h b/mm/slab.h
index 08ef468..9fc04b0 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -147,6 +147,13 @@ static inline struct kmem_cache *cache_from_memcg(struct kmem_cache *s, int idx)
 {
 	return s->memcg_params->memcg_caches[idx];
 }
+
+static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
+{
+	if (is_root_cache(s))
+		return s;
+	return s->memcg_params->root_cache;
+}
 #else
 static inline bool is_root_cache(struct kmem_cache *s)
 {
@@ -182,6 +189,11 @@ static inline struct kmem_cache *cache_from_memcg(struct kmem_cache *s, int idx)
 {
 	return NULL;
 }
+
+static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
+{
+	return s;
+}
 #endif
 
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 9a6f421..34743d8 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -136,7 +136,8 @@ out:
 
 struct kmem_cache *
 kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
-			size_t align, unsigned long flags, void (*ctor)(void *))
+			size_t align, unsigned long flags, void (*ctor)(void *),
+			struct kmem_cache *parent_cache)
 {
 	struct kmem_cache *s = NULL;
 	int err = 0;
@@ -165,7 +166,7 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 		s->align = align;
 		s->ctor = ctor;
 
-		if (memcg_register_cache(memcg, s)) {
+		if (memcg_register_cache(memcg, s, parent_cache)) {
 			kmem_cache_free(kmem_cache, s);
 			err = -ENOMEM;
 			goto out_locked;
@@ -215,7 +216,7 @@ struct kmem_cache *
 kmem_cache_create(const char *name, size_t size, size_t align,
 		  unsigned long flags, void (*ctor)(void *))
 {
-	return kmem_cache_create_memcg(NULL, name, size, align, flags, ctor);
+	return kmem_cache_create_memcg(NULL, name, size, align, flags, ctor, NULL);
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
