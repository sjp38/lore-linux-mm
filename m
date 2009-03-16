Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE766B009A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:51:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 24/27] Convert gfp_zone() to use a table of precalculated values
Date: Mon, 16 Mar 2009 17:53:38 +0000
Message-Id: <1237226020-14057-25-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Every page allocation uses gfp_zone() to calcuate what the highest zone
allowed by a combination of GFP flags is. This is a large number of branches
to have in a fast path. This patch replaces the branches with a lookup
table that is calculated at boot-time and stored in the read-mostly section
so it can be shared. This requires __GFP_MOVABLE to be redefined but it's
debatable as to whether it should be considered a zone modifier or not.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/gfp.h |   28 +++++++++++-----------------
 init/main.c         |    1 +
 mm/page_alloc.c     |   36 +++++++++++++++++++++++++++++++++++-
 3 files changed, 47 insertions(+), 18 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 59eb093..581f8a9 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -16,6 +16,10 @@ struct vm_area_struct;
  * Do not put any conditional on these. If necessary modify the definitions
  * without the underscores and use the consistently. The definitions here may
  * be used in bit comparisons.
+ *
+ * Note that __GFP_MOVABLE uses the next available bit but it is not
+ * a zone modifier. It uses the fourth bit so that the calculation of
+ * gfp_zone() can use a table rather than a series of comparisons
  */
 #define __GFP_DMA	((__force gfp_t)0x01u)
 #define __GFP_HIGHMEM	((__force gfp_t)0x02u)
@@ -50,7 +54,7 @@ struct vm_area_struct;
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
-#define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */
+#define __GFP_MOVABLE	((__force gfp_t)0x08u)  /* Page is movable */
 
 #define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -77,6 +81,9 @@ struct vm_area_struct;
 #define GFP_THISNODE	((__force gfp_t)0)
 #endif
 
+/* This is a mask of all modifiers affecting gfp_zonemask() */
+#define GFP_ZONEMASK (__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32 | __GFP_MOVABLE)
+
 /* This mask makes up all the page movable related flags */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
 
@@ -112,24 +119,11 @@ static inline int allocflags_to_migratetype(gfp_t gfp_flags)
 		((gfp_flags & __GFP_RECLAIMABLE) != 0);
 }
 
+extern int gfp_zone_table[GFP_ZONEMASK];
+void init_gfp_zone_table(void);
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
-#ifdef CONFIG_ZONE_DMA
-	if (flags & __GFP_DMA)
-		return ZONE_DMA;
-#endif
-#ifdef CONFIG_ZONE_DMA32
-	if (flags & __GFP_DMA32)
-		return ZONE_DMA32;
-#endif
-	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
-			(__GFP_HIGHMEM | __GFP_MOVABLE))
-		return ZONE_MOVABLE;
-#ifdef CONFIG_HIGHMEM
-	if (flags & __GFP_HIGHMEM)
-		return ZONE_HIGHMEM;
-#endif
-	return ZONE_NORMAL;
+	return gfp_zone_table[flags & GFP_ZONEMASK];
 }
 
 /*
diff --git a/init/main.c b/init/main.c
index 8442094..08a5663 100644
--- a/init/main.c
+++ b/init/main.c
@@ -573,6 +573,7 @@ asmlinkage void __init start_kernel(void)
 	 * fragile until we cpu_idle() for the first time.
 	 */
 	preempt_disable();
+	init_gfp_zone_table();
 	build_all_zonelists();
 	page_alloc_init();
 	printk(KERN_NOTICE "Kernel command line: %s\n", boot_command_line);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 98ce091..f71091a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -70,6 +70,7 @@ EXPORT_SYMBOL(node_states);
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 unsigned long highest_memmap_pfn __read_mostly;
+int gfp_zone_table[GFP_ZONEMASK] __read_mostly;
 int static_num_online_nodes __read_mostly;
 int percpu_pagelist_fraction;
 
@@ -4569,7 +4570,7 @@ static void setup_per_zone_inactive_ratio(void)
  * 8192MB:	11584k
  * 16384MB:	16384k
  */
-static int __init init_per_zone_pages_min(void)
+static int init_per_zone_pages_min(void)
 {
 	unsigned long lowmem_kbytes;
 
@@ -4587,6 +4588,39 @@ static int __init init_per_zone_pages_min(void)
 }
 module_init(init_per_zone_pages_min)
 
+static inline int __init gfp_flags_to_zone(gfp_t flags)
+{
+#ifdef CONFIG_ZONE_DMA
+	if (flags & __GFP_DMA)
+		return ZONE_DMA;
+#endif
+#ifdef CONFIG_ZONE_DMA32
+	if (flags & __GFP_DMA32)
+		return ZONE_DMA32;
+#endif
+	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
+			(__GFP_HIGHMEM | __GFP_MOVABLE))
+		return ZONE_MOVABLE;
+#ifdef CONFIG_HIGHMEM
+	if (flags & __GFP_HIGHMEM)
+		return ZONE_HIGHMEM;
+#endif
+	return ZONE_NORMAL;
+}
+
+/*
+ * For each possible combination of zone modifier flags, we calculate
+ * what zone it should be using. This consumes a cache line in most
+ * cases but avoids a number of branches in the allocator fast path
+ */
+void __init init_gfp_zone_table(void)
+{
+	gfp_t gfp_flags;
+
+	for (gfp_flags = 0; gfp_flags < GFP_ZONEMASK; gfp_flags++)
+		gfp_zone_table[gfp_flags] = gfp_flags_to_zone(gfp_flags);
+}
+
 /*
  * min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so 
  *	that we can call two helper functions whenever min_free_kbytes
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
