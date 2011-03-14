Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5EA8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:59:49 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2017264qwa.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:59:48 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 17:59:48 +0000
Message-ID: <AANLkTim9zfcfMkLhQeXE7TCdFGGF8Ypb_h=s4bxFMZ9E@mail.gmail.com>
Subject: [RFC][PATCH v2 16/23] (sh) __vmalloc: add gfp flags variant of pte
 and pmd allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org, Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/sh/include/asm/pgalloc.h |    8 +++++++-
arch/sh/mm/pgtable.c          |    8 +++++++-
2 files changed, 14 insertions(+), 2 deletions(-)
---
diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
index 8c00785..aaed989 100644
--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -31,10 +31,16 @@ static inline void pmd_populate(struct mm_struct
*mm, pmd_t *pmd,
 /*
  * Allocate and free page tables.
  */
+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address, gfp_t gfp_mask)
+{
+	return quicklist_alloc(QUICK_PT, gfp_mask, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/sh/mm/pgtable.c b/arch/sh/mm/pgtable.c
index 26e03a1..b938eb8 100644
--- a/arch/sh/mm/pgtable.c
+++ b/arch/sh/mm/pgtable.c
@@ -45,9 +45,15 @@ void pud_populate(struct mm_struct *mm, pud_t *pud,
pmd_t *pmd)
 	set_pud(pud, __pud((unsigned long)pmd));
 }

+pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
+{
+	return kmem_cache_alloc(pmd_cachep, gfp_mask | __GFP_ZERO);
+}
+
 pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	return kmem_cache_alloc(pmd_cachep, PGALLOC_GFP);
+	return __pmd_alloc_one(mm, address, GFP_KERNEL | __GFP_REPEAT);
 }

 void pmd_free(struct mm_struct *mm, pmd_t *pmd)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
