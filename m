Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 91643900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 21:52:08 -0400 (EDT)
Subject: [patch 2/2]slub: explicitly document position of inserting slab to
 partial list
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Aug 2011 09:54:12 +0800
Message-ID: <1314669252.29510.49.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "Shi, Alex" <alex.shi@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, linux-mm <linux-mm@kvack.org>

Adding slab to partial list head/tail is sensitive to performance. Using 0/1
can easily cause typo. So explicitly uses DEACTIVATE_TO_TAIL/DEACTIVATE_TO_HEAD
to document it to avoid we get it wrong.

Signed-off-by: Shaohua Li <shli@kernel.org>
Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2011-08-30 09:45:03.000000000 +0800
+++ linux/mm/slub.c	2011-08-30 09:45:45.000000000 +0800
@@ -1534,7 +1534,7 @@ static inline void add_partial(struct km
 				struct page *page, int tail)
 {
 	n->nr_partial++;
-	if (tail)
+	if (tail == DEACTIVATE_TO_TAIL)
 		list_add_tail(&page->lru, &n->partial);
 	else
 		list_add(&page->lru, &n->partial);
@@ -1781,13 +1781,13 @@ static void deactivate_slab(struct kmem_
 	enum slab_modes l = M_NONE, m = M_NONE;
 	void *freelist;
 	void *nextfree;
-	int tail = 0;
+	int tail = DEACTIVATE_TO_HEAD;
 	struct page new;
 	struct page old;
 
 	if (page->freelist) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
-		tail = 1;
+		tail = DEACTIVATE_TO_TAIL;
 	}
 
 	c->tid = next_tid(c->tid);
@@ -1893,7 +1893,7 @@ redo:
 		if (m == M_PARTIAL) {
 
 			add_partial(n, page, tail);
-			stat(s, tail ? DEACTIVATE_TO_TAIL : DEACTIVATE_TO_HEAD);
+			stat(s, tail);
 
 		} else if (m == M_FULL) {
 
@@ -2382,7 +2382,7 @@ static void __slab_free(struct kmem_cach
 			 * partial list tail so it will not be used
 			 * immediately.
 			 */
-			add_partial(n, page, 1);
+			add_partial(n, page, DEACTIVATE_TO_TAIL);
 			stat(s, FREE_ADD_PARTIAL);
 		}
 	}
@@ -2700,7 +2700,7 @@ static void early_kmem_cache_node_alloc(
 	init_kmem_cache_node(n, kmem_cache_node);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
-	add_partial(n, page, 0);
+	add_partial(n, page, DEACTIVATE_TO_HEAD);
 }
 
 static void free_kmem_cache_nodes(struct kmem_cache *s)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
