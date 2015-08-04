Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3092D6B025D
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:33 -0400 (EDT)
Received: by pdco4 with SMTP id o4so8340881pdc.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x8si815737pde.111.2015.08.04.12.58.13
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:14 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 09/11] dax: Don't use set_huge_zero_page()
Date: Tue,  4 Aug 2015 15:58:03 -0400
Message-Id: <1438718285-21168-10-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, willy@linux.intel.com

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is another place where DAX assumed that pgtable_t was a pointer.
Open code the important parts of set_huge_zero_page() in DAX and make
set_huge_zero_page() static again.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/dax.c                | 18 ++++++++++++------
 include/linux/huge_mm.h |  3 ---
 mm/huge_memory.c        |  2 +-
 3 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 9daf005..bf9a22b 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -572,18 +572,24 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
 
 	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
-		bool set;
 		spinlock_t *ptl;
-		struct mm_struct *mm = vma->vm_mm;
+		pmd_t entry;
 		struct page *zero_page = get_huge_zero_page();
+
 		if (unlikely(!zero_page))
 			goto fallback;
 
-		ptl = pmd_lock(mm, pmd);
-		set = set_huge_zero_page(NULL, mm, vma, pmd_addr, pmd,
-								zero_page);
-		spin_unlock(ptl);
+		ptl = pmd_lock(vma->vm_mm, pmd);
+		if (!pmd_none(*pmd)) {
+			spin_unlock(ptl);
+			goto fallback;
+		}
+
+		entry = mk_pmd(zero_page, vma->vm_page_prot);
+		entry = pmd_mkhuge(entry);
+		set_pmd_at(vma->vm_mm, pmd_addr, pmd, entry);
 		result = VM_FAULT_NOPAGE;
+		spin_unlock(ptl);
 	} else {
 		sector = bh.b_blocknr << (blkbits - 9);
 		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index f9b612f..ecb080d 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -163,9 +163,6 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 }
 
 struct page *get_huge_zero_page(void);
-bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
-		struct vm_area_struct *vma, unsigned long haddr,
-		pmd_t *pmd, struct page *zero_page);
 
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b51bed1..63c8fe5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -767,7 +767,7 @@ static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
 }
 
 /* Caller must hold page table lock. */
-bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
+static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
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
