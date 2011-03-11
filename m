Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B21BB8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:01:14 -0500 (EST)
Received: by qyk2 with SMTP id 2so6926893qyk.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:01:10 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 21:01:10 +0000
Message-ID: <AANLkTinD3QFWdVz-PL6PAJSdciFRbg4EjrNmXRsh9sXN@mail.gmail.com>
Subject: [RFC][PATCH 17/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/include/asm-generic/4level-fixup.h
b/include/asm-generic/4level-fixup.h
index 77ff547..f638309 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -10,10 +10,14 @@

 #define pud_t              pgd_t

-#define pmd_alloc(mm, pud, address) \
-   ((unlikely(pgd_none(*(pud))) && __pmd_alloc(mm, pud, address))? \
+#define pmd_alloc_with_mask(mm, pud, address, mask) \
+   ((unlikely(pgd_none(*(pud))) && __pmd_alloc(mm, pud, address, mask))? \
        NULL: pmd_offset(pud, address))

+#define pmd_alloc(mm, pud, address) \
+   pmd_alloc_with_mask(mm, pud, address, GFP_KERNEL)
+
+#define pud_alloc_with_mask(mm, pgd, address, mask)    (pgd)
 #define pud_alloc(mm, pgd, address)    (pgd)
 #define pud_offset(pgd, start)     (pgd)
 #define pud_none(pud)          0
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
-#define pmd_alloc_one(mm, address)     NULL
+#define __pmd_alloc_one(mm, address, mask)     NULL
+#define pmd_alloc_one(mm, address)             NULL
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
+#define __pud_alloc_one(mm, address, mask)     NULL
 #define pud_alloc_one(mm, address)     NULL
 #define pud_free(mm, x)                do { } while (0)
 #define __pud_free_tlb(tlb, x, a)      do { } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
