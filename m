Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id A981A6B003C
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 11:20:31 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/18] sched: Add infrastructure for split shared/private accounting of NUMA hinting faults
Date: Mon, 15 Jul 2013 16:20:11 +0100
Message-Id: <1373901620-2021-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1373901620-2021-1-git-send-email-mgorman@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Ideally it would be possible to distinguish between NUMA hinting faults
that are private to a task and those that are shared.  This patch prepares
infrastructure for separately accounting shared and private faults by
allocating the necessary buffers and passing in relevant information. For
now, all faults are treated as private and detection will be introduced
later.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  5 +++--
 kernel/sched/fair.c   | 33 ++++++++++++++++++++++++---------
 mm/huge_memory.c      |  7 ++++---
 mm/memory.c           |  9 ++++++---
 4 files changed, 37 insertions(+), 17 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 82a6136..b81195e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1600,10 +1600,11 @@ struct task_struct {
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
 #ifdef CONFIG_NUMA_BALANCING
-extern void task_numa_fault(int node, int pages, bool migrated);
+extern void task_numa_fault(int last_node, int node, int pages, bool migrated);
 extern void set_numabalancing_state(bool enabled);
 #else
-static inline void task_numa_fault(int node, int pages, bool migrated)
+static inline void task_numa_fault(int last_node, int node, int pages,
+				   bool migrated)
 {
 }
 static inline void set_numabalancing_state(bool enabled)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index f68fad5..9590fcd 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -800,6 +800,11 @@ unsigned int sysctl_numa_balancing_scan_delay = 1000;
  */
 unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
 
+static inline int task_faults_idx(int nid, int priv)
+{
+	return 2 * nid + priv;
+}
+
 static unsigned long weighted_cpuload(const int cpu);
 
 
@@ -841,13 +846,19 @@ static void task_numa_placement(struct task_struct *p)
 	/* Find the node with the highest number of faults */
 	for (nid = 0; nid < nr_node_ids; nid++) {
 		unsigned long faults;
+		int priv, i;
 
-		/* Decay existing window and copy faults since last scan */
-		p->numa_faults[nid] >>= 1;
-		p->numa_faults[nid] += p->numa_faults_buffer[nid];
-		p->numa_faults_buffer[nid] = 0;
+		for (priv = 0; priv < 2; priv++) {
+			i = task_faults_idx(nid, priv);
 
-		faults = p->numa_faults[nid];
+			/* Decay existing window, copy faults since last scan */
+			p->numa_faults[i] >>= 1;
+			p->numa_faults[i] += p->numa_faults_buffer[i];
+			p->numa_faults_buffer[i] = 0;
+		}
+
+		/* Find maximum private faults */
+		faults = p->numa_faults[task_faults_idx(nid, 1)];
 		if (faults > max_faults) {
 			max_faults = faults;
 			max_nid = nid;
@@ -883,16 +894,20 @@ static void task_numa_placement(struct task_struct *p)
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int node, int pages, bool migrated)
+void task_numa_fault(int last_nid, int node, int pages, bool migrated)
 {
 	struct task_struct *p = current;
+	int priv;
 
 	if (!sched_feat_numa(NUMA))
 		return;
 
+	/* For now, do not attempt to detect private/shared accesses */
+	priv = 1;
+
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults)) {
-		int size = sizeof(*p->numa_faults) * nr_node_ids;
+		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
 
 		/* numa_faults and numa_faults_buffer share the allocation */
 		p->numa_faults = kzalloc(size * 2, GFP_KERNEL);
@@ -900,7 +915,7 @@ void task_numa_fault(int node, int pages, bool migrated)
 			return;
 
 		BUG_ON(p->numa_faults_buffer);
-		p->numa_faults_buffer = p->numa_faults + nr_node_ids;
+		p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
 	}
 
 	/*
@@ -914,7 +929,7 @@ void task_numa_fault(int node, int pages, bool migrated)
 	task_numa_placement(p);
 
 	/* Record the fault, double the weight if pages were migrated */
-	p->numa_faults_buffer[node] += pages << migrated;
+	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages << migrated;
 }
 
 static void reset_ptenuma_scan(struct task_struct *p)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ec938ed..9462591 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1292,7 +1292,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
-	int target_nid;
+	int target_nid, last_nid;
 	int src_nid = -1;
 	bool migrated;
 
@@ -1316,6 +1316,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (src_nid == page_to_nid(page))
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
+	last_nid = page_nid_last(page);
 	target_nid = mpol_misplaced(page, vma, haddr);
 	if (target_nid == -1) {
 		put_page(page);
@@ -1341,7 +1342,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!migrated)
 		goto check_same;
 
-	task_numa_fault(target_nid, HPAGE_PMD_NR, true);
+	task_numa_fault(last_nid, target_nid, HPAGE_PMD_NR, true);
 	return 0;
 
 check_same:
@@ -1356,7 +1357,7 @@ clear_pmdnuma:
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
 	if (src_nid != -1)
-		task_numa_fault(src_nid, HPAGE_PMD_NR, false);
+		task_numa_fault(last_nid, src_nid, HPAGE_PMD_NR, false);
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 6c6f6b0..ab933be 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3536,7 +3536,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *page = NULL;
 	spinlock_t *ptl;
-	int current_nid = -1;
+	int current_nid = -1, last_nid;
 	int target_nid;
 	bool migrated = false;
 
@@ -3571,6 +3571,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return 0;
 	}
 
+	last_nid = page_nid_last(page);
 	current_nid = page_to_nid(page);
 	target_nid = numa_migrate_prep(page, vma, addr, current_nid);
 	pte_unmap_unlock(ptep, ptl);
@@ -3591,7 +3592,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 out:
 	if (current_nid != -1)
-		task_numa_fault(current_nid, 1, migrated);
+		task_numa_fault(last_nid, current_nid, 1, migrated);
 	return 0;
 }
 
@@ -3607,6 +3608,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	bool numa = false;
 	int local_nid = numa_node_id();
+	int last_nid;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3659,6 +3661,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * migrated to.
 		 */
 		curr_nid = local_nid;
+		last_nid = page_nid_last(page);
 		target_nid = numa_migrate_prep(page, vma, addr,
 					       page_to_nid(page));
 		if (target_nid == -1) {
@@ -3671,7 +3674,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		migrated = migrate_misplaced_page(page, target_nid);
 		if (migrated)
 			curr_nid = target_nid;
-		task_numa_fault(curr_nid, 1, migrated);
+		task_numa_fault(last_nid, curr_nid, 1, migrated);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
