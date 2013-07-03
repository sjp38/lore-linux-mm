Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 5EBBA6B003B
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:22:22 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/13] sched: Split accounting of NUMA hinting faults that pass two-stage filter
Date: Wed,  3 Jul 2013 15:21:34 +0100
Message-Id: <1372861300-9973-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1372861300-9973-1-git-send-email-mgorman@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Ideally it would be possible to distinguish between NUMA hinting faults
that are private to a task and those that are shared. This would require
that the last task that accessed a page for a hinting fault would be
recorded which would increase the size of struct page. Instead this patch
approximates private pages by assuming that faults that pass the two-stage
filter are private pages and all others are shared. The preferred NUMA
node is then selected based on where the maximum number of approximately
private faults were measured. Shared faults are not taken into
consideration for a few reasons.

First, if there are many tasks sharing the page then they'll all move
towards the same node. The node will be compute overloaded and then
scheduled away later only to bounce back again. Alternatively the shared
tasks would just bounce around nodes because the fault information is
effectively noise. Either way accounting for shared faults the same as
private faults may result in lower performance overall.

The second reason is based on a hypothetical workload that has a small
number of very important, heavily accessed private pages but a large shared
array. The shared array would dominate the number of faults and be selected
as a preferred node even though it's the wrong decision.

The third reason is that multiple threads in a process will race each
other to fault the shared page making the fault information unreliable.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  4 ++--
 kernel/sched/fair.c   | 30 +++++++++++++++++++++---------
 mm/huge_memory.c      |  7 ++++---
 mm/memory.c           |  9 ++++++---
 4 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 82a6136..a41edea 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1600,10 +1600,10 @@ struct task_struct {
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
 #ifdef CONFIG_NUMA_BALANCING
-extern void task_numa_fault(int node, int pages, bool migrated);
+extern void task_numa_fault(int last_node, int node, int pages, bool migrated);
 extern void set_numabalancing_state(bool enabled);
 #else
-static inline void task_numa_fault(int node, int pages, bool migrated)
+static inline void task_numa_fault(int last_node, int node, int pages, bool migrated)
 {
 }
 static inline void set_numabalancing_state(bool enabled)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index b9139be..a66f2bb 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -831,6 +831,11 @@ find_idlest_cpu_node(int this_cpu, int nid)
 	return idlest_cpu;
 }
 
+static inline int task_faults_idx(int nid, int priv)
+{
+	return 2 * nid + priv;
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = 0;
@@ -847,13 +852,19 @@ static void task_numa_placement(struct task_struct *p)
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
+
+			/* Decay existing window and copy faults since last scan */
+			p->numa_faults[i] >>= 1;
+			p->numa_faults[i] += p->numa_faults_buffer[i];
+			p->numa_faults_buffer[i] = 0;
+		}
 
-		faults = p->numa_faults[nid];
+		/* Find maximum private faults */
+		faults = p->numa_faults[task_faults_idx(nid, 1)];
 		if (faults > max_faults) {
 			max_faults = faults;
 			max_nid = nid;
@@ -886,16 +897,17 @@ static void task_numa_placement(struct task_struct *p)
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int node, int pages, bool migrated)
+void task_numa_fault(int last_nid, int node, int pages, bool migrated)
 {
 	struct task_struct *p = current;
+	int priv = (cpu_to_node(task_cpu(p)) == last_nid);
 
 	if (!sched_feat_numa(NUMA))
 		return;
 
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults)) {
-		int size = sizeof(*p->numa_faults) * nr_node_ids;
+		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
 
 		/* numa_faults and numa_faults_buffer share the allocation */
 		p->numa_faults = kzalloc(size * 2, GFP_KERNEL);
@@ -903,7 +915,7 @@ void task_numa_fault(int node, int pages, bool migrated)
 			return;
 
 		BUG_ON(p->numa_faults_buffer);
-		p->numa_faults_buffer = p->numa_faults + nr_node_ids;
+		p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
 	}
 
 	/*
@@ -917,7 +929,7 @@ void task_numa_fault(int node, int pages, bool migrated)
 	task_numa_placement(p);
 
 	/* Record the fault, double the weight if pages were migrated */
-	p->numa_faults_buffer[node] += pages << migrated;
+	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages << migrated;
 }
 
 static void reset_ptenuma_scan(struct task_struct *p)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e2f7f5aa..7cd7114 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1292,7 +1292,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
-	int target_nid;
+	int target_nid, last_nid;
 	int current_nid = -1;
 	bool migrated;
 
@@ -1307,6 +1307,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (current_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
+	last_nid = page_nid_last(page);
 	target_nid = mpol_misplaced(page, vma, haddr);
 	if (target_nid == -1) {
 		put_page(page);
@@ -1332,7 +1333,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!migrated)
 		goto check_same;
 
-	task_numa_fault(target_nid, HPAGE_PMD_NR, true);
+	task_numa_fault(last_nid, target_nid, HPAGE_PMD_NR, true);
 	return 0;
 
 check_same:
@@ -1347,7 +1348,7 @@ clear_pmdnuma:
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
 	if (current_nid != -1)
-		task_numa_fault(current_nid, HPAGE_PMD_NR, false);
+		task_numa_fault(last_nid, current_nid, HPAGE_PMD_NR, false);
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index ba94dec..c28bf52 100644
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
 
@@ -3566,6 +3566,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return 0;
 	}
 
+	last_nid = page_nid_last(page);
 	current_nid = page_to_nid(page);
 	target_nid = numa_migrate_prep(page, vma, addr, current_nid);
 	pte_unmap_unlock(ptep, ptl);
@@ -3586,7 +3587,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 out:
 	if (current_nid != -1)
-		task_numa_fault(current_nid, 1, migrated);
+		task_numa_fault(last_nid, current_nid, 1, migrated);
 	return 0;
 }
 
@@ -3602,6 +3603,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	bool numa = false;
 	int local_nid = numa_node_id();
+	int last_nid;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3654,6 +3656,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * migrated to.
 		 */
 		curr_nid = local_nid;
+		last_nid = page_nid_last(page);
 		target_nid = numa_migrate_prep(page, vma, addr,
 					       page_to_nid(page));
 		if (target_nid == -1) {
@@ -3666,7 +3669,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
