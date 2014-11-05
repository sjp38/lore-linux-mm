Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 42C206B009F
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:30 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id eu11so933507pac.9
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:29 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qd3si3316359pac.23.2014.11.05.06.50.18
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:19 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 17/19] mlock, thp: HACK: split all pages in VM_LOCKED vma
Date: Wed,  5 Nov 2014 16:49:52 +0200
Message-Id: <1415198994-15252-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't yet handle mlocked pages properly with new THP refcounting.
For now we split all pages in VMA on mlock and disallow khugepaged
collapse pages in the VMA. If split failed on mlock() we fail the
syscall with -EBUSY.
---
 include/linux/huge_mm.h |  24 +++++++++
 mm/huge_memory.c        |  17 ++-----
 mm/mlock.c              | 130 +++++++++++++++++++++++++++++++++---------------
 3 files changed, 118 insertions(+), 53 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 94f331166974..abe146bd8ed7 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -140,6 +140,18 @@ static inline int hpage_nr_pages(struct page *page)
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
+extern struct page *huge_zero_page __read_mostly;
+
+static inline bool is_huge_zero_page(struct page *page)
+{
+	return ACCESS_ONCE(huge_zero_page) == page;
+}
+
+static inline bool is_huge_zero_pmd(pmd_t pmd)
+{
+	return is_huge_zero_page(pmd_page(pmd));
+}
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -185,6 +197,18 @@ static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_str
 	return 0;
 }
 
+static inline bool is_huge_zero_page(struct page *page)
+{
+	BUG();
+	return 0;
+}
+
+static inline bool is_huge_zero_pmd(pmd_t pmd)
+{
+	BUG();
+	return 0;
+}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 95f2a83ad9d8..555a9134dfa0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -171,17 +171,7 @@ static int start_khugepaged(void)
 }
 
 static atomic_t huge_zero_refcount;
-static struct page *huge_zero_page __read_mostly;
-
-static inline bool is_huge_zero_page(struct page *page)
-{
-	return ACCESS_ONCE(huge_zero_page) == page;
-}
-
-static inline bool is_huge_zero_pmd(pmd_t pmd)
-{
-	return is_huge_zero_page(pmd_page(pmd));
-}
+struct page *huge_zero_page __read_mostly;
 
 static struct page *get_huge_zero_page(void)
 {
@@ -801,6 +791,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
 		return VM_FAULT_FALLBACK;
+	if (vma->vm_flags & VM_LOCKED)
+		return VM_FAULT_FALLBACK;
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma)))
@@ -2352,7 +2344,8 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
 	    (vma->vm_flags & VM_NOHUGEPAGE))
 		return false;
-
+	if (vma->vm_flags & VM_LOCKED)
+		return false;
 	if (!vma->anon_vma || vma->vm_ops)
 		return false;
 	if (is_vma_temporary_stack(vma))
diff --git a/mm/mlock.c b/mm/mlock.c
index ce84cb0b83ef..e3a367685503 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -500,38 +500,26 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 				&page_mask);
 
 		if (page && !IS_ERR(page)) {
-			if (PageTransHuge(page)) {
-				lock_page(page);
-				/*
-				 * Any THP page found by follow_page_mask() may
-				 * have gotten split before reaching
-				 * munlock_vma_page(), so we need to recompute
-				 * the page_mask here.
-				 */
-				page_mask = munlock_vma_page(page);
-				unlock_page(page);
-				put_page(page); /* follow_page_mask() */
-			} else {
-				/*
-				 * Non-huge pages are handled in batches via
-				 * pagevec. The pin from follow_page_mask()
-				 * prevents them from collapsing by THP.
-				 */
-				pagevec_add(&pvec, page);
-				zone = page_zone(page);
-				zoneid = page_zone_id(page);
+			VM_BUG_ON_PAGE(PageTransCompound(page), page);
+			/*
+			 * Non-huge pages are handled in batches via
+			 * pagevec. The pin from follow_page_mask()
+			 * prevents them from collapsing by THP.
+			 */
+			pagevec_add(&pvec, page);
+			zone = page_zone(page);
+			zoneid = page_zone_id(page);
 
-				/*
-				 * Try to fill the rest of pagevec using fast
-				 * pte walk. This will also update start to
-				 * the next page to process. Then munlock the
-				 * pagevec.
-				 */
-				start = __munlock_pagevec_fill(&pvec, vma,
-						zoneid, start, end);
-				__munlock_pagevec(&pvec, zone);
-				goto next;
-			}
+			/*
+			 * Try to fill the rest of pagevec using fast
+			 * pte walk. This will also update start to
+			 * the next page to process. Then munlock the
+			 * pagevec.
+			 */
+			start = __munlock_pagevec_fill(&pvec, vma,
+					zoneid, start, end);
+			__munlock_pagevec(&pvec, zone);
+			goto next;
 		}
 		/* It's a bug to munlock in the middle of a THP page */
 		VM_BUG_ON((start >> PAGE_SHIFT) & page_mask);
@@ -542,6 +530,60 @@ next:
 	}
 }
 
+static int thp_split(pmd_t *pmd, unsigned long addr, unsigned long end,
+		struct mm_walk *walk)
+{
+	spinlock_t *ptl;
+	struct page *page = NULL;
+	pte_t *pte;
+	int err = 0;
+
+retry:
+	if (pmd_none(*pmd))
+		return 0;
+	if (pmd_trans_huge(*pmd)) {
+		if (is_huge_zero_pmd(*pmd)) {
+			split_huge_pmd(walk->vma, pmd, addr);
+			return 0;
+		}
+		ptl = pmd_lock(walk->mm, pmd);
+		if (!pmd_trans_huge(*pmd)) {
+			spin_unlock(ptl);
+			goto retry;
+		}
+		page = pmd_page(*pmd);
+		VM_BUG_ON_PAGE(!PageHead(page), page);
+		get_page(page);
+		spin_unlock(ptl);
+		err = split_huge_page(page);
+		put_page(page);
+		return err;
+	}
+	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	do {
+		if (!pte_present(*pte))
+			continue;
+		page = vm_normal_page(walk->vma, addr, *pte);
+		if (!page)
+			continue;
+		if (PageTransCompound(page)) {
+			page = compound_head(page);
+			get_page(page);
+			spin_unlock(ptl);
+			err = split_huge_page(page);
+			spin_lock(ptl);
+			put_page(page);
+			if (!err) {
+				VM_BUG_ON_PAGE(compound_mapcount(page), page);
+				VM_BUG_ON_PAGE(PageTransCompound(page), page);
+			} else
+				break;
+		}
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	return err;
+}
+
 /*
  * mlock_fixup  - handle mlock[all]/munlock[all] requests.
  *
@@ -586,24 +628,30 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 
 success:
 	/*
-	 * Keep track of amount of locked VM.
-	 */
-	nr_pages = (end - start) >> PAGE_SHIFT;
-	if (!lock)
-		nr_pages = -nr_pages;
-	mm->locked_vm += nr_pages;
-
-	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 * It's okay if try_to_unmap_one unmaps a page just after we
 	 * set VM_LOCKED, __mlock_vma_pages_range will bring it back.
 	 */
 
-	if (lock)
+	if (lock) {
+		struct mm_walk thp_split_walk = {
+			.mm = mm,
+			.pmd_entry = thp_split,
+		};
+		ret = walk_page_vma(vma, &thp_split_walk);
+		if (ret)
+			goto out;
 		vma->vm_flags = newflags;
-	else
+	} else
 		munlock_vma_pages_range(vma, start, end);
 
+	/*
+	 * Keep track of amount of locked VM.
+	 */
+	nr_pages = (end - start) >> PAGE_SHIFT;
+	if (!lock)
+		nr_pages = -nr_pages;
+	mm->locked_vm += nr_pages;
 out:
 	*prev = vma;
 	return ret;
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
