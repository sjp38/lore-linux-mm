Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2B53F5F0003
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 11:09:56 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
Subject: [PATCH] [2/16] POISON: Add page flag for poisoned pages
Message-Id: <20090407150958.BA68F1D046D@basil.firstfloor.org>
Date: Tue,  7 Apr 2009 17:09:58 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Poisoned pages need special handling in the VM and shouldn't be touched 
again. This requires a new page flag. Define it here.

The page flags wars seem to be over, so it shouldn't be a problem
to get a new one. I hope.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/page-flags.h |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

Index: linux/include/linux/page-flags.h
===================================================================
--- linux.orig/include/linux/page-flags.h	2009-04-07 16:39:27.000000000 +0200
+++ linux/include/linux/page-flags.h	2009-04-07 16:39:39.000000000 +0200
@@ -51,6 +51,9 @@
  * PG_buddy is set to indicate that the page is free and in the buddy system
  * (see mm/page_alloc.c).
  *
+ * PG_poison indicates that a page got corrupted in hardware and contains
+ * data with incorrect ECC bits that triggered a machine check. Accessing is
+ * not safe since it may cause another machine check. Don't touch!
  */
 
 /*
@@ -104,6 +107,9 @@
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	PG_uncached,		/* Page has been mapped as uncached */
 #endif
+#ifdef CONFIG_MEMORY_FAILURE
+	PG_poison,		/* poisoned page. Don't touch */
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -273,6 +279,14 @@
 PAGEFLAG_FALSE(Uncached)
 #endif
 
+#ifdef CONFIG_MEMORY_FAILURE
+PAGEFLAG(Poison, poison)
+#define __PG_POISON (1UL << PG_poison)
+#else
+PAGEFLAG_FALSE(Poison)
+#define __PG_POISON 0
+#endif
+
 static inline int PageUptodate(struct page *page)
 {
 	int ret = test_bit(PG_uptodate, &(page)->flags);
@@ -403,7 +417,7 @@
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 __PG_UNEVICTABLE | __PG_MLOCKED)
+	 __PG_POISON  | __PG_UNEVICTABLE | __PG_MLOCKED)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
