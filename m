Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2E57B6B003A
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 17:46:01 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so1557736pad.25
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 14:46:00 -0700 (PDT)
Received: from psmtp.com ([74.125.245.202])
        by mx.google.com with SMTP id yh6si358905pab.121.2013.10.30.14.45.59
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 14:46:00 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 05/11] pagemap: redefine callback functions for page table walker
Date: Wed, 30 Oct 2013 17:44:53 -0400
Message-Id: <1383169499-25144-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

pagemap_pte_range() connected to pmd_entry() does both of pmd loop and
pte loop. So this patch moves pte part into pagemap_pte() on pte_entry().

We remove VM_SOFTDIRTY check in pagemap_pte_range(), because in the new
page table walker we call __walk_page_range() for each vma separately,
so we never experience multiple vmas in single pgd/pud/pmd/pte loop.

ChangeLog v2:
- remove cond_sched() (moved it to walk_hugetlb_range())
- rebase onto mmots

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 76 ++++++++++++++++++++----------------------------------
 1 file changed, 28 insertions(+), 48 deletions(-)

diff --git v3.12-rc7-mmots-2013-10-29-16-24.orig/fs/proc/task_mmu.c v3.12-rc7-mmots-2013-10-29-16-24/fs/proc/task_mmu.c
index 3e1b739..fde594c 100644
--- v3.12-rc7-mmots-2013-10-29-16-24.orig/fs/proc/task_mmu.c
+++ v3.12-rc7-mmots-2013-10-29-16-24/fs/proc/task_mmu.c
@@ -978,19 +978,33 @@ static inline void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme, struct pagemap
 }
 #endif
 
-static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
+static int pagemap_pte(pte_t *pte, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
-	struct vm_area_struct *vma;
+	struct vm_area_struct *vma = walk->vma;
 	struct pagemapread *pm = walk->private;
-	spinlock_t *ptl;
-	pte_t *pte;
+	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
+
+	if (vma && vma->vm_start <= addr && end <= vma->vm_end) {
+		pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
+		/* unmap before userspace copy */
+		pte_unmap(pte);
+	}
+	return add_to_pagemap(addr, &pme, pm);
+}
+
+static int pagemap_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
+			     struct mm_walk *walk)
+{
 	int err = 0;
+	struct vm_area_struct *vma = walk->vma;
+	struct pagemapread *pm = walk->private;
 	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
+	spinlock_t *ptl;
 
-	/* find the first VMA at or above 'addr' */
-	vma = find_vma(walk->mm, addr);
-	if (vma && pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (!vma)
+		return err;
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		int pmd_flags2;
 
 		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
@@ -1009,41 +1023,9 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 				break;
 		}
 		spin_unlock(ptl);
-		return err;
-	}
-
-	if (pmd_trans_unstable(pmd))
-		return 0;
-	for (; addr != end; addr += PAGE_SIZE) {
-		int flags2;
-
-		/* check to see if we've left 'vma' behind
-		 * and need a new, higher one */
-		if (vma && (addr >= vma->vm_end)) {
-			vma = find_vma(walk->mm, addr);
-			if (vma && (vma->vm_flags & VM_SOFTDIRTY))
-				flags2 = __PM_SOFT_DIRTY;
-			else
-				flags2 = 0;
-			pme = make_pme(PM_NOT_PRESENT(pm->v2) | PM_STATUS2(pm->v2, flags2));
-		}
-
-		/* check that 'vma' actually covers this address,
-		 * and that it isn't a huge page vma */
-		if (vma && (vma->vm_start <= addr) &&
-		    !is_vm_hugetlb_page(vma)) {
-			pte = pte_offset_map(pmd, addr);
-			pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
-			/* unmap before userspace copy */
-			pte_unmap(pte);
-		}
-		err = add_to_pagemap(addr, &pme, pm);
-		if (err)
-			return err;
+		/* don't call pagemap_pte() */
+		walk->skip = 1;
 	}
-
-	cond_resched();
-
 	return err;
 }
 
@@ -1066,12 +1048,11 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 				 struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
-	struct vm_area_struct *vma;
+	struct vm_area_struct *vma = walk->vma;
 	int err = 0;
 	int flags2;
 	pagemap_entry_t pme;
 
-	vma = find_vma(walk->mm, addr);
 	WARN_ON_ONCE(!vma);
 
 	if (vma && (vma->vm_flags & VM_SOFTDIRTY))
@@ -1079,6 +1060,7 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 	else
 		flags2 = 0;
 
+	hmask = huge_page_mask(hstate_vma(vma));
 	for (; addr != end; addr += PAGE_SIZE) {
 		int offset = (addr & ~hmask) >> PAGE_SHIFT;
 		huge_pte_to_pagemap_entry(&pme, pm, *pte, offset, flags2);
@@ -1086,9 +1068,6 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 		if (err)
 			return err;
 	}
-
-	cond_resched();
-
 	return err;
 }
 #endif /* HUGETLB_PAGE */
@@ -1155,10 +1134,11 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!mm || IS_ERR(mm))
 		goto out_free;
 
-	pagemap_walk.pmd_entry = pagemap_pte_range;
+	pagemap_walk.pte_entry = pagemap_pte;
+	pagemap_walk.pmd_entry = pagemap_pmd;
 	pagemap_walk.pte_hole = pagemap_pte_hole;
 #ifdef CONFIG_HUGETLB_PAGE
-	pagemap_walk.hugetlb_entry = pagemap_hugetlb_range;
+	pagemap_walk.hugetlb_entry = pagemap_hugetlb;
 #endif
 	pagemap_walk.mm = mm;
 	pagemap_walk.private = &pm;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
