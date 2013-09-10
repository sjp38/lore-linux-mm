Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 601A56B0074
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:33:00 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 25/50] sched: Add infrastructure for split shared/private accounting of NUMA hinting faults
Date: Tue, 10 Sep 2013 10:32:05 +0100
Message-Id: <1378805550-29949-26-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Ideally it would be possible to distinguish between NUMA hinting faults
that are private to a task and those that are shared.  This patch prepares
infrastructure for separately accounting shared and private faults by
allocating the necessary buffers and passing in relevant information. For
now, all faults are treated as private and detection will be introduced
later.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |  5 +++--
 kernel/sched/fair.c   | 46 +++++++++++++++++++++++++++++++++++-----------
 mm/huge_memory.c      |  5 +++--
 mm/memory.c           |  8 ++++++--
 4 files changed, 47 insertions(+), 17 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index a2e661d..6eb8fa6 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1430,10 +1430,11 @@ struct task_struct {
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
index 350c411..108f357 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -886,6 +886,20 @@ static unsigned int task_scan_max(struct task_struct *p)
  */
 unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
 
+static inline int task_faults_idx(int nid, int priv)
+{
+	return 2 * nid + priv;
+}
+
+static inline unsigned long task_faults(struct task_struct *p, int nid)
+{
+	if (!p->numa_faults)
+		return 0;
+
+	return p->numa_faults[task_faults_idx(nid, 0)] +
+		p->numa_faults[task_faults_idx(nid, 1)];
+}
+
 static unsigned long weighted_cpuload(const int cpu);
 
 
@@ -928,13 +942,19 @@ static void task_numa_placement(struct task_struct *p)
 	/* Find the node with the highest number of faults */
 	for_each_online_node(nid) {
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
@@ -970,16 +990,20 @@ static void task_numa_placement(struct task_struct *p)
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int node, int pages, bool migrated)
+void task_numa_fault(int last_nid, int node, int pages, bool migrated)
 {
 	struct task_struct *p = current;
+	int priv;
 
 	if (!numabalancing_enabled)
 		return;
 
+	/* For now, do not attempt to detect private/shared accesses */
+	priv = 1;
+
 	/* Allocate buffer to track faults on a per-node basis */
 	if (unlikely(!p->numa_faults)) {
-		int size = sizeof(*p->numa_faults) * nr_node_ids;
+		int size = sizeof(*p->numa_faults) * 2 * nr_node_ids;
 
 		/* numa_faults and numa_faults_buffer share the allocation */
 		p->numa_faults = kzalloc(size * 2, GFP_KERNEL|__GFP_NOWARN);
@@ -987,7 +1011,7 @@ void task_numa_fault(int node, int pages, bool migrated)
 			return;
 
 		BUG_ON(p->numa_faults_buffer);
-		p->numa_faults_buffer = p->numa_faults + nr_node_ids;
+		p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
 	}
 
 	/*
@@ -1005,7 +1029,7 @@ void task_numa_fault(int node, int pages, bool migrated)
 
 	task_numa_placement(p);
 
-	p->numa_faults_buffer[node] += pages;
+	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
 }
 
 static void reset_ptenuma_scan(struct task_struct *p)
@@ -4099,7 +4123,7 @@ static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
 		return false;
 
 	if (dst_nid == p->numa_preferred_nid ||
-	    p->numa_faults[dst_nid] > p->numa_faults[src_nid])
+	    task_faults(p, dst_nid) > task_faults(p, src_nid))
 		return true;
 
 	return false;
@@ -4123,7 +4147,7 @@ static bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
 	    p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
 		return false;
 
-	if (p->numa_faults[dst_nid] < p->numa_faults[src_nid])
+	if (task_faults(p, dst_nid) < task_faults(p, src_nid))
  		return true;
  
  	return false;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 065a31d..ca66a8a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1294,7 +1294,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
 	int page_nid = -1, this_nid = numa_node_id();
-	int target_nid;
+	int target_nid, last_nid = -1;
 	bool page_locked;
 	bool migrated = false;
 
@@ -1305,6 +1305,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	page = pmd_page(pmd);
 	BUG_ON(is_huge_zero_page(page));
 	page_nid = page_to_nid(page);
+	last_nid = page_nid_last(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
 	if (page_nid == this_nid)
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
@@ -1376,7 +1377,7 @@ out:
 		page_unlock_anon_vma_read(anon_vma);
 
 	if (page_nid != -1)
-		task_numa_fault(page_nid, HPAGE_PMD_NR, migrated);
+		task_numa_fault(last_nid, page_nid, HPAGE_PMD_NR, migrated);
 
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 86c3caf..bd016c2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3547,6 +3547,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page = NULL;
 	spinlock_t *ptl;
 	int page_nid = -1;
+	int last_nid;
 	int target_nid;
 	bool migrated = false;
 
@@ -3577,6 +3578,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 	BUG_ON(is_zero_pfn(page_to_pfn(page)));
 
+	last_nid = page_nid_last(page);
 	page_nid = page_to_nid(page);
 	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 	pte_unmap_unlock(ptep, ptl);
@@ -3592,7 +3594,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 out:
 	if (page_nid != -1)
-		task_numa_fault(page_nid, 1, migrated);
+		task_numa_fault(last_nid, page_nid, 1, migrated);
 	return 0;
 }
 
@@ -3607,6 +3609,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
+	int last_nid;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3654,6 +3657,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(page_mapcount(page) != 1))
 			continue;
 
+		last_nid = page_nid_last(page);
 		page_nid = page_to_nid(page);
 		target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 		pte_unmap_unlock(pte, ptl);
@@ -3666,7 +3670,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 
 		if (page_nid != -1)
-			task_numa_fault(page_nid, 1, migrated);
+			task_numa_fault(last_nid, page_nid, 1, migrated);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
