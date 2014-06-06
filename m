Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 565476B008A
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 18:59:01 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id ho1so1746575wib.11
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 15:59:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id dl7si19857881wjb.39.2014.06.06.15.58.59
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 15:59:00 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/7] mm/pagewalk: replace mm_walk->skip with more general mm_walk->control
Date: Fri,  6 Jun 2014 18:58:35 -0400
Message-Id: <1402095520-10109-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

Originally mm_walk->skip is used to determine whether we walk over a vma
or not. But this is not enough because one of the page table walker's caller
subpage_mark_vma_nohuge(), will need another behavior PTWALK_BREAK, which
let us break current loop and continue from the beginning of the next loop.

To implement this behavior and make it extensible for future users, this patch
replaces mm_walk->skip with more flexible mm_walk->control, and changes its
default value to PTWALK_NEXT (which is equivalent to present walk->skip == 1.)
This is because PTWALK_NEXT provides the behavior which is most likely to be
used globally.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 20 +++++++-------
 include/linux/mm.h | 13 ++++++---
 mm/memcontrol.c    |  5 ++--
 mm/mempolicy.c     |  3 +--
 mm/pagewalk.c      | 79 +++++++++++++++++++++++++++++++++---------------------
 5 files changed, 71 insertions(+), 49 deletions(-)

diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/fs/proc/task_mmu.c v3.15-rc8-mmots-2014-06-03-16-28/fs/proc/task_mmu.c
index fa6d6a4e85b3..2864028ae2f8 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/fs/proc/task_mmu.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/fs/proc/task_mmu.c
@@ -502,9 +502,8 @@ static int smaps_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
 		smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
 		spin_unlock(ptl);
 		mss->anonymous_thp += HPAGE_PMD_SIZE;
-		/* don't call smaps_pte() */
-		walk->skip = 1;
-	}
+	} else
+		walk->control = PTWALK_DOWN;
 	return 0;
 }
 
@@ -762,13 +761,14 @@ static int clear_refs_test_walk(unsigned long start, unsigned long end,
 	 * Writing 4 to /proc/pid/clear_refs affects all pages.
 	 */
 	if (cp->type == CLEAR_REFS_ANON && vma->vm_file)
-		walk->skip = 1;
+		return 0;
 	if (cp->type == CLEAR_REFS_MAPPED && !vma->vm_file)
-		walk->skip = 1;
+		return 0;
 	if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
 		if (vma->vm_flags & VM_SOFTDIRTY)
 			vma->vm_flags &= ~VM_SOFTDIRTY;
 	}
+	walk->control = PTWALK_DOWN;
 	return 0;
 }
 
@@ -1006,9 +1006,8 @@ static int pagemap_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
 				break;
 		}
 		spin_unlock(ptl);
-		/* don't call pagemap_pte() */
-		walk->skip = 1;
-	}
+	} else
+		walk->control = PTWALK_DOWN;
 	return err;
 }
 
@@ -1288,9 +1287,8 @@ static int gather_pmd_stats(pmd_t *pmd, unsigned long addr,
 			gather_stats(page, md, pte_dirty(huge_pte),
 				     HPAGE_PMD_SIZE/PAGE_SIZE);
 		spin_unlock(ptl);
-		/* don't call gather_pte_stats() */
-		walk->skip = 1;
-	}
+	} else
+		walk->control = PTWALK_DOWN;
 	return 0;
 }
 #ifdef CONFIG_HUGETLB_PAGE
diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/include/linux/mm.h v3.15-rc8-mmots-2014-06-03-16-28/include/linux/mm.h
index b4aa6579f2b1..43449eba3032 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/include/linux/mm.h
+++ v3.15-rc8-mmots-2014-06-03-16-28/include/linux/mm.h
@@ -1106,8 +1106,7 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *             right now." 0 means "skip the current vma."
  * @mm:        mm_struct representing the target process of page table walk
  * @vma:       vma currently walked
- * @skip:      internal control flag which is set when we skip the lower
- *             level entries.
+ * @control:   walk control flag
  * @private:   private data for callbacks' use
  *
  * (see the comment on walk_page_range() for more details)
@@ -1125,10 +1124,18 @@ struct mm_walk {
 			struct mm_walk *walk);
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
-	int skip;
+	int control;
 	void *private;
 };
 
+enum mm_walk_control {
+	PTWALK_NEXT = 0,	/* Go to the next entry in the same level or
+				 * the next vma. This is default behavior. */
+	PTWALK_DOWN,		/* Go down to lower level */
+	PTWALK_BREAK,		/* Break current loop and continue from the
+				 * next loop */
+};
+
 int walk_page_range(unsigned long addr, unsigned long end,
 		struct mm_walk *walk);
 int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/memcontrol.c v3.15-rc8-mmots-2014-06-03-16-28/mm/memcontrol.c
index 6970857ba0c8..aeab82bce739 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/memcontrol.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/mm/memcontrol.c
@@ -6729,9 +6729,8 @@ static int mem_cgroup_count_precharge_pmd(pmd_t *pmd,
 		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
 		spin_unlock(ptl);
-		/* don't call mem_cgroup_count_precharge_pte() */
-		walk->skip = 1;
-	}
+	} else
+		skip->control = PTWALK_DOWN;
 	return 0;
 }
 
diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/mempolicy.c v3.15-rc8-mmots-2014-06-03-16-28/mm/mempolicy.c
index cf3b995b21d0..cc9dc8c06bcb 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/mempolicy.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/mm/mempolicy.c
@@ -596,7 +596,6 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 	}
 
 	qp->prev = vma;
-	walk->skip = 1;
 
 	if (vma->vm_flags & VM_PFNMAP)
 		return 0;
@@ -610,7 +609,7 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 	    ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
 	     vma_migratable(vma)))
 		/* queue pages from current vma */
-		walk->skip = 0;
+		walk->control = PTWALK_DOWN;
 	return 0;
 }
 
diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/pagewalk.c v3.15-rc8-mmots-2014-06-03-16-28/mm/pagewalk.c
index 15c7585e8684..385efd59178f 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/pagewalk.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/mm/pagewalk.c
@@ -3,22 +3,12 @@
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
+static int get_reset_walk_control(struct mm_walk *walk)
 {
-	if (walk->skip) {
-		walk->skip = 0;
-		return true;
-	}
-	return false;
+	int ret = walk->control;
+	/* Reset to default value */
+	walk->control = PTWALK_NEXT;
+	return ret;
 }
 
 static int walk_pte_range(pmd_t *pmd, unsigned long addr,
@@ -47,7 +37,18 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr,
 		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
 		if (err)
 		       break;
+		switch (get_reset_walk_control(walk)) {
+		case PTWALK_NEXT:
+			continue;
+		case PTWALK_DOWN:
+			break;
+		case PTWALK_BREAK:
+			goto out_unlock;
+		default:
+			BUG();
+		}
 	} while (pte++, addr += PAGE_SIZE, addr < end);
+out_unlock:
 	pte_unmap_unlock(orig_pte, ptl);
 	cond_resched();
 	return addr == end ? 0 : err;
@@ -75,10 +76,16 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr,
 
 		if (walk->pmd_entry) {
 			err = walk->pmd_entry(pmd, addr, next, walk);
-			if (skip_lower_level_walking(walk))
-				continue;
 			if (err)
 				break;
+			switch (get_reset_walk_control(walk)) {
+			case PTWALK_NEXT:
+				continue;
+			case PTWALK_DOWN:
+				break;
+			default:
+				BUG();
+			}
 		}
 
 		if (walk->pte_entry) {
@@ -204,13 +211,13 @@ static inline int walk_hugetlb_range(unsigned long addr, unsigned long end,
 #endif /* CONFIG_HUGETLB_PAGE */
 
 /*
- * Decide whether we really walk over the current vma on [@start, @end)
- * or skip it. When we skip it, we set @walk->skip to 1.
- * The return value is used to control the page table walking to
- * continue (for zero) or not (for non-zero).
+ * Decide whether we really walk over the current vma on [@start, @end) or
+ * skip it. If we walk over it, we should set @walk->control to PTWALK_DOWN.
+ * Otherwise, we skip it. The return value is used to control the current
+ * walking to continue (for zero) or terminate (for non-zero).
  *
- * Default check (only VM_PFNMAP check for now) is used when the caller
- * doesn't define test_walk() callback.
+ * We fall through to the default check if the caller doesn't define its own
+ * test_walk() callback.
  */
 static int walk_page_test(unsigned long start, unsigned long end,
 			struct mm_walk *walk)
@@ -224,8 +231,8 @@ static int walk_page_test(unsigned long start, unsigned long end,
 	 * Do not walk over vma(VM_PFNMAP), because we have no valid struct
 	 * page backing a VM_PFNMAP range. See also commit a9ff785e4437.
 	 */
-	if (vma->vm_flags & VM_PFNMAP)
-		walk->skip = 1;
+	if (!(vma->vm_flags & VM_PFNMAP))
+		walk->control = PTWALK_DOWN;
 	return 0;
 }
 
@@ -266,7 +273,7 @@ static int __walk_page_range(unsigned long start, unsigned long end,
  * defines test_walk(), pmd_entry(), and pte_entry(), then callbacks are
  * called in the order of test_walk(), pmd_entry(), and pte_entry().
  * If you don't want to go down to lower level at some point and move to
- * the next entry in the same level, you set @walk->skip to 1.
+ * the next entry in the same level, you set @walk->control to PTWALK_DOWN.
  * For example if you succeed to handle some pmd entry as trans_huge entry,
  * you need not call walk_pte_range() any more, so set it to avoid that.
  * We can't determine whether to go down to lower level with the return
@@ -310,10 +317,16 @@ int walk_page_range(unsigned long start, unsigned long end,
 			next = min(end, vma->vm_end);
 
 			err = walk_page_test(start, next, walk);
-			if (skip_lower_level_walking(walk))
-				continue;
 			if (err)
 				break;
+			switch (get_reset_walk_control(walk)) {
+			case PTWALK_NEXT:
+				continue;
+			case PTWALK_DOWN:
+				break;
+			default:
+				BUG();
+			}
 		}
 		err = __walk_page_range(start, next, walk);
 		if (err)
@@ -333,9 +346,15 @@ int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
 	VM_BUG_ON(!vma);
 	walk->vma = vma;
 	err = walk_page_test(vma->vm_start, vma->vm_end, walk);
-	if (skip_lower_level_walking(walk))
-		return 0;
 	if (err)
 		return err;
+	switch (get_reset_walk_control(walk)) {
+	case PTWALK_NEXT:
+		return 0;
+	case PTWALK_DOWN:
+		break;
+	default:
+		BUG();
+	}
 	return __walk_page_range(vma->vm_start, vma->vm_end, walk);
 }
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
