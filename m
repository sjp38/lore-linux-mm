Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 36DC06B00A4
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:17:40 -0400 (EDT)
Message-Id: <00000139596cab81-8759391f-4d20-494a-9c7c-a759363e2b87-000000@email.amazonses.com>
Date: Fri, 24 Aug 2012 16:17:38 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C13 [13/14] Shrink __kmem_cache_create() parameter lists
References: <20120824160903.168122683@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Do the initial settings of the fields in common code. This will allow
us to push more processing into common code later and improve readability.

Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |   91 ++++++++++++++++++++++++------------------------------
 mm/slab.h        |    3 +-
 mm/slab_common.c |   26 ++++++++--------
 mm/slob.c        |    8 ++---
 mm/slub.c        |   39 +++++++++++------------
 5 files changed, 76 insertions(+), 91 deletions(-)

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-08-22 16:00:44.201655179 -0500
+++ linux/mm/slab.c	2012-08-22 16:00:45.705677849 -0500
@@ -1667,20 +1667,20 @@ void __init kmem_cache_init(void)
 	 */
 
 	sizes[INDEX_AC].cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-	__kmem_cache_create(sizes[INDEX_AC].cs_cachep, names[INDEX_AC].name,
-					sizes[INDEX_AC].cs_size,
-					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
-					NULL);
-
+	sizes[INDEX_AC].cs_cachep->name = names[INDEX_AC].name;
+	sizes[INDEX_AC].cs_cachep->size = sizes[INDEX_AC].cs_size;
+	sizes[INDEX_AC].cs_cachep->object_size = sizes[INDEX_AC].cs_size;
+	sizes[INDEX_AC].cs_cachep->align = ARCH_KMALLOC_MINALIGN;
+	__kmem_cache_create(sizes[INDEX_AC].cs_cachep, ARCH_KMALLOC_FLAGS|SLAB_PANIC);
 	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
+
 	if (INDEX_AC != INDEX_L3) {
 		sizes[INDEX_L3].cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-		__kmem_cache_create(sizes[INDEX_L3].cs_cachep, names[INDEX_L3].name,
-				sizes[INDEX_L3].cs_size,
-				ARCH_KMALLOC_MINALIGN,
-				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
-				NULL);
+		sizes[INDEX_L3].cs_cachep->name = names[INDEX_L3].name;
+		sizes[INDEX_L3].cs_cachep->size = sizes[INDEX_L3].cs_size;
+		sizes[INDEX_L3].cs_cachep->object_size = sizes[INDEX_L3].cs_size;
+		sizes[INDEX_L3].cs_cachep->align = ARCH_KMALLOC_MINALIGN;
+		__kmem_cache_create(sizes[INDEX_L3].cs_cachep, ARCH_KMALLOC_FLAGS|SLAB_PANIC);
 		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
 	}
 
@@ -1696,22 +1696,21 @@ void __init kmem_cache_init(void)
 		 */
 		if (!sizes->cs_cachep) {
 			sizes->cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-			__kmem_cache_create(sizes->cs_cachep, names->name,
-					sizes->cs_size,
-					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
-					NULL);
+			sizes->cs_cachep->name = names->name;
+			sizes->cs_cachep->size = sizes->cs_size;
+			sizes->cs_cachep->object_size = sizes->cs_size;
+			sizes->cs_cachep->align = ARCH_KMALLOC_MINALIGN;
+			__kmem_cache_create(sizes->cs_cachep, ARCH_KMALLOC_FLAGS|SLAB_PANIC);
 			list_add(&sizes->cs_cachep->list, &slab_caches);
 		}
 #ifdef CONFIG_ZONE_DMA
 		sizes->cs_dmacachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
+		sizes->cs_dmacachep->name = names->name_dma;
+		sizes->cs_dmacachep->size = sizes->cs_size;
+		sizes->cs_dmacachep->object_size = sizes->cs_size;
+		sizes->cs_dmacachep->align = ARCH_KMALLOC_MINALIGN;
 		__kmem_cache_create(sizes->cs_dmacachep,
-					names->name_dma,
-					sizes->cs_size,
-					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
-						SLAB_PANIC,
-					NULL);
+			       ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA| SLAB_PANIC);
 		list_add(&sizes->cs_dmacachep->list, &slab_caches);
 #endif
 		sizes++;
@@ -2350,8 +2349,7 @@ static int __init_refok setup_cpu_cache(
  * as davem.
  */
 int
-__kmem_cache_create (struct kmem_cache *cachep, const char *name, size_t size, size_t align,
-	unsigned long flags, void (*ctor)(void *))
+__kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 {
 	size_t left_over, slab_size, ralign;
 	gfp_t gfp;
@@ -2385,9 +2383,9 @@ __kmem_cache_create (struct kmem_cache *
 	 * unaligned accesses for some archs when redzoning is used, and makes
 	 * sure any on-slab bufctl's are also correctly aligned.
 	 */
-	if (size & (BYTES_PER_WORD - 1)) {
-		size += (BYTES_PER_WORD - 1);
-		size &= ~(BYTES_PER_WORD - 1);
+	if (cachep->size & (BYTES_PER_WORD - 1)) {
+		cachep->size += (BYTES_PER_WORD - 1);
+		cachep->size &= ~(BYTES_PER_WORD - 1);
 	}
 
 	/* calculate the final buffer alignment: */
@@ -2400,7 +2398,7 @@ __kmem_cache_create (struct kmem_cache *
 		 * one cacheline.
 		 */
 		ralign = cache_line_size();
-		while (size <= ralign / 2)
+		while (cachep->size <= ralign / 2)
 			ralign /= 2;
 	} else {
 		ralign = BYTES_PER_WORD;
@@ -2418,8 +2416,8 @@ __kmem_cache_create (struct kmem_cache *
 		ralign = REDZONE_ALIGN;
 		/* If redzoning, ensure that the second redzone is suitably
 		 * aligned, by adjusting the object size accordingly. */
-		size += REDZONE_ALIGN - 1;
-		size &= ~(REDZONE_ALIGN - 1);
+		cachep->size += REDZONE_ALIGN - 1;
+		cachep->size &= ~(REDZONE_ALIGN - 1);
 	}
 
 	/* 2) arch mandated alignment */
@@ -2427,8 +2425,8 @@ __kmem_cache_create (struct kmem_cache *
 		ralign = ARCH_SLAB_MINALIGN;
 	}
 	/* 3) caller mandated alignment */
-	if (ralign < align) {
-		ralign = align;
+	if (ralign < cachep->align) {
+		ralign = cachep->align;
 	}
 	/* disable debug if necessary */
 	if (ralign > __alignof__(unsigned long long))
@@ -2436,7 +2434,7 @@ __kmem_cache_create (struct kmem_cache *
 	/*
 	 * 4) Store it.
 	 */
-	align = ralign;
+	cachep->align = ralign;
 
 	if (slab_is_available())
 		gfp = GFP_KERNEL;
@@ -2444,8 +2442,6 @@ __kmem_cache_create (struct kmem_cache *
 		gfp = GFP_NOWAIT;
 
 	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
-	cachep->object_size = size;
-	cachep->align = align;
 #if DEBUG
 
 	/*
@@ -2482,7 +2478,7 @@ __kmem_cache_create (struct kmem_cache *
 	 * it too early on. Always use on-slab management when
 	 * SLAB_NOLEAKTRACE to avoid recursive calls into kmemleak)
 	 */
-	if ((size >= (PAGE_SIZE >> 3)) && !slab_early_init &&
+	if ((cachep->size >= (PAGE_SIZE >> 3)) && !slab_early_init &&
 	    !(flags & SLAB_NOLEAKTRACE))
 		/*
 		 * Size is large, assume best to place the slab management obj
@@ -2490,17 +2486,15 @@ __kmem_cache_create (struct kmem_cache *
 		 */
 		flags |= CFLGS_OFF_SLAB;
 
-	size = ALIGN(size, align);
+	cachep->size = ALIGN(cachep->size, cachep->align);
 
-	left_over = calculate_slab_order(cachep, size, align, flags);
+	left_over = calculate_slab_order(cachep, cachep->size, cachep->align, flags);
 
-	if (!cachep->num) {
-		printk(KERN_ERR
-		       "kmem_cache_create: couldn't create cache %s.\n", name);
+	if (!cachep->num)
 		return -E2BIG;
-	}
+
 	slab_size = ALIGN(cachep->num * sizeof(kmem_bufctl_t)
-			  + sizeof(struct slab), align);
+			  + sizeof(struct slab), cachep->align);
 
 	/*
 	 * If the slab has been placed off-slab, and we have enough space then
@@ -2521,23 +2515,22 @@ __kmem_cache_create (struct kmem_cache *
 		 * poisoning, then it's going to smash the contents of
 		 * the redzone and userword anyhow, so switch them off.
 		 */
-		if (size % PAGE_SIZE == 0 && flags & SLAB_POISON)
+		if (cachep->size % PAGE_SIZE == 0 && flags & SLAB_POISON)
 			flags &= ~(SLAB_RED_ZONE | SLAB_STORE_USER);
 #endif
 	}
 
 	cachep->colour_off = cache_line_size();
 	/* Offset must be a multiple of the alignment. */
-	if (cachep->colour_off < align)
-		cachep->colour_off = align;
+	if (cachep->colour_off < cachep->align)
+		cachep->colour_off = cachep->align;
 	cachep->colour = left_over / cachep->colour_off;
 	cachep->slab_size = slab_size;
 	cachep->flags = flags;
 	cachep->allocflags = 0;
 	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
 		cachep->allocflags |= GFP_DMA;
-	cachep->size = size;
-	cachep->reciprocal_buffer_size = reciprocal_value(size);
+	cachep->reciprocal_buffer_size = reciprocal_value(cachep->size);
 
 	if (flags & CFLGS_OFF_SLAB) {
 		cachep->slabp_cache = kmem_find_general_cachep(slab_size, 0u);
@@ -2550,8 +2543,6 @@ __kmem_cache_create (struct kmem_cache *
 		 */
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
-	cachep->ctor = ctor;
-	cachep->name = name;
 	cachep->refcount = 1;
 
 	err = setup_cpu_cache(cachep, gfp);
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2012-08-22 16:00:44.205655239 -0500
+++ linux/mm/slab.h	2012-08-22 16:00:45.705677849 -0500
@@ -33,8 +33,7 @@ extern struct list_head slab_caches;
 extern struct kmem_cache *kmem_cache;
 
 /* Functions provided by the slab allocators */
-extern int __kmem_cache_create(struct kmem_cache *, const char *name,
-	size_t size, size_t align, unsigned long flags, void (*ctor)(void *));
+extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 
 #ifdef CONFIG_SLUB
 struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-08-22 16:00:44.205655239 -0500
+++ linux/mm/slab_common.c	2012-08-22 16:00:45.705677849 -0500
@@ -100,7 +100,6 @@ struct kmem_cache *kmem_cache_create(con
 {
 	struct kmem_cache *s = NULL;
 	int err = 0;
-	char *n;
 
 	get_online_cpus();
 	mutex_lock(&slab_mutex);
@@ -109,32 +108,33 @@ struct kmem_cache *kmem_cache_create(con
 		goto out_locked;
 
 
-	n = kstrdup(name, GFP_KERNEL);
-	if (!n) {
-		err = -ENOMEM;
-		goto out_locked;
-	}
-
 	s = __kmem_cache_alias(name, size, align, flags, ctor);
 	if (s)
 		goto out_locked;
 
 	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
 	if (s) {
-		err = __kmem_cache_create(s, n, size, align, flags, ctor);
+		s->object_size = s->size = size;
+		s->align = align;
+		s->ctor = ctor;
+		s->name = kstrdup(name, GFP_KERNEL);
+		if (!s->name) {
+			kmem_cache_free(kmem_cache, s);
+			err = -ENOMEM;
+			goto out_locked;
+		}
+
+		err = __kmem_cache_create(s, flags);
 		if (!err)
 
 			list_add(&s->list, &slab_caches);
 
 		else {
-			kfree(n);
+			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
 		}
-
-	} else {
-		kfree(n);
+	} else
 		err = -ENOMEM;
-	}
 
 out_locked:
 	mutex_unlock(&slab_mutex);
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2012-08-22 16:00:44.205655239 -0500
+++ linux/mm/slob.c	2012-08-22 16:00:45.705677849 -0500
@@ -508,17 +508,15 @@ size_t ksize(const void *block)
 }
 EXPORT_SYMBOL(ksize);
 
-int __kmem_cache_create(struct kmem_cache *c, const char *name, size_t size,
-	size_t align, unsigned long flags, void (*ctor)(void *))
+int __kmem_cache_create(struct kmem_cache *c, unsigned long flags)
 {
-	c->name = name;
-	c->size = size;
+	size_t align = c->size;
+
 	if (flags & SLAB_DESTROY_BY_RCU) {
 		/* leave room for rcu footer at the end of object */
 		c->size += sizeof(struct slob_rcu);
 	}
 	c->flags = flags;
-	c->ctor = ctor;
 	/* ignore alignment unless it's forced */
 	c->align = (flags & SLAB_HWCACHE_ALIGN) ? SLOB_ALIGN : 0;
 	if (c->align < ARCH_SLAB_MINALIGN)
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-08-22 16:00:44.737663265 -0500
+++ linux/mm/slub.c	2012-08-22 16:00:45.709677909 -0500
@@ -3029,16 +3029,9 @@ static int calculate_sizes(struct kmem_c
 
 }
 
-static int kmem_cache_open(struct kmem_cache *s,
-		const char *name, size_t size,
-		size_t align, unsigned long flags,
-		void (*ctor)(void *))
+static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 {
-	s->name = name;
-	s->ctor = ctor;
-	s->object_size = size;
-	s->align = align;
-	s->flags = kmem_cache_flags(size, flags, name, ctor);
+	s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
 	s->reserved = 0;
 
 	if (need_reserve_slab_rcu && (s->flags & SLAB_DESTROY_BY_RCU))
@@ -3115,7 +3108,7 @@ error:
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slab %s size=%lu realsize=%u "
 			"order=%u offset=%u flags=%lx\n",
-			s->name, (unsigned long)size, s->size, oo_order(s->oo),
+			s->name, (unsigned long)s->size, s->size, oo_order(s->oo),
 			s->offset, flags);
 	return -EINVAL;
 }
@@ -3261,12 +3254,15 @@ static struct kmem_cache *__init create_
 
 	s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 
+	s->name = name;
+	s->size = s->object_size = size;
+	s->align = ARCH_KMALLOC_MINALIGN;
+
 	/*
 	 * This function is called with IRQs disabled during early-boot on
 	 * single CPU so there's no need to take slab_mutex here.
 	 */
-	if (kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
-								flags, NULL))
+	if (kmem_cache_open(s, flags))
 		goto panic;
 
 	list_add(&s->list, &slab_caches);
@@ -3719,9 +3715,10 @@ void __init kmem_cache_init(void)
 	 */
 	kmem_cache_node = (void *)kmem_cache + kmalloc_size;
 
-	kmem_cache_open(kmem_cache_node, "kmem_cache_node",
-		sizeof(struct kmem_cache_node),
-		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	kmem_cache_node->name = "kmem_cache_node";
+	kmem_cache_node->size = kmem_cache_node->object_size =
+		sizeof(struct kmem_cache_node);
+	kmem_cache_open(kmem_cache_node, SLAB_HWCACHE_ALIGN | SLAB_PANIC);
 
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
 
@@ -3729,8 +3726,10 @@ void __init kmem_cache_init(void)
 	slab_state = PARTIAL;
 
 	temp_kmem_cache = kmem_cache;
-	kmem_cache_open(kmem_cache, "kmem_cache", kmem_size,
-		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	kmem_cache->name = "kmem_cache";
+	kmem_cache->size = kmem_cache->object_size = kmem_size;
+	kmem_cache_open(kmem_cache, SLAB_HWCACHE_ALIGN | SLAB_PANIC);
+
 	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
 	memcpy(kmem_cache, temp_kmem_cache, kmem_size);
 
@@ -3943,11 +3942,9 @@ struct kmem_cache *__kmem_cache_alias(co
 	return s;
 }
 
-int __kmem_cache_create(struct kmem_cache *s,
-		const char *name, size_t size,
-		size_t align, unsigned long flags, void (*ctor)(void *))
+int __kmem_cache_create(struct kmem_cache *s, unsigned long flags)
 {
-	return kmem_cache_open(s, name, size, align, flags, ctor);
+	return kmem_cache_open(s, flags);
 }
 
 #ifdef CONFIG_SMP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
