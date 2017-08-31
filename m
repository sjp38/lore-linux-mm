Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9CF86B02FD
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 17:17:51 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x29so2279512qtc.6
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 14:17:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m35si671736qtd.210.2017.08.31.14.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 14:17:50 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic v2
Date: Thu, 31 Aug 2017 17:17:27 -0400
Message-Id: <20170831211738.17922-3-jglisse@redhat.com>
In-Reply-To: <20170831211738.17922-1-jglisse@redhat.com>
References: <20170831211738.17922-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Replacing all mmu_notifier_invalidate_page() by mmu_notifier_invalidat_range()
and making sure it is bracketed by call to mmu_notifier_invalidate_range_start/
end.

Note that because we can not presume the pmd value or pte value we have to
assume the worse and unconditionaly report an invalidation as happening.

Changed since v2:
  - try_to_unmap_one() only one call to mmu_notifier_invalidate_range()
  - compute end with PAGE_SIZE << compound_order(page)
  - fix PageHuge() case in try_to_unmap_one()

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bernhard Held <berny156@gmx.de>
Cc: Adam Borowski <kilobyte@angband.pl>
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
 mm/rmap.c | 35 ++++++++++++++++++++++++++++++++---
 1 file changed, 32 insertions(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index c8993c63eb25..c570f82e6827 100644
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
+	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
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
+	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
+	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
+
 	while (page_vma_mapped_walk(&pvmw)) {
 		/*
 		 * If the page is mlock()d, we cannot swap it out.
@@ -1445,6 +1469,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
 				WARN_ON_ONCE(1);
 				ret = false;
+				/* We have to invalidate as we cleared the pte */
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1490,8 +1515,12 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 discard:
 		page_remove_rmap(subpage, PageHuge(page));
 		put_page(page);
-		mmu_notifier_invalidate_page(mm, address);
+		mmu_notifier_invalidate_range(mm, address,
+					      address + PAGE_SIZE);
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
