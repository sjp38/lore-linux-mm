Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 027D9900017
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:01:11 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 25/27] sched: Set preferred NUMA node based on number of private faults
Date: Thu,  8 Aug 2013 15:00:37 +0100
Message-Id: <1375970439-5111-26-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Ideally it would be possible to distinguish between NUMA hinting faults that
are private to a task and those that are shared. If treated identically
there is a risk that shared pages bounce between nodes depending on
the order they are referenced by tasks. Ultimately what is desirable is
that task private pages remain local to the task while shared pages are
interleaved between sharing tasks running on different nodes to give good
average performance. This is further complicated by THP as even
applications that partition their data may not be partitioning on a huge
page boundary.

To start with, this patch assumes that multi-threaded or multi-process
applications partition their data and that in general the private accesses
are more important for cpu->memory locality in the general case. Also,
no new infrastructure is required to treat private pages properly but
interleaving for shared pages requires additional infrastructure.

To detect private accesses the pid of the last accessing task is required
but the storage requirements are a high. This patch borrows heavily from
Ingo Molnar's patch "numa, mm, sched: Implement last-CPU+PID hash tracking"
to encode some bits from the last accessing task in the page flags as
well as the node information. Collisions will occur but it is better than
just depending on the node information. Node information is then used to
determine if a page needs to migrate. The PID information is used to detect
private/shared accesses. The preferred NUMA node is selected based on where
the maximum number of approximately private faults were measured. Shared
faults are not taken into consideration for a few reasons.

First, if there are many tasks sharing the page then they'll all move
towards the same node. The node will be compute overloaded and then
scheduled away later only to bounce back again. Alternatively the shared
tasks would just bounce around nodes because the fault information is
effectively noise. Either way accounting for shared faults the same as
private faults can result in lower performance overall.

The second reason is based on a hypothetical workload that has a small
number of very important, heavily accessed private pages but a large shared
array. The shared array would dominate the number of faults and be selected
as a preferred node even though it's the wrong decision.

The third reason is that multiple threads in a process will race each
other to fault the shared page making the fault information unreliable.

[riel@redhat.com: Fix complication error when !NUMA_BALANCING]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm.h                | 89 +++++++++++++++++++++++++++++----------
 include/linux/mm_types.h          |  4 +-
 include/linux/page-flags-layout.h | 28 +++++++-----
 kernel/sched/fair.c               | 12 ++++--
 mm/huge_memory.c                  |  8 ++--
 mm/memory.c                       | 16 +++----
 mm/mempolicy.c                    |  8 ++--
 mm/migrate.c                      |  4 +-
 mm/mm_init.c                      | 18 ++++----
 mm/mmzone.c                       | 14 +++---
 mm/mprotect.c                     | 26 ++++++++----
 mm/page_alloc.c                   |  4 +-
 12 files changed, 149 insertions(+), 82 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f022460..0a0db6c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -588,11 +588,11 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
  * sets it, so none of the operations on it need to be atomic.
  */
 
-/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_NID] | ... | FLAGS | */
+/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_NIDPID] | ... | FLAGS | */
 #define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
 #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
 #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
-#define LAST_NID_PGOFF		(ZONES_PGOFF - LAST_NID_WIDTH)
+#define LAST_NIDPID_PGOFF	(ZONES_PGOFF - LAST_NIDPID_WIDTH)
 
 /*
  * Define the bit shifts to access each section.  For non-existent
@@ -602,7 +602,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
 #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
 #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
-#define LAST_NID_PGSHIFT	(LAST_NID_PGOFF * (LAST_NID_WIDTH != 0))
+#define LAST_NIDPID_PGSHIFT	(LAST_NIDPID_PGOFF * (LAST_NIDPID_WIDTH != 0))
 
 /* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allocator */
 #ifdef NODE_NOT_IN_PAGE_FLAGS
@@ -624,7 +624,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
-#define LAST_NID_MASK		((1UL << LAST_NID_WIDTH) - 1)
+#define LAST_NIDPID_MASK	((1UL << LAST_NIDPID_WIDTH) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
 static inline enum zone_type page_zonenum(const struct page *page)
@@ -668,48 +668,93 @@ static inline int page_to_nid(const struct page *page)
 #endif
 
 #ifdef CONFIG_NUMA_BALANCING
-#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
-static inline int page_nid_xchg_last(struct page *page, int nid)
+static inline int nid_pid_to_nidpid(int nid, int pid)
 {
-	return xchg(&page->_last_nid, nid);
+	return ((nid & LAST__NID_MASK) << LAST__PID_SHIFT) | (pid & LAST__PID_MASK);
 }
 
-static inline int page_nid_last(struct page *page)
+static inline int nidpid_to_pid(int nidpid)
 {
-	return page->_last_nid;
+	return nidpid & LAST__PID_MASK;
 }
-static inline void page_nid_reset_last(struct page *page)
+
+static inline int nidpid_to_nid(int nidpid)
+{
+	return (nidpid >> LAST__PID_SHIFT) & LAST__NID_MASK;
+}
+
+static inline bool nidpid_pid_unset(int nidpid)
+{
+	return nidpid_to_pid(nidpid) == (-1 & LAST__PID_MASK);
+}
+
+static inline bool nidpid_nid_unset(int nidpid)
 {
-	page->_last_nid = -1;
+	return nidpid_to_nid(nidpid) == (-1 & LAST__NID_MASK);
+}
+
+#ifdef LAST_NIDPID_NOT_IN_PAGE_FLAGS
+static inline int page_nidpid_xchg_last(struct page *page, int nid)
+{
+	return xchg(&page->_last_nidpid, nid);
+}
+
+static inline int page_nidpid_last(struct page *page)
+{
+	return page->_last_nidpid;
+}
+static inline void page_nidpid_reset_last(struct page *page)
+{
+	page->_last_nidpid = -1;
 }
 #else
-static inline int page_nid_last(struct page *page)
+static inline int page_nidpid_last(struct page *page)
 {
-	return (page->flags >> LAST_NID_PGSHIFT) & LAST_NID_MASK;
+	return (page->flags >> LAST_NIDPID_PGSHIFT) & LAST_NIDPID_MASK;
 }
 
-extern int page_nid_xchg_last(struct page *page, int nid);
+extern int page_nidpid_xchg_last(struct page *page, int nidpid);
 
-static inline void page_nid_reset_last(struct page *page)
+static inline void page_nidpid_reset_last(struct page *page)
 {
-	int nid = (1 << LAST_NID_SHIFT) - 1;
+	int nidpid = (1 << LAST_NIDPID_SHIFT) - 1;
 
-	page->flags &= ~(LAST_NID_MASK << LAST_NID_PGSHIFT);
-	page->flags |= (nid & LAST_NID_MASK) << LAST_NID_PGSHIFT;
+	page->flags &= ~(LAST_NIDPID_MASK << LAST_NIDPID_PGSHIFT);
+	page->flags |= (nidpid & LAST_NIDPID_MASK) << LAST_NIDPID_PGSHIFT;
 }
-#endif /* LAST_NID_NOT_IN_PAGE_FLAGS */
+#endif /* LAST_NIDPID_NOT_IN_PAGE_FLAGS */
 #else
-static inline int page_nid_xchg_last(struct page *page, int nid)
+static inline int page_nidpid_xchg_last(struct page *page, int nidpid)
 {
 	return page_to_nid(page);
 }
 
-static inline int page_nid_last(struct page *page)
+static inline int page_nidpid_last(struct page *page)
 {
 	return page_to_nid(page);
 }
 
-static inline void page_nid_reset_last(struct page *page)
+static inline int nidpid_to_nid(int nidpid)
+{
+	return -1;
+}
+
+static inline int nidpid_to_pid(int nidpid)
+{
+	return -1;
+}
+
+static inline int nid_pid_to_nidpid(int nid, int pid)
+{
+	return -1;
+}
+
+static inline bool nidpid_pid_unset(int nidpid)
+{
+	return 1;
+}
+
+static inline void page_nidpid_reset_last(struct page *page)
 {
 }
 #endif
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 86f3a56..65960f1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -174,8 +174,8 @@ struct page {
 	void *shadow;
 #endif
 
-#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
-	int _last_nid;
+#ifdef LAST_NIDPID_NOT_IN_PAGE_FLAGS
+	int _last_nidpid;
 #endif
 }
 /*
diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
index 93506a1..02bc918 100644
--- a/include/linux/page-flags-layout.h
+++ b/include/linux/page-flags-layout.h
@@ -38,10 +38,10 @@
  * The last is when there is insufficient space in page->flags and a separate
  * lookup is necessary.
  *
- * No sparsemem or sparsemem vmemmap: |       NODE     | ZONE |          ... | FLAGS |
- *         " plus space for last_nid: |       NODE     | ZONE | LAST_NID ... | FLAGS |
- * classic sparse with space for node:| SECTION | NODE | ZONE |          ... | FLAGS |
- *         " plus space for last_nid: | SECTION | NODE | ZONE | LAST_NID ... | FLAGS |
+ * No sparsemem or sparsemem vmemmap: |       NODE     | ZONE |             ... | FLAGS |
+ *      " plus space for last_nidpid: |       NODE     | ZONE | LAST_NIDPID ... | FLAGS |
+ * classic sparse with space for node:| SECTION | NODE | ZONE |             ... | FLAGS |
+ *      " plus space for last_nidpid: | SECTION | NODE | ZONE | LAST_NIDPID ... | FLAGS |
  * classic sparse no space for node:  | SECTION |     ZONE    | ... | FLAGS |
  */
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
@@ -62,15 +62,21 @@
 #endif
 
 #ifdef CONFIG_NUMA_BALANCING
-#define LAST_NID_SHIFT NODES_SHIFT
+#define LAST__PID_SHIFT 8
+#define LAST__PID_MASK  ((1 << LAST__PID_SHIFT)-1)
+
+#define LAST__NID_SHIFT NODES_SHIFT
+#define LAST__NID_MASK  ((1 << LAST__NID_SHIFT)-1)
+
+#define LAST_NIDPID_SHIFT (LAST__PID_SHIFT+LAST__NID_SHIFT)
 #else
-#define LAST_NID_SHIFT 0
+#define LAST_NIDPID_SHIFT 0
 #endif
 
-#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_NID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
-#define LAST_NID_WIDTH LAST_NID_SHIFT
+#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_NIDPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
+#define LAST_NIDPID_WIDTH LAST_NIDPID_SHIFT
 #else
-#define LAST_NID_WIDTH 0
+#define LAST_NIDPID_WIDTH 0
 #endif
 
 /*
@@ -81,8 +87,8 @@
 #define NODE_NOT_IN_PAGE_FLAGS
 #endif
 
-#if defined(CONFIG_NUMA_BALANCING) && LAST_NID_WIDTH == 0
-#define LAST_NID_NOT_IN_PAGE_FLAGS
+#if defined(CONFIG_NUMA_BALANCING) && LAST_NIDPID_WIDTH == 0
+#define LAST_NIDPID_NOT_IN_PAGE_FLAGS
 #endif
 
 #endif /* _LINUX_PAGE_FLAGS_LAYOUT */
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index b66c662..9d8b5cb 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -988,7 +988,7 @@ static void task_numa_placement(struct task_struct *p)
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int last_nid, int node, int pages, bool migrated)
+void task_numa_fault(int last_nidpid, int node, int pages, bool migrated)
 {
 	struct task_struct *p = current;
 	int priv;
@@ -1000,8 +1000,14 @@ void task_numa_fault(int last_nid, int node, int pages, bool migrated)
 	if (!p->mm)
 		return;
 
-	/* For now, do not attempt to detect private/shared accesses */
-	priv = 1;
+	/*
+	 * First accesses are treated as private, otherwise consider accesses
+	 * to be private if the accessing pid has not changed
+	 */
+	if (!nidpid_pid_unset(last_nidpid))
+		priv = ((p->pid & LAST__PID_MASK) == nidpid_to_pid(last_nidpid));
+	else
+		priv = 1;
 
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults)) {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a6153eb..72b2b5a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1293,7 +1293,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
 	int page_nid = -1, this_nid = numa_node_id();
-	int target_nid, last_nid = -1;
+	int target_nid, last_nidpid = -1;
 	bool migrated = false;
 
 	spin_lock(&mm->page_table_lock);
@@ -1316,7 +1316,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (page_nid == this_nid)
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
-	last_nid = page_nid_last(page);
+	last_nidpid = page_nidpid_last(page);
 	target_nid = mpol_misplaced(page, vma, haddr);
 	if (target_nid == -1) {
 		put_page(page);
@@ -1360,7 +1360,7 @@ out_unlock:
 
 out:
 	if (page_nid != -1)
-		task_numa_fault(last_nid, page_nid, HPAGE_PMD_NR, migrated);
+		task_numa_fault(last_nidpid, page_nid, HPAGE_PMD_NR, migrated);
 	return 0;
 }
 
@@ -1670,7 +1670,7 @@ static void __split_huge_page_refcount(struct page *page,
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
-		page_nid_xchg_last(page_tail, page_nid_last(page));
+		page_nidpid_xchg_last(page_tail, page_nidpid_last(page));
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
diff --git a/mm/memory.c b/mm/memory.c
index 0e7010c..6b2212d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -69,8 +69,8 @@
 
 #include "internal.h"
 
-#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
-#warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_nid.
+#ifdef LAST_NIDPID_NOT_IN_PAGE_FLAGS
+#warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_nidpid.
 #endif
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
@@ -3534,7 +3534,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page = NULL;
 	spinlock_t *ptl;
 	int page_nid = -1;
-	int last_nid;
+	int last_nidpid;
 	int target_nid;
 	bool migrated = false;
 
@@ -3569,7 +3569,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return 0;
 	}
 
-	last_nid = page_nid_last(page);
+	last_nidpid = page_nidpid_last(page);
 	page_nid = page_to_nid(page);
 	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 	pte_unmap_unlock(ptep, ptl);
@@ -3585,7 +3585,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 out:
 	if (page_nid != -1)
-		task_numa_fault(last_nid, page_nid, 1, migrated);
+		task_numa_fault(last_nidpid, page_nid, 1, migrated);
 	return 0;
 }
 
@@ -3600,7 +3600,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
-	int last_nid;
+	int last_nidpid;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3645,7 +3645,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(!page))
 			continue;
 
-		last_nid = page_nid_last(page);
+		last_nidpid = page_nidpid_last(page);
 		page_nid = page_to_nid(page);
 		target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 		pte_unmap_unlock(pte, ptl);
@@ -3658,7 +3658,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 
 		if (page_nid != -1)
-			task_numa_fault(last_nid, page_nid, 1, migrated);
+			task_numa_fault(last_nidpid, page_nid, 1, migrated);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7431001..97fe8bb 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2288,9 +2288,11 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 
 	/* Migrate the page towards the node whose CPU is referencing it */
 	if (pol->flags & MPOL_F_MORON) {
-		int last_nid;
+		int last_nidpid;
+		int this_nidpid;
 
 		polnid = numa_node_id();
+		this_nidpid = nid_pid_to_nidpid(polnid, current->pid);
 
 		/*
 		 * Multi-stage node selection is used in conjunction
@@ -2313,8 +2315,8 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 * it less likely we act on an unlikely task<->page
 		 * relation.
 		 */
-		last_nid = page_nid_xchg_last(page, polnid);
-		if (last_nid != polnid)
+		last_nidpid = page_nidpid_xchg_last(page, this_nidpid);
+		if (!nidpid_pid_unset(last_nidpid) && nidpid_to_nid(last_nidpid) != polnid)
 			goto out;
 	}
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 08ac3ba..f56ca20 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1495,7 +1495,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 					  __GFP_NOWARN) &
 					 ~GFP_IOFS, 0);
 	if (newpage)
-		page_nid_xchg_last(newpage, page_nid_last(page));
+		page_nidpid_xchg_last(newpage, page_nidpid_last(page));
 
 	return newpage;
 }
@@ -1672,7 +1672,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	if (!new_page)
 		goto out_fail;
 
-	page_nid_xchg_last(new_page, page_nid_last(page));
+	page_nidpid_xchg_last(new_page, page_nidpid_last(page));
 
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated) {
diff --git a/mm/mm_init.c b/mm/mm_init.c
index 633c088..467de57 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -71,26 +71,26 @@ void __init mminit_verify_pageflags_layout(void)
 	unsigned long or_mask, add_mask;
 
 	shift = 8 * sizeof(unsigned long);
-	width = shift - SECTIONS_WIDTH - NODES_WIDTH - ZONES_WIDTH - LAST_NID_SHIFT;
+	width = shift - SECTIONS_WIDTH - NODES_WIDTH - ZONES_WIDTH - LAST_NIDPID_SHIFT;
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_widths",
-		"Section %d Node %d Zone %d Lastnid %d Flags %d\n",
+		"Section %d Node %d Zone %d Lastnidpid %d Flags %d\n",
 		SECTIONS_WIDTH,
 		NODES_WIDTH,
 		ZONES_WIDTH,
-		LAST_NID_WIDTH,
+		LAST_NIDPID_WIDTH,
 		NR_PAGEFLAGS);
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_shifts",
-		"Section %d Node %d Zone %d Lastnid %d\n",
+		"Section %d Node %d Zone %d Lastnidpid %d\n",
 		SECTIONS_SHIFT,
 		NODES_SHIFT,
 		ZONES_SHIFT,
-		LAST_NID_SHIFT);
+		LAST_NIDPID_SHIFT);
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_pgshifts",
-		"Section %lu Node %lu Zone %lu Lastnid %lu\n",
+		"Section %lu Node %lu Zone %lu Lastnidpid %lu\n",
 		(unsigned long)SECTIONS_PGSHIFT,
 		(unsigned long)NODES_PGSHIFT,
 		(unsigned long)ZONES_PGSHIFT,
-		(unsigned long)LAST_NID_PGSHIFT);
+		(unsigned long)LAST_NIDPID_PGSHIFT);
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_nodezoneid",
 		"Node/Zone ID: %lu -> %lu\n",
 		(unsigned long)(ZONEID_PGOFF + ZONEID_SHIFT),
@@ -102,9 +102,9 @@ void __init mminit_verify_pageflags_layout(void)
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_nodeflags",
 		"Node not in page flags");
 #endif
-#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
+#ifdef LAST_NIDPID_NOT_IN_PAGE_FLAGS
 	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_nodeflags",
-		"Last nid not in page flags");
+		"Last nidpid not in page flags");
 #endif
 
 	if (SECTIONS_WIDTH) {
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 2ac0afb..25bb477 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -97,20 +97,20 @@ void lruvec_init(struct lruvec *lruvec)
 		INIT_LIST_HEAD(&lruvec->lists[lru]);
 }
 
-#if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_NID_NOT_IN_PAGE_FLAGS)
-int page_nid_xchg_last(struct page *page, int nid)
+#if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_NIDPID_NOT_IN_PAGE_FLAGS)
+int page_nidpid_xchg_last(struct page *page, int nidpid)
 {
 	unsigned long old_flags, flags;
-	int last_nid;
+	int last_nidpid;
 
 	do {
 		old_flags = flags = page->flags;
-		last_nid = page_nid_last(page);
+		last_nidpid = page_nidpid_last(page);
 
-		flags &= ~(LAST_NID_MASK << LAST_NID_PGSHIFT);
-		flags |= (nid & LAST_NID_MASK) << LAST_NID_PGSHIFT;
+		flags &= ~(LAST_NIDPID_MASK << LAST_NIDPID_PGSHIFT);
+		flags |= (nidpid & LAST_NIDPID_MASK) << LAST_NIDPID_PGSHIFT;
 	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
 
-	return last_nid;
+	return last_nidpid;
 }
 #endif
diff --git a/mm/mprotect.c b/mm/mprotect.c
index df64356..e20fe13 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -37,14 +37,15 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable, int prot_numa, bool *ret_all_same_node)
+		int dirty_accountable, int prot_numa, bool *ret_all_same_nidpid)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
-	bool all_same_node = true;
+	bool all_same_nidpid = true;
 	int last_nid = -1;
+	int last_pid = -1;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -63,11 +64,18 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 				page = vm_normal_page(vma, addr, oldpte);
 				if (page) {
-					int this_nid = page_to_nid(page);
+					int nidpid = page_nidpid_last(page);
+					int this_nid = nidpid_to_nid(nidpid);
+					int this_pid = nidpid_to_pid(nidpid);
+
 					if (last_nid == -1)
 						last_nid = this_nid;
-					if (last_nid != this_nid)
-						all_same_node = false;
+					if (last_pid == -1)
+						last_pid = this_pid;
+					if (last_nid != this_nid ||
+					    last_pid != this_pid) {
+						all_same_nidpid = false;
+					}
 
 					if (!pte_numa(oldpte)) {
 						ptent = pte_mknuma(ptent);
@@ -107,7 +115,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
-	*ret_all_same_node = all_same_node;
+	*ret_all_same_nidpid = all_same_nidpid;
 	return pages;
 }
 
@@ -134,7 +142,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	pmd_t *pmd;
 	unsigned long next;
 	unsigned long pages = 0;
-	bool all_same_node;
+	bool all_same_nidpid;
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -158,7 +166,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		pages += change_pte_range(vma, pmd, addr, next, newprot,
-				 dirty_accountable, prot_numa, &all_same_node);
+				 dirty_accountable, prot_numa, &all_same_nidpid);
 
 		/*
 		 * If we are changing protections for NUMA hinting faults then
@@ -166,7 +174,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		 * node. This allows a regular PMD to be handled as one fault
 		 * and effectively batches the taking of the PTL
 		 */
-		if (prot_numa && all_same_node)
+		if (prot_numa && all_same_nidpid)
 			change_pmd_protnuma(vma->vm_mm, addr, pmd);
 	} while (pmd++, addr = next, addr != end);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..7bf960e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -622,7 +622,7 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page);
 		return 1;
 	}
-	page_nid_reset_last(page);
+	page_nidpid_reset_last(page);
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	return 0;
@@ -3944,7 +3944,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		mminit_verify_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		page_mapcount_reset(page);
-		page_nid_reset_last(page);
+		page_nidpid_reset_last(page);
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
