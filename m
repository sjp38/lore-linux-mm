Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2F24F6B00A2
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 02:27:59 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/2] [BUGFIX] pagemap: fix pfn calculation for hugepage
Date: Fri, 19 Mar 2010 15:26:36 +0900
Message-Id: <1268979996-12297-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

When we look into pagemap using page-types with option -p, the value
of pfn for hugepages looks wrong (see below.)
This is because pte was evaluated only once for one vma
although it should be updated for each hugepage. This patch fixes it.

$ page-types -p 3277 -Nl -b huge
voffset   offset  len     flags
7f21e8a00 11e400  1       ___U___________H_G________________
7f21e8a01 11e401  1ff     ________________TG________________
7f21e8c00 11e400  1       ___U___________H_G________________
7f21e8c01 11e401  1ff     ________________TG________________
             ^^^
             should not be the same

With this patch applied:

$ page-types -p 3386 -Nl -b huge
voffset   offset   len    flags
7fec7a600 112c00   1      ___UD__________H_G________________
7fec7a601 112c01   1ff    ________________TG________________
7fec7a800 113200   1      ___UD__________H_G________________
7fec7a801 113201   1ff    ________________TG________________
             ^^^
             OK

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c |   37 +++++++++++++++++++------------------
 include/linux/mm.h |    4 ++--
 mm/pagewalk.c      |   14 ++++----------
 3 files changed, 25 insertions(+), 30 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2a3ef17..cc14479 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -662,31 +662,32 @@ static u64 huge_pte_to_pagemap_entry(pte_t pte, int offset)
 	return pme;
 }
 
-static int pagemap_hugetlb_range(pte_t *pte, unsigned long addr,
+/* This function walks only within @vma */
+static int pagemap_hugetlb_range(struct vm_area_struct *vma, unsigned long addr,
 				 unsigned long end, struct mm_walk *walk)
 {
-	struct vm_area_struct *vma;
+	struct mm_struct *mm = walk->mm;
 	struct pagemapread *pm = walk->private;
 	struct hstate *hs = NULL;
 	int err = 0;
-
-	vma = find_vma(walk->mm, addr);
-	if (vma)
-		hs = hstate_vma(vma);
+	pte_t *pte = NULL;
+
+	BUG_ON(!mm);
+	BUG_ON(!vma || !is_vm_hugetlb_page(vma));
+	BUG_ON(addr < vma->vm_start || addr >= vma->vm_end);
+	hs = hstate_vma(vma);
+	BUG_ON(!hs);
+	pte = huge_pte_offset(mm, addr);
+	if (!pte)
+		return err;
 	for (; addr != end; addr += PAGE_SIZE) {
 		u64 pfn = PM_NOT_PRESENT;
-
-		if (vma && (addr >= vma->vm_end)) {
-			vma = find_vma(walk->mm, addr);
-			if (vma)
-				hs = hstate_vma(vma);
-		}
-
-		if (vma && (vma->vm_start <= addr) && is_vm_hugetlb_page(vma)) {
-			/* calculate pfn of the "raw" page in the hugepage. */
-			int offset = (addr & ~huge_page_mask(hs)) >> PAGE_SHIFT;
-			pfn = huge_pte_to_pagemap_entry(*pte, offset);
-		}
+		/* calculate pfn of the "raw" page in the hugepage. */
+		int offset = (addr & ~huge_page_mask(hs)) >> PAGE_SHIFT;
+		/* next hugepage */
+		if (!offset)
+			pte = huge_pte_offset(mm, addr);
+		pfn = huge_pte_to_pagemap_entry(*pte, offset);
 		err = add_to_pagemap(addr, pfn, pm);
 		if (err)
 			return err;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3899395..5faafc2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -783,8 +783,8 @@ struct mm_walk {
 	int (*pmd_entry)(pmd_t *, unsigned long, unsigned long, struct mm_walk *);
 	int (*pte_entry)(pte_t *, unsigned long, unsigned long, struct mm_walk *);
 	int (*pte_hole)(unsigned long, unsigned long, struct mm_walk *);
-	int (*hugetlb_entry)(pte_t *, unsigned long, unsigned long,
-			     struct mm_walk *);
+	int (*hugetlb_entry)(struct vm_area_struct *,
+			     unsigned long, unsigned long, struct mm_walk *);
 	struct mm_struct *mm;
 	void *private;
 };
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 7b47a57..3148dc5 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -128,20 +128,14 @@ int walk_page_range(unsigned long addr, unsigned long end,
 		vma = find_vma(walk->mm, addr);
 #ifdef CONFIG_HUGETLB_PAGE
 		if (vma && is_vm_hugetlb_page(vma)) {
-			pte_t *pte;
-			struct hstate *hs;
-
 			if (vma->vm_end < next)
 				next = vma->vm_end;
-			hs = hstate_vma(vma);
-			pte = huge_pte_offset(walk->mm,
-					      addr & huge_page_mask(hs));
-			if (pte && !huge_pte_none(huge_ptep_get(pte))
-			    && walk->hugetlb_entry)
-				err = walk->hugetlb_entry(pte, addr,
-							  next, walk);
+			if (walk->hugetlb_entry)
+				err = walk->hugetlb_entry(vma, addr, next,
+							  walk);
 			if (err)
 				break;
+			pgd = pgd_offset(walk->mm, next);
 			continue;
 		}
 #endif
-- 
1.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
