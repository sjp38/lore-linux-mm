Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 52AE56B0071
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 14:15:04 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so4983524pde.12
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:15:04 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ko6si28113155pab.77.2015.01.13.11.15.01
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 11:15:02 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: account pmd page tables to the process
Date: Tue, 13 Jan 2015 21:14:16 +0200
Message-Id: <1421176456-21796-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dave noticed that unprivileged process can allocate significant amount
of memory -- >500 MiB on x86_64 -- and stay unnoticed by oom-killer and
memory cgroup. The trick is to allocate a lot of PMD page tables. Linux
kernel doesn't account PMD tables to the process, only PTE.

The use-cases below use few tricks to allocate a lot of PMD page tables
while keeping VmRSS and VmPTE low. oom_score for the process will be 0.

	#include <errno.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <sys/mman.h>
	#include <sys/prctl.h>

	#define PUD_SIZE (1UL << 30)
	#define PMD_SIZE (1UL << 21)

	#define NR_PUD 130000

	int main(void)
	{
		char *addr = NULL;
		unsigned long i;

		prctl(PR_SET_THP_DISABLE);
		for (i = 0; i < NR_PUD ; i++) {
			addr = mmap(addr + PUD_SIZE, PUD_SIZE, PROT_WRITE|PROT_READ,
					MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
			if (addr == MAP_FAILED) {
				perror("mmap");
				break;
			}
			*addr = 'x';
			munmap(addr, PMD_SIZE);
			mmap(addr, PMD_SIZE, PROT_WRITE|PROT_READ,
					MAP_ANONYMOUS|MAP_PRIVATE|MAP_FIXED, -1, 0);
			if (addr == MAP_FAILED)
				perror("re-mmap"), exit(1);
		}
		printf("PID %d consumed %lu KiB in PMD page tables\n",
				getpid(), i * 4096 >> 10);
		return pause();
	}

The patch addresses the issue by account PMD tables to the process the
same way we account PTE.

The main place where PMD tables is accounted is __pmd_alloc() and
free_pmd_range(). But there're few corner cases:

 - HugeTLB can share PMD page tables. The patch handles by accounting
   the table to all processes who share it.

 - x86 PAE pre-allocates few PMD tables on fork.

 - Architectures with FIRST_USER_ADDRESS > 0. We need to adjust sanity
   check on exit(2).

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 arch/x86/mm/pgtable.c | 13 ++++++++-----
 mm/hugetlb.c          |  8 ++++++--
 mm/memory.c           |  2 ++
 mm/mmap.c             |  9 +++++++--
 4 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 6fb6927f9e76..7f7b7005a7d5 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -190,7 +190,7 @@ void pud_populate(struct mm_struct *mm, pud_t *pudp, pmd_t *pmd)
 
 #endif	/* CONFIG_X86_PAE */
 
-static void free_pmds(pmd_t *pmds[])
+static void free_pmds(struct mm_struct *mm, pmd_t *pmds[])
 {
 	int i;
 
@@ -198,10 +198,11 @@ static void free_pmds(pmd_t *pmds[])
 		if (pmds[i]) {
 			pgtable_pmd_page_dtor(virt_to_page(pmds[i]));
 			free_page((unsigned long)pmds[i]);
+			atomic_long_dec(&mm->nr_pgtables);
 		}
 }
 
-static int preallocate_pmds(pmd_t *pmds[])
+static int preallocate_pmds(struct mm_struct *mm, pmd_t *pmds[])
 {
 	int i;
 	bool failed = false;
@@ -215,11 +216,13 @@ static int preallocate_pmds(pmd_t *pmds[])
 			pmd = NULL;
 			failed = true;
 		}
+		if (pmd)
+			atomic_long_inc(&mm->nr_pgtables);
 		pmds[i] = pmd;
 	}
 
 	if (failed) {
-		free_pmds(pmds);
+		free_pmds(mm, pmds);
 		return -ENOMEM;
 	}
 
@@ -283,7 +286,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 
 	mm->pgd = pgd;
 
-	if (preallocate_pmds(pmds) != 0)
+	if (preallocate_pmds(mm, pmds) != 0)
 		goto out_free_pgd;
 
 	if (paravirt_pgd_alloc(mm) != 0)
@@ -304,7 +307,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return pgd;
 
 out_free_pmds:
-	free_pmds(pmds);
+	free_pmds(mm, pmds);
 out_free_pgd:
 	free_page((unsigned long)pgd);
 out:
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index be0e5d0db5ec..edd1278b4965 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3558,6 +3558,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 		if (saddr) {
 			spte = huge_pte_offset(svma->vm_mm, saddr);
 			if (spte) {
+				atomic_long_inc(&mm->nr_pgtables);
 				get_page(virt_to_page(spte));
 				break;
 			}
@@ -3569,11 +3570,13 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 
 	ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
 	spin_lock(ptl);
-	if (pud_none(*pud))
+	if (pud_none(*pud)) {
 		pud_populate(mm, pud,
 				(pmd_t *)((unsigned long)spte & PAGE_MASK));
-	else
+	} else {
 		put_page(virt_to_page(spte));
+		atomic_long_dec(&mm->nr_pgtables);
+	}
 	spin_unlock(ptl);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
@@ -3604,6 +3607,7 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
 
 	pud_clear(pud);
 	put_page(virt_to_page(ptep));
+	atomic_long_dec(&mm->nr_pgtables);
 	*addr = ALIGN(*addr, HPAGE_SIZE * PTRS_PER_PTE) - HPAGE_SIZE;
 	return 1;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 2f9ee3089c20..8b6f32e1c0b5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -428,6 +428,7 @@ static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
 	pmd = pmd_offset(pud, start);
 	pud_clear(pud);
 	pmd_free_tlb(tlb, pmd, start);
+	atomic_long_dec(&tlb->mm->nr_pgtables);
 }
 
 static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
@@ -3321,6 +3322,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 	smp_wmb(); /* See comment in __pte_alloc */
 
 	spin_lock(&mm->page_table_lock);
+	atomic_long_inc(&mm->nr_pgtables);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */
 		pmd_free(mm, new);
diff --git a/mm/mmap.c b/mm/mmap.c
index 3c591112263d..d8013a6b7ebd 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2812,6 +2812,7 @@ void exit_mmap(struct mm_struct *mm)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
+	unsigned long max_nr_pgtables;
 
 	/* mm's last user has gone, and its about to be pulled down */
 	mmu_notifier_release(mm);
@@ -2852,8 +2853,12 @@ void exit_mmap(struct mm_struct *mm)
 	}
 	vm_unacct_memory(nr_accounted);
 
-	WARN_ON(atomic_long_read(&mm->nr_pgtables) >
-			(FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
+	max_nr_pgtables = round_up(FIRST_USER_ADDRESS, PMD_SIZE) >> PMD_SHIFT;
+	if (!IS_ENABLED(__PAGETABLE_PMD_FOLDED)) {
+		max_nr_pgtables +=
+			round_up(FIRST_USER_ADDRESS, PUD_SIZE) >> PUD_SHIFT;
+	}
+	WARN_ON(atomic_long_read(&mm->nr_pgtables) > max_nr_pgtables);
 }
 
 /* Insert vm structure into process list sorted by address
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
