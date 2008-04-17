From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080417000644.18399.66175.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080417000624.18399.35041.sendpatchset@skynet.skynet.ie>
References: <20080417000624.18399.35041.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/4] Add a basic debugging framework for memory initialisation
Date: Thu, 17 Apr 2008 01:06:44 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch creates a new file mm/mm_init.c which is conditionally
compiled to have almost all of the debugging and verification code to
avoid further polluting page_alloc.c. Ideally other mm initialisation code
will be moved here over time and the file partially compiled depending
on Kconfig. This patch introduces a simple mminit_debug_printk() macro
and an mminit_debug_level commmand-line parameter for setting the level of
tracing and verification that should be done.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 Documentation/kernel-parameters.txt |    8 ++++++++
 lib/Kconfig.debug                   |   12 ++++++++++++
 mm/Makefile                         |    1 +
 mm/internal.h                       |   26 ++++++++++++++++++++++++++
 mm/mm_init.c                        |   18 ++++++++++++++++++
 mm/page_alloc.c                     |   16 ++++++++++------
 6 files changed, 75 insertions(+), 6 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-ingo-fix-sparsemem/Documentation/kernel-parameters.txt linux-2.6.25-rc9-0010_mminit_debug_framework/Documentation/kernel-parameters.txt
--- linux-2.6.25-rc9-ingo-fix-sparsemem/Documentation/kernel-parameters.txt	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-0010_mminit_debug_framework/Documentation/kernel-parameters.txt	2008-04-17 00:20:19.000000000 +0100
@@ -1148,6 +1148,14 @@ and is between 256 and 4096 characters. 
 
 	mga=		[HW,DRM]
 
+	mminit_debug_level=
+			[KNL] When CONFIG_DEBUG_MEMORY_INIT is set, this
+			parameter allows control of what level of debugging
+			and verification is done during memory initialisation.
+			A value of -1 disables the checks and a level of 4 will
+			enable tracing. By default basic verifications are made
+			when the Kconfig option is set
+
 	mousedev.tap_time=
 			[MOUSE] Maximum time between finger touching and
 			leaving touchpad surface for touch to be considered
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-ingo-fix-sparsemem/lib/Kconfig.debug linux-2.6.25-rc9-0010_mminit_debug_framework/lib/Kconfig.debug
--- linux-2.6.25-rc9-ingo-fix-sparsemem/lib/Kconfig.debug	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-0010_mminit_debug_framework/lib/Kconfig.debug	2008-04-17 00:20:19.000000000 +0100
@@ -437,6 +437,18 @@ config DEBUG_VM
 
 	  If unsure, say N.
 
+config DEBUG_MEMORY_INIT
+	bool "Debug memory initialisation"
+	depends on DEBUG_KERNEL
+	help
+	  Enable this to turn on debug checks during memory initialisation. By
+	  default, sanity checks will be made on the memory model and
+	  information provided by the architecture. What level of checking
+	  made and verbosity during boot can be set with the
+	  mminit_debug_level= command-line option.
+
+	  If unsure, say N
+
 config DEBUG_LIST
 	bool "Debug linked list manipulation"
 	depends on DEBUG_KERNEL
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-ingo-fix-sparsemem/mm/internal.h linux-2.6.25-rc9-0010_mminit_debug_framework/mm/internal.h
--- linux-2.6.25-rc9-ingo-fix-sparsemem/mm/internal.h	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-0010_mminit_debug_framework/mm/internal.h	2008-04-17 00:20:19.000000000 +0100
@@ -60,4 +60,30 @@ static inline unsigned long page_order(s
 #define __paginginit __init
 #endif
 
+/* Memory initialisation debug and verification */
+enum mminit_levels {
+	MMINIT_NORMAL = -1,
+	MMINIT_VERIFY,
+	MMINIT_TRACE
+};
+
+#ifdef CONFIG_DEBUG_MEMORY_INIT
+
+extern int mminit_debug_level;
+
+#define mminit_debug_printk(level, prefix, fmt, arg...) \
+do { \
+	if (level < mminit_debug_level) { \
+		printk(KERN_INFO "mminit::%s " fmt, prefix, ##arg); \
+	} \
+} while (0)
+
+#else
+
+static inline void mminit_debug_printk(unsigned int level, const char *prefix,
+				const char *fmt, ...)
+{
+}
+
+#endif /* CONFIG_DEBUG_MEMORY_INIT */
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-ingo-fix-sparsemem/mm/Makefile linux-2.6.25-rc9-0010_mminit_debug_framework/mm/Makefile
--- linux-2.6.25-rc9-ingo-fix-sparsemem/mm/Makefile	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-0010_mminit_debug_framework/mm/Makefile	2008-04-17 00:20:19.000000000 +0100
@@ -33,4 +33,5 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_DEBUG_MEMORY_INIT) += mm_init.o
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-ingo-fix-sparsemem/mm/mm_init.c linux-2.6.25-rc9-0010_mminit_debug_framework/mm/mm_init.c
--- linux-2.6.25-rc9-ingo-fix-sparsemem/mm/mm_init.c	2008-04-16 10:42:54.000000000 +0100
+++ linux-2.6.25-rc9-0010_mminit_debug_framework/mm/mm_init.c	2008-04-17 00:20:19.000000000 +0100
@@ -0,0 +1,18 @@
+/*
+ * mm_init.c - Memory initialisation verification and debugging
+ *
+ * Copyright 2008 IBM Corporation, 2008
+ * Author Mel Gorman <mel@csn.ul.ie>
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/init.h>
+
+int __initdata mminit_debug_level;
+
+static __init int set_mminit_debug_level(char *str)
+{
+	get_option(&str, &mminit_debug_level);
+	return 0;
+}
+early_param("mminit_debug_level", set_mminit_debug_level);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-ingo-fix-sparsemem/mm/page_alloc.c linux-2.6.25-rc9-0010_mminit_debug_framework/mm/page_alloc.c
--- linux-2.6.25-rc9-ingo-fix-sparsemem/mm/page_alloc.c	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-0010_mminit_debug_framework/mm/page_alloc.c	2008-04-17 00:20:19.000000000 +0100
@@ -2958,7 +2958,8 @@ void __init sparse_memory_present_with_a
 void __init push_node_boundaries(unsigned int nid,
 		unsigned long start_pfn, unsigned long end_pfn)
 {
-	printk(KERN_DEBUG "Entering push_node_boundaries(%u, %lu, %lu)\n",
+	mminit_debug_printk(MMINIT_TRACE, "zoneboundary",
+			"Entering push_node_boundaries(%u, %lu, %lu)\n",
 			nid, start_pfn, end_pfn);
 
 	/* Initialise the boundary for this node if necessary */
@@ -2976,7 +2977,8 @@ void __init push_node_boundaries(unsigne
 static void __meminit account_node_boundary(unsigned int nid,
 		unsigned long *start_pfn, unsigned long *end_pfn)
 {
-	printk(KERN_DEBUG "Entering account_node_boundary(%u, %lu, %lu)\n",
+	mminit_debug_printk(MMINIT_TRACE, "zoneboundary",
+			"Entering account_node_boundary(%u, %lu, %lu)\n",
 			nid, *start_pfn, *end_pfn);
 
 	/* Return if boundary information has not been provided */
@@ -3350,8 +3352,8 @@ static void __paginginit free_area_init_
 		memmap_pages = (size * sizeof(struct page)) >> PAGE_SHIFT;
 		if (realsize >= memmap_pages) {
 			realsize -= memmap_pages;
-			printk(KERN_DEBUG
-				"  %s zone: %lu pages used for memmap\n",
+			mminit_debug_printk(MMINIT_TRACE, "memmap_init",
+				"%s zone: %lu pages used for memmap\n",
 				zone_names[j], memmap_pages);
 		} else
 			printk(KERN_WARNING
@@ -3361,7 +3363,8 @@ static void __paginginit free_area_init_
 		/* Account for reserved pages */
 		if (j == 0 && realsize > dma_reserve) {
 			realsize -= dma_reserve;
-			printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
+			mminit_debug_printk(MMINIT_TRACE, "memmap_init",
+					"%s zone: %lu pages reserved\n",
 					zone_names[0], dma_reserve);
 		}
 
@@ -3496,7 +3499,8 @@ void __init add_active_range(unsigned in
 {
 	int i;
 
-	printk(KERN_DEBUG "Entering add_active_range(%d, %lu, %lu) "
+	mminit_debug_printk(MMINIT_TRACE, "memory_register",
+			"Entering add_active_range(%d, %lu, %lu) "
 			  "%d entries of %d used\n",
 			  nid, start_pfn, end_pfn,
 			  nr_nodemap_entries, MAX_ACTIVE_REGIONS);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
