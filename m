Date: Fri, 14 Sep 2007 15:16:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Simplify IRQ off handling
Message-ID: <Pine.LNX.4.64.0709141515550.14763@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Move irq handling out of new slab into __slab_alloc. That is useful
for Mathieu's cmpxchg_local patchset and also allows us to remove the
crude local_irq_off in early_kmem_cache_alloc().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-09-14 13:54:47.000000000 -0700
@@ -1063,9 +1063,6 @@ static struct page *new_slab(struct kmem
 
 	BUG_ON(flags & ~(GFP_DMA | __GFP_ZERO | GFP_LEVEL_MASK));
 
-	if (flags & __GFP_WAIT)
-		local_irq_enable();
-
 	page = allocate_slab(s, flags & GFP_LEVEL_MASK, node);
 	if (!page)
 		goto out;
@@ -1097,8 +1094,6 @@ static struct page *new_slab(struct kmem
 	page->freelist = start;
 	page->inuse = 0;
 out:
-	if (flags & __GFP_WAIT)
-		local_irq_disable();
 	return page;
 }
 
@@ -1482,7 +1477,14 @@ new_slab:
 		goto load_freelist;
 	}
 
+	if (gfpflags & __GFP_WAIT)
+		local_irq_enable();
+
 	new = new_slab(s, gfpflags, node);
+
+	if (gfpflags & __GFP_WAIT)
+		local_irq_disable();
+
 	if (new) {
 		c = get_cpu_slab(s, smp_processor_id());
 		if (c->page) {
@@ -2017,12 +2019,6 @@ static struct kmem_cache_node * __init e
 	init_kmem_cache_node(n);
 	atomic_long_inc(&n->nr_slabs);
 	add_partial(n, page);
-
-	/*
-	 * new_slab() disables interupts. If we do not reenable interrupts here
-	 * then bootup would continue with interrupts disabled.
-	 */
-	local_irq_enable();
 	return n;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
