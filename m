Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id A08796B007D
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:08 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/49] mm: Count the number of pages affected in change_protection()
Date: Fri,  7 Dec 2012 10:23:09 +0000
Message-Id: <1354875832-9700-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

This will be used for three kinds of purposes:

 - to optimize mprotect()

 - to speed up working set scanning for working set areas that
   have not been touched

 - to more accurately scan per real working set

No change in functionality from this patch.

Suggested-by: Ingo Molnar <mingo@kernel.org>
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
 include/linux/hugetlb.h |    8 +++++--
 include/linux/mm.h      |    3 +++
 mm/hugetlb.c            |   10 ++++++--
 mm/mprotect.c           |   58 +++++++++++++++++++++++++++++++++++------------
 4 files changed, 61 insertions(+), 18 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2251648..06e691b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -87,7 +87,7 @@ struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
 				pud_t *pud, int write);
 int pmd_huge(pmd_t pmd);
 int pud_huge(pud_t pmd);
-void hugetlb_change_protection(struct vm_area_struct *vma,
+unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot);
 
 #else /* !CONFIG_HUGETLB_PAGE */
@@ -132,7 +132,11 @@ static inline void copy_huge_page(struct page *dst, struct page *src)
 {
 }
 
-#define hugetlb_change_protection(vma, address, end, newprot)
+static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
+		unsigned long address, unsigned long end, pgprot_t newprot)
+{
+	return 0;
+}
 
 static inline void __unmap_hugepage_range_final(struct mmu_gather *tlb,
 			struct vm_area_struct *vma, unsigned long start,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcaab4e..1856c62 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1078,6 +1078,9 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
 extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long old_len, unsigned long new_len,
 			       unsigned long flags, unsigned long new_addr);
+extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
+			      unsigned long end, pgprot_t newprot,
+			      int dirty_accountable);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
 			  unsigned long end, unsigned long newflags);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 59a0059..712895e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3014,7 +3014,7 @@ same_page:
 	return i ? i : -EFAULT;
 }
 
-void hugetlb_change_protection(struct vm_area_struct *vma,
+unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -3022,6 +3022,7 @@ void hugetlb_change_protection(struct vm_area_struct *vma,
 	pte_t *ptep;
 	pte_t pte;
 	struct hstate *h = hstate_vma(vma);
+	unsigned long pages = 0;
 
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
@@ -3032,12 +3033,15 @@ void hugetlb_change_protection(struct vm_area_struct *vma,
 		ptep = huge_pte_offset(mm, address);
 		if (!ptep)
 			continue;
-		if (huge_pmd_unshare(mm, &address, ptep))
+		if (huge_pmd_unshare(mm, &address, ptep)) {
+			pages++;
 			continue;
+		}
 		if (!huge_pte_none(huge_ptep_get(ptep))) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
 			set_huge_pte_at(mm, address, ptep, pte);
+			pages++;
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
@@ -3049,6 +3053,8 @@ void hugetlb_change_protection(struct vm_area_struct *vma,
 	 */
 	flush_tlb_range(vma, start, end);
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+
+	return pages << h->order;
 }
 
 int hugetlb_reserve_pages(struct inode *inode,
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a409926..1e265be 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -35,12 +35,13 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 }
 #endif
 
-static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
+static unsigned long change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
+	unsigned long pages = 0;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -60,6 +61,7 @@ static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 				ptent = pte_mkwrite(ptent);
 
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
+			pages++;
 		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
@@ -72,18 +74,22 @@ static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 				set_pte_at(mm, addr, pte,
 					swp_entry_to_pte(entry));
 			}
+			pages++;
 		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
+
+	return pages;
 }
 
-static inline void change_pmd_range(struct vm_area_struct *vma, pud_t *pud,
+static inline unsigned long change_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
 	pmd_t *pmd;
 	unsigned long next;
+	unsigned long pages = 0;
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -91,35 +97,42 @@ static inline void change_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
 				split_huge_page_pmd(vma->vm_mm, pmd);
-			else if (change_huge_pmd(vma, pmd, addr, newprot))
+			else if (change_huge_pmd(vma, pmd, addr, newprot)) {
+				pages += HPAGE_PMD_NR;
 				continue;
+			}
 			/* fall through */
 		}
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		change_pte_range(vma->vm_mm, pmd, addr, next, newprot,
+		pages += change_pte_range(vma->vm_mm, pmd, addr, next, newprot,
 				 dirty_accountable);
 	} while (pmd++, addr = next, addr != end);
+
+	return pages;
 }
 
-static inline void change_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+static inline unsigned long change_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
 	pud_t *pud;
 	unsigned long next;
+	unsigned long pages = 0;
 
 	pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		change_pmd_range(vma, pud, addr, next, newprot,
+		pages += change_pmd_range(vma, pud, addr, next, newprot,
 				 dirty_accountable);
 	} while (pud++, addr = next, addr != end);
+
+	return pages;
 }
 
-static void change_protection(struct vm_area_struct *vma,
+static unsigned long change_protection_range(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
@@ -127,6 +140,7 @@ static void change_protection(struct vm_area_struct *vma,
 	pgd_t *pgd;
 	unsigned long next;
 	unsigned long start = addr;
+	unsigned long pages = 0;
 
 	BUG_ON(addr >= end);
 	pgd = pgd_offset(mm, addr);
@@ -135,10 +149,30 @@ static void change_protection(struct vm_area_struct *vma,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		change_pud_range(vma, pgd, addr, next, newprot,
+		pages += change_pud_range(vma, pgd, addr, next, newprot,
 				 dirty_accountable);
 	} while (pgd++, addr = next, addr != end);
+
 	flush_tlb_range(vma, start, end);
+
+	return pages;
+}
+
+unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
+		       unsigned long end, pgprot_t newprot,
+		       int dirty_accountable)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long pages;
+
+	mmu_notifier_invalidate_range_start(mm, start, end);
+	if (is_vm_hugetlb_page(vma))
+		pages = hugetlb_change_protection(vma, start, end, newprot);
+	else
+		pages = change_protection_range(vma, start, end, newprot, dirty_accountable);
+	mmu_notifier_invalidate_range_end(mm, start, end);
+
+	return pages;
 }
 
 int
@@ -213,12 +247,8 @@ success:
 		dirty_accountable = 1;
 	}
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
-	if (is_vm_hugetlb_page(vma))
-		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
-	else
-		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
+
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	perf_event_mmap(vma);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
