From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080428192859.23649.24538.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080428192839.23649.82172.sendpatchset@skynet.skynet.ie>
References: <20080428192839.23649.82172.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/4] Add a basic debugging framework for memory initialisation
Date: Mon, 28 Apr 2008 20:28:59 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, mingo@elte.hu, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch adds additional debugging and verification code for memory
initialisation. Once enabled, the verification checks are always run and
when required additional debugging information may be outputted via a
mminit_loglevel= command-line parameter. The verification code is placed
in a new file mm/mm_init.c. Ideally other mm initialisation code will be
moved here over time.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 Documentation/kernel-parameters.txt |    8 ++++++++
 lib/Kconfig.debug                   |   12 ++++++++++++
 mm/Makefile                         |    1 +
 mm/internal.h                       |   27 +++++++++++++++++++++++++++
 mm/mm_init.c                        |   18 ++++++++++++++++++
 mm/page_alloc.c                     |   16 ++++++++++------
 6 files changed, 76 insertions(+), 6 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/Documentation/kernel-parameters.txt linux-2.6.25-mm1-0010_mminit_debug_framework/Documentation/kernel-parameters.txt
--- linux-2.6.25-mm1-clean/Documentation/kernel-parameters.txt	2008-04-22 10:29:56.000000000 +0100
+++ linux-2.6.25-mm1-0010_mminit_debug_framework/Documentation/kernel-parameters.txt	2008-04-28 14:39:59.000000000 +0100
@@ -1185,6 +1185,14 @@ and is between 256 and 4096 characters. 
 
 	mga=		[HW,DRM]
 
+	mminit_loglevel=
+			[KNL] When CONFIG_DEBUG_MEMORY_INIT is set, this
+			parameter allows control of the logging verbosity for
+			the additional memory initialisation checks. A value
+			of 0 disables mminit logging and a level of 4 will
+			log everything. Information is printed at KERN_DEBUG
+			so loglevel=8 may also need to be specified.
+
 	mousedev.tap_time=
 			[MOUSE] Maximum time between finger touching and
 			leaving touchpad surface for touch to be considered
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/lib/Kconfig.debug linux-2.6.25-mm1-0010_mminit_debug_framework/lib/Kconfig.debug
--- linux-2.6.25-mm1-clean/lib/Kconfig.debug	2008-04-22 10:30:04.000000000 +0100
+++ linux-2.6.25-mm1-0010_mminit_debug_framework/lib/Kconfig.debug	2008-04-28 14:39:59.000000000 +0100
@@ -482,6 +482,18 @@ config DEBUG_WRITECOUNT
 
 	  If unsure, say N.
 
+config DEBUG_MEMORY_INIT
+	bool "Debug memory initialisation" if EMBEDDED
+	default !EMBEDDED
+	help
+	  Enable this for additional checks during memory initialisation.
+	  The sanity checks verify aspects of the VM such as the memory model
+	  and other information provided by the architecture. Verbose
+	  information will be printed at KERN_DEBUG loglevel depending 
+	  on the mminit_loglevel= command-line option.
+
+	  If unsure, say Y
+
 config DEBUG_LIST
 	bool "Debug linked list manipulation"
 	depends on DEBUG_KERNEL
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/mm/internal.h linux-2.6.25-mm1-0010_mminit_debug_framework/mm/internal.h
--- linux-2.6.25-mm1-clean/mm/internal.h	2008-04-22 10:30:04.000000000 +0100
+++ linux-2.6.25-mm1-0010_mminit_debug_framework/mm/internal.h	2008-04-28 14:39:59.000000000 +0100
@@ -59,4 +59,31 @@ static inline unsigned long page_order(s
 #define __paginginit __init
 #endif
 
+/* Memory initialisation debug and verification */
+enum mminit_level {
+	MMINIT_WARNING,
+	MMINIT_VERIFY,
+	MMINIT_TRACE
+};
+
+#ifdef CONFIG_DEBUG_MEMORY_INIT
+
+extern int mminit_loglevel;
+
+#define mminit_dprintk(level, prefix, fmt, arg...) \
+do { \
+	if (level < mminit_loglevel) { \
+		printk(level <= MMINIT_WARNING ? KERN_WARNING : KERN_DEBUG \
+			"mminit:: " prefix " " fmt, ##arg); \
+	} \
+} while (0)
+
+#else
+
+static inline void mminit_dprintk(enum mminit_level level,
+				const char *prefix, const char *fmt, ...)
+{
+}
+
+#endif /* CONFIG_DEBUG_MEMORY_INIT */
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/mm/Makefile linux-2.6.25-mm1-0010_mminit_debug_framework/mm/Makefile
--- linux-2.6.25-mm1-clean/mm/Makefile	2008-04-22 10:30:04.000000000 +0100
+++ linux-2.6.25-mm1-0010_mminit_debug_framework/mm/Makefile	2008-04-28 14:39:59.000000000 +0100
@@ -33,4 +33,5 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_DEBUG_MEMORY_INIT) += mm_init.o
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/mm/mm_init.c linux-2.6.25-mm1-0010_mminit_debug_framework/mm/mm_init.c
--- linux-2.6.25-mm1-clean/mm/mm_init.c	2008-04-22 12:29:06.000000000 +0100
+++ linux-2.6.25-mm1-0010_mminit_debug_framework/mm/mm_init.c	2008-04-28 14:39:59.000000000 +0100
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
+int __meminitdata mminit_loglevel;
+
+static __init int set_mminit_loglevel(char *str)
+{
+	get_option(&str, &mminit_loglevel);
+	return 0;
+}
+early_param("mminit_loglevel", set_mminit_loglevel);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/mm/page_alloc.c linux-2.6.25-mm1-0010_mminit_debug_framework/mm/page_alloc.c
--- linux-2.6.25-mm1-clean/mm/page_alloc.c	2008-04-22 10:30:04.000000000 +0100
+++ linux-2.6.25-mm1-0010_mminit_debug_framework/mm/page_alloc.c	2008-04-28 14:39:59.000000000 +0100
@@ -3068,7 +3068,8 @@ void __init sparse_memory_present_with_a
 void __init push_node_boundaries(unsigned int nid,
 		unsigned long start_pfn, unsigned long end_pfn)
 {
-	printk(KERN_DEBUG "Entering push_node_boundaries(%u, %lu, %lu)\n",
+	mminit_dprintk(MMINIT_TRACE, "zoneboundary",
+			"Entering push_node_boundaries(%u, %lu, %lu)\n",
 			nid, start_pfn, end_pfn);
 
 	/* Initialise the boundary for this node if necessary */
@@ -3086,7 +3087,8 @@ void __init push_node_boundaries(unsigne
 static void __meminit account_node_boundary(unsigned int nid,
 		unsigned long *start_pfn, unsigned long *end_pfn)
 {
-	printk(KERN_DEBUG "Entering account_node_boundary(%u, %lu, %lu)\n",
+	mminit_dprintk(MMINIT_TRACE, "zoneboundary",
+			"Entering account_node_boundary(%u, %lu, %lu)\n",
 			nid, *start_pfn, *end_pfn);
 
 	/* Return if boundary information has not been provided */
@@ -3460,8 +3462,8 @@ static void __paginginit free_area_init_
 		memmap_pages = (size * sizeof(struct page)) >> PAGE_SHIFT;
 		if (realsize >= memmap_pages) {
 			realsize -= memmap_pages;
-			printk(KERN_DEBUG
-				"  %s zone: %lu pages used for memmap\n",
+			mminit_dprintk(MMINIT_TRACE, "memmap_init",
+				"%s zone: %lu pages used for memmap\n",
 				zone_names[j], memmap_pages);
 		} else
 			printk(KERN_WARNING
@@ -3471,7 +3473,8 @@ static void __paginginit free_area_init_
 		/* Account for reserved pages */
 		if (j == 0 && realsize > dma_reserve) {
 			realsize -= dma_reserve;
-			printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
+			mminit_dprintk(MMINIT_TRACE, "memmap_init",
+					"%s zone: %lu pages reserved\n",
 					zone_names[0], dma_reserve);
 		}
 
@@ -3609,7 +3612,8 @@ void __init add_active_range(unsigned in
 {
 	int i;
 
-	printk(KERN_DEBUG "Entering add_active_range(%d, %lu, %lu) "
+	mminit_dprintk(MMINIT_TRACE, "memory_register",
+			"Entering add_active_range(%d, %lu, %lu) "
 			  "%d entries of %d used\n",
 			  nid, start_pfn, end_pfn,
 			  nr_nodemap_entries, MAX_ACTIVE_REGIONS);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
