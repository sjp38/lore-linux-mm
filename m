Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 95A716B0047
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 09:22:47 -0400 (EDT)
Date: Mon, 4 Oct 2010 08:22:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: slub: Enable sysfs support for !CONFIG_SLUB_DEBUG
Message-ID: <alpine.DEB.2.00.1010040821420.2865@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently disabling CONFIG_SLUB_DEBUG also disabled SYSFS support meaning
that the slabs cannot be tuned without DEBUG.

Make SYSFS support independent of DEBUG

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    2 +-
 lib/Kconfig.debug        |    2 +-
 mm/slub.c                |   40 +++++++++++++++++++++++++++++++++++-----
 3 files changed, 37 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-04 08:16:36.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-04 08:17:49.000000000 -0500
@@ -198,7 +198,7 @@ struct track {

 enum track_item { TRACK_ALLOC, TRACK_FREE };

-#ifdef CONFIG_SLUB_DEBUG
+#ifdef CONFIG_SYSFS
 static int sysfs_slab_add(struct kmem_cache *);
 static int sysfs_slab_alias(struct kmem_cache *, const char *);
 static void sysfs_slab_remove(struct kmem_cache *);
@@ -1102,7 +1102,7 @@ static inline void slab_free_hook(struct
 static inline void slab_free_hook_irq(struct kmem_cache *s,
 		void *object) {}

-#endif
+#endif /* CONFIG_SLUB_DEBUG */

 /*
  * Slab allocation and freeing
@@ -3373,7 +3373,7 @@ void *__kmalloc_node_track_caller(size_t
 }
 #endif

-#ifdef CONFIG_SLUB_DEBUG
+#ifdef CONFIG_SYSFS
 static int count_inuse(struct page *page)
 {
 	return page->inuse;
@@ -3383,7 +3383,9 @@ static int count_total(struct page *page
 {
 	return page->objects;
 }
+#endif

+#ifdef CONFIG_SLUB_DEBUG
 static int validate_slab(struct kmem_cache *s, struct page *page,
 						unsigned long *map)
 {
@@ -3474,6 +3476,7 @@ static long validate_slab_cache(struct k
 	kfree(map);
 	return count;
 }
+#endif

 #ifdef SLUB_RESILIENCY_TEST
 static void resiliency_test(void)
@@ -3532,9 +3535,12 @@ static void resiliency_test(void)
 	validate_slab_cache(kmalloc_caches[9]);
 }
 #else
+#ifdef CONFIG_SYSFS
 static void resiliency_test(void) {};
 #endif
+#endif

+#ifdef CONFIG_DEBUG
 /*
  * Generate lists of code addresses where slabcache objects are allocated
  * and freed.
@@ -3763,7 +3769,9 @@ static int list_locations(struct kmem_ca
 		len += sprintf(buf, "No data\n");
 	return len;
 }
+#endif

+#ifdef CONFIG_SYSFS
 enum slab_stat_type {
 	SL_ALL,			/* All slabs */
 	SL_PARTIAL,		/* Only partially allocated slabs */
@@ -3816,6 +3824,8 @@ static ssize_t show_slab_objects(struct
 		}
 	}

+	down_read(&slub_lock);
+#ifdef CONFIG_SLUB_DEBUG
 	if (flags & SO_ALL) {
 		for_each_node_state(node, N_NORMAL_MEMORY) {
 			struct kmem_cache_node *n = get_node(s, node);
@@ -3832,7 +3842,9 @@ static ssize_t show_slab_objects(struct
 			nodes[node] += x;
 		}

-	} else if (flags & SO_PARTIAL) {
+	} else
+#endif
+	if (flags & SO_PARTIAL) {
 		for_each_node_state(node, N_NORMAL_MEMORY) {
 			struct kmem_cache_node *n = get_node(s, node);

@@ -3857,6 +3869,7 @@ static ssize_t show_slab_objects(struct
 	return x + sprintf(buf + x, "\n");
 }

+#ifdef CONFIG_SLUB_DEBUG
 static int any_slab_objects(struct kmem_cache *s)
 {
 	int node;
@@ -3872,6 +3885,7 @@ static int any_slab_objects(struct kmem_
 	}
 	return 0;
 }
+#endif

 #define to_slab_attr(n) container_of(n, struct slab_attribute, attr)
 #define to_slab(n) container_of(n, struct kmem_cache, kobj);
@@ -3973,11 +3987,13 @@ static ssize_t aliases_show(struct kmem_
 }
 SLAB_ATTR_RO(aliases);

+#ifdef CONFIG_SLUB_DEBUG
 static ssize_t slabs_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_ALL);
 }
 SLAB_ATTR_RO(slabs);
+#endif

 static ssize_t partial_show(struct kmem_cache *s, char *buf)
 {
@@ -4003,6 +4019,7 @@ static ssize_t objects_partial_show(stru
 }
 SLAB_ATTR_RO(objects_partial);

+#ifdef CONFIG_SLUB_DEBUG
 static ssize_t total_objects_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_ALL|SO_TOTAL);
@@ -4055,6 +4072,7 @@ static ssize_t failslab_store(struct kme
 }
 SLAB_ATTR(failslab);
 #endif
+#endif

 static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
 {
@@ -4091,6 +4109,7 @@ static ssize_t destroy_by_rcu_show(struc
 }
 SLAB_ATTR_RO(destroy_by_rcu);

+#ifdef CONFIG_SLUB_DEBUG
 static ssize_t red_zone_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", !!(s->flags & SLAB_RED_ZONE));
@@ -4166,6 +4185,7 @@ static ssize_t validate_store(struct kme
 	return ret;
 }
 SLAB_ATTR(validate);
+#endif

 static ssize_t shrink_show(struct kmem_cache *s, char *buf)
 {
@@ -4186,6 +4206,7 @@ static ssize_t shrink_store(struct kmem_
 }
 SLAB_ATTR(shrink);

+#ifdef CONFIG_SLUB_DEBUG
 static ssize_t alloc_calls_show(struct kmem_cache *s, char *buf)
 {
 	if (!(s->flags & SLAB_STORE_USER))
@@ -4201,6 +4222,7 @@ static ssize_t free_calls_show(struct km
 	return list_locations(s, buf, TRACK_FREE);
 }
 SLAB_ATTR_RO(free_calls);
+#endif

 #ifdef CONFIG_NUMA
 static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
@@ -4307,25 +4329,33 @@ static struct attribute *slab_attrs[] =
 	&min_partial_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
+#ifdef CONFIG_SLUB_DEBUG
 	&total_objects_attr.attr,
 	&slabs_attr.attr,
+#endif
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
 	&ctor_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
+#ifdef CONFIG_SLUB_DEBUG
 	&sanity_checks_attr.attr,
 	&trace_attr.attr,
+#endif
 	&hwcache_align_attr.attr,
 	&reclaim_account_attr.attr,
 	&destroy_by_rcu_attr.attr,
+#ifdef CONFIG_SLUB_DEBUG
 	&red_zone_attr.attr,
 	&poison_attr.attr,
 	&store_user_attr.attr,
 	&validate_attr.attr,
+#endif
 	&shrink_attr.attr,
+#ifdef CONFIG_SLUB_DEBUG
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+#endif
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif
@@ -4608,7 +4638,7 @@ static int __init slab_sysfs_init(void)
 }

 __initcall(slab_sysfs_init);
-#endif
+#endif /* CONFIG_SYSFS */

 /*
  * The /proc/slabinfo ABI
Index: linux-2.6/lib/Kconfig.debug
===================================================================
--- linux-2.6.orig/lib/Kconfig.debug	2010-10-04 08:14:26.000000000 -0500
+++ linux-2.6/lib/Kconfig.debug	2010-10-04 08:17:49.000000000 -0500
@@ -353,7 +353,7 @@ config SLUB_DEBUG_ON
 config SLUB_STATS
 	default n
 	bool "Enable SLUB performance statistics"
-	depends on SLUB && SLUB_DEBUG && SYSFS
+	depends on SLUB && SYSFS
 	help
 	  SLUB statistics are useful to debug SLUBs allocation behavior in
 	  order find ways to optimize the allocator. This should never be
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-10-04 08:16:36.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-10-04 08:17:49.000000000 -0500
@@ -87,7 +87,7 @@ struct kmem_cache {
 	unsigned long min_partial;
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
-#ifdef CONFIG_SLUB_DEBUG
+#ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
