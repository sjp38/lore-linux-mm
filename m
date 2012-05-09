Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 4E8A46B0116
	for <linux-mm@kvack.org>; Wed,  9 May 2012 11:10:09 -0400 (EDT)
Message-Id: <20120509151007.365973198@linux.com>
Date: Wed, 09 May 2012 10:09:51 -0500
From: cl@linux.com
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 1/9] slub: Use freelist instead of "object" in __slab_alloc
References: <20120509150950.243797150@linux.com>
Content-Disposition: inline; filename=use_freelist_instead_of_object
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

The variable "object" really refers to a list of objects that we
are handling.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   38 ++++++++++++++++++++------------------
 1 file changed, 20 insertions(+), 18 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-04-09 09:54:31.036589056 -0500
+++ linux-2.6/mm/slub.c	2012-04-10 10:32:54.322751065 -0500
@@ -2127,7 +2127,7 @@ slab_out_of_memory(struct kmem_cache *s,
 static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 			int node, struct kmem_cache_cpu **pc)
 {
-	void *object;
+	void *freelist;
 	struct kmem_cache_cpu *c;
 	struct page *page = new_slab(s, flags, node);
 
@@ -2140,7 +2140,7 @@ static inline void *new_slab_objects(str
 		 * No other reference to the page yet so we can
 		 * muck around with it freely without cmpxchg
 		 */
-		object = page->freelist;
+		freelist = page->freelist;
 		page->freelist = NULL;
 
 		stat(s, ALLOC_SLAB);
@@ -2148,9 +2148,9 @@ static inline void *new_slab_objects(str
 		c->page = page;
 		*pc = c;
 	} else
-		object = NULL;
+		freelist = NULL;
 
-	return object;
+	return freelist;
 }
 
 /*
@@ -2170,6 +2170,7 @@ static inline void *get_freelist(struct
 	do {
 		freelist = page->freelist;
 		counters = page->counters;
+
 		new.counters = counters;
 		VM_BUG_ON(!new.frozen);
 
@@ -2203,7 +2204,7 @@ static inline void *get_freelist(struct
 static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 			  unsigned long addr, struct kmem_cache_cpu *c)
 {
-	void **object;
+	void *freelist;
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -2219,6 +2220,7 @@ static void *__slab_alloc(struct kmem_ca
 	if (!c->page)
 		goto new_slab;
 redo:
+
 	if (unlikely(!node_match(c, node))) {
 		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, c);
@@ -2226,15 +2228,15 @@ redo:
 	}
 
 	/* must check again c->freelist in case of cpu migration or IRQ */
-	object = c->freelist;
-	if (object)
+	freelist = c->freelist;
+	if (freelist)
 		goto load_freelist;
 
 	stat(s, ALLOC_SLOWPATH);
 
-	object = get_freelist(s, c->page);
+	freelist = get_freelist(s, c->page);
 
-	if (!object) {
+	if (!freelist) {
 		c->page = NULL;
 		stat(s, DEACTIVATE_BYPASS);
 		goto new_slab;
@@ -2243,10 +2245,10 @@ redo:
 	stat(s, ALLOC_REFILL);
 
 load_freelist:
-	c->freelist = get_freepointer(s, object);
+	c->freelist = get_freepointer(s, freelist);
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
-	return object;
+	return freelist;
 
 new_slab:
 
@@ -2260,13 +2262,13 @@ new_slab:
 	}
 
 	/* Then do expensive stuff like retrieving pages from the partial lists */
-	object = get_partial(s, gfpflags, node, c);
+	freelist = get_partial(s, gfpflags, node, c);
 
-	if (unlikely(!object)) {
+	if (unlikely(!freelist)) {
 
-		object = new_slab_objects(s, gfpflags, node, &c);
+		freelist = new_slab_objects(s, gfpflags, node, &c);
 
-		if (unlikely(!object)) {
+		if (unlikely(!freelist)) {
 			if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 				slab_out_of_memory(s, gfpflags, node);
 
@@ -2279,14 +2281,14 @@ new_slab:
 		goto load_freelist;
 
 	/* Only entered in the debug case */
-	if (!alloc_debug_processing(s, c->page, object, addr))
+	if (!alloc_debug_processing(s, c->page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
-	c->freelist = get_freepointer(s, object);
+	c->freelist = get_freepointer(s, freelist);
 	deactivate_slab(s, c);
 	c->node = NUMA_NO_NODE;
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
