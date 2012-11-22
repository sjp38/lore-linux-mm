Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 4B8016B0096
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:50:46 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so6043409eek.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:50:45 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 08/33] sched, numa, mm: Add last_cpu to page flags
Date: Thu, 22 Nov 2012 23:49:29 +0100
Message-Id: <1353624594-1118-9-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Introduce a per-page last_cpu field, fold this into the struct
page::flags field whenever possible.

The unlikely/rare 32bit NUMA configs will likely grow the page-frame.

[ Completely dropping 32bit support for CONFIG_NUMA_BALANCING would simplify
  things, but it would also remove the warning if we grow enough 64bit
  only page-flags to push the last-cpu out. ]

Suggested-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mm.h                | 90 +++++++++++++++++++++------------------
 include/linux/mm_types.h          |  5 +++
 include/linux/mmzone.h            | 14 +-----
 include/linux/page-flags-layout.h | 83 ++++++++++++++++++++++++++++++++++++
 kernel/bounds.c                   |  4 ++
 mm/memory.c                       |  4 ++
 6 files changed, 146 insertions(+), 54 deletions(-)
 create mode 100644 include/linux/page-flags-layout.h

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8d86d5a..5fc1d46 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -581,50 +581,11 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
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
+/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_CPU] | ... | FLAGS | */
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
+#define LAST_CPU_PGOFF		(ZONES_PGOFF - LAST_CPU_WIDTH)
 
 /*
  * Define the bit shifts to access each section.  For non-existent
@@ -634,6 +595,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
 #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
 #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
+#define LAST_CPU_PGSHIFT	(LAST_CPU_PGOFF * (LAST_CPU_WIDTH != 0))
 
 /* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allocator */
 #ifdef NODE_NOT_IN_PAGE_FLAGS
@@ -655,6 +617,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
+#define LAST_CPU_MASK		((1UL << LAST_CPU_WIDTH) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
 static inline enum zone_type page_zonenum(const struct page *page)
@@ -693,6 +656,51 @@ static inline int page_to_nid(const struct page *page)
 }
 #endif
 
+#ifdef CONFIG_NUMA_BALANCING
+#ifdef LAST_CPU_NOT_IN_PAGE_FLAGS
+static inline int page_xchg_last_cpu(struct page *page, int cpu)
+{
+	return xchg(&page->_last_cpu, cpu);
+}
+
+static inline int page_last_cpu(struct page *page)
+{
+	return page->_last_cpu;
+}
+#else
+static inline int page_xchg_last_cpu(struct page *page, int cpu)
+{
+	unsigned long old_flags, flags;
+	int last_cpu;
+
+	do {
+		old_flags = flags = page->flags;
+		last_cpu = (flags >> LAST_CPU_PGSHIFT) & LAST_CPU_MASK;
+
+		flags &= ~(LAST_CPU_MASK << LAST_CPU_PGSHIFT);
+		flags |= (cpu & LAST_CPU_MASK) << LAST_CPU_PGSHIFT;
+	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
+
+	return last_cpu;
+}
+
+static inline int page_last_cpu(struct page *page)
+{
+	return (page->flags >> LAST_CPU_PGSHIFT) & LAST_CPU_MASK;
+}
+#endif /* LAST_CPU_NOT_IN_PAGE_FLAGS */
+#else /* CONFIG_NUMA_BALANCING */
+static inline int page_xchg_last_cpu(struct page *page, int cpu)
+{
+	return page_to_nid(page);
+}
+
+static inline int page_last_cpu(struct page *page)
+{
+	return page_to_nid(page);
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 static inline struct zone *page_zone(const struct page *page)
 {
 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 31f8a3a..7e9f758 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
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
+#ifdef LAST_CPU_NOT_IN_PAGE_FLAGS
+	int _last_cpu;
+#endif
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 50aaca8..7e116ed 100644
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
 
@@ -318,16 +318,6 @@ enum zone_type {
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
 
@@ -1030,8 +1020,6 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
  * PA_SECTION_SHIFT		physical address to/from section number
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
-#define SECTIONS_SHIFT		(MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)
-
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
 #define PFN_SECTION_SHIFT	(SECTION_SIZE_BITS - PAGE_SHIFT)
 
diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
new file mode 100644
index 0000000..b258132
--- /dev/null
+++ b/include/linux/page-flags-layout.h
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
+ *     "      plus space for last_cpu:|       NODE     | ZONE | LAST_CPU | ... | FLAGS |
+ * classic sparse with space for node:| SECTION | NODE | ZONE |            ... | FLAGS |
+ *     "      plus space for last_cpu:| SECTION | NODE | ZONE | LAST_CPU | ... | FLAGS |
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
+#ifdef CONFIG_NUMA_BALANCING
+#define LAST_CPU_SHIFT	NR_CPUS_BITS
+#else
+#define LAST_CPU_SHIFT	0
+#endif
+
+#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPU_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
+#define LAST_CPU_WIDTH	LAST_CPU_SHIFT
+#else
+#define LAST_CPU_WIDTH	0
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
+#if defined(CONFIG_NUMA_BALANCING) && LAST_CPU_WIDTH == 0
+#define LAST_CPU_NOT_IN_PAGE_FLAGS
+#endif
+
+#endif /* _LINUX_PAGE_FLAGS_LAYOUT */
diff --git a/kernel/bounds.c b/kernel/bounds.c
index 0c9b862..e8ca97b 100644
--- a/kernel/bounds.c
+++ b/kernel/bounds.c
@@ -10,6 +10,7 @@
 #include <linux/mmzone.h>
 #include <linux/kbuild.h>
 #include <linux/page_cgroup.h>
+#include <linux/log2.h>
 
 void foo(void)
 {
@@ -17,5 +18,8 @@ void foo(void)
 	DEFINE(NR_PAGEFLAGS, __NR_PAGEFLAGS);
 	DEFINE(MAX_NR_ZONES, __MAX_NR_ZONES);
 	DEFINE(NR_PCG_FLAGS, __NR_PCG_FLAGS);
+#ifdef CONFIG_SMP
+	DEFINE(NR_CPUS_BITS, ilog2(CONFIG_NR_CPUS));
+#endif
 	/* End of constants */
 }
diff --git a/mm/memory.c b/mm/memory.c
index fb135ba..24d3a4a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -67,6 +67,10 @@
 
 #include "internal.h"
 
+#ifdef LAST_CPU_NOT_IN_PAGE_FLAGS
+#warning Unfortunate NUMA config, growing page-frame for last_cpu.
+#endif
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
