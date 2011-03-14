Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CAC338D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 14:04:27 -0400 (EDT)
Received: by qyk30 with SMTP id 30so5119459qyk.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:04:25 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 18:04:25 +0000
Message-ID: <AANLkTinAp6FyP9Ln7HJOY0wZEZyW4yvfjgdOJK1uNzu_@mail.gmail.com>
Subject: [RFC][PATCH v2 19/23] (x86) __vmalloc: add gfp flags variant of pte,
 pmd, and pud allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/x86/include/asm/pgalloc.h |   17 +++++++++++++++--
arch/x86/mm/pgtable.c          |    8 +++++++-
2 files changed, 22 insertions(+), 3 deletions(-)
---
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index b4389a4..db83bd4 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -34,6 +34,7 @@ extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);

 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern pte_t *__pte_alloc_one_kernel(struct mm_struct *, unsigned long, gfp_t);
 extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);

 /* Should really implement gc for free page table pages. This could be
@@ -78,9 +79,15 @@ static inline void pmd_populate(struct mm_struct
*mm, pmd_t *pmd,
 #define pmd_pgtable(pmd) pmd_page(pmd)

 #if PAGETABLE_LEVELS > 2
+static inline pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
+{
+	return (pmd_t *)get_zeroed_page(gfp_mask);
+}
+
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return __pmd_alloc_one(mm, addr, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -114,9 +121,15 @@ static inline void pgd_populate(struct mm_struct
*mm, pgd_t *pgd, pud_t *pud)
 	set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(pud)));
 }

+static inline pud_t *
+__pud_alloc_one(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
+{
+	return (pud_t *)get_zeroed_page(gfp_mask);
+}
+
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return __pud_alloc_one(mm, addr, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 500242d..c42a27c 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -15,9 +15,15 @@

 gfp_t __userpte_alloc_gfp = PGALLOC_GFP | PGALLOC_USER_GFP;

+pte_t *
+__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
gfp_t gfp_mask)
+{
+	return (pte_t *)__get_free_page(gfp_mask | __GFP_NOTRACK | __GFP_ZERO);
+}
+
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return (pte_t *)__get_free_page(PGALLOC_GFP);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
 }

 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
