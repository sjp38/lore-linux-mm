Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC8BF6B027D
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 12:39:10 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so426853416pfx.1
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 09:39:10 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l127si6570940pga.348.2017.01.29.09.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 09:39:09 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 06/12] mm: convert page_mkclean_one() to use page_vma_mapped_walk()
Date: Sun, 29 Jan 2017 20:38:52 +0300
Message-Id: <20170129173858.45174-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
References: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For consistency, it worth converting all page_check_address() to
page_vma_mapped_walk(), so we could drop the former.

PMD handling here is future-proofing, we don't have users yet. ext4 with
huge pages will be the first.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/rmap.c | 68 ++++++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 45 insertions(+), 23 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index c4bad599cc7b..58597de049fd 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1017,34 +1017,56 @@ int page_referenced(struct page *page,
 static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			    unsigned long address, void *arg)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	pte_t *pte;
-	spinlock_t *ptl;
-	int ret = 0;
+	struct page_vma_mapped_walk pvmw = {
+		.page = page,
+		.vma = vma,
+		.address = address,
+		.flags = PVMW_SYNC,
+	};
 	int *cleaned = arg;
 
-	pte = page_check_address(page, mm, address, &ptl, 1);
-	if (!pte)
-		goto out;
-
-	if (pte_dirty(*pte) || pte_write(*pte)) {
-		pte_t entry;
+	while (page_vma_mapped_walk(&pvmw)) {
+		int ret = 0;
+		address = pvmw.address;
+		if (pvmw.pte) {
+			pte_t entry;
+			pte_t *pte = pvmw.pte;
+
+			if (!pte_dirty(*pte) && !pte_write(*pte))
+				continue;
+
+			flush_cache_page(vma, address, pte_pfn(*pte));
+			entry = ptep_clear_flush(vma, address, pte);
+			entry = pte_wrprotect(entry);
+			entry = pte_mkclean(entry);
+			set_pte_at(vma->vm_mm, address, pte, entry);
+			ret = 1;
+		} else {
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
+			pmd_t *pmd = pvmw.pmd;
+			pmd_t entry;
+
+			if (!pmd_dirty(*pmd) && !pmd_write(*pmd))
+				continue;
+
+			flush_cache_page(vma, address, page_to_pfn(page));
+			entry = pmdp_huge_clear_flush(vma, address, pmd);
+			entry = pmd_wrprotect(entry);
+			entry = pmd_mkclean(entry);
+			set_pmd_at(vma->vm_mm, address, pmd, entry);
+			ret = 1;
+#else
+			/* unexpected pmd-mapped page? */
+			WARN_ON_ONCE(1);
+#endif
+		}
 
-		flush_cache_page(vma, address, pte_pfn(*pte));
-		entry = ptep_clear_flush(vma, address, pte);
-		entry = pte_wrprotect(entry);
-		entry = pte_mkclean(entry);
-		set_pte_at(mm, address, pte, entry);
-		ret = 1;
+		if (ret) {
+			mmu_notifier_invalidate_page(vma->vm_mm, address);
+			(*cleaned)++;
+		}
 	}
 
-	pte_unmap_unlock(pte, ptl);
-
-	if (ret) {
-		mmu_notifier_invalidate_page(mm, address);
-		(*cleaned)++;
-	}
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
