Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 33A77900090
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:02 -0400 (EDT)
Message-Id: <20110415201259.618331755@linux.com>
Date: Fri, 15 Apr 2011 15:12:54 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] slub: Move page->frozen handling near where the page->freelist handling occurs
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=frozen_move
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

This is necessary because the frozen bit has to be handled in the same cmpxchg_double
with the freelist and the counters.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 13:14:36.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 13:14:40.000000000 -0500
@@ -1264,6 +1264,7 @@ static struct page *new_slab(struct kmem
 
 	page->freelist = start;
 	page->inuse = 0;
+	page->frozen = 1;
 out:
 	return page;
 }
@@ -1402,7 +1403,6 @@ static inline int lock_and_freeze_slab(s
 {
 	if (slab_trylock(page)) {
 		__remove_partial(n, page);
-		page->frozen = 1;
 		return 1;
 	}
 	return 0;
@@ -1516,7 +1516,6 @@ static void unfreeze_slab(struct kmem_ca
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
-	page->frozen = 0;
 	if (page->inuse) {
 
 		if (page->freelist) {
@@ -1657,6 +1656,7 @@ static void deactivate_slab(struct kmem_
 #ifdef CONFIG_CMPXCHG_LOCAL
 	c->tid = next_tid(c->tid);
 #endif
+	page->frozen = 0;
 	unfreeze_slab(s, page, tail);
 }
 
@@ -1819,6 +1819,8 @@ static void *__slab_alloc(struct kmem_ca
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
 load_from_page:
 		c->node = page_to_nid(page);
 		c->page = page;
@@ -1867,7 +1870,6 @@ load_from_page:
 			flush_slab(s, c);
 
 		slab_lock(page);
-		page->frozen = 1;
 
 		goto load_from_page;
 	}
@@ -2430,6 +2432,7 @@ static void early_kmem_cache_node_alloc(
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
