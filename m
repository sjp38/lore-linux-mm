Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 36BA66B026E
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:27:05 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so281676359pge.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:27:05 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id d20si9188338pfb.20.2017.01.25.10.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:27:04 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 11/12] mm: drop page_check_address{,_transhuge}
Date: Wed, 25 Jan 2017 21:25:37 +0300
Message-Id: <20170125182538.86249-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

All users are gone. Let's drop them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h |  36 --------------
 mm/rmap.c            | 138 ---------------------------------------------------
 2 files changed, 174 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b76343610653..8c89e902df3e 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -197,42 +197,6 @@ int page_referenced(struct page *, int is_locked,
 
 int try_to_unmap(struct page *, enum ttu_flags flags);
 
-/*
- * Used by uprobes to replace a userspace page safely
- */
-pte_t *__page_check_address(struct page *, struct mm_struct *,
-				unsigned long, spinlock_t **, int);
-
-static inline pte_t *page_check_address(struct page *page, struct mm_struct *mm,
-					unsigned long address,
-					spinlock_t **ptlp, int sync)
-{
-	pte_t *ptep;
-
-	__cond_lock(*ptlp, ptep = __page_check_address(page, mm, address,
-						       ptlp, sync));
-	return ptep;
-}
-
-/*
- * Used by idle page tracking to check if a page was referenced via page
- * tables.
- */
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-bool page_check_address_transhuge(struct page *page, struct mm_struct *mm,
-				  unsigned long address, pmd_t **pmdp,
-				  pte_t **ptep, spinlock_t **ptlp);
-#else
-static inline bool page_check_address_transhuge(struct page *page,
-				struct mm_struct *mm, unsigned long address,
-				pmd_t **pmdp, pte_t **ptep, spinlock_t **ptlp)
-{
-	*ptep = page_check_address(page, mm, address, ptlp, 0);
-	*pmdp = NULL;
-	return !!*ptep;
-}
-#endif
-
 /* Avoid racy checks */
 #define PVMW_SYNC		(1 << 0)
 /* Look for migarion entries rather than present PTEs */
diff --git a/mm/rmap.c b/mm/rmap.c
index 5d5e504c41d8..c1d8f52c2c7e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -708,144 +708,6 @@ pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address)
 	return pmd;
 }
 
-/*
- * Check that @page is mapped at @address into @mm.
- *
- * If @sync is false, page_check_address may perform a racy check to avoid
- * the page table lock when the pte is not present (helpful when reclaiming
- * highly shared pages).
- *
- * On success returns with pte mapped and locked.
- */
-pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
-			  unsigned long address, spinlock_t **ptlp, int sync)
-{
-	pmd_t *pmd;
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	if (unlikely(PageHuge(page))) {
-		/* when pud is not present, pte will be NULL */
-		pte = huge_pte_offset(mm, address);
-		if (!pte)
-			return NULL;
-
-		ptl = huge_pte_lockptr(page_hstate(page), mm, pte);
-		goto check;
-	}
-
-	pmd = mm_find_pmd(mm, address);
-	if (!pmd)
-		return NULL;
-
-	pte = pte_offset_map(pmd, address);
-	/* Make a quick check before getting the lock */
-	if (!sync && !pte_present(*pte)) {
-		pte_unmap(pte);
-		return NULL;
-	}
-
-	ptl = pte_lockptr(mm, pmd);
-check:
-	spin_lock(ptl);
-	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
-		*ptlp = ptl;
-		return pte;
-	}
-	pte_unmap_unlock(pte, ptl);
-	return NULL;
-}
-
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-/*
- * Check that @page is mapped at @address into @mm. In contrast to
- * page_check_address(), this function can handle transparent huge pages.
- *
- * On success returns true with pte mapped and locked. For PMD-mapped
- * transparent huge pages *@ptep is set to NULL.
- */
-bool page_check_address_transhuge(struct page *page, struct mm_struct *mm,
-				  unsigned long address, pmd_t **pmdp,
-				  pte_t **ptep, spinlock_t **ptlp)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	if (unlikely(PageHuge(page))) {
-		/* when pud is not present, pte will be NULL */
-		pte = huge_pte_offset(mm, address);
-		if (!pte)
-			return false;
-
-		ptl = huge_pte_lockptr(page_hstate(page), mm, pte);
-		pmd = NULL;
-		goto check_pte;
-	}
-
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		return false;
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		return false;
-	pmd = pmd_offset(pud, address);
-
-	if (pmd_trans_huge(*pmd)) {
-		ptl = pmd_lock(mm, pmd);
-		if (!pmd_present(*pmd))
-			goto unlock_pmd;
-		if (unlikely(!pmd_trans_huge(*pmd))) {
-			spin_unlock(ptl);
-			goto map_pte;
-		}
-
-		if (pmd_page(*pmd) != page)
-			goto unlock_pmd;
-
-		pte = NULL;
-		goto found;
-unlock_pmd:
-		spin_unlock(ptl);
-		return false;
-	} else {
-		pmd_t pmde = *pmd;
-
-		barrier();
-		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
-			return false;
-	}
-map_pte:
-	pte = pte_offset_map(pmd, address);
-	if (!pte_present(*pte)) {
-		pte_unmap(pte);
-		return false;
-	}
-
-	ptl = pte_lockptr(mm, pmd);
-check_pte:
-	spin_lock(ptl);
-
-	if (!pte_present(*pte)) {
-		pte_unmap_unlock(pte, ptl);
-		return false;
-	}
-
-	/* THP can be referenced by any subpage */
-	if (pte_pfn(*pte) - page_to_pfn(page) >= hpage_nr_pages(page)) {
-		pte_unmap_unlock(pte, ptl);
-		return false;
-	}
-found:
-	*ptep = pte;
-	*pmdp = pmd;
-	*ptlp = ptl;
-	return true;
-}
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-
 struct page_referenced_arg {
 	int mapcount;
 	int referenced;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
