Message-ID: <4181EFD7.7000902@yahoo.com.au>
Date: Fri, 29 Oct 2004 17:23:03 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 6/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au> <4181EF54.6080308@yahoo.com.au> <4181EF69.4070201@yahoo.com.au> <4181EF80.3030709@yahoo.com.au> <4181EF96.2030602@yahoo.com.au> <4181EFBD.6000007@yahoo.com.au>
In-Reply-To: <4181EFBD.6000007@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------050103070504060304020201"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050103070504060304020201
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

6/7

--------------050103070504060304020201
Content-Type: text/x-patch;
 name="vm-i386-lockless-page-table.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-i386-lockless-page-table.patch"



i386: Implement lockless pagetables using cmpxchg


---

 linux-2.6-npiggin/include/asm-i386/pgtable-2level.h |    3 +
 linux-2.6-npiggin/include/asm-i386/pgtable-3level.h |   23 +++-------
 linux-2.6-npiggin/include/asm-i386/pgtable.h        |   46 ++++++++++++++++++++
 3 files changed, 58 insertions(+), 14 deletions(-)

diff -puN include/asm-i386/pgtable.h~vm-i386-lockless-page-table include/asm-i386/pgtable.h
--- linux-2.6/include/asm-i386/pgtable.h~vm-i386-lockless-page-table	2004-10-29 16:28:16.000000000 +1000
+++ linux-2.6-npiggin/include/asm-i386/pgtable.h	2004-10-29 16:41:46.000000000 +1000
@@ -398,6 +398,52 @@ extern pte_t *lookup_address(unsigned lo
 		}							  \
 	} while (0)
 
+#define __HAVE_ARCH_PTEP_CMPXCHG
+
+#ifdef CONFIG_X86_PAE
+#define __HAVE_ARCH_PTEP_ATOMIC_READ
+#define ptep_atomic_read(__ptep)					\
+({									\
+	unsigned long long ret = get_64bit((unsigned long long *)__ptep); \
+ 	*((pte_t *)&ret);						\
+})
+#endif
+
+#define pgd_test_and_populate(__mm, ___pgd, ___page)			\
+({									\
+	BUG();								\
+	0;								\
+})
+
+#define PMD_NONE 0
+
+#ifndef CONFIG_X86_PAE
+#define pmd_test_and_populate(__mm, ___pmd, ___page)			\
+({									\
+	unlikely(cmpxchg((unsigned long *)___pmd, PMD_NONE,		\
+	_PAGE_TABLE + (page_to_pfn(___page) << PAGE_SHIFT)) != PMD_NONE); \
+})
+
+#define pmd_test_and_populate_kernel(__mm, ___pmd, ___page)		\
+({									\
+	unlikely(cmpxchg((unsigned long *)___pmd, PMD_NONE,		\
+			_PAGE_TABLE + __pa(___page)) != PMD_NONE);	\
+})
+#else
+#define pmd_test_and_populate(__mm, ___pmd, ___page)			\
+({									\
+	unlikely(cmpxchg8b((unsigned long long *)___pmd, PMD_NONE,	\
+	_PAGE_TABLE + ((unsigned long long)page_to_pfn(___page) << PAGE_SHIFT)) != PMD_NONE); \
+})
+
+#define pmd_test_and_populate_kernel(__mm, ___pmd, ___page)		\
+({									\
+	unlikely(cmpxchg8b((unsigned long long *)___pmd, PMD_NONE,	\
+		_PAGE_TABLE + (unsigned long long)__pa(___page)) != PMD_NONE); \
+})
+#endif
+
+
 #endif /* !__ASSEMBLY__ */
 
 #ifndef CONFIG_DISCONTIGMEM
diff -puN include/asm-i386/pgtable-2level.h~vm-i386-lockless-page-table include/asm-i386/pgtable-2level.h
--- linux-2.6/include/asm-i386/pgtable-2level.h~vm-i386-lockless-page-table	2004-10-29 16:28:16.000000000 +1000
+++ linux-2.6-npiggin/include/asm-i386/pgtable-2level.h	2004-10-29 16:28:16.000000000 +1000
@@ -82,4 +82,7 @@ static inline int pte_exec_kernel(pte_t 
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { (pte).pte_low })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
+#define ptep_cmpxchg(ptep, old, new)					\
+({ cmpxchg(&(ptep)->pte_low, (old).pte_low, (new).pte_low) != (old).pte_low; })
+
 #endif /* _I386_PGTABLE_2LEVEL_H */
diff -puN include/asm-i386/pgtable-3level.h~vm-i386-lockless-page-table include/asm-i386/pgtable-3level.h
--- linux-2.6/include/asm-i386/pgtable-3level.h~vm-i386-lockless-page-table	2004-10-29 16:28:16.000000000 +1000
+++ linux-2.6-npiggin/include/asm-i386/pgtable-3level.h	2004-10-29 16:28:16.000000000 +1000
@@ -42,26 +42,15 @@ static inline int pte_exec_kernel(pte_t 
 	return pte_x(pte);
 }
 
-/* Rules for using set_pte: the pte being assigned *must* be
- * either not present or in a state where the hardware will
- * not attempt to update the pte.  In places where this is
- * not possible, use pte_get_and_clear to obtain the old pte
- * value and then use set_pte to update it.  -ben
- */
-static inline void set_pte(pte_t *ptep, pte_t pte)
-{
-	ptep->pte_high = pte.pte_high;
-	smp_wmb();
-	ptep->pte_low = pte.pte_low;
-}
-#define __HAVE_ARCH_SET_PTE_ATOMIC
-#define set_pte_atomic(pteptr,pteval) \
+#define set_pte(pteptr,pteval) \
 		set_64bit((unsigned long long *)(pteptr),pte_val(pteval))
 #define set_pmd(pmdptr,pmdval) \
 		set_64bit((unsigned long long *)(pmdptr),pmd_val(pmdval))
 #define set_pgd(pgdptr,pgdval) \
 		set_64bit((unsigned long long *)(pgdptr),pgd_val(pgdval))
 
+#define set_pte_atomic(pteptr,pteval) set_pte(pteptr,pteval)
+
 /*
  * Pentium-II erratum A13: in PAE mode we explicitly have to flush
  * the TLB via cr3 if the top-level pgd is changed...
@@ -142,4 +131,10 @@ static inline pmd_t pfn_pmd(unsigned lon
 #define __pte_to_swp_entry(pte)		((swp_entry_t){ (pte).pte_high })
 #define __swp_entry_to_pte(x)		((pte_t){ 0, (x).val })
 
+#define ptep_cmpxchg(ptep, old, new)					\
+({									\
+	cmpxchg8b(((unsigned long long *)ptep), pte_val(old), pte_val(new)) \
+ 			!= pte_val(old);				\
+})
+
 #endif /* _I386_PGTABLE_3LEVEL_H */

_

--------------050103070504060304020201--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
