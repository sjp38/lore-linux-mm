Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 3ED006B007B
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 17:12:06 -0400 (EDT)
Message-Id: <20120801211204.342096542@linux.com>
Date: Wed, 01 Aug 2012 16:11:45 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [15/16] Shrink __kmem_cache_create() parameter lists
References: <20120801211130.025389154@linux.com>
Content-Disposition: inline; filename=reduce_parameters
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Do the initial settings of the fields in common code. This will allow
us to push more processing into common code later and improve readability.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-01 15:56:37.662086761 -0500
+++ linux-2.6/mm/slab.h	2012-08-01 15:56:38.578103381 -0500
@@ -33,8 +33,7 @@
 extern struct kmem_cache *kmem_cache;
 
 /* Functions provided by the slab allocators */
-extern int __kmem_cache_create(struct kmem_cache *, const char *name,
-	size_t size, size_t align, unsigned long flags, void (*ctor)(void *));
+extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 
 extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
 			unsigned long flags);
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-01 15:56:37.662086761 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-01 15:58:41.936341265 -0500
@@ -53,8 +53,6 @@
 		unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
-	char *n;
-	int alias = 0;
 
 #ifdef CONFIG_DEBUG_VM
 	if (!name || in_interrupt() || size < sizeof(void *) ||
@@ -100,29 +98,36 @@
 #endif
 
 	s = __kmem_cache_alias(name, size, align, flags, ctor);
-	if (s) {
-		alias = 1;
-		goto oops;
-	}
-
-	n = kstrdup(name, GFP_KERNEL);
-	if (!n)
+	if (s)
 		goto oops;
 
 	s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 
 	if (s) {
-		int r = __kmem_cache_create(s, n, size, align, flags, ctor);
+		int r;
 
-		if (!r)
+		s->object_size = s->size = size;
+		s->align = align;
+		s->ctor = ctor;
+		s->name = kstrdup(name, GFP_KERNEL);
+		if (!s->name) {
+			kmem_cache_free(kmem_cache, s);
+			s = NULL;
+			goto oops;
+		}
+
+		r = __kmem_cache_create(s, flags);
+
+		if (!r) {
+			s->refcount = 1;
 			list_add(&s->list, &slab_caches);
-		else {
-			kfree(n);
+		} else {
+			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
 			s = NULL;
 		}
 	} else
-		kfree(n);
+		kfree(s->name);
 
 #ifdef CONFIG_DEBUG_VM
 oops:
@@ -136,7 +141,7 @@
 	if (!s && (flags & SLAB_PANIC))
 		panic("kmem_cache_create: Failed to create slab '%s'\n", name);
 
-	if (!alias)
+	if (s && s->refcount == 1)
 		sysfs_slab_add(s);
 
 	return s;
@@ -181,8 +186,10 @@
 	int r = -ENOMEM;
 
 	if (s) {
-		r = __kmem_cache_create(s, name, size, ARCH_KMALLOC_MINALIGN,
-		       	flags, NULL);
+		s->name = name;
+		s->size = s->object_size = size;
+		s->align = ARCH_KMALLOC_MINALIGN;
+		r = __kmem_cache_create(s, flags);
 
 		if (!r) {
 			list_add(&s->list, &slab_caches);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-01 15:56:37.662086761 -0500
+++ linux-2.6/mm/slub.c	2012-08-01 15:57:44.771304427 -0500
@@ -3022,16 +3022,9 @@
 
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
@@ -3093,7 +3086,6 @@
 	else
 		s->cpu_partial = 30;
 
-	s->refcount = 1;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
@@ -3108,7 +3100,7 @@
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slab %s size=%lu realsize=%u "
 			"order=%u offset=%u flags=%lx\n",
-			s->name, (unsigned long)size, s->size, oo_order(s->oo),
+			s->name, (unsigned long)s->size, s->size, oo_order(s->oo),
 			s->offset, flags);
 	return -EINVAL;
 }
@@ -3249,8 +3241,11 @@
 
 static int kmem_cache_open_boot(struct kmem_cache *s, const char *name, int size)
 {
-	return kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
-		SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	s->size = s->object_size = size;
+	s->name = name;
+	s->align = ARCH_KMALLOC_MINALIGN;
+	s->ctor = NULL;
+	return kmem_cache_open(s, SLAB_HWCACHE_ALIGN | SLAB_PANIC);
 }
 
 /*
@@ -3900,11 +3895,9 @@
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
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-01 15:56:37.658086688 -0500
+++ linux-2.6/mm/slab.c	2012-08-01 15:57:38.187184829 -0500
@@ -2339,8 +2339,7 @@
  * as davem.
  */
 int
-__kmem_cache_create (struct kmem_cache *cachep, const char *name, size_t size, size_t align,
-	unsigned long flags, void (*ctor)(void *))
+__kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 {
 	size_t left_over, slab_size, ralign;
 	gfp_t gfp;
@@ -2373,9 +2372,9 @@
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
@@ -2388,7 +2387,7 @@
 		 * one cacheline.
 		 */
 		ralign = cache_line_size();
-		while (size <= ralign / 2)
+		while (cachep->size <= ralign / 2)
 			ralign /= 2;
 	} else {
 		ralign = BYTES_PER_WORD;
@@ -2406,8 +2405,8 @@
 		ralign = REDZONE_ALIGN;
 		/* If redzoning, ensure that the second redzone is suitably
 		 * aligned, by adjusting the object size accordingly. */
-		size += REDZONE_ALIGN - 1;
-		size &= ~(REDZONE_ALIGN - 1);
+		cachep->size += REDZONE_ALIGN - 1;
+		cachep->size &= ~(REDZONE_ALIGN - 1);
 	}
 
 	/* 2) arch mandated alignment */
@@ -2415,8 +2414,8 @@
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
@@ -2424,7 +2423,7 @@
 	/*
 	 * 4) Store it.
 	 */
-	align = ralign;
+	cachep->align = ralign;
 
 	if (slab_is_available())
 		gfp = GFP_KERNEL;
@@ -2432,8 +2431,6 @@
 		gfp = GFP_NOWAIT;
 
 	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
-	cachep->object_size = size;
-	cachep->align = align;
 #if DEBUG
 
 	/*
@@ -2470,7 +2467,7 @@
 	 * it too early on. Always use on-slab management when
 	 * SLAB_NOLEAKTRACE to avoid recursive calls into kmemleak)
 	 */
-	if ((size >= (PAGE_SIZE >> 3)) && !slab_early_init &&
+	if ((cachep->size >= (PAGE_SIZE >> 3)) && !slab_early_init &&
 	    !(flags & SLAB_NOLEAKTRACE))
 		/*
 		 * Size is large, assume best to place the slab management obj
@@ -2478,17 +2475,15 @@
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
@@ -2509,23 +2504,22 @@
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
@@ -2538,9 +2532,6 @@
 		 */
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
-	cachep->ctor = ctor;
-	cachep->name = name;
-	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_shutdown(cachep);
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-08-01 15:56:37.662086761 -0500
+++ linux-2.6/mm/slob.c	2012-08-01 15:57:53.035454237 -0500
@@ -508,17 +508,15 @@
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
@@ -527,7 +525,6 @@
 		c->align = align;
 
 	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
-	c->refcount = 1;
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
