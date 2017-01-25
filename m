Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BAE816B026E
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:27:04 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f144so279931294pfa.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:27:04 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id u132si24162689pgb.122.2017.01.25.10.27.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:27:03 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 10/12] mm: convert page_mapped_in_vma() to page_vma_mapped_walk()
Date: Wed, 25 Jan 2017 21:25:36 +0300
Message-Id: <20170125182538.86249-11-kirill.shutemov@linux.intel.com>
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
 mm/page_vma_mapped.c | 30 ++++++++++++++++++++++++++++++
 mm/rmap.c            | 26 --------------------------
 2 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index 63168b4baf19..13929f2418b0 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -179,3 +179,33 @@ next_pte:	do {
 		}
 	}
 }
+
+/**
+ * page_mapped_in_vma - check whether a page is really mapped in a VMA
+ * @page: the page to test
+ * @vma: the VMA to test
+ *
+ * Returns 1 if the page is mapped into the page tables of the VMA, 0
+ * if the page is not mapped into the page tables of this VMA.  Only
+ * valid for normal file or anonymous VMAs.
+ */
+int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
+{
+	struct page_vma_mapped_walk pvmw = {
+		.page = page,
+		.vma = vma,
+		.flags = PVMW_SYNC,
+	};
+	unsigned long start, end;
+
+	start = __vma_address(page, vma);
+	end = start + PAGE_SIZE * (hpage_nr_pages(page) - 1);
+
+	if (unlikely(end < vma->vm_start || start >= vma->vm_end))
+		return 0;
+	pvmw.address = max(start, vma->vm_start);
+	if (!page_vma_mapped_walk(&pvmw))
+		return 0;
+	page_vma_mapped_walk_done(&pvmw);
+	return 1;
+}
diff --git a/mm/rmap.c b/mm/rmap.c
index 95183dbea2eb..5d5e504c41d8 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -756,32 +756,6 @@ pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
 	return NULL;
 }
 
-/**
- * page_mapped_in_vma - check whether a page is really mapped in a VMA
- * @page: the page to test
- * @vma: the VMA to test
- *
- * Returns 1 if the page is mapped into the page tables of the VMA, 0
- * if the page is not mapped into the page tables of this VMA.  Only
- * valid for normal file or anonymous VMAs.
- */
-int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
-{
-	unsigned long address;
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	address = __vma_address(page, vma);
-	if (unlikely(address < vma->vm_start || address >= vma->vm_end))
-		return 0;
-	pte = page_check_address(page, vma->vm_mm, address, &ptl, 1);
-	if (!pte)			/* the page is not in this mm */
-		return 0;
-	pte_unmap_unlock(pte, ptl);
-
-	return 1;
-}
-
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /*
  * Check that @page is mapped at @address into @mm. In contrast to
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
