Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 493F45F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 11:10:08 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
Subject: [PATCH] [5/16] POISON: Add support for poison swap entries
Message-Id: <20090407151002.0AA8F1D046E@basil.firstfloor.org>
Date: Tue,  7 Apr 2009 17:10:01 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


CPU migration uses special swap entry types to trigger special actions on page
faults. Extend this mechanism to also support poisoned swap entries, to trigger
poison handling on page faults. This allows followon patches to prevent 
processes from faulting in poisoned pages again.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/swap.h    |   34 ++++++++++++++++++++++++++++------
 include/linux/swapops.h |   38 ++++++++++++++++++++++++++++++++++++++
 mm/swapfile.c           |    4 ++--
 3 files changed, 68 insertions(+), 8 deletions(-)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2009-04-07 16:39:25.000000000 +0200
+++ linux/include/linux/swap.h	2009-04-07 16:39:39.000000000 +0200
@@ -34,16 +34,38 @@
  * the type/offset into the pte as 5/27 as well.
  */
 #define MAX_SWAPFILES_SHIFT	5
-#ifndef CONFIG_MIGRATION
-#define MAX_SWAPFILES		(1 << MAX_SWAPFILES_SHIFT)
+
+/*
+ * Use some of the swap files numbers for other purposes. This
+ * is a convenient way to hook into the VM to trigger special
+ * actions on faults.
+ */
+
+/*
+ * NUMA node memory migration support
+ */
+#ifdef CONFIG_MIGRATION
+#define SWP_MIGRATION_NUM 2
+#define SWP_MIGRATION_READ	(MAX_SWAPFILES + SWP_POISON_NUM + 1)
+#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + SWP_POISON_NUM + 2)
 #else
-/* Use last two entries for page migration swap entries */
-#define MAX_SWAPFILES		((1 << MAX_SWAPFILES_SHIFT)-2)
-#define SWP_MIGRATION_READ	MAX_SWAPFILES
-#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + 1)
+#define SWP_MIGRATION_NUM 0
 #endif
 
 /*
+ * Handling of poisoned pages with memory corruption.
+ */
+#ifdef CONFIG_MEMORY_FAILURE
+#define SWP_POISON_NUM 1
+#define SWP_POISON 		(MAX_SWAPFILES + 1)
+#else
+#define SWP_POISON_NUM 0
+#endif
+
+#define MAX_SWAPFILES \
+	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_POISON_NUM)
+
+/*
  * Magic header for a swap area. The first part of the union is
  * what the swap magic looks like for the old (limited to 128MB)
  * swap area format, the second part of the union adds - in the
Index: linux/include/linux/swapops.h
===================================================================
--- linux.orig/include/linux/swapops.h	2009-04-07 16:39:25.000000000 +0200
+++ linux/include/linux/swapops.h	2009-04-07 16:39:39.000000000 +0200
@@ -131,3 +131,41 @@
 
 #endif
 
+#ifdef CONFIG_MEMORY_FAILURE
+/*
+ * Support for poisoned pages
+ */
+static inline swp_entry_t make_poison_entry(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+	return swp_entry(SWP_POISON, page_to_pfn(page));
+}
+
+static inline int is_poison_entry(swp_entry_t entry)
+{
+	return swp_type(entry) == SWP_POISON;
+}
+#else
+
+static inline swp_entry_t make_poison_entry(struct page *page)
+{
+	return swp_entry(0, 0);
+}
+
+static inline int is_poison_entry(swp_entry_t swp)
+{
+	return 0;
+}
+#endif
+
+#if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION)
+static inline int non_swap_entry(swp_entry_t entry)
+{
+	return swp_type(entry) > MAX_SWAPFILES;
+}
+#else
+static inline int non_swap_entry(swp_entry_t entry)
+{
+	return 0;
+}
+#endif
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2009-04-07 16:39:25.000000000 +0200
+++ linux/mm/swapfile.c	2009-04-07 16:39:39.000000000 +0200
@@ -579,7 +579,7 @@
 	struct swap_info_struct *p;
 	struct page *page = NULL;
 
-	if (is_migration_entry(entry))
+	if (non_swap_entry(entry))
 		return 1;
 
 	p = swap_info_get(entry);
@@ -1949,7 +1949,7 @@
 	unsigned long offset, type;
 	int result = 0;
 
-	if (is_migration_entry(entry))
+	if (non_swap_entry(entry))
 		return 1;
 
 	type = swp_type(entry);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
