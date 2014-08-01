Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id D6B94900002
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 15:21:19 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id f12so4490304qad.3
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 12:21:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hl16si17236325qcb.1.2014.08.01.12.21.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Aug 2014 12:21:19 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v6 13/13] mincore: apply page table walker on do_mincore()
Date: Fri,  1 Aug 2014 15:20:49 -0400
Message-Id: <1406920849-25908-14-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch makes do_mincore() use walk_page_vma(), which reduces many lines
of code by using common page table walk code.

ChangeLog v5:
- fix buffer overflow

ChangeLog v4:
- remove redundant vma

ChangeLog v3:
- add NULL vma check in mincore_unmapped_range()
- don't use pte_entry()

ChangeLog v2:
- change type of args of callbacks to void *
- move definition of mincore_walk to the start of the function to fix compiler
  warning

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/huge_memory.c |  20 -------
 mm/mincore.c     | 169 +++++++++++++++++++------------------------------------
 2 files changed, 59 insertions(+), 130 deletions(-)

diff --git mmotm-2014-07-30-15-57.orig/mm/huge_memory.c mmotm-2014-07-30-15-57/mm/huge_memory.c
index 0ca83f1a76f8..22df1e18bd61 100644
--- mmotm-2014-07-30-15-57.orig/mm/huge_memory.c
+++ mmotm-2014-07-30-15-57/mm/huge_memory.c
@@ -1423,26 +1423,6 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
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
diff --git mmotm-2014-07-30-15-57.orig/mm/mincore.c mmotm-2014-07-30-15-57/mm/mincore.c
index 725c80961048..0e548fbce19e 100644
--- mmotm-2014-07-30-15-57.orig/mm/mincore.c
+++ mmotm-2014-07-30-15-57/mm/mincore.c
@@ -19,38 +19,26 @@
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 
-static void mincore_hugetlb_page_range(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
-				unsigned char *vec)
+static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
+			unsigned long end, struct mm_walk *walk)
 {
+	int err = 0;
 #ifdef CONFIG_HUGETLB_PAGE
-	struct hstate *h;
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
+	walk->private = vec;
 #else
 	BUG();
 #endif
+	return err;
 }
 
 /*
@@ -94,14 +82,15 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 	return present;
 }
 
-static void mincore_unmapped_range(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
-				unsigned char *vec)
+static int mincore_unmapped_range(unsigned long addr, unsigned long end,
+				   struct mm_walk *walk)
 {
+	struct vm_area_struct *vma = walk->vma;
+	unsigned char *vec = walk->private;
 	unsigned long nr = (end - addr) >> PAGE_SHIFT;
 	int i;
 
-	if (vma->vm_file) {
+	if (vma && vma->vm_file) {
 		pgoff_t pgoff;
 
 		pgoff = linear_page_index(vma, addr);
@@ -111,25 +100,40 @@ static void mincore_unmapped_range(struct vm_area_struct *vma,
 		for (i = 0; i < nr; i++)
 			vec[i] = 0;
 	}
+	walk->private += nr;
+	return 0;
 }
 
-static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-			unsigned long addr, unsigned long end,
-			unsigned char *vec)
+static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
+			struct mm_walk *walk)
 {
-	unsigned long next;
 	spinlock_t *ptl;
+	struct vm_area_struct *vma = walk->vma;
 	pte_t *ptep;
 
-	ptep = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+		memset(walk->private, 1, (end - addr) >> PAGE_SHIFT);
+		walk->private += (end - addr) >> PAGE_SHIFT;
+		spin_unlock(ptl);
+		return 0;
+	}
+
+	if (pmd_trans_unstable(pmd)) {
+		mincore_unmapped_range(addr, end, walk);
+		return 0;
+	}
+
+	ptep = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	for (; addr != end; ptep++, addr += PAGE_SIZE) {
 		pte_t pte = *ptep;
 		pgoff_t pgoff;
+		unsigned char *vec = walk->private;
 
-		next = addr + PAGE_SIZE;
-		if (pte_none(pte))
-			mincore_unmapped_range(vma, addr, next, vec);
-		else if (pte_present(pte))
+		if (pte_none(pte)) {
+			mincore_unmapped_range(addr, addr + PAGE_SIZE, walk);
+			continue;
+		}
+		if (pte_present(pte))
 			*vec = 1;
 		else if (pte_file(pte)) {
 			pgoff = pte_to_pgoff(pte);
@@ -151,70 +155,11 @@ static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 #endif
 			}
 		}
-		vec++;
-	} while (ptep++, addr = next, addr != end);
+		walk->private++;
+	}
 	pte_unmap_unlock(ptep - 1, ptl);
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
-		}
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
-}
-
-static void mincore_page_range(struct vm_area_struct *vma,
-			unsigned long addr, unsigned long end,
-			unsigned char *vec)
-{
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
+	cond_resched();
+	return 0;
 }
 
 /*
@@ -226,18 +171,22 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 {
 	struct vm_area_struct *vma;
 	unsigned long end;
+	int err;
+	struct mm_walk mincore_walk = {
+		.pmd_entry = mincore_pte_range,
+		.pte_hole = mincore_unmapped_range,
+		.hugetlb_entry = mincore_hugetlb,
+		.private = vec,
+	};
 
 	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
-
+	mincore_walk.mm = vma->vm_mm;
 	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
-
-	if (is_vm_hugetlb_page(vma))
-		mincore_hugetlb_page_range(vma, addr, end, vec);
-	else
-		mincore_page_range(vma, addr, end, vec);
-
+	err = walk_page_range(addr, end, &mincore_walk);
+	if (err < 0)
+		return err;
 	return (end - addr) >> PAGE_SHIFT;
 }
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
