Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8960B6B0299
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:29:23 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id y196so140137348ity.1
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:29:23 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u186si12181553itf.113.2017.01.24.08.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 08:29:17 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 08/12] mm, ksm: convert write_protect_page() to page_check_walk()
Date: Tue, 24 Jan 2017 19:28:20 +0300
Message-Id: <20170124162824.91275-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For consistency, it worth converting all page_check_address() to
page_check_walk(), so we could drop the former.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/ksm.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 9ae6011a41f8..6653ca186cfe 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -850,33 +850,35 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 			      pte_t *orig_pte)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long addr;
-	pte_t *ptep;
-	spinlock_t *ptl;
+	struct page_check_walk pcw = {
+		.page = page,
+		.vma = vma,
+	};
 	int swapped;
 	int err = -EFAULT;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
-	addr = page_address_in_vma(page, vma);
-	if (addr == -EFAULT)
+	pcw.address = page_address_in_vma(page, vma);
+	if (pcw.address == -EFAULT)
 		goto out;
 
 	BUG_ON(PageTransCompound(page));
 
-	mmun_start = addr;
-	mmun_end   = addr + PAGE_SIZE;
+	mmun_start = pcw.address;
+	mmun_end   = pcw.address + PAGE_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 
-	ptep = page_check_address(page, mm, addr, &ptl, 0);
-	if (!ptep)
+	if (!page_check_walk(&pcw))
 		goto out_mn;
+	if (WARN_ONCE(!pcw.pte, "Unexpected PMD mapping?"))
+		goto out_unlock;
 
-	if (pte_write(*ptep) || pte_dirty(*ptep)) {
+	if (pte_write(*pcw.pte) || pte_dirty(*pcw.pte)) {
 		pte_t entry;
 
 		swapped = PageSwapCache(page);
-		flush_cache_page(vma, addr, page_to_pfn(page));
+		flush_cache_page(vma, pcw.address, page_to_pfn(page));
 		/*
 		 * Ok this is tricky, when get_user_pages_fast() run it doesn't
 		 * take any lock, therefore the check that we are going to make
@@ -886,25 +888,25 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		 * this assure us that no O_DIRECT can happen after the check
 		 * or in the middle of the check.
 		 */
-		entry = ptep_clear_flush_notify(vma, addr, ptep);
+		entry = ptep_clear_flush_notify(vma, pcw.address, pcw.pte);
 		/*
 		 * Check that no O_DIRECT or similar I/O is in progress on the
 		 * page
 		 */
 		if (page_mapcount(page) + 1 + swapped != page_count(page)) {
-			set_pte_at(mm, addr, ptep, entry);
+			set_pte_at(mm, pcw.address, pcw.pte, entry);
 			goto out_unlock;
 		}
 		if (pte_dirty(entry))
 			set_page_dirty(page);
 		entry = pte_mkclean(pte_wrprotect(entry));
-		set_pte_at_notify(mm, addr, ptep, entry);
+		set_pte_at_notify(mm, pcw.address, pcw.pte, entry);
 	}
-	*orig_pte = *ptep;
+	*orig_pte = *pcw.pte;
 	err = 0;
 
 out_unlock:
-	pte_unmap_unlock(ptep, ptl);
+	page_check_walk_done(&pcw);
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
