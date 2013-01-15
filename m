Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id C91BA6B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 02:20:16 -0500 (EST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/3] slub: correct to calculate num of acquired objects in get_partial_node()
Date: Tue, 15 Jan 2013 16:20:00 +0900
Message-Id: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is a subtle bug when calculating a number of acquired objects.
After acquire_slab() is executed at first, page->inuse is same as
page->objects, then, available is always 0. So, we always go next
iteration.

Correct it to stop a iteration when we find sufficient objects
at first iteration.

After that, we don't need return value of put_cpu_partial().
So remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
These are based on v3.8-rc3 and there is no dependency between each other.
If rebase is needed, please notify me.

diff --git a/mm/slub.c b/mm/slub.c
index ba2ca53..abef30e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1493,7 +1493,7 @@ static inline void remove_partial(struct kmem_cache_node *n,
  */
 static inline void *acquire_slab(struct kmem_cache *s,
 		struct kmem_cache_node *n, struct page *page,
-		int mode)
+		int mode, int *objects)
 {
 	void *freelist;
 	unsigned long counters;
@@ -1506,6 +1506,7 @@ static inline void *acquire_slab(struct kmem_cache *s,
 	 */
 	freelist = page->freelist;
 	counters = page->counters;
+	*objects = page->objects - page->inuse;
 	new.counters = counters;
 	if (mode) {
 		new.inuse = page->objects;
@@ -1528,7 +1529,7 @@ static inline void *acquire_slab(struct kmem_cache *s,
 	return freelist;
 }
 
-static int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain);
+static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain);
 static inline bool pfmemalloc_match(struct page *page, gfp_t gfpflags);
 
 /*
@@ -1539,6 +1540,8 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 {
 	struct page *page, *page2;
 	void *object = NULL;
+	int available = 0;
+	int objects;
 
 	/*
 	 * Racy check. If we mistakenly see no partial slabs then we
@@ -1552,22 +1555,21 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 	spin_lock(&n->list_lock);
 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
 		void *t;
-		int available;
 
 		if (!pfmemalloc_match(page, flags))
 			continue;
 
-		t = acquire_slab(s, n, page, object == NULL);
+		t = acquire_slab(s, n, page, object == NULL, &objects);
 		if (!t)
 			break;
 
+		available += objects;
 		if (!object) {
 			c->page = page;
 			stat(s, ALLOC_FROM_PARTIAL);
 			object = t;
-			available =  page->objects - page->inuse;
 		} else {
-			available = put_cpu_partial(s, page, 0);
+			put_cpu_partial(s, page, 0);
 			stat(s, CPU_PARTIAL_NODE);
 		}
 		if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
@@ -1946,7 +1948,7 @@ static void unfreeze_partials(struct kmem_cache *s,
  * If we did not find a slot then simply move all the partials to the
  * per node partial list.
  */
-static int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
+static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 {
 	struct page *oldpage;
 	int pages;
@@ -1984,7 +1986,6 @@ static int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 		page->next = oldpage;
 
 	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
-	return pobjects;
 }
 
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
