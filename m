Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D275B8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:54:09 -0500 (EST)
Received: by qwa26 with SMTP id 26so101177qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:54:07 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:54:07 +0000
Message-ID: <AANLkTin4qNz1_AYH0eaf0KHRWf0dh07JodfSGGRZrSnK@mail.gmail.com>
Subject: [RFC][PATCH 08/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Changes for s390 architecture.

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/arch/s390/include/asm/pgalloc.h b/arch/s390/include/asm/pgalloc.h
index 082eb4e..8335d05 100644
--- a/arch/s390/include/asm/pgalloc.h
+++ b/arch/s390/include/asm/pgalloc.h
@@ -62,9 +62,11 @@ static inline unsigned long pgd_entry_type(struct
mm_struct *mm)
    return _SEGMENT_ENTRY_EMPTY;
 }

+#define __pud_alloc_one(mm,address,mask)       ({ BUG(); ((pud_t *)2); })
 #define pud_alloc_one(mm,address)      ({ BUG(); ((pud_t *)2); })
 #define pud_free(mm, x)                do { } while (0)

+#define __pmd_alloc_one(mm,address,mask)       ({ BUG(); ((pmd_t *)2); })
 #define pmd_alloc_one(mm,address)      ({ BUG(); ((pmd_t *)2); })
 #define pmd_free(mm, x)                do { } while (0)

@@ -88,22 +90,34 @@ static inline unsigned long pgd_entry_type(struct
mm_struct *mm)
 int crst_table_upgrade(struct mm_struct *, unsigned long limit);
 void crst_table_downgrade(struct mm_struct *, unsigned long limit);

-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pud_t *
+__pud_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_mask)
 {
-   unsigned long *table = crst_table_alloc(mm, mm->context.noexec);
+   unsigned long *table = __crst_table_alloc(mm, mm->context.noexec, gfp_mask);
    if (table)
        crst_table_init(table, _REGION3_ENTRY_EMPTY);
    return (pud_t *) table;
 }
+
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+   return __pud_alloc_one(mm, address, GFP_KERNEL);
+}
 #define pud_free(mm, pud) crst_table_free(mm, (unsigned long *) pud)

-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long vmaddr)
+static inline pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long vmaddr, gfp_t gfp_mask)
 {
-   unsigned long *table = crst_table_alloc(mm, mm->context.noexec);
+   unsigned long *table = __crst_table_alloc(mm, mm->context.noexec, gfp_mask);
    if (table)
        crst_table_init(table, _SEGMENT_ENTRY_EMPTY);
    return (pmd_t *) table;
 }
+
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long vmaddr)
+{
+   return __pmd_alloc_one(mm, vmaddr, GFP_KERNEL);
+}
 #define pmd_free(mm, pmd) crst_table_free(mm, (unsigned long *) pmd)

 static inline void pgd_populate_kernel(struct mm_struct *mm,
@@ -172,7 +186,11 @@ static inline void pmd_populate(struct mm_struct *mm,
 /*
  * page table entry allocation/free routines.
  */
-#define pte_alloc_one_kernel(mm, vmaddr) ((pte_t *) page_table_alloc(mm))
+#define __pte_alloc_one_kernel(mm, vmaddr, mask) \
+   ((pte_t *) __page_table_alloc((mm), (mask)))
+#define pte_alloc_one_kernel(mm, vmaddr) \
+   ((pte_t *) __pte_alloc_one_kernel((mm), (vmaddr), GFP_KERNEL)
+
 #define pte_alloc_one(mm, vmaddr) ((pte_t *) page_table_alloc(mm))

 #define pte_free_kernel(mm, pte) page_table_free(mm, (unsigned long *) pte)
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index e1850c2..784c649 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -125,15 +125,16 @@ static int __init parse_vmalloc(char *arg)
 }
 early_param("vmalloc", parse_vmalloc);

-unsigned long *crst_table_alloc(struct mm_struct *mm, int noexec)
+unsigned long *
+__crst_table_alloc(struct mm_struct *mm, int noexec, gfp_t gfp_mask)
 {
-   struct page *page = alloc_pages(GFP_KERNEL, ALLOC_ORDER);
+   struct page *page = alloc_pages(gfp_mask, ALLOC_ORDER);

    if (!page)
        return NULL;
    page->index = 0;
    if (noexec) {
-       struct page *shadow = alloc_pages(GFP_KERNEL, ALLOC_ORDER);
+       struct page *shadow = alloc_pages(gfp_mask, ALLOC_ORDER);
        if (!shadow) {
            __free_pages(page, ALLOC_ORDER);
            return NULL;
@@ -146,6 +147,11 @@ unsigned long *crst_table_alloc(struct mm_struct
*mm, int noexec)
    return (unsigned long *) page_to_phys(page);
 }

+unsigned long *crst_table_alloc(struct mm_struct *mm, int noexec)
+{
+   return __crst_table_alloc(mm, noexec, GFP_KERNEL);
+}
+
 static void __crst_table_free(struct mm_struct *mm, unsigned long *table)
 {
    unsigned long *shadow = get_shadow_table(table);
@@ -267,7 +273,7 @@ void crst_table_downgrade(struct mm_struct *mm,
unsigned long limit)
 /*
  * page table entry allocation/free routines.
  */
-unsigned long *page_table_alloc(struct mm_struct *mm)
+unsigned long *__page_table_alloc(struct mm_struct *mm, gfp_t gfp_mask)
 {
    struct page *page;
    unsigned long *table;
@@ -284,7 +290,7 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
    }
    if (!page) {
        spin_unlock_bh(&mm->context.list_lock);
-       page = alloc_page(GFP_KERNEL|__GFP_REPEAT);
+       page = alloc_page(gfp_mask|__GFP_REPEAT);
        if (!page)
            return NULL;
        pgtable_page_ctor(page);
@@ -309,6 +315,12 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
    return table;
 }

+
+unsigned long *page_table_alloc(struct mm_struct *mm)
+{
+   return __page_table_alloc(mm, GFP_KERNEL);
+}
+
 static void __page_table_free(struct mm_struct *mm, unsigned long *table)
 {
    struct page *page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
