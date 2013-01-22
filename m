Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 0BA586B0011
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 12:12:43 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/6] mm: Move page flags layout to separate header
Date: Tue, 22 Jan 2013 17:12:40 +0000
Message-Id: <1358874762-19717-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1358874762-19717-1-git-send-email-mgorman@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

This is a preparation patch for moving page->_last_nid into page->flags
that moves page flag layout information to a separate header. This patch
is necessary because otherwise there would be a circular dependency
between mm_types.h and mm.h.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm.h                |   40 ---------------------
 include/linux/mm_types.h          |    1 +
 include/linux/mmzone.h            |   22 +-----------
 include/linux/page-flags-layout.h |   71 +++++++++++++++++++++++++++++++++++++
 4 files changed, 73 insertions(+), 61 deletions(-)
 create mode 100644 include/linux/page-flags-layout.h

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 66e2f7c..87420e6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -580,52 +580,12 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
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
 /* Page flags: | [SECTION] | [NODE] | ZONE | ... | FLAGS | */
 #define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
 #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
 #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
 
 /*
- * We are going to use the flags for the page to node mapping if its in
- * there.  This includes the case where there is no node, so it is implicit.
- */
-#if !(NODES_WIDTH > 0 || NODES_SHIFT == 0)
-#define NODE_NOT_IN_PAGE_FLAGS
-#endif
-
-/*
  * Define the bit shifts to access each section.  For non-existent
  * sections we define the shift as 0; that plus a 0 mask ensures
  * the compiler will optimise away reference to them.
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 47047cb..d05d632 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
+#include <linux/page-flags-layout.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 73b64a3..5e6a814 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -15,7 +15,7 @@
 #include <linux/seqlock.h>
 #include <linux/nodemask.h>
 #include <linux/pageblock-flags.h>
-#include <generated/bounds.h>
+#include <linux/page-flags-layout.h>
 #include <linux/atomic.h>
 #include <asm/page.h>
 
@@ -308,24 +308,6 @@ enum zone_type {
 
 #ifndef __GENERATING_BOUNDS_H
 
-/*
- * When a memory allocation must conform to specific limitations (such
- * as being suitable for DMA) the caller will pass in hints to the
- * allocator in the gfp_mask, in the zone modifier bits.  These bits
- * are used to select a priority ordered list of memory zones which
- * match the requested limits. See gfp_zone() in include/linux/gfp.h
- */
-
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
 
@@ -1053,8 +1035,6 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
  * PA_SECTION_SHIFT		physical address to/from section number
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
-#define SECTIONS_SHIFT		(MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)
-
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
 #define PFN_SECTION_SHIFT	(SECTION_SIZE_BITS - PAGE_SHIFT)
 
diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
new file mode 100644
index 0000000..316805d
--- /dev/null
+++ b/include/linux/page-flags-layout.h
@@ -0,0 +1,71 @@
+#ifndef PAGE_FLAGS_LAYOUT_H
+#define PAGE_FLAGS_LAYOUT_H
+
+#include <linux/numa.h>
+#include <generated/bounds.h>
+
+/*
+ * When a memory allocation must conform to specific limitations (such
+ * as being suitable for DMA) the caller will pass in hints to the
+ * allocator in the gfp_mask, in the zone modifier bits.  These bits
+ * are used to select a priority ordered list of memory zones which
+ * match the requested limits. See gfp_zone() in include/linux/gfp.h
+ */
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
+/* SECTION_SHIFT	#bits space required to store a section # */
+#define SECTIONS_SHIFT	(MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)
+
+#endif /* CONFIG_SPARSEMEM */
+
+/*
+ * page->flags layout:
+ *
+ * There are three possibilities for how page->flags get
+ * laid out.  The first is for the normal case, without
+ * sparsemem.  The second is for sparsemem when there is
+ * plenty of space for node and section.  The last is when
+ * we have run out of space and have to fall back to an
+ * alternate (slower) way of determining the node.
+ *
+ * No sparsemem or sparsemem vmemmap: |       NODE     | ZONE | ... | FLAGS |
+ * classic sparse with space for node:| SECTION | NODE | ZONE | ... | FLAGS |
+ * classic sparse no space for node:  | SECTION |     ZONE    | ... | FLAGS |
+ */
+#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
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
+/*
+ * We are going to use the flags for the page to node mapping if its in
+ * there.  This includes the case where there is no node, so it is implicit.
+ */
+#if !(NODES_WIDTH > 0 || NODES_SHIFT == 0)
+#define NODE_NOT_IN_PAGE_FLAGS
+#endif
+
+#endif /* _LINUX_PAGE_FLAGS_LAYOUT */
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
