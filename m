Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 608B76B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 08:07:30 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so12328730wic.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 05:07:29 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id dh3si15036585wjc.175.2015.07.10.05.07.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jul 2015 05:07:28 -0700 (PDT)
Message-Id: <20150710120259.836414367@linutronix.de>
Date: Fri, 10 Jul 2015 12:07:13 -0000
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch] mm/slub: Move slab initialization into irq enabled region
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=slub-move-slab-init-into-irq-enabled-region.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>

Initializing a new slab can introduce rather large latencies because
most of the initialization runs always with interrupts disabled.

There is no point in doing so. The newly allocated slab is not visible
yet, so there is no reason to protect it against concurrent alloc/free.

Move the expensive parts of the initialization into allocate_slab(),
so for all allocations with GFP_WAIT set, interrupts are enabled.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 mm/slub.c |   85 +++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 43 insertions(+), 42 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -1306,6 +1306,17 @@ static inline void slab_free_hook(struct
 	kasan_slab_free(s, x);
 }
 
+static void setup_object(struct kmem_cache *s, struct page *page,
+				void *object)
+{
+	setup_object_debug(s, page, object);
+	if (unlikely(s->ctor)) {
+		kasan_unpoison_object_data(s, object);
+		s->ctor(object);
+		kasan_poison_object_data(s, object);
+	}
+}
+
 /*
  * Slab allocation and freeing
  */
@@ -1336,6 +1347,8 @@ static struct page *allocate_slab(struct
 	struct page *page;
 	struct kmem_cache_order_objects oo = s->oo;
 	gfp_t alloc_gfp;
+	void *start, *p;
+	int idx, order;
 
 	flags &= gfp_allowed_mask;
 
@@ -1364,8 +1377,11 @@ static struct page *allocate_slab(struct
 			stat(s, ORDER_FALLBACK);
 	}
 
-	if (kmemcheck_enabled && page
-		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
+	if (!page)
+		goto out;
+
+	if (kmemcheck_enabled &&
+	    !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
 		int pages = 1 << oo_order(oo);
 
 		kmemcheck_alloc_shadow(page, oo_order(oo), alloc_gfp, node);
@@ -1380,51 +1396,12 @@ static struct page *allocate_slab(struct
 			kmemcheck_mark_unallocated_pages(page, pages);
 	}
 
-	if (flags & __GFP_WAIT)
-		local_irq_disable();
 	if (!page)
-		return NULL;
+		goto out;
 
 	page->objects = oo_objects(oo);
-	mod_zone_page_state(page_zone(page),
-		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
-		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
-		1 << oo_order(oo));
-
-	return page;
-}
-
-static void setup_object(struct kmem_cache *s, struct page *page,
-				void *object)
-{
-	setup_object_debug(s, page, object);
-	if (unlikely(s->ctor)) {
-		kasan_unpoison_object_data(s, object);
-		s->ctor(object);
-		kasan_poison_object_data(s, object);
-	}
-}
-
-static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
-{
-	struct page *page;
-	void *start;
-	void *p;
-	int order;
-	int idx;
-
-	if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
-		pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
-		BUG();
-	}
-
-	page = allocate_slab(s,
-		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
-	if (!page)
-		goto out;
 
 	order = compound_order(page);
-	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab_cache = s;
 	__SetPageSlab(page);
 	if (page->pfmemalloc)
@@ -1448,10 +1425,34 @@ static struct page *new_slab(struct kmem
 	page->freelist = start;
 	page->inuse = page->objects;
 	page->frozen = 1;
+
 out:
+	if (flags & __GFP_WAIT)
+		local_irq_disable();
+	if (!page)
+		return NULL;
+
+	mod_zone_page_state(page_zone(page),
+		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
+		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
+		1 << oo_order(oo));
+
+	inc_slabs_node(s, page_to_nid(page), page->objects);
+
 	return page;
 }
 
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+{
+	if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
+		pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
+		BUG();
+	}
+
+	return allocate_slab(s,
+		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
+}
+
 static void __free_slab(struct kmem_cache *s, struct page *page)
 {
 	int order = compound_order(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
