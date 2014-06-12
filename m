Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 52DFF6B0062
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:36 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so1864422wgg.25
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id sh2si28987530wic.40.2014.06.12.14.48.34
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 14:48:35 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v2 04/11] pagewalk: move pmd_trans_huge_lock() from callbacks to common code
Date: Thu, 12 Jun 2014 17:48:04 -0400
Message-Id: <1402609691-13950-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

Now all of current users of page table walker are canonicalized, i.e.
pmd_entry() handles only trans_pmd entry, and pte_entry() handles pte entry.
So we can factorize common code more.
This patch moves pmd_trans_huge_lock() in each pmd_entry() to pagewalk core.

ChangeLog v2:
- add null check walk->vma in walk_pmd_range()
- move comment update into a separate patch

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/powerpc/mm/subpage-prot.c |  2 ++
 fs/proc/task_mmu.c             | 66 ++++++++++++++----------------------------
 mm/memcontrol.c                | 55 ++++++++++-------------------------
 mm/pagewalk.c                  | 18 ++++++++++--
 4 files changed, 55 insertions(+), 86 deletions(-)

diff --git mmotm-2014-05-21-16-57.orig/arch/powerpc/mm/subpage-prot.c mmotm-2014-05-21-16-57/arch/powerpc/mm/subpage-prot.c
index fa9fb5b4c66c..d0d94ac606f3 100644
--- mmotm-2014-05-21-16-57.orig/arch/powerpc/mm/subpage-prot.c
+++ mmotm-2014-05-21-16-57/arch/powerpc/mm/subpage-prot.c
@@ -135,7 +135,9 @@ static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
 				  unsigned long end, struct mm_walk *walk)
 {
 	struct vm_area_struct *vma = walk->vma;
+	spin_unlock(walk->ptl);
 	split_huge_page_pmd(vma, addr, pmd);
+	spin_lock(walk->ptl);
 	return 0;
 }
 
diff --git mmotm-2014-05-21-16-57.orig/fs/proc/task_mmu.c mmotm-2014-05-21-16-57/fs/proc/task_mmu.c
index fa6d6a4e85b3..059206ea3c6b 100644
--- mmotm-2014-05-21-16-57.orig/fs/proc/task_mmu.c
+++ mmotm-2014-05-21-16-57/fs/proc/task_mmu.c
@@ -496,15 +496,8 @@ static int smaps_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
 			struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
-	spinlock_t *ptl;
-
-	if (pmd_trans_huge_lock(pmd, walk->vma, &ptl) == 1) {
-		smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
-		spin_unlock(ptl);
-		mss->anonymous_thp += HPAGE_PMD_SIZE;
-		/* don't call smaps_pte() */
-		walk->skip = 1;
-	}
+	smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
+	mss->anonymous_thp += HPAGE_PMD_SIZE;
 	return 0;
 }
 
@@ -983,31 +976,21 @@ static int pagemap_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
 	struct vm_area_struct *vma = walk->vma;
 	struct pagemapread *pm = walk->private;
 	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
-	spinlock_t *ptl;
-
-	if (!vma)
-		return err;
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		int pmd_flags2;
+	int pmd_flags2;
 
-		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
-			pmd_flags2 = __PM_SOFT_DIRTY;
-		else
-			pmd_flags2 = 0;
+	if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
+		pmd_flags2 = __PM_SOFT_DIRTY;
+	else
+		pmd_flags2 = 0;
 
-		for (; addr != end; addr += PAGE_SIZE) {
-			unsigned long offset;
+	for (; addr != end; addr += PAGE_SIZE) {
+		unsigned long offset;
 
-			offset = (addr & ~PAGEMAP_WALK_MASK) >>
-					PAGE_SHIFT;
-			thp_pmd_to_pagemap_entry(&pme, pm, *pmd, offset, pmd_flags2);
-			err = add_to_pagemap(addr, &pme, pm);
-			if (err)
-				break;
-		}
-		spin_unlock(ptl);
-		/* don't call pagemap_pte() */
-		walk->skip = 1;
+		offset = (addr & ~PAGEMAP_WALK_MASK) >> PAGE_SHIFT;
+		thp_pmd_to_pagemap_entry(&pme, pm, *pmd, offset, pmd_flags2);
+		err = add_to_pagemap(addr, &pme, pm);
+		if (err)
+			break;
 	}
 	return err;
 }
@@ -1277,20 +1260,13 @@ static int gather_pmd_stats(pmd_t *pmd, unsigned long addr,
 {
 	struct numa_maps *md = walk->private;
 	struct vm_area_struct *vma = walk->vma;
-	spinlock_t *ptl;
-
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		pte_t huge_pte = *(pte_t *)pmd;
-		struct page *page;
-
-		page = can_gather_numa_stats(huge_pte, vma, addr);
-		if (page)
-			gather_stats(page, md, pte_dirty(huge_pte),
-				     HPAGE_PMD_SIZE/PAGE_SIZE);
-		spin_unlock(ptl);
-		/* don't call gather_pte_stats() */
-		walk->skip = 1;
-	}
+	pte_t huge_pte = *(pte_t *)pmd;
+	struct page *page;
+
+	page = can_gather_numa_stats(huge_pte, vma, addr);
+	if (page)
+		gather_stats(page, md, pte_dirty(huge_pte),
+			     HPAGE_PMD_SIZE/PAGE_SIZE);
 	return 0;
 }
 #ifdef CONFIG_HUGETLB_PAGE
diff --git mmotm-2014-05-21-16-57.orig/mm/memcontrol.c mmotm-2014-05-21-16-57/mm/memcontrol.c
index 01a66a208769..bb987cb9e043 100644
--- mmotm-2014-05-21-16-57.orig/mm/memcontrol.c
+++ mmotm-2014-05-21-16-57/mm/memcontrol.c
@@ -6723,15 +6723,9 @@ static int mem_cgroup_count_precharge_pmd(pmd_t *pmd,
 					struct mm_walk *walk)
 {
 	struct vm_area_struct *vma = walk->vma;
-	spinlock_t *ptl;
-
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
-			mc.precharge += HPAGE_PMD_NR;
-		spin_unlock(ptl);
-		/* don't call mem_cgroup_count_precharge_pte() */
-		walk->skip = 1;
-	}
+
+	if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
+		mc.precharge += HPAGE_PMD_NR;
 	return 0;
 }
 
@@ -6952,38 +6946,21 @@ static int mem_cgroup_move_charge_pmd(pmd_t *pmd,
 	struct page *page;
 	struct page_cgroup *pc;
 
-	/*
-	 * We don't take compound_lock() here but no race with splitting thp
-	 * happens because:
-	 *  - if pmd_trans_huge_lock() returns 1, the relevant thp is not
-	 *    under splitting, which means there's no concurrent thp split,
-	 *  - if another thread runs into split_huge_page() just after we
-	 *    entered this if-block, the thread must wait for page table lock
-	 *    to be unlocked in __split_huge_page_splitting(), where the main
-	 *    part of thp split is not executed yet.
-	 */
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		if (mc.precharge < HPAGE_PMD_NR) {
-			spin_unlock(ptl);
-			return 0;
-		}
-		target_type = get_mctgt_type_thp(vma, addr, *pmd, &target);
-		if (target_type == MC_TARGET_PAGE) {
-			page = target.page;
-			if (!isolate_lru_page(page)) {
-				pc = lookup_page_cgroup(page);
-				if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
-							pc, mc.from, mc.to)) {
-					mc.precharge -= HPAGE_PMD_NR;
-					mc.moved_charge += HPAGE_PMD_NR;
-				}
-				putback_lru_page(page);
+	if (mc.precharge < HPAGE_PMD_NR)
+		return 0;
+	target_type = get_mctgt_type_thp(vma, addr, *pmd, &target);
+	if (target_type == MC_TARGET_PAGE) {
+		page = target.page;
+		if (!isolate_lru_page(page)) {
+			pc = lookup_page_cgroup(page);
+			if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
+						     pc, mc.from, mc.to)) {
+				mc.precharge -= HPAGE_PMD_NR;
+				mc.moved_charge += HPAGE_PMD_NR;
 			}
-			put_page(page);
+			putback_lru_page(page);
 		}
-		spin_unlock(ptl);
-		/* don't call mem_cgroup_move_charge_pte() */
-		walk->skip = 1;
+		put_page(page);
 	}
 	return 0;
 }
diff --git mmotm-2014-05-21-16-57.orig/mm/pagewalk.c mmotm-2014-05-21-16-57/mm/pagewalk.c
index 24311d6f5c20..f1a3417d0b51 100644
--- mmotm-2014-05-21-16-57.orig/mm/pagewalk.c
+++ mmotm-2014-05-21-16-57/mm/pagewalk.c
@@ -73,8 +73,22 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr,
 			continue;
 		}
 
-		if (walk->pmd_entry) {
-			err = walk->pmd_entry(pmd, addr, next, walk);
+		/*
+		 * We don't take compound_lock() here but no race with splitting
+		 * thp happens because:
+		 *  - if pmd_trans_huge_lock() returns 1, the relevant thp is
+		 *    not under splitting, which means there's no concurrent
+		 *    thp split,
+		 *  - if another thread runs into split_huge_page() just after
+		 *    we entered this if-block, the thread must wait for page
+		 *    table lock to be unlocked in __split_huge_page_splitting(),
+		 *    where the main part of thp split is not executed yet.
+		 */
+		if (walk->pmd_entry && walk->vma) {
+			if (pmd_trans_huge_lock(pmd, walk->vma, &walk->ptl) == 1) {
+				err = walk->pmd_entry(pmd, addr, next, walk);
+				spin_unlock(walk->ptl);
+			}
 			if (skip_lower_level_walking(walk))
 				continue;
 			if (err)
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
