Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7C2426B0044
	for <linux-mm@kvack.org>; Sun, 25 Jan 2009 16:35:46 -0500 (EST)
Received: by nf-out-0910.google.com with SMTP id c10so1340768nfd.6
        for <linux-mm@kvack.org>; Sun, 25 Jan 2009 13:35:43 -0800 (PST)
From: Andrea Righi <righi.andrea@gmail.com>
Subject: [PATCH -mmotm] mm: unify some pmd_*() functions
Date: Sun, 25 Jan 2009 22:35:37 +0100
Message-Id: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Andrea Righi <righi.andrea@gmail.com>
List-ID: <linux-mm.kvack.org>

Unify all the identical implementations of pmd_free(), __pmd_free_tlb(),
pmd_alloc_one(), pmd_addr_end() in include/asm-generic/pgtable-nopmd.h

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 include/asm-frv/pgalloc.h           |    9 +-------
 include/asm-generic/pgtable-nopmd.h |   36 ++++++++++++++++++++++++++++++----
 include/asm-m32r/pgalloc.h          |    9 +-------
 include/asm-m68k/motorola_pgalloc.h |    4 ++-
 include/asm-m68k/sun3_pgalloc.h     |   10 +--------
 5 files changed, 37 insertions(+), 31 deletions(-)

diff --git a/include/asm-frv/pgalloc.h b/include/asm-frv/pgalloc.h
index 971e6ad..c4be813 100644
--- a/include/asm-frv/pgalloc.h
+++ b/include/asm-frv/pgalloc.h
@@ -55,14 +55,7 @@ do {							\
 	tlb_remove_page((tlb),(pte));			\
 } while (0)
 
-/*
- * allocating and freeing a pmd is trivial: the 1-entry pmd is
- * inside the pgd, so has no extra memory associated with it.
- * (In the PAE case we free the pmds as part of the pgd.)
- */
-#define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *) 2); })
-#define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
+#define pmd_alloc_one pmd_alloc_one_bug
 
 #endif /* CONFIG_MMU */
 
diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
index a7cdc48..b132d69 100644
--- a/include/asm-generic/pgtable-nopmd.h
+++ b/include/asm-generic/pgtable-nopmd.h
@@ -4,6 +4,7 @@
 #ifndef __ASSEMBLY__
 
 #include <asm-generic/pgtable-nopud.h>
+#include <asm/bug.h>
 
 struct mm_struct;
 
@@ -54,15 +55,40 @@ static inline pmd_t * pmd_offset(pud_t * pud, unsigned long address)
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
  * inside the pud, so has no extra memory associated with it.
+ * (In the PAE case we free the pmds as part of the pgd.)
  */
-#define pmd_alloc_one(mm, address)		NULL
+#ifndef pmd_alloc_one
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
+{
+	return NULL;
+}
+#define pmd_alloc_one pmd_alloc_one
+#endif
+static inline pmd_t *pmd_alloc_one_bug(struct mm_struct *mm, unsigned long addr)
+{
+	BUG();
+	return (pmd_t *)(2);
+}
+#ifndef pmd_free
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 }
-#define __pmd_free_tlb(tlb, x)			do { } while (0)
-
-#undef  pmd_addr_end
-#define pmd_addr_end(addr, end)			(end)
+#define pmd_free pmd_free
+#endif
+#ifndef __pmd_free_tlb
+struct mmu_gather;
+static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
+{
+}
+#define __pmd_free_tlb __pmd_free_tlb
+#endif
+#ifndef pmd_addr_end
+static inline unsigned long pmd_addr_end(unsigned long addr, unsigned long end)
+{
+	return end;
+}
+#define pmd_addr_end pmd_addr_end
+#endif
 
 #endif /* __ASSEMBLY__ */
 
diff --git a/include/asm-m32r/pgalloc.h b/include/asm-m32r/pgalloc.h
index f11a2b9..b700896 100644
--- a/include/asm-m32r/pgalloc.h
+++ b/include/asm-m32r/pgalloc.h
@@ -60,15 +60,8 @@ static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 
 #define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
 
-/*
- * allocating and freeing a pmd is trivial: the 1-entry pmd is
- * inside the pgd, so has no extra memory associated with it.
- * (In the PAE case we free the pmds as part of the pgd.)
- */
+#define pmd_alloc_one pmd_alloc_one_bug
 
-#define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 #define check_pgt_cache()	do { } while (0)
diff --git a/include/asm-m68k/motorola_pgalloc.h b/include/asm-m68k/motorola_pgalloc.h
index d08bf62..984436d 100644
--- a/include/asm-m68k/motorola_pgalloc.h
+++ b/include/asm-m68k/motorola_pgalloc.h
@@ -67,17 +67,19 @@ static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	return get_pointer_table();
 }
+#define pmd_alloc_one pmd_alloc_one
 
 static inline int pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	return free_pointer_table(pmd);
 }
+#define pmd_free pmd_free
 
 static inline int __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
 {
 	return free_pointer_table(pmd);
 }
-
+#define __pmd_free_tlb __pmd_free_tlb
 
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
diff --git a/include/asm-m68k/sun3_pgalloc.h b/include/asm-m68k/sun3_pgalloc.h
index d4c83f1..0fe28fc 100644
--- a/include/asm-m68k/sun3_pgalloc.h
+++ b/include/asm-m68k/sun3_pgalloc.h
@@ -18,8 +18,7 @@
 
 extern const char bad_pmd_string[];
 
-#define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
-
+#define pmd_alloc_one pmd_alloc_one_bug
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
@@ -75,13 +74,6 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, pgtable_t page
 }
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
-/*
- * allocating and freeing a pmd is trivial: the 1-entry pmd is
- * inside the pgd, so has no extra memory associated with it.
- */
-#define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
-
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
         free_page((unsigned long) pgd);
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
