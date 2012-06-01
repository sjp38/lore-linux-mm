Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id C7B7C6B0083
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 15:53:12 -0400 (EDT)
Message-Id: <20120601195310.987976257@linux.com>
Date: Fri, 01 Jun 2012 14:53:05 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [20/20] Common alignment code
References: <20120601195245.084749371@linux.com>
Content-Disposition: inline; filename=common_alignment
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Extract the code to do object alignment from the allocators.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c        |   22 +---------------------
 mm/slab.h        |    3 +++
 mm/slab_common.c |   30 +++++++++++++++++++++++++++++-
 mm/slob.c        |   11 -----------
 mm/slub.c        |   45 ++++++++-------------------------------------
 5 files changed, 41 insertions(+), 70 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-06-01 08:27:19.418609242 -0500
+++ linux-2.6/mm/slab.c	2012-06-01 08:27:41.138608792 -0500
@@ -1439,7 +1439,7 @@ struct kmem_cache *create_kmalloc_cache(
 
 	s->name = name;
 	s->size = s->object_size = size;
-	s->align = ARCH_KMALLOC_MINALIGN;
+	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
 	s->flags = flags | ARCH_KMALLOC_FLAGS;
 
 	r = __kmem_cache_create(s);
@@ -2217,22 +2217,6 @@ int __kmem_cache_create(struct kmem_cach
 		size &= ~(BYTES_PER_WORD - 1);
 	}
 
-	/* calculate the final buffer alignment: */
-
-	/* 1) arch recommendation: can be overridden for debug */
-	if (flags & SLAB_HWCACHE_ALIGN) {
-		/*
-		 * Default alignment: as specified by the arch code.  Except if
-		 * an object is really small, then squeeze multiple objects into
-		 * one cacheline.
-		 */
-		ralign = cache_line_size();
-		while (size <= ralign / 2)
-			ralign /= 2;
-	} else {
-		ralign = BYTES_PER_WORD;
-	}
-
 	/*
 	 * Redzoning and user store require word alignment or possibly larger.
 	 * Note this will be overridden by architecture or caller mandated
@@ -2249,10 +2233,6 @@ int __kmem_cache_create(struct kmem_cach
 		size &= ~(REDZONE_ALIGN - 1);
 	}
 
-	/* 2) arch mandated alignment */
-	if (ralign < ARCH_SLAB_MINALIGN) {
-		ralign = ARCH_SLAB_MINALIGN;
-	}
 	/* 3) caller mandated alignment */
 	if (ralign < cachep->align) {
 		ralign = cachep->align;
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-06-01 08:27:19.490609240 -0500
+++ linux-2.6/mm/slab_common.c	2012-06-01 08:27:41.138608792 -0500
@@ -25,6 +25,34 @@ DEFINE_MUTEX(slab_mutex);
 struct kmem_cache *kmem_cache;
 
 /*
+ * Figure out what the alignment of the objects will be given a set of
+ * flags, a user specified alignment and the size of the objects.
+ */
+unsigned long calculate_alignment(unsigned long flags,
+		unsigned long align, unsigned long size)
+{
+	/*
+	 * If the user wants hardware cache aligned objects then follow that
+	 * suggestion if the object is sufficiently large.
+	 *
+	 * The hardware cache alignment cannot override the specified
+	 * alignment though. If that is greater then use it.
+	 */
+	if (flags & SLAB_HWCACHE_ALIGN) {
+		unsigned long ralign = cache_line_size();
+		while (size <= ralign / 2)
+			ralign /= 2;
+		align = max(align, ralign);
+	}
+
+	if (align < ARCH_SLAB_MINALIGN)
+		align = ARCH_SLAB_MINALIGN;
+
+	return ALIGN(align, sizeof(void *));
+}
+
+
+/*
  * kmem_cache_create - Create a cache.
  * @name: A string which is used in /proc/slabinfo to identify this cache.
  * @size: The size of objects to be created in this cache.
@@ -118,7 +146,7 @@ struct kmem_cache *kmem_cache_create(con
 	s->size = s->object_size = size;
 	s->ctor = ctor;
 	s->flags = flags;
-	s->align = align;
+	s->align = calculate_alignment(flags, align, size);
 
 	r = __kmem_cache_create(s);
 
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-06-01 08:27:33.298609009 -0500
+++ linux-2.6/mm/slob.c	2012-06-01 08:28:00.674608397 -0500
@@ -124,7 +124,6 @@ static inline void clear_slob_page_free(
 
 #define SLOB_UNIT sizeof(slob_t)
 #define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT)
-#define SLOB_ALIGN L1_CACHE_BYTES
 
 /*
  * struct slob_rcu is inserted at the tail of allocated slob blocks, which
@@ -510,20 +509,10 @@ EXPORT_SYMBOL(ksize);
 
 int __kmem_cache_create(struct kmem_cache *c)
 {
-	int align = c->align;
-
 	if (c->flags & SLAB_DESTROY_BY_RCU) {
 		/* leave room for rcu footer at the end of object */
 		c->size += sizeof(struct slob_rcu);
 	}
-	/* ignore alignment unless it's forced */
-	c->align = (c->flags & SLAB_HWCACHE_ALIGN) ? SLOB_ALIGN : 0;
-	if (c->align < ARCH_SLAB_MINALIGN)
-		c->align = ARCH_SLAB_MINALIGN;
-	if (c->align < align)
-		c->align = align;
-
-	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
 	return 0;
 }
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-06-01 08:27:19.438609242 -0500
+++ linux-2.6/mm/slub.c	2012-06-01 08:27:41.142608792 -0500
@@ -2724,32 +2724,6 @@ static inline int calculate_order(int si
 	return -ENOSYS;
 }
 
-/*
- * Figure out what the alignment of the objects will be.
- */
-static unsigned long calculate_alignment(unsigned long flags,
-		unsigned long align, unsigned long size)
-{
-	/*
-	 * If the user wants hardware cache aligned objects then follow that
-	 * suggestion if the object is sufficiently large.
-	 *
-	 * The hardware cache alignment cannot override the specified
-	 * alignment though. If that is greater then use it.
-	 */
-	if (flags & SLAB_HWCACHE_ALIGN) {
-		unsigned long ralign = cache_line_size();
-		while (size <= ralign / 2)
-			ralign /= 2;
-		align = max(align, ralign);
-	}
-
-	if (align < ARCH_SLAB_MINALIGN)
-		align = ARCH_SLAB_MINALIGN;
-
-	return ALIGN(align, sizeof(void *));
-}
-
 static void
 init_kmem_cache_node(struct kmem_cache_node *n, struct kmem_cache *s)
 {
@@ -2955,14 +2929,6 @@ static int calculate_sizes(struct kmem_c
 #endif
 
 	/*
-	 * Determine the alignment based on various parameters that the
-	 * user specified and the dynamic determination of cache line size
-	 * on bootup.
-	 */
-	align = calculate_alignment(flags, align, s->object_size);
-	s->align = align;
-
-	/*
 	 * SLUB stores one object immediately after another beginning from
 	 * offset 0. In order to align the objects we have to simply size
 	 * each object to conform to the alignment.
@@ -2996,7 +2962,6 @@ static int calculate_sizes(struct kmem_c
 		s->max = s->oo;
 
 	return !!oo_objects(s->oo);
-
 }
 
 static int kmem_cache_open(struct kmem_cache *s)
@@ -3220,7 +3185,7 @@ static struct kmem_cache *__init create_
 	s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 	s->name = name;
 	s->size = s->object_size = size;
-	s->align = ARCH_KMALLOC_MINALIGN;
+	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
 	s->flags = flags;
 
 	/*
@@ -3681,6 +3646,8 @@ void __init kmem_cache_init(void)
 	kmem_cache_node->name = "kmem_cache_node";
 	kmem_cache_node->size = kmem_cache_node->object_size = sizeof(struct kmem_cache_node);
 	kmem_cache_node->flags = SLAB_HWCACHE_ALIGN;
+	kmem_cache_node->align = calculate_alignment(SLAB_HWCACHE_ALIGN,
+					0, sizeof(struct kmem_cache_node));
 
 	r = kmem_cache_open(kmem_cache_node);
 	if (r)
@@ -3695,6 +3662,8 @@ void __init kmem_cache_init(void)
 	kmem_cache->name = "kmem_cache";
 	kmem_cache->size = kmem_cache->object_size = kmem_size;
 	kmem_cache->flags = SLAB_HWCACHE_ALIGN;
+	kmem_cache->align = calculate_alignment(SLAB_HWCACHE_ALIGN,
+					0, sizeof(struct kmem_cache));
 
 	r = kmem_cache_open(kmem_cache);
 	if (r)
@@ -3918,7 +3887,9 @@ struct kmem_cache *__kmem_cache_alias(co
 
 int __kmem_cache_create(struct kmem_cache *s)
 {
-	int r = kmem_cache_open(s);
+	int r;
+
+	r = kmem_cache_open(s);
 
 	if (r)
 		return r;
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-06-01 08:27:19.462609243 -0500
+++ linux-2.6/mm/slab.h	2012-06-01 08:27:41.142608792 -0500
@@ -32,6 +32,9 @@ extern struct list_head slab_caches;
 /* The slab cache that manages slab cache information */
 extern struct kmem_cache *kmem_cache;
 
+unsigned long calculate_alignment(unsigned long flags,
+		unsigned long align, unsigned long size);
+
 /* Functions provided by the slab allocators */
 int __kmem_cache_create(struct kmem_cache *s);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
