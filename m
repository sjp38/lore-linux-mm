From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 03/10] SLUB: Move kmem_cache_node determination into add_full and add_partial
Date: Sat, 27 Oct 2007 20:31:59 -0700
Message-ID: <20071028033259.021882647@sgi.com>
References: <20071028033156.022983073@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755721AbXJ1Ddt@vger.kernel.org>
Content-Disposition: inline; filename=slub_add_partial_kmem_cache_parameter
Sender: linux-kernel-owner@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

The kmem_cache_node determination can be moved into add_full()
and add_partial(). This removes some code from the slab_free()
slow path and reduces the register overhead that has to be managed
in the slow path.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-10-25 19:36:59.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-10-25 19:37:38.000000000 -0700
@@ -800,8 +800,12 @@ static void trace(struct kmem_cache *s, 
 /*
  * Tracking of fully allocated slabs for debugging purposes.
  */
-static void add_full(struct kmem_cache_node *n, struct page *page)
+static void add_full(struct kmem_cache *s, struct page *page)
 {
+	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+
+	if (!SlabDebug(page) || !(s->flags & SLAB_STORE_USER))
+		return;
 	spin_lock(&n->list_lock);
 	list_add(&page->lru, &n->full);
 	spin_unlock(&n->list_lock);
@@ -1025,7 +1029,7 @@ static inline int slab_pad_check(struct 
 			{ return 1; }
 static inline int check_object(struct kmem_cache *s, struct page *page,
 			void *object, int active) { return 1; }
-static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
+static inline void add_full(struct kmem_cache *s, struct page *page) {}
 static inline unsigned long kmem_cache_flags(unsigned long objsize,
 	unsigned long flags, const char *name,
 	void (*ctor)(struct kmem_cache *, void *))
@@ -1198,9 +1202,11 @@ static __always_inline int slab_trylock(
 /*
  * Management of partially allocated slabs
  */
-static void add_partial(struct kmem_cache_node *n,
+static void add_partial(struct kmem_cache *s,
 				struct page *page, int tail)
 {
+	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+
 	spin_lock(&n->list_lock);
 	n->nr_partial++;
 	if (tail)
@@ -1336,19 +1342,18 @@ static struct page *get_partial(struct k
  */
 static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
 {
-	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
-
 	ClearSlabFrozen(page);
 	if (page->inuse) {
 
 		if (page->freelist)
-			add_partial(n, page, tail);
-		else if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
-			add_full(n, page);
+			add_partial(s, page, tail);
+		else
+			add_full(s, page);
 		slab_unlock(page);
 
 	} else {
-		if (n->nr_partial < MIN_PARTIAL) {
+		if (get_node(s, page_to_nid(page))->nr_partial
+							< MIN_PARTIAL) {
 			/*
 			 * Adding an empty slab to the partial slabs in order
 			 * to avoid page allocator overhead. This slab needs
@@ -1357,7 +1362,7 @@ static void unfreeze_slab(struct kmem_ca
 			 * partial list stays small. kmem_cache_shrink can
 			 * reclaim empty slabs from the partial list.
 			 */
-			add_partial(n, page, 1);
+			add_partial(s, page, 1);
 			slab_unlock(page);
 		} else {
 			slab_unlock(page);
@@ -1633,7 +1638,7 @@ checks_ok:
 	 * then add it.
 	 */
 	if (unlikely(!prior))
-		add_partial(get_node(s, page_to_nid(page)), page, 0);
+		add_partial(s, page, 0);
 
 out_unlock:
 	slab_unlock(page);
@@ -2041,7 +2046,7 @@ static struct kmem_cache_node *early_kme
 #endif
 	init_kmem_cache_node(n);
 	atomic_long_inc(&n->nr_slabs);
-	add_partial(n, page, 0);
+	add_partial(kmalloc_caches, page, 0);
 	return n;
 }
 

-- 
