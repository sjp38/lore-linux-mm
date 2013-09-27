Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7868A900023
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:35 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so2773244pab.38
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:34 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 42/63] mm: numa: Change page last {nid,pid} into {cpu,pid}
Date: Fri, 27 Sep 2013 14:27:27 +0100
Message-Id: <1380288468-5551-43-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <peterz@infradead.org>

Change the per page last fault tracking to use cpu,pid instead of
nid,pid. This will allow us to try and lookup the alternate task more
easily. Note that even though it is the cpu that is store in the page
flags that the mpol_misplaced decision is still based on the node.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm.h                | 90 ++++++++++++++++++++++-----------------
 include/linux/mm_types.h          |  4 +-
 include/linux/page-flags-layout.h | 22 +++++-----
 kernel/bounds.c                   |  4 ++
 kernel/sched/fair.c               |  6 +--
 mm/huge_memory.c                  |  8 ++--
 mm/memory.c                       | 16 +++----
 mm/mempolicy.c                    | 16 ++++---
 mm/migrate.c                      |  4 +-
 mm/mm_init.c                      | 18 ++++----
 mm/mmzone.c                       | 14 +++---
 mm/mprotect.c                     | 28 ++++++------
 mm/page_alloc.c                   |  4 +-
 13 files changed, 125 insertions(+), 109 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0a0db6c..61dc023 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -588,11 +588,11 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
  * sets it, so none of the operations on it need to be atomic.
  */
 
-/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_NIDPID] | ... | FLAGS | */
+/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_CPUPID] | ... | FLAGS | */
 #define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
 #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
 #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
-#define LAST_NIDPID_PGOFF	(ZONES_PGOFF - LAST_NIDPID_WIDTH)
+#define LAST_CPUPID_PGOFF	(ZONES_PGOFF - LAST_CPUPID_WIDTH)
 
 /*
  * Define the bit shifts to access each section.  For non-existent
@@ -602,7 +602,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
 #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
 #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
-#define LAST_NIDPID_PGSHIFT	(LAST_NIDPID_PGOFF * (LAST_NIDPID_WIDTH != 0))
+#define LAST_CPUPID_PGSHIFT	(LAST_CPUPID_PGOFF * (LAST_CPUPID_WIDTH != 0))
 
 /* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allocator */
 #ifdef NODE_NOT_IN_PAGE_FLAGS
@@ -624,7 +624,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
-#define LAST_NIDPID_MASK	((1UL << LAST_NIDPID_WIDTH) - 1)
+#define LAST_CPUPID_MASK	((1UL << LAST_CPUPID_WIDTH) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
 static inline enum zone_type page_zonenum(const struct page *page)
@@ -668,96 +668,106 @@ static inline int page_to_nid(const struct page *page)
 #endif
 
 #ifdef CONFIG_NUMA_BALANCING
-static inline int nid_pid_to_nidpid(int nid, int pid)
+static inline int cpu_pid_to_cpupid(int cpu, int pid)
 {
-	return ((nid & LAST__NID_MASK) << LAST__PID_SHIFT) | (pid & LAST__PID_MASK);
+	return ((cpu & LAST__CPU_MASK) << LAST__PID_SHIFT) | (pid & LAST__PID_MASK);
 }
 
-static inline int nidpid_to_pid(int nidpid)
+static inline int cpupid_to_pid(int cpupid)
 {
-	return nidpid & LAST__PID_MASK;
+	return cpupid & LAST__PID_MASK;
 }
 
-static inline int nidpid_to_nid(int nidpid)
+static inline int cpupid_to_cpu(int cpupid)
 {
-	return (nidpid >> LAST__PID_SHIFT) & LAST__NID_MASK;
+	return (cpupid >> LAST__PID_SHIFT) & LAST__CPU_MASK;
 }
 
-static inline bool nidpid_pid_unset(int nidpid)
+static inline int cpupid_to_nid(int cpupid)
 {
-	return nidpid_to_pid(nidpid) == (-1 & LAST__PID_MASK);
+	return cpu_to_node(cpupid_to_cpu(cpupid));
 }
 
-static inline bool nidpid_nid_unset(int nidpid)
+static inline bool cpupid_pid_unset(int cpupid)
 {
-	return nidpid_to_nid(nidpid) == (-1 & LAST__NID_MASK);
+	return cpupid_to_pid(cpupid) == (-1 & LAST__PID_MASK);
 }
 
-#ifdef LAST_NIDPID_NOT_IN_PAGE_FLAGS
-static inline int page_nidpid_xchg_last(struct page *page, int nid)
+static inline bool cpupid_cpu_unset(int cpupid)
 {
-	return xchg(&page->_last_nidpid, nid);
+	return cpupid_to_cpu(cpupid) == (-1 & LAST__CPU_MASK);
 }
 
-static inline int page_nidpid_last(struct page *page)
+#ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
+static inline int page_cpupid_xchg_last(struct page *page, int cpupid)
 {
-	return page->_last_nidpid;
+	return xchg(&page->_last_cpupid, cpupid);
 }
-static inline void page_nidpid_reset_last(struct page *page)
+
+static inline int page_cpupid_last(struct page *page)
+{
+	return page->_last_cpupid;
+}
+static inline void page_cpupid_reset_last(struct page *page)
 {
-	page->_last_nidpid = -1;
+	page->_last_cpupid = -1;
 }
 #else
-static inline int page_nidpid_last(struct page *page)
+static inline int page_cpupid_last(struct page *page)
 {
-	return (page->flags >> LAST_NIDPID_PGSHIFT) & LAST_NIDPID_MASK;
+	return (page->flags >> LAST_CPUPID_PGSHIFT) & LAST_CPUPID_MASK;
 }
 
-extern int page_nidpid_xchg_last(struct page *page, int nidpid);
+extern int page_cpupid_xchg_last(struct page *page, int cpupid);
 
-static inline void page_nidpid_reset_last(struct page *page)
+static inline void page_cpupid_reset_last(struct page *page)
 {
-	int nidpid = (1 << LAST_NIDPID_SHIFT) - 1;
+	int cpupid = (1 << LAST_CPUPID_SHIFT) - 1;
 
-	page->flags &= ~(LAST_NIDPID_MASK << LAST_NIDPID_PGSHIFT);
-	page->flags |= (nidpid & LAST_NIDPID_MASK) << LAST_NIDPID_PGSHIFT;
+	page->flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
+	page->flags |= (cpupid & LAST_CPUPID_MASK) << LAST_CPUPID_PGSHIFT;
 }
-#endif /* LAST_NIDPID_NOT_IN_PAGE_FLAGS */
-#else
-static inline int page_nidpid_xchg_last(struct page *page, int nidpid)
+#endif /* LAST_CPUPID_NOT_IN_PAGE_FLAGS */
+#else /* !CONFIG_NUMA_BALANCING */
+static inline int page_cpupid_xchg_last(struct page *page, int cpupid)
 {
-	return page_to_nid(page);
+	return page_to_nid(page); /* XXX */
 }
 
-static inline int page_nidpid_last(struct page *page)
+static inline int page_cpupid_last(struct page *page)
 {
-	return page_to_nid(page);
+	return page_to_nid(page); /* XXX */
 }
 
-static inline int nidpid_to_nid(int nidpid)
+static inline int cpupid_to_nid(int cpupid)
 {
 	return -1;
 }
 
-static inline int nidpid_to_pid(int nidpid)
+static inline int cpupid_to_pid(int cpupid)
 {
 	return -1;
 }
 
-static inline int nid_pid_to_nidpid(int nid, int pid)
+static inline int cpupid_to_cpu(int cpupid)
 {
 	return -1;
 }
 
-static inline bool nidpid_pid_unset(int nidpid)
+static inline int cpu_pid_to_cpupid(int nid, int pid)
+{
+	return -1;
+}
+
+static inline bool cpupid_pid_unset(int cpupid)
 {
 	return 1;
 }
 
-static inline void page_nidpid_reset_last(struct page *page)
+static inline void page_cpupid_reset_last(struct page *page)
 {
 }
-#endif
+#endif /* CONFIG_NUMA_BALANCING */
 
 static inline struct zone *page_zone(const struct page *page)
 {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f46378e..b0370cd 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -174,8 +174,8 @@ struct page {
 	void *shadow;
 #endif
 
-#ifdef LAST_NIDPID_NOT_IN_PAGE_FLAGS
-	int _last_nidpid;
+#ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
+	int _last_cpupid;
 #endif
 }
 /*
diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
index 02bc918..da52366 100644
--- a/include/linux/page-flags-layout.h
+++ b/include/linux/page-flags-layout.h
@@ -39,9 +39,9 @@
  * lookup is necessary.
  *
  * No sparsemem or sparsemem vmemmap: |       NODE     | ZONE |             ... | FLAGS |
- *      " plus space for last_nidpid: |       NODE     | ZONE | LAST_NIDPID ... | FLAGS |
+ *      " plus space for last_cpupid: |       NODE     | ZONE | LAST_CPUPID ... | FLAGS |
  * classic sparse with space for node:| SECTION | NODE | ZONE |             ... | FLAGS |
- *      " plus space for last_nidpid: | SECTION | NODE | ZONE | LAST_NIDPID ... | FLAGS |
+ *      " plus space for last_cpupid: | SECTION | NODE | ZONE | LAST_CPUPID ... | FLAGS |
  * classic sparse no space for node:  | SECTION |     ZONE    | ... | FLAGS |
  */
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
@@ -65,18 +65,18 @@
 #define LAST__PID_SHIFT 8
 #define LAST__PID_MASK  ((1 << LAST__PID_SHIFT)-1)
 
-#define LAST__NID_SHIFT NODES_SHIFT
-#define LAST__NID_MASK  ((1 << LAST__NID_SHIFT)-1)
+#define LAST__CPU_SHIFT NR_CPUS_BITS
+#define LAST__CPU_MASK  ((1 << LAST__CPU_SHIFT)-1)
 
-#define LAST_NIDPID_SHIFT (LAST__PID_SHIFT+LAST__NID_SHIFT)
+#define LAST_CPUPID_SHIFT (LAST__PID_SHIFT+LAST__CPU_SHIFT)
 #else
-#define LAST_NIDPID_SHIFT 0
+#define LAST_CPUPID_SHIFT 0
 #endif
 
-#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_NIDPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
-#define LAST_NIDPID_WIDTH LAST_NIDPID_SHIFT
+#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
+#define LAST_CPUPID_WIDTH LAST_CPUPID_SHIFT
 #else
-#define LAST_NIDPID_WIDTH 0
+#define LAST_CPUPID_WIDTH 0
 #endif
 
 /*
@@ -87,8 +87,8 @@
 #define NODE_NOT_IN_PAGE_FLAGS
 #endif
 
-#if defined(CONFIG_NUMA_BALANCING) && LAST_NIDPID_WIDTH == 0
-#define LAST_NIDPID_NOT_IN_PAGE_FLAGS
+#if defined(CONFIG_NUMA_BALANCING) && LAST_CPUPID_WIDTH == 0
+#define LAST_CPUPID_NOT_IN_PAGE_FLAGS
 #endif
 
 #endif /* _LINUX_PAGE_FLAGS_LAYOUT */
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
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 8ebed0a..7408951 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1210,7 +1210,7 @@ static void task_numa_placement(struct task_struct *p)
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int last_nidpid, int node, int pages, bool migrated)
+void task_numa_fault(int last_cpupid, int node, int pages, bool migrated)
 {
 	struct task_struct *p = current;
 	int priv;
@@ -1226,8 +1226,8 @@ void task_numa_fault(int last_nidpid, int node, int pages, bool migrated)
 	 * First accesses are treated as private, otherwise consider accesses
 	 * to be private if the accessing pid has not changed
 	 */
-	if (!nidpid_pid_unset(last_nidpid))
-		priv = ((p->pid & LAST__PID_MASK) == nidpid_to_pid(last_nidpid));
+	if (!cpupid_pid_unset(last_cpupid))
+		priv = ((p->pid & LAST__PID_MASK) == cpupid_to_pid(last_cpupid));
 	else
 		priv = 1;
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0e73685..048d4b2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1294,7 +1294,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
 	int page_nid = -1, this_nid = numa_node_id();
-	int target_nid, last_nidpid = -1;
+	int target_nid, last_cpupid = -1;
 	bool page_locked;
 	bool migrated = false;
 
@@ -1305,7 +1305,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	page = pmd_page(pmd);
 	BUG_ON(is_huge_zero_page(page));
 	page_nid = page_to_nid(page);
-	last_nidpid = page_nidpid_last(page);
+	last_cpupid = page_cpupid_last(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
 	if (page_nid == this_nid)
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
@@ -1374,7 +1374,7 @@ out:
 		page_unlock_anon_vma_read(anon_vma);
 
 	if (page_nid != -1)
-		task_numa_fault(last_nidpid, page_nid, HPAGE_PMD_NR, migrated);
+		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR, migrated);
 
 	return 0;
 }
@@ -1694,7 +1694,7 @@ static void __split_huge_page_refcount(struct page *page,
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
-		page_nidpid_xchg_last(page_tail, page_nidpid_last(page));
+		page_cpupid_xchg_last(page_tail, page_cpupid_last(page));
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
diff --git a/mm/memory.c b/mm/memory.c
index 948ec32..6b558a5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -69,8 +69,8 @@
 
 #include "internal.h"
 
-#ifdef LAST_NIDPID_NOT_IN_PAGE_FLAGS
-#warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_nidpid.
+#ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
+#warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_cpupid.
 #endif
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
@@ -3547,7 +3547,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page = NULL;
 	spinlock_t *ptl;
 	int page_nid = -1;
-	int last_nidpid;
+	int last_cpupid;
 	int target_nid;
 	bool migrated = false;
 
@@ -3578,7 +3578,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 	BUG_ON(is_zero_pfn(page_to_pfn(page)));
 
-	last_nidpid = page_nidpid_last(page);
+	last_cpupid = page_cpupid_last(page);
 	page_nid = page_to_nid(page);
 	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 	pte_unmap_unlock(ptep, ptl);
@@ -3594,7 +3594,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 out:
 	if (page_nid != -1)
-		task_numa_fault(last_nidpid, page_nid, 1, migrated);
+		task_numa_fault(last_cpupid, page_nid, 1, migrated);
 	return 0;
 }
 
@@ -3609,7 +3609,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
-	int last_nidpid;
+	int last_cpupid;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3654,7 +3654,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(!page))
 			continue;
 
-		last_nidpid = page_nidpid_last(page);
+		last_cpupid = page_cpupid_last(page);
 		page_nid = page_to_nid(page);
 		target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 		pte_unmap_unlock(pte, ptl);
@@ -3667,7 +3667,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 
 		if (page_nid != -1)
-			task_numa_fault(last_nidpid, page_nid, 1, migrated);
+			task_numa_fault(last_cpupid, page_nid, 1, migrated);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 54004a8..07db309 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2268,6 +2268,8 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	struct zone *zone;
 	int curnid = page_to_nid(page);
 	unsigned long pgoff;
+	int thiscpu = raw_smp_processor_id();
+	int thisnid = cpu_to_node(thiscpu);
 	int polnid = -1;
 	int ret = -1;
 
@@ -2316,11 +2318,11 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 
 	/* Migrate the page towards the node whose CPU is referencing it */
 	if (pol->flags & MPOL_F_MORON) {
-		int last_nidpid;
-		int this_nidpid;
+		int last_cpupid;
+		int this_cpupid;
 
-		polnid = numa_node_id();
-		this_nidpid = nid_pid_to_nidpid(polnid, current->pid);
+		polnid = thisnid;
+		this_cpupid = cpu_pid_to_cpupid(thiscpu, current->pid);
 
 		/*
 		 * Multi-stage node selection is used in conjunction
@@ -2343,8 +2345,8 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 * it less likely we act on an unlikely task<->page
 		 * relation.
 		 */
-		last_nidpid = page_nidpid_xchg_last(page, this_nidpid);
-		if (!nidpid_pid_unset(last_nidpid) && nidpid_to_nid(last_nidpid) != polnid)
+		last_cpupid = page_cpupid_xchg_last(page, this_cpupid);
+		if (!cpupid_pid_unset(last_cpupid) && cpupid_to_nid(last_cpupid) != thisnid)
 			goto out;
 
 #ifdef CONFIG_NUMA_BALANCING
@@ -2354,7 +2356,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 * This way a short and temporary process migration will
 		 * not cause excessive memory migration.
 		 */
-		if (polnid != current->numa_preferred_nid &&
+		if (thisnid != current->numa_preferred_nid &&
 				!current->numa_migrate_seq)
 			goto out;
 #endif
diff --git a/mm/migrate.c b/mm/migrate.c
index cea719d..6ff845f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1495,7 +1495,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 					  __GFP_NOWARN) &
 					 ~GFP_IOFS, 0);
 	if (newpage)
-		page_nidpid_xchg_last(newpage, page_nidpid_last(page));
+		page_cpupid_xchg_last(newpage, page_cpupid_last(page));
 
 	return newpage;
 }
@@ -1672,7 +1672,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	if (!new_page)
 		goto out_fail;
 
-	page_nidpid_xchg_last(new_page, page_nidpid_last(page));
+	page_cpupid_xchg_last(new_page, page_cpupid_last(page));
 
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated) {
diff --git a/mm/mm_init.c b/mm/mm_init.c
index 467de57..68562e9 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -71,26 +71,26 @@ void __init mminit_verify_pageflags_layout(void)
 	unsigned long or_mask, add_mask;
 
 	shift = 8 * sizeof(unsigned long);
-	width = shift - SECTIONS_WIDTH - NODES_WIDTH - ZONES_WIDTH - LAST_NIDPID_SHIFT;
+	width = shift - SECTIONS_WIDTH - NODES_WIDTH - ZONES_WIDTH - LAST_CPUPID_SHIFT;
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_widths",
-		"Section %d Node %d Zone %d Lastnidpid %d Flags %d\n",
+		"Section %d Node %d Zone %d Lastcpupid %d Flags %d\n",
 		SECTIONS_WIDTH,
 		NODES_WIDTH,
 		ZONES_WIDTH,
-		LAST_NIDPID_WIDTH,
+		LAST_CPUPID_WIDTH,
 		NR_PAGEFLAGS);
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_shifts",
-		"Section %d Node %d Zone %d Lastnidpid %d\n",
+		"Section %d Node %d Zone %d Lastcpupid %d\n",
 		SECTIONS_SHIFT,
 		NODES_SHIFT,
 		ZONES_SHIFT,
-		LAST_NIDPID_SHIFT);
+		LAST_CPUPID_SHIFT);
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_pgshifts",
-		"Section %lu Node %lu Zone %lu Lastnidpid %lu\n",
+		"Section %lu Node %lu Zone %lu Lastcpupid %lu\n",
 		(unsigned long)SECTIONS_PGSHIFT,
 		(unsigned long)NODES_PGSHIFT,
 		(unsigned long)ZONES_PGSHIFT,
-		(unsigned long)LAST_NIDPID_PGSHIFT);
+		(unsigned long)LAST_CPUPID_PGSHIFT);
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_nodezoneid",
 		"Node/Zone ID: %lu -> %lu\n",
 		(unsigned long)(ZONEID_PGOFF + ZONEID_SHIFT),
@@ -102,9 +102,9 @@ void __init mminit_verify_pageflags_layout(void)
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_nodeflags",
 		"Node not in page flags");
 #endif
-#ifdef LAST_NIDPID_NOT_IN_PAGE_FLAGS
+#ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_nodeflags",
-		"Last nidpid not in page flags");
+		"Last cpupid not in page flags");
 #endif
 
 	if (SECTIONS_WIDTH) {
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 25bb477..2c70c3a 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -97,20 +97,20 @@ void lruvec_init(struct lruvec *lruvec)
 		INIT_LIST_HEAD(&lruvec->lists[lru]);
 }
 
-#if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_NIDPID_NOT_IN_PAGE_FLAGS)
-int page_nidpid_xchg_last(struct page *page, int nidpid)
+#if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_CPUPID_IN_PAGE_FLAGS)
+int page_cpupid_xchg_last(struct page *page, int cpupid)
 {
 	unsigned long old_flags, flags;
-	int last_nidpid;
+	int last_cpupid;
 
 	do {
 		old_flags = flags = page->flags;
-		last_nidpid = page_nidpid_last(page);
+		last_cpupid = page_cpupid_last(page);
 
-		flags &= ~(LAST_NIDPID_MASK << LAST_NIDPID_PGSHIFT);
-		flags |= (nidpid & LAST_NIDPID_MASK) << LAST_NIDPID_PGSHIFT;
+		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
+		flags |= (cpupid & LAST_CPUPID_MASK) << LAST_CPUPID_PGSHIFT;
 	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
 
-	return last_nidpid;
+	return last_cpupid;
 }
 #endif
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 5aae390..9a74855 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -37,14 +37,14 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable, int prot_numa, bool *ret_all_same_nidpid)
+		int dirty_accountable, int prot_numa, bool *ret_all_same_cpupid)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
-	bool all_same_nidpid = true;
-	int last_nid = -1;
+	bool all_same_cpupid = true;
+	int last_cpu = -1;
 	int last_pid = -1;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
@@ -64,17 +64,17 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 				page = vm_normal_page(vma, addr, oldpte);
 				if (page) {
-					int nidpid = page_nidpid_last(page);
-					int this_nid = nidpid_to_nid(nidpid);
-					int this_pid = nidpid_to_pid(nidpid);
+					int cpupid = page_cpupid_last(page);
+					int this_cpu = cpupid_to_cpu(cpupid);
+					int this_pid = cpupid_to_pid(cpupid);
 
-					if (last_nid == -1)
-						last_nid = this_nid;
+					if (last_cpu == -1)
+						last_cpu = this_cpu;
 					if (last_pid == -1)
 						last_pid = this_pid;
-					if (last_nid != this_nid ||
+					if (last_cpu != this_cpu ||
 					    last_pid != this_pid) {
-						all_same_nidpid = false;
+						all_same_cpupid = false;
 					}
 
 					if (!pte_numa(oldpte)) {
@@ -115,7 +115,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
-	*ret_all_same_nidpid = all_same_nidpid;
+	*ret_all_same_cpupid = all_same_cpupid;
 	return pages;
 }
 
@@ -142,7 +142,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	pmd_t *pmd;
 	unsigned long next;
 	unsigned long pages = 0;
-	bool all_same_nidpid;
+	bool all_same_cpupid;
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -168,7 +168,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
-				 dirty_accountable, prot_numa, &all_same_nidpid);
+				 dirty_accountable, prot_numa, &all_same_cpupid);
 		pages += this_pages;
 
 		/*
@@ -177,7 +177,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		 * node. This allows a regular PMD to be handled as one fault
 		 * and effectively batches the taking of the PTL
 		 */
-		if (prot_numa && this_pages && all_same_nidpid)
+		if (prot_numa && this_pages && all_same_cpupid)
 			change_pmd_protnuma(vma->vm_mm, addr, pmd);
 	} while (pmd++, addr = next, addr != end);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7bf960e..4b6c4e8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -622,7 +622,7 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page);
 		return 1;
 	}
-	page_nidpid_reset_last(page);
+	page_cpupid_reset_last(page);
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	return 0;
@@ -3944,7 +3944,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		mminit_verify_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		page_mapcount_reset(page);
-		page_nidpid_reset_last(page);
+		page_cpupid_reset_last(page);
 		SetPageReserved(page);
 		/*
 		 * Mark the block movable so that blocks are reserved for
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
