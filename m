Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 90BB26B0115
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 15:15:49 -0400 (EDT)
Received: by mail-oa0-f52.google.com with SMTP id j17so1818075oag.39
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 12:15:49 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id z1si2478823oby.6.2014.06.12.12.15.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 12:15:48 -0700 (PDT)
From: Waiman Long <Waiman.Long@hp.com>
Subject: [PATCH] mm: Move __vma_address() to internal.h to be inlined in huge_memory.c
Date: Thu, 12 Jun 2014 15:15:40 -0400
Message-Id: <1402600540-52031-1-git-send-email-Waiman.Long@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>, Waiman Long <Waiman.Long@hp.com>

The vma_address() function which is used to compute the virtual address
within a VMA is used only by 2 files in the mm subsystem - rmap.c and
huge_memory.c. This function is defined in rmap.c and is inlined by
its callers there, but it is also declared as an external function.

However, the __split_huge_page() function which calls vma_address()
in huge_memory.c is calling it as a real function call. This is not
as efficient as an inlined function. This patch moves the underlying
inlined __vma_address() function to internal.h to be shared by both
the rmap.c and huge_memory.c file.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 mm/huge_memory.c |    4 ++--
 mm/internal.h    |   19 +++++++++++++++----
 mm/rmap.c        |   14 --------------
 3 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b4b1feb..75a54ce 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1816,7 +1816,7 @@ static void __split_huge_page(struct page *page,
 	mapcount = 0;
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long addr = vma_address(page, vma);
+		unsigned long addr = __vma_address(page, vma);
 		BUG_ON(is_vma_temporary_stack(vma));
 		mapcount += __split_huge_page_splitting(page, vma, addr);
 	}
@@ -1840,7 +1840,7 @@ static void __split_huge_page(struct page *page,
 	mapcount2 = 0;
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long addr = vma_address(page, vma);
+		unsigned long addr = __vma_address(page, vma);
 		BUG_ON(is_vma_temporary_stack(vma));
 		mapcount2 += __split_huge_page_map(page, vma, addr);
 	}
diff --git a/mm/internal.h b/mm/internal.h
index 07b6736..3c9dbc2 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -13,6 +13,7 @@
 
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/hugetlb.h>
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
@@ -238,12 +239,22 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
 	}
 }
 
+/*
+ * __vma_address - at what user virtual address is page expected in @vma?
+ */
+static inline unsigned long
+__vma_address(struct page *page, struct vm_area_struct *vma)
+{
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		pgoff = page->index << huge_page_order(page_hstate(page));
+
+	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+}
+
 extern pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma);
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-extern unsigned long vma_address(struct page *page,
-				 struct vm_area_struct *vma);
-#endif
 #else /* !CONFIG_MMU */
 static inline int mlocked_vma_newpage(struct vm_area_struct *v, struct page *p)
 {
diff --git a/mm/rmap.c b/mm/rmap.c
index 83bfafa..5ab9a74 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -509,21 +509,7 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
 	anon_vma_unlock_read(anon_vma);
 }
 
-/*
- * At what user virtual address is page expected in @vma?
- */
 static inline unsigned long
-__vma_address(struct page *page, struct vm_area_struct *vma)
-{
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-
-	if (unlikely(is_vm_hugetlb_page(vma)))
-		pgoff = page->index << huge_page_order(page_hstate(page));
-
-	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
-}
-
-inline unsigned long
 vma_address(struct page *page, struct vm_area_struct *vma)
 {
 	unsigned long address = __vma_address(page, vma);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
