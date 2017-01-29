Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAE6F6B028C
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 12:39:41 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so426864172pfx.1
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 09:39:41 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v3si10192700plk.296.2017.01.29.09.39.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 09:39:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 07/12] mm: convert try_to_unmap_one() to use page_vma_mapped_walk()
Date: Sun, 29 Jan 2017 20:38:53 +0300
Message-Id: <20170129173858.45174-8-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
References: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For consistency, it worth converting all page_check_address() to
page_vma_mapped_walk(), so we could drop the former.

It also makes freeze_page() as we walk though rmap only once.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |  16 +---
 mm/rmap.c        | 260 ++++++++++++++++++++++++++++---------------------------
 2 files changed, 137 insertions(+), 139 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 16820e001d79..ca7855f857fa 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1839,24 +1839,16 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 static void freeze_page(struct page *page)
 {
 	enum ttu_flags ttu_flags = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS |
-		TTU_RMAP_LOCKED;
-	int i, ret;
+		TTU_RMAP_LOCKED | TTU_SPLIT_HUGE_PMD;
+	int ret;
 
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
 	if (PageAnon(page))
 		ttu_flags |= TTU_MIGRATION;
 
-	/* We only need TTU_SPLIT_HUGE_PMD once */
-	ret = try_to_unmap(page, ttu_flags | TTU_SPLIT_HUGE_PMD);
-	for (i = 1; !ret && i < HPAGE_PMD_NR; i++) {
-		/* Cut short if the page is unmapped */
-		if (page_count(page) == 1)
-			return;
-
-		ret = try_to_unmap(page + i, ttu_flags);
-	}
-	VM_BUG_ON_PAGE(ret, page + i - 1);
+	ret = try_to_unmap(page, ttu_flags);
+	VM_BUG_ON_PAGE(ret, page);
 }
 
 static void unfreeze_page(struct page *page)
diff --git a/mm/rmap.c b/mm/rmap.c
index 58597de049fd..11668fb881d8 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -607,8 +607,7 @@ void try_to_unmap_flush_dirty(void)
 		try_to_unmap_flush();
 }
 
-static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
-		struct page *page, bool writable)
+static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
 {
 	struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
 
@@ -643,8 +642,7 @@ static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
 	return should_defer;
 }
 #else
-static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
-		struct page *page, bool writable)
+static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
 {
 }
 
@@ -1459,155 +1457,163 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		     unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	pte_t *pte;
+	struct page_vma_mapped_walk pvmw = {
+		.page = page,
+		.vma = vma,
+		.address = address,
+	};
 	pte_t pteval;
-	spinlock_t *ptl;
+	struct page *subpage;
 	int ret = SWAP_AGAIN;
 	struct rmap_private *rp = arg;
 	enum ttu_flags flags = rp->flags;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
-		goto out;
+		return SWAP_AGAIN;
 
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
 				flags & TTU_MIGRATION, page);
-		/* check if we have anything to do after split */
-		if (page_mapcount(page) == 0)
-			goto out;
 	}
 
-	pte = page_check_address(page, mm, address, &ptl,
-				 PageTransCompound(page));
-	if (!pte)
-		goto out;
+	while (page_vma_mapped_walk(&pvmw)) {
+		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
+		address = pvmw.address;
 
-	/*
-	 * If the page is mlock()d, we cannot swap it out.
-	 * If it's recently referenced (perhaps page_referenced
-	 * skipped over this mm) then we should reactivate it.
-	 */
-	if (!(flags & TTU_IGNORE_MLOCK)) {
-		if (vma->vm_flags & VM_LOCKED) {
-			/* PTE-mapped THP are never mlocked */
-			if (!PageTransCompound(page)) {
-				/*
-				 * Holding pte lock, we do *not* need
-				 * mmap_sem here
-				 */
-				mlock_vma_page(page);
+		/* Unexpected PMD-mapped THP? */
+		VM_BUG_ON_PAGE(!pvmw.pte, page);
+
+		/*
+		 * If the page is mlock()d, we cannot swap it out.
+		 * If it's recently referenced (perhaps page_referenced
+		 * skipped over this mm) then we should reactivate it.
+		 */
+		if (!(flags & TTU_IGNORE_MLOCK)) {
+			if (vma->vm_flags & VM_LOCKED) {
+				/* PTE-mapped THP are never mlocked */
+				if (!PageTransCompound(page)) {
+					/*
+					 * Holding pte lock, we do *not* need
+					 * mmap_sem here
+					 */
+					mlock_vma_page(page);
+				}
+				ret = SWAP_MLOCK;
+				page_vma_mapped_walk_done(&pvmw);
+				break;
 			}
-			ret = SWAP_MLOCK;
-			goto out_unmap;
+			if (flags & TTU_MUNLOCK)
+				continue;
 		}
-		if (flags & TTU_MUNLOCK)
-			goto out_unmap;
-	}
-	if (!(flags & TTU_IGNORE_ACCESS)) {
-		if (ptep_clear_flush_young_notify(vma, address, pte)) {
-			ret = SWAP_FAIL;
-			goto out_unmap;
+
+		if (!(flags & TTU_IGNORE_ACCESS)) {
+			if (ptep_clear_flush_young_notify(vma, address,
+						pvmw.pte)) {
+				ret = SWAP_FAIL;
+				page_vma_mapped_walk_done(&pvmw);
+				break;
+			}
 		}
-  	}
 
-	/* Nuke the page table entry. */
-	flush_cache_page(vma, address, page_to_pfn(page));
-	if (should_defer_flush(mm, flags)) {
-		/*
-		 * We clear the PTE but do not flush so potentially a remote
-		 * CPU could still be writing to the page. If the entry was
-		 * previously clean then the architecture must guarantee that
-		 * a clear->dirty transition on a cached TLB entry is written
-		 * through and traps if the PTE is unmapped.
-		 */
-		pteval = ptep_get_and_clear(mm, address, pte);
+		/* Nuke the page table entry. */
+		flush_cache_page(vma, address, pte_pfn(*pvmw.pte));
+		if (should_defer_flush(mm, flags)) {
+			/*
+			 * We clear the PTE but do not flush so potentially
+			 * a remote CPU could still be writing to the page.
+			 * If the entry was previously clean then the
+			 * architecture must guarantee that a clear->dirty
+			 * transition on a cached TLB entry is written through
+			 * and traps if the PTE is unmapped.
+			 */
+			pteval = ptep_get_and_clear(mm, address, pvmw.pte);
+
+			set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));
+		} else {
+			pteval = ptep_clear_flush(vma, address, pvmw.pte);
+		}
 
-		set_tlb_ubc_flush_pending(mm, page, pte_dirty(pteval));
-	} else {
-		pteval = ptep_clear_flush(vma, address, pte);
-	}
+		/* Move the dirty bit to the page. Now the pte is gone. */
+		if (pte_dirty(pteval))
+			set_page_dirty(page);
 
-	/* Move the dirty bit to the physical page now the pte is gone. */
-	if (pte_dirty(pteval))
-		set_page_dirty(page);
+		/* Update high watermark before we lower rss */
+		update_hiwater_rss(mm);
 
-	/* Update high watermark before we lower rss */
-	update_hiwater_rss(mm);
+		if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
+			if (PageHuge(page)) {
+				int nr = 1 << compound_order(page);
+				hugetlb_count_sub(nr, mm);
+			} else {
+				dec_mm_counter(mm, mm_counter(page));
+			}
 
-	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
-		if (PageHuge(page)) {
-			hugetlb_count_sub(1 << compound_order(page), mm);
-		} else {
+			pteval = swp_entry_to_pte(make_hwpoison_entry(subpage));
+			set_pte_at(mm, address, pvmw.pte, pteval);
+		} else if (pte_unused(pteval)) {
+			/*
+			 * The guest indicated that the page content is of no
+			 * interest anymore. Simply discard the pte, vmscan
+			 * will take care of the rest.
+			 */
 			dec_mm_counter(mm, mm_counter(page));
-		}
-		set_pte_at(mm, address, pte,
-			   swp_entry_to_pte(make_hwpoison_entry(page)));
-	} else if (pte_unused(pteval)) {
-		/*
-		 * The guest indicated that the page content is of no
-		 * interest anymore. Simply discard the pte, vmscan
-		 * will take care of the rest.
-		 */
-		dec_mm_counter(mm, mm_counter(page));
-	} else if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION)) {
-		swp_entry_t entry;
-		pte_t swp_pte;
-		/*
-		 * Store the pfn of the page in a special migration
-		 * pte. do_swap_page() will wait until the migration
-		 * pte is removed and then restart fault handling.
-		 */
-		entry = make_migration_entry(page, pte_write(pteval));
-		swp_pte = swp_entry_to_pte(entry);
-		if (pte_soft_dirty(pteval))
-			swp_pte = pte_swp_mksoft_dirty(swp_pte);
-		set_pte_at(mm, address, pte, swp_pte);
-	} else if (PageAnon(page)) {
-		swp_entry_t entry = { .val = page_private(page) };
-		pte_t swp_pte;
-		/*
-		 * Store the swap location in the pte.
-		 * See handle_pte_fault() ...
-		 */
-		VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+		} else if (IS_ENABLED(CONFIG_MIGRATION) &&
+				(flags & TTU_MIGRATION)) {
+			swp_entry_t entry;
+			pte_t swp_pte;
+			/*
+			 * Store the pfn of the page in a special migration
+			 * pte. do_swap_page() will wait until the migration
+			 * pte is removed and then restart fault handling.
+			 */
+			entry = make_migration_entry(subpage,
+					pte_write(pteval));
+			swp_pte = swp_entry_to_pte(entry);
+			if (pte_soft_dirty(pteval))
+				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			set_pte_at(mm, address, pvmw.pte, swp_pte);
+		} else if (PageAnon(page)) {
+			swp_entry_t entry = { .val = page_private(subpage) };
+			pte_t swp_pte;
+			/*
+			 * Store the swap location in the pte.
+			 * See handle_pte_fault() ...
+			 */
+			VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+
+			if (!PageDirty(page) && (flags & TTU_LZFREE)) {
+				/* It's a freeable page by MADV_FREE */
+				dec_mm_counter(mm, MM_ANONPAGES);
+				rp->lazyfreed++;
+				goto discard;
+			}
 
-		if (!PageDirty(page) && (flags & TTU_LZFREE)) {
-			/* It's a freeable page by MADV_FREE */
+			if (swap_duplicate(entry) < 0) {
+				set_pte_at(mm, address, pvmw.pte, pteval);
+				ret = SWAP_FAIL;
+				page_vma_mapped_walk_done(&pvmw);
+				break;
+			}
+			if (list_empty(&mm->mmlist)) {
+				spin_lock(&mmlist_lock);
+				if (list_empty(&mm->mmlist))
+					list_add(&mm->mmlist, &init_mm.mmlist);
+				spin_unlock(&mmlist_lock);
+			}
 			dec_mm_counter(mm, MM_ANONPAGES);
-			rp->lazyfreed++;
-			goto discard;
-		}
-
-		if (swap_duplicate(entry) < 0) {
-			set_pte_at(mm, address, pte, pteval);
-			ret = SWAP_FAIL;
-			goto out_unmap;
-		}
-		if (list_empty(&mm->mmlist)) {
-			spin_lock(&mmlist_lock);
-			if (list_empty(&mm->mmlist))
-				list_add(&mm->mmlist, &init_mm.mmlist);
-			spin_unlock(&mmlist_lock);
-		}
-		dec_mm_counter(mm, MM_ANONPAGES);
-		inc_mm_counter(mm, MM_SWAPENTS);
-		swp_pte = swp_entry_to_pte(entry);
-		if (pte_soft_dirty(pteval))
-			swp_pte = pte_swp_mksoft_dirty(swp_pte);
-		set_pte_at(mm, address, pte, swp_pte);
-	} else
-		dec_mm_counter(mm, mm_counter_file(page));
-
+			inc_mm_counter(mm, MM_SWAPENTS);
+			swp_pte = swp_entry_to_pte(entry);
+			if (pte_soft_dirty(pteval))
+				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			set_pte_at(mm, address, pvmw.pte, swp_pte);
+		} else
+			dec_mm_counter(mm, mm_counter_file(page));
 discard:
-	page_remove_rmap(page, PageHuge(page));
-	put_page(page);
-
-out_unmap:
-	pte_unmap_unlock(pte, ptl);
-	if (ret != SWAP_FAIL && ret != SWAP_MLOCK && !(flags & TTU_MUNLOCK))
+		page_remove_rmap(subpage, PageHuge(page));
+		put_page(page);
 		mmu_notifier_invalidate_page(mm, address);
-out:
+	}
 	return ret;
 }
 
@@ -1632,7 +1638,7 @@ static bool invalid_migration_vma(struct vm_area_struct *vma, void *arg)
 
 static int page_mapcount_is_zero(struct page *page)
 {
-	return !page_mapcount(page);
+	return !total_mapcount(page);
 }
 
 /**
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
