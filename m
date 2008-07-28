Received: by fg-out-1718.google.com with SMTP id 19so7452709fgg.4
        for <linux-mm@kvack.org>; Mon, 28 Jul 2008 15:53:36 -0700 (PDT)
Message-ID: <488E4DEB.5010705@gmail.com>
Date: Tue, 29 Jul 2008 00:53:31 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm: unify pmd_free() and __pmd_free_tlb() implementation
References: <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org>	<488DF119.2000004@gmail.com>	<20080729012656.566F.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<488DFFB0.1090107@gmail.com> <20080728133030.8b29fa5a.akpm@linux-foundation.org> <488E3020.1040701@goop.org>
In-Reply-To: <488E3020.1040701@goop.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> Andrew Morton wrote:
>> I can second that.  See
>> http://userweb.kernel.org/~akpm/mmotm/broken-out/include-asm-generic-pgtable-nopmdh-macros-are-noxious-reason-435.patch
>>
>> Ingo cruelly ignored it.  Probably he's used to ignoring the comit
>> storm which I send in his direction - I'll need to resend it sometime.
>>
>> I'd consider that patch to be partial - we should demacroize the
>> surrounding similar functions too.  But that will require a bit more
>> testing.
> 
> Its immediate neighbours should be easy enough (pmd_alloc_one, 
> __pmd_free_tlb), but any of the ones involving pmd_t risk #include hell 
> (though the earlier references to pud_t in inline functions suggest it 
> will work).  And pmd_addr_end is just ugly.
> 
>     J
> 

ok, let's start with the easiest: pmd_free() and __pmd_free_tlb().

Following another attempt to unify the implementations using inline
functions. It seems to build fine on x86 (pae / non-pae) and on x86_64.
This is an RFC patch right now, not for inclusion (just asking if it
could be a reasonable approach or not). And in any case this would need
more testing.

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 arch/sparc/include/asm/pgalloc_64.h |    1 +
 include/asm-alpha/pgalloc.h         |    1 +
 include/asm-arm/pgalloc.h           |    1 -
 include/asm-frv/pgalloc.h           |    2 --
 include/asm-generic/pgtable-nopmd.h |   19 +++++++++++++++++--
 include/asm-ia64/pgalloc.h          |    1 +
 include/asm-m32r/pgalloc.h          |    2 --
 include/asm-m68k/motorola_pgalloc.h |    3 ++-
 include/asm-m68k/sun3_pgalloc.h     |    7 -------
 include/asm-mips/pgalloc.h          |   12 +-----------
 include/asm-parisc/pgalloc.h        |    2 +-
 include/asm-powerpc/pgalloc-32.h    |    2 --
 include/asm-powerpc/pgalloc-64.h    |    1 +
 include/asm-s390/pgalloc.h          |    1 -
 include/asm-sh/pgalloc.h            |    8 --------
 include/asm-um/pgalloc.h            |    1 +
 include/asm-x86/pgalloc.h           |    2 ++
 17 files changed, 28 insertions(+), 38 deletions(-)

diff --git a/arch/sparc/include/asm/pgalloc_64.h b/arch/sparc/include/asm/pgalloc_64.h
index 5bdfa2c..17cf9f5 100644
--- a/arch/sparc/include/asm/pgalloc_64.h
+++ b/arch/sparc/include/asm/pgalloc_64.h
@@ -35,6 +35,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	quicklist_free(0, NULL, pmd);
 }
+#define pmd_free pmd_free
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
diff --git a/include/asm-alpha/pgalloc.h b/include/asm-alpha/pgalloc.h
index fd09015..ba68ca2 100644
--- a/include/asm-alpha/pgalloc.h
+++ b/include/asm-alpha/pgalloc.h
@@ -49,6 +49,7 @@ pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_page((unsigned long)pmd);
 }
+#define pmd_free pmd_free
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
 
diff --git a/include/asm-arm/pgalloc.h b/include/asm-arm/pgalloc.h
index 163b030..c1da401 100644
--- a/include/asm-arm/pgalloc.h
+++ b/include/asm-arm/pgalloc.h
@@ -27,7 +27,6 @@
  * Since we have only two-level page tables, these are trivial
  */
 #define pmd_alloc_one(mm,addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(mm, pmd)		do { } while (0)
 #define pgd_populate(mm,pmd,pte)	BUG()
 
 extern pgd_t *get_pgd_slow(struct mm_struct *mm);
diff --git a/include/asm-frv/pgalloc.h b/include/asm-frv/pgalloc.h
index 971e6ad..790b9ff 100644
--- a/include/asm-frv/pgalloc.h
+++ b/include/asm-frv/pgalloc.h
@@ -61,8 +61,6 @@ do {							\
  * (In the PAE case we free the pmds as part of the pgd.)
  */
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *) 2); })
-#define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
 
 #endif /* CONFIG_MMU */
 
diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
index 087325e..7bf330e 100644
--- a/include/asm-generic/pgtable-nopmd.h
+++ b/include/asm-generic/pgtable-nopmd.h
@@ -5,6 +5,9 @@
 
 #include <asm-generic/pgtable-nopud.h>
 
+struct mm_struct;
+struct mmu_gather;
+
 #define __PAGETABLE_PMD_FOLDED
 
 /*
@@ -54,8 +57,20 @@ static inline pmd_t * pmd_offset(pud_t * pud, unsigned long address)
  * inside the pud, so has no extra memory associated with it.
  */
 #define pmd_alloc_one(mm, address)		NULL
-#define pmd_free(mm, x)				do { } while (0)
-#define __pmd_free_tlb(tlb, x)			do { } while (0)
+
+#ifndef pmd_free
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
+{
+}
+#define pmd_free pmd_free
+#endif
+
+#ifndef __pmd_free_tlb
+static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
+{
+}
+#define __pmd_free_tlb __pmd_free_tlb
+#endif
 
 #undef  pmd_addr_end
 #define pmd_addr_end(addr, end)			(end)
diff --git a/include/asm-ia64/pgalloc.h b/include/asm-ia64/pgalloc.h
index b9ac1a6..6c9575c 100644
--- a/include/asm-ia64/pgalloc.h
+++ b/include/asm-ia64/pgalloc.h
@@ -66,6 +66,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	quicklist_free(0, NULL, pmd);
 }
+#define pmd_free pmd_free
 
 #define __pmd_free_tlb(tlb, pmd)	pmd_free((tlb)->mm, pmd)
 
diff --git a/include/asm-m32r/pgalloc.h b/include/asm-m32r/pgalloc.h
index f11a2b9..f7ecc72 100644
--- a/include/asm-m32r/pgalloc.h
+++ b/include/asm-m32r/pgalloc.h
@@ -67,8 +67,6 @@ static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
  */
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 #define check_pgt_cache()	do { } while (0)
diff --git a/include/asm-m68k/motorola_pgalloc.h b/include/asm-m68k/motorola_pgalloc.h
index d08bf62..1dc96c7 100644
--- a/include/asm-m68k/motorola_pgalloc.h
+++ b/include/asm-m68k/motorola_pgalloc.h
@@ -72,12 +72,13 @@ static inline int pmd_free(struct mm_struct *mm, pmd_t *pmd)
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
index d4c83f1..795e3c0 100644
--- a/include/asm-m68k/sun3_pgalloc.h
+++ b/include/asm-m68k/sun3_pgalloc.h
@@ -75,13 +75,6 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, pgtable_t page
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
diff --git a/include/asm-mips/pgalloc.h b/include/asm-mips/pgalloc.h
index 1275831..79a4182 100644
--- a/include/asm-mips/pgalloc.h
+++ b/include/asm-mips/pgalloc.h
@@ -104,17 +104,6 @@ do {							\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
-#ifdef CONFIG_32BIT
-
-/*
- * allocating and freeing a pmd is trivial: the 1-entry pmd is
- * inside the pgd, so has no extra memory associated with it.
- */
-#define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb, x)		do { } while (0)
-
-#endif
-
 #ifdef CONFIG_64BIT
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
@@ -131,6 +120,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_pages((unsigned long)pmd, PMD_ORDER);
 }
+#define pmd_free pmd_free
 
 #define __pmd_free_tlb(tlb, x)	pmd_free((tlb)->mm, x)
 
diff --git a/include/asm-parisc/pgalloc.h b/include/asm-parisc/pgalloc.h
index fc987a1..632b2c5 100644
--- a/include/asm-parisc/pgalloc.h
+++ b/include/asm-parisc/pgalloc.h
@@ -80,6 +80,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 #endif
 	free_pages((unsigned long)pmd, PMD_ORDER);
 }
+#define pmd_free pmd_free
 
 #else
 
@@ -91,7 +92,6 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
  */
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(mm, x)			do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 #endif
diff --git a/include/asm-powerpc/pgalloc-32.h b/include/asm-powerpc/pgalloc-32.h
index 58c0714..dc6dca5 100644
--- a/include/asm-powerpc/pgalloc-32.h
+++ b/include/asm-powerpc/pgalloc-32.h
@@ -13,8 +13,6 @@ extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
  * the pgd will always be present..
  */
 /* #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); }) */
-#define pmd_free(mm, x) 		do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
 /* #define pgd_populate(mm, pmd, pte)      BUG() */
 
 #ifndef CONFIG_BOOKE
diff --git a/include/asm-powerpc/pgalloc-64.h b/include/asm-powerpc/pgalloc-64.h
index 812a1d8..0b63bc4 100644
--- a/include/asm-powerpc/pgalloc-64.h
+++ b/include/asm-powerpc/pgalloc-64.h
@@ -87,6 +87,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	kmem_cache_free(pgtable_cache[PMD_CACHE_NUM], pmd);
 }
+#define pmd_free pmd_free
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
diff --git a/include/asm-s390/pgalloc.h b/include/asm-s390/pgalloc.h
index f5b2bf3..67b4758 100644
--- a/include/asm-s390/pgalloc.h
+++ b/include/asm-s390/pgalloc.h
@@ -61,7 +61,6 @@ static inline unsigned long pgd_entry_type(struct mm_struct *mm)
 #define pud_free(mm, x)				do { } while (0)
 
 #define pmd_alloc_one(mm,address)		({ BUG(); ((pmd_t *)2); })
-#define pmd_free(mm, x)				do { } while (0)
 
 #define pgd_populate(mm, pgd, pud)		BUG()
 #define pgd_populate_kernel(mm, pgd, pud)	BUG()
diff --git a/include/asm-sh/pgalloc.h b/include/asm-sh/pgalloc.h
index 84dd2db..f9d9ccb 100644
--- a/include/asm-sh/pgalloc.h
+++ b/include/asm-sh/pgalloc.h
@@ -79,14 +79,6 @@ do {							\
 	tlb_remove_page((tlb), (pte));			\
 } while (0)
 
-/*
- * allocating and freeing a pmd is trivial: the 1-entry pmd is
- * inside the pgd, so has no extra memory associated with it.
- */
-
-#define pmd_free(mm, x)			do { } while (0)
-#define __pmd_free_tlb(tlb,x)		do { } while (0)
-
 static inline void check_pgt_cache(void)
 {
 	quicklist_trim(QUICK_PGD, NULL, 25, 16);
diff --git a/include/asm-um/pgalloc.h b/include/asm-um/pgalloc.h
index 9062a6e..264120b 100644
--- a/include/asm-um/pgalloc.h
+++ b/include/asm-um/pgalloc.h
@@ -52,6 +52,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	free_page((unsigned long)pmd);
 }
+#define pmd_free pmd_free
 
 #define __pmd_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
 #endif
diff --git a/include/asm-x86/pgalloc.h b/include/asm-x86/pgalloc.h
index d63ea43..3c46c59 100644
--- a/include/asm-x86/pgalloc.h
+++ b/include/asm-x86/pgalloc.h
@@ -76,8 +76,10 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 	BUG_ON((unsigned long)pmd & (PAGE_SIZE-1));
 	free_page((unsigned long)pmd);
 }
+#define pmd_free pmd_free
 
 extern void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd);
+#define __pmd_free_tlb __pmd_free_tlb
 
 #ifdef CONFIG_X86_PAE
 extern void pud_populate(struct mm_struct *mm, pud_t *pudp, pmd_t *pmd);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
