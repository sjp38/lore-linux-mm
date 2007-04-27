Message-Id: <20070427042909.181261436@sgi.com>
References: <20070427042655.019305162@sgi.com>
Date: Thu, 26 Apr 2007 21:27:03 -0700
From: clameter@sgi.com
Subject: [patch 08/10] SLUB: Reduce the order of allocations to avoid fragmentation
Content-Disposition: inline; filename=slub_i386_no_frag
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Seems that fragmentation is an important subject. So be safe.

If an arch supports 4k page size then assume that defragmentation may be
a major problem. Reduce the minimum number of objects in a slab and
limit the order of slabs. Be a little bit more lenient for larger
page sizes.

Change the bootup message of SLUB to show the parameters so that
difficulties due to fragmentation are detectable when the boot
log is reviewed.

Cc: Mel Gorman <mel@skynet.ie>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc7-mm2/mm/slub.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/mm/slub.c	2007-04-26 21:01:28.000000000 -0700
+++ linux-2.6.21-rc7-mm2/mm/slub.c	2007-04-26 21:02:01.000000000 -0700
@@ -109,6 +109,25 @@
 /* Enable to test recovery from slab corruption on boot */
 #undef SLUB_RESILIENCY_TEST
 
+#if PAGE_SHIFT <= 12
+
+/*
+ * Small page size. Make sure that we do not fragment memory
+ */
+#define DEFAULT_MAX_ORDER 1
+#define DEFAULT_MIN_OBJECTS 4
+
+#else
+
+/*
+ * Large page machines are customarily able to handle larger
+ * page orders.
+ */
+#define DEFAULT_MAX_ORDER 2
+#define DEFAULT_MIN_OBJECTS 8
+
+#endif
+
 /*
  * Mininum number of partial slabs. These will be left on the partial
  * lists even if they are empty. kmem_cache_shrink may reclaim them.
@@ -1437,13 +1456,13 @@ static struct page *get_object_page(cons
  * take the list_lock.
  */
 static int slub_min_order;
-static int slub_max_order = 4;
+static int slub_max_order = DEFAULT_MAX_ORDER;
 
 /*
  * Minimum number of objects per slab. This is necessary in order to
  * reduce locking overhead. Similar to the queue size in SLAB.
  */
-static int slub_min_objects = 8;
+static int slub_min_objects = DEFAULT_MIN_OBJECTS;
 
 /*
  * Merge control. If this is set then no merging of slab caches will occur.
@@ -2338,9 +2357,10 @@ void __init kmem_cache_init(void)
 		kmem_size = offsetof(struct kmem_cache, cpu_slab)
 			 + nr_cpu_ids * sizeof(struct page *);
 
-	printk(KERN_INFO "SLUB: General Slabs=%d, HW alignment=%d, "
-		"Processors=%d, Nodes=%d\n",
+	printk(KERN_INFO "SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
+		" Processors=%d, Nodes=%d\n",
 		KMALLOC_SHIFT_HIGH, L1_CACHE_BYTES,
+		slub_min_order, slub_max_order, slub_min_objects,
 		nr_cpu_ids, nr_node_ids);
 }
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
