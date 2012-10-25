Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 606A16B0088
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:09:24 -0400 (EDT)
Message-Id: <20121025124834.312153519@chello.nl>
Date: Thu, 25 Oct 2012 14:16:41 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 24/31] sched, numa, mm: Introduce last_nid in the pageframe
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0024-sched-numa-mm-Fold-page-nid_last-into-page-flags-whe.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

Introduce a per-page last_nid field, fold this into the struct
page::flags field whenever possible.

The unlikely/rare 32bit NUMA configs will likely grow the page-frame.

Completely dropping 32bit support for CONFIG_SCHED_NUMA would simplify
things, but it would also remove the warning if we grow enough 64bit
only page-flags to push the last-nid out.

Suggested-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mm.h                |   90 ++++++++++++++++++++------------------
 include/linux/mm_types.h          |    5 ++
 include/linux/mmzone.h            |   14 -----
 include/linux/page-flags-layout.h |   83 +++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                  |    1 
 mm/memory.c                       |    4 +
 6 files changed, 143 insertions(+), 54 deletions(-)
 create mode 100644 include/linux/page-flags-layout.h

Index: tip/include/linux/mm.h
===================================================================
--- tip.orig/include/linux/mm.h
+++ tip/include/linux/mm.h
@@ -594,50 +594,11 @@ static inline pte_t maybe_mkwrite(pte_t
  * sets it, so none of the operations on it need to be atomic.
  */
 
-
-/*
- * page->flags layout:
- *
- * There are three possibilities for how page->flags get
- * laid out.  The first is for the normal case, without
- * sparsemem.  The second is for sparsemem when there is
- * plenty of space for node and section.  The last is when
- * we have run out of space and have to fall back to an
- * alternate (slower) way of determining the node.
- *
- * No sparsemem or sparsemem vmemmap: |       NODE     | ZONE | ... | FLAGS |
- * classic sparse with space for node:| SECTION | NODE | ZONE | ... | FLAGS |
- * classic sparse no space for node:  | SECTION |     ZONE    | ... | FLAGS |
- */
-#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
-#define SECTIONS_WIDTH		SECTIONS_SHIFT
-#else
-#define SECTIONS_WIDTH		0
-#endif
-
-#define ZONES_WIDTH		ZONES_SHIFT
-
-#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
-#define NODES_WIDTH		NODES_SHIFT
-#else
-#ifdef CONFIG_SPARSEMEM_VMEMMAP
-#error "Vmemmap: No space for nodes field in page flags"
-#endif
-#define NODES_WIDTH		0
-#endif
-
-/* Page flags: | [SECTION] | [NODE] | ZONE | ... | FLAGS | */
+/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_NID] | ... | FLAGS | */
 #define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
 #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
 #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
-
-/*
- * We are going to use the flags for the page to node mapping if its in
- * there.  This includes the case where there is no node, so it is implicit.
- */
-#if !(NODES_WIDTH > 0 || NODES_SHIFT == 0)
-#define NODE_NOT_IN_PAGE_FLAGS
-#endif
+#define LAST_NID_PGOFF		(ZONES_PGOFF - LAST_NID_WIDTH)
 
 /*
  * Define the bit shifts to access each section.  For non-existent
@@ -647,6 +608,7 @@ static inline pte_t maybe_mkwrite(pte_t
 #define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
 #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
 #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
+#define LAST_NID_PGSHIFT	(LAST_NID_PGOFF * (LAST_NID_WIDTH != 0))
 
 /* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allocator */
 #ifdef NODE_NOT_IN_PAGE_FLAGS
@@ -668,6 +630,7 @@ static inline pte_t maybe_mkwrite(pte_t
 #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
+#define LAST_NID_MASK		((1UL << LAST_NID_WIDTH) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
 static inline enum zone_type page_zonenum(const struct page *page)
@@ -706,6 +669,51 @@ static inline int page_to_nid(const stru
 }
 #endif
 
+#ifdef CONFIG_SCHED_NUMA
+#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
+static inline int page_xchg_last_nid(struct page *page, int nid)
+{
+	return xchg(&page->_last_nid, nid);
+}
+
+static inline int page_last_nid(struct page *page)
+{
+	return page->_last_nid;
+}
+#else
+static inline int page_xchg_last_nid(struct page *page, int nid)
+{
+	unsigned long old_flags, flags;
+	int last_nid;
+
+	do {
+		old_flags = flags = page->flags;
+		last_nid = (flags >> LAST_NID_PGSHIFT) & LAST_NID_MASK;
+
+		flags &= ~(LAST_NID_MASK << LAST_NID_PGSHIFT);
+		flags |= (nid & LAST_NID_MASK) << LAST_NID_PGSHIFT;
+	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
+
+	return last_nid;
+}
+
+static inline int page_last_nid(struct page *page)
+{
+	return (page->flags >> LAST_NID_PGSHIFT) & LAST_NID_MASK;
+}
+#endif /* LAST_NID_NOT_IN_PAGE_FLAGS */
+#else /* CONFIG_SCHED_NUMA */
+static inline int page_xchg_last_nid(struct page *page, int nid)
+{
+	return page_to_nid(page);
+}
+
+static inline int page_last_nid(struct page *page)
+{
+	return page_to_nid(page);
+}
+#endif /* CONFIG_SCHED_NUMA */
+
 static inline struct zone *page_zone(const struct page *page)
 {
 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
Index: tip/include/linux/mm_types.h
===================================================================
--- tip.orig/include/linux/mm_types.h
+++ tip/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
+#include <linux/page-flags-layout.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -175,6 +176,10 @@ struct page {
 	 */
 	void *shadow;
 #endif
+
+#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
+	int _last_nid;
+#endif
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
Index: tip/include/linux/mmzone.h
===================================================================
--- tip.orig/include/linux/mmzone.h
+++ tip/include/linux/mmzone.h
@@ -15,7 +15,7 @@
 #include <linux/seqlock.h>
 #include <linux/nodemask.h>
 #include <linux/pageblock-flags.h>
-#include <generated/bounds.h>
+#include <linux/page-flags-layout.h>
 #include <linux/atomic.h>
 #include <asm/page.h>
 
@@ -317,16 +317,6 @@ enum zone_type {
  * match the requested limits. See gfp_zone() in include/linux/gfp.h
  */
 
-#if MAX_NR_ZONES < 2
-#define ZONES_SHIFT 0
-#elif MAX_NR_ZONES <= 2
-#define ZONES_SHIFT 1
-#elif MAX_NR_ZONES <= 4
-#define ZONES_SHIFT 2
-#else
-#error ZONES_SHIFT -- too many zones configured adjust calculation
-#endif
-
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 
@@ -1029,8 +1019,6 @@ static inline unsigned long early_pfn_to
  * PA_SECTION_SHIFT		physical address to/from section number
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
-#define SECTIONS_SHIFT		(MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)
-
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
 #define PFN_SECTION_SHIFT	(SECTION_SIZE_BITS - PAGE_SHIFT)
 
Index: tip/include/linux/page-flags-layout.h
===================================================================
--- /dev/null
+++ tip/include/linux/page-flags-layout.h
@@ -0,0 +1,83 @@
+#ifndef _LINUX_PAGE_FLAGS_LAYOUT
+#define _LINUX_PAGE_FLAGS_LAYOUT
+
+#include <linux/numa.h>
+#include <generated/bounds.h>
+
+#if MAX_NR_ZONES < 2
+#define ZONES_SHIFT 0
+#elif MAX_NR_ZONES <= 2
+#define ZONES_SHIFT 1
+#elif MAX_NR_ZONES <= 4
+#define ZONES_SHIFT 2
+#else
+#error ZONES_SHIFT -- too many zones configured adjust calculation
+#endif
+
+#ifdef CONFIG_SPARSEMEM
+#include <asm/sparsemem.h>
+
+/* 
+ * SECTION_SHIFT    		#bits space required to store a section #
+ */
+#define SECTIONS_SHIFT         (MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)
+#endif
+
+/*
+ * page->flags layout:
+ *
+ * There are five possibilities for how page->flags get laid out.  The first
+ * (and second) is for the normal case, without sparsemem. The third is for
+ * sparsemem when there is plenty of space for node and section. The last is
+ * when we have run out of space and have to fall back to an alternate (slower)
+ * way of determining the node.
+ *
+ * No sparsemem or sparsemem vmemmap: |       NODE     | ZONE |            ... | FLAGS |
+ *     "      plus space for last_nid:|       NODE     | ZONE | LAST_NID | ... | FLAGS |
+ * classic sparse with space for node:| SECTION | NODE | ZONE |            ... | FLAGS |
+ *     "      plus space for last_nid:| SECTION | NODE | ZONE | LAST_NID | ... | FLAGS |
+ * classic sparse no space for node:  | SECTION |     ZONE    |            ... | FLAGS |
+ */
+#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
+
+#define SECTIONS_WIDTH		SECTIONS_SHIFT
+#else
+#define SECTIONS_WIDTH		0
+#endif
+
+#define ZONES_WIDTH		ZONES_SHIFT
+
+#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
+#define NODES_WIDTH		NODES_SHIFT
+#else
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+#error "Vmemmap: No space for nodes field in page flags"
+#endif
+#define NODES_WIDTH		0
+#endif
+
+#ifdef CONFIG_SCHED_NUMA
+#define LAST_NID_SHIFT	NODES_SHIFT
+#else
+#define LAST_NID_SHIFT	0
+#endif
+
+#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_NID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
+#define LAST_NID_WIDTH	LAST_NID_SHIFT
+#else
+#define LAST_NID_WIDTH	0
+#endif
+
+/*
+ * We are going to use the flags for the page to node mapping if its in
+ * there.  This includes the case where there is no node, so it is implicit.
+ */
+#if !(NODES_WIDTH > 0 || NODES_SHIFT == 0)
+#define NODE_NOT_IN_PAGE_FLAGS
+#endif
+
+#if defined(CONFIG_SCHED_NUMA) && LAST_NID_WIDTH == 0
+#define LAST_NID_NOT_IN_PAGE_FLAGS
+#endif
+
+#endif /* _LINUX_PAGE_FLAGS_LAYOUT */
Index: tip/mm/huge_memory.c
===================================================================
--- tip.orig/mm/huge_memory.c
+++ tip/mm/huge_memory.c
@@ -1440,6 +1440,7 @@ static void __split_huge_page_refcount(s
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
+		page_xchg_last_nid(page, page_last_nid(page_tail));
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
Index: tip/mm/memory.c
===================================================================
--- tip.orig/mm/memory.c
+++ tip/mm/memory.c
@@ -68,6 +68,10 @@
 
 #include "internal.h"
 
+#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
+#warning Unfortunate NUMA config, growing page-frame for last_nid.
+#endif
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
