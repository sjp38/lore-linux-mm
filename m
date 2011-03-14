Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 19CA58D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:58:05 -0400 (EDT)
Received: by qyk2 with SMTP id 2so1840598qyk.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:58:03 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 17:58:03 +0000
Message-ID: <AANLkTi=A=gho5k74oDHYdrWCJYqcn-wr7u0G9N3Eev5P@mail.gmail.com>
Subject: [RFC][PATCH v2 15/23] (score) __vmalloc: add gfp flags variant of
 pte, pmd, and pud allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Liqin <liqin.chen@sunplusct.com>, Lennox Wu <lennox.wu@gmail.com>, Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/score/include/asm/pgalloc.h |   13 +++++++------
1 files changed, 7 insertions(+), 6 deletions(-)
---
diff --git a/arch/score/include/asm/pgalloc.h b/arch/score/include/asm/pgalloc.h
index 059a61b..1a0a3a5 100644
--- a/arch/score/include/asm/pgalloc.h
+++ b/arch/score/include/asm/pgalloc.h
@@ -37,15 +37,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
 	free_pages((unsigned long)pgd, PGD_ORDER);
 }

+static inline pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
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
-					PTE_ORDER);
-
-	return pte;
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline struct page *pte_alloc_one(struct mm_struct *mm,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
