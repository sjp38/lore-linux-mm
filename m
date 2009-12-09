Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EBC1C60021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 21:01:40 -0500 (EST)
Message-ID: <4B1F0460.5040209@ah.jp.nec.com>
Date: Wed, 09 Dec 2009 10:58:56 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reply-To: n-horiguchi@ah.jp.nec.com
MIME-Version: 1.0
Subject: Re: + mm-hugetlb-add-hugepage-support-to-pagemap.patch added to -mm
 tree
References: <200912082239.nB8Mdi0Q019687@imap1.linux-foundation.org>
In-Reply-To: <200912082239.nB8Mdi0Q019687@imap1.linux-foundation.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, ak@linux.intel.com, apw@canonical.com, fengguang.wu@intel.com, hugh.dickins@tiscali.co.uk, lee.schermerhorn@hp.com, mel@csn.ul.ie, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Subject: mm hugetlb: add hugepage support to pagemap
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Enable extraction of the pfn of the hugepage from /proc/pid/pagemap in an
> architecture independent manner.

I want to add more description for this patch (and one fix.)

Thanks,
Naoya Horiguchi
---
This patch enables to extract pfn of the hugepage from
/proc/pid/pagemap in architecture independent manner.

Changelog v2:
- NULL check of vma

Details
=======
My test program (leak_pagemap) works as follows:
 - creat() and mmap() a file on hugetlbfs (file size is 200MB == 100 hugepages,)
 - read()/write() something on it,
 - call page-types with option -p,
 - munmap() and unlink() the file on hugetlbfs

Without my patches
------------------
$ ./leak_pagemap
             flags page-count       MB  symbolic-flags                     long-symbolic-flags
0x0000000000000000          1        0  __________________________________
0x0000000000000804          1        0  __R________M______________________ referenced,mmap
0x000000000000086c         81        0  __RU_lA____M______________________ referenced,uptodate,lru,active,mmap
0x0000000000005808          5        0  ___U_______Ma_b___________________ uptodate,mmap,anonymous,swapbacked
0x0000000000005868         12        0  ___U_lA____Ma_b___________________ uptodate,lru,active,mmap,anonymous,swapbacked
0x000000000000586c          1        0  __RU_lA____Ma_b___________________ referenced,uptodate,lru,active,mmap,anonymous,swapbacked
             total        101        0

The output of page-types don't show any hugepage.


With my patches
---------------
$ ./leak_pagemap
             flags page-count       MB  symbolic-flags                     long-symbolic-flags
0x0000000000000000          1        0  __________________________________
0x0000000000030000      51100      199  ________________TG________________ compound_tail,huge
0x0000000000028018        100        0  ___UD__________H_G________________ uptodate,dirty,compound_head,huge
0x0000000000000804          1        0  __R________M______________________ referenced,mmap
0x000000000000080c          1        0  __RU_______M______________________ referenced,uptodate,mmap
0x000000000000086c         80        0  __RU_lA____M______________________ referenced,uptodate,lru,active,mmap
0x0000000000005808          4        0  ___U_______Ma_b___________________ uptodate,mmap,anonymous,swapbacked
0x0000000000005868         12        0  ___U_lA____Ma_b___________________ uptodate,lru,active,mmap,anonymous,swapbacked
0x000000000000586c          1        0  __RU_lA____Ma_b___________________ referenced,uptodate,lru,active,mmap,anonymous,swapbacked
             total      51300      200

The output of page-types shows 51200 pages contributing to hugepages,
containing 100 head pages and 51100 tail pages as expected.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andy Whitcroft <apw@canonical.com>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 fs/proc/task_mmu.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h |    3 +++
 mm/pagewalk.c      |   18 ++++++++++++++++--
 3 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2a1bef9..47c03f4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -650,6 +650,50 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	return err;
 }
 
+static u64 huge_pte_to_pagemap_entry(pte_t pte, int offset)
+{
+	u64 pme = 0;
+	if (pte_present(pte))
+		pme = PM_PFRAME(pte_pfn(pte) + offset)
+			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
+	return pme;
+}
+
+static int pagemap_hugetlb_range(pte_t *pte, unsigned long addr,
+				 unsigned long end, struct mm_walk *walk)
+{
+	struct vm_area_struct *vma;
+	struct pagemapread *pm = walk->private;
+	struct hstate *hs = NULL;
+	int err = 0;
+
+	vma = find_vma(walk->mm, addr);
+	if (vma)
+		hs = hstate_vma(vma);
+	for (; addr != end; addr += PAGE_SIZE) {
+		u64 pfn = PM_NOT_PRESENT;
+
+		if (vma && (addr >= vma->vm_end)) {
+			vma = find_vma(walk->mm, addr);
+			if (vma)
+				hs = hstate_vma(vma);
+		}
+
+		if (vma && (vma->vm_start <= addr) && is_vm_hugetlb_page(vma)) {
+			/* calculate pfn of the "raw" page in the hugepage. */
+			int offset = (addr & ~huge_page_mask(hs)) >> PAGE_SHIFT;
+			pfn = huge_pte_to_pagemap_entry(*pte, offset);
+		}
+		err = add_to_pagemap(addr, pfn, pm);
+		if (err)
+			return err;
+	}
+
+	cond_resched();
+
+	return err;
+}
+
 /*
  * /proc/pid/pagemap - an array mapping virtual pages to pfns
  *
@@ -742,6 +786,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 
 	pagemap_walk.pmd_entry = pagemap_pte_range;
 	pagemap_walk.pte_hole = pagemap_pte_hole;
+	pagemap_walk.hugetlb_entry = pagemap_hugetlb_range;
 	pagemap_walk.mm = mm;
 	pagemap_walk.private = &pm;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4d33403..14835f0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -758,6 +758,7 @@ unsigned long unmap_vmas(struct mmu_gather **tlb,
  * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
  * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
  * @pte_hole: if set, called for each hole at all levels
+ * @hugetlb_entry: if set, called for each hugetlb entry
  *
  * (see walk_page_range for more details)
  */
@@ -767,6 +768,8 @@ struct mm_walk {
 	int (*pmd_entry)(pmd_t *, unsigned long, unsigned long, struct mm_walk *);
 	int (*pte_entry)(pte_t *, unsigned long, unsigned long, struct mm_walk *);
 	int (*pte_hole)(unsigned long, unsigned long, struct mm_walk *);
+	int (*hugetlb_entry)(pte_t *, unsigned long, unsigned long,
+			     struct mm_walk *);
 	struct mm_struct *mm;
 	void *private;
 };
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index a286915..e7986db 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -106,9 +106,11 @@ int walk_page_range(unsigned long addr, unsigned long end,
 		    struct mm_walk *walk)
 {
 	pgd_t *pgd;
+	pte_t *pte;
 	unsigned long next;
 	int err = 0;
 	struct vm_area_struct *vma;
+	struct hstate *hs;
 
 	if (addr >= end)
 		return err;
@@ -120,12 +122,24 @@ int walk_page_range(unsigned long addr, unsigned long end,
 	do {
 		next = pgd_addr_end(addr, end);
 
-		/* skip hugetlb vma to avoid hugepage PMD being cleared
-		 * in pmd_none_or_clear_bad(). */
+		/*
+		 * handle hugetlb vma individually because pagetable walk for
+		 * the hugetlb page is dependent on the architecture and
+		 * we can't handled it in the same manner as non-huge pages.
+		 */
 		vma = find_vma(walk->mm, addr);
 		if (vma && is_vm_hugetlb_page(vma)) {
 			if (vma->vm_end < next)
 				next = vma->vm_end;
+			hs = hstate_vma(vma);
+			pte = huge_pte_offset(walk->mm,
+					      addr & huge_page_mask(hs));
+			if (pte && !huge_pte_none(huge_ptep_get(pte))
+			    && walk->hugetlb_entry)
+				err = walk->hugetlb_entry(pte, addr,
+							  next, walk);
+			if (err)
+				break;
 			continue;
 		}
 
-- 1.6.0.6 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
