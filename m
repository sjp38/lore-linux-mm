Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 01D7C8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 14:02:50 -0400 (EDT)
Received: by qyk30 with SMTP id 30so5117732qyk.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:02:48 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 18:02:48 +0000
Message-ID: <AANLkTi=UH1n1YFBVQwTKUsaLPQXOci_7g-LZV3QtHU2s@mail.gmail.com>
Subject: [RFC][PATCH v2 18/23] (tile) __vmalloc: add gfp flags variant of pte
 and pmd allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>, Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/tile/include/asm/pgalloc.h |   13 ++++++++++++-
arch/tile/mm/pgtable.c          |   10 ++++++++--
2 files changed, 20 insertions(+), 3 deletions(-)
---
diff --git a/arch/tile/include/asm/pgalloc.h b/arch/tile/include/asm/pgalloc.h
index cf52791..2dcad88 100644
--- a/arch/tile/include/asm/pgalloc.h
+++ b/arch/tile/include/asm/pgalloc.h
@@ -69,14 +69,23 @@ extern pgd_t *pgd_alloc(struct mm_struct *mm);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);

 extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address);
+extern pgtable_t __pte_alloc_one(struct mm_struct *, unsigned long, gfp_t);
+
 extern void pte_free(struct mm_struct *mm, struct page *pte);

 #define pmd_pgtable(pmd) pmd_page(pmd)

 static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
+		gfp_t gfp_mask)
+{
+	return pfn_to_kaddr(page_to_pfn(__pte_alloc_one(mm, address, gfp_mask)));
+}
+
+static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return pfn_to_kaddr(page_to_pfn(pte_alloc_one(mm, address)));
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
@@ -108,6 +117,8 @@ void shatter_pmd(pmd_t *pmd);
 #define L1_USER_PGTABLE_ORDER L2_USER_PGTABLE_ORDER
 #define pud_populate(mm, pud, pmd) \
   pmd_populate_kernel((mm), (pmd_t *)(pud), (pte_t *)(pmd))
+#define __pmd_alloc_one(mm, addr, mask) \
+  ((pmd_t *)page_to_virt(__pte_alloc_one((mm), (addr), (mask))))
 #define pmd_alloc_one(mm, addr) \
   ((pmd_t *)page_to_virt(pte_alloc_one((mm), (addr))))
 #define pmd_free(mm, pmdp) \
diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 1f5430c..34ee920 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -218,9 +218,10 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)

 #define L2_USER_PGTABLE_PAGES (1 << L2_USER_PGTABLE_ORDER)

-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+struct page *
+__pte_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
 {
-	gfp_t flags = GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO|__GFP_COMP;
+	gfp_t flags = gfp_mask | __GFP_ZERO | __GFP_COMP;
 	struct page *p;

 #ifdef CONFIG_HIGHPTE
@@ -235,6 +236,11 @@ struct page *pte_alloc_one(struct mm_struct *mm,
unsigned long address)
 	return p;
 }

+struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+	return __pte_alloc_one(mm, address, GFP_KERNEL);
+}
+
 /*
  * Free page immediately (used in __pte_alloc if we raced with another
  * process).  We have to correct whatever pte_alloc_one() did before

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
