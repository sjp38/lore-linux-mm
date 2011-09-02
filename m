Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7B2C490014D
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:45 -0400 (EDT)
Message-Id: <20110902204742.620566119@linux.com>
Date: Fri, 02 Sep 2011 15:47:03 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 06/12] slub: Use freelist instead of "object" in __slab_alloc
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=use_freelist_instead_of_object
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

The variable "object" really refers to a list of objects that we
are handling. Since the lockless allocator path will depend on it
we rename the variable now.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-09-02 08:20:32.491219417 -0500
+++ linux-2.6/mm/slub.c	2011-09-02 08:20:39.221219372 -0500
@@ -2075,7 +2075,7 @@ static inline void *get_freelist(struct
 static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 			  unsigned long addr, struct kmem_cache_cpu *c)
 {
-	void **object;
+	void *freelist;
 	struct page *page;
 	unsigned long flags;
 
@@ -2089,13 +2089,15 @@ static void *__slab_alloc(struct kmem_ca
 	c = this_cpu_ptr(s->cpu_slab);
 #endif
 
+	freelist = c->freelist;
 	page = c->page;
 	if (!page)
 		goto new_slab;
 
+
 	if (unlikely(!node_match(c, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, c->page, c->freelist);
+		deactivate_slab(s, page, freelist);
 		c->page = NULL;
 		c->freelist = NULL;
 		goto new_slab;
@@ -2103,9 +2105,9 @@ static void *__slab_alloc(struct kmem_ca
 
 	stat(s, ALLOC_SLOWPATH);
 
-	object = get_freelist(s, page);
+	freelist = get_freelist(s, page);
 
-	if (unlikely(!object)) {
+	if (unlikely(!freelist)) {
 		c->page = NULL;
 		stat(s, DEACTIVATE_BYPASS);
 		goto new_slab;
@@ -2114,18 +2116,21 @@ static void *__slab_alloc(struct kmem_ca
 	stat(s, ALLOC_REFILL);
 
 load_freelist:
+	/*
+	 * freelist is pointing to the list of objects to be used.
+	 * page is pointing to the page from which the objects are obtained.
+	 */
 	VM_BUG_ON(!page->frozen);
-	c->freelist = get_freepointer(s, object);
+	c->freelist = get_freepointer(s, freelist);
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
-	return object;
+	return freelist;
 
 new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {
 		stat(s, ALLOC_FROM_PARTIAL);
-		object = c->freelist;
-
+		freelist = c->freelist;
 		if (kmem_cache_debug(s))
 			goto debug;
 		goto load_freelist;
@@ -2142,7 +2147,7 @@ new_slab:
 		 * No other reference to the page yet so we can
 		 * muck around with it freely without cmpxchg
 		 */
-		object = page->freelist;
+		freelist = page->freelist;
 		page->freelist = NULL;
 		page->inuse = page->objects;
 
@@ -2159,14 +2164,14 @@ new_slab:
 	return NULL;
 
 debug:
-	if (!object || !alloc_debug_processing(s, page, object, addr))
+	if (!freelist || !alloc_debug_processing(s, page, freelist, addr))
 		goto new_slab;
 
-	deactivate_slab(s, c->page, get_freepointer(s, object));
+	deactivate_slab(s, c->page, get_freepointer(s, freelist));
 	c->page = NULL;
 	c->freelist = NULL;
 	local_irq_restore(flags);
-	return object;
+	return freelist;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
