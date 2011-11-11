Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7D75E6B0073
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:39 -0500 (EST)
Message-Id: <20111111200736.489943908@linux.com>
Date: Fri, 11 Nov 2011 14:07:28 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 17/18] slub: Move __slab_free() into slab_free()
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=move_kfree
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Both functions now share variables and the control flow is easier to follow
as a single function.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |  173 ++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 84 insertions(+), 89 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-11 09:33:03.545996392 -0600
+++ linux-2.6/mm/slub.c	2011-11-11 09:42:39.619212550 -0600
@@ -2290,7 +2290,7 @@ retry:
  *
  * Otherwise we can simply pick the next object from the lockless free list.
  */
-static __always_inline void *slab_alloc(struct kmem_cache *s,
+static void *slab_alloc(struct kmem_cache *s,
 		gfp_t gfpflags, int node, unsigned long addr)
 {
 	void **object;
@@ -2421,30 +2421,69 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trac
 #endif
 
 /*
- * Slow patch handling. This may still be called frequently since objects
- * have a longer lifetime than the cpu slabs in most processing loads.
- *
- * So we still attempt to reduce cache line usage. Just take the slab
- * lock and free the item. If there is no additional partial page
- * handling required then we can return immediately.
+ * Free an object. First see if the object is from the per cpu slab.
+ * if so then it can be freed to the per cpu queue. Otherwise we have
+ * to free the object to the free queue of the slab page.
  */
-static void __slab_free(struct kmem_cache *s, struct page *page,
-			void *x, unsigned long addr)
+static void slab_free(struct kmem_cache *s,
+			struct page *page, void *x, unsigned long addr)
 {
-	void *prior;
+	struct kmem_cache_node *n = NULL;
 	void **object = (void *)x;
+	struct kmem_cache_cpu *c;
+	unsigned long tid;
+	void *prior;
 	int was_frozen;
 	int inuse;
-	struct page new;
 	unsigned long counters;
-	struct kmem_cache_node *n = NULL;
 	unsigned long uninitialized_var(flags);
+	struct page new;
 
-	stat(s, FREE_SLOWPATH);
+
+	slab_free_hook(s, x);
+
+	/*
+	 * First see if we can free to the per cpu list in kmem_cache_cpu
+	 */
+	do {
+		/*
+		 * Determine the currently cpus per cpu slab.
+		 * The cpu may change afterward. However that does not matter since
+		 * data is retrieved via this pointer. If we are on the same cpu
+		 * during the cmpxchg then the free will succeed.
+		 */
+		c = __this_cpu_ptr(s->cpu_slab);
+
+		tid = c->tid;
+		barrier();
+
+		if (!c->freelist || unlikely(page != virt_to_head_page(c->freelist)))
+			break;
+
+		set_freepointer(s, object, c->freelist);
+
+		if (likely(irqsafe_cpu_cmpxchg_double(
+				s->cpu_slab->freelist, s->cpu_slab->tid,
+				c->freelist, tid,
+				object, next_tid(tid)))) {
+
+			stat(s, FREE_FASTPATH);
+			return;
+
+		}
+
+		note_cmpxchg_failure("slab_free", s, tid);
+
+	} while (1);
 
 	if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
 		return;
 
+	stat(s, FREE_SLOWPATH);
+
+	/*
+ 	 * Put the object onto the slab pages freelist.
+	 */
 	do {
 		prior = page->freelist;
 		counters = page->counters;
@@ -2484,6 +2523,10 @@ static void __slab_free(struct kmem_cach
 		object, new.counters,
 		"__slab_free"));
 
+
+	if (was_frozen)
+		stat(s, FREE_FROZEN);
+
 	if (likely(!n)) {
 
 		/*
@@ -2497,20 +2540,37 @@ static void __slab_free(struct kmem_cach
 		 * The list lock was not taken therefore no list
 		 * activity can be necessary.
 		 */
-                if (was_frozen)
-                        stat(s, FREE_FROZEN);
-                return;
-        }
+		return;
+	}
 
 	/*
-	 * was_frozen may have been set after we acquired the list_lock in
-	 * an earlier loop. So we need to check it here again.
+	 * List lock was taken. We have to deal with additional
+	 * complexer processing.
 	 */
-	if (was_frozen)
-		stat(s, FREE_FROZEN);
-	else {
-		if (unlikely(!inuse && n->nr_partial > s->min_partial))
-                        goto slab_empty;
+	if (!was_frozen) {
+
+		/*
+		 * Only if the slab page was not frozen will we have to do
+		 * list update activities.
+		 */
+		if (unlikely(!inuse && n->nr_partial > s->min_partial)) {
+
+			/* Slab is now empty and could be freed */
+			if (prior) {
+				/*
+				 * Slab was on the partial list.
+				 */
+				remove_partial(n, page);
+				stat(s, FREE_REMOVE_PARTIAL);
+			} else
+				/* Slab must be on the full list */
+				remove_full(s, page);
+
+			spin_unlock_irqrestore(&n->list_lock, flags);
+			stat(s, FREE_SLAB);
+			discard_slab(s, page);
+			return;
+		}
 
 		/*
 		 * Objects left in the slab. If it was not on the partial list before
@@ -2523,71 +2583,6 @@ static void __slab_free(struct kmem_cach
 		}
 	}
 	spin_unlock_irqrestore(&n->list_lock, flags);
-	return;
-
-slab_empty:
-	if (prior) {
-		/*
-		 * Slab on the partial list.
-		 */
-		remove_partial(n, page);
-		stat(s, FREE_REMOVE_PARTIAL);
-	} else
-		/* Slab must be on the full list */
-		remove_full(s, page);
-
-	spin_unlock_irqrestore(&n->list_lock, flags);
-	stat(s, FREE_SLAB);
-	discard_slab(s, page);
-}
-
-/*
- * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
- * can perform fastpath freeing without additional function calls.
- *
- * The fastpath is only possible if we are freeing to the current cpu slab
- * of this processor. This typically the case if we have just allocated
- * the item before.
- *
- * If fastpath is not possible then fall back to __slab_free where we deal
- * with all sorts of special processing.
- */
-static __always_inline void slab_free(struct kmem_cache *s,
-			struct page *page, void *x, unsigned long addr)
-{
-	void **object = (void *)x;
-	struct kmem_cache_cpu *c;
-	unsigned long tid;
-
-	slab_free_hook(s, x);
-
-redo:
-	/*
-	 * Determine the currently cpus per cpu slab.
-	 * The cpu may change afterward. However that does not matter since
-	 * data is retrieved via this pointer. If we are on the same cpu
-	 * during the cmpxchg then the free will succedd.
-	 */
-	c = __this_cpu_ptr(s->cpu_slab);
-
-	tid = c->tid;
-	barrier();
-
-	if (c->freelist && likely(page == virt_to_head_page(c->freelist))) {
-		set_freepointer(s, object, c->freelist);
-
-		if (unlikely(!irqsafe_cpu_cmpxchg_double(
-				s->cpu_slab->freelist, s->cpu_slab->tid,
-				c->freelist, tid,
-				object, next_tid(tid)))) {
-
-			note_cmpxchg_failure("slab_free", s, tid);
-			goto redo;
-		}
-		stat(s, FREE_FASTPATH);
-	} else
-		__slab_free(s, page, x, addr);
-
 }
 
 void kmem_cache_free(struct kmem_cache *s, void *x)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
