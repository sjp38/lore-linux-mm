Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 80B336B0080
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 16:25:25 -0400 (EDT)
Message-Id: <20120706202523.606441932@linux.com>
Date: Fri, 06 Jul 2012 15:25:10 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [1/4] Extract common code for kmem_cache_create()
References: <20120706202509.294809131@linux.com>
Content-Disposition: inline; filename=common_kmem_cache_checks
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Kmem_cache_create() does a variety of sanity checks but those
vary depending on the allocator. Use the strictest tests and put them into
a slab_common file. Make the tests conditional on CONFIG_DEBUG_VM.

This patch has the effect of adding sanity checks for SLUB and SLOB
under CONFIG_DEBUG_VM and removes the checks in SLAB for !CONFIG_DEBUG_VM.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slab.h |    4 ++
 mm/Makefile          |    3 +-
 mm/slab.c            |   24 ++++++-----------
 mm/slab_common.c     |   69 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/slob.c            |    8 ++---
 mm/slub.c            |   11 --------
 6 files changed, 88 insertions(+), 31 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-07-06 07:29:01.643292029 -0500
+++ linux-2.6/mm/slab.c	2012-07-06 07:30:09.119290631 -0500
@@ -1558,7 +1558,7 @@ void __init kmem_cache_init(void)
 	 * bug.
 	 */
 
-	sizes[INDEX_AC].cs_cachep = kmem_cache_create(names[INDEX_AC].name,
+	sizes[INDEX_AC].cs_cachep = __kmem_cache_create(names[INDEX_AC].name,
 					sizes[INDEX_AC].cs_size,
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
@@ -1566,7 +1566,7 @@ void __init kmem_cache_init(void)
 
 	if (INDEX_AC != INDEX_L3) {
 		sizes[INDEX_L3].cs_cachep =
-			kmem_cache_create(names[INDEX_L3].name,
+			__kmem_cache_create(names[INDEX_L3].name,
 				sizes[INDEX_L3].cs_size,
 				ARCH_KMALLOC_MINALIGN,
 				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
@@ -1584,14 +1584,14 @@ void __init kmem_cache_init(void)
 		 * allow tighter packing of the smaller caches.
 		 */
 		if (!sizes->cs_cachep) {
-			sizes->cs_cachep = kmem_cache_create(names->name,
+			sizes->cs_cachep = __kmem_cache_create(names->name,
 					sizes->cs_size,
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
 		}
 #ifdef CONFIG_ZONE_DMA
-		sizes->cs_dmacachep = kmem_cache_create(
+		sizes->cs_dmacachep = __kmem_cache_create(
 					names->name_dma,
 					sizes->cs_size,
 					ARCH_KMALLOC_MINALIGN,
@@ -2220,7 +2220,7 @@ static int __init_refok setup_cpu_cache(
 }
 
 /**
- * kmem_cache_create - Create a cache.
+ * __kmem_cache_create - Create a cache.
  * @name: A string which is used in /proc/slabinfo to identify this cache.
  * @size: The size of objects to be created in this cache.
  * @align: The required alignment for the objects.
@@ -2247,7 +2247,7 @@ static int __init_refok setup_cpu_cache(
  * as davem.
  */
 struct kmem_cache *
-kmem_cache_create (const char *name, size_t size, size_t align,
+__kmem_cache_create (const char *name, size_t size, size_t align,
 	unsigned long flags, void (*ctor)(void *))
 {
 	size_t left_over, slab_size, ralign;
@@ -2388,7 +2388,7 @@ kmem_cache_create (const char *name, siz
 	/* Get cache's description obj. */
 	cachep = kmem_cache_zalloc(&cache_cache, gfp);
 	if (!cachep)
-		goto oops;
+		return NULL;
 
 	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
 	cachep->object_size = size;
@@ -2445,8 +2445,7 @@ kmem_cache_create (const char *name, siz
 		printk(KERN_ERR
 		       "kmem_cache_create: couldn't create cache %s.\n", name);
 		kmem_cache_free(&cache_cache, cachep);
-		cachep = NULL;
-		goto oops;
+		return NULL;
 	}
 	slab_size = ALIGN(cachep->num * sizeof(kmem_bufctl_t)
 			  + sizeof(struct slab), align);
@@ -2504,8 +2503,7 @@ kmem_cache_create (const char *name, siz
 
 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
-		cachep = NULL;
-		goto oops;
+		return NULL;
 	}
 
 	if (flags & SLAB_DEBUG_OBJECTS) {
@@ -2521,16 +2519,12 @@ kmem_cache_create (const char *name, siz
 	/* cache setup completed, link it into the list */
 	list_add(&cachep->list, &cache_chain);
 oops:
-	if (!cachep && (flags & SLAB_PANIC))
-		panic("kmem_cache_create(): failed to create slab `%s'\n",
-		      name);
 	if (slab_is_available()) {
 		mutex_unlock(&cache_chain_mutex);
 		put_online_cpus();
 	}
 	return cachep;
 }
-EXPORT_SYMBOL(kmem_cache_create);
 
 #if DEBUG
 static void check_irq_off(void)
Index: linux-2.6/mm/slab_common.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/mm/slab_common.c	2012-07-06 07:30:09.119290631 -0500
@@ -0,0 +1,69 @@
+/*
+ * Slab allocator functions that are independent of the allocator strategy
+ *
+ * (C) 2012 Christoph Lameter <cl@linux.com>
+ */
+#include <linux/slab.h>
+
+#include <linux/mm.h>
+#include <linux/poison.h>
+#include <linux/interrupt.h>
+#include <linux/memory.h>
+#include <linux/compiler.h>
+#include <linux/module.h>
+
+#include <asm/cacheflush.h>
+#include <asm/tlbflush.h>
+#include <asm/page.h>
+
+/*
+ * kmem_cache_create - Create a cache.
+ * @name: A string which is used in /proc/slabinfo to identify this cache.
+ * @size: The size of objects to be created in this cache.
+ * @align: The required alignment for the objects.
+ * @flags: SLAB flags
+ * @ctor: A constructor for the objects.
+ *
+ * Returns a ptr to the cache on success, NULL on failure.
+ * Cannot be called within a interrupt, but can be interrupted.
+ * The @ctor is run when new pages are allocated by the cache.
+ *
+ * The flags are
+ *
+ * %SLAB_POISON - Poison the slab with a known test pattern (a5a5a5a5)
+ * to catch references to uninitialised memory.
+ *
+ * %SLAB_RED_ZONE - Insert `Red' zones around the allocated memory to check
+ * for buffer overruns.
+ *
+ * %SLAB_HWCACHE_ALIGN - Align the objects in this cache to a hardware
+ * cacheline.  This can be beneficial if you're counting cycles as closely
+ * as davem.
+ */
+
+struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align,
+		unsigned long flags, void (*ctor)(void *))
+{
+	struct kmem_cache *s = NULL;
+
+#ifdef CONFIG_DEBUG_VM
+	if (!name || in_interrupt() || size < sizeof(void *) ||
+		size > KMALLOC_MAX_SIZE) {
+		printk(KERN_ERR "kmem_cache_create(%s) integrity check"
+			" failed\n", name);
+		goto out;
+	}
+#endif
+
+	s = __kmem_cache_create(name, size, align, flags, ctor);
+
+#ifdef CONFIG_DEBUG_VM
+out:
+#endif
+	if (!s && (flags & SLAB_PANIC))
+		panic("kmem_cache_create: Failed to create slab '%s'\n", name);
+
+	return s;
+}
+EXPORT_SYMBOL(kmem_cache_create);
+
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-07-06 07:30:05.939290696 -0500
+++ linux-2.6/mm/slub.c	2012-07-06 07:30:09.119290631 -0500
@@ -3919,15 +3919,12 @@ static struct kmem_cache *find_mergeable
 	return NULL;
 }
 
-struct kmem_cache *kmem_cache_create(const char *name, size_t size,
+struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
 	char *n;
 
-	if (WARN_ON(!name))
-		return NULL;
-
 	down_write(&slub_lock);
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
@@ -3971,14 +3968,8 @@ struct kmem_cache *kmem_cache_create(con
 	kfree(n);
 err:
 	up_write(&slub_lock);
-
-	if (flags & SLAB_PANIC)
-		panic("Cannot create slabcache %s\n", name);
-	else
-		s = NULL;
 	return s;
 }
-EXPORT_SYMBOL(kmem_cache_create);
 
 #ifdef CONFIG_SMP
 /*
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-07-06 07:29:01.635292029 -0500
+++ linux-2.6/mm/slob.c	2012-07-06 07:30:09.119290631 -0500
@@ -506,7 +506,7 @@ size_t ksize(const void *block)
 }
 EXPORT_SYMBOL(ksize);
 
-struct kmem_cache *kmem_cache_create(const char *name, size_t size,
+struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *c;
@@ -529,13 +529,11 @@ struct kmem_cache *kmem_cache_create(con
 			c->align = ARCH_SLAB_MINALIGN;
 		if (c->align < align)
 			c->align = align;
-	} else if (flags & SLAB_PANIC)
-		panic("Cannot create slab cache %s\n", name);
 
-	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
+		kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
+	}
 	return c;
 }
-EXPORT_SYMBOL(kmem_cache_create);
 
 void kmem_cache_destroy(struct kmem_cache *c)
 {
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile	2012-07-06 07:29:01.663292030 -0500
+++ linux-2.6/mm/Makefile	2012-07-06 07:30:09.119290631 -0500
@@ -16,7 +16,8 @@ obj-y			:= filemap.o mempool.o oom_kill.
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
 			   page_isolation.o mm_init.o mmu_context.o percpu.o \
-			   compaction.o $(mmu-y)
+			   compaction.o slab_common.o $(mmu-y)
+
 obj-y += init-mm.o
 
 ifdef CONFIG_NO_BOOTMEM
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2012-07-06 07:29:01.627292029 -0500
+++ linux-2.6/include/linux/slab.h	2012-07-06 07:30:09.119290631 -0500
@@ -130,6 +130,10 @@ int kmem_cache_shrink(struct kmem_cache
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
 
+/* Slab internal function */
+struct kmem_cache *__kmem_cache_create(const char *, size_t, size_t,
+			unsigned long,
+			void (*)(void *));
 /*
  * Please use this macro to create slab caches. Simply specify the
  * name of the structure and maybe some flags that are listed above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
