Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 890A68D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:02:52 -0500 (EST)
Received: by qwa26 with SMTP id 26so107033qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:02:49 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 21:02:49 +0000
Message-ID: <AANLkTi=8cUWzYZ6LRe=cZnp0k_6yqvComW6YErzPbwpw@mail.gmail.com>
Subject: [RFC][PATCH 19/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f6385fc..5ff89df 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1156,44 +1156,60 @@ static inline pte_t *get_locked_pte(struct
mm_struct *mm, unsigned long addr,

 #ifdef __PAGETABLE_PUD_FOLDED
 static inline int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
-                       unsigned long address)
+                       unsigned long address, gfp_t gfp_mask)
 {
    return 0;
 }
 #else
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address,
+       gfp_t gfp_mask);
 #endif

 #ifdef __PAGETABLE_PMD_FOLDED
 static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
-                       unsigned long address)
+                       unsigned long address, gfp_t gfp_mask)
 {
    return 0;
 }
 #else
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address,
+       gfp_t gfp_mask);
 #endif

 int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
        pmd_t *pmd, unsigned long address);
-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address, gfp_t gfp_mask);

 /*
  * The following ifdef needed to get the 4level-fixup.h header to work.
  * Remove it when 4level-fixup.h has been removed.
  */
 #if defined(CONFIG_MMU) && !defined(__ARCH_HAS_4LEVEL_HACK)
-static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd,
unsigned long address)
+static inline pud_t *pud_alloc_with_mask(struct mm_struct *mm, pgd_t *pgd,
+       unsigned long address, gfp_t gfp_mask)
 {
-   return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
+   return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address,
gfp_mask))?
        NULL: pud_offset(pgd, address);
 }

-static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud,
unsigned long address)
+static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd,
+       unsigned long address)
 {
-   return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
+   return pud_alloc_with_mask(mm, pgd, address, GFP_KERNEL);
+}
+
+static inline pmd_t *pmd_alloc_with_mask(struct mm_struct *mm, pud_t *pud,
+       unsigned long address, gfp_t gfp_mask)
+{
+   return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address,
gfp_mask))?
        NULL: pmd_offset(pud, address);
 }
+
+static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud,
+       unsigned long address)
+{
+   return pmd_alloc_with_mask(mm, pud, address, GFP_KERNEL);
+}
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */

 #if USE_SPLIT_PTLOCKS
@@ -1254,8 +1270,12 @@ static inline void pgtable_page_dtor(struct page *page)
                            pmd, address))? \
        NULL: pte_offset_map_lock(mm, pmd, address, ptlp))

+#define pte_alloc_kernel_with_mask(pmd, address, mask)         \
+   ((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address, mask))? \
+       NULL: pte_offset_kernel(pmd, address))
+
 #define pte_alloc_kernel(pmd, address)         \
-   ((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
+   ((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address,
GFP_KERNEL))? \
        NULL: pte_offset_kernel(pmd, address))

 extern void free_area_init(unsigned long * zones_size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
