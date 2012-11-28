Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id C07126B007D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:23:10 -0500 (EST)
Message-Id: <0000013b47d43458-badf31fd-b4f3-492a-a054-d6f0727ca69c-000000@email.amazonses.com>
Date: Wed, 28 Nov 2012 16:23:07 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK5 [3/6] create common functions for boot slab creation
References: <20121128162238.111670741@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, elezegarcia@gmail.com

Use a special function to create kmalloc caches and use that function in
SLAB and SLUB.

V1->V2:
	Do check for slasb state in slub's __kmem_cache_create to avoid
	unlocking a lock that was not taken
V2->V3:
	Remove slab_state check from sysfs_slab_add(). [Joonsoo]

V3->V4:
	- Use %zd instead of %td for size info.
	- Do not add slab caches to the list of slab caches during early
	  boot.

Acked-by: Joonsoo Kim <js1304@gmail.com>
Reviewed-by: Glauber Costa <glommer@parallels.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |   48 ++++++++++++++----------------------------------
 mm/slab.h        |    5 +++++
 mm/slab_common.c |   32 ++++++++++++++++++++++++++++++++
 mm/slub.c        |   36 +++---------------------------------
 4 files changed, 54 insertions(+), 67 deletions(-)

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-11-05 09:08:34.692753484 -0600
+++ linux/mm/slab.c	2012-11-05 09:11:52.020821613 -0600
@@ -1659,23 +1659,13 @@ void __init kmem_cache_init(void)
 	 * bug.
 	 */
 
-	sizes[INDEX_AC].cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-	sizes[INDEX_AC].cs_cachep->name = names[INDEX_AC].name;
-	sizes[INDEX_AC].cs_cachep->size = sizes[INDEX_AC].cs_size;
-	sizes[INDEX_AC].cs_cachep->object_size = sizes[INDEX_AC].cs_size;
-	sizes[INDEX_AC].cs_cachep->align = ARCH_KMALLOC_MINALIGN;
-	__kmem_cache_create(sizes[INDEX_AC].cs_cachep, ARCH_KMALLOC_FLAGS|SLAB_PANIC);
-	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
+	sizes[INDEX_AC].cs_cachep = create_kmalloc_cache(names[INDEX_AC].name,
+					sizes[INDEX_AC].cs_size, ARCH_KMALLOC_FLAGS);
 
-	if (INDEX_AC != INDEX_L3) {
-		sizes[INDEX_L3].cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-		sizes[INDEX_L3].cs_cachep->name = names[INDEX_L3].name;
-		sizes[INDEX_L3].cs_cachep->size = sizes[INDEX_L3].cs_size;
-		sizes[INDEX_L3].cs_cachep->object_size = sizes[INDEX_L3].cs_size;
-		sizes[INDEX_L3].cs_cachep->align = ARCH_KMALLOC_MINALIGN;
-		__kmem_cache_create(sizes[INDEX_L3].cs_cachep, ARCH_KMALLOC_FLAGS|SLAB_PANIC);
-		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
-	}
+	if (INDEX_AC != INDEX_L3)
+		sizes[INDEX_L3].cs_cachep =
+			create_kmalloc_cache(names[INDEX_L3].name,
+				sizes[INDEX_L3].cs_size, ARCH_KMALLOC_FLAGS);
 
 	slab_early_init = 0;
 
@@ -1687,24 +1677,14 @@ void __init kmem_cache_init(void)
 		 * Note for systems short on memory removing the alignment will
 		 * allow tighter packing of the smaller caches.
 		 */
-		if (!sizes->cs_cachep) {
-			sizes->cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-			sizes->cs_cachep->name = names->name;
-			sizes->cs_cachep->size = sizes->cs_size;
-			sizes->cs_cachep->object_size = sizes->cs_size;
-			sizes->cs_cachep->align = ARCH_KMALLOC_MINALIGN;
-			__kmem_cache_create(sizes->cs_cachep, ARCH_KMALLOC_FLAGS|SLAB_PANIC);
-			list_add(&sizes->cs_cachep->list, &slab_caches);
-		}
+		if (!sizes->cs_cachep)
+			sizes->cs_cachep = create_kmalloc_cache(names->name,
+					sizes->cs_size, ARCH_KMALLOC_FLAGS);
+
 #ifdef CONFIG_ZONE_DMA
-		sizes->cs_dmacachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-		sizes->cs_dmacachep->name = names->name_dma;
-		sizes->cs_dmacachep->size = sizes->cs_size;
-		sizes->cs_dmacachep->object_size = sizes->cs_size;
-		sizes->cs_dmacachep->align = ARCH_KMALLOC_MINALIGN;
-		__kmem_cache_create(sizes->cs_dmacachep,
-			       ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA| SLAB_PANIC);
-		list_add(&sizes->cs_dmacachep->list, &slab_caches);
+		sizes->cs_dmacachep = create_kmalloc_cache(
+			names->name_dma, sizes->cs_size,
+			SLAB_CACHE_DMA|ARCH_KMALLOC_FLAGS);
 #endif
 		sizes++;
 		names++;
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2012-11-05 09:05:23.568665085 -0600
+++ linux/mm/slab.h	2012-11-05 09:11:52.020821613 -0600
@@ -35,6 +35,11 @@ extern struct kmem_cache *kmem_cache;
 /* Functions provided by the slab allocators */
 extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 
+extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
+			unsigned long flags);
+extern void create_boot_cache(struct kmem_cache *, const char *name,
+			size_t size, unsigned long flags);
+
 #ifdef CONFIG_SLUB
 struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-11-05 09:05:23.568665085 -0600
+++ linux/mm/slab_common.c	2012-11-05 09:11:52.020821613 -0600
@@ -202,6 +202,42 @@ int slab_is_available(void)
 	return slab_state >= UP;
 }
 
+#ifndef CONFIG_SLOB
+/* Create a cache during boot when no slab services are available yet */
+void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
+		unsigned long flags)
+{
+	int err;
+
+	s->name = name;
+	s->size = s->object_size = size;
+	s->align = ARCH_KMALLOC_MINALIGN;
+	err = __kmem_cache_create(s, flags);
+
+	if (err)
+		panic("Creation of kmalloc slab %s size=%zd failed. Reason %d\n",
+					name, size, err);
+
+	s->refcount = -1;	/* Exempt from merging for now */
+}
+
+struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
+				unsigned long flags)
+{
+	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
+
+	if (!s)
+		panic("Out of memory when creating slab %s\n", name);
+
+	create_boot_cache(s, name, size, flags);
+	list_add(&s->list, &slab_caches);
+	s->refcount = 1;
+	return s;
+}
+
+#endif /* !CONFIG_SLOB */
+
+
 #ifdef CONFIG_SLABINFO
 static void print_slabinfo_header(struct seq_file *m)
 {
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-11-05 09:08:04.208740893 -0600
+++ linux/mm/slub.c	2012-11-05 09:11:52.020821613 -0600
@@ -3245,32 +3245,6 @@ static int __init setup_slub_nomerge(cha
 
 __setup("slub_nomerge", setup_slub_nomerge);
 
-static struct kmem_cache *__init create_kmalloc_cache(const char *name,
-						int size, unsigned int flags)
-{
-	struct kmem_cache *s;
-
-	s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-
-	s->name = name;
-	s->size = s->object_size = size;
-	s->align = ARCH_KMALLOC_MINALIGN;
-
-	/*
-	 * This function is called with IRQs disabled during early-boot on
-	 * single CPU so there's no need to take slab_mutex here.
-	 */
-	if (kmem_cache_open(s, flags))
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
@@ -3948,6 +3922,10 @@ int __kmem_cache_create(struct kmem_cach
 	if (err)
 		return err;
 
+	/* Mutex is not taken during early boot */
+	if (slab_state <= UP)
+		return 0;
+
 	mutex_unlock(&slab_mutex);
 	err = sysfs_slab_add(s);
 	mutex_lock(&slab_mutex);
@@ -5249,13 +5227,8 @@ static int sysfs_slab_add(struct kmem_ca
 {
 	int err;
 	const char *name;
-	int unmergeable;
-
-	if (slab_state < FULL)
-		/* Defer until later */
-		return 0;
+	int unmergeable = slab_unmergeable(s);
 
-	unmergeable = slab_unmergeable(s);
 	if (unmergeable) {
 		/*
 		 * Slabcache can never be merged so we can use the name proper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
