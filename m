Message-Id: <20070427042908.476546262@sgi.com>
References: <20070427042655.019305162@sgi.com>
Date: Thu, 26 Apr 2007 21:27:00 -0700
From: clameter@sgi.com
Subject: [patch 05/10] SLUB: Add MIN_PARTIAL
Content-Disposition: inline; filename=slab_partial
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We leave a mininum of partial slabs on nodes when we search for
partial slabs on other node. Define a constant for that value.

Then modify slub to keep MIN_PARTIAL slabs around.

This avoids bad situations where a function frees the last object
in a slab (which results in the page being returned to the page
allocator) only to then allocate one again (which requires getting
a page back from the page allocator if the partial list was empty).
Keeping a couple of slabs on the partial list reduces overhead.

Empty slabs are added to the end of the partial list to insure that
partially allocated slabs are consumed first (defragmentation).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc7-mm2/mm/slub.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/mm/slub.c	2007-04-26 11:41:43.000000000 -0700
+++ linux-2.6.21-rc7-mm2/mm/slub.c	2007-04-26 11:41:54.000000000 -0700
@@ -109,6 +109,9 @@
 /* Enable to test recovery from slab corruption on boot */
 #undef SLUB_RESILIENCY_TEST
 
+/* Mininum number of partial slabs */
+#define MIN_PARTIAL 2
+
 #define DEBUG_DEFAULT_FLAGS (SLAB_DEBUG_FREE | SLAB_RED_ZONE | \
 				SLAB_POISON | SLAB_STORE_USER)
 /*
@@ -635,16 +638,8 @@ static int on_freelist(struct kmem_cache
 /*
  * Tracking of fully allocated slabs for debugging
  */
-static void add_full(struct kmem_cache *s, struct page *page)
+static void add_full(struct kmem_cache_node *n, struct page *page)
 {
-	struct kmem_cache_node *n;
-
-	VM_BUG_ON(!irqs_disabled());
-
-	if (!(s->flags & SLAB_STORE_USER))
-		return;
-
-	n = get_node(s, page_to_nid(page));
 	spin_lock(&n->list_lock);
 	list_add(&page->lru, &n->full);
 	spin_unlock(&n->list_lock);
@@ -923,10 +918,16 @@ static __always_inline int slab_trylock(
 /*
  * Management of partially allocated slabs
  */
-static void add_partial(struct kmem_cache *s, struct page *page)
+static void add_partial_tail(struct kmem_cache_node *n, struct page *page)
 {
-	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	spin_lock(&n->list_lock);
+	n->nr_partial++;
+	list_add_tail(&page->lru, &n->partial);
+	spin_unlock(&n->list_lock);
+}
 
+static void add_partial(struct kmem_cache_node *n, struct page *page)
+{
 	spin_lock(&n->list_lock);
 	n->nr_partial++;
 	list_add(&page->lru, &n->partial);
@@ -1026,7 +1027,7 @@ static struct page *get_any_partial(stru
 		n = get_node(s, zone_to_nid(*z));
 
 		if (n && cpuset_zone_allowed_hardwall(*z, flags) &&
-				n->nr_partial > 2) {
+				n->nr_partial > MIN_PARTIAL) {
 			page = get_partial_node(n);
 			if (page)
 				return page;
@@ -1060,15 +1061,31 @@ static struct page *get_partial(struct k
  */
 static void putback_slab(struct kmem_cache *s, struct page *page)
 {
+	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+
 	if (page->inuse) {
+
 		if (page->freelist)
-			add_partial(s, page);
-		else if (PageError(page))
-			add_full(s, page);
+			add_partial(n, page);
+		else if (PageError(page) && (s->flags & SLAB_STORE_USER))
+			add_full(n, page);
 		slab_unlock(page);
+
 	} else {
-		slab_unlock(page);
-		discard_slab(s, page);
+		if (n->nr_partial < MIN_PARTIAL) {
+			/*
+			 * Adding an empty page to the partial slabs in order
+			 * to avoid page allocator overhead. This page needs to
+			 * come after all the others that are not fully empty
+			 * in order to make sure that we do maximum
+			 * defragmentation.
+			 */
+			add_partial_tail(n, page);
+			slab_unlock(page);
+		} else {
+			slab_unlock(page);
+			discard_slab(s, page);
+		}
 	}
 }
 
@@ -1326,7 +1343,7 @@ checks_ok:
 	 * then add it.
 	 */
 	if (unlikely(!prior))
-		add_partial(s, page);
+		add_partial(get_node(s, page_to_nid(page)), page);
 
 out_unlock:
 	slab_unlock(page);
@@ -1542,7 +1559,7 @@ static struct kmem_cache_node * __init e
 	kmalloc_caches->node[node] = n;
 	init_kmem_cache_node(n);
 	atomic_long_inc(&n->nr_slabs);
-	add_partial(kmalloc_caches, page);
+	add_partial(n, page);
 	return n;
 }
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
