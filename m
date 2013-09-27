Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5C28D6B0038
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:16:45 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so2774923pad.35
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:16:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 04/10] mm, thp: change pmd_trans_huge_lock() to return taken lock
Date: Fri, 27 Sep 2013 16:16:21 +0300
Message-Id: <1380287787-30252-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With split ptlock it's important to know which lock pmd_trans_huge_lock()
took. This patch adds one more parameter to the function to return the
lock.

In most places migration to new api is trivial.
Exception is move_huge_pmd(): we need to take two locks if pmd tables
are different.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Alex Thorlton <athorlton@sgi.com>
---
 fs/proc/task_mmu.c      | 13 +++++++------
 include/linux/huge_mm.h | 14 +++++++-------
 mm/huge_memory.c        | 40 +++++++++++++++++++++++++++-------------
 mm/memcontrol.c         | 10 +++++-----
 4 files changed, 46 insertions(+), 31 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c52c597fbf..d7df94069e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -506,9 +506,9 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
-		spin_unlock(&walk->mm->page_table_lock);
+		spin_unlock(ptl);
 		mss->anonymous_thp += HPAGE_PMD_SIZE;
 		return 0;
 	}
@@ -994,13 +994,14 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 {
 	struct vm_area_struct *vma;
 	struct pagemapread *pm = walk->private;
+	spinlock_t *ptl;
 	pte_t *pte;
 	int err = 0;
 	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
 
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
-	if (vma && pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (vma && pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		int pmd_flags2;
 
 		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
@@ -1018,7 +1019,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			if (err)
 				break;
 		}
-		spin_unlock(&walk->mm->page_table_lock);
+		spin_unlock(ptl);
 		return err;
 	}
 
@@ -1320,7 +1321,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 
 	md = walk->private;
 
-	if (pmd_trans_huge_lock(pmd, md->vma) == 1) {
+	if (pmd_trans_huge_lock(pmd, md->vma, &ptl) == 1) {
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
@@ -1328,7 +1329,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 		if (page)
 			gather_stats(page, md, pte_dirty(huge_pte),
 				     HPAGE_PMD_SIZE/PAGE_SIZE);
-		spin_unlock(&walk->mm->page_table_lock);
+		spin_unlock(ptl);
 		return 0;
 	}
 
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 3935428c57..4aca0d8da1 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -129,15 +129,15 @@ extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
 				    long adjust_next);
-extern int __pmd_trans_huge_lock(pmd_t *pmd,
-				 struct vm_area_struct *vma);
+extern int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
+		spinlock_t **ptl);
 /* mmap_sem must be held on entry */
-static inline int pmd_trans_huge_lock(pmd_t *pmd,
-				      struct vm_area_struct *vma)
+static inline int pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
+		spinlock_t **ptl)
 {
 	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
 	if (pmd_trans_huge(*pmd))
-		return __pmd_trans_huge_lock(pmd, vma);
+		return __pmd_trans_huge_lock(pmd, vma, ptl);
 	else
 		return 0;
 }
@@ -215,8 +215,8 @@ static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 long adjust_next)
 {
 }
-static inline int pmd_trans_huge_lock(pmd_t *pmd,
-				      struct vm_area_struct *vma)
+static inline int pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
+		spinlock_t **ptl)
 {
 	return 0;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bbd41a2f49..59a1340f35 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1342,9 +1342,10 @@ out_unlock:
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
+	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		struct page *page;
 		pgtable_t pgtable;
 		pmd_t orig_pmd;
@@ -1359,7 +1360,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
 		if (is_huge_zero_pmd(orig_pmd)) {
 			atomic_dec(&tlb->mm->nr_ptes);
-			spin_unlock(&tlb->mm->page_table_lock);
+			spin_unlock(ptl);
 			put_huge_zero_page();
 		} else {
 			page = pmd_page(orig_pmd);
@@ -1368,7 +1369,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON(!PageHead(page));
 			atomic_dec(&tlb->mm->nr_ptes);
-			spin_unlock(&tlb->mm->page_table_lock);
+			spin_unlock(ptl);
 			tlb_remove_page(tlb, page);
 		}
 		pte_free(tlb->mm, pgtable);
@@ -1381,14 +1382,15 @@ int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end,
 		unsigned char *vec)
 {
+	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		/*
 		 * All logical pages in the range are present
 		 * if backed by a huge page.
 		 */
-		spin_unlock(&vma->vm_mm->page_table_lock);
+		spin_unlock(ptl);
 		memset(vec, 1, (end - addr) >> PAGE_SHIFT);
 		ret = 1;
 	}
@@ -1401,6 +1403,7 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		  unsigned long new_addr, unsigned long old_end,
 		  pmd_t *old_pmd, pmd_t *new_pmd)
 {
+	spinlock_t *old_ptl, *new_ptl;
 	int ret = 0;
 	pmd_t pmd;
 
@@ -1421,12 +1424,21 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		goto out;
 	}
 
-	ret = __pmd_trans_huge_lock(old_pmd, vma);
+	/*
+	 * We don't have to worry about the ordering of src and dst
+	 * ptlocks because exclusive mmap_sem prevents deadlock.
+	 */
+	ret = __pmd_trans_huge_lock(old_pmd, vma, &old_ptl);
 	if (ret == 1) {
+		new_ptl = pmd_lockptr(mm, new_pmd);
+		if (new_ptl != old_ptl)
+			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
 		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
 		VM_BUG_ON(!pmd_none(*new_pmd));
 		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
-		spin_unlock(&mm->page_table_lock);
+		if (new_ptl != old_ptl)
+			spin_unlock(new_ptl);
+		spin_unlock(old_ptl);
 	}
 out:
 	return ret;
@@ -1436,9 +1448,10 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, pgprot_t newprot, int prot_numa)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		pmd_t entry;
 		entry = pmdp_get_and_clear(mm, addr, pmd);
 		if (!prot_numa) {
@@ -1454,7 +1467,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			}
 		}
 		set_pmd_at(mm, addr, pmd, entry);
-		spin_unlock(&vma->vm_mm->page_table_lock);
+		spin_unlock(ptl);
 		ret = 1;
 	}
 
@@ -1468,12 +1481,13 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
  * Note that if it returns 1, this routine returns without unlocking page
  * table locks. So callers must unlock them.
  */
-int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
+int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
+		spinlock_t **ptl)
 {
-	spin_lock(&vma->vm_mm->page_table_lock);
+	*ptl = pmd_lock(vma->vm_mm, pmd);
 	if (likely(pmd_trans_huge(*pmd))) {
 		if (unlikely(pmd_trans_splitting(*pmd))) {
-			spin_unlock(&vma->vm_mm->page_table_lock);
+			spin_unlock(*ptl);
 			wait_split_huge_page(vma->anon_vma, pmd);
 			return -1;
 		} else {
@@ -1482,7 +1496,7 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
 			return 1;
 		}
 	}
-	spin_unlock(&vma->vm_mm->page_table_lock);
+	spin_unlock(*ptl);
 	return 0;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d5ff3ce130..5f35b2a116 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6376,10 +6376,10 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
-		spin_unlock(&vma->vm_mm->page_table_lock);
+		spin_unlock(ptl);
 		return 0;
 	}
 
@@ -6568,9 +6568,9 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	 *    to be unlocked in __split_huge_page_splitting(), where the main
 	 *    part of thp split is not executed yet.
 	 */
-	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		if (mc.precharge < HPAGE_PMD_NR) {
-			spin_unlock(&vma->vm_mm->page_table_lock);
+			spin_unlock(ptl);
 			return 0;
 		}
 		target_type = get_mctgt_type_thp(vma, addr, *pmd, &target);
@@ -6587,7 +6587,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			}
 			put_page(page);
 		}
-		spin_unlock(&vma->vm_mm->page_table_lock);
+		spin_unlock(ptl);
 		return 0;
 	}
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
