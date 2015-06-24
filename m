Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1696B006C
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 06:25:09 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so26556206pab.1
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 03:25:08 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r11si39258938pdj.220.2015.06.24.03.25.07
        for <linux-mm@kvack.org>;
        Wed, 24 Jun 2015 03:25:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: make GUP handle pfn mapping unless FOLL_GET is requested
Date: Wed, 24 Jun 2015 13:25:03 +0300
Message-Id: <1435141503-100635-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>

With DAX, pfn mapping becoming more common. The patch adjusts GUP code
to cover pfn mapping for cases when we don't need struct page to
proceed.

To make it possible, let's change follow_page() code to return -EEXIST
error code if proper page table entry exists, but no corresponding
struct page. __get_user_page() would ignore the error code and move to
the next page frame.

The immediate effect of the change is working MAP_POPULATE and mlock()
on DAX mappings.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Toshi Kani <toshi.kani@hp.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
---
 mm/gup.c | 58 ++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 48 insertions(+), 10 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 222d57e335f9..03645f400748 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -33,6 +33,30 @@ static struct page *no_page_table(struct vm_area_struct *vma,
 	return NULL;
 }
 
+static int follow_pfn_pte(struct vm_area_struct *vma, unsigned long address,
+		pte_t *pte, unsigned int flags)
+{
+	/* No page to get reference */
+	if (flags & FOLL_GET)
+		return -EFAULT;
+
+	if (flags & FOLL_TOUCH) {
+		pte_t entry = *pte;
+
+		if (flags & FOLL_WRITE)
+			entry = pte_mkdirty(entry);
+		entry = pte_mkyoung(entry);
+
+		if (!pte_same(*pte, entry)) {
+			set_pte_at(vma->vm_mm, address, pte, entry);
+			update_mmu_cache(vma, address, pte);
+		}
+	}
+
+	/* Proper page table entry exists, but no corresponding struct page */
+	return -EEXIST;
+}
+
 static struct page *follow_page_pte(struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd, unsigned int flags)
 {
@@ -74,10 +98,21 @@ retry:
 
 	page = vm_normal_page(vma, address, pte);
 	if (unlikely(!page)) {
-		if ((flags & FOLL_DUMP) ||
-		    !is_zero_pfn(pte_pfn(pte)))
-			goto bad_page;
-		page = pte_page(pte);
+		if (flags & FOLL_DUMP) {
+			/* Avoid special (like zero) pages in core dumps */
+			page = ERR_PTR(-EFAULT);
+			goto out;
+		}
+
+		if (is_zero_pfn(pte_pfn(pte))) {
+			page = pte_page(pte);
+		} else {
+			int ret;
+
+			ret = follow_pfn_pte(vma, address, ptep, flags);
+			page = ERR_PTR(ret);
+			goto out;
+		}
 	}
 
 	if (flags & FOLL_GET)
@@ -115,12 +150,9 @@ retry:
 			unlock_page(page);
 		}
 	}
+out:
 	pte_unmap_unlock(ptep, ptl);
 	return page;
-bad_page:
-	pte_unmap_unlock(ptep, ptl);
-	return ERR_PTR(-EFAULT);
-
 no_page:
 	pte_unmap_unlock(ptep, ptl);
 	if (!pte_none(pte))
@@ -490,9 +522,15 @@ retry:
 				goto next_page;
 			}
 			BUG();
-		}
-		if (IS_ERR(page))
+		} else if (PTR_ERR(page) == -EEXIST) {
+			/*
+			 * Proper page table entry exists, but no corresponding
+			 * struct page.
+			 */
+			goto next_page;
+		} else if (IS_ERR(page)) {
 			return i ? i : PTR_ERR(page);
+		}
 		if (pages) {
 			pages[i] = page;
 			flush_anon_page(vma, page, start);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
