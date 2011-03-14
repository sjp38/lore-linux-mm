Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D88D28D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:46:22 -0400 (EDT)
Received: by qyk2 with SMTP id 2so1828788qyk.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:46:21 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 17:46:21 +0000
Message-ID: <AANLkTin2c2wTpqBNF_ZjmeTex9m5+3h6vhH7=jD1JX0K@mail.gmail.com>
Subject: [RFC][PATCH v2 10/23] (mips) __vmalloc: add gfp flags variant of pte
 and pmd allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/mips/include/asm/pgalloc.h |   22 +++++++++++++++-------
1 files changed, 15 insertions(+), 7 deletions(-)
---
diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index 881d18b..f2c5439 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -64,14 +64,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
 	free_pages((unsigned long)pgd, PGD_ORDER);
 }

+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+	unsigned long address, gfp_t gfp_mask)
+{
+	return (pte_t *) __get_free_pages(gfp_mask | __GFP_ZERO, PTE_ORDER);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	unsigned long address)
 {
-	pte_t *pte;
-
-	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO,
PTE_ORDER);
-
-	return pte;
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline struct page *pte_alloc_one(struct mm_struct *mm,
@@ -106,16 +108,22 @@ do {							\

 #ifndef __PAGETABLE_PMD_FOLDED

-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
 {
 	pmd_t *pmd;

-	pmd = (pmd_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT, PMD_ORDER);
+	pmd = (pmd_t *) __get_free_pages(gfp_mask, PMD_ORDER);
 	if (pmd)
 		pmd_init((unsigned long)pmd, (unsigned long)invalid_pte_table);
 	return pmd;
 }

+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+	return __pmd_alloc_one(mm, address, GFP_KERNEL | __GFP_REPEAT);
+}
+
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_pages((unsigned long)pmd, PMD_ORDER);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
