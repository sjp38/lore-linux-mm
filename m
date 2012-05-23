Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 5698C6B00E9
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:35:10 -0400 (EDT)
Message-Id: <20120523203508.434967564@linux.com>
Date: Wed, 23 May 2012 15:34:39 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common 06/22] Extract common fields from struct kmem_cache
References: <20120523203433.340661918@linux.com>
Content-Disposition: inline; filename=common_fields
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Define "COMMON" to include definitions for fields used in all
slab allocators. After that it will be possible to share code that
only operates on those fields of kmem_cache.

The patch basically takes the slob definition of kmem cache and
uses the field namees for the other allocators.

The slob definition of kmem_cache is moved from slob.c to slob_def.h
so that the location of the kmem_cache definition is the same for
all allocators.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slab.h     |   11 +++++++++++
 include/linux/slab_def.h |    8 ++------
 include/linux/slob_def.h |    4 ++++
 include/linux/slub_def.h |   11 ++++-------
 mm/slab.c                |   30 +++++++++++++++---------------
 mm/slob.c                |    7 -------
 6 files changed, 36 insertions(+), 35 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2012-05-22 09:05:49.416464029 -0500
+++ linux-2.6/include/linux/slab.h	2012-05-23 04:23:21.423024939 -0500
@@ -93,6 +93,17 @@
 				(unsigned long)ZERO_SIZE_PTR)
 
 /*
+ * Common fields provided in kmem_cache by all slab allocators
+ */
+#define SLAB_COMMON \
+	unsigned int size, align;					\
+	unsigned long flags;						\
+	const char *name;						\
+	int refcount;							\
+	void (*ctor)(void *);						\
+	struct list_head list;
+
+/*
  * struct kmem_cache related prototypes
  */
 void __init kmem_cache_init(void);
Index: linux-2.6/include/linux/slab_def.h
===================================================================
--- linux-2.6.orig/include/linux/slab_def.h	2012-05-22 09:05:49.360464030 -0500
+++ linux-2.6/include/linux/slab_def.h	2012-05-23 04:23:21.423024939 -0500
@@ -31,7 +31,6 @@ struct kmem_cache {
 	u32 reciprocal_buffer_size;
 /* 2) touched by every alloc & free from the backend */
 
-	unsigned int flags;		/* constant flags */
 	unsigned int num;		/* # of objs per slab */
 
 /* 3) cache_grow/shrink */
@@ -47,12 +46,9 @@ struct kmem_cache {
 	unsigned int slab_size;
 	unsigned int dflags;		/* dynamic flags */
 
-	/* constructor func */
-	void (*ctor)(void *obj);
-
 /* 4) cache creation/removal */
-	const char *name;
-	struct list_head next;
+
+	SLAB_COMMON
 
 /* 5) statistics */
 #ifdef CONFIG_DEBUG_SLAB
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2012-05-22 09:05:49.392464029 -0500
+++ linux-2.6/include/linux/slub_def.h	2012-05-23 04:23:21.423024939 -0500
@@ -80,9 +80,7 @@ struct kmem_cache_order_objects {
 struct kmem_cache {
 	struct kmem_cache_cpu __percpu *cpu_slab;
 	/* Used for retriving partial slabs etc */
-	unsigned long flags;
 	unsigned long min_partial;
-	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
 	int cpu_partial;	/* Number of per cpu partial objects to keep around */
@@ -92,13 +90,12 @@ struct kmem_cache {
 	struct kmem_cache_order_objects max;
 	struct kmem_cache_order_objects min;
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
-	int refcount;		/* Refcount for slab cache destroy */
-	void (*ctor)(void *);
+
+	SLAB_COMMON
+
 	int inuse;		/* Offset to metadata */
-	int align;		/* Alignment */
 	int reserved;		/* Reserved bytes at the end of slabs */
-	const char *name;	/* Name (only for display!) */
-	struct list_head list;	/* List of slab caches */
+
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 #endif
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-05-22 09:21:26.588444610 -0500
+++ linux-2.6/mm/slob.c	2012-05-23 04:23:21.423024939 -0500
@@ -506,13 +506,6 @@ size_t ksize(const void *block)
 }
 EXPORT_SYMBOL(ksize);
 
-struct kmem_cache {
-	unsigned int size, align;
-	unsigned long flags;
-	const char *name;
-	void (*ctor)(void *);
-};
-
 struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *))
 {
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-05-22 09:27:35.664436970 -0500
+++ linux-2.6/mm/slab.c	2012-05-23 04:23:21.427024939 -0500
@@ -1134,7 +1134,7 @@ static int init_cache_nodelists_node(int
 	struct kmem_list3 *l3;
 	const int memsize = sizeof(struct kmem_list3);
 
-	list_for_each_entry(cachep, &cache_chain, next) {
+	list_for_each_entry(cachep, &cache_chain, list) {
 		/*
 		 * Set up the size64 kmemlist for cpu before we can
 		 * begin anything. Make sure some other cpu on this
@@ -1172,7 +1172,7 @@ static void __cpuinit cpuup_canceled(lon
 	int node = cpu_to_mem(cpu);
 	const struct cpumask *mask = cpumask_of_node(node);
 
-	list_for_each_entry(cachep, &cache_chain, next) {
+	list_for_each_entry(cachep, &cache_chain, list) {
 		struct array_cache *nc;
 		struct array_cache *shared;
 		struct array_cache **alien;
@@ -1222,7 +1222,7 @@ free_array_cache:
 	 * the respective cache's slabs,  now we can go ahead and
 	 * shrink each nodelist to its limit.
 	 */
-	list_for_each_entry(cachep, &cache_chain, next) {
+	list_for_each_entry(cachep, &cache_chain, list) {
 		l3 = cachep->nodelists[node];
 		if (!l3)
 			continue;
@@ -1251,7 +1251,7 @@ static int __cpuinit cpuup_prepare(long
 	 * Now we can go ahead with allocating the shared arrays and
 	 * array caches
 	 */
-	list_for_each_entry(cachep, &cache_chain, next) {
+	list_for_each_entry(cachep, &cache_chain, list) {
 		struct array_cache *nc;
 		struct array_cache *shared = NULL;
 		struct array_cache **alien = NULL;
@@ -1383,7 +1383,7 @@ static int __meminit drain_cache_nodelis
 	struct kmem_cache *cachep;
 	int ret = 0;
 
-	list_for_each_entry(cachep, &cache_chain, next) {
+	list_for_each_entry(cachep, &cache_chain, list) {
 		struct kmem_list3 *l3;
 
 		l3 = cachep->nodelists[node];
@@ -1526,7 +1526,7 @@ void __init kmem_cache_init(void)
 
 	/* 1) create the cache_cache */
 	INIT_LIST_HEAD(&cache_chain);
-	list_add(&cache_cache.next, &cache_chain);
+	list_add(&cache_cache.list, &cache_chain);
 	cache_cache.colour_off = cache_line_size();
 	cache_cache.array[smp_processor_id()] = &initarray_cache.cache;
 	cache_cache.nodelists[node] = &initkmem_list3[CACHE_CACHE + node];
@@ -1671,7 +1671,7 @@ void __init kmem_cache_init_late(void)
 
 	/* 6) resize the head arrays to their final sizes */
 	mutex_lock(&cache_chain_mutex);
-	list_for_each_entry(cachep, &cache_chain, next)
+	list_for_each_entry(cachep, &cache_chain, list)
 		if (enable_cpucache(cachep, GFP_NOWAIT))
 			BUG();
 	mutex_unlock(&cache_chain_mutex);
@@ -2281,7 +2281,7 @@ kmem_cache_create (const char *name, siz
 		mutex_lock(&cache_chain_mutex);
 	}
 
-	list_for_each_entry(pc, &cache_chain, next) {
+	list_for_each_entry(pc, &cache_chain, list) {
 		char tmp;
 		int res;
 
@@ -2526,7 +2526,7 @@ kmem_cache_create (const char *name, siz
 	}
 
 	/* cache setup completed, link it into the list */
-	list_add(&cachep->next, &cache_chain);
+	list_add(&cachep->list, &cache_chain);
 oops:
 	if (!cachep && (flags & SLAB_PANIC))
 		panic("kmem_cache_create(): failed to create slab `%s'\n",
@@ -2721,10 +2721,10 @@ void kmem_cache_destroy(struct kmem_cach
 	/*
 	 * the chain is never empty, cache_cache is never destroyed
 	 */
-	list_del(&cachep->next);
+	list_del(&cachep->list);
 	if (__cache_shrink(cachep)) {
 		slab_error(cachep, "Can't free all objects");
-		list_add(&cachep->next, &cache_chain);
+		list_add(&cachep->list, &cache_chain);
 		mutex_unlock(&cache_chain_mutex);
 		put_online_cpus();
 		return;
@@ -4011,7 +4011,7 @@ static int alloc_kmemlist(struct kmem_ca
 	return 0;
 
 fail:
-	if (!cachep->next.next) {
+	if (!cachep->list.next) {
 		/* Cache is not active yet. Roll back what we did */
 		node--;
 		while (node >= 0) {
@@ -4196,7 +4196,7 @@ static void cache_reap(struct work_struc
 		/* Give up. Setup the next iteration. */
 		goto out;
 
-	list_for_each_entry(searchp, &cache_chain, next) {
+	list_for_each_entry(searchp, &cache_chain, list) {
 		check_irq_on();
 
 		/*
@@ -4289,7 +4289,7 @@ static void s_stop(struct seq_file *m, v
 
 static int s_show(struct seq_file *m, void *p)
 {
-	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, next);
+	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
 	struct slab *slabp;
 	unsigned long active_objs;
 	unsigned long num_objs;
@@ -4437,7 +4437,7 @@ static ssize_t slabinfo_write(struct fil
 	/* Find the cache in the chain of caches. */
 	mutex_lock(&cache_chain_mutex);
 	res = -EINVAL;
-	list_for_each_entry(cachep, &cache_chain, next) {
+	list_for_each_entry(cachep, &cache_chain, list) {
 		if (!strcmp(cachep->name, kbuf)) {
 			if (limit < 1 || batchcount < 1 ||
 					batchcount > limit || shared < 0) {
Index: linux-2.6/include/linux/slob_def.h
===================================================================
--- linux-2.6.orig/include/linux/slob_def.h	2012-05-22 09:05:49.376464032 -0500
+++ linux-2.6/include/linux/slob_def.h	2012-05-23 04:23:21.427024939 -0500
@@ -1,6 +1,10 @@
 #ifndef __LINUX_SLOB_DEF_H
 #define __LINUX_SLOB_DEF_H
 
+struct kmem_cache {
+	SLAB_COMMON
+};
+
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
 static __always_inline void *kmem_cache_alloc(struct kmem_cache *cachep,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
