Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0306B0273
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:27:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 194so281345867pgd.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:27:36 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t11si2338395plm.267.2017.01.25.10.27.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:27:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 12/12] mm: convert remove_migration_pte() to page_vma_mapped_walk()
Date: Wed, 25 Jan 2017 21:25:38 +0300
Message-Id: <20170125182538.86249-13-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

remove_migration_pte() also can easily be converted to page_vma_mapped_walk().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/migrate.c | 104 +++++++++++++++++++++++------------------------------------
 1 file changed, 41 insertions(+), 63 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 87f4d0f81819..366466ed7fdc 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -193,82 +193,60 @@ void putback_movable_pages(struct list_head *l)
 /*
  * Restore a potential migration pte to a working pte entry
  */
-static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
+static int remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 				 unsigned long addr, void *old)
 {
-	struct mm_struct *mm = vma->vm_mm;
+	struct page_vma_mapped_walk pvmw = {
+		.page = old,
+		.vma = vma,
+		.address = addr,
+		.flags = PVMW_SYNC | PVMW_MIGRATION,
+	};
+	struct page *new;
+	pte_t pte;
 	swp_entry_t entry;
- 	pmd_t *pmd;
-	pte_t *ptep, pte;
- 	spinlock_t *ptl;
 
-	if (unlikely(PageHuge(new))) {
-		ptep = huge_pte_offset(mm, addr);
-		if (!ptep)
-			goto out;
-		ptl = huge_pte_lockptr(hstate_vma(vma), mm, ptep);
-	} else {
-		pmd = mm_find_pmd(mm, addr);
-		if (!pmd)
-			goto out;
+	VM_BUG_ON_PAGE(PageTail(page), page);
+	while (page_vma_mapped_walk(&pvmw)) {
+		new = page - pvmw.page->index +
+			linear_page_index(vma, pvmw.address);
 
-		ptep = pte_offset_map(pmd, addr);
+		get_page(new);
+		pte = pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
+		if (pte_swp_soft_dirty(*pvmw.pte))
+			pte = pte_mksoft_dirty(pte);
 
-		/*
-		 * Peek to check is_swap_pte() before taking ptlock?  No, we
-		 * can race mremap's move_ptes(), which skips anon_vma lock.
-		 */
-
-		ptl = pte_lockptr(mm, pmd);
-	}
-
- 	spin_lock(ptl);
-	pte = *ptep;
-	if (!is_swap_pte(pte))
-		goto unlock;
-
-	entry = pte_to_swp_entry(pte);
-
-	if (!is_migration_entry(entry) ||
-	    migration_entry_to_page(entry) != old)
-		goto unlock;
-
-	get_page(new);
-	pte = pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
-	if (pte_swp_soft_dirty(*ptep))
-		pte = pte_mksoft_dirty(pte);
-
-	/* Recheck VMA as permissions can change since migration started  */
-	if (is_write_migration_entry(entry))
-		pte = maybe_mkwrite(pte, vma);
+		/* Recheck VMA as permissions can change since migration started  */
+		entry = pte_to_swp_entry(*pvmw.pte);
+		if (is_write_migration_entry(entry))
+			pte = maybe_mkwrite(pte, vma);
 
 #ifdef CONFIG_HUGETLB_PAGE
-	if (PageHuge(new)) {
-		pte = pte_mkhuge(pte);
-		pte = arch_make_huge_pte(pte, vma, new, 0);
-	}
+		if (PageHuge(new)) {
+			pte = pte_mkhuge(pte);
+			pte = arch_make_huge_pte(pte, vma, new, 0);
+		}
 #endif
-	flush_dcache_page(new);
-	set_pte_at(mm, addr, ptep, pte);
+		flush_dcache_page(new);
+		set_pte_at(vma->vm_mm, pvmw.address, pvmw.pte, pte);
 
-	if (PageHuge(new)) {
-		if (PageAnon(new))
-			hugepage_add_anon_rmap(new, vma, addr);
+		if (PageHuge(new)) {
+			if (PageAnon(new))
+				hugepage_add_anon_rmap(new, vma, pvmw.address);
+			else
+				page_dup_rmap(new, true);
+		} else if (PageAnon(new))
+			page_add_anon_rmap(new, vma, pvmw.address, false);
 		else
-			page_dup_rmap(new, true);
-	} else if (PageAnon(new))
-		page_add_anon_rmap(new, vma, addr, false);
-	else
-		page_add_file_rmap(new, false);
+			page_add_file_rmap(new, false);
 
-	if (vma->vm_flags & VM_LOCKED && !PageTransCompound(new))
-		mlock_vma_page(new);
+		if (vma->vm_flags & VM_LOCKED && !PageTransCompound(new))
+			mlock_vma_page(new);
+
+		/* No need to invalidate - it was non-present before */
+		update_mmu_cache(vma, pvmw.address, pvmw.pte);
+	}
 
-	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, addr, ptep);
-unlock:
-	pte_unmap_unlock(ptep, ptl);
-out:
 	return SWAP_AGAIN;
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
