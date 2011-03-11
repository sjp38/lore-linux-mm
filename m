Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBB68D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:06:14 -0500 (EST)
Received: by qyk2 with SMTP id 2so6930438qyk.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:06:01 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 21:06:01 +0000
Message-ID: <AANLkTikT0RA=BqeSLUfsoh_Uokzq5wB6GnBi0pRqxkYY@mail.gmail.com>
Subject: [RFC][PATCH 23/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/m32r/include/asm/pgalloc.h b/arch/m32r/include/asm/pgalloc.h
index 0fc7361..b49202a 100644
--- a/arch/m32r/include/asm/pgalloc.h
+++ b/arch/m32r/include/asm/pgalloc.h
@@ -30,12 +30,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
    free_page((unsigned long)pgd);
 }

+static __inline__ pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+   unsigned long address, gfp_t gfp_mask)
+{
+   return (pte_t *)__get_free_page(gfp_mask|__GFP_ZERO);
+}
+
 static __inline__ pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
    unsigned long address)
 {
-   pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
-
-   return pte;
+   return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static __inline__ pgtable_t pte_alloc_one(struct mm_struct *mm,
@@ -66,6 +70,7 @@ static inline void pte_free(struct mm_struct *mm,
pgtable_t pte)
  * (In the PAE case we free the pmds as part of the pgd.)
  */

+#define __pmd_alloc_one(mm, addr,mask)     ({ BUG(); ((pmd_t *)2); })
 #define pmd_alloc_one(mm, addr)        ({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)            do { } while (0)
 #define __pmd_free_tlb(tlb, x, addr)   do { } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
