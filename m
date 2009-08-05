Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E4BC56B007E
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:36:30 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200908051136.682859934@firstfloor.org>
In-Reply-To: <200908051136.682859934@firstfloor.org>
Subject: [PATCH] [1/19] HWPOISON: Add page flag for poisoned pages
Message-Id: <20090805093628.B90C3B15D8@basil.firstfloor.org>
Date: Wed,  5 Aug 2009 11:36:28 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>


Hardware poisoned pages need special handling in the VM and shouldn't be 
touched again. This requires a new page flag. Define it here.

The page flags wars seem to be over, so it shouldn't be a problem
to get a new one.

v2: Add TestSetHWPoison (suggested by Johannes Weiner)

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/page-flags.h |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

Index: linux/include/linux/page-flags.h
===================================================================
--- linux.orig/include/linux/page-flags.h
+++ linux/include/linux/page-flags.h
@@ -51,6 +51,9 @@
  * PG_buddy is set to indicate that the page is free and in the buddy system
  * (see mm/page_alloc.c).
  *
+ * PG_hwpoison indicates that a page got corrupted in hardware and contains
+ * data with incorrect ECC bits that triggered a machine check. Accessing is
+ * not safe since it may cause another machine check. Don't touch!
  */
 
 /*
@@ -102,6 +105,9 @@ enum pageflags {
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	PG_uncached,		/* Page has been mapped as uncached */
 #endif
+#ifdef CONFIG_MEMORY_FAILURE
+	PG_hwpoison,		/* hardware poisoned page. Don't touch */
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -263,6 +269,15 @@ PAGEFLAG(Uncached, uncached)
 PAGEFLAG_FALSE(Uncached)
 #endif
 
+#ifdef CONFIG_MEMORY_FAILURE
+PAGEFLAG(HWPoison, hwpoison)
+TESTSETFLAG(HWPoison, hwpoison)
+#define __PG_HWPOISON (1UL << PG_hwpoison)
+#else
+PAGEFLAG_FALSE(HWPoison)
+#define __PG_HWPOISON 0
+#endif
+
 static inline int PageUptodate(struct page *page)
 {
 	int ret = test_bit(PG_uptodate, &(page)->flags);
@@ -387,7 +402,7 @@ static inline void __ClearPageTail(struc
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 1 << PG_unevictable | __PG_MLOCKED)
+	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
