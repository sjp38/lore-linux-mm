Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6122B6B0070
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 11:23:08 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so26999513pab.6
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:23:08 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id d8si6448748pas.50.2015.01.28.08.23.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jan 2015 08:23:07 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 3/3] slub: make dead caches discard free slabs immediately
Date: Wed, 28 Jan 2015 19:22:51 +0300
Message-ID: <6eecfafdc6c3dcbb98d2176cdebcb65abbc180b4.1422461573.git.vdavydov@parallels.com>
In-Reply-To: <cover.1422461573.git.vdavydov@parallels.com>
References: <cover.1422461573.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To speed up further allocations SLUB may store empty slabs in per
cpu/node partial lists instead of freeing them immediately. This
prevents per memcg caches destruction, because kmem caches created for a
memory cgroup are only destroyed after the last page charged to the
cgroup is freed.

To fix this issue, this patch resurrects approach first proposed in [1].
It forbids SLUB to cache empty slabs after the memory cgroup that the
cache belongs to was destroyed. It is achieved by setting kmem_cache's
cpu_partial and min_partial constants to 0 and tuning put_cpu_partial()
so that it would drop frozen empty slabs immediately if cpu_partial = 0.

The runtime overhead is minimal. From all the hot functions, we only
touch relatively cold put_cpu_partial(): we make it call
unfreeze_partials() after freezing a slab that belongs to an offline
memory cgroup. Since slab freezing exists to avoid moving slabs from/to
a partial list on free/alloc, and there can't be allocations from dead
caches, it shouldn't cause any overhead. We do have to disable
preemption for put_cpu_partial() to achieve that though.

The original patch was accepted well and even merged to the mm tree.
However, I decided to withdraw it due to changes happening to the memcg
core at that time. I had an idea of introducing per-memcg shrinkers for
kmem caches, but now, as memcg has finally settled down, I do not see it
as an option, because SLUB shrinker would be too costly to call since
SLUB does not keep free slabs on a separate list. Besides, we currently
do not even call per-memcg shrinkers for offline memcgs. Overall, it
would introduce much more complexity to both SLUB and memcg than this
small patch.

Regarding to SLAB, there's no problem with it, because it shrinks
per-cpu/node caches periodically. Thanks to list_lru reparenting, we no
longer keep entries for offline cgroups in per-memcg arrays (such as
memcg_cache_params->memcg_caches), so we do not have to bother if a
per-memcg cache will be shrunk a bit later than it could be.

[1] http://thread.gmane.org/gmane.linux.kernel.mm/118649/focus=118650

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab.c        |    4 ++--
 mm/slab.h        |    2 +-
 mm/slab_common.c |   15 +++++++++++++--
 mm/slob.c        |    2 +-
 mm/slub.c        |   31 ++++++++++++++++++++++++++-----
 5 files changed, 43 insertions(+), 11 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 7894017bc160..c4b89eaf4c96 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2382,7 +2382,7 @@ out:
 	return nr_freed;
 }
 
-int __kmem_cache_shrink(struct kmem_cache *cachep)
+int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
 {
 	int ret = 0;
 	int node;
@@ -2404,7 +2404,7 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
 	int i;
 	struct kmem_cache_node *n;
-	int rc = __kmem_cache_shrink(cachep);
+	int rc = __kmem_cache_shrink(cachep, false);
 
 	if (rc)
 		return rc;
diff --git a/mm/slab.h b/mm/slab.h
index 0a56d76ac0e9..4c3ac12dd644 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -138,7 +138,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 #define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)
 
 int __kmem_cache_shutdown(struct kmem_cache *);
-int __kmem_cache_shrink(struct kmem_cache *);
+int __kmem_cache_shrink(struct kmem_cache *, bool);
 void slab_kmem_cache_release(struct kmem_cache *);
 
 struct seq_file;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 0dd9eb4e0f87..9395842cfc6b 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -549,10 +549,13 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 {
 	int idx;
 	struct memcg_cache_array *arr;
-	struct kmem_cache *s;
+	struct kmem_cache *s, *c;
 
 	idx = memcg_cache_id(memcg);
 
+	get_online_cpus();
+	get_online_mems();
+
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list) {
 		if (!is_root_cache(s))
@@ -560,9 +563,17 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
 
 		arr = rcu_dereference_protected(s->memcg_params.memcg_caches,
 						lockdep_is_held(&slab_mutex));
+		c = arr->entries[idx];
+		if (!c)
+			continue;
+
+		__kmem_cache_shrink(c, true);
 		arr->entries[idx] = NULL;
 	}
 	mutex_unlock(&slab_mutex);
+
+	put_online_mems();
+	put_online_cpus();
 }
 
 void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
@@ -649,7 +660,7 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
 
 	get_online_cpus();
 	get_online_mems();
-	ret = __kmem_cache_shrink(cachep);
+	ret = __kmem_cache_shrink(cachep, false);
 	put_online_mems();
 	put_online_cpus();
 	return ret;
diff --git a/mm/slob.c b/mm/slob.c
index 96a86206a26b..94a7fede6d48 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -618,7 +618,7 @@ int __kmem_cache_shutdown(struct kmem_cache *c)
 	return 0;
 }
 
-int __kmem_cache_shrink(struct kmem_cache *d)
+int __kmem_cache_shrink(struct kmem_cache *d, bool deactivate)
 {
 	return 0;
 }
diff --git a/mm/slub.c b/mm/slub.c
index 63abe52c2951..a91789f59ab6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2007,6 +2007,7 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 	int pages;
 	int pobjects;
 
+	preempt_disable();
 	do {
 		pages = 0;
 		pobjects = 0;
@@ -2040,6 +2041,14 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 
 	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
 								!= oldpage);
+	if (unlikely(!s->cpu_partial)) {
+		unsigned long flags;
+
+		local_irq_save(flags);
+		unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
+		local_irq_restore(flags);
+	}
+	preempt_enable();
 #endif
 }
 
@@ -3369,7 +3378,7 @@ EXPORT_SYMBOL(kfree);
  * being allocated from last increasing the chance that the last objects
  * are freed in them.
  */
-int __kmem_cache_shrink(struct kmem_cache *s)
+int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
 {
 	int node;
 	int i;
@@ -3381,14 +3390,26 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 	unsigned long flags;
 	int ret = 0;
 
+	if (deactivate) {
+		/*
+		 * Disable empty slabs caching. Used to avoid pinning offline
+		 * memory cgroups by kmem pages that can be freed.
+		 */
+		s->cpu_partial = 0;
+		s->min_partial = 0;
+
+		/*
+		 * s->cpu_partial is checked locklessly (see put_cpu_partial),
+		 * so we have to make sure the change is visible.
+		 */
+		kick_all_cpus_sync();
+	}
+
 	for (i = 0; i < SHRINK_PROMOTE_MAX; i++)
 		INIT_LIST_HEAD(promote + i);
 
 	flush_all(s);
 	for_each_kmem_cache_node(s, node, n) {
-		if (!n->nr_partial)
-			continue;
-
 		spin_lock_irqsave(&n->list_lock, flags);
 
 		/*
@@ -3439,7 +3460,7 @@ static int slab_mem_going_offline_callback(void *arg)
 
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list)
-		__kmem_cache_shrink(s);
+		__kmem_cache_shrink(s, false);
 	mutex_unlock(&slab_mutex);
 
 	return 0;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
