Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 42253900146
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:48:05 -0400 (EDT)
Message-Id: <20110902204746.113275791@linux.com>
Date: Fri, 02 Sep 2011 15:47:09 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 12/12] slub: Drop page field from kmem_cache_cpu
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=drop_kmem_cache_cpu_page
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

The page field can be calculated from the freelist pointer because

	page == virt_to_head_page(object)

This introduces additional inefficiencies since the calculation is complex.

We then end up with a special case for freelist == NULL because we can then no
longer determine which page is the active per cpu slab. Therefore we must
deactivate the slab page when the last object is allocated from the per cpu
list.

This patch in effect makes the slub allocator paths also lockless and no longer
requiring a disabling of interrupts or preemption.

Signed-off-by: Christoph Lameter <cl@linux.com>



---
 mm/slub.c |  140 ++++++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 92 insertions(+), 48 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-09-02 10:12:30.881176403 -0500
+++ linux-2.6/mm/slub.c	2011-09-02 10:12:50.291176282 -0500
@@ -1906,11 +1906,11 @@ redo:
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
@@ -1922,7 +1922,7 @@ static inline void __flush_cpu_slab(stru
 {
 	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
-	if (likely(c && c->page))
+	if (likely(c && c->freelist))
 		flush_slab(s, c);
 }
 
@@ -2015,6 +2015,55 @@ slab_out_of_memory(struct kmem_cache *s,
 }
 
 /*
+ * Retrieve pointer to the current freelist and
+ * zap the per cpu object list.
+ *
+ * Returns NULL if there was no object on the freelist.
+ */
+void *get_cpu_objects(struct kmem_cache *s)
+{
+	void *freelist;
+	unsigned long tid;
+
+	do {
+		struct kmem_cache_cpu *c = this_cpu_ptr(s->cpu_slab);
+
+		tid = c->tid;
+		barrier();
+		freelist = c->freelist;
+		if (!freelist)
+			return NULL;
+
+	} while (!this_cpu_cmpxchg_double(s->cpu_slab->freelist, s->cpu_slab->tid,
+			freelist, tid,
+			NULL, next_tid(tid)));
+
+	return freelist;
+}
+
+/*
+ * Set the per cpu object list to the freelist. The page must
+ * be frozen.
+ *
+ * Page will be unfrozen (and the freelist object put onto the pages freelist)
+ * if the per cpu freelist has been used in the meantime.
+ */
+static inline void put_cpu_objects(struct kmem_cache *s,
+				struct page *page, void *freelist)
+{
+	unsigned long tid = this_cpu_read(s->cpu_slab->tid);
+
+	VM_BUG_ON(!page->frozen);
+	if (!irqsafe_cpu_cmpxchg_double(s->cpu_slab->freelist, s->cpu_slab->tid,
+		NULL, tid, freelist, next_tid(tid)))
+
+		/*
+		 * There was an intervening free or alloc. Cannot free to the
+		 * per cpu queue. Must unfreeze page.
+		 */
+		deactivate_slab(s, page, freelist);
+}
+/*
  * Check the page->freelist of a page and either transfer the freelist to the per cpu freelist
  * or deactivate the page.
  *
@@ -2064,33 +2113,21 @@ static inline void *get_freelist(struct
  * a call to the page allocator and the setup of a new slab.
  */
 static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
-			  unsigned long addr, struct kmem_cache_cpu *c)
+			  unsigned long addr)
 {
-	void *freelist;
+	void *freelist, *next;
 	struct page *page;
-	unsigned long flags;
 
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
-	freelist = c->freelist;
-	page = c->page;
-	if (!page)
+	freelist = get_cpu_objects(s);
+	if (!freelist)
 		goto new_slab;
 
+	page = virt_to_head_page(freelist);
+	BUG_ON(!page->frozen);
 
 	if (unlikely(!node_match(page, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, page, freelist);
-		c->page = NULL;
-		c->freelist = NULL;
 		goto new_slab;
 	}
 
@@ -2099,7 +2136,6 @@ static void *__slab_alloc(struct kmem_ca
 	freelist = get_freelist(s, page);
 
 	if (unlikely(!freelist)) {
-		c->page = NULL;
 		stat(s, DEACTIVATE_BYPASS);
 		goto new_slab;
 	}
@@ -2111,10 +2147,19 @@ load_freelist:
 	 * freelist is pointing to the list of objects to be used.
 	 * page is pointing to the page from which the objects are obtained.
 	 */
+	next = get_freepointer(s, freelist);
 	VM_BUG_ON(!page->frozen);
-	c->freelist = get_freepointer(s, freelist);
-	c->tid = next_tid(c->tid);
-	local_irq_restore(flags);
+
+	if (!next)
+		/*
+		 * last object so we either unfreeze the page or
+		 * get more objects.
+		 */
+		next = get_freelist(s, page);
+
+	if (next)
+		put_cpu_objects(s, page, next);
+
 	return freelist;
 
 new_slab:
@@ -2122,7 +2167,6 @@ new_slab:
 	if (page) {
 		stat(s, ALLOC_FROM_PARTIAL);
 		freelist = page->lru.next;
-		c->page  = page;
 		if (kmem_cache_debug(s))
 			goto debug;
 		goto load_freelist;
@@ -2131,10 +2175,6 @@ new_slab:
 	page = new_slab(s, gfpflags, node);
 
 	if (page) {
-		c = __this_cpu_ptr(s->cpu_slab);
-		if (c->page)
-			flush_slab(s, c);
-
 		/*
 		 * No other reference to the page yet so we can
 		 * muck around with it freely without cmpxchg
@@ -2144,7 +2184,6 @@ new_slab:
 		page->inuse = page->objects;
 
 		stat(s, ALLOC_SLAB);
-		c->page = page;
 
 		if (kmem_cache_debug(s))
 			goto debug;
@@ -2152,17 +2191,13 @@ new_slab:
 	}
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 		slab_out_of_memory(s, gfpflags, node);
-	local_irq_restore(flags);
 	return NULL;
 
 debug:
 	if (!freelist || !alloc_debug_processing(s, page, freelist, addr))
 		goto new_slab;
 
-	deactivate_slab(s, c->page, get_freepointer(s, freelist));
-	c->page = NULL;
-	c->freelist = NULL;
-	local_irq_restore(flags);
+	deactivate_slab(s, page, get_freepointer(s, freelist));
 	return freelist;
 }
 
@@ -2207,12 +2242,13 @@ redo:
 	barrier();
 
 	object = c->freelist;
-	page = c->page;
-	if (unlikely(!object || !node_match(page, node)))
+	if (unlikely(!object || !node_match((page = virt_to_head_page(object)), node)))
 
-		object = __slab_alloc(s, gfpflags, node, addr, c);
+		object = __slab_alloc(s, gfpflags, node, addr);
 
 	else {
+		void *next = get_freepointer_safe(s, object);
+
 		/*
 		 * The cmpxchg will only match if there was no additional
 		 * operation and if we are on the right processor.
@@ -2228,12 +2264,18 @@ redo:
 		if (unlikely(!irqsafe_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
 				object, tid,
-				get_freepointer_safe(s, object), next_tid(tid)))) {
+				next, next_tid(tid)))) {
 
 			note_cmpxchg_failure("slab_alloc", s, tid);
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
@@ -2432,7 +2474,7 @@ redo:
 	tid = c->tid;
 	barrier();
 
-	if (likely(page == c->page)) {
+	if (c->freelist && likely(page == virt_to_head_page(c->freelist))) {
 		set_freepointer(s, object, c->freelist);
 
 		if (unlikely(!irqsafe_cpu_cmpxchg_double(
@@ -4318,16 +4360,18 @@ static ssize_t show_slab_objects(struct
 
 		for_each_possible_cpu(cpu) {
 			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+			struct page *page;
 
 			if (!c || !c->freelist)
 				continue;
 
-			node = page_to_nid(c->page);
-			if (c->page) {
+			page = virt_to_head_page(c->freelist);
+			node = page_to_nid(page);
+			if (page) {
 					if (flags & SO_TOTAL)
-						x = c->page->objects;
+						x = page->objects;
 				else if (flags & SO_OBJECTS)
-					x = c->page->inuse;
+					x = page->inuse;
 				else
 					x = 1;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
