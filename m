Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED366B0270
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:27:07 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e4so152094820pfg.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:27:07 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u2si2337379plm.263.2017.01.25.10.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:27:06 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 08/12] mm, ksm: convert write_protect_page() to page_vma_mapped_walk()
Date: Wed, 25 Jan 2017 21:25:34 +0300
Message-Id: <20170125182538.86249-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For consistency, it worth converting all page_check_address() to
page_vma_mapped_walk(), so we could drop the former.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/ksm.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 9ae6011a41f8..91a2eb048516 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -850,33 +850,35 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 			      pte_t *orig_pte)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long addr;
-	pte_t *ptep;
-	spinlock_t *ptl;
+	struct page_vma_mapped_walk pvmw = {
+		.page = page,
+		.vma = vma,
+	};
 	int swapped;
 	int err = -EFAULT;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
-	addr = page_address_in_vma(page, vma);
-	if (addr == -EFAULT)
+	pvmw.address = page_address_in_vma(page, vma);
+	if (pvmw.address == -EFAULT)
 		goto out;
 
 	BUG_ON(PageTransCompound(page));
 
-	mmun_start = addr;
-	mmun_end   = addr + PAGE_SIZE;
+	mmun_start = pvmw.address;
+	mmun_end   = pvmw.address + PAGE_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 
-	ptep = page_check_address(page, mm, addr, &ptl, 0);
-	if (!ptep)
+	if (!page_vma_mapped_walk(&pvmw))
 		goto out_mn;
+	if (WARN_ONCE(!pvmw.pte, "Unexpected PMD mapping?"))
+		goto out_unlock;
 
-	if (pte_write(*ptep) || pte_dirty(*ptep)) {
+	if (pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte)) {
 		pte_t entry;
 
 		swapped = PageSwapCache(page);
-		flush_cache_page(vma, addr, page_to_pfn(page));
+		flush_cache_page(vma, pvmw.address, page_to_pfn(page));
 		/*
 		 * Ok this is tricky, when get_user_pages_fast() run it doesn't
 		 * take any lock, therefore the check that we are going to make
@@ -886,25 +888,25 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		 * this assure us that no O_DIRECT can happen after the check
 		 * or in the middle of the check.
 		 */
-		entry = ptep_clear_flush_notify(vma, addr, ptep);
+		entry = ptep_clear_flush_notify(vma, pvmw.address, pvmw.pte);
 		/*
 		 * Check that no O_DIRECT or similar I/O is in progress on the
 		 * page
 		 */
 		if (page_mapcount(page) + 1 + swapped != page_count(page)) {
-			set_pte_at(mm, addr, ptep, entry);
+			set_pte_at(mm, pvmw.address, pvmw.pte, entry);
 			goto out_unlock;
 		}
 		if (pte_dirty(entry))
 			set_page_dirty(page);
 		entry = pte_mkclean(pte_wrprotect(entry));
-		set_pte_at_notify(mm, addr, ptep, entry);
+		set_pte_at_notify(mm, pvmw.address, pvmw.pte, entry);
 	}
-	*orig_pte = *ptep;
+	*orig_pte = *pvmw.pte;
 	err = 0;
 
 out_unlock:
-	pte_unmap_unlock(ptep, ptl);
+	page_vma_mapped_walk_done(&pvmw);
 out_mn:
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 out:
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
