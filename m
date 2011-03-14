Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1588D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:44:05 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2001115qwa.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:44:04 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 17:44:04 +0000
Message-ID: <AANLkTinL2MHh0CtW_UKESmZPO5vnDXhHqcOrTPf9=-0W@mail.gmail.com>
Subject: [RFC][PATCH v2 09/23] (microblaze) __vmalloc: add gfp flags variant
 of pte and pmd allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Simek <monstr@monstr.eu>, microblaze-uclinux@itee.uq.edu.au, Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/microblaze/include/asm/pgalloc.h |    3 +++
arch/microblaze/mm/pgtable.c          |   13 +++++++++----
2 files changed, 12 insertions(+), 4 deletions(-)
---
diff --git a/arch/microblaze/include/asm/pgalloc.h
b/arch/microblaze/include/asm/pgalloc.h
index ebd3579..7df761f 100644
--- a/arch/microblaze/include/asm/pgalloc.h
+++ b/arch/microblaze/include/asm/pgalloc.h
@@ -106,9 +106,11 @@ extern inline void free_pgd_slow(pgd_t *pgd)
  * the pgd will always be present..
  */
 #define pmd_alloc_one_fast(mm, address)	({ BUG(); ((pmd_t *)1); })
+#define __pmd_alloc_one(mm, address,mask)	({ BUG(); ((pmd_t *)2); })
 #define pmd_alloc_one(mm, address)	({ BUG(); ((pmd_t *)2); })

 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
+extern pte_t *__pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);

 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 		unsigned long address)
@@ -175,6 +177,7 @@ extern inline void pte_free(struct mm_struct *mm,
struct page *ptepage)
  * We don't have any real pmd's, and this code never triggers because
  * the pgd will always be present..
  */
+#define __pmd_alloc_one(mm, address,mask)	({ BUG(); ((pmd_t *)2); })
 #define pmd_alloc_one(mm, address)	({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)			do { } while (0)
 #define __pmd_free_tlb(tlb, x, addr)	pmd_free((tlb)->mm, x)
diff --git a/arch/microblaze/mm/pgtable.c b/arch/microblaze/mm/pgtable.c
index 59bf233..ae4d315 100644
--- a/arch/microblaze/mm/pgtable.c
+++ b/arch/microblaze/mm/pgtable.c
@@ -240,13 +240,12 @@ unsigned long iopa(unsigned long addr)
 	return pa;
 }

-__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-		unsigned long address)
+__init_refok pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+		unsigned long address, gfp_t gfp_mask)
 {
 	pte_t *pte;
 	if (mem_init_done) {
-		pte = (pte_t *)__get_free_page(GFP_KERNEL |
-					__GFP_REPEAT | __GFP_ZERO);
+		pte = (pte_t *)__get_free_page(gfp_mask | __GFP_ZERO);
 	} else {
 		pte = (pte_t *)early_get_page();
 		if (pte)
@@ -254,3 +253,9 @@ __init_refok pte_t *pte_alloc_one_kernel(struct
mm_struct *mm,
 	}
 	return pte;
 }
+
+__init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+		unsigned long address)
+{
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
