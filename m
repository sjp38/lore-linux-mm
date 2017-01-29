Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3FE6B0291
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 12:40:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d123so173301721pfd.0
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 09:40:13 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q9si4781097plk.87.2017.01.29.09.40.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 09:40:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 10/12] mm: convert page_mapped_in_vma() to use page_vma_mapped_walk()
Date: Sun, 29 Jan 2017 20:38:56 +0300
Message-Id: <20170129173858.45174-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
References: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For consistency, it worth converting all page_check_address() to
page_vma_mapped_walk(), so we could drop the former.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 mm/page_vma_mapped.c | 30 ++++++++++++++++++++++++++++++
 mm/rmap.c            | 26 --------------------------
 2 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index bbd2a39e985d..dc4756f878be 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -186,3 +186,33 @@ next_pte:	do {
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
index 11668fb881d8..80525820aada 100644
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
