Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA416B0296
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:29:04 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 204so243233889pge.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:29:04 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e185si14933177pgc.284.2017.01.24.08.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 08:29:03 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 10/12] mm: convert page_mapped_in_vma() to page_check_walk()
Date: Tue, 24 Jan 2017 19:28:22 +0300
Message-Id: <20170124162824.91275-11-kirill.shutemov@linux.intel.com>
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
 mm/page_check.c | 30 ++++++++++++++++++++++++++++++
 mm/rmap.c       | 26 --------------------------
 2 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/mm/page_check.c b/mm/page_check.c
index d4b3536a6bf2..5a544ca382a7 100644
--- a/mm/page_check.c
+++ b/mm/page_check.c
@@ -146,3 +146,33 @@ next_pte:	do {
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
+	struct page_check_walk pcw = {
+		.page = page,
+		.vma = vma,
+		.flags = PAGE_CHECK_WALK_SYNC,
+	};
+	unsigned long start, end;
+
+	start = __vma_address(page, vma);
+	end = start + PAGE_SIZE * (hpage_nr_pages(page) - 1);
+
+	if (unlikely(end < vma->vm_start || start >= vma->vm_end))
+		return 0;
+	pcw.address = max(start, vma->vm_start);
+	if (!page_check_walk(&pcw))
+		return 0;
+	page_check_walk_done(&pcw);
+	return 1;
+}
diff --git a/mm/rmap.c b/mm/rmap.c
index c9a096ffb242..cb34fd68a23a 100644
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
