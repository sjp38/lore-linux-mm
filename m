Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 3A3806B0074
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 15:22:01 -0400 (EDT)
Message-Id: <20120803192159.421766959@linux.com>
Date: Fri, 03 Aug 2012 14:21:12 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common10 [20/20] Common alignment code
References: <20120803192052.448575403@linux.com>
Content-Disposition: inline; filename=common_alignment
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

Extract the code to do object alignment from the allocators.
Do the alignment calculations in slab_common so that the
__kmem_cache_create functions of the allocators do not have
to deal with alignment.

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
--- linux-2.6.orig/mm/slab.c	2012-08-03 13:59:45.394594227 -0500
+++ linux-2.6/mm/slab.c	2012-08-03 14:01:27.200431671 -0500
@@ -2369,22 +2369,6 @@ __kmem_cache_create (struct kmem_cache *
 		cachep->size &= ~(BYTES_PER_WORD - 1);
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
-		while (cachep->size <= ralign / 2)
-			ralign /= 2;
-	} else {
-		ralign = BYTES_PER_WORD;
-	}
-
 	/*
 	 * Redzoning and user store require word alignment or possibly larger.
 	 * Note this will be overridden by architecture or caller mandated
@@ -2401,10 +2385,6 @@ __kmem_cache_create (struct kmem_cache *
 		cachep->size &= ~(REDZONE_ALIGN - 1);
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
--- linux-2.6.orig/mm/slab_common.c	2012-08-03 13:54:42.000000000 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-03 14:02:49.785922392 -0500
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
@@ -100,7 +128,7 @@ struct kmem_cache *kmem_cache_create(con
 	s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 	if (s) {
 		s->object_size = s->size = size;
-		s->align = align;
+		s->align = calculate_alignment(flags, align, size);
 		s->ctor = ctor;
 		s->name = kstrdup(name, GFP_KERNEL);
 		if (!s->name) {
@@ -189,7 +217,7 @@ void __init create_boot_cache(struct kme
 
 	s->name = name;
 	s->size = s->object_size = size;
-	s->align = ARCH_KMALLOC_MINALIGN;
+	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
 	err = __kmem_cache_create(s, flags);
 
 	if (err)
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-08-03 13:50:36.000000000 -0500
+++ linux-2.6/mm/slob.c	2012-08-03 14:01:27.200431671 -0500
@@ -124,7 +124,6 @@ static inline void clear_slob_page_free(
 
 #define SLOB_UNIT sizeof(slob_t)
 #define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT)
-#define SLOB_ALIGN L1_CACHE_BYTES
 
 /*
  * struct slob_rcu is inserted at the tail of allocated slob blocks, which
@@ -510,20 +509,11 @@ EXPORT_SYMBOL(ksize);
 
 int __kmem_cache_create(struct kmem_cache *c, unsigned long flags)
 {
-	size_t align = c->size;
-
 	if (flags & SLAB_DESTROY_BY_RCU) {
 		/* leave room for rcu footer at the end of object */
 		c->size += sizeof(struct slob_rcu);
 	}
 	c->flags = flags;
-	/* ignore alignment unless it's forced */
-	c->align = (flags & SLAB_HWCACHE_ALIGN) ? SLOB_ALIGN : 0;
-	if (c->align < ARCH_SLAB_MINALIGN)
-		c->align = ARCH_SLAB_MINALIGN;
-	if (c->align < align)
-		c->align = align;
-
 	return 0;
 }
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-03 13:50:36.000000000 -0500
+++ linux-2.6/mm/slub.c	2012-08-03 14:01:27.204431729 -0500
@@ -2747,32 +2747,6 @@ static inline int calculate_order(int si
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
 init_kmem_cache_node(struct kmem_cache_node *n)
 {
@@ -2906,7 +2880,6 @@ static int calculate_sizes(struct kmem_c
 {
 	unsigned long flags = s->flags;
 	unsigned long size = s->object_size;
-	unsigned long align = s->align;
 	int order;
 
 	/*
@@ -2978,19 +2951,11 @@ static int calculate_sizes(struct kmem_c
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
 	 */
-	size = ALIGN(size, align);
+	size = ALIGN(size, s->align);
 	s->size = size;
 	if (forced_order >= 0)
 		order = forced_order;
@@ -3019,7 +2984,6 @@ static int calculate_sizes(struct kmem_c
 		s->max = s->oo;
 
 	return !!oo_objects(s->oo);
-
 }
 
 static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-03 13:54:42.000000000 -0500
+++ linux-2.6/mm/slab.h	2012-08-03 14:01:27.204431729 -0500
@@ -32,6 +32,9 @@ extern struct list_head slab_caches;
 /* The slab cache that manages slab cache information */
 extern struct kmem_cache *kmem_cache;
 
+unsigned long calculate_alignment(unsigned long flags,
+		unsigned long align, unsigned long size);
+
 /* Functions provided by the slab allocators */
 extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
