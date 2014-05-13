Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1E71A6B0037
	for <linux-mm@kvack.org>; Tue, 13 May 2014 09:48:58 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id mc6so296668lab.16
        for <linux-mm@kvack.org>; Tue, 13 May 2014 06:48:58 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id tj10si6227824lbb.172.2014.05.13.06.48.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 06:48:57 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 1/3] slub: keep full slabs on list for per memcg caches
Date: Tue, 13 May 2014 17:48:51 +0400
Message-ID: <bc70b480221f7765926c8b4d63c55fb42e85baaf.1399982635.git.vdavydov@parallels.com>
In-Reply-To: <cover.1399982635.git.vdavydov@parallels.com>
References: <cover.1399982635.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently full slabs are only kept on per-node lists for debugging, but
we need this feature to reparent per memcg caches, so let's enable it
for them too.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab.h |    2 ++
 mm/slub.c |   91 +++++++++++++++++++++++++++++++++++++++++--------------------
 2 files changed, 63 insertions(+), 30 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 961a3fb1f5a2..0eca922ed7a0 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -288,6 +288,8 @@ struct kmem_cache_node {
 #ifdef CONFIG_SLUB_DEBUG
 	atomic_long_t nr_slabs;
 	atomic_long_t total_objects;
+#endif
+#if defined(CONFIG_MEMCG_KMEM) || defined(CONFIG_SLUB_DEBUG)
 	struct list_head full;
 #endif
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index 4d5002f518b1..6019c315a2f9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -132,6 +132,11 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 #endif
 }
 
+static inline bool kmem_cache_tracks_full(struct kmem_cache *s)
+{
+	return !is_root_cache(s) || kmem_cache_debug(s);
+}
+
 /*
  * Issues still to be resolved:
  *
@@ -998,28 +1003,6 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 		debug_check_no_obj_freed(x, s->object_size);
 }
 
-/*
- * Tracking of fully allocated slabs for debugging purposes.
- */
-static void add_full(struct kmem_cache *s,
-	struct kmem_cache_node *n, struct page *page)
-{
-	if (!(s->flags & SLAB_STORE_USER))
-		return;
-
-	lockdep_assert_held(&n->list_lock);
-	list_add(&page->lru, &n->full);
-}
-
-static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct page *page)
-{
-	if (!(s->flags & SLAB_STORE_USER))
-		return;
-
-	lockdep_assert_held(&n->list_lock);
-	list_del(&page->lru);
-}
-
 /* Tracking of the number of slabs for debugging purposes */
 static inline unsigned long slabs_node(struct kmem_cache *s, int node)
 {
@@ -1259,10 +1242,6 @@ static inline int slab_pad_check(struct kmem_cache *s, struct page *page)
 			{ return 1; }
 static inline int check_object(struct kmem_cache *s, struct page *page,
 			void *object, u8 val) { return 1; }
-static inline void add_full(struct kmem_cache *s, struct kmem_cache_node *n,
-					struct page *page) {}
-static inline void remove_full(struct kmem_cache *s, struct kmem_cache_node *n,
-					struct page *page) {}
 static inline unsigned long kmem_cache_flags(unsigned long object_size,
 	unsigned long flags, const char *name,
 	void (*ctor)(void *))
@@ -1557,6 +1536,33 @@ static inline void remove_partial(struct kmem_cache_node *n,
 	__remove_partial(n, page);
 }
 
+#if defined(CONFIG_SLUB_DEBUG) || defined(CONFIG_MEMCG_KMEM)
+static inline void add_full(struct kmem_cache *s,
+			    struct kmem_cache_node *n, struct page *page)
+{
+	if (is_root_cache(s) && !(s->flags & SLAB_STORE_USER))
+		return;
+
+	lockdep_assert_held(&n->list_lock);
+	list_add(&page->lru, &n->full);
+}
+
+static inline void remove_full(struct kmem_cache *s,
+			       struct kmem_cache_node *n, struct page *page)
+{
+	if (is_root_cache(s) && !(s->flags & SLAB_STORE_USER))
+		return;
+
+	lockdep_assert_held(&n->list_lock);
+	list_del(&page->lru);
+}
+#else
+static inline void add_full(struct kmem_cache *s, struct kmem_cache_node *n,
+					struct page *page) {}
+static inline void remove_full(struct kmem_cache *s, struct kmem_cache_node *n,
+					struct page *page) {}
+#endif
+
 /*
  * Remove slab from the partial list, freeze it and
  * return the pointer to the freelist.
@@ -1896,7 +1902,7 @@ redo:
 		}
 	} else {
 		m = M_FULL;
-		if (kmem_cache_debug(s) && !lock) {
+		if (kmem_cache_tracks_full(s) && !lock) {
 			lock = 1;
 			/*
 			 * This also ensures that the scanning of full
@@ -2257,8 +2263,14 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 	struct page new;
 	unsigned long counters;
 	void *freelist;
+	struct kmem_cache_node *n = NULL;
 
 	do {
+		if (unlikely(n)) {
+			spin_unlock(&n->list_lock);
+			n = NULL;
+		}
+
 		freelist = page->freelist;
 		counters = page->counters;
 
@@ -2268,11 +2280,21 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 		new.inuse = page->objects;
 		new.frozen = freelist != NULL;
 
+		if (kmem_cache_tracks_full(s) && !new.frozen) {
+			n = get_node(s, page_to_nid(page));
+			spin_lock(&n->list_lock);
+		}
+
 	} while (!__cmpxchg_double_slab(s, page,
 		freelist, counters,
 		NULL, new.counters,
 		"get_freelist"));
 
+	if (n) {
+		add_full(s, n, page);
+		spin_unlock(&n->list_lock);
+	}
+
 	return freelist;
 }
 
@@ -2575,7 +2597,8 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		new.inuse--;
 		if ((!new.inuse || !prior) && !was_frozen) {
 
-			if (kmem_cache_has_cpu_partial(s) && !prior) {
+			if (kmem_cache_has_cpu_partial(s) &&
+			    !kmem_cache_tracks_full(s) && !prior) {
 
 				/*
 				 * Slab was on no list before and will be
@@ -2587,6 +2610,9 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 			} else { /* Needs to be taken off a list */
 
+				if (kmem_cache_has_cpu_partial(s) && !prior)
+					new.frozen = 1;
+
 	                        n = get_node(s, page_to_nid(page));
 				/*
 				 * Speculatively acquire the list_lock.
@@ -2606,6 +2632,12 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		object, new.counters,
 		"__slab_free"));
 
+	if (unlikely(n) && new.frozen && !was_frozen) {
+		remove_full(s, n, page);
+		spin_unlock_irqrestore(&n->list_lock, flags);
+		n = NULL;
+	}
+
 	if (likely(!n)) {
 
 		/*
@@ -2633,8 +2665,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	 * then add it.
 	 */
 	if (!kmem_cache_has_cpu_partial(s) && unlikely(!prior)) {
-		if (kmem_cache_debug(s))
-			remove_full(s, n, page);
+		remove_full(s, n, page);
 		add_partial(n, page, DEACTIVATE_TO_TAIL);
 		stat(s, FREE_ADD_PARTIAL);
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
