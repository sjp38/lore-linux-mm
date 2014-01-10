Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id D542B6B0035
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 07:24:11 -0500 (EST)
Received: by mail-bk0-f45.google.com with SMTP id mx13so1551545bkb.32
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 04:24:11 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id kv5si3880630bkb.234.2014.01.10.04.24.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jan 2014 04:24:10 -0800 (PST)
Date: Fri, 10 Jan 2014 13:23:49 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH] slub: use lockdep_assert_held
Message-ID: <20140110122349.GN31570@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com

Instead of using comments in an attempt at getting the locking right,
use proper assertions that actively warn you if you got it wrong.

Also add extra braces in a few sites to comply with coding-style.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 mm/slub.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 545a170ebf9f..dc5be8c47633 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -985,23 +985,22 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 
 /*
  * Tracking of fully allocated slabs for debugging purposes.
- *
- * list_lock must be held.
  */
 static void add_full(struct kmem_cache *s,
 	struct kmem_cache_node *n, struct page *page)
 {
+	lockdep_assert_held(&n->list_lock);
+
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 
 	list_add(&page->lru, &n->full);
 }
 
-/*
- * list_lock must be held.
- */
-static void remove_full(struct kmem_cache *s, struct page *page)
+static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct page *page)
 {
+	lockdep_assert_held(&n->list_lock);
+
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 
@@ -1250,7 +1249,8 @@ static inline int check_object(struct kmem_cache *s, struct page *page,
 			void *object, u8 val) { return 1; }
 static inline void add_full(struct kmem_cache *s, struct kmem_cache_node *n,
 					struct page *page) {}
-static inline void remove_full(struct kmem_cache *s, struct page *page) {}
+static inline void remove_full(struct kmem_cache *s, struct kmem_cache_node *n,
+					struct page *page) {}
 static inline unsigned long kmem_cache_flags(unsigned long object_size,
 	unsigned long flags, const char *name,
 	void (*ctor)(void *))
@@ -1504,12 +1504,12 @@ static void discard_slab(struct kmem_cache *s, struct page *page)
 
 /*
  * Management of partially allocated slabs.
- *
- * list_lock must be held.
  */
 static inline void add_partial(struct kmem_cache_node *n,
 				struct page *page, int tail)
 {
+	lockdep_assert_held(&n->list_lock);
+
 	n->nr_partial++;
 	if (tail == DEACTIVATE_TO_TAIL)
 		list_add_tail(&page->lru, &n->partial);
@@ -1517,12 +1517,11 @@ static inline void add_partial(struct kmem_cache_node *n,
 		list_add(&page->lru, &n->partial);
 }
 
-/*
- * list_lock must be held.
- */
 static inline void remove_partial(struct kmem_cache_node *n,
 					struct page *page)
 {
+	lockdep_assert_held(&n->list_lock);
+
 	list_del(&page->lru);
 	n->nr_partial--;
 }
@@ -1532,8 +1531,6 @@ static inline void remove_partial(struct kmem_cache_node *n,
  * return the pointer to the freelist.
  *
  * Returns a list of objects or NULL if it fails.
- *
- * Must hold list_lock since we modify the partial list.
  */
 static inline void *acquire_slab(struct kmem_cache *s,
 		struct kmem_cache_node *n, struct page *page,
@@ -1543,6 +1540,8 @@ static inline void *acquire_slab(struct kmem_cache *s,
 	unsigned long counters;
 	struct page new;
 
+	lockdep_assert_held(&n->list_lock);
+
 	/*
 	 * Zap the freelist and set the frozen bit.
 	 * The old freelist is the list of objects for the
@@ -1887,7 +1886,7 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 
 		else if (l == M_FULL)
 
-			remove_full(s, page);
+			remove_full(s, n, page);
 
 		if (m == M_PARTIAL) {
 
@@ -2541,7 +2540,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		new.inuse--;
 		if ((!new.inuse || !prior) && !was_frozen) {
 
-			if (kmem_cache_has_cpu_partial(s) && !prior)
+			if (kmem_cache_has_cpu_partial(s) && !prior) {
 
 				/*
 				 * Slab was on no list before and will be
@@ -2551,7 +2550,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 				 */
 				new.frozen = 1;
 
-			else { /* Needs to be taken off a list */
+			} else { /* Needs to be taken off a list */
 
 	                        n = get_node(s, page_to_nid(page));
 				/*
@@ -2600,7 +2599,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	 */
 	if (!kmem_cache_has_cpu_partial(s) && unlikely(!prior)) {
 		if (kmem_cache_debug(s))
-			remove_full(s, page);
+			remove_full(s, n, page);
 		add_partial(n, page, DEACTIVATE_TO_TAIL);
 		stat(s, FREE_ADD_PARTIAL);
 	}
@@ -2614,9 +2613,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		 */
 		remove_partial(n, page);
 		stat(s, FREE_REMOVE_PARTIAL);
-	} else
+	} else {
 		/* Slab must be on the full list */
-		remove_full(s, page);
+		remove_full(s, n, page);
+	}
 
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	stat(s, FREE_SLAB);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
