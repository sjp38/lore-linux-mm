Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1233E8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:52:32 -0500 (EST)
Received: by qwa26 with SMTP id 26so100050qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:52:30 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:52:30 +0000
Message-ID: <AANLkTi=NzMBDBN0rPaX3_o2NWo_BmoWCxd7ybOaTRkNN@mail.gmail.com>
Subject: [RFC][PATCH 07/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Changes for ARM.

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
index 22de005..8cbb4f7 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -28,6 +28,7 @@
 /*
  * Since we have only two-level page tables, these are trivial
  */
+#define __pmd_alloc_one(mm,addr,mask)  ({ BUG(); ((pmd_t *)2); })
 #define pmd_alloc_one(mm,addr)     ({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, pmd)      do { } while (0)
 #define pgd_populate(mm,pmd,pte)   BUG()
@@ -59,17 +60,24 @@ static inline void clean_pte_table(pte_t *pte)
  *  +------------+
  */
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr,
gfp_t gfp_mask)
 {
    pte_t *pte;

-   pte = (pte_t *)__get_free_page(PGALLOC_GFP);
+   pte = (pte_t *)__get_free_page(gfp_mask | __GFP_NOTRACK |
+       __GFP_REPEAT | __GFP_ZERO);
    if (pte)
        clean_pte_table(pte);

    return pte;
 }

+static inline pte_t *
+pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+{
+   return __pte_alloc_one_kernel(mm, addr, GFP_KERNEL);
+}
+
 static inline pgtable_t
 pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
