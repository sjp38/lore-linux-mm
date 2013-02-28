Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 9EB4A6B0008
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:05 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 16:27:04 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 062ECC9001D
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:03 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLR1Qg300094
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:02 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLQvlE019001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:26:58 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 13/24] page-flags dnuma: reserve a pageflag for determining if a page needs a node lookup.
Date: Thu, 28 Feb 2013 13:26:10 -0800
Message-Id: <1362086781-16725-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

Add a pageflag called "lookup_node"/ PG_lookup_node / Page*LookupNode().

Used by dynamic numa to indicate when a page has a new node assignment
waiting for it.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/page-flags.h | 18 ++++++++++++++++++
 mm/page_alloc.c            |  3 +++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6d53675..e0241d8 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -109,6 +109,9 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+#ifdef CONFIG_DYNAMIC_NUMA
+	PG_lookup_node,		/* need to do an extra lookup to determine actual node */
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -275,6 +278,17 @@ PAGEFLAG_FALSE(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
+/* Setting is unconditional, simply leads to an extra lookup.
+ * Clearing must be conditional so we don't miss any memlayout changes.
+ */
+#ifdef CONFIG_DYNAMIC_NUMA
+PAGEFLAG(LookupNode, lookup_node)
+TESTCLEARFLAG(LookupNode, lookup_node)
+#else
+PAGEFLAG_FALSE(LookupNode)
+TESTCLEARFLAG_FALSE(LookupNode)
+#endif
+
 u64 stable_page_flags(struct page *page);
 
 static inline int PageUptodate(struct page *page)
@@ -509,7 +523,11 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
  * Pages being prepped should not have any flags set.  It they are set,
  * there has been a kernel bug or struct page corruption.
  */
+#ifndef CONFIG_DYNAMIC_NUMA
 #define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
+#else
+#define PAGE_FLAGS_CHECK_AT_PREP	(((1 << NR_PAGEFLAGS) - 1) & ~(1 << PG_lookup_node))
+#endif
 
 #define PAGE_FLAGS_PRIVATE				\
 	(1 << PG_private | 1 << PG_private_2)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 274826c..5eeb547 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6449,6 +6449,9 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
+#ifdef CONFIG_DYNAMIC_NUMA
+	{1UL << PG_lookup_node,		"lookup_node"   },
+#endif
 };
 
 static void dump_page_flags(unsigned long flags)
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
