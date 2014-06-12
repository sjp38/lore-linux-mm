Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF0C6B0074
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:48 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so6267919wib.0
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z13si3730989wjr.48.2014.06.12.14.48.45
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 14:48:46 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v2 11/11] mincore: apply page table walker on do_mincore()
Date: Thu, 12 Jun 2014 17:48:11 -0400
Message-Id: <1402609691-13950-12-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

This patch makes do_mincore() use walk_page_vma(), which reduces many lines
of code by using common page table walk code.

ChangeLog v2:
- change type of args of callbacks to void *
- move definition of mincore_walk to the start of the function to fix compiler
  warning

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/huge_memory.c |  20 ------
 mm/mincore.c     | 195 +++++++++++++++++++------------------------------------
 2 files changed, 67 insertions(+), 148 deletions(-)

diff --git mmotm-2014-05-21-16-57.orig/mm/huge_memory.c mmotm-2014-05-21-16-57/mm/huge_memory.c
index 6fd0668d4e1d..2671a9621d0e 100644
--- mmotm-2014-05-21-16-57.orig/mm/huge_memory.c
+++ mmotm-2014-05-21-16-57/mm/huge_memory.c
@@ -1379,26 +1379,6 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	return ret;
 }
 
-int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, unsigned long end,
-		unsigned char *vec)
-{
-	spinlock_t *ptl;
-	int ret = 0;
-
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		/*
-		 * All logical pages in the range are present
-		 * if backed by a huge page.
-		 */
-		spin_unlock(ptl);
-		memset(vec, 1, (end - addr) >> PAGE_SHIFT);
-		ret = 1;
-	}
-
-	return ret;
-}
-
 int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		  unsigned long old_addr,
 		  unsigned long new_addr, unsigned long old_end,
diff --git mmotm-2014-05-21-16-57.orig/mm/mincore.c mmotm-2014-05-21-16-57/mm/mincore.c
index 725c80961048..d53b07548ce1 100644
--- mmotm-2014-05-21-16-57.orig/mm/mincore.c
+++ mmotm-2014-05-21-16-57/mm/mincore.c
@@ -19,38 +19,28 @@
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 
-static void mincore_hugetlb_page_range(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
-				unsigned char *vec)
+static int mincore_hugetlb(void *entry, unsigned long addr,
+			unsigned long end, struct mm_walk *walk)
 {
+	int err = 0;
 #ifdef CONFIG_HUGETLB_PAGE
-	struct hstate *h;
+	pte_t *pte = entry;
+	unsigned char present;
+	unsigned char *vec = walk->private;
 
-	h = hstate_vma(vma);
-	while (1) {
-		unsigned char present;
-		pte_t *ptep;
-		/*
-		 * Huge pages are always in RAM for now, but
-		 * theoretically it needs to be checked.
-		 */
-		ptep = huge_pte_offset(current->mm,
-				       addr & huge_page_mask(h));
-		present = ptep && !huge_pte_none(huge_ptep_get(ptep));
-		while (1) {
-			*vec = present;
-			vec++;
-			addr += PAGE_SIZE;
-			if (addr == end)
-				return;
-			/* check hugepage border */
-			if (!(addr & ~huge_page_mask(h)))
-				break;
-		}
-	}
+	/*
+	 * Hugepages under user process are always in RAM and never
+	 * swapped out, but theoretically it needs to be checked.
+	 */
+	present = pte && !huge_pte_none(huge_ptep_get(pte));
+	for (; addr != end; vec++, addr += PAGE_SIZE)
+		*vec = present;
+	cond_resched();
+	walk->private += (end - addr) >> PAGE_SHIFT;
 #else
 	BUG();
 #endif
+	return err;
 }
 
 /*
@@ -94,10 +84,11 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 	return present;
 }
 
-static void mincore_unmapped_range(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
-				unsigned char *vec)
+static int mincore_hole(unsigned long addr, unsigned long end,
+				struct mm_walk *walk)
 {
+	struct vm_area_struct *vma = walk->vma;
+	unsigned char *vec = walk->private;
 	unsigned long nr = (end - addr) >> PAGE_SHIFT;
 	int i;
 
@@ -111,110 +102,50 @@ static void mincore_unmapped_range(struct vm_area_struct *vma,
 		for (i = 0; i < nr; i++)
 			vec[i] = 0;
 	}
+	walk->private += nr;
+	return 0;
 }
 
-static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-			unsigned long addr, unsigned long end,
-			unsigned char *vec)
+static int mincore_pte(void *entry, unsigned long addr, unsigned long end,
+			struct mm_walk *walk)
 {
-	unsigned long next;
-	spinlock_t *ptl;
-	pte_t *ptep;
-
-	ptep = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
-		pte_t pte = *ptep;
-		pgoff_t pgoff;
-
-		next = addr + PAGE_SIZE;
-		if (pte_none(pte))
-			mincore_unmapped_range(vma, addr, next, vec);
-		else if (pte_present(pte))
+	pte_t *pte = entry;
+	struct vm_area_struct *vma = walk->vma;
+	unsigned char *vec = walk->private;
+	pgoff_t pgoff;
+
+	if (pte_present(*pte))
+		*vec = 1;
+	else if (pte_file(*pte)) {
+		pgoff = pte_to_pgoff(*pte);
+		*vec = mincore_page(vma->vm_file->f_mapping, pgoff);
+	} else { /* pte is a swap entry */
+		swp_entry_t entry = pte_to_swp_entry(*pte);
+
+		if (is_migration_entry(entry)) {
+			/* migration entries are always uptodate */
 			*vec = 1;
-		else if (pte_file(pte)) {
-			pgoff = pte_to_pgoff(pte);
-			*vec = mincore_page(vma->vm_file->f_mapping, pgoff);
-		} else { /* pte is a swap entry */
-			swp_entry_t entry = pte_to_swp_entry(pte);
-
-			if (is_migration_entry(entry)) {
-				/* migration entries are always uptodate */
-				*vec = 1;
-			} else {
+		} else {
 #ifdef CONFIG_SWAP
-				pgoff = entry.val;
-				*vec = mincore_page(swap_address_space(entry),
-					pgoff);
+			pgoff = entry.val;
+			*vec = mincore_page(swap_address_space(entry),
+					    pgoff);
 #else
-				WARN_ON(1);
-				*vec = 1;
+			WARN_ON(1);
+			*vec = 1;
 #endif
-			}
-		}
-		vec++;
-	} while (ptep++, addr = next, addr != end);
-	pte_unmap_unlock(ptep - 1, ptl);
-}
-
-static void mincore_pmd_range(struct vm_area_struct *vma, pud_t *pud,
-			unsigned long addr, unsigned long end,
-			unsigned char *vec)
-{
-	unsigned long next;
-	pmd_t *pmd;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_trans_huge(*pmd)) {
-			if (mincore_huge_pmd(vma, pmd, addr, next, vec)) {
-				vec += (next - addr) >> PAGE_SHIFT;
-				continue;
-			}
-			/* fall through */
 		}
-		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
-			mincore_unmapped_range(vma, addr, next, vec);
-		else
-			mincore_pte_range(vma, pmd, addr, next, vec);
-		vec += (next - addr) >> PAGE_SHIFT;
-	} while (pmd++, addr = next, addr != end);
-}
-
-static void mincore_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
-			unsigned long addr, unsigned long end,
-			unsigned char *vec)
-{
-	unsigned long next;
-	pud_t *pud;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			mincore_unmapped_range(vma, addr, next, vec);
-		else
-			mincore_pmd_range(vma, pud, addr, next, vec);
-		vec += (next - addr) >> PAGE_SHIFT;
-	} while (pud++, addr = next, addr != end);
+	}
+	walk->private++;
+	return 0;
 }
 
-static void mincore_page_range(struct vm_area_struct *vma,
-			unsigned long addr, unsigned long end,
-			unsigned char *vec)
+static int mincore_pmd(void *entry, unsigned long addr, unsigned long end,
+			struct mm_walk *walk)
 {
-	unsigned long next;
-	pgd_t *pgd;
-
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			mincore_unmapped_range(vma, addr, next, vec);
-		else
-			mincore_pud_range(vma, pgd, addr, next, vec);
-		vec += (next - addr) >> PAGE_SHIFT;
-	} while (pgd++, addr = next, addr != end);
+	memset(walk->private, 1, (end - addr) >> PAGE_SHIFT);
+	walk->private += (end - addr) >> PAGE_SHIFT;
+	return 0;
 }
 
 /*
@@ -226,19 +157,27 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 {
 	struct vm_area_struct *vma;
 	unsigned long end;
+	int err;
+	struct mm_walk mincore_walk = {
+		.pmd_entry = mincore_pmd,
+		.pte_entry = mincore_pte,
+		.pte_hole = mincore_hole,
+		.hugetlb_entry = mincore_hugetlb,
+		.private = vec,
+	};
 
 	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
-
+	mincore_walk.mm = vma->vm_mm;
+	mincore_walk.vma = vma;
 	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
 
-	if (is_vm_hugetlb_page(vma))
-		mincore_hugetlb_page_range(vma, addr, end, vec);
+	err = walk_page_vma(vma, &mincore_walk);
+	if (err < 0)
+		return err;
 	else
-		mincore_page_range(vma, addr, end, vec);
-
-	return (end - addr) >> PAGE_SHIFT;
+		return (end - addr) >> PAGE_SHIFT;
 }
 
 /*
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
