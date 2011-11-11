Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 81C1B6B0072
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:40 -0500 (EST)
Message-Id: <20111111200737.166165123@linux.com>
Date: Fri, 11 Nov 2011 14:07:29 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 18/18] slub: Move __slab_alloc() into slab_alloc()
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=move_alloc
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Both functions are now quite small and share numerous variables.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |  170 ++++++++++++++++++++++++++------------------------------------
 1 file changed, 73 insertions(+), 97 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-11 09:33:05.056004788 -0600
+++ linux-2.6/mm/slub.c	2011-11-11 09:38:51.767942529 -0600
@@ -2195,100 +2195,13 @@ static inline void *get_freelist(struct
 }
 
 /*
- * Slow path. The lockless freelist is empty or we need to perform
- * debugging duties.
+ * Main allocation function. First try to allocate from per cpu
+ * object list, if empty replenish list from per cpu page list,
+ * then from the per node partial list. Finally go to the
+ * page allocator if nothing else is available.
  *
- * Processing is still very fast if new objects have been freed to the
- * regular freelist. In that case we simply take over the regular freelist
- * as the lockless freelist and zap the regular freelist.
- *
- * If that is not working then we fall back to the partial lists. We take the
- * first element of the freelist as the object to allocate now and move the
- * rest of the freelist to the lockless freelist.
- *
- * And if we were unable to get a new slab from the partial slab lists then
- * we need to allocate a new slab. This is the slowest path since it involves
- * a call to the page allocator and the setup of a new slab.
- */
-static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
-		unsigned long addr)
-{
-	void *freelist;
-	struct page *page;
-
-	stat(s, ALLOC_SLOWPATH);
-
-retry:
-	freelist = get_cpu_objects(s);
-	/* Try per cpu partial list */
-	if (!freelist) {
-
-		page = this_cpu_read(s->cpu_slab->partial);
-		if (page && this_cpu_cmpxchg(s->cpu_slab->partial,
-				page, page->next) == page) {
-			stat(s, CPU_PARTIAL_ALLOC);
-			freelist = get_freelist(s, page);
-		}
-	} else
-		page = virt_to_head_page(freelist);
-
-	if (freelist) {
-		if (likely(node_match(page, node)))
-			stat(s, ALLOC_REFILL);
-		else {
-			stat(s, ALLOC_NODE_MISMATCH);
-			deactivate_slab(s, page, freelist);
-			freelist = NULL;
-		}
-	}
-
-	/* Allocate a new slab */
-	if (!freelist) {
-		freelist = new_slab_objects(s, gfpflags, node);
-		if (freelist)
-			page = virt_to_head_page(freelist);
-	}
-
-	/* If nothing worked then fail */
-	if (!freelist) {
-		if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
-			slab_out_of_memory(s, gfpflags, node);
-
-		return NULL;
-	}
-
-	if (unlikely(kmem_cache_debug(s)) &&
-				!alloc_debug_processing(s, page, freelist, addr))
-			goto retry;
-
-	VM_BUG_ON(!page->frozen);
-
-	{
-		void *next = get_freepointer(s, freelist);
-
-		if (!next)
-			/*
-			 * last object so we either unfreeze the page or
-			 * get more objects.
-			 */
-			next = get_freelist(s, page);
-
-		if (next)
-			put_cpu_objects(s, page, next);
-	}
-
-	return freelist;
-}
-
-/*
- * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
- * have the fastpath folded into their functions. So no function call
- * overhead for requests that can be satisfied on the fastpath.
- *
- * The fastpath works by first checking if the lockless freelist can be used.
- * If not then __slab_alloc is called for slow processing.
- *
- * Otherwise we can simply pick the next object from the lockless free list.
+ * This is one of the most performance critical function of the
+ * Linux kernel.
  */
 static void *slab_alloc(struct kmem_cache *s,
 		gfp_t gfpflags, int node, unsigned long addr)
@@ -2321,11 +2234,8 @@ redo:
 	barrier();
 
 	object = c->freelist;
-	if (unlikely(!object || !node_match((page = virt_to_head_page(object)), node)))
+	if (likely(object && node_match((page = virt_to_head_page(object)), node))) {
 
-		object = __slab_alloc(s, gfpflags, node, addr);
-
-	else {
 		void *next = get_freepointer_safe(s, object);
 
 		/*
@@ -2355,8 +2265,74 @@ redo:
 				/* Refill the per cpu queue */
 				put_cpu_objects(s, page, next);
 		}
+
+	} else {
+
+		void *freelist;
+
+		stat(s, ALLOC_SLOWPATH);
+
+retry:
+		freelist = get_cpu_objects(s);
+		/* Try per cpu partial list */
+		if (!freelist) {
+
+			page = this_cpu_read(s->cpu_slab->partial);
+			if (page && this_cpu_cmpxchg(s->cpu_slab->partial,
+					page, page->next) == page) {
+				stat(s, CPU_PARTIAL_ALLOC);
+				freelist = get_freelist(s, page);
+			}
+		} else
+			page = virt_to_head_page(freelist);
+
+		if (freelist) {
+			if (likely(node_match(page, node)))
+				stat(s, ALLOC_REFILL);
+			else {
+				stat(s, ALLOC_NODE_MISMATCH);
+				deactivate_slab(s, page, freelist);
+				freelist = NULL;
+			}
+		}
+
+		/* Allocate a new slab */
+		if (!freelist) {
+			freelist = new_slab_objects(s, gfpflags, node);
+			if (freelist)
+				page = virt_to_head_page(freelist);
+		}
+
+		/* If nothing worked then fail */
+		if (!freelist) {
+			if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
+				slab_out_of_memory(s, gfpflags, node);
+
+			return NULL;
+		}
+
+		if (unlikely(kmem_cache_debug(s)) &&
+				!alloc_debug_processing(s, page, freelist, addr))
+			goto retry;
+
+		VM_BUG_ON(!page->frozen);
+
+		object = freelist;
+		freelist = get_freepointer(s, freelist);
+
+		if (!freelist)
+			/*
+			 * last object so we either unfreeze the page or
+			 * get more objects.
+			 */
+			freelist = get_freelist(s, page);
+
+		if (freelist)
+			put_cpu_objects(s, page, freelist);
+
 	}
 
+
 	if (unlikely(gfpflags & __GFP_ZERO) && object)
 		memset(object, 0, s->objsize);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
