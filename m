Date: Tue, 12 Jun 2007 16:26:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: minimum alignment fixes
Message-ID: <Pine.LNX.4.64.0706121623490.7300@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: =?iso-8859-1?Q?H=E5vard_Skinnemoen?= <hskinnemoen@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If ARCH_KMALLOC_MINALIGN is set to a value greater than 8 (SLUBs smallest
kmalloc cache) then SLUB may generate duplicate slabs in sysfs (yes again) 
because the object size is padded to reach ARCH_KMALLOC_MINALIGN. Thus 
the size of the small slabs is all the same.

No arch sets ARCH_KMALLOC_MINALIGN larger than 8 though except mips which 
for some reason wants a 128 byte alignment.

This patch increases the size of the smallest cache if ARCH_KMALLOC_MINALIGN
is greater than 8. In that case more and more of the smallest caches are
disabled.

If we do that then the count of the active general caches that is displayed
on boot is not correct anymore since we may skip elements of the kmalloc
array. So count them separately.

This approach was tested by Havard yesterday.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slub_def.h |   13 +++++++++++--
 mm/slub.c                |   20 +++++++++++++++-----
 2 files changed, 26 insertions(+), 7 deletions(-)

Index: vps/include/linux/slub_def.h
===================================================================
--- vps.orig/include/linux/slub_def.h	2007-06-12 15:58:30.000000000 -0700
+++ vps/include/linux/slub_def.h	2007-06-12 16:00:43.000000000 -0700
@@ -28,7 +28,7 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
-	unsigned int order;
+	int order;
 
 	/*
 	 * Avoid an extra cache line for UP, SMP and for the node local to
@@ -56,7 +56,13 @@ struct kmem_cache {
 /*
  * Kmalloc subsystem.
  */
-#define KMALLOC_SHIFT_LOW 3
+#if defined(ARCH_KMALLOC_MINALIGN) && ARCH_KMALLOC_MINALIGN > 8
+#define KMALLOC_MIN_SIZE ARCH_KMALLOC_MINALIGN
+#else
+#define KMALLOC_MIN_SIZE 8
+#endif
+
+#define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)
 
 /*
  * We keep the general caches in an array of slab caches that are used for
@@ -76,6 +82,9 @@ static inline int kmalloc_index(size_t s
 	if (size > KMALLOC_MAX_SIZE)
 		return -1;
 
+	if (size <= KMALLOC_MIN_SIZE)
+		return KMALLOC_SHIFT_LOW;
+
 	if (size > 64 && size <= 96)
 		return 1;
 	if (size > 128 && size <= 192)
Index: vps/mm/slub.c
===================================================================
--- vps.orig/mm/slub.c	2007-06-12 15:58:37.000000000 -0700
+++ vps/mm/slub.c	2007-06-12 16:03:00.000000000 -0700
@@ -2521,6 +2521,7 @@ EXPORT_SYMBOL(krealloc);
 void __init kmem_cache_init(void)
 {
 	int i;
+	int caches = 0;
 
 	if (!page_group_by_mobility_disabled && !user_override) {
 		/*
@@ -2540,20 +2541,29 @@ void __init kmem_cache_init(void)
 	create_kmalloc_cache(&kmalloc_caches[0], "kmem_cache_node",
 		sizeof(struct kmem_cache_node), GFP_KERNEL);
 	kmalloc_caches[0].refcount = -1;
+	caches++;
 #endif
 
 	/* Able to allocate the per node structures */
 	slab_state = PARTIAL;
 
 	/* Caches that are not of the two-to-the-power-of size */
-	create_kmalloc_cache(&kmalloc_caches[1],
+	if (KMALLOC_MIN_SIZE <= 64) {
+		create_kmalloc_cache(&kmalloc_caches[1],
 				"kmalloc-96", 96, GFP_KERNEL);
-	create_kmalloc_cache(&kmalloc_caches[2],
+		caches++;
+	}
+	if (KMALLOC_MIN_SIZE <= 128) {
+		create_kmalloc_cache(&kmalloc_caches[2],
 				"kmalloc-192", 192, GFP_KERNEL);
+		caches++;
+	}
 
-	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++)
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
 		create_kmalloc_cache(&kmalloc_caches[i],
 			"kmalloc", 1 << i, GFP_KERNEL);
+		caches++;
+	}
 
 	slab_state = UP;
 
@@ -2570,8 +2580,8 @@ void __init kmem_cache_init(void)
 				nr_cpu_ids * sizeof(struct page *);
 
 	printk(KERN_INFO "SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
-		" Processors=%d, Nodes=%d\n",
-		KMALLOC_SHIFT_HIGH, cache_line_size(),
+		" CPUs=%d, Nodes=%d\n",
+		caches, cache_line_size(),
 		slub_min_order, slub_max_order, slub_min_objects,
 		nr_cpu_ids, nr_node_ids);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
