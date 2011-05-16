Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 07B636B0029
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:27 -0400 (EDT)
Message-Id: <20110516202624.616923279@linux.com>
Date: Mon, 16 May 2011 15:26:11 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 06/25] slub: Move page->frozen handling near where the page->freelist handling occurs
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=frozen_move
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

This is necessary because the frozen bit has to be handled in the same cmpxchg_double
with the freelist and the counters.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-12 15:36:29.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-05-12 15:37:30.000000000 -0500
@@ -1276,6 +1276,7 @@ static struct page *new_slab(struct kmem
 
 	page->freelist = start;
 	page->inuse = 0;
+	page->frozen = 1;
 out:
 	return page;
 }
@@ -1414,7 +1415,6 @@ static inline int lock_and_freeze_slab(s
 {
 	if (slab_trylock(page)) {
 		__remove_partial(n, page);
-		page->frozen = 1;
 		return 1;
 	}
 	return 0;
@@ -1528,7 +1528,6 @@ static void unfreeze_slab(struct kmem_ca
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
-	page->frozen = 0;
 	if (page->inuse) {
 
 		if (page->freelist) {
@@ -1661,6 +1660,7 @@ static void deactivate_slab(struct kmem_
 	}
 	c->page = NULL;
 	c->tid = next_tid(c->tid);
+	page->frozen = 0;
 	unfreeze_slab(s, page, tail);
 }
 
@@ -1821,6 +1821,8 @@ static void *__slab_alloc(struct kmem_ca
 	stat(s, ALLOC_REFILL);
 
 load_freelist:
+	VM_BUG_ON(!page->frozen);
+
 	object = page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
@@ -1845,6 +1847,7 @@ new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {
 		stat(s, ALLOC_FROM_PARTIAL);
+		page->frozen = 1;
 		c->node = page_to_nid(page);
 		c->page = page;
 		goto load_freelist;
@@ -2370,6 +2373,7 @@ static void early_kmem_cache_node_alloc(
 	BUG_ON(!n);
 	page->freelist = get_freepointer(kmem_cache_node, n);
 	page->inuse++;
+	page->frozen = 0;
 	kmem_cache_node->node[node] = n;
 #ifdef CONFIG_SLUB_DEBUG
 	init_object(kmem_cache_node, n, SLUB_RED_ACTIVE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
