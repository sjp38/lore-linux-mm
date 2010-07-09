Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 28037600924
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:12:33 -0400 (EDT)
Message-Id: <20100709190857.289989794@quilx.com>
Date: Fri, 09 Jul 2010 14:07:19 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q2 13/19] slub: Extract hooks for memory checkers from hotpaths
References: <20100709190706.938177313@quilx.com>
Content-Disposition: inline; filename=slub_extract
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
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
--- linux-2.6.orig/mm/slub.c	2010-07-07 09:14:45.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-07 10:38:17.000000000 -0500
@@ -793,6 +793,37 @@ static void trace(struct kmem_cache *s, 
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
@@ -1704,10 +1735,7 @@ static __always_inline void *slab_alloc(
 
 	gfpflags &= gfp_allowed_mask;
 
-	lockdep_trace_alloc(gfpflags);
-	might_sleep_if(gfpflags & __GFP_WAIT);
-
-	if (should_failslab(s->objsize, gfpflags, s->flags))
+	if (!slab_pre_alloc_hook(s, gfpflags))
 		return NULL;
 
 	local_irq_save(flags);
@@ -1726,8 +1754,7 @@ static __always_inline void *slab_alloc(
 	if (unlikely(gfpflags & __GFP_ZERO) && object)
 		memset(object, 0, s->objsize);
 
-	kmemcheck_slab_alloc(s, gfpflags, object, s->objsize);
-	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, gfpflags);
+	slab_post_alloc_hook(s, gfpflags, object);
 
 	return object;
 }
@@ -1856,13 +1883,13 @@ static __always_inline void slab_free(st
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
