From: Prasad Joshi <prasadjoshi124@gmail.com>
Subject: [RFC][PATCH v2 07/23] (m32r) __vmalloc: add gfp flags variant of pte
 and pmd allocation
Date: Mon, 14 Mar 2011 17:39:54 +0000
Message-ID: <AANLkTi=N6mnsHr-Cci3SOxYf=aNvPD-aEfLkQpU5-6+z__1107.1645225913$1300124455$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PzBl4-0003gk-Jj
	for glkm-linux-mm-2@m.gmane.org; Mon, 14 Mar 2011 18:40:42 +0100
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8C37D8D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:40:40 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1996887qwa.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:39:55 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hirokazu Takata <takata@linux-m32r.org>, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>A

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/m32r/include/asm/pgalloc.h |   11 ++++++++---
1 files changed, 8 insertions(+), 3 deletions(-)
---
diff --git a/arch/m32r/include/asm/pgalloc.h b/arch/m32r/include/asm/pgalloc.h
index 0fc7361..0c1e4ae 100644
--- a/arch/m32r/include/asm/pgalloc.h
+++ b/arch/m32r/include/asm/pgalloc.h
@@ -30,12 +30,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
 	free_page((unsigned long)pgd);
 }

+static __inline__ pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+	unsigned long address, gfp_t gfp_mask)
+{
+	return (pte_t *)__get_free_page(gfp_mask | __GFP_ZERO);
+}
+
 static __inline__ pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	unsigned long address)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
-
-	return pte;
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL);
 }

 static __inline__ pgtable_t pte_alloc_one(struct mm_struct *mm,
@@ -66,6 +70,7 @@ static inline void pte_free(struct mm_struct *mm,
pgtable_t pte)
  * (In the PAE case we free the pmds as part of the pgd.)
  */

+#define __pmd_alloc_one(mm, addr,mask)		({ BUG(); ((pmd_t *)2); })
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb, x, addr)	do { } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
