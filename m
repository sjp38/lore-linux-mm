Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2CE676B00A6
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:51 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 31/49] mm: numa: Migrate pages handled during a pmd_numa hinting fault
Date: Fri,  7 Dec 2012 10:23:34 +0000
Message-Id: <1354875832-9700-32-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

To say that the PMD handling code was incorrectly transferred from autonuma
is an understatement. The intention was to handle a PMDs worth of pages
in the same fault and effectively batch the taking of the PTL and page
migration. The copied version instead has the impact of clearing a number
of pte_numa PTE entries and whether any page migration takes place depends
on racing. This just happens to work in some cases.

This patch handles pte_numa faults in batch when a pmd_numa fault is
handled. The pages are migrated if they are currently misplaced.
Essentially this is making an assumption that NUMA locality is
on a PMD boundary but that could be addressed by only setting
pmd_numa if all the pages within that PMD are on the same node
if necessary.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/memory.c   |   51 ++++++++++++++++++++++++++++++++++-----------------
 mm/mprotect.c |   25 ++++++++++++++++++++-----
 2 files changed, 54 insertions(+), 22 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 47f5dd1..6a1e534 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3449,6 +3449,18 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
+int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
+				unsigned long addr, int current_nid)
+{
+	get_page(page);
+
+	count_vm_numa_event(NUMA_HINT_FAULTS);
+	if (current_nid == numa_node_id())
+		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
+
+	return mpol_misplaced(page, vma, addr);
+}
+
 int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
 {
@@ -3477,18 +3489,14 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	set_pte_at(mm, addr, ptep, pte);
 	update_mmu_cache(vma, addr, ptep);
 
-	count_vm_numa_event(NUMA_HINT_FAULTS);
 	page = vm_normal_page(vma, addr, pte);
 	if (!page) {
 		pte_unmap_unlock(ptep, ptl);
 		return 0;
 	}
 
-	get_page(page);
 	current_nid = page_to_nid(page);
-	if (current_nid == numa_node_id())
-		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
-	target_nid = mpol_misplaced(page, vma, addr);
+	target_nid = numa_migrate_prep(page, vma, addr, current_nid);
 	pte_unmap_unlock(ptep, ptl);
 	if (target_nid == -1) {
 		/*
@@ -3505,7 +3513,8 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		current_nid = target_nid;
 
 out:
-	task_numa_fault(current_nid, 1);
+	if (current_nid != -1)
+		task_numa_fault(current_nid, 1);
 	return 0;
 }
 
@@ -3521,8 +3530,6 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	bool numa = false;
 	int local_nid = numa_node_id();
-	unsigned long nr_faults = 0;
-	unsigned long nr_faults_local = 0;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3545,7 +3552,8 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
 		pte_t pteval = *pte;
 		struct page *page;
-		int curr_nid;
+		int curr_nid = local_nid;
+		int target_nid;
 		if (!pte_present(pteval))
 			continue;
 		if (!pte_numa(pteval))
@@ -3566,21 +3574,30 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		/* only check non-shared pages */
 		if (unlikely(page_mapcount(page) != 1))
 			continue;
-		pte_unmap_unlock(pte, ptl);
 
-		curr_nid = page_to_nid(page);
-		task_numa_fault(curr_nid, 1);
+		/*
+		 * Note that the NUMA fault is later accounted to either
+		 * the node that is currently running or where the page is
+		 * migrated to.
+		 */
+		curr_nid = local_nid;
+		target_nid = numa_migrate_prep(page, vma, addr,
+					       page_to_nid(page));
+		if (target_nid == -1) {
+			put_page(page);
+			continue;
+		}
 
-		nr_faults++;
-		if (curr_nid == local_nid)
-			nr_faults_local++;
+		/* Migrate to the requested node */
+		pte_unmap_unlock(pte, ptl);
+		if (migrate_misplaced_page(page, target_nid))
+			curr_nid = target_nid;
+		task_numa_fault(curr_nid, 1);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
 	pte_unmap_unlock(orig_pte, ptl);
 
-	count_vm_numa_events(NUMA_HINT_FAULTS, nr_faults);
-	count_vm_numa_events(NUMA_HINT_FAULTS_LOCAL, nr_faults_local);
 	return 0;
 }
 #else
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 8abf7c6..629dba1 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -37,12 +37,14 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable, int prot_numa)
+		int dirty_accountable, int prot_numa, bool *ret_all_same_node)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
+	bool all_same_node = true;
+	int last_nid = -1;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -61,6 +63,12 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 				page = vm_normal_page(vma, addr, oldpte);
 				if (page) {
+					int this_nid = page_to_nid(page);
+					if (last_nid == -1)
+						last_nid = this_nid;
+					if (last_nid != this_nid)
+						all_same_node = false;
+
 					/* only check non-shared pages */
 					if (!pte_numa(oldpte) &&
 					    page_mapcount(page) == 1) {
@@ -81,7 +89,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 			if (updated)
 				pages++;
-
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
 		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
@@ -101,6 +108,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
+	*ret_all_same_node = all_same_node;
 	return pages;
 }
 
@@ -127,6 +135,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *
 	pmd_t *pmd;
 	unsigned long next;
 	unsigned long pages = 0;
+	bool all_same_node;
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -143,9 +152,15 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		pages += change_pte_range(vma, pmd, addr, next, newprot,
-				 dirty_accountable, prot_numa);
-
-		if (prot_numa)
+				 dirty_accountable, prot_numa, &all_same_node);
+
+		/*
+		 * If we are changing protections for NUMA hinting faults then
+		 * set pmd_numa if the examined pages were all on the same
+		 * node. This allows a regular PMD to be handled as one fault
+		 * and effectively batches the taking of the PTL
+		 */
+		if (prot_numa && all_same_node)
 			change_pmd_protnuma(vma->vm_mm, addr, pmd);
 	} while (pmd++, addr = next, addr != end);
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
