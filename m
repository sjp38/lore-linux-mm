Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id AE1626B0074
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 03:50:53 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so95297eaa.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 00:50:52 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 1/2] sched, numa, mm: Count WS scanning against present PTEs, not virtual memory ranges
Date: Wed, 14 Nov 2012 09:50:28 +0100
Message-Id: <1352883029-7885-2-git-send-email-mingo@kernel.org>
In-Reply-To: <1352883029-7885-1-git-send-email-mingo@kernel.org>
References: <1352883029-7885-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

By accounting against the present PTEs, scanning speed reflects the
actual present (mapped) memory.

For this we modify mm/mprotect.c::change_protection() to return the
number of ptes modified. (No change in functionality.)

Suggested-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/hugetlb.h |  8 ++++++--
 include/linux/mm.h      |  6 +++---
 kernel/sched/fair.c     | 37 +++++++++++++++++++++----------------
 mm/hugetlb.c            | 10 ++++++++--
 mm/mprotect.c           | 41 ++++++++++++++++++++++++++++++-----------
 5 files changed, 68 insertions(+), 34 deletions(-)

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
index 141a28f..e6df281 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1099,7 +1099,7 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
 extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long old_len, unsigned long new_len,
 			       unsigned long flags, unsigned long new_addr);
-extern void change_protection(struct vm_area_struct *vma, unsigned long start,
+extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 			      unsigned long end, pgprot_t newprot,
 			      int dirty_accountable);
 extern int mprotect_fixup(struct vm_area_struct *vma,
@@ -1581,10 +1581,10 @@ static inline pgprot_t vma_prot_none(struct vm_area_struct *vma)
 	return pgprot_modify(vma->vm_page_prot, vm_get_page_prot(vmflags));
 }
 
-static inline void
+static inline unsigned long
 change_prot_none(struct vm_area_struct *vma, unsigned long start, unsigned long end)
 {
-	change_protection(vma, start, end, vma_prot_none(vma), 0);
+	return change_protection(vma, start, end, vma_prot_none(vma), 0);
 }
 
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 4ed0ab1..d4d708e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -915,8 +915,8 @@ void task_numa_work(struct callback_head *work)
 	struct task_struct *p = current;
 	struct mm_struct *mm = p->mm;
 	struct vm_area_struct *vma;
-	unsigned long offset, end;
-	long length;
+	unsigned long start, end;
+	long pages;
 
 	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_work));
 
@@ -945,30 +945,35 @@ void task_numa_work(struct callback_head *work)
 
 	current->numa_scan_period += jiffies_to_msecs(2);
 
-	offset = mm->numa_scan_offset;
-	length = sysctl_sched_numa_scan_size;
-	length <<= 20;
+	start = mm->numa_scan_offset;
+	pages = sysctl_sched_numa_scan_size;
+	pages <<= 20 - PAGE_SHIFT; /* MB in pages */
+	if (!pages)
+		return;
 
 	down_write(&mm->mmap_sem);
-	vma = find_vma(mm, offset);
+	vma = find_vma(mm, start);
 	if (!vma) {
 		ACCESS_ONCE(mm->numa_scan_seq)++;
-		offset = 0;
+		start = 0;
 		vma = mm->mmap;
 	}
-	for (; vma && length > 0; vma = vma->vm_next) {
+	for (; vma; vma = vma->vm_next) {
 		if (!vma_migratable(vma))
 			continue;
 
-		offset = max(offset, vma->vm_start);
-		end = min(ALIGN(offset + length, HPAGE_SIZE), vma->vm_end);
-		length -= end - offset;
-
-		change_prot_none(vma, offset, end);
-
-		offset = end;
+		do {
+			start = max(start, vma->vm_start);
+			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
+			end = min(end, vma->vm_end);
+			pages -= change_prot_none(vma, start, end);
+			start = end;
+			if (pages <= 0)
+				goto out;
+		} while (end != vma->vm_end);
 	}
-	mm->numa_scan_offset = offset;
+out:
+	mm->numa_scan_offset = start;
 	up_write(&mm->mmap_sem);
 }
 
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
index 392b124..ce0377b 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -28,12 +28,13 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
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
@@ -53,6 +54,7 @@ static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 				ptent = pte_mkwrite(ptent);
 
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
+			pages++;
 		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
@@ -65,18 +67,22 @@ static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
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
@@ -84,35 +90,42 @@ static inline void change_pmd_range(struct vm_area_struct *vma, pud_t *pud,
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
 
-static void change_protection_range(struct vm_area_struct *vma,
+static unsigned long change_protection_range(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
@@ -120,6 +133,7 @@ static void change_protection_range(struct vm_area_struct *vma,
 	pgd_t *pgd;
 	unsigned long next;
 	unsigned long start = addr;
+	unsigned long pages = 0;
 
 	BUG_ON(addr >= end);
 	pgd = pgd_offset(mm, addr);
@@ -128,24 +142,29 @@ static void change_protection_range(struct vm_area_struct *vma,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		change_pud_range(vma, pgd, addr, next, newprot,
+		pages += change_pud_range(vma, pgd, addr, next, newprot,
 				 dirty_accountable);
 	} while (pgd++, addr = next, addr != end);
 	flush_tlb_range(vma, start, end);
+
+	return pages;
 }
 
-void change_protection(struct vm_area_struct *vma, unsigned long start,
+unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 		       unsigned long end, pgprot_t newprot,
 		       int dirty_accountable)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	unsigned long pages;
 
 	mmu_notifier_invalidate_range_start(mm, start, end);
 	if (is_vm_hugetlb_page(vma))
-		hugetlb_change_protection(vma, start, end, newprot);
+		pages = hugetlb_change_protection(vma, start, end, newprot);
 	else
-		change_protection_range(vma, start, end, newprot, dirty_accountable);
+		pages = change_protection_range(vma, start, end, newprot, dirty_accountable);
 	mmu_notifier_invalidate_range_end(mm, start, end);
+
+	return pages;
 }
 
 int
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
