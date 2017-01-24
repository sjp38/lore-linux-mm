Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC0B96B0294
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:29:01 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 204so243232663pge.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:29:01 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p83si19804436pfi.65.2017.01.24.08.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 08:29:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 06/12] mm: convert page_mkclean_one() to page_check_walk()
Date: Tue, 24 Jan 2017 19:28:18 +0300
Message-Id: <20170124162824.91275-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For consistency, it worth converting all page_check_address() to
page_check_walk(), so we could drop the former.

PMD handling here is future-proofing, we don't have users yet. ext4 with
huge pages will be the first.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/rmap.c | 66 +++++++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 43 insertions(+), 23 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 3bbf83b32553..41874a6f6cf5 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1017,34 +1017,54 @@ int page_referenced(struct page *page,
 static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			    unsigned long address, void *arg)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	pte_t *pte;
-	spinlock_t *ptl;
-	int ret = 0;
+	struct page_check_walk pcw = {
+		.page = page,
+		.vma = vma,
+		.address = address,
+		.flags = PAGE_CHECK_WALK_SYNC,
+	};
 	int *cleaned = arg;
 
-	pte = page_check_address(page, mm, address, &ptl, 1);
-	if (!pte)
-		goto out;
-
-	if (pte_dirty(*pte) || pte_write(*pte)) {
-		pte_t entry;
+	while (page_check_walk(&pcw)) {
+		int ret = 0;
+		address = pcw.address;
+		if (pcw.pte) {
+			pte_t entry;
+			pte_t *pte = pcw.pte;
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
+		} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE)) {
+			pmd_t *pmd = pcw.pmd;
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
+		} else {
+			/* unexpected pmd-mapped page? */
+			WARN_ON_ONCE(1);
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
