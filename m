Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 051026B0096
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:37 -0500 (EST)
Message-Id: <20111111200735.800480462@linux.com>
Date: Fri, 11 Nov 2011 14:07:27 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 16/18] slub: Drop page field from kmem_cache_cpu
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=drop_kmem_cache_cpu_page
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

The page field can be calculated from the freelist pointer because

	page == virt_to_head_page(object)

This introduces additional inefficiencies since the determination of the
page can be complex.

We then end up with a special case for freelist == NULL because we can then no
longer determine which page is the active per cpu slab. Therefore we must
deactivate the slab page when the last object is allocated from the per cpu
list.

This patch in effect makes the slub allocator paths also lockless and no longer
requires a disabling of interrupts or preemption.

Signed-off-by: Christoph Lameter <cl@linux.com>



---
 mm/slub.c |  150 ++++++++++++++++++++++++++------------------------------------
 1 file changed, 65 insertions(+), 85 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-10 14:22:31.000000000 -0600
+++ linux-2.6/mm/slub.c	2011-11-10 14:23:54.971978776 -0600
@@ -1972,11 +1972,11 @@ int put_cpu_partial(struct kmem_cache *s
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	stat(s, CPUSLAB_FLUSH);
-	deactivate_slab(s, c->page, c->freelist);
-
-	c->tid = next_tid(c->tid);
-	c->page = NULL;
-	c->freelist = NULL;
+	if (c->freelist) {
+		deactivate_slab(s, virt_to_head_page(c->freelist), c->freelist);
+		c->tid = next_tid(c->tid);
+		c->freelist = NULL;
+}
 }
 
 /*
@@ -1988,9 +1988,8 @@ static inline void __flush_cpu_slab(stru
 {
 	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
-	if (likely(c)) {
-		if (c->page)
-			flush_slab(s, c);
+	if (likely(c->freelist)) {
+		flush_slab(s, c);
 
 		unfreeze_partials(s);
 	}
@@ -2088,9 +2087,9 @@ static inline void *new_slab_objects(str
 			int node)
 {
 	void *freelist;
-	struct kmem_cache_cpu *c;
 	struct page *page;
 
+	/* Per node partial list */
 	freelist = get_partial(s, flags, node);
 
 	if (freelist)
@@ -2098,10 +2097,6 @@ static inline void *new_slab_objects(str
 
 	page = new_slab(s, flags, node);
 	if (page) {
-		c = __this_cpu_ptr(s->cpu_slab);
-		if (c->page)
-			flush_slab(s, c);
-
 		/*
 		 * No other reference to the page yet so we can
 		 * muck around with it freely without cmpxchg
@@ -2216,92 +2211,72 @@ static inline void *get_freelist(struct
  * a call to the page allocator and the setup of a new slab.
  */
 static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
-			  unsigned long addr, struct kmem_cache_cpu *c)
+		unsigned long addr)
 {
 	void *freelist;
 	struct page *page;
-	unsigned long flags;
-
-	local_irq_save(flags);
-#ifdef CONFIG_PREEMPT
-	/*
-	 * We may have been preempted and rescheduled on a different
-	 * cpu before disabling interrupts. Need to reload cpu area
-	 * pointer.
-	 */
-	c = this_cpu_ptr(s->cpu_slab);
-#endif
-
-	page = c->page;
-	if (!page)
-		goto new_slab;
-redo:
-
-	if (unlikely(!node_match(page, node))) {
-		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, page, c->freelist);
-		c->page = NULL;
-		c->freelist = NULL;
-		goto new_slab;
-	}
 
 	stat(s, ALLOC_SLOWPATH);
 
-	freelist = get_freelist(s, page);
+retry:
+	freelist = get_cpu_objects(s);
+	/* Try per cpu partial list */
+	if (!freelist) {
+
+		page = this_cpu_read(s->cpu_slab->partial);
+		if (page && this_cpu_cmpxchg(s->cpu_slab->partial,
+				page, page->next) == page) {
+			stat(s, CPU_PARTIAL_ALLOC);
+			freelist = get_freelist(s, page);
+		}
+	} else
+		page = virt_to_head_page(freelist);
 
-	if (unlikely(!freelist)) {
-		c->page = NULL;
-		stat(s, DEACTIVATE_BYPASS);
-		goto new_slab;
+	if (freelist) {
+		if (likely(node_match(page, node)))
+			stat(s, ALLOC_REFILL);
+		else {
+			stat(s, ALLOC_NODE_MISMATCH);
+			deactivate_slab(s, page, freelist);
+			freelist = NULL;
+		}
 	}
 
-	stat(s, ALLOC_REFILL);
-
-load_freelist:
-	/*
-	 * freelist is pointing to the list of objects to be used.
-	 * page is pointing to the page from which the objects are obtained.
-	 */
-	VM_BUG_ON(!c->page->frozen);
-	c->freelist = get_freepointer(s, freelist);
-	c->tid = next_tid(c->tid);
-	local_irq_restore(flags);
-	return freelist;
-
-new_slab:
-
-	if (c->partial) {
-		page = c->page = c->partial;
-		c->partial = page->next;
-		stat(s, CPU_PARTIAL_ALLOC);
-		c->freelist = NULL;
-		goto redo;
+	/* Allocate a new slab */
+	if (!freelist) {
+		freelist = new_slab_objects(s, gfpflags, node);
+		if (freelist)
+			page = virt_to_head_page(freelist);
 	}
 
-	freelist = new_slab_objects(s, gfpflags, node);
-
-
-	if (unlikely(!freelist)) {
+	/* If nothing worked then fail */
+	if (!freelist) {
 		if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 			slab_out_of_memory(s, gfpflags, node);
 
-		local_irq_restore(flags);
 		return NULL;
 	}
 
-	page = c->page = virt_to_head_page(freelist);
+	if (unlikely(kmem_cache_debug(s)) &&
+				!alloc_debug_processing(s, page, freelist, addr))
+			goto retry;
+
+	VM_BUG_ON(!page->frozen);
+
+	{
+		void *next = get_freepointer(s, freelist);
 
-	if (likely(!kmem_cache_debug(s)))
-		goto load_freelist;
+		if (!next)
+			/*
+			 * last object so we either unfreeze the page or
+			 * get more objects.
+			 */
+			next = get_freelist(s, page);
+
+		if (next)
+			put_cpu_objects(s, page, next);
+	}
 
-	/* Only entered in the debug case */
-	if (!alloc_debug_processing(s, page, freelist, addr))
-		goto new_slab;	/* Slab failed checks. Next slab needed */
-	deactivate_slab(s, page, get_freepointer(s, freelist));
-
-	c->page = NULL;
-	c->freelist = NULL;
-	local_irq_restore(flags);
 	return freelist;
 }
 
@@ -2320,7 +2295,7 @@ static __always_inline void *slab_alloc(
 {
 	void **object;
 	struct kmem_cache_cpu *c;
-	struct page *page;
+	struct page *page = NULL;
 	unsigned long tid;
 
 	if (slab_pre_alloc_hook(s, gfpflags))
@@ -2346,10 +2321,9 @@ redo:
 	barrier();
 
 	object = c->freelist;
-	page = c->page;
-	if (unlikely(!object || !node_match(page, node)))
+	if (unlikely(!object || !node_match((page = virt_to_head_page(object)), node)))
 
-		object = __slab_alloc(s, gfpflags, node, addr, c);
+		object = __slab_alloc(s, gfpflags, node, addr);
 
 	else {
 		void *next = get_freepointer_safe(s, object);
@@ -2375,6 +2349,12 @@ redo:
 			goto redo;
 		}
 		stat(s, ALLOC_FASTPATH);
+		if (!next) {
+			next = get_freelist(s, page);
+			if (next)
+				/* Refill the per cpu queue */
+				put_cpu_objects(s, page, next);
+		}
 	}
 
 	if (unlikely(gfpflags & __GFP_ZERO) && object)
@@ -2593,7 +2573,7 @@ redo:
 	tid = c->tid;
 	barrier();
 
-	if (likely(page == c->page)) {
+	if (c->freelist && likely(page == virt_to_head_page(c->freelist))) {
 		set_freepointer(s, object, c->freelist);
 
 		if (unlikely(!irqsafe_cpu_cmpxchg_double(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
