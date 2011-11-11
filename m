Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7C57E6B0070
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:30 -0500 (EST)
Message-Id: <20111111200727.668158433@linux.com>
Date: Fri, 11 Nov 2011 14:07:15 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 04/18] slub: Use freelist instead of "object" in __slab_alloc
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=use_freelist_instead_of_object
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

The variable "object" really refers to a list of objects that we
are handling. Since the lockless allocator path will depend on it
we rename the variable now.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   40 ++++++++++++++++++++++------------------
 1 file changed, 22 insertions(+), 18 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-09 11:11:13.471490305 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 11:11:22.381541568 -0600
@@ -2084,7 +2084,7 @@ slab_out_of_memory(struct kmem_cache *s,
 static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 			int node, struct kmem_cache_cpu **pc)
 {
-	void *object;
+	void *freelist;
 	struct kmem_cache_cpu *c;
 	struct page *page = new_slab(s, flags, node);
 
@@ -2097,16 +2097,16 @@ static inline void *new_slab_objects(str
 		 * No other reference to the page yet so we can
 		 * muck around with it freely without cmpxchg
 		 */
-		object = page->freelist;
+		freelist = page->freelist;
 		page->freelist = NULL;
 
 		stat(s, ALLOC_SLAB);
 		c->page = page;
 		*pc = c;
 	} else
-		object = NULL;
+		freelist = NULL;
 
-	return object;
+	return freelist;
 }
 
 /*
@@ -2159,7 +2159,7 @@ static inline void *get_freelist(struct
 static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 			  unsigned long addr, struct kmem_cache_cpu *c)
 {
-	void **object;
+	void *freelist;
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -2175,6 +2175,7 @@ static void *__slab_alloc(struct kmem_ca
 	if (!c->page)
 		goto new_slab;
 redo:
+
 	if (unlikely(!node_match(c, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, c->page, c->freelist);
@@ -2185,9 +2186,9 @@ redo:
 
 	stat(s, ALLOC_SLOWPATH);
 
-	object = get_freelist(s, c->page);
+	freelist = get_freelist(s, c->page);
 
-	if (!object) {
+	if (unlikely(!freelist)) {
 		c->page = NULL;
 		stat(s, DEACTIVATE_BYPASS);
 		goto new_slab;
@@ -2196,10 +2197,15 @@ redo:
 	stat(s, ALLOC_REFILL);
 
 load_freelist:
-	c->freelist = get_freepointer(s, object);
+	/*
+	 * freelist is pointing to the list of objects to be used.
+	 * page is pointing to the page from which the objects are obtained.
+	 */
+	VM_BUG_ON(!c->page->frozen);
+	c->freelist = get_freepointer(s, freelist);
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
-	return object;
+	return freelist;
 
 new_slab:
 
@@ -2211,14 +2217,12 @@ new_slab:
 		goto redo;
 	}
 
-	/* Then do expensive stuff like retrieving pages from the partial lists */
-	object = get_partial(s, gfpflags, node, c);
+	freelist = get_partial(s, gfpflags, node, c);
 
-	if (unlikely(!object)) {
+	if (unlikely(!freelist)) {
+		freelist = new_slab_objects(s, gfpflags, node, &c);
 
-		object = new_slab_objects(s, gfpflags, node, &c);
-
-		if (unlikely(!object)) {
+		if (unlikely(!freelist)) {
 			if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 				slab_out_of_memory(s, gfpflags, node);
 
@@ -2231,14 +2235,14 @@ new_slab:
 		goto load_freelist;
 
 	/* Only entered in the debug case */
-	if (!alloc_debug_processing(s, c->page, object, addr))
+	if (!alloc_debug_processing(s, c->page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
+	deactivate_slab(s, c->page, get_freepointer(s, freelist));
 
-	deactivate_slab(s, c->page, get_freepointer(s, object));
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
