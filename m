Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 836036B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 03:24:47 -0500 (EST)
From: Alex Shi <alex.shi@intel.com>
Subject: [PATCH 1/3] slub: set a criteria for slub node partial adding
Date: Fri,  2 Dec 2011 16:23:07 +0800
Message-Id: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Alex Shi <alexs@intel.com>

Times performance regression were due to slub add to node partial head
or tail. That inspired me to do tunning on the node partial adding, to
set a criteria for head or tail position selection when do partial
adding.
My experiment show, when used objects is less than 1/4 total objects
of slub performance will get about 1.5% improvement on netperf loopback
testing with 2048 clients, wherever on our 4 or 2 sockets platforms,
includes sandbridge or core2.

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 mm/slub.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ed3334d..c419e80 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1461,14 +1461,13 @@ static void discard_slab(struct kmem_cache *s, struct page *page)
  *
  * list_lock must be held.
  */
-static inline void add_partial(struct kmem_cache_node *n,
-				struct page *page, int tail)
+static inline void add_partial(struct kmem_cache_node *n, struct page *page)
 {
 	n->nr_partial++;
-	if (tail == DEACTIVATE_TO_TAIL)
-		list_add_tail(&page->lru, &n->partial);
-	else
+	if (page->inuse <= page->objects / 4)
 		list_add(&page->lru, &n->partial);
+	else
+		list_add_tail(&page->lru, &n->partial);
 }
 
 /*
@@ -1829,7 +1828,7 @@ redo:
 
 		if (m == M_PARTIAL) {
 
-			add_partial(n, page, tail);
+			add_partial(n, page);
 			stat(s, tail);
 
 		} else if (m == M_FULL) {
@@ -1904,8 +1903,7 @@ static void unfreeze_partials(struct kmem_cache *s)
 				if (l == M_PARTIAL)
 					remove_partial(n, page);
 				else
-					add_partial(n, page,
-						DEACTIVATE_TO_TAIL);
+					add_partial(n, page);
 
 				l = m;
 			}
@@ -2476,7 +2474,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		 */
 		if (unlikely(!prior)) {
 			remove_full(s, page);
-			add_partial(n, page, DEACTIVATE_TO_TAIL);
+			add_partial(n, page);
 			stat(s, FREE_ADD_PARTIAL);
 		}
 	}
@@ -2793,7 +2791,7 @@ static void early_kmem_cache_node_alloc(int node)
 	init_kmem_cache_node(n, kmem_cache_node);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
-	add_partial(n, page, DEACTIVATE_TO_HEAD);
+	add_partial(n, page);
 }
 
 static void free_kmem_cache_nodes(struct kmem_cache *s)
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
