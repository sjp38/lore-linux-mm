Message-Id: <20071030160910.813944000@chello.nl>
References: <20071030160401.296770000@chello.nl>
Date: Tue, 30 Oct 2007 17:04:04 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/33] mm: slub: add knowledge of reserve pages
Content-Disposition: inline; filename=reserve-slab.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
contexts that are entitled to it.

Care is taken to only touch the SLUB slow path.

This is done to ensure reserve pages don't leak out and get consumed.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |   31 +++++++++++++++++++++++--------
 2 files changed, 24 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -20,11 +20,12 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include "internal.h"
 
 /*
  * Lock order:
  *   1. slab_lock(page)
- *   2. slab->list_lock
+ *   2. node->list_lock
  *
  *   The slab_lock protects operations on the object of a particular
  *   slab and its metadata in the page struct. If the slab lock
@@ -1074,7 +1075,7 @@ static void setup_object(struct kmem_cac
 		s->ctor(s, object);
 }
 
-static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, int *reserve)
 {
 	struct page *page;
 	struct kmem_cache_node *n;
@@ -1090,6 +1091,7 @@ static struct page *new_slab(struct kmem
 	if (!page)
 		goto out;
 
+	*reserve = page->reserve;
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
@@ -1468,10 +1470,22 @@ static void *__slab_alloc(struct kmem_ca
 {
 	void **object;
 	struct page *new;
+	int reserve = 0;
 
 	if (!c->page)
 		goto new_slab;
 
+	if (unlikely(c->reserve)) {
+		/*
+		 * If the current slab is a reserve slab and the current
+		 * allocation context does not allow access to the reserves
+		 * we must force an allocation to test the current levels.
+		 */
+		if (!(gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
+			goto alloc_slab;
+		reserve = 1;
+	}
+
 	slab_lock(c->page);
 	if (unlikely(!node_match(c, node)))
 		goto another_slab;
@@ -1479,10 +1493,9 @@ load_freelist:
 	object = c->page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (unlikely(SlabDebug(c->page)))
+	if (unlikely(SlabDebug(c->page) || reserve))
 		goto debug;
 
-	object = c->page->freelist;
 	c->freelist = object[c->offset];
 	c->page->inuse = s->objects;
 	c->page->freelist = NULL;
@@ -1500,16 +1513,18 @@ new_slab:
 		goto load_freelist;
 	}
 
+alloc_slab:
 	if (gfpflags & __GFP_WAIT)
 		local_irq_enable();
 
-	new = new_slab(s, gfpflags, node);
+	new = new_slab(s, gfpflags, node, &reserve);
 
 	if (gfpflags & __GFP_WAIT)
 		local_irq_disable();
 
 	if (new) {
 		c = get_cpu_slab(s, smp_processor_id());
+		c->reserve = reserve;
 		if (c->page) {
 			/*
 			 * Someone else populated the cpu_slab while we
@@ -1537,8 +1552,7 @@ new_slab:
 	}
 	return NULL;
 debug:
-	object = c->page->freelist;
-	if (!alloc_debug_processing(s, c->page, object, addr))
+	if (SlabDebug(c->page) && !alloc_debug_processing(s, c->page, object, addr))
 		goto another_slab;
 
 	c->page->inuse++;
@@ -2010,10 +2024,11 @@ static struct kmem_cache_node *early_kme
 {
 	struct page *page;
 	struct kmem_cache_node *n;
+	int reserve;
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmalloc_caches, gfpflags, node);
+	page = new_slab(kmalloc_caches, gfpflags, node, &reserve);
 
 	BUG_ON(!page);
 	if (page_to_nid(page) != node) {
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h
+++ linux-2.6/include/linux/slub_def.h
@@ -17,6 +17,7 @@ struct kmem_cache_cpu {
 	int node;
 	unsigned int offset;
 	unsigned int objsize;
+	int reserve;
 };
 
 struct kmem_cache_node {

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
