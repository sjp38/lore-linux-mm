Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2E06B005C
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:36 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id l6so2985595qcy.32
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e10si2587111qai.96.2014.06.12.14.48.35
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 14:48:35 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v2 05/11] pagewalk: remove mm_walk->skip
Date: Thu, 12 Jun 2014 17:48:05 -0400
Message-Id: <1402609691-13950-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

Due to the relocation of pmd locking, mm_walk->skip becomes less important
because only walk_page_test() and walk->test_walk() use it. None of these
functions uses a positive value as a return value, so we can define it to
determine whether we skip the current vma or not.
Thus this patch removes mm_walk->skip.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c |  4 ++--
 include/linux/mm.h |  3 ---
 mm/mempolicy.c     |  9 ++++-----
 mm/pagewalk.c      | 36 ++++++++----------------------------
 4 files changed, 14 insertions(+), 38 deletions(-)

diff --git mmotm-2014-05-21-16-57.orig/fs/proc/task_mmu.c mmotm-2014-05-21-16-57/fs/proc/task_mmu.c
index 059206ea3c6b..8211f6c8236d 100644
--- mmotm-2014-05-21-16-57.orig/fs/proc/task_mmu.c
+++ mmotm-2014-05-21-16-57/fs/proc/task_mmu.c
@@ -755,9 +755,9 @@ static int clear_refs_test_walk(unsigned long start, unsigned long end,
 	 * Writing 4 to /proc/pid/clear_refs affects all pages.
 	 */
 	if (cp->type == CLEAR_REFS_ANON && vma->vm_file)
-		walk->skip = 1;
+		return 1;
 	if (cp->type == CLEAR_REFS_MAPPED && !vma->vm_file)
-		walk->skip = 1;
+		return 1;
 	if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
 		if (vma->vm_flags & VM_SOFTDIRTY)
 			vma->vm_flags &= ~VM_SOFTDIRTY;
diff --git mmotm-2014-05-21-16-57.orig/include/linux/mm.h mmotm-2014-05-21-16-57/include/linux/mm.h
index aa832161a1ff..0a20674c84e2 100644
--- mmotm-2014-05-21-16-57.orig/include/linux/mm.h
+++ mmotm-2014-05-21-16-57/include/linux/mm.h
@@ -1106,8 +1106,6 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *             right now." 0 means "skip the current vma."
  * @mm:        mm_struct representing the target process of page table walk
  * @vma:       vma currently walked
- * @skip:      internal control flag which is set when we skip the lower
- *             level entries.
  * @pmd:       current pmd entry
  * @ptl:       page table lock associated with current entry
  * @private:   private data for callbacks' use
@@ -1127,7 +1125,6 @@ struct mm_walk {
 			struct mm_walk *walk);
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
-	int skip;
 	pmd_t *pmd;
 	spinlock_t *ptl;
 	void *private;
diff --git mmotm-2014-05-21-16-57.orig/mm/mempolicy.c mmotm-2014-05-21-16-57/mm/mempolicy.c
index cf3b995b21d0..b8267f753748 100644
--- mmotm-2014-05-21-16-57.orig/mm/mempolicy.c
+++ mmotm-2014-05-21-16-57/mm/mempolicy.c
@@ -596,22 +596,21 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 	}
 
 	qp->prev = vma;
-	walk->skip = 1;
 
 	if (vma->vm_flags & VM_PFNMAP)
-		return 0;
+		return 1;
 
 	if (flags & MPOL_MF_LAZY) {
 		change_prot_numa(vma, start, endvma);
-		return 0;
+		return 1;
 	}
 
 	if ((flags & MPOL_MF_STRICT) ||
 	    ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
 	     vma_migratable(vma)))
 		/* queue pages from current vma */
-		walk->skip = 0;
-	return 0;
+		return 0;
+	return 1;
 }
 
 /*
diff --git mmotm-2014-05-21-16-57.orig/mm/pagewalk.c mmotm-2014-05-21-16-57/mm/pagewalk.c
index f1a3417d0b51..61d6bd9545d6 100644
--- mmotm-2014-05-21-16-57.orig/mm/pagewalk.c
+++ mmotm-2014-05-21-16-57/mm/pagewalk.c
@@ -3,24 +3,6 @@
 #include <linux/sched.h>
 #include <linux/hugetlb.h>
 
-/*
- * Check the current skip status of page table walker.
- *
- * Here what I mean by skip is to skip lower level walking, and that was
- * determined for each entry independently. For example, when walk_pmd_range
- * handles a pmd_trans_huge we don't have to walk over ptes under that pmd,
- * and the skipping does not affect the walking over ptes under other pmds.
- * That's why we reset @walk->skip after tested.
- */
-static bool skip_lower_level_walking(struct mm_walk *walk)
-{
-	if (walk->skip) {
-		walk->skip = 0;
-		return true;
-	}
-	return false;
-}
-
 static int walk_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
@@ -89,8 +71,6 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr,
 				err = walk->pmd_entry(pmd, addr, next, walk);
 				spin_unlock(walk->ptl);
 			}
-			if (skip_lower_level_walking(walk))
-				continue;
 			if (err)
 				break;
 		}
@@ -225,9 +205,9 @@ static inline int walk_hugetlb_range(unsigned long addr, unsigned long end,
 
 /*
  * Decide whether we really walk over the current vma on [@start, @end)
- * or skip it. When we skip it, we set @walk->skip to 1.
- * The return value is used to control the page table walking to
- * continue (for zero) or not (for non-zero).
+ * or skip it via the returned value. Return 0 if we do walk over the
+ * current vma, and return 1 if we skip the vma. Negative values means
+ * error, where we abort the current walk.
  *
  * Default check (only VM_PFNMAP check for now) is used when the caller
  * doesn't define test_walk() callback.
@@ -245,7 +225,7 @@ static int walk_page_test(unsigned long start, unsigned long end,
 	 * page backing a VM_PFNMAP range. See also commit a9ff785e4437.
 	 */
 	if (vma->vm_flags & VM_PFNMAP)
-		walk->skip = 1;
+		return 1;
 	return 0;
 }
 
@@ -330,9 +310,9 @@ int walk_page_range(unsigned long start, unsigned long end,
 			next = min(end, vma->vm_end);
 
 			err = walk_page_test(start, next, walk);
-			if (skip_lower_level_walking(walk))
+			if (err == 1)
 				continue;
-			if (err)
+			if (err < 0)
 				break;
 		}
 		err = __walk_page_range(start, next, walk);
@@ -353,9 +333,9 @@ int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
 	VM_BUG_ON(!vma);
 	walk->vma = vma;
 	err = walk_page_test(vma->vm_start, vma->vm_end, walk);
-	if (skip_lower_level_walking(walk))
+	if (err == 1)
 		return 0;
-	if (err)
+	if (err < 0)
 		return err;
 	return __walk_page_range(vma->vm_start, vma->vm_end, walk);
 }
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
