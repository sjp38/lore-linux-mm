Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C83E6B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 07:48:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g5-v6so2834955pgq.5
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 04:48:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d37-v6sor867290pla.28.2018.07.27.04.48.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 04:48:28 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH resend] powerpc/64s: fix page table fragment refcount race vs speculative references
Date: Fri, 27 Jul 2018 21:48:17 +1000
Message-Id: <20180727114817.27190-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Nicholas Piggin <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org

The page table fragment allocator uses the main page refcount racily
with respect to speculative references. A customer observed a BUG due
to page table page refcount underflow in the fragment allocator. This
can be caused by the fragment allocator set_page_count stomping on a
speculative reference, and then the speculative failure handler
decrements the new reference, and the underflow eventually pops when
the page tables are freed.

Fix this by using a dedicated field in the struct page for the page
table fragment allocator.

Fixes: 5c1f6ee9a31c ("powerpc: Reduce PTE table memory wastage")
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---

Any objection to the struct page change to grab the arch specific
page table page word for powerpc to use? If not, then this should
go via powerpc tree because it's inconsequential for core mm.

Thanks,
Nick

 arch/powerpc/mm/mmu_context_book3s64.c |  8 ++++----
 arch/powerpc/mm/pgtable-book3s64.c     | 17 +++++++++++------
 include/linux/mm_types.h               |  5 ++++-
 3 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_book3s64.c b/arch/powerpc/mm/mmu_context_book3s64.c
index f3d4b4a0e561..3bb5cec03d1f 100644
--- a/arch/powerpc/mm/mmu_context_book3s64.c
+++ b/arch/powerpc/mm/mmu_context_book3s64.c
@@ -200,9 +200,9 @@ static void pte_frag_destroy(void *pte_frag)
 	/* drop all the pending references */
 	count = ((unsigned long)pte_frag & ~PAGE_MASK) >> PTE_FRAG_SIZE_SHIFT;
 	/* We allow PTE_FRAG_NR fragments from a PTE page */
-	if (page_ref_sub_and_test(page, PTE_FRAG_NR - count)) {
+	if (atomic_sub_and_test(PTE_FRAG_NR - count, &page->pt_frag_refcount)) {
 		pgtable_page_dtor(page);
-		free_unref_page(page);
+		__free_page(page);
 	}
 }
 
@@ -215,9 +215,9 @@ static void pmd_frag_destroy(void *pmd_frag)
 	/* drop all the pending references */
 	count = ((unsigned long)pmd_frag & ~PAGE_MASK) >> PMD_FRAG_SIZE_SHIFT;
 	/* We allow PTE_FRAG_NR fragments from a PTE page */
-	if (page_ref_sub_and_test(page, PMD_FRAG_NR - count)) {
+	if (atomic_sub_and_test(PMD_FRAG_NR - count, &page->pt_frag_refcount)) {
 		pgtable_pmd_page_dtor(page);
-		free_unref_page(page);
+		__free_page(page);
 	}
 }
 
diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
index 4afbfbb64bfd..78d0b3d5ebad 100644
--- a/arch/powerpc/mm/pgtable-book3s64.c
+++ b/arch/powerpc/mm/pgtable-book3s64.c
@@ -270,6 +270,8 @@ static pmd_t *__alloc_for_pmdcache(struct mm_struct *mm)
 		return NULL;
 	}
 
+	atomic_set(&page->pt_frag_refcount, 1);
+
 	ret = page_address(page);
 	/*
 	 * if we support only one fragment just return the
@@ -285,7 +287,7 @@ static pmd_t *__alloc_for_pmdcache(struct mm_struct *mm)
 	 * count.
 	 */
 	if (likely(!mm->context.pmd_frag)) {
-		set_page_count(page, PMD_FRAG_NR);
+		atomic_set(&page->pt_frag_refcount, PMD_FRAG_NR);
 		mm->context.pmd_frag = ret + PMD_FRAG_SIZE;
 	}
 	spin_unlock(&mm->page_table_lock);
@@ -308,9 +310,10 @@ void pmd_fragment_free(unsigned long *pmd)
 {
 	struct page *page = virt_to_page(pmd);
 
-	if (put_page_testzero(page)) {
+	BUG_ON(atomic_read(&page->pt_frag_refcount) <= 0);
+	if (atomic_dec_and_test(&page->pt_frag_refcount)) {
 		pgtable_pmd_page_dtor(page);
-		free_unref_page(page);
+		__free_page(page);
 	}
 }
 
@@ -352,6 +355,7 @@ static pte_t *__alloc_for_ptecache(struct mm_struct *mm, int kernel)
 			return NULL;
 	}
 
+	atomic_set(&page->pt_frag_refcount, 1);
 
 	ret = page_address(page);
 	/*
@@ -367,7 +371,7 @@ static pte_t *__alloc_for_ptecache(struct mm_struct *mm, int kernel)
 	 * count.
 	 */
 	if (likely(!mm->context.pte_frag)) {
-		set_page_count(page, PTE_FRAG_NR);
+		atomic_set(&page->pt_frag_refcount, PTE_FRAG_NR);
 		mm->context.pte_frag = ret + PTE_FRAG_SIZE;
 	}
 	spin_unlock(&mm->page_table_lock);
@@ -390,10 +394,11 @@ void pte_fragment_free(unsigned long *table, int kernel)
 {
 	struct page *page = virt_to_page(table);
 
-	if (put_page_testzero(page)) {
+	BUG_ON(atomic_read(&page->pt_frag_refcount) <= 0);
+	if (atomic_dec_and_test(&page->pt_frag_refcount)) {
 		if (!kernel)
 			pgtable_page_dtor(page);
-		free_unref_page(page);
+		__free_page(page);
 	}
 }
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 99ce070e7dcb..22651e124071 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -139,7 +139,10 @@ struct page {
 			unsigned long _pt_pad_1;	/* compound_head */
 			pgtable_t pmd_huge_pte; /* protected by page->ptl */
 			unsigned long _pt_pad_2;	/* mapping */
-			struct mm_struct *pt_mm;	/* x86 pgds only */
+			union {
+				struct mm_struct *pt_mm; /* x86 pgds only */
+				atomic_t pt_frag_refcount; /* powerpc */
+			};
 #if ALLOC_SPLIT_PTLOCKS
 			spinlock_t *ptl;
 #else
-- 
2.17.0
