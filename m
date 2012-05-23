Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 5821A6B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:45:16 -0400 (EDT)
Message-Id: <20120523203515.816134866@linux.com>
Date: Wed, 23 May 2012 15:34:52 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common 19/22] Do not pass ctor to __kmem_cache_create()
References: <20120523203433.340661918@linux.com>
Content-Disposition: inline; filename=no_passing_of_ctor
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Set the ctor field like the name field directly in the kmem_cache
structure after alloc before calling the allocator specific portion.

Also extract refcount handling to common code.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.h        |    2 +-
 mm/slab_common.c |    9 +++++----
 mm/slob.c        |    4 +---
 mm/slub.c        |   17 +++++++----------
 4 files changed, 14 insertions(+), 18 deletions(-)

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-05-23 08:54:34.202687757 -0500
+++ linux-2.6/mm/slab_common.c	2012-05-23 08:54:35.234687733 -0500
@@ -115,12 +115,13 @@ struct kmem_cache *kmem_cache_create(con
 	}
 
 	s->name = n;
+	s->ctor = ctor;
+	r = __kmem_cache_create(s, size, align, flags);
 
-	r = __kmem_cache_create(s, size, align, flags, ctor);
-
-	if (!r)
+	if (!r) {
+		s->refcount = 1;
 		list_add(&s->list, &slab_caches);
-	else {
+	} else {
 		kmem_cache_free(kmem_cache, s);
 		kfree(n);
 		s = NULL;
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-05-23 08:54:34.202687757 -0500
+++ linux-2.6/mm/slab.h	2012-05-23 08:54:35.234687733 -0500
@@ -34,7 +34,7 @@ extern struct kmem_cache *kmem_cache;
 
 /* Functions provided by the slab allocators */
 int __kmem_cache_create(struct kmem_cache *s, size_t size,
-	size_t align, unsigned long flags, void (*ctor)(void *));
+	size_t align, unsigned long flags);
 
 #ifdef CONFIG_SLUB
 struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-05-23 08:54:34.210687755 -0500
+++ linux-2.6/mm/slob.c	2012-05-23 08:55:12.074686972 -0500
@@ -509,7 +509,7 @@ size_t ksize(const void *block)
 EXPORT_SYMBOL(ksize);
 
 int __kmem_cache_create(struct kmem_cache *c, size_t size,
-	size_t align, unsigned long flags, void (*ctor)(void *))
+	size_t align, unsigned long flags)
 {
 	c->size = size;
 	if (flags & SLAB_DESTROY_BY_RCU) {
@@ -517,7 +517,6 @@ int __kmem_cache_create(struct kmem_cach
 		c->size += sizeof(struct slob_rcu);
 	}
 	c->flags = flags;
-	c->ctor = ctor;
 	/* ignore alignment unless it's forced */
 	c->align = (flags & SLAB_HWCACHE_ALIGN) ? SLOB_ALIGN : 0;
 	if (c->align < ARCH_SLAB_MINALIGN)
@@ -526,7 +525,6 @@ int __kmem_cache_create(struct kmem_cach
 		c->align = align;
 
 	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
-	c->refcount = 1;
 	return 0;
 }
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-05-23 08:54:34.206687757 -0500
+++ linux-2.6/mm/slub.c	2012-05-23 08:54:35.238687733 -0500
@@ -3000,13 +3000,11 @@ static int calculate_sizes(struct kmem_c
 }
 
 static int kmem_cache_open(struct kmem_cache *s, size_t size,
-		size_t align, unsigned long flags,
-		void (*ctor)(void *))
+		size_t align, unsigned long flags)
 {
-	s->ctor = ctor;
 	s->objsize = size;
 	s->align = align;
-	s->flags = kmem_cache_flags(size, flags, s->name, ctor);
+	s->flags = kmem_cache_flags(size, flags, s->name, s->ctor);
 	s->reserved = 0;
 
 	if (need_reserve_slab_rcu && (s->flags & SLAB_DESTROY_BY_RCU))
@@ -3069,7 +3067,6 @@ static int kmem_cache_open(struct kmem_c
 	else
 		s->cpu_partial = 30;
 
-	s->refcount = 1;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
@@ -3230,7 +3227,7 @@ static struct kmem_cache *__init create_
 	 * This function is called with IRQs disabled during early-boot on
 	 * single CPU so there's no need to take slab_mutex here.
 	 */
-	r = kmem_cache_open(s, size, ARCH_KMALLOC_MINALIGN, flags, NULL);
+	r = kmem_cache_open(s, size, ARCH_KMALLOC_MINALIGN, flags);
 	if (r)
 		panic("Creation of kmalloc slab %s size=%d failed. Code %d\n",
 				name, size, r);
@@ -3684,7 +3681,7 @@ void __init kmem_cache_init(void)
 	kmem_cache_node->name = "kmem_cache_node";
 
 	r = kmem_cache_open(kmem_cache_node, sizeof(struct kmem_cache_node),
-		0, SLAB_HWCACHE_ALIGN, NULL);
+		0, SLAB_HWCACHE_ALIGN);
 	if (r)
 		goto panic;
 
@@ -3697,7 +3694,7 @@ void __init kmem_cache_init(void)
 	kmem_cache->name = "kmem_cache";
 
 	r = kmem_cache_open(kmem_cache, kmem_size, 0,
-			SLAB_HWCACHE_ALIGN, NULL);
+			SLAB_HWCACHE_ALIGN);
 	if (r)
 		goto panic;
 
@@ -3918,9 +3915,9 @@ struct kmem_cache *__kmem_cache_alias(co
 }
 
 int __kmem_cache_create(struct kmem_cache *s, size_t size,
-		size_t align, unsigned long flags, void (*ctor)(void *))
+		size_t align, unsigned long flags)
 {
-	int r = kmem_cache_open(s, size, align, flags, ctor);
+	int r = kmem_cache_open(s, size, align, flags);
 
 	if (r)
 		return r;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
