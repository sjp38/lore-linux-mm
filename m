Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 977276B008C
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 18:59:01 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id ho1so1768631wib.7
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 15:59:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d5si49730633wiw.57.2014.06.06.15.58.59
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 15:59:00 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/7] madvise: cleanup swapin_walk_pmd_entry()
Date: Fri,  6 Jun 2014 18:58:36 -0400
Message-Id: <1402095520-10109-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

With the recent update on page table walker, we can use common code for
the walking more. Unlike many other users, this swapin_walk expects to
handle swap entries. As a result we should be careful about ptl locking.
Swapin operation, read_swap_cache_async(), could cause page reclaim, so
we can't keep holding ptl throughout this pte loop.
In order to properly handle ptl in pte_entry(), this patch adds two new
members on struct mm_walk.

This cleanup is necessary to get to the final form of page table walker,
where we should do all caller's specific work on leaf entries (IOW, all
pmd_entry() should be used for trans_pmd.)

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>
---
 include/linux/mm.h |  4 ++++
 mm/madvise.c       | 54 +++++++++++++++++++++++-------------------------------
 mm/pagewalk.c      |  5 +++--
 3 files changed, 30 insertions(+), 33 deletions(-)

diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/include/linux/mm.h v3.15-rc8-mmots-2014-06-03-16-28/include/linux/mm.h
index 43449eba3032..a94166b1b48b 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/include/linux/mm.h
+++ v3.15-rc8-mmots-2014-06-03-16-28/include/linux/mm.h
@@ -1106,6 +1106,8 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *             right now." 0 means "skip the current vma."
  * @mm:        mm_struct representing the target process of page table walk
  * @vma:       vma currently walked
+ * @pmd:       current pmd entry
+ * @ptl:       page table lock associated with current entry
  * @control:   walk control flag
  * @private:   private data for callbacks' use
  *
@@ -1124,6 +1126,8 @@ struct mm_walk {
 			struct mm_walk *walk);
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
+	pmd_t *pmd;
+	spinlock_t *ptl;
 	int control;
 	void *private;
 };
diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/madvise.c v3.15-rc8-mmots-2014-06-03-16-28/mm/madvise.c
index a402f8fdc68e..06b390a6fbbd 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/madvise.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/mm/madvise.c
@@ -135,38 +135,31 @@ static long madvise_behavior(struct vm_area_struct *vma,
 }
 
 #ifdef CONFIG_SWAP
-static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
+/*
+ * Assuming that page table walker holds page table lock.
+ */
+static int swapin_walk_pte_entry(pte_t *pte, unsigned long start,
 	unsigned long end, struct mm_walk *walk)
 {
-	pte_t *orig_pte;
-	struct vm_area_struct *vma = walk->private;
-	unsigned long index;
-
-	if (pmd_none_or_trans_huge_or_clear_bad(pmd))
-		return 0;
-
-	for (index = start; index != end; index += PAGE_SIZE) {
-		pte_t pte;
-		swp_entry_t entry;
-		struct page *page;
-		spinlock_t *ptl;
-
-		orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);
-		pte = *(orig_pte + ((index - start) / PAGE_SIZE));
-		pte_unmap_unlock(orig_pte, ptl);
-
-		if (pte_present(pte) || pte_none(pte) || pte_file(pte))
-			continue;
-		entry = pte_to_swp_entry(pte);
-		if (unlikely(non_swap_entry(entry)))
-			continue;
-
-		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
-								vma, index);
-		if (page)
-			page_cache_release(page);
-	}
+	pte_t ptent;
+	pte_t *orig_pte = pte - ((start & (PMD_SIZE - 1)) >> PAGE_SHIFT);
+	swp_entry_t entry;
+	struct page *page;
 
+	ptent = *pte;
+	pte_unmap_unlock(orig_pte, walk->ptl);
+	if (pte_present(ptent) || pte_none(ptent) || pte_file(ptent))
+		goto lock;
+	entry = pte_to_swp_entry(ptent);
+	if (unlikely(non_swap_entry(entry)))
+		goto lock;
+	page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
+				     walk->vma, start);
+	if (page)
+		page_cache_release(page);
+lock:
+	pte_offset_map(walk->pmd, start & PMD_MASK);
+	spin_lock(walk->ptl);
 	return 0;
 }
 
@@ -175,8 +168,7 @@ static void force_swapin_readahead(struct vm_area_struct *vma,
 {
 	struct mm_walk walk = {
 		.mm = vma->vm_mm,
-		.pmd_entry = swapin_walk_pmd_entry,
-		.private = vma,
+		.pte_entry = swapin_walk_pte_entry,
 	};
 
 	walk_page_range(start, end, &walk);
diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/pagewalk.c v3.15-rc8-mmots-2014-06-03-16-28/mm/pagewalk.c
index 385efd59178f..8d71e09a36ea 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/pagewalk.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/mm/pagewalk.c
@@ -20,7 +20,8 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	int err = 0;
 
-	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	walk->pmd = pmd;
+	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &walk->ptl);
 	do {
 		if (pte_none(*pte)) {
 			if (walk->pte_hole)
@@ -49,7 +50,7 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr,
 		}
 	} while (pte++, addr += PAGE_SIZE, addr < end);
 out_unlock:
-	pte_unmap_unlock(orig_pte, ptl);
+	pte_unmap_unlock(orig_pte, walk->ptl);
 	cond_resched();
 	return addr == end ? 0 : err;
 }
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
