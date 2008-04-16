From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080416135118.1346.72244.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
References: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/4] Add a basic debugging framework for memory initialisation
Date: Wed, 16 Apr 2008 14:51:18 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch creates a new file mm/mm_init.c which memory initialisation should
be moved to over time to avoid further polluting page_alloc.c. This patch
introduces a simple mminit_debug_printk() function and an (undocumented)
mminit_debug_level commmand-line parameter for setting the level of tracing
and verification that should be done.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 mm/Makefile     |    2 +-
 mm/internal.h   |    9 +++++++++
 mm/mm_init.c    |   40 ++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c |   16 ++++++++++------
 4 files changed, 60 insertions(+), 7 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/mm/internal.h linux-2.6.25-rc9-0010_mminit_debug_framework/mm/internal.h
--- linux-2.6.25-rc9-clean/mm/internal.h	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-0010_mminit_debug_framework/mm/internal.h	2008-04-16 14:44:19.000000000 +0100
@@ -60,4 +60,13 @@ static inline unsigned long page_order(s
 #define __paginginit __init
 #endif
 
+/* Memory initilisation debug and verification */
+enum mminit_levels {
+	MMINIT_NORMAL,
+	MMINIT_VERIFY,
+	MMINIT_TRACE
+};
+
+extern void mminit_debug_printk(unsigned int level, const char *prefix,
+				const char *fmt, ...);
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/mm/Makefile linux-2.6.25-rc9-0010_mminit_debug_framework/mm/Makefile
--- linux-2.6.25-rc9-clean/mm/Makefile	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-0010_mminit_debug_framework/mm/Makefile	2008-04-16 14:44:19.000000000 +0100
@@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o $(mmu-y)
+			   page_isolation.o mm_init.o $(mmu-y)
 
 obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
 obj-$(CONFIG_BOUNCE)	+= bounce.o
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/mm/mm_init.c linux-2.6.25-rc9-0010_mminit_debug_framework/mm/mm_init.c
--- linux-2.6.25-rc9-clean/mm/mm_init.c	2008-04-16 10:42:54.000000000 +0100
+++ linux-2.6.25-rc9-0010_mminit_debug_framework/mm/mm_init.c	2008-04-16 14:44:19.000000000 +0100
@@ -0,0 +1,40 @@
+/*
+ * mm_init.c - Memory initialisation verification and debugging
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/init.h>
+
+int __initdata mminit_debug_level;
+
+#define MMINIT_BUF_LEN 256
+
+void __meminit mminit_debug_printk(unsigned int level, const char *prefix,
+			const char *fmt, ...)
+{
+	char s[MMINIT_BUF_LEN];
+	va_list args;
+	unsigned int len;
+
+	WARN_ON(!prefix);
+	if (level < mminit_debug_level) {
+		len = snprintf(s, MMINIT_BUF_LEN, KERN_INFO "mminit::%s ",
+								prefix);
+
+		va_start(args, fmt);
+		len += vsnprintf(&s[len], (MMINIT_BUF_LEN - len), fmt, args);
+		va_end(args);
+
+		printk(s);
+
+		WARN_ON(len < 5);
+		WARN_ON(len == MMINIT_BUF_LEN);
+	}
+}
+
+static __init int set_mminit_debug_level(char *str)
+{
+	get_option(&str, &mminit_debug_level);
+	return 0;
+}
+early_param("mminit_debug_level", set_mminit_debug_level);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/mm/page_alloc.c linux-2.6.25-rc9-0010_mminit_debug_framework/mm/page_alloc.c
--- linux-2.6.25-rc9-clean/mm/page_alloc.c	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-0010_mminit_debug_framework/mm/page_alloc.c	2008-04-16 14:44:19.000000000 +0100
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
