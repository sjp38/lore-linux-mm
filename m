Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id DE3F26B0070
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:20:30 -0400 (EDT)
Message-Id: <0000013a043cdd84-8ef9fc74-ac0d-4773-a044-459cb03ff40f-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 20:20:28 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK1 [05/13] Common alignment code
References: <20120926200005.911809821@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Extract the code to do object alignment from the allocators.
Do the alignment calculations in slab_common so that the
__kmem_cache_create functions of the allocators do not have
to deal with alignment.

Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |   20 --------------------
 mm/slab.h        |    3 +++
 mm/slab_common.c |   32 ++++++++++++++++++++++++++++++--
 mm/slob.c        |   10 ----------
 mm/slub.c        |   38 +-------------------------------------
 5 files changed, 34 insertions(+), 69 deletions(-)

Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2012-09-19 09:21:14.422971030 -0500
+++ linux/mm/slab.h	2012-09-19 09:21:24.235174758 -0500
@@ -32,6 +32,9 @@ extern struct list_head slab_caches;
 /* The slab cache that manages slab cache information */
 extern struct kmem_cache *kmem_cache;
 
+unsigned long calculate_alignment(unsigned long flags,
+		unsigned long align, unsigned long size);
+
 /* Functions provided by the slab allocators */
 extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-19 09:21:14.422971030 -0500
+++ linux/mm/slab_common.c	2012-09-19 09:21:24.235174758 -0500
@@ -71,6 +71,34 @@ static inline int kmem_cache_sanity_chec
 #endif
 
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
@@ -115,7 +143,7 @@ struct kmem_cache *kmem_cache_create(con
 	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
 	if (s) {
 		s->object_size = s->size = size;
-		s->align = align;
+		s->align = calculate_alignment(flags, align, size);
 		s->ctor = ctor;
 		s->name = kstrdup(name, GFP_KERNEL);
 		if (!s->name) {
@@ -198,7 +226,7 @@ void __init create_boot_cache(struct kme
 
 	s->name = name;
 	s->size = s->object_size = size;
-	s->align = ARCH_KMALLOC_MINALIGN;
+	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
 	err = __kmem_cache_create(s, flags);
 
 	if (err)
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2012-09-19 09:21:11.354907281 -0500
+++ linux/mm/slob.c	2012-09-19 09:21:24.235174758 -0500
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
 
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-19 09:21:18.403053765 -0500
+++ linux/mm/slub.c	2012-09-19 09:21:24.239174845 -0500
@@ -2761,32 +2761,6 @@ static inline int calculate_order(int si
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
@@ -2920,7 +2894,6 @@ static int calculate_sizes(struct kmem_c
 {
 	unsigned long flags = s->flags;
 	unsigned long size = s->object_size;
-	unsigned long align = s->align;
 	int order;
 
 	/*
@@ -2992,19 +2965,11 @@ static int calculate_sizes(struct kmem_c
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
@@ -3033,7 +2998,6 @@ static int calculate_sizes(struct kmem_c
 		s->max = s->oo;
 
 	return !!oo_objects(s->oo);
-
 }
 
 static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
