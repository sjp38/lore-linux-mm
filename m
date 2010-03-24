Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EEA606B01B7
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 01:44:00 -0400 (EDT)
Date: Wed, 24 Mar 2010 14:42:27 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mmotm] [BUGFIX] pagemap: fix pfn calculation for hugepage
Message-ID: <20100324054227.GB9336@spritzerA.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Matt Mackall <mpm@selenic.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

When we look into pagemap using page-types with option -p, the value
of pfn for hugepages looks wrong (see below.)
This is because pte was evaluated only once for one vma
although it should be updated for each hugepage. This patch fixes it.

  $ page-types -p 3277 -Nl -b huge
  voffset   offset  len     flags
  7f21e8a00 11e400  1       ___U___________H_G________________
  7f21e8a01 11e401  1ff     ________________TG________________
               ^^^
  7f21e8c00 11e400  1       ___U___________H_G________________
  7f21e8c01 11e401  1ff     ________________TG________________
               ^^^

One hugepage contains 1 head page and 511 tail pages in x86_64 and
each two lines represent each hugepage. Voffset and offset mean
virtual address and physical address in the page unit, respectively.
The different hugepages should not have the same offset value.

With this patch applied:

  $ page-types -p 3386 -Nl -b huge
  voffset   offset   len    flags
  7fec7a600 112c00   1      ___UD__________H_G________________
  7fec7a601 112c01   1ff    ________________TG________________
               ^^^
  7fec7a800 113200   1      ___UD__________H_G________________
  7fec7a801 113201   1ff    ________________TG________________
               ^^^
               OK

Changelog:
 - add hugetlb entry walker in mm/pagewalk.c
   (the idea based on Kamezawa-san's patch)

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c |   27 +++++++--------------------
 include/linux/mm.h |    4 ++--
 mm/pagewalk.c      |   47 +++++++++++++++++++++++++++++++++++++----------
 3 files changed, 46 insertions(+), 32 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2a3ef17..9635f0b 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -662,31 +662,18 @@ static u64 huge_pte_to_pagemap_entry(pte_t pte, int offset)
 	return pme;
 }
 
-static int pagemap_hugetlb_range(pte_t *pte, unsigned long addr,
-				 unsigned long end, struct mm_walk *walk)
+/* This function walks within one hugetlb entry in the single call */
+static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
+				 unsigned long addr, unsigned long end,
+				 struct mm_walk *walk)
 {
-	struct vm_area_struct *vma;
 	struct pagemapread *pm = walk->private;
-	struct hstate *hs = NULL;
 	int err = 0;
+	u64 pfn;
 
-	vma = find_vma(walk->mm, addr);
-	if (vma)
-		hs = hstate_vma(vma);
 	for (; addr != end; addr += PAGE_SIZE) {
-		u64 pfn = PM_NOT_PRESENT;
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
+		int offset = (addr & ~hmask) >> PAGE_SHIFT;
+		pfn = huge_pte_to_pagemap_entry(*pte, offset);
 		err = add_to_pagemap(addr, pfn, pm);
 		if (err)
 			return err;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3899395..24f198e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -783,8 +783,8 @@ struct mm_walk {
 	int (*pmd_entry)(pmd_t *, unsigned long, unsigned long, struct mm_walk *);
 	int (*pte_entry)(pte_t *, unsigned long, unsigned long, struct mm_walk *);
 	int (*pte_hole)(unsigned long, unsigned long, struct mm_walk *);
-	int (*hugetlb_entry)(pte_t *, unsigned long, unsigned long,
-			     struct mm_walk *);
+	int (*hugetlb_entry)(pte_t *, unsigned long,
+			     unsigned long, unsigned long, struct mm_walk *);
 	struct mm_struct *mm;
 	void *private;
 };
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 7b47a57..f77a568 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -80,6 +80,37 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	return err;
 }
 
+#ifdef CONFIG_HUGETLB_PAGE
+static unsigned long hugetlb_entry_end(struct hstate *h, unsigned long addr,
+				       unsigned long end)
+{
+	unsigned long boundary = (addr & huge_page_mask(h)) + huge_page_size(h);
+	return boundary < end ? boundary : end;
+}
+
+static int walk_hugetlb_range(struct vm_area_struct *vma,
+			      unsigned long addr, unsigned long end,
+			      struct mm_walk *walk)
+{
+	struct hstate *h = hstate_vma(vma);
+	unsigned long next;
+	unsigned long hmask = huge_page_mask(h);
+	pte_t *pte;
+	int err = 0;
+
+	do {
+		next = hugetlb_entry_end(h, addr, end);
+		pte = huge_pte_offset(walk->mm, addr & hmask);
+		if (pte && walk->hugetlb_entry)
+			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
+		if (err)
+			return err;
+	} while (addr = next, addr != end);
+
+	return err;
+}
+#endif
+
 /**
  * walk_page_range - walk a memory map's page tables with a callback
  * @mm: memory map to walk
@@ -128,20 +159,16 @@ int walk_page_range(unsigned long addr, unsigned long end,
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
+			/*
+			 * Hugepage is very tightly coupled with vma, so
+			 * walk through hugetlb entries within a given vma.
+			 */
+			err = walk_hugetlb_range(vma, addr, next, walk);
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
