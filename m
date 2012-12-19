Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id AA38E6B0069
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 09:03:15 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 3/3] sl[auo]b: retry allocation once in case of failure.
Date: Wed, 19 Dec 2012 18:01:42 +0400
Message-Id: <1355925702-7537-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1355925702-7537-1-git-send-email-glommer@parallels.com>
References: <1355925702-7537-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

When we are out of space in the caches, we will try to allocate a new
page.  If we still fail, the page allocator will try to free pages
through direct reclaim. Which means that if an object allocation failed
we can be sure that no new pages could be given to us, even though
direct reclaim was likely invoked.

However, direct reclaim will also try to shrink objects from registered
shrinkers. They won't necessarily free a full page, but if our cache
happens to be one with a shrinker, this may very well open up the space
we need. So we retry the allocation in this case.

We can't know for sure if this happened. So the best we can do is try to
derive from our allocation flags how likely it is for direct reclaim to
have been called, and retry if we conclude that this is highly likely
(GFP_NOWAIT | GFP_FS | !GFP_NORETRY).

The common case is for the allocation to succeed. So we carefuly insert
a likely branch for that case.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: David Rientjes <rientjes@google.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Mel Gorman <mgorman@suse.de>
---
 mm/slab.c |  2 ++
 mm/slab.h | 42 ++++++++++++++++++++++++++++++++++++++++++
 mm/slob.c | 27 +++++++++++++++++++++++----
 mm/slub.c | 26 ++++++++++++++++++++------
 4 files changed, 87 insertions(+), 10 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a98295f..7e82f99 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3535,6 +3535,8 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
 	objp = __do_slab_alloc_node(cachep, flags, nodeid);
+	if (slab_should_retry(objp, flags))
+		objp = __do_slab_alloc_node(cachep, flags, nodeid);
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	kmemleak_alloc_recursive(objp, cachep->object_size, 1, cachep->flags,
diff --git a/mm/slab.h b/mm/slab.h
index 34a98d6..03d1590 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -104,6 +104,48 @@ void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *s);
 ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 		       size_t count, loff_t *ppos);
 
+/*
+ * When we are out of space in the caches, we will try to allocate a new page.
+ * If we still fail, the page allocator will try to free pages through direct
+ * reclaim. Which means that if an object allocation failed we can be sure that
+ * no new pages could be given to us.
+ *
+ * However, direct reclaim will also try to shrink objects from registered
+ * shrinkers. They won't necessarily free a full page, but if our cache happens
+ * to be one with a shrinker, this may very well open up the space we need. So
+ * we retry the allocation in this case.
+ *
+ * We can't know for sure if this is the case. So the best we can do is try
+ * to derive from our allocation flags how likely it is for direct reclaim to
+ * have been called.
+ *
+ * Most of the time the allocation will succeed, and this will be just a branch
+ * with a very high hit ratio.
+ */
+static inline bool slab_should_retry(void *obj, gfp_t flags)
+{
+	if (likely(obj))
+		return false;
+
+	/*
+	 * those are obvious. We can't retry if the flags either explicitly
+	 * prohibit, or disallow waiting.
+	 */
+	if ((flags & __GFP_NORETRY) && !(flags & __GFP_WAIT))
+		return false;
+
+	/*
+	 * If this is not a __GFP_FS allocation, we are unlikely to have
+	 * reclaimed many objects - if at all. We may have succeeded in
+	 * allocating a new page, in which case the object allocation would
+	 * have succeeded, but most of the shrinkable objects would still be
+	 * in their caches. So retrying is likely futile.
+	 */
+	if (!(flags & __GFP_FS))
+		return false;
+	return true;
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 static inline bool is_root_cache(struct kmem_cache *s)
 {
diff --git a/mm/slob.c b/mm/slob.c
index a99fdf7..f00127b 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -424,7 +424,7 @@ out:
  */
 
 static __always_inline void *
-__do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
+___do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 {
 	unsigned int *m;
 	int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
@@ -462,6 +462,16 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 	return ret;
 }
 
+
+static __always_inline void *
+__do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
+{
+	void *obj = ___do_kmalloc_node(size, gfp, node, caller);
+        if (slab_should_retry(obj, gfp))
+		obj = ___do_kmalloc_node(size, gfp, node, caller);
+	return obj;
+}
+
 void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 {
 	return __do_kmalloc_node(size, gfp, node, _RET_IP_);
@@ -534,7 +544,9 @@ int __kmem_cache_create(struct kmem_cache *c, unsigned long flags)
 	return 0;
 }
 
-void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
+static __always_inline void *
+slab_alloc_node(struct kmem_cache *c, gfp_t flags, int node,
+		unsigned long caller)
 {
 	void *b;
 
@@ -544,12 +556,12 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 
 	if (c->size < PAGE_SIZE) {
 		b = slob_alloc(c->size, flags, c->align, node);
-		trace_kmem_cache_alloc_node(_RET_IP_, b, c->object_size,
+		trace_kmem_cache_alloc_node(caller, b, c->object_size,
 					    SLOB_UNITS(c->size) * SLOB_UNIT,
 					    flags, node);
 	} else {
 		b = slob_new_pages(flags, get_order(c->size), node);
-		trace_kmem_cache_alloc_node(_RET_IP_, b, c->object_size,
+		trace_kmem_cache_alloc_node(caller, b, c->object_size,
 					    PAGE_SIZE << get_order(c->size),
 					    flags, node);
 	}
@@ -562,6 +574,13 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
+void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
+{
+	void *obj = slab_alloc_node(c, flags, node, _RET_IP_);
+        if (slab_should_retry(obj, flags))
+		obj = slab_alloc_node(c, flags, node, _RET_IP_);
+	return obj;
+}
 static void __kmem_cache_free(void *b, int size)
 {
 	if (size < PAGE_SIZE)
diff --git a/mm/slub.c b/mm/slub.c
index b72569c..580dfa8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2318,18 +2318,15 @@ new_slab:
  *
  * Otherwise we can simply pick the next object from the lockless free list.
  */
-static __always_inline void *slab_alloc_node(struct kmem_cache *s,
-		gfp_t gfpflags, int node, unsigned long addr)
+static __always_inline void *
+do_slab_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node,
+		   unsigned long addr)
 {
 	void **object;
 	struct kmem_cache_cpu *c;
 	struct page *page;
 	unsigned long tid;
 
-	if (slab_pre_alloc_hook(s, gfpflags))
-		return NULL;
-
-	s = memcg_kmem_get_cache(s, gfpflags);
 redo:
 
 	/*
@@ -2389,6 +2386,23 @@ redo:
 	return object;
 }
 
+static __always_inline void *
+slab_alloc_node(struct kmem_cache *s, gfp_t gfpflags,
+		int node, unsigned long addr)
+{
+	void *obj;
+
+	if (slab_pre_alloc_hook(s, gfpflags))
+		return NULL;
+
+	s = memcg_kmem_get_cache(s, gfpflags);
+
+	obj = do_slab_alloc_node(s, gfpflags, node, addr);
+	if (slab_should_retry(obj, gfpflags))
+		obj = do_slab_alloc_node(s, gfpflags, node, addr);
+	return obj;
+}
+
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
 	void *ret = slab_alloc_node(s, gfpflags, NUMA_NO_NODE, _RET_IP_);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
