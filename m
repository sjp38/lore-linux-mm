Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id DAEDA6B0254
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 10:26:40 -0500 (EST)
Received: by iodd200 with SMTP id d200so22084072iod.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 07:26:40 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id w41si21060095ioi.169.2015.11.03.07.26.39
        for <linux-mm@kvack.org>;
        Tue, 03 Nov 2015 07:26:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/4] mm: prepare page_referenced() and page_idle to new THP refcounting
Date: Tue,  3 Nov 2015 17:26:15 +0200
Message-Id: <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@parallels.com>

I've missed two simlar codepath which need some preparation to work well
with reworked THP refcounting.

Both page_referenced() and page_idle_clear_pte_refs_one() assume that
THP can only be mapped with PMD, so there's no reason to look on PTEs
for PageTransHuge() pages. That's no true anymore: THP can be mapped
with PTEs too.

The patch removes PageTransHuge() test from the functions and opencode
page table check.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/huge_mm.h |   4 --
 include/linux/mm.h      |  19 ++++++++
 mm/huge_memory.c        |  54 ----------------------
 mm/page_idle.c          |  64 ++++++++++++++++++++++----
 mm/rmap.c               | 118 +++++++++++++++++++++++++++++++++---------------
 5 files changed, 155 insertions(+), 104 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index f7c3f13f3a9c..5c7b00e88236 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -51,10 +51,6 @@ enum transparent_hugepage_flag {
 #endif
 };
 
-extern pmd_t *page_check_address_pmd(struct page *page,
-				     struct mm_struct *mm,
-				     unsigned long address,
-				     spinlock_t **ptl);
 extern int pmd_freeable(pmd_t pmd);
 
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b4cd988a794a..a36f9fa4e4cd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -432,6 +432,25 @@ static inline int page_mapcount(struct page *page)
 	return ret;
 }
 
+static inline int total_mapcount(struct page *page)
+{
+	int i, ret;
+
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
+	if (likely(!PageCompound(page)))
+		return atomic_read(&page->_mapcount) + 1;
+
+	ret = compound_mapcount(page);
+	if (PageHuge(page))
+		return ret;
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		ret += atomic_read(&page[i]._mapcount) + 1;
+	if (PageDoubleMap(page))
+		ret -= HPAGE_PMD_NR;
+	return ret;
+}
+
 static inline int page_count(struct page *page)
 {
 	return atomic_read(&compound_head(page)->_count);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3700981f8035..14cbbad54a3e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1713,46 +1713,6 @@ bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 	return false;
 }
 
-/*
- * This function returns whether a given @page is mapped onto the @address
- * in the virtual space of @mm.
- *
- * When it's true, this function returns *pmd with holding the page table lock
- * and passing it back to the caller via @ptl.
- * If it's false, returns NULL without holding the page table lock.
- */
-pmd_t *page_check_address_pmd(struct page *page,
-			      struct mm_struct *mm,
-			      unsigned long address,
-			      spinlock_t **ptl)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-
-	if (address & ~HPAGE_PMD_MASK)
-		return NULL;
-
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		return NULL;
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		return NULL;
-	pmd = pmd_offset(pud, address);
-
-	*ptl = pmd_lock(mm, pmd);
-	if (!pmd_present(*pmd))
-		goto unlock;
-	if (pmd_page(*pmd) != page)
-		goto unlock;
-	if (pmd_trans_huge(*pmd))
-		return pmd;
-unlock:
-	spin_unlock(*ptl);
-	return NULL;
-}
-
 #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
@@ -3169,20 +3129,6 @@ static void unfreeze_page(struct anon_vma *anon_vma, struct page *page)
 	}
 }
 
-static int total_mapcount(struct page *page)
-{
-	int i, ret;
-
-	ret = compound_mapcount(page);
-	for (i = 0; i < HPAGE_PMD_NR; i++)
-		ret += atomic_read(&page[i]._mapcount) + 1;
-
-	if (PageDoubleMap(page))
-		ret -= HPAGE_PMD_NR;
-
-	return ret;
-}
-
 static int __split_huge_page_tail(struct page *head, int tail,
 		struct lruvec *lruvec, struct list_head *list)
 {
diff --git a/mm/page_idle.c b/mm/page_idle.c
index 1c245d9027e3..2c9ebe12b40d 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -56,23 +56,69 @@ static int page_idle_clear_pte_refs_one(struct page *page,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
+	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	bool referenced = false;
 
-	if (unlikely(PageTransHuge(page))) {
-		pmd = page_check_address_pmd(page, mm, addr, &ptl);
-		if (pmd) {
-			referenced = pmdp_clear_young_notify(vma, addr, pmd);
+	pgd = pgd_offset(mm, addr);
+	if (!pgd_present(*pgd))
+		return SWAP_AGAIN;
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud))
+		return SWAP_AGAIN;
+	pmd = pmd_offset(pud, addr);
+
+	if (pmd_trans_huge(*pmd)) {
+		ptl = pmd_lock(mm, pmd);
+                if (!pmd_present(*pmd))
+			goto unlock_pmd;
+		if (unlikely(!pmd_trans_huge(*pmd))) {
 			spin_unlock(ptl);
+			goto map_pte;
 		}
+
+		if (pmd_page(*pmd) != page)
+			goto unlock_pmd;
+
+		referenced = pmdp_clear_young_notify(vma, addr, pmd);
+		spin_unlock(ptl);
+		goto found;
+unlock_pmd:
+		spin_unlock(ptl);
+		return SWAP_AGAIN;
 	} else {
-		pte = page_check_address(page, mm, addr, &ptl, 0);
-		if (pte) {
-			referenced = ptep_clear_young_notify(vma, addr, pte);
-			pte_unmap_unlock(pte, ptl);
-		}
+		pmd_t pmde = *pmd;
+		barrier();
+		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
+			return SWAP_AGAIN;
+
+	}
+map_pte:
+	pte = pte_offset_map(pmd, addr);
+	if (!pte_present(*pte)) {
+		pte_unmap(pte);
+		return SWAP_AGAIN;
 	}
+
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+
+	if (!pte_present(*pte)) {
+		pte_unmap_unlock(pte, ptl);
+		return SWAP_AGAIN;
+	}
+
+	/* THP can be referenced by any subpage */
+	if (pte_pfn(*pte) - page_to_pfn(page) >= hpage_nr_pages(page)) {
+		pte_unmap_unlock(pte, ptl);
+		return SWAP_AGAIN;
+	}
+
+	referenced = ptep_clear_young_notify(vma, addr, pte);
+	pte_unmap_unlock(pte, ptl);
+found:
 	if (referenced) {
 		clear_page_idle(page);
 		/*
diff --git a/mm/rmap.c b/mm/rmap.c
index ad9af8b3a381..0837487d3737 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -812,60 +812,104 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int referenced = 0;
 	struct page_referenced_arg *pra = arg;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
 
-	if (unlikely(PageTransHuge(page))) {
-		pmd_t *pmd;
-
-		/*
-		 * rmap might return false positives; we must filter
-		 * these out using page_check_address_pmd().
-		 */
-		pmd = page_check_address_pmd(page, mm, address, &ptl);
-		if (!pmd)
+	if (unlikely(PageHuge(page))) {
+		/* when pud is not present, pte will be NULL */
+		pte = huge_pte_offset(mm, address);
+		if (!pte)
 			return SWAP_AGAIN;
 
-		if (vma->vm_flags & VM_LOCKED) {
+		ptl = huge_pte_lockptr(page_hstate(page), mm, pte);
+		goto check_pte;
+	}
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return SWAP_AGAIN;
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return SWAP_AGAIN;
+	pmd = pmd_offset(pud, address);
+
+	if (pmd_trans_huge(*pmd)) {
+		int ret = SWAP_AGAIN;
+
+		ptl = pmd_lock(mm, pmd);
+		if (!pmd_present(*pmd))
+			goto unlock_pmd;
+		if (unlikely(!pmd_trans_huge(*pmd))) {
 			spin_unlock(ptl);
+			goto map_pte;
+		}
+
+		if (pmd_page(*pmd) != page)
+			goto unlock_pmd;
+
+		if (vma->vm_flags & VM_LOCKED) {
 			pra->vm_flags |= VM_LOCKED;
-			return SWAP_FAIL; /* To break the loop */
+			ret = SWAP_FAIL; /* To break the loop */
+			goto unlock_pmd;
 		}
 
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
-
 		spin_unlock(ptl);
+		goto found;
+unlock_pmd:
+		spin_unlock(ptl);
+		return ret;
 	} else {
-		pte_t *pte;
-
-		/*
-		 * rmap might return false positives; we must filter
-		 * these out using page_check_address().
-		 */
-		pte = page_check_address(page, mm, address, &ptl, 0);
-		if (!pte)
+		pmd_t pmde = *pmd;
+		barrier();
+		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
 			return SWAP_AGAIN;
+	}
+map_pte:
+	pte = pte_offset_map(pmd, address);
+	if (!pte_present(*pte)) {
+		pte_unmap(pte);
+		return SWAP_AGAIN;
+	}
 
-		if (vma->vm_flags & VM_LOCKED) {
-			pte_unmap_unlock(pte, ptl);
-			pra->vm_flags |= VM_LOCKED;
-			return SWAP_FAIL; /* To break the loop */
-		}
+	ptl = pte_lockptr(mm, pmd);
+check_pte:
+	spin_lock(ptl);
 
-		if (ptep_clear_flush_young_notify(vma, address, pte)) {
-			/*
-			 * Don't treat a reference through a sequentially read
-			 * mapping as such.  If the page has been used in
-			 * another mapping, we will catch it; if this other
-			 * mapping is already gone, the unmap path will have
-			 * set PG_referenced or activated the page.
-			 */
-			if (likely(!(vma->vm_flags & VM_SEQ_READ)))
-				referenced++;
-		}
+	if (!pte_present(*pte)) {
+		pte_unmap_unlock(pte, ptl);
+		return SWAP_AGAIN;
+	}
+
+	/* THP can be referenced by any subpage */
+	if (pte_pfn(*pte) - page_to_pfn(page) >= hpage_nr_pages(page)) {
+		pte_unmap_unlock(pte, ptl);
+		return SWAP_AGAIN;
+	}
 
+	if (vma->vm_flags & VM_LOCKED) {
 		pte_unmap_unlock(pte, ptl);
+		pra->vm_flags |= VM_LOCKED;
+		return SWAP_FAIL; /* To break the loop */
 	}
 
+	if (ptep_clear_flush_young_notify(vma, address, pte)) {
+		/*
+		 * Don't treat a reference through a sequentially read
+		 * mapping as such.  If the page has been used in
+		 * another mapping, we will catch it; if this other
+		 * mapping is already gone, the unmap path will have
+		 * set PG_referenced or activated the page.
+		 */
+		if (likely(!(vma->vm_flags & VM_SEQ_READ)))
+			referenced++;
+	}
+	pte_unmap_unlock(pte, ptl);
+
+found:
 	if (referenced)
 		clear_page_idle(page);
 	if (test_and_clear_page_young(page))
@@ -912,7 +956,7 @@ int page_referenced(struct page *page,
 	int ret;
 	int we_locked = 0;
 	struct page_referenced_arg pra = {
-		.mapcount = page_mapcount(page),
+		.mapcount = total_mapcount(page),
 		.memcg = memcg,
 	};
 	struct rmap_walk_control rwc = {
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
