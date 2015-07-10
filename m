Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A5E689003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:29:40 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so173157137pab.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:29:40 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id dx5si4577642pbc.22.2015.07.10.13.29.35
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 13:29:35 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 05/10] mm: Export various functions for the benefit of DAX
Date: Fri, 10 Jul 2015 16:29:20 -0400
Message-Id: <1436560165-8943-6-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

To use the huge zero page in DAX, we need these functions exported.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/huge_mm.h | 10 ++++++++++
 mm/huge_memory.c        |  9 ++-------
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 1c53c7d..70587ea 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -155,6 +155,16 @@ static inline bool is_huge_zero_page(struct page *page)
 	return ACCESS_ONCE(huge_zero_page) == page;
 }
 
+static inline bool is_huge_zero_pmd(pmd_t pmd)
+{
+	return is_huge_zero_page(pmd_page(pmd));
+}
+
+struct page *get_huge_zero_page(void);
+bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long haddr,
+		pmd_t *pmd, struct page *zero_page);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b7bd855..db3180f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -172,12 +172,7 @@ fail:
 static atomic_t huge_zero_refcount;
 struct page *huge_zero_page __read_mostly;
 
-static inline bool is_huge_zero_pmd(pmd_t pmd)
-{
-	return is_huge_zero_page(pmd_page(pmd));
-}
-
-static struct page *get_huge_zero_page(void)
+struct page *get_huge_zero_page(void)
 {
 	struct page *zero_page;
 retry:
@@ -772,7 +767,7 @@ static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
 }
 
 /* Caller must hold page table lock. */
-static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
+bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
 		struct page *zero_page)
 {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
