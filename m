Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 43AEC90008E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:05 -0400 (EDT)
Message-Id: <20110415201302.499714086@linux.com>
Date: Fri, 15 Apr 2011 15:12:59 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] slub: Pass kmem_cache struct to lock and freeze slab
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=pass_kmem_cache_to_lock_and_freeze
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

We need more information about the slab for the cmpxchg implementation.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 14:29:01.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 14:29:35.000000000 -0500
@@ -1424,8 +1424,8 @@ static inline void remove_partial(struct
  *
  * Must hold list_lock.
  */
-static inline int lock_and_freeze_slab(struct kmem_cache_node *n,
-							struct page *page)
+static inline int lock_and_freeze_slab(struct kmem_cache *s,
+		struct kmem_cache_node *n, struct page *page)
 {
 	if (slab_trylock(page)) {
 		remove_partial(n, page);
@@ -1437,7 +1437,8 @@ static inline int lock_and_freeze_slab(s
 /*
  * Try to allocate a partial slab from a specific node.
  */
-static struct page *get_partial_node(struct kmem_cache_node *n)
+static struct page *get_partial_node(struct kmem_cache *s,
+					struct kmem_cache_node *n)
 {
 	struct page *page;
 
@@ -1452,7 +1453,7 @@ static struct page *get_partial_node(str
 
 	spin_lock(&n->list_lock);
 	list_for_each_entry(page, &n->partial, lru)
-		if (lock_and_freeze_slab(n, page))
+		if (lock_and_freeze_slab(s, n, page))
 			goto out;
 	page = NULL;
 out:
@@ -1503,7 +1504,7 @@ static struct page *get_any_partial(stru
 
 		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 				n->nr_partial > s->min_partial) {
-			page = get_partial_node(n);
+			page = get_partial_node(s, n);
 			if (page) {
 				put_mems_allowed();
 				return page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
