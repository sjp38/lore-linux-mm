Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 17FCC6B0341
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 13:37:43 -0400 (EDT)
Message-Id: <20100820173739.877884390@linux.com>
Date: Fri, 20 Aug 2010 12:37:16 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [S+Q Cleanup4 5/6] slub: Extract hooks for memory checkers from hotpaths
References: <20100820173711.136529149@linux.com>
Content-Disposition: inline; filename=slub_extract
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Extract the code that memory checkers and other verification tools use from
the hotpaths. Makes it easier to add new ones and reduces the disturbances
of the hotpaths.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   49 ++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 38 insertions(+), 11 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-19 16:32:55.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-19 16:34:07.000000000 -0500
@@ -791,6 +791,37 @@ static void trace(struct kmem_cache *s, 
 }
 
 /*
+ * Hooks for other subsystems that check memory allocations. In a typical
+ * production configuration these hooks all should produce no code at all.
+ */
+static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
+{
+	lockdep_trace_alloc(flags);
+	might_sleep_if(flags & __GFP_WAIT);
+
+	return should_failslab(s->objsize, flags, s->flags);
+}
+
+static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags, void *object)
+{
+	kmemcheck_slab_alloc(s, flags, object, s->objsize);
+	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, flags);
+}
+
+static inline void slab_free_hook(struct kmem_cache *s, void *x)
+{
+	kmemleak_free_recursive(x, s->flags);
+}
+
+static inline void slab_free_hook_irq(struct kmem_cache *s, void *object)
+{
+	kmemcheck_slab_free(s, object, s->objsize);
+	debug_check_no_locks_freed(object, s->objsize);
+	if (!(s->flags & SLAB_DEBUG_OBJECTS))
+		debug_check_no_obj_freed(object, s->objsize);
+}
+
+/*
  * Tracking of fully allocated slabs for debugging purposes.
  */
 static void add_full(struct kmem_cache_node *n, struct page *page)
@@ -1696,10 +1727,7 @@ static __always_inline void *slab_alloc(
 
 	gfpflags &= gfp_allowed_mask;
 
-	lockdep_trace_alloc(gfpflags);
-	might_sleep_if(gfpflags & __GFP_WAIT);
-
-	if (should_failslab(s->objsize, gfpflags, s->flags))
+	if (slab_pre_alloc_hook(s, gfpflags))
 		return NULL;
 
 	local_irq_save(flags);
@@ -1718,8 +1746,7 @@ static __always_inline void *slab_alloc(
 	if (unlikely(gfpflags & __GFP_ZERO) && object)
 		memset(object, 0, s->objsize);
 
-	kmemcheck_slab_alloc(s, gfpflags, object, s->objsize);
-	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, gfpflags);
+	slab_post_alloc_hook(s, gfpflags, object);
 
 	return object;
 }
@@ -1849,13 +1876,13 @@ static __always_inline void slab_free(st
 	struct kmem_cache_cpu *c;
 	unsigned long flags;
 
-	kmemleak_free_recursive(x, s->flags);
+	slab_free_hook(s, x);
+
 	local_irq_save(flags);
 	c = __this_cpu_ptr(s->cpu_slab);
-	kmemcheck_slab_free(s, object, s->objsize);
-	debug_check_no_locks_freed(object, s->objsize);
-	if (!(s->flags & SLAB_DEBUG_OBJECTS))
-		debug_check_no_obj_freed(object, s->objsize);
+
+	slab_free_hook_irq(s, x);
+
 	if (likely(page == c->page && c->node >= 0)) {
 		set_freepointer(s, object, c->freelist);
 		c->freelist = object;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
