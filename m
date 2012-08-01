Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id DB7F96B0075
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 17:12:04 -0400 (EDT)
Message-Id: <20120801211202.431857668@linux.com>
Date: Wed, 01 Aug 2012 16:11:42 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [12/16] create common create_kmalloc_cache()
References: <20120801211130.025389154@linux.com>
Content-Disposition: inline; filename=extract_create_kmalloc_cache
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Use a special function to create kmalloc caches and use that function in
SLAB and SLUB.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c |   53 +++++++++++++++++++++++------------------------------
 1 file changed, 23 insertions(+), 30 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-01 15:50:48.659751183 -0500
+++ linux-2.6/mm/slab.c	2012-08-01 15:51:07.812099028 -0500
@@ -1673,22 +1673,13 @@
 	 * bug.
 	 */
 
-	sizes[INDEX_AC].cs_cachep = __kmem_cache_create(names[INDEX_AC].name,
-					sizes[INDEX_AC].cs_size,
-					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
-					NULL);
+	sizes[INDEX_AC].cs_cachep = create_kmalloc_cache(names[INDEX_AC].name,
+					sizes[INDEX_AC].cs_size, ARCH_KMALLOC_FLAGS);
 
-	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
-	if (INDEX_AC != INDEX_L3) {
+	if (INDEX_AC != INDEX_L3)
 		sizes[INDEX_L3].cs_cachep =
-			__kmem_cache_create(names[INDEX_L3].name,
-				sizes[INDEX_L3].cs_size,
-				ARCH_KMALLOC_MINALIGN,
-				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
-				NULL);
-		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
-	}
+			create_kmalloc_cache(names[INDEX_L3].name,
+				sizes[INDEX_L3].cs_size, ARCH_KMALLOC_FLAGS);
 
 	slab_early_init = 0;
 
@@ -1700,23 +1691,14 @@
 		 * Note for systems short on memory removing the alignment will
 		 * allow tighter packing of the smaller caches.
 		 */
-		if (!sizes->cs_cachep) {
-			sizes->cs_cachep = __kmem_cache_create(names->name,
-					sizes->cs_size,
-					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
-					NULL);
-			list_add(&sizes->cs_cachep->list, &slab_caches);
-		}
+		if (!sizes->cs_cachep)
+			sizes->cs_cachep = create_kmalloc_cache(names->name,
+					sizes->cs_size, ARCH_KMALLOC_FLAGS);
+
 #ifdef CONFIG_ZONE_DMA
-		sizes->cs_dmacachep = __kmem_cache_create(
-					names->name_dma,
-					sizes->cs_size,
-					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
-						SLAB_PANIC,
-					NULL);
-		list_add(&sizes->cs_dmacachep->list, &slab_caches);
+		sizes->cs_dmacachep = create_kmalloc_cache(
+			names->name_dma, sizes->cs_size,
+			SLAB_CACHE_DMA|ARCH_KMALLOC_FLAGS);
 #endif
 		sizes++;
 		names++;
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-01 15:51:03.032012215 -0500
+++ linux-2.6/mm/slab.h	2012-08-01 15:51:07.812099028 -0500
@@ -33,9 +33,12 @@
 extern struct kmem_cache *kmem_cache;
 
 /* Functions provided by the slab allocators */
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+extern struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
+extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
+			unsigned long flags);
+
 #ifdef CONFIG_SLUB
 struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-01 15:51:03.032012215 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-01 15:51:07.812099028 -0500
@@ -165,3 +165,21 @@
 {
 	return slab_state >= UP;
 }
+
+struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
+				unsigned long flags)
+{
+	struct kmem_cache *s;
+
+	s = __kmem_cache_create(name, size, ARCH_KMALLOC_MINALIGN,
+		       	flags, NULL);
+
+	if (s) {
+		list_add(&s->list, &slab_caches);
+		return s;
+	}
+
+	panic("Creation of kmalloc slab %s size=%ld failed.\n", name, size);
+	return NULL;
+}
+
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-01 15:51:04.532039458 -0500
+++ linux-2.6/mm/slub.c	2012-08-01 15:51:19.300307609 -0500
@@ -3248,29 +3248,6 @@
 
 __setup("slub_nomerge", setup_slub_nomerge);
 
-static struct kmem_cache *__init create_kmalloc_cache(const char *name,
-						int size, unsigned int flags)
-{
-	struct kmem_cache *s;
-
-	s = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
-
-	/*
-	 * This function is called with IRQs disabled during early-boot on
-	 * single CPU so there's no need to take slab_mutex here.
-	 */
-	if (!kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
-								flags, NULL))
-		goto panic;
-
-	list_add(&s->list, &slab_caches);
-	return s;
-
-panic:
-	panic("Creation of kmalloc slab %s size=%d failed.\n", name, size);
-	return NULL;
-}
-
 /*
  * Conversion table for small slabs sizes / 8 to the index in the
  * kmalloc array. This is necessary for slabs < 192 since we have non power

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
