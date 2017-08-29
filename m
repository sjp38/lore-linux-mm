Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67B59280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:55:03 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x36so14758795qtx.9
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:55:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t82si4055286qke.145.2017.08.29.16.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 16:55:02 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Date: Tue, 29 Aug 2017 19:54:36 -0400
Message-Id: <20170829235447.10050-3-jglisse@redhat.com>
In-Reply-To: <20170829235447.10050-1-jglisse@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

Replacing all mmu_notifier_invalidate_page() by mmu_notifier_invalidat_range()
and making sure it is bracketed by call to mmu_notifier_invalidate_range_start/
end.

Note that because we can not presume the pmd value or pte value we have to
assume the worse and unconditionaly report an invalidation as happening.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bernhard Held <berny156@gmx.de>
Cc: Adam Borowski <kilobyte@angband.pl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: Wanpeng Li <kernellwp@gmail.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Mike Galbraith <efault@gmx.de>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: axie <axie@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/rmap.c | 44 +++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 41 insertions(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index c8993c63eb25..da97ed525088 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -887,11 +887,21 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		.address = address,
 		.flags = PVMW_SYNC,
 	};
+	unsigned long start = address, end;
 	int *cleaned = arg;
 
+	/*
+	 * We have to assume the worse case ie pmd for invalidation. Note that
+	 * the page can not be free from this function.
+	 */
+	end = min(vma->vm_end, (start & PMD_MASK) + PMD_SIZE);
+	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
+
 	while (page_vma_mapped_walk(&pvmw)) {
+		unsigned long cstart, cend;
 		int ret = 0;
-		address = pvmw.address;
+
+		cstart = address = pvmw.address;
 		if (pvmw.pte) {
 			pte_t entry;
 			pte_t *pte = pvmw.pte;
@@ -904,6 +914,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			entry = pte_wrprotect(entry);
 			entry = pte_mkclean(entry);
 			set_pte_at(vma->vm_mm, address, pte, entry);
+			cend = cstart + PAGE_SIZE;
 			ret = 1;
 		} else {
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
@@ -918,6 +929,8 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			entry = pmd_wrprotect(entry);
 			entry = pmd_mkclean(entry);
 			set_pmd_at(vma->vm_mm, address, pmd, entry);
+			cstart &= PMD_MASK;
+			cend = cstart + PMD_SIZE;
 			ret = 1;
 #else
 			/* unexpected pmd-mapped page? */
@@ -926,11 +939,13 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		}
 
 		if (ret) {
-			mmu_notifier_invalidate_page(vma->vm_mm, address);
+			mmu_notifier_invalidate_range(vma->vm_mm, cstart, cend);
 			(*cleaned)++;
 		}
 	}
 
+	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
+
 	return true;
 }
 
@@ -1324,6 +1339,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	pte_t pteval;
 	struct page *subpage;
 	bool ret = true;
+	unsigned long start = address, end;
 	enum ttu_flags flags = (enum ttu_flags)arg;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
@@ -1335,6 +1351,14 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				flags & TTU_MIGRATION, page);
 	}
 
+	/*
+	 * We have to assume the worse case ie pmd for invalidation. Note that
+	 * the page can not be free in this function as call of try_to_unmap()
+	 * must hold a reference on the page.
+	 */
+	end = min(vma->vm_end, (start & PMD_MASK) + PMD_SIZE);
+	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
+
 	while (page_vma_mapped_walk(&pvmw)) {
 		/*
 		 * If the page is mlock()d, we cannot swap it out.
@@ -1408,6 +1432,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				set_huge_swap_pte_at(mm, address,
 						     pvmw.pte, pteval,
 						     vma_mmu_pagesize(vma));
+				mmu_notifier_invalidate_range(mm, address,
+					address + vma_mmu_pagesize(vma));
 			} else {
 				dec_mm_counter(mm, mm_counter(page));
 				set_pte_at(mm, address, pvmw.pte, pteval);
@@ -1435,6 +1461,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
 			set_pte_at(mm, address, pvmw.pte, swp_pte);
+			mmu_notifier_invalidate_range(mm, address,
+						      address + PAGE_SIZE);
 		} else if (PageAnon(page)) {
 			swp_entry_t entry = { .val = page_private(subpage) };
 			pte_t swp_pte;
@@ -1445,6 +1473,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
 				WARN_ON_ONCE(1);
 				ret = false;
+				/* We have to invalidate as we cleared the pte */
+				mmu_notifier_invalidate_range(mm, address,
+							address + PAGE_SIZE);
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1453,6 +1484,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (!PageSwapBacked(page)) {
 				if (!PageDirty(page)) {
 					dec_mm_counter(mm, MM_ANONPAGES);
+					/* Invalidate as we cleared the pte */
+					mmu_notifier_invalidate_range(mm,
+						address, address + PAGE_SIZE);
 					goto discard;
 				}
 
@@ -1485,13 +1519,17 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (pte_soft_dirty(pteval))
 				swp_pte = pte_swp_mksoft_dirty(swp_pte);
 			set_pte_at(mm, address, pvmw.pte, swp_pte);
+			mmu_notifier_invalidate_range(mm, address,
+						      address + PAGE_SIZE);
 		} else
 			dec_mm_counter(mm, mm_counter_file(page));
 discard:
 		page_remove_rmap(subpage, PageHuge(page));
 		put_page(page);
-		mmu_notifier_invalidate_page(mm, address);
 	}
+
+	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
+
 	return ret;
 }
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
