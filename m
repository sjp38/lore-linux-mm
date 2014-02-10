Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B36D26B003A
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 16:45:20 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id e4so3194448wiv.4
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:45:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n18si7500913wij.19.2014.02.10.13.45.14
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 13:45:15 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 01/11] pagewalk: update page table walker core
Date: Mon, 10 Feb 2014 16:44:26 -0500
Message-Id: <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

This patch updates mm/pagewalk.c to make code less complex and more maintenable.
The basic idea is unchanged and there's no userspace visible effect.

Most of existing callback functions need access to vma to handle each entry.
So we had better add a new member vma in struct mm_walk instead of using
mm_walk->private, which makes code simpler.

One problem in current page table walker is that we check vma in pgd loop.
Historically this was introduced to support hugetlbfs in the strange manner.
It's better and cleaner to do the vma check outside pgd loop.

Another problem is that many users of page table walker now use only
pmd_entry(), although it does both pmd-walk and pte-walk. This makes code
duplication and fluctuation among callers, which worsens the maintenability.

One difficulty of code sharing is that the callers want to determine
whether they try to walk over a specific vma or not in their own way.
To solve this, this patch introduces test_walk() callback.

When we try to use multiple callbacks in different levels, skip control is
also important. For example we have thp enabled in normal configuration, and
we are interested in doing some work for a thp. But sometimes we want to
split it and handle as normal pages, and in another time user would handle
both at pmd level and pte level.
What we need is that when we've done pmd_entry() we want to decide whether
to go down to pte level handling based on the pmd_entry()'s result. So this
patch introduces a skip control flag in mm_walk.
We can't use the returned value for this purpose, because we already
defined the meaning of whole range of returned values (>0 is to terminate
page table walk in caller's specific manner, =0 is to continue to walk,
and <0 is to abort the walk in the general manner.)

ChangeLog v5:
- fix build error ("mm/pagewalk.c:201: error: 'hmask' undeclared")

ChangeLog v4:
- add more comment
- remove verbose variable in walk_page_test()
- rename skip_check to skip_lower_level_walking
- rebased onto mmotm-2014-01-09-16-23

ChangeLog v3:
- rebased onto v3.13-rc3-mmots-2013-12-10-16-38

ChangeLog v2:
- rebase onto mmots
- add pte_none() check in walk_pte_range()
- add cond_sched() in walk_hugetlb_range()
- add skip_check()
- do VM_PFNMAP check only when ->test_walk() is not defined (because some
  caller could handle VM_PFNMAP vma. copy_page_range() is an example.)
- use do-while condition (addr < end) instead of (addr != end)

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/mm.h |  18 ++-
 mm/pagewalk.c      | 352 +++++++++++++++++++++++++++++++++--------------------
 2 files changed, 235 insertions(+), 135 deletions(-)

diff --git v3.14-rc2.orig/include/linux/mm.h v3.14-rc2/include/linux/mm.h
index f28f46eade6a..4d0bc01de43c 100644
--- v3.14-rc2.orig/include/linux/mm.h
+++ v3.14-rc2/include/linux/mm.h
@@ -1067,10 +1067,18 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
  * @pte_hole: if set, called for each hole at all levels
  * @hugetlb_entry: if set, called for each hugetlb entry
- *		   *Caution*: The caller must hold mmap_sem() if @hugetlb_entry
- * 			      is used.
+ * @test_walk: caller specific callback function to determine whether
+ *             we walk over the current vma or not. A positive returned
+ *             value means "do page table walk over the current vma,"
+ *             and a negative one means "abort current page table walk
+ *             right now." 0 means "skip the current vma."
+ * @mm:        mm_struct representing the target process of page table walk
+ * @vma:       vma currently walked
+ * @skip:      internal control flag which is set when we skip the lower
+ *             level entries.
+ * @private:   private data for callbacks' use
  *
- * (see walk_page_range for more details)
+ * (see the comment on walk_page_range() for more details)
  */
 struct mm_walk {
 	int (*pgd_entry)(pgd_t *pgd, unsigned long addr,
@@ -1086,7 +1094,11 @@ struct mm_walk {
 	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
 			     unsigned long addr, unsigned long next,
 			     struct mm_walk *walk);
+	int (*test_walk)(unsigned long addr, unsigned long next,
+			struct mm_walk *walk);
 	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	int skip;
 	void *private;
 };
 
diff --git v3.14-rc2.orig/mm/pagewalk.c v3.14-rc2/mm/pagewalk.c
index 2beeabf502c5..4770558feea8 100644
--- v3.14-rc2.orig/mm/pagewalk.c
+++ v3.14-rc2/mm/pagewalk.c
@@ -3,29 +3,58 @@
 #include <linux/sched.h>
 #include <linux/hugetlb.h>
 
-static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
-			  struct mm_walk *walk)
+/*
+ * Check the current skip status of page table walker.
+ *
+ * Here what I mean by skip is to skip lower level walking, and that was
+ * determined for each entry independently. For example, when walk_pmd_range
+ * handles a pmd_trans_huge we don't have to walk over ptes under that pmd,
+ * and the skipping does not affect the walking over ptes under other pmds.
+ * That's why we reset @walk->skip after tested.
+ */
+static bool skip_lower_level_walking(struct mm_walk *walk)
+{
+	if (walk->skip) {
+		walk->skip = 0;
+		return true;
+	}
+	return false;
+}
+
+static int walk_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
 {
+	struct mm_struct *mm = walk->mm;
 	pte_t *pte;
+	pte_t *orig_pte;
+	spinlock_t *ptl;
 	int err = 0;
 
-	pte = pte_offset_map(pmd, addr);
-	for (;;) {
+	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	do {
+		if (pte_none(*pte)) {
+			if (walk->pte_hole)
+				err = walk->pte_hole(addr, addr + PAGE_SIZE,
+							walk);
+			if (err)
+				break;
+			continue;
+		}
+		/*
+		 * Callers should have their own way to handle swap entries
+		 * in walk->pte_entry().
+		 */
 		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
 		if (err)
 		       break;
-		addr += PAGE_SIZE;
-		if (addr == end)
-			break;
-		pte++;
-	}
-
-	pte_unmap(pte);
-	return err;
+	} while (pte++, addr += PAGE_SIZE, addr < end);
+	pte_unmap_unlock(orig_pte, ptl);
+	cond_resched();
+	return addr == end ? 0 : err;
 }
 
-static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
-			  struct mm_walk *walk)
+static int walk_pmd_range(pud_t *pud, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -35,6 +64,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	do {
 again:
 		next = pmd_addr_end(addr, end);
+
 		if (pmd_none(*pmd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
@@ -42,35 +72,32 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 				break;
 			continue;
 		}
-		/*
-		 * This implies that each ->pmd_entry() handler
-		 * needs to know about pmd_trans_huge() pmds
-		 */
-		if (walk->pmd_entry)
-			err = walk->pmd_entry(pmd, addr, next, walk);
-		if (err)
-			break;
 
-		/*
-		 * Check this here so we only break down trans_huge
-		 * pages when we _need_ to
-		 */
-		if (!walk->pte_entry)
-			continue;
+		if (walk->pmd_entry) {
+			err = walk->pmd_entry(pmd, addr, next, walk);
+			if (skip_lower_level_walking(walk))
+				continue;
+			if (err)
+				break;
+		}
 
-		split_huge_page_pmd_mm(walk->mm, addr, pmd);
-		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
-			goto again;
-		err = walk_pte_range(pmd, addr, next, walk);
-		if (err)
-			break;
-	} while (pmd++, addr = next, addr != end);
+		if (walk->pte_entry) {
+			if (walk->vma) {
+				split_huge_page_pmd(walk->vma, addr, pmd);
+				if (pmd_trans_unstable(pmd))
+					goto again;
+			}
+			err = walk_pte_range(pmd, addr, next, walk);
+			if (err)
+				break;
+		}
+	} while (pmd++, addr = next, addr < end);
 
 	return err;
 }
 
-static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
-			  struct mm_walk *walk)
+static int walk_pud_range(pgd_t *pgd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -79,6 +106,7 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
+
 		if (pud_none_or_clear_bad(pud)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
@@ -86,13 +114,58 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 				break;
 			continue;
 		}
-		if (walk->pud_entry)
+
+		if (walk->pud_entry) {
 			err = walk->pud_entry(pud, addr, next, walk);
-		if (!err && (walk->pmd_entry || walk->pte_entry))
+			if (skip_lower_level_walking(walk))
+				continue;
+			if (err)
+				break;
+		}
+
+		if (walk->pmd_entry || walk->pte_entry) {
 			err = walk_pmd_range(pud, addr, next, walk);
-		if (err)
-			break;
-	} while (pud++, addr = next, addr != end);
+			if (err)
+				break;
+		}
+	} while (pud++, addr = next, addr < end);
+
+	return err;
+}
+
+static int walk_pgd_range(unsigned long addr, unsigned long end,
+			struct mm_walk *walk)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	int err = 0;
+
+	pgd = pgd_offset(walk->mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+
+		if (pgd_none_or_clear_bad(pgd)) {
+			if (walk->pte_hole)
+				err = walk->pte_hole(addr, next, walk);
+			if (err)
+				break;
+			continue;
+		}
+
+		if (walk->pgd_entry) {
+			err = walk->pgd_entry(pgd, addr, next, walk);
+			if (skip_lower_level_walking(walk))
+				continue;
+			if (err)
+				break;
+		}
+
+		if (walk->pud_entry || walk->pmd_entry || walk->pte_entry) {
+			err = walk_pud_range(pgd, addr, next, walk);
+			if (err)
+				break;
+		}
+	} while (pgd++, addr = next, addr < end);
 
 	return err;
 }
@@ -105,144 +178,159 @@ static unsigned long hugetlb_entry_end(struct hstate *h, unsigned long addr,
 	return boundary < end ? boundary : end;
 }
 
-static int walk_hugetlb_range(struct vm_area_struct *vma,
-			      unsigned long addr, unsigned long end,
-			      struct mm_walk *walk)
+static int walk_hugetlb_range(unsigned long addr, unsigned long end,
+				struct mm_walk *walk)
 {
+	struct mm_struct *mm = walk->mm;
+	struct vm_area_struct *vma = walk->vma;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long next;
 	unsigned long hmask = huge_page_mask(h);
 	pte_t *pte;
 	int err = 0;
+	spinlock_t *ptl;
 
 	do {
 		next = hugetlb_entry_end(h, addr, end);
 		pte = huge_pte_offset(walk->mm, addr & hmask);
+		ptl = huge_pte_lock(h, mm, pte);
+		/*
+		 * Callers should have their own way to handle swap entries
+		 * in walk->hugetlb_entry().
+		 */
 		if (pte && walk->hugetlb_entry)
 			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
+		spin_unlock(ptl);
 		if (err)
-			return err;
+			break;
 	} while (addr = next, addr != end);
-
-	return 0;
+	cond_resched();
+	return err;
 }
 
 #else /* CONFIG_HUGETLB_PAGE */
-static int walk_hugetlb_range(struct vm_area_struct *vma,
-			      unsigned long addr, unsigned long end,
-			      struct mm_walk *walk)
+static inline int walk_hugetlb_range(unsigned long addr, unsigned long end,
+				struct mm_walk *walk)
 {
 	return 0;
 }
 
 #endif /* CONFIG_HUGETLB_PAGE */
 
+/*
+ * Decide whether we really walk over the current vma on [@start, @end)
+ * or skip it. When we skip it, we set @walk->skip to 1.
+ * The return value is used to control the page table walking to
+ * continue (for zero) or not (for non-zero).
+ *
+ * Default check (only VM_PFNMAP check for now) is used when the caller
+ * doesn't define test_walk() callback.
+ */
+static int walk_page_test(unsigned long start, unsigned long end,
+			struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->vma;
 
+	if (walk->test_walk)
+		return walk->test_walk(start, end, walk);
+
+	/*
+	 * Do not walk over vma(VM_PFNMAP), because we have no valid struct
+	 * page backing a VM_PFNMAP range. See also commit a9ff785e4437.
+	 */
+	if (vma->vm_flags & VM_PFNMAP)
+		walk->skip = 1;
+	return 0;
+}
+
+static int __walk_page_range(unsigned long start, unsigned long end,
+			struct mm_walk *walk)
+{
+	int err = 0;
+	struct vm_area_struct *vma = walk->vma;
+
+	if (vma && is_vm_hugetlb_page(vma)) {
+		if (walk->hugetlb_entry)
+			err = walk_hugetlb_range(start, end, walk);
+	} else
+		err = walk_pgd_range(start, end, walk);
+
+	return err;
+}
 
 /**
- * walk_page_range - walk a memory map's page tables with a callback
- * @addr: starting address
- * @end: ending address
- * @walk: set of callbacks to invoke for each level of the tree
+ * walk_page_range - walk page table with caller specific callbacks
+ *
+ * Recursively walk the page table tree of the process represented by
+ * @walk->mm within the virtual address range [@start, @end). In walking,
+ * we can call caller-specific callback functions against each entry.
  *
- * Recursively walk the page table for the memory area in a VMA,
- * calling supplied callbacks. Callbacks are called in-order (first
- * PGD, first PUD, first PMD, first PTE, second PTE... second PMD,
- * etc.). If lower-level callbacks are omitted, walking depth is reduced.
+ * Before starting to walk page table, some callers want to check whether
+ * they really want to walk over the vma (for example by checking vm_flags.)
+ * walk_page_test() and @walk->test_walk() do that check.
  *
- * Each callback receives an entry pointer and the start and end of the
- * associated range, and a copy of the original mm_walk for access to
- * the ->private or ->mm fields.
+ * If any callback returns a non-zero value, the page table walk is aborted
+ * immediately and the return value is propagated back to the caller.
+ * Note that the meaning of the positive returned value can be defined
+ * by the caller for its own purpose.
  *
- * Usually no locks are taken, but splitting transparent huge page may
- * take page table lock. And the bottom level iterator will map PTE
- * directories from highmem if necessary.
+ * If the caller defines multiple callbacks in different levels, the
+ * callbacks are called in depth-first manner. It could happen that
+ * multiple callbacks are called on a address. For example if some caller
+ * defines test_walk(), pmd_entry(), and pte_entry(), then callbacks are
+ * called in the order of test_walk(), pmd_entry(), and pte_entry().
+ * If you don't want to go down to lower level at some point and move to
+ * the next entry in the same level, you set @walk->skip to 1.
+ * For example if you succeed to handle some pmd entry as trans_huge entry,
+ * you need not call walk_pte_range() any more, so set it to avoid that.
+ * We can't determine whether to go down to lower level with the return
+ * value of the callback, because the whole range of return values (0, >0,
+ * and <0) are used up for other meanings.
  *
- * If any callback returns a non-zero value, the walk is aborted and
- * the return value is propagated back to the caller. Otherwise 0 is returned.
+ * Each callback can access to the vma over which it is doing page table
+ * walk right now via @walk->vma. @walk->vma is set to NULL in walking
+ * outside a vma. If you want to access to some caller-specific data from
+ * callbacks, @walk->private should be helpful.
  *
- * walk->mm->mmap_sem must be held for at least read if walk->hugetlb_entry
- * is !NULL.
+ * The callers should hold @walk->mm->mmap_sem. Note that the lower level
+ * iterators can take page table lock in lowest level iteration and/or
+ * in split_huge_page_pmd().
  */
-int walk_page_range(unsigned long addr, unsigned long end,
+int walk_page_range(unsigned long start, unsigned long end,
 		    struct mm_walk *walk)
 {
-	pgd_t *pgd;
-	unsigned long next;
 	int err = 0;
+	struct vm_area_struct *vma;
+	unsigned long next;
 
-	if (addr >= end)
-		return err;
+	if (start >= end)
+		return -EINVAL;
 
 	if (!walk->mm)
 		return -EINVAL;
 
 	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
 
-	pgd = pgd_offset(walk->mm, addr);
 	do {
-		struct vm_area_struct *vma = NULL;
-
-		next = pgd_addr_end(addr, end);
-
-		/*
-		 * This function was not intended to be vma based.
-		 * But there are vma special cases to be handled:
-		 * - hugetlb vma's
-		 * - VM_PFNMAP vma's
-		 */
-		vma = find_vma(walk->mm, addr);
-		if (vma) {
-			/*
-			 * There are no page structures backing a VM_PFNMAP
-			 * range, so do not allow split_huge_page_pmd().
-			 */
-			if ((vma->vm_start <= addr) &&
-			    (vma->vm_flags & VM_PFNMAP)) {
-				next = vma->vm_end;
-				pgd = pgd_offset(walk->mm, next);
-				continue;
-			}
-			/*
-			 * Handle hugetlb vma individually because pagetable
-			 * walk for the hugetlb page is dependent on the
-			 * architecture and we can't handled it in the same
-			 * manner as non-huge pages.
-			 */
-			if (walk->hugetlb_entry && (vma->vm_start <= addr) &&
-			    is_vm_hugetlb_page(vma)) {
-				if (vma->vm_end < next)
-					next = vma->vm_end;
-				/*
-				 * Hugepage is very tightly coupled with vma,
-				 * so walk through hugetlb entries within a
-				 * given vma.
-				 */
-				err = walk_hugetlb_range(vma, addr, next, walk);
-				if (err)
-					break;
-				pgd = pgd_offset(walk->mm, next);
+		vma = find_vma(walk->mm, start);
+		if (!vma) { /* after the last vma */
+			walk->vma = NULL;
+			next = end;
+		} else if (start < vma->vm_start) { /* outside the found vma */
+			walk->vma = NULL;
+			next = vma->vm_start;
+		} else { /* inside the found vma */
+			walk->vma = vma;
+			next = vma->vm_end;
+			err = walk_page_test(start, end, walk);
+			if (skip_lower_level_walking(walk))
 				continue;
-			}
-		}
-
-		if (pgd_none_or_clear_bad(pgd)) {
-			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
 			if (err)
 				break;
-			pgd++;
-			continue;
 		}
-		if (walk->pgd_entry)
-			err = walk->pgd_entry(pgd, addr, next, walk);
-		if (!err &&
-		    (walk->pud_entry || walk->pmd_entry || walk->pte_entry))
-			err = walk_pud_range(pgd, addr, next, walk);
+		err = __walk_page_range(start, next, walk);
 		if (err)
 			break;
-		pgd++;
-	} while (addr = next, addr < end);
-
+	} while (start = next, start < end);
 	return err;
 }
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
