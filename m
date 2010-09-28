Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1959C6B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 09:11:01 -0400 (EDT)
Message-Id: <20100928131057.084357922@linux.com>
Date: Tue, 28 Sep 2010 08:10:27 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup5 2/3] SLUB: Pass active and inactive redzone flags instead of boolean to debug functions
References: <20100928131025.319846721@linux.com>
Content-Disposition: inline; filename=change_debug
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Pass the actual values used for inactive and active redzoning to the
functions that check the objects. Avoids a lot of the ? : things to
lookup the values in the functions.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   37 +++++++++++++++++--------------------
 1 file changed, 17 insertions(+), 20 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-09-28 08:02:26.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-09-28 08:04:04.000000000 -0500
@@ -490,7 +490,8 @@ static void slab_err(struct kmem_cache *
 	dump_stack();
 }
 
-static void init_object(struct kmem_cache *s, void *object, int active)
+
+static void init_object(struct kmem_cache *s, void *object, u8 val)
 {
 	u8 *p = object;
 
@@ -500,9 +501,7 @@ static void init_object(struct kmem_cach
 	}
 
 	if (s->flags & SLAB_RED_ZONE)
-		memset(p + s->objsize,
-			active ? SLUB_RED_ACTIVE : SLUB_RED_INACTIVE,
-			s->inuse - s->objsize);
+		memset(p + s->objsize, val, s->inuse - s->objsize);
 }
 
 static u8 *check_bytes(u8 *start, unsigned int value, unsigned int bytes)
@@ -637,17 +636,14 @@ static int slab_pad_check(struct kmem_ca
 }
 
 static int check_object(struct kmem_cache *s, struct page *page,
-					void *object, int active)
+					void *object, u8 val)
 {
 	u8 *p = object;
 	u8 *endobject = object + s->objsize;
 
 	if (s->flags & SLAB_RED_ZONE) {
-		unsigned int red =
-			active ? SLUB_RED_ACTIVE : SLUB_RED_INACTIVE;
-
 		if (!check_bytes_and_report(s, page, object, "Redzone",
-			endobject, red, s->inuse - s->objsize))
+			endobject, val, s->inuse - s->objsize))
 			return 0;
 	} else {
 		if ((s->flags & SLAB_POISON) && s->objsize < s->inuse) {
@@ -657,7 +653,7 @@ static int check_object(struct kmem_cach
 	}
 
 	if (s->flags & SLAB_POISON) {
-		if (!active && (s->flags & __OBJECT_POISON) &&
+		if (val != SLUB_RED_ACTIVE && (s->flags & __OBJECT_POISON) &&
 			(!check_bytes_and_report(s, page, p, "Poison", p,
 					POISON_FREE, s->objsize - 1) ||
 			 !check_bytes_and_report(s, page, p, "Poison",
@@ -669,7 +665,7 @@ static int check_object(struct kmem_cach
 		check_pad_bytes(s, page, p);
 	}
 
-	if (!s->offset && active)
+	if (!s->offset && val == SLUB_RED_ACTIVE)
 		/*
 		 * Object and freepointer overlap. Cannot check
 		 * freepointer while object is allocated.
@@ -887,7 +883,7 @@ static void setup_object_debug(struct km
 	if (!(s->flags & (SLAB_STORE_USER|SLAB_RED_ZONE|__OBJECT_POISON)))
 		return;
 
-	init_object(s, object, 0);
+	init_object(s, object, SLUB_RED_INACTIVE);
 	init_tracking(s, object);
 }
 
@@ -907,14 +903,14 @@ static noinline int alloc_debug_processi
 		goto bad;
 	}
 
-	if (!check_object(s, page, object, 0))
+	if (!check_object(s, page, object, SLUB_RED_INACTIVE))
 		goto bad;
 
 	/* Success perform special debug activities for allocs */
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_ALLOC, addr);
 	trace(s, page, object, 1);
-	init_object(s, object, 1);
+	init_object(s, object, SLUB_RED_ACTIVE);
 	return 1;
 
 bad:
@@ -947,7 +943,7 @@ static noinline int free_debug_processin
 		goto fail;
 	}
 
-	if (!check_object(s, page, object, 1))
+	if (!check_object(s, page, object, SLUB_RED_ACTIVE))
 		return 0;
 
 	if (unlikely(s != page->slab)) {
@@ -971,7 +967,7 @@ static noinline int free_debug_processin
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_FREE, addr);
 	trace(s, page, object, 0);
-	init_object(s, object, 0);
+	init_object(s, object, SLUB_RED_INACTIVE);
 	return 1;
 
 fail:
@@ -1075,8 +1071,9 @@ static inline int free_debug_processing(
 static inline int slab_pad_check(struct kmem_cache *s, struct page *page)
 			{ return 1; }
 static inline int check_object(struct kmem_cache *s, struct page *page,
-			void *object, int active) { return 1; }
-static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
+			void *object, u8 val) { return 1; }
+static inline void add_full(struct kmem_cache *s,
+		struct kmem_cache_node *n, struct page *page) {}
 static inline unsigned long kmem_cache_flags(unsigned long objsize,
 	unsigned long flags, const char *name,
 	void (*ctor)(void *))
@@ -1235,7 +1232,7 @@ static void __free_slab(struct kmem_cach
 		slab_pad_check(s, page);
 		for_each_object(p, s, page_address(page),
 						page->objects)
-			check_object(s, page, p, 0);
+			check_object(s, page, p, SLUB_RED_INACTIVE);
 	}
 
 	kmemcheck_free_shadow(page, compound_order(page));
@@ -2143,7 +2140,7 @@ static void early_kmem_cache_node_alloc(
 	page->inuse++;
 	kmem_cache_node->node[node] = n;
 #ifdef CONFIG_SLUB_DEBUG
-	init_object(kmem_cache_node, n, 1);
+	init_object(kmem_cache_node, n, SLUB_RED_ACTIVE);
 	init_tracking(kmem_cache_node, n);
 #endif
 	init_kmem_cache_node(n, kmem_cache_node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
