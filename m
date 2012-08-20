Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id A1BF86B008C
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 17:01:57 -0400 (EDT)
Message-Id: <0000013945d78345-62099ff3-9364-4fbe-86db-0da855cfecd1-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 21:01:55 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [19/19] Common alignment code
References: <20120820204021.494276880@linux.com>
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

diff --git a/mm/slab.c b/mm/slab.c
index 0612c54..6c26dec 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2361,22 +2361,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
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
@@ -2393,10 +2377,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		cachep->size &= ~(REDZONE_ALIGN - 1);
 	}
 
-	/* 2) arch mandated alignment */
-	if (ralign < ARCH_SLAB_MINALIGN) {
-		ralign = ARCH_SLAB_MINALIGN;
-	}
 	/* 3) caller mandated alignment */
 	if (ralign < cachep->align) {
 		ralign = cachep->align;
diff --git a/mm/slab.h b/mm/slab.h
index ad8a7de..799f29a 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -32,6 +32,9 @@ extern struct list_head slab_caches;
 /* The slab cache that manages slab cache information */
 extern struct kmem_cache *kmem_cache;
 
+unsigned long calculate_alignment(unsigned long flags,
+		unsigned long align, unsigned long size);
+
 /* Functions provided by the slab allocators */
 extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index db7b6cf..4268c40 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -71,6 +71,34 @@ static inline int kmem_cache_sanity_check(const char *name, size_t size)
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
@@ -115,7 +143,7 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
 	if (s) {
 		s->object_size = s->size = size;
-		s->align = align;
+		s->align = calculate_alignment(flags, align, size);
 		s->ctor = ctor;
 		s->name = kstrdup(name, GFP_KERNEL);
 		if (!s->name) {
@@ -206,7 +234,7 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t siz
 
 	s->name = name;
 	s->size = s->object_size = size;
-	s->align = ARCH_KMALLOC_MINALIGN;
+	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
 	err = __kmem_cache_create(s, flags);
 
 	if (err)
diff --git a/mm/slob.c b/mm/slob.c
index 3edfeaa..8a73604 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -124,7 +124,6 @@ static inline void clear_slob_page_free(struct page *sp)
 
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
 
diff --git a/mm/slub.c b/mm/slub.c
index 2610bcb..6a44211 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2754,32 +2754,6 @@ static inline int calculate_order(int size, int reserved)
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
@@ -2913,7 +2887,6 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 {
 	unsigned long flags = s->flags;
 	unsigned long size = s->object_size;
-	unsigned long align = s->align;
 	int order;
 
 	/*
@@ -2985,19 +2958,11 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
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
@@ -3026,7 +2991,6 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 		s->max = s->oo;
 
 	return !!oo_objects(s->oo);
-
 }
 
 static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
-- 
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
