Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3A7A48D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:24:19 -0400 (EDT)
Message-Id: <20110330202416.864916763@linux.com>
Date: Wed, 30 Mar 2011 15:23:45 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubll1 03/19] slub: Eliminate repeated use of c->page through a new page variable
References: <20110330202342.669400887@linux.com>
Content-Disposition: inline; filename=avoid_c_page
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

__slab_alloc is full of "c->page" repeats. Lets just use one local variable
named "page" for this. Also avoids the need to a have another variable
called "new".

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-30 14:30:24.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-30 14:30:51.000000000 -0500
@@ -1790,7 +1790,7 @@ static void *__slab_alloc(struct kmem_ca
 			  unsigned long addr, struct kmem_cache_cpu *c)
 {
 	void **object;
-	struct page *new;
+	struct page *page;
 #ifdef CONFIG_CMPXCHG_LOCAL
 	unsigned long flags;
 
@@ -1808,28 +1808,30 @@ static void *__slab_alloc(struct kmem_ca
 	/* We handle __GFP_ZERO in the caller */
 	gfpflags &= ~__GFP_ZERO;
 
-	if (!c->page)
+	page = c->page;
+	if (!page)
 		goto new_slab;
 
-	slab_lock(c->page);
+	slab_lock(page);
 	if (unlikely(!node_match(c, node)))
 		goto another_slab;
 
 	stat(s, ALLOC_REFILL);
 
 load_freelist:
-	object = c->page->freelist;
+	object = page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
 	if (kmem_cache_debug(s))
 		goto debug;
 
 	c->freelist = get_freepointer(s, object);
-	c->page->inuse = c->page->objects;
-	c->page->freelist = NULL;
-	c->node = page_to_nid(c->page);
+	page->inuse = page->objects;
+	page->freelist = NULL;
+	c->node = page_to_nid(page);
+
 unlock_out:
-	slab_unlock(c->page);
+	slab_unlock(page);
 #ifdef CONFIG_CMPXCHG_LOCAL
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
@@ -1841,9 +1843,9 @@ another_slab:
 	deactivate_slab(s, c);
 
 new_slab:
-	new = get_partial(s, gfpflags, node);
-	if (new) {
-		c->page = new;
+	page = get_partial(s, gfpflags, node);
+	if (page) {
+		c->page = page;
 		stat(s, ALLOC_FROM_PARTIAL);
 		goto load_freelist;
 	}
@@ -1852,19 +1854,20 @@ new_slab:
 	if (gfpflags & __GFP_WAIT)
 		local_irq_enable();
 
-	new = new_slab(s, gfpflags, node);
+	page = new_slab(s, gfpflags, node);
 
 	if (gfpflags & __GFP_WAIT)
 		local_irq_disable();
 
-	if (new) {
+	if (page) {
 		c = __this_cpu_ptr(s->cpu_slab);
 		stat(s, ALLOC_SLAB);
 		if (c->page)
 			flush_slab(s, c);
-		slab_lock(new);
-		__SetPageSlubFrozen(new);
-		c->page = new;
+
+		slab_lock(page);
+		__SetPageSlubFrozen(page);
+		c->page = page;
 		goto load_freelist;
 	}
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
@@ -1874,11 +1877,11 @@ new_slab:
 #endif
 	return NULL;
 debug:
-	if (!alloc_debug_processing(s, c->page, object, addr))
+	if (!alloc_debug_processing(s, page, object, addr))
 		goto another_slab;
 
-	c->page->inuse++;
-	c->page->freelist = get_freepointer(s, object);
+	page->inuse++;
+	page->freelist = get_freepointer(s, object);
 	c->node = NUMA_NO_NODE;
 	goto unlock_out;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
