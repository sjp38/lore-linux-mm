Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id C6CA66B009B
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 18:59:05 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id x13so760290wgg.27
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 15:59:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id js5si19792153wjc.105.2014.06.06.15.59.02
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 15:59:03 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 6/7] mm/pagewalk: move pmd_trans_huge_lock() from callbacks to common code
Date: Fri,  6 Jun 2014 18:58:39 -0400
Message-Id: <1402095520-10109-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

Now all of current users of page table walker are canonicalized, i.e.
pmd_entry() handles only trans_pmd entry, and pte_entry() handles pte entry.
So we can factorize common code more.
This patch moves pmd_trans_huge_lock() in each pmd_entry() to pagewalk core.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 65 ++++++++++++++++++------------------------------------
 mm/memcontrol.c    | 53 ++++++++++++++------------------------------
 mm/pagewalk.c      | 25 +++++++++++++++++----
 3 files changed, 59 insertions(+), 84 deletions(-)

diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/fs/proc/task_mmu.c v3.15-rc8-mmots-2014-06-03-16-28/fs/proc/task_mmu.c
index 2864028ae2f8..0b45bb9f3351 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/fs/proc/task_mmu.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/fs/proc/task_mmu.c
@@ -496,14 +496,8 @@ static int smaps_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
 			struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
-	spinlock_t *ptl;
-
-	if (pmd_trans_huge_lock(pmd, walk->vma, &ptl) == 1) {
-		smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
-		spin_unlock(ptl);
-		mss->anonymous_thp += HPAGE_PMD_SIZE;
-	} else
-		walk->control = PTWALK_DOWN;
+	smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
+	mss->anonymous_thp += HPAGE_PMD_SIZE;
 	return 0;
 }
 
@@ -983,31 +977,22 @@ static int pagemap_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
 	struct vm_area_struct *vma = walk->vma;
 	struct pagemapread *pm = walk->private;
 	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
-	spinlock_t *ptl;
+	int pmd_flags2;
 
-	if (!vma)
-		return err;
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		int pmd_flags2;
-
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
-	} else
-		walk->control = PTWALK_DOWN;
+		offset = (addr & ~PAGEMAP_WALK_MASK) >> PAGE_SHIFT;
+		thp_pmd_to_pagemap_entry(&pme, pm, *pmd, offset, pmd_flags2);
+		err = add_to_pagemap(addr, &pme, pm);
+		if (err)
+			break;
+	}
 	return err;
 }
 
@@ -1276,19 +1261,13 @@ static int gather_pmd_stats(pmd_t *pmd, unsigned long addr,
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
-	} else
-		walk->control = PTWALK_DOWN;
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
diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/memcontrol.c v3.15-rc8-mmots-2014-06-03-16-28/mm/memcontrol.c
index 3b1692d2bca3..bb987cb9e043 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/memcontrol.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/mm/memcontrol.c
@@ -6723,14 +6723,9 @@ static int mem_cgroup_count_precharge_pmd(pmd_t *pmd,
 					struct mm_walk *walk)
 {
 	struct vm_area_struct *vma = walk->vma;
-	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
-			mc.precharge += HPAGE_PMD_NR;
-		spin_unlock(ptl);
-	} else
-		skip->control = PTWALK_DOWN;
+	if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
+		mc.precharge += HPAGE_PMD_NR;
 	return 0;
 }
 
@@ -6951,38 +6946,22 @@ static int mem_cgroup_move_charge_pmd(pmd_t *pmd,
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
-	} else
-		walk->control = PTWALK_DOWN;
+		put_page(page);
+	}
 	return 0;
 }
 
diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/pagewalk.c v3.15-rc8-mmots-2014-06-03-16-28/mm/pagewalk.c
index 8d71e09a36ea..879cee00eb70 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/pagewalk.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/mm/pagewalk.c
@@ -61,6 +61,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr,
 	pmd_t *pmd;
 	unsigned long next;
 	int err = 0;
+	spinlock_t *ptl;
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -75,8 +76,22 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr,
 			continue;
 		}
 
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
 		if (walk->pmd_entry) {
-			err = walk->pmd_entry(pmd, addr, next, walk);
+			if (pmd_trans_huge_lock(pmd, walk->vma, &ptl) == 1) {
+				err = walk->pmd_entry(pmd, addr, next, walk);
+				spin_unlock(ptl);
+			}
 			if (err)
 				break;
 			switch (get_reset_walk_control(walk)) {
@@ -286,9 +301,11 @@ static int __walk_page_range(unsigned long start, unsigned long end,
  * outside a vma. If you want to access to some caller-specific data from
  * callbacks, @walk->private should be helpful.
  *
- * The callers should hold @walk->mm->mmap_sem. Note that the lower level
- * iterators can take page table lock in lowest level iteration and/or
- * in split_huge_page_pmd().
+ * Locking:
+ *   Callers of walk_page_range() and walk_page_vma() should hold
+ *   @walk->mm->mmap_sem, because these function traverse vma list and/or
+ *   access to vma's data. And page table lock is held during running
+ *   pmd_entry() and pte_entry().
  */
 int walk_page_range(unsigned long start, unsigned long end,
 		    struct mm_walk *walk)
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
