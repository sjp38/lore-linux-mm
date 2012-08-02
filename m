Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 398DF6B0085
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:15:41 -0400 (EDT)
Message-Id: <20120802201539.447559271@linux.com>
Date: Thu, 02 Aug 2012 15:15:22 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [16/19] Move kmem_cache allocations into common code.
References: <20120802201506.266817615@linux.com>
Content-Disposition: inline; filename=kmem_alloc_common
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

Shift the allocations to common code. That way the allocation
and freeing of the kmem_cache structures is handled by common code.

V1-V2: Use the return code from setup_cpucache() in slab instead of returning -ENOSPC

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-02 14:23:17.660018494 -0500
+++ linux-2.6/mm/slab.c	2012-08-02 14:23:29.056222811 -0500
@@ -2338,13 +2338,13 @@
  * cacheline.  This can be beneficial if you're counting cycles as closely
  * as davem.
  */
-struct kmem_cache *
-__kmem_cache_create (const char *name, size_t size, size_t align,
+int
+__kmem_cache_create (struct kmem_cache *cachep, const char *name, size_t size, size_t align,
 	unsigned long flags, void (*ctor)(void *))
 {
 	size_t left_over, slab_size, ralign;
-	struct kmem_cache *cachep = NULL;
 	gfp_t gfp;
+	int err;
 
 #if DEBUG
 #if FORCED_DEBUG
@@ -2432,11 +2432,6 @@
 	else
 		gfp = GFP_NOWAIT;
 
-	/* Get cache's description obj. */
-	cachep = kmem_cache_zalloc(kmem_cache, gfp);
-	if (!cachep)
-		return NULL;
-
 	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
 	cachep->object_size = size;
 	cachep->align = align;
@@ -2491,8 +2486,7 @@
 	if (!cachep->num) {
 		printk(KERN_ERR
 		       "kmem_cache_create: couldn't create cache %s.\n", name);
-		kmem_cache_free(kmem_cache, cachep);
-		return NULL;
+		return -E2BIG;
 	}
 	slab_size = ALIGN(cachep->num * sizeof(kmem_bufctl_t)
 			  + sizeof(struct slab), align);
@@ -2549,9 +2543,10 @@
 	cachep->name = name;
 	cachep->refcount = 1;
 
-	if (setup_cpu_cache(cachep, gfp)) {
+	err = setup_cpu_cache(cachep, gfp);
+	if (err) {
 		__kmem_cache_shutdown(cachep);
-		return NULL;
+		return err;
 	}
 
 	if (flags & SLAB_DEBUG_OBJECTS) {
@@ -2564,7 +2559,7 @@
 		slab_set_debugobj_lock_classes(cachep);
 	}
 
-	return cachep;
+	return 0;
 }
 
 #if DEBUG
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-02 14:23:17.000000000 -0500
+++ linux-2.6/mm/slab.h	2012-08-02 14:23:29.056222811 -0500
@@ -33,8 +33,8 @@
 extern struct kmem_cache *kmem_cache;
 
 /* Functions provided by the slab allocators */
-extern struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
-	size_t align, unsigned long flags, void (*ctor)(void *));
+extern int __kmem_cache_create(struct kmem_cache *, const char *name,
+	size_t size, size_t align, unsigned long flags, void (*ctor)(void *));
 
 extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
 			unsigned long flags);
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-02 14:23:17.000000000 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-02 14:26:20.039275929 -0500
@@ -104,19 +104,23 @@
 		goto out_locked;
 	}
 
-	s = __kmem_cache_create(n, size, align, flags, ctor);
+	s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 
 	if (s) {
-		/*
-		 * Check if the slab has actually been created and if it was a
-		 * real instatiation. Aliases do not belong on the list
-		 */
-		if (s->refcount == 1)
+		err = __kmem_cache_create(s, n, size, align, flags, ctor);
+
+		if (!err)
+
 			list_add(&s->list, &slab_caches);
 
+		else {
+			kfree(n);
+			kmem_cache_free(kmem_cache, s);
+		}
+
 	} else {
 		kfree(n);
-		err = -ENOSYS; /* Until __kmem_cache_create returns code */
+		err = -ENOMEM;
 	}
 
 out_locked:
@@ -181,17 +185,21 @@
 struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
 				unsigned long flags)
 {
-	struct kmem_cache *s;
+	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
+	int r = -ENOMEM;
 
-	s = __kmem_cache_create(name, size, ARCH_KMALLOC_MINALIGN,
+	if (s) {
+		r = __kmem_cache_create(s, name, size, ARCH_KMALLOC_MINALIGN,
 		       	flags, NULL);
 
-	if (s) {
-		list_add(&s->list, &slab_caches);
-		return s;
+		if (!r) {
+			list_add(&s->list, &slab_caches);
+			return s;
+		}
 	}
 
-	panic("Creation of kmalloc slab %s size=%ld failed.\n", name, size);
+	panic("Creation of kmalloc slab %s size=%ld failed. Reason %d\n",
+		       			name, size, r);
 	return NULL;
 }
 
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-08-02 14:21:24.000000000 -0500
+++ linux-2.6/mm/slob.c	2012-08-02 14:23:29.056222811 -0500
@@ -508,34 +508,27 @@
 }
 EXPORT_SYMBOL(ksize);
 
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+int __kmem_cache_create(struct kmem_cache *c, const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *))
 {
-	struct kmem_cache *c;
-
-	c = slob_alloc(sizeof(struct kmem_cache),
-		GFP_KERNEL, ARCH_KMALLOC_MINALIGN, -1);
-
-	if (c) {
-		c->name = name;
-		c->size = size;
-		if (flags & SLAB_DESTROY_BY_RCU) {
-			/* leave room for rcu footer at the end of object */
-			c->size += sizeof(struct slob_rcu);
-		}
-		c->flags = flags;
-		c->ctor = ctor;
-		/* ignore alignment unless it's forced */
-		c->align = (flags & SLAB_HWCACHE_ALIGN) ? SLOB_ALIGN : 0;
-		if (c->align < ARCH_SLAB_MINALIGN)
-			c->align = ARCH_SLAB_MINALIGN;
-		if (c->align < align)
-			c->align = align;
-
-		kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
-		c->refcount = 1;
+	c->name = name;
+	c->size = size;
+	if (flags & SLAB_DESTROY_BY_RCU) {
+		/* leave room for rcu footer at the end of object */
+		c->size += sizeof(struct slob_rcu);
 	}
-	return c;
+	c->flags = flags;
+	c->ctor = ctor;
+	/* ignore alignment unless it's forced */
+	c->align = (flags & SLAB_HWCACHE_ALIGN) ? SLOB_ALIGN : 0;
+	if (c->align < ARCH_SLAB_MINALIGN)
+		c->align = ARCH_SLAB_MINALIGN;
+	if (c->align < align)
+		c->align = align;
+
+	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
+	c->refcount = 1;
+	return 0;
 }
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-02 14:23:21.000000000 -0500
+++ linux-2.6/mm/slub.c	2012-08-02 14:23:29.060222898 -0500
@@ -3027,7 +3027,6 @@
 		size_t align, unsigned long flags,
 		void (*ctor)(void *))
 {
-	memset(s, 0, kmem_size);
 	s->name = name;
 	s->ctor = ctor;
 	s->object_size = size;
@@ -3102,7 +3101,7 @@
 		goto error;
 
 	if (alloc_kmem_cache_cpus(s))
-		return 1;
+		return 0;
 
 	free_kmem_cache_nodes(s);
 error:
@@ -3111,7 +3110,7 @@
 			"order=%u offset=%u flags=%lx\n",
 			s->name, (unsigned long)size, s->size, oo_order(s->oo),
 			s->offset, flags);
-	return 0;
+	return -EINVAL;
 }
 
 /*
@@ -3901,20 +3900,11 @@
 	return s;
 }
 
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+int __kmem_cache_create(struct kmem_cache *s,
+		const char *name, size_t size,
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
-	struct kmem_cache *s;
-
-	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
-	if (s) {
-		if (kmem_cache_open(s, name,
-				size, align, flags, ctor)) {
-			return s;
-		}
-		kmem_cache_free(kmem_cache, s);
-	}
-	return NULL;
+	return kmem_cache_open(s, name, size, align, flags, ctor);
 }
 
 #ifdef CONFIG_SMP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
