Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A819E6B0292
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 12:17:15 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k126so32278563qke.8
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 09:17:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b67si3462842qkd.525.2017.08.09.09.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 09:17:14 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/rmap: try_to_unmap_one() do not call mmu_notifier under ptl
Date: Wed,  9 Aug 2017 12:17:09 -0400
Message-Id: <20170809161709.9278-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

MMU notifiers can sleep, but in try_to_unmap_one() we call
mmu_notifier_invalidate_page() under page table lock.

Let's instead use mmu_notifier_invalidate_range() outside
page_vma_mapped_walk() loop.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Fixes: c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use page_vma_mapped_walk()")
---
 mm/rmap.c | 36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index aff607d5f7d2..d60e887f1cda 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1329,7 +1329,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	};
 	pte_t pteval;
 	struct page *subpage;
-	bool ret = true;
+	bool ret = true, invalidation_needed = false;
+	unsigned long end = address + PAGE_SIZE;
 	enum ttu_flags flags = (enum ttu_flags)arg;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
@@ -1386,7 +1387,6 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		VM_BUG_ON_PAGE(!pvmw.pte, page);
 
 		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
-		address = pvmw.address;
 
 		if (IS_ENABLED(CONFIG_MIGRATION) &&
 		    (flags & TTU_MIGRATION) &&
@@ -1394,7 +1394,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_entry_t entry;
 			pte_t swp_pte;
 
-			pteval = ptep_get_and_clear(mm, address, pvmw.pte);
+			pteval = ptep_get_and_clear(mm, pvmw.address,
+						    pvmw.pte);
 
 			/*
 			 * Store the pfn of the page in a special migration
@@ -1405,12 +1406,12 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
-			set_pte_at(mm, address, pvmw.pte, swp_pte);
+			set_pte_at(mm, pvmw.address, pvmw.pte, swp_pte);
 			goto discard;
 		}
 
 		if (!(flags & TTU_IGNORE_ACCESS)) {
-			if (ptep_clear_flush_young_notify(vma, address,
+			if (ptep_clear_flush_young_notify(vma, pvmw.address,
 						pvmw.pte)) {
 				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
@@ -1419,7 +1420,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		}
 
 		/* Nuke the page table entry. */
-		flush_cache_page(vma, address, pte_pfn(*pvmw.pte));
+		flush_cache_page(vma, pvmw.address, pte_pfn(*pvmw.pte));
 		if (should_defer_flush(mm, flags)) {
 			/*
 			 * We clear the PTE but do not flush so potentially
@@ -1429,11 +1430,12 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			 * transition on a cached TLB entry is written through
 			 * and traps if the PTE is unmapped.
 			 */
-			pteval = ptep_get_and_clear(mm, address, pvmw.pte);
+			pteval = ptep_get_and_clear(mm, pvmw.address,
+						    pvmw.pte);
 
 			set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));
 		} else {
-			pteval = ptep_clear_flush(vma, address, pvmw.pte);
+			pteval = ptep_clear_flush(vma, pvmw.address, pvmw.pte);
 		}
 
 		/* Move the dirty bit to the page. Now the pte is gone. */
@@ -1448,12 +1450,12 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (PageHuge(page)) {
 				int nr = 1 << compound_order(page);
 				hugetlb_count_sub(nr, mm);
-				set_huge_swap_pte_at(mm, address,
+				set_huge_swap_pte_at(mm, pvmw.address,
 						     pvmw.pte, pteval,
 						     vma_mmu_pagesize(vma));
 			} else {
 				dec_mm_counter(mm, mm_counter(page));
-				set_pte_at(mm, address, pvmw.pte, pteval);
+				set_pte_at(mm, pvmw.address, pvmw.pte, pteval);
 			}
 
 		} else if (pte_unused(pteval)) {
@@ -1477,7 +1479,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
-			set_pte_at(mm, address, pvmw.pte, swp_pte);
+			set_pte_at(mm, pvmw.address, pvmw.pte, swp_pte);
 		} else if (PageAnon(page)) {
 			swp_entry_t entry = { .val = page_private(subpage) };
 			pte_t swp_pte;
@@ -1503,7 +1505,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				 * If the page was redirtied, it cannot be
 				 * discarded. Remap the page to page table.
 				 */
-				set_pte_at(mm, address, pvmw.pte, pteval);
+				set_pte_at(mm, pvmw.address, pvmw.pte, pteval);
 				SetPageSwapBacked(page);
 				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
@@ -1511,7 +1513,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			}
 
 			if (swap_duplicate(entry) < 0) {
-				set_pte_at(mm, address, pvmw.pte, pteval);
+				set_pte_at(mm, pvmw.address, pvmw.pte, pteval);
 				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
@@ -1527,14 +1529,18 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_pte = swp_entry_to_pte(entry);
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
-			set_pte_at(mm, address, pvmw.pte, swp_pte);
+			set_pte_at(mm, pvmw.address, pvmw.pte, swp_pte);
 		} else
 			dec_mm_counter(mm, mm_counter_file(page));
 discard:
 		page_remove_rmap(subpage, PageHuge(page));
 		put_page(page);
-		mmu_notifier_invalidate_page(mm, address);
+		end = pvmw.address + PAGE_SIZE;
+		invalidation_needed = true;
 	}
+
+	if (invalidation_needed)
+		mmu_notifier_invalidate_range(mm, address, end);
 	return ret;
 }
 
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
