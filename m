Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 519856B02C3
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:03:02 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:03:01 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id B0BF419D8052
	for <linux-mm@kvack.org>; Thu,  2 May 2013 18:01:23 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301ML5097330
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:25 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301Mqe001973
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:22 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 11/31] page-flags dnuma: reserve a pageflag for determining if a page needs a node lookup.
Date: Thu,  2 May 2013 17:00:43 -0700
Message-Id: <1367539263-19999-12-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Add a pageflag called "lookup_node"/ PG_lookup_node / Page*LookupNode().

Used by dynamic numa to indicate when a page has a new node assignment
waiting for it.

FIXME: This also exempts PG_lookup_node from PAGE_FLAGS_CHECK_AT_PREP
due to the asynchronous usage of PG_lookup_node, which needs to be
avoided.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/page-flags.h | 19 +++++++++++++++++++
 mm/page_alloc.c            |  3 +++
 2 files changed, 22 insertions(+)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6d53675..09dd94e 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -109,6 +109,9 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+#ifdef CONFIG_DYNAMIC_NUMA
+	PG_lookup_node,		/* extra lookup required to find real node */
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
@@ -509,7 +523,12 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
  * Pages being prepped should not have any flags set.  It they are set,
  * there has been a kernel bug or struct page corruption.
  */
+#ifndef CONFIG_DYNAMIC_NUMA
 #define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
+#else
+#define PAGE_FLAGS_CHECK_AT_PREP	(((1 << NR_PAGEFLAGS) - 1) \
+						& ~(1 << PG_lookup_node))
+#endif
 
 #define PAGE_FLAGS_PRIVATE				\
 	(1 << PG_private | 1 << PG_private_2)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9de55a2..ea4fda8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6238,6 +6238,9 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
+#ifdef CONFIG_DYNAMIC_NUMA
+	{1UL << PG_lookup_node,		"lookup_node"   },
+#endif
 };
 
 static void dump_page_flags(unsigned long flags)
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
