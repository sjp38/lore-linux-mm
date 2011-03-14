Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2855C8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 14:15:01 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2034468qwa.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:14:59 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 18:14:58 +0000
Message-ID: <AANLkTik=m5dCx_9bmnXfXJ9LPMwoS8Bc3CUoT7OAB5gY@mail.gmail.com>
Subject: [RFC][PATCH v2 22/23] (asm-generic) __vmalloc: add gfp flags variant
 of pte, pmd, and pud allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
include/asm-generic/4level-fixup.h  |    8 ++++++--
include/asm-generic/pgtable-nopmd.h |    3 ++-
include/asm-generic/pgtable-nopud.h |    1 +
3 files changed, 9 insertions(+), 3 deletions(-)
---
diff --git a/include/asm-generic/4level-fixup.h
b/include/asm-generic/4level-fixup.h
index 77ff547..f638309 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -10,10 +10,14 @@

 #define pud_t				pgd_t

-#define pmd_alloc(mm, pud, address) \
-	((unlikely(pgd_none(*(pud))) && __pmd_alloc(mm, pud, address))? \
+#define pmd_alloc_with_mask(mm, pud, address, mask) \
+	((unlikely(pgd_none(*(pud))) && __pmd_alloc(mm, pud, address, mask))? \
  		NULL: pmd_offset(pud, address))

+#define pmd_alloc(mm, pud, address) \
+	pmd_alloc_with_mask(mm, pud, address, GFP_KERNEL)
+
+#define pud_alloc_with_mask(mm, pgd, address, mask)	(pgd)
 #define pud_alloc(mm, pgd, address)	(pgd)
 #define pud_offset(pgd, start)		(pgd)
 #define pud_none(pud)			0
diff --git a/include/asm-generic/pgtable-nopmd.h
b/include/asm-generic/pgtable-nopmd.h
index 725612b..96ca8da 100644
--- a/include/asm-generic/pgtable-nopmd.h
+++ b/include/asm-generic/pgtable-nopmd.h
@@ -55,7 +55,8 @@ static inline pmd_t * pmd_offset(pud_t * pud,
unsigned long address)
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
  * inside the pud, so has no extra memory associated with it.
  */
-#define pmd_alloc_one(mm, address)		NULL
+#define __pmd_alloc_one(mm, address, mask)		NULL
+#define pmd_alloc_one(mm, address)				NULL
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 }
diff --git a/include/asm-generic/pgtable-nopud.h
b/include/asm-generic/pgtable-nopud.h
index 810431d..5a21868 100644
--- a/include/asm-generic/pgtable-nopud.h
+++ b/include/asm-generic/pgtable-nopud.h
@@ -50,6 +50,7 @@ static inline pud_t * pud_offset(pgd_t * pgd,
unsigned long address)
  * allocating and freeing a pud is trivial: the 1-entry pud is
  * inside the pgd, so has no extra memory associated with it.
  */
+#define __pud_alloc_one(mm, address, mask)		NULL
 #define pud_alloc_one(mm, address)		NULL
 #define pud_free(mm, x)				do { } while (0)
 #define __pud_free_tlb(tlb, x, a)		do { } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
