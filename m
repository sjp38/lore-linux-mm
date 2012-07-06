Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 318346B0082
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 16:25:26 -0400 (EDT)
Message-Id: <20120706202524.172033286@linux.com>
Date: Fri, 06 Jul 2012 15:25:11 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [2/4] Common definition for boot state of the slab allocators
References: <20120706202509.294809131@linux.com>
Content-Disposition: inline; filename=slab_internal
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

All allocators have some sort of support for the bootstrap status.

Setup a common definition for the boot states and make all slab
allocators use that definition.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slab.h |    4 ----
 mm/slab.c            |   45 ++++++++++++++-------------------------------
 mm/slab.h            |   30 ++++++++++++++++++++++++++++++
 mm/slab_common.c     |    9 +++++++++
 mm/slob.c            |   14 +++++---------
 mm/slub.c            |   21 +++++----------------
 6 files changed, 63 insertions(+), 60 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-07-06 08:43:04.495199970 -0500
+++ linux-2.6/mm/slab.c	2012-07-06 08:43:58.847198851 -0500
@@ -87,6 +87,7 @@
  */
 
 #include	<linux/slab.h>
+#include	"slab.h"
 #include	<linux/mm.h>
 #include	<linux/poison.h>
 #include	<linux/swap.h>
@@ -565,27 +566,6 @@ static struct kmem_cache cache_cache = {
 
 #define BAD_ALIEN_MAGIC 0x01020304ul
 
-/*
- * chicken and egg problem: delay the per-cpu array allocation
- * until the general caches are up.
- */
-static enum {
-	NONE,
-	PARTIAL_AC,
-	PARTIAL_L3,
-	EARLY,
-	LATE,
-	FULL
-} g_cpucache_up;
-
-/*
- * used by boot code to determine if it can use slab based allocator
- */
-int slab_is_available(void)
-{
-	return g_cpucache_up >= EARLY;
-}
-
 #ifdef CONFIG_LOCKDEP
 
 /*
@@ -651,7 +631,7 @@ static void init_node_lock_keys(int q)
 {
 	struct cache_sizes *s = malloc_sizes;
 
-	if (g_cpucache_up < LATE)
+	if (slab_state < UP)
 		return;
 
 	for (s = malloc_sizes; s->cs_size != ULONG_MAX; s++) {
@@ -1649,14 +1629,14 @@ void __init kmem_cache_init(void)
 		}
 	}
 
-	g_cpucache_up = EARLY;
+	slab_state = UP;
 }
 
 void __init kmem_cache_init_late(void)
 {
 	struct kmem_cache *cachep;
 
-	g_cpucache_up = LATE;
+	slab_state = UP;
 
 	/* Annotate slab for lockdep -- annotate the malloc caches */
 	init_lock_keys();
@@ -1668,6 +1648,9 @@ void __init kmem_cache_init_late(void)
 			BUG();
 	mutex_unlock(&cache_chain_mutex);
 
+	/* Done! */
+	slab_state = FULL;
+
 	/*
 	 * Register a cpu startup notifier callback that initializes
 	 * cpu_cache_get for all new cpus
@@ -1699,7 +1682,7 @@ static int __init cpucache_init(void)
 		start_cpu_timer(cpu);
 
 	/* Done! */
-	g_cpucache_up = FULL;
+	slab_state = FULL;
 	return 0;
 }
 __initcall(cpucache_init);
@@ -2167,10 +2150,10 @@ static size_t calculate_slab_order(struc
 
 static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
-	if (g_cpucache_up >= LATE)
+	if (slab_state >= FULL)
 		return enable_cpucache(cachep, gfp);
 
-	if (g_cpucache_up == NONE) {
+	if (slab_state == DOWN) {
 		/*
 		 * Note: the first kmem_cache_create must create the cache
 		 * that's used by kmalloc(24), otherwise the creation of
@@ -2185,16 +2168,16 @@ static int __init_refok setup_cpu_cache(
 		 */
 		set_up_list3s(cachep, SIZE_AC);
 		if (INDEX_AC == INDEX_L3)
-			g_cpucache_up = PARTIAL_L3;
+			slab_state = PARTIAL_L3;
 		else
-			g_cpucache_up = PARTIAL_AC;
+			slab_state = PARTIAL_ARRAYCACHE;
 	} else {
 		cachep->array[smp_processor_id()] =
 			kmalloc(sizeof(struct arraycache_init), gfp);
 
-		if (g_cpucache_up == PARTIAL_AC) {
+		if (slab_state == PARTIAL_ARRAYCACHE) {
 			set_up_list3s(cachep, SIZE_L3);
-			g_cpucache_up = PARTIAL_L3;
+			slab_state = PARTIAL_L3;
 		} else {
 			int node;
 			for_each_online_node(node) {
Index: linux-2.6/mm/slab.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/mm/slab.h	2012-07-06 08:43:20.759199635 -0500
@@ -0,0 +1,30 @@
+#ifndef MM_SLAB_H
+#define MM_SLAB_H
+/*
+ * Internal slab definitions
+ */
+
+/*
+ * State of the slab allocator.
+ *
+ * This is used to describe the states of the allocator during bootup.
+ * Allocators use this to gradually bootstrap themselves. Most allocators
+ * have the problem that the structures used for managing slab caches are
+ * allocated from slab caches themselves.
+ */
+enum slab_state {
+	DOWN,			/* No slab functionality yet */
+	PARTIAL,		/* SLUB: kmem_cache_node available */
+	PARTIAL_ARRAYCACHE,	/* SLAB: kmalloc size for arraycache available */
+	PARTIAL_L3,		/* SLAB: kmalloc size for l3 struct available */
+	UP,			/* Slab caches usable but not all extras yet */
+	FULL			/* Everything is working */
+};
+
+extern enum slab_state slab_state;
+
+struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+	size_t align, unsigned long flags, void (*ctor)(void *));
+
+#endif
+
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-07-06 08:43:04.499199970 -0500
+++ linux-2.6/mm/slob.c	2012-07-06 08:43:20.759199635 -0500
@@ -59,6 +59,8 @@
 
 #include <linux/kernel.h>
 #include <linux/slab.h>
+#include "slab.h"
+
 #include <linux/mm.h>
 #include <linux/swap.h> /* struct reclaim_state */
 #include <linux/cache.h>
@@ -531,6 +533,7 @@ struct kmem_cache *__kmem_cache_create(c
 			c->align = align;
 
 		kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
+		c->refcount = 1;
 	}
 	return c;
 }
@@ -616,19 +619,12 @@ int kmem_cache_shrink(struct kmem_cache
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
-static unsigned int slob_ready __read_mostly;
-
-int slab_is_available(void)
-{
-	return slob_ready;
-}
-
 void __init kmem_cache_init(void)
 {
-	slob_ready = 1;
+	slab_state = UP;
 }
 
 void __init kmem_cache_init_late(void)
 {
-	/* Nothing to do */
+	slab_state = FULL;
 }
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-07-06 08:43:04.495199970 -0500
+++ linux-2.6/mm/slub.c	2012-07-06 08:43:20.759199635 -0500
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/bitops.h>
 #include <linux/slab.h>
+#include "slab.h"
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/kmemcheck.h>
@@ -182,13 +183,6 @@ static int kmem_size = sizeof(struct kme
 static struct notifier_block slab_notifier;
 #endif
 
-static enum {
-	DOWN,		/* No slab functionality available */
-	PARTIAL,	/* Kmem_cache_node works */
-	UP,		/* Everything works but does not show up in sysfs */
-	SYSFS		/* Sysfs up */
-} slab_state = DOWN;
-
 /* A list of all slab caches on the system */
 static DECLARE_RWSEM(slub_lock);
 static LIST_HEAD(slab_caches);
@@ -237,11 +231,6 @@ static inline void stat(const struct kme
  * 			Core slab cache functions
  *******************************************************************/
 
-int slab_is_available(void)
-{
-	return slab_state >= UP;
-}
-
 static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 {
 	return s->node[node];
@@ -5273,7 +5262,7 @@ static int sysfs_slab_add(struct kmem_ca
 	const char *name;
 	int unmergeable;
 
-	if (slab_state < SYSFS)
+	if (slab_state < FULL)
 		/* Defer until later */
 		return 0;
 
@@ -5318,7 +5307,7 @@ static int sysfs_slab_add(struct kmem_ca
 
 static void sysfs_slab_remove(struct kmem_cache *s)
 {
-	if (slab_state < SYSFS)
+	if (slab_state < FULL)
 		/*
 		 * Sysfs has not been setup yet so no need to remove the
 		 * cache from sysfs.
@@ -5346,7 +5335,7 @@ static int sysfs_slab_alias(struct kmem_
 {
 	struct saved_alias *al;
 
-	if (slab_state == SYSFS) {
+	if (slab_state == FULL) {
 		/*
 		 * If we have a leftover link then remove it.
 		 */
@@ -5379,7 +5368,7 @@ static int __init slab_sysfs_init(void)
 		return -ENOSYS;
 	}
 
-	slab_state = SYSFS;
+	slab_state = FULL;
 
 	list_for_each_entry(s, &slab_caches, list) {
 		err = sysfs_slab_add(s);
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-07-06 08:43:04.495199970 -0500
+++ linux-2.6/mm/slab_common.c	2012-07-06 08:43:20.759199635 -0500
@@ -16,6 +16,10 @@
 #include <asm/tlbflush.h>
 #include <asm/page.h>
 
+#include "slab.h"
+
+enum slab_state slab_state;
+
 /*
  * kmem_cache_create - Create a cache.
  * @name: A string which is used in /proc/slabinfo to identify this cache.
@@ -67,3 +71,8 @@ out:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
+int slab_is_available(void)
+{
+	return slab_state >= UP;
+}
+
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2012-07-06 08:43:04.499199970 -0500
+++ linux-2.6/include/linux/slab.h	2012-07-06 08:43:20.759199635 -0500
@@ -130,10 +130,6 @@ int kmem_cache_shrink(struct kmem_cache
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
 
-/* Slab internal function */
-struct kmem_cache *__kmem_cache_create(const char *, size_t, size_t,
-			unsigned long,
-			void (*)(void *));
 /*
  * Please use this macro to create slab caches. Simply specify the
  * name of the structure and maybe some flags that are listed above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
