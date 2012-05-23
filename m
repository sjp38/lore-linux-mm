Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id AC6076B00EC
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:35:11 -0400 (EDT)
Message-Id: <20120523203509.571095241@linux.com>
Date: Wed, 23 May 2012 15:34:41 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common 08/22] Common definition for boot state of the slab allocators
References: <20120523203433.340661918@linux.com>
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
 mm/slab.c            |   42 +++++++++++-------------------------------
 mm/slab.h            |   30 ++++++++++++++++++++++++++++++
 mm/slab_common.c     |    9 +++++++++
 mm/slob.c            |   14 +++++---------
 mm/slub.c            |   21 +++++----------------
 6 files changed, 60 insertions(+), 60 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-05-23 04:23:27.567024810 -0500
+++ linux-2.6/mm/slab.c	2012-05-23 04:23:44.379024464 -0500
@@ -87,6 +87,7 @@
  */
 
 #include	<linux/slab.h>
+#include	"slab.h"
 #include	<linux/mm.h>
 #include	<linux/poison.h>
 #include	<linux/swap.h>
@@ -571,27 +572,6 @@ static struct kmem_cache cache_cache = {
 
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
@@ -657,7 +637,7 @@ static void init_node_lock_keys(int q)
 {
 	struct cache_sizes *s = malloc_sizes;
 
-	if (g_cpucache_up < LATE)
+	if (slab_state < UP)
 		return;
 
 	for (s = malloc_sizes; s->cs_size != ULONG_MAX; s++) {
@@ -1657,14 +1637,14 @@ void __init kmem_cache_init(void)
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
@@ -1677,7 +1657,7 @@ void __init kmem_cache_init_late(void)
 	mutex_unlock(&cache_chain_mutex);
 
 	/* Done! */
-	g_cpucache_up = FULL;
+	slab_state = FULL;
 
 	/*
 	 * Register a cpu startup notifier callback that initializes
@@ -2175,10 +2155,10 @@ static size_t calculate_slab_order(struc
 
 static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
-	if (g_cpucache_up == FULL)
+	if (slab_state == FULL)
 		return enable_cpucache(cachep, gfp);
 
-	if (g_cpucache_up == NONE) {
+	if (slab_state == DOWN) {
 		/*
 		 * Note: the first kmem_cache_create must create the cache
 		 * that's used by kmalloc(24), otherwise the creation of
@@ -2193,16 +2173,16 @@ static int __init_refok setup_cpu_cache(
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
+++ linux-2.6/mm/slab.h	2012-05-23 04:23:44.379024464 -0500
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
--- linux-2.6.orig/mm/slob.c	2012-05-23 04:23:27.571024809 -0500
+++ linux-2.6/mm/slob.c	2012-05-23 04:23:44.379024464 -0500
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
--- linux-2.6.orig/mm/slub.c	2012-05-23 04:23:27.571024809 -0500
+++ linux-2.6/mm/slub.c	2012-05-23 04:23:44.383024464 -0500
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
@@ -5274,7 +5263,7 @@ static int sysfs_slab_add(struct kmem_ca
 	const char *name;
 	int unmergeable;
 
-	if (slab_state < SYSFS)
+	if (slab_state < FULL)
 		/* Defer until later */
 		return 0;
 
@@ -5319,7 +5308,7 @@ static int sysfs_slab_add(struct kmem_ca
 
 static void sysfs_slab_remove(struct kmem_cache *s)
 {
-	if (slab_state < SYSFS)
+	if (slab_state < FULL)
 		/*
 		 * Sysfs has not been setup yet so no need to remove the
 		 * cache from sysfs.
@@ -5347,7 +5336,7 @@ static int sysfs_slab_alias(struct kmem_
 {
 	struct saved_alias *al;
 
-	if (slab_state == SYSFS) {
+	if (slab_state == FULL) {
 		/*
 		 * If we have a leftover link then remove it.
 		 */
@@ -5380,7 +5369,7 @@ static int __init slab_sysfs_init(void)
 		return -ENOSYS;
 	}
 
-	slab_state = SYSFS;
+	slab_state = FULL;
 
 	list_for_each_entry(s, &slab_caches, list) {
 		err = sysfs_slab_add(s);
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-05-23 04:23:27.567024810 -0500
+++ linux-2.6/mm/slab_common.c	2012-05-23 04:23:44.383024464 -0500
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
@@ -65,3 +69,8 @@ out:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
+int slab_is_available(void)
+{
+	return slab_state >= UP;
+}
+
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2012-05-23 04:23:27.571024809 -0500
+++ linux-2.6/include/linux/slab.h	2012-05-23 04:23:44.383024464 -0500
@@ -117,10 +117,6 @@ int kmem_cache_shrink(struct kmem_cache
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
