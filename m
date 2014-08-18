Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id AB9B06B003D
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 20:17:42 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id x48so4307084wes.5
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 17:17:42 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id m9si14119876wib.84.2014.08.17.17.17.35
        for <linux-mm@kvack.org>;
        Sun, 17 Aug 2014 17:17:37 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v15 7/7] mm: Don't split THP page when syscall is called
Date: Mon, 18 Aug 2014 09:17:56 +0900
Message-Id: <1408321076-2231-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1408321076-2231-1-git-send-email-minchan@kernel.org>
References: <1408321076-2231-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't need to split THP page when MADV_FREE syscall is
called. It could be done when VM decide really frees it so
we could avoid unnecessary THP split.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/huge_mm.h |  4 ++++
 mm/huge_memory.c        | 35 +++++++++++++++++++++++++++++++++++
 mm/madvise.c            | 21 ++++++++++++++++++++-
 mm/rmap.c               |  8 ++++++--
 mm/vmscan.c             | 28 ++++++++++++++++++----------
 5 files changed, 83 insertions(+), 13 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 63579cb8d3dc..25a961256d9f 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -19,6 +19,9 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
 					  pmd_t *pmd,
 					  unsigned int flags);
+extern int madvise_free_huge_pmd(struct mmu_gather *tlb,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, unsigned long addr);
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
@@ -56,6 +59,7 @@ extern pmd_t *page_check_address_pmd(struct page *page,
 				     unsigned long address,
 				     enum page_check_address_pmd_flag flag,
 				     spinlock_t **ptl);
+extern int pmd_freeable(pmd_t pmd);
 
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d9a21d06b862..6d9faa652f54 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1384,6 +1384,36 @@ out:
 	return 0;
 }
 
+int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		 pmd_t *pmd, unsigned long addr)
+
+{
+	spinlock_t *ptl;
+	struct mm_struct *mm = tlb->mm;
+	int ret = 1;
+
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+		struct page *page;
+		pmd_t orig_pmd;
+
+		orig_pmd = pmdp_get_and_clear(mm, addr, pmd);
+
+		/* No hugepage in swapcache */
+		page = pmd_page(orig_pmd);
+		VM_BUG_ON_PAGE(PageSwapCache(page), page);
+
+		orig_pmd = pmd_mkold(orig_pmd);
+		orig_pmd = pmd_mkclean(orig_pmd);
+
+		set_pmd_at(mm, addr, pmd, orig_pmd);
+		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+		spin_unlock(ptl);
+		ret = 0;
+	}
+
+	return ret;
+}
+
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
@@ -1620,6 +1650,11 @@ unlock:
 	return NULL;
 }
 
+int pmd_freeable(pmd_t pmd)
+{
+	return !pmd_dirty(pmd);
+}
+
 static int __split_huge_page_splitting(struct page *page,
 				       struct vm_area_struct *vma,
 				       unsigned long address)
diff --git a/mm/madvise.c b/mm/madvise.c
index a21584235bb6..84badee5f46d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -271,8 +271,26 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	pte_t *pte, ptent;
 	struct page *page;
+	unsigned long next;
+
+	next = pmd_addr_end(addr, end);
+	if (pmd_trans_huge(*pmd)) {
+		if (next - addr != HPAGE_PMD_SIZE) {
+#ifdef CONFIG_DEBUG_VM
+			if (!rwsem_is_locked(&mm->mmap_sem)) {
+				pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
+					__func__, addr, end,
+					vma->vm_start,
+					vma->vm_end);
+				BUG();
+			}
+#endif
+			split_huge_page_pmd(vma, addr, pmd);
+		} else if (!madvise_free_huge_pmd(tlb, vma, pmd, addr))
+			goto next;
+		/* fall through */
+	}
 
-	split_huge_page_pmd(vma, addr, pmd);
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
@@ -316,6 +334,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	}
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
+next:
 	cond_resched();
 	return 0;
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 04c181133890..9c407576ff8e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -704,9 +704,13 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			referenced++;
 
 		/*
-		 * In this implmentation, MADV_FREE doesn't support THP free
+		 * Use pmd_freeable instead of raw pmd_dirty because in some
+		 * of architecture, pmd_dirty is not defined unless
+		 * CONFIG_TRANSPARNTE_HUGE is enabled
 		 */
-		dirty++;
+		if (!pmd_freeable(*pmd))
+			dirty++;
+
 		spin_unlock(ptl);
 	} else {
 		pte_t *pte;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 76c2cc858323..d404da3ad1a5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -976,17 +976,25 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page) && !freeable) {
-			if (!(sc->gfp_mask & __GFP_IO))
-				goto keep_locked;
-			if (!add_to_swap(page, page_list))
-				goto activate_locked;
-			may_enter_fs = 1;
-
-			/* Adding to swap updated mapping */
-			mapping = page_mapping(page);
+		if (PageAnon(page) && !PageSwapCache(page)) {
+			if (!freeable) {
+				if (!(sc->gfp_mask & __GFP_IO))
+					goto keep_locked;
+				if (!add_to_swap(page, page_list))
+					goto activate_locked;
+				may_enter_fs = 1;
+				/* Adding to swap updated mapping */
+				mapping = page_mapping(page);
+			} else {
+				if (likely(!PageTransHuge(page)))
+					goto unmap;
+				/* try_to_unmap isn't aware of THP page */
+				if (unlikely(split_huge_page_to_list(page,
+								page_list)))
+					goto keep_locked;
+			}
 		}
-
+unmap:
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
