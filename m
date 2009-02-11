Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 68A416B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 05:17:03 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n1BAH0Ve004434
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 10:17:00 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1BAGxss2056446
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 11:16:59 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1BAGvX0010758
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 11:16:58 +0100
Subject: Re: [PATCH -mmotm] mm: unify some pmd_*() functions
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <a2776ec50902100541p1503adaay52d221411d92c842@mail.gmail.com>
References: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
	 <16182.1234199195@redhat.com>
	 <a2776ec50902100541p1503adaay52d221411d92c842@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 11 Feb 2009 11:16:55 +0100
Message-Id: <1234347415.19362.5.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <righi.andrea@gmail.com>
Cc: David Howells <dhowells@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-02-10 at 14:41 +0100, Andrea Righi wrote: 
> On Mon, Feb 9, 2009 at 6:06 PM, David Howells <dhowells@redhat.com> wrote:
> > Andrea Righi <righi.andrea@gmail.com> wrote:
> >
> >> Unify all the identical implementations of pmd_free(), __pmd_free_tlb(),
> >> pmd_alloc_one(), pmd_addr_end() in include/asm-generic/pgtable-nopmd.h
> >
> > NAK for FRV on two fronts:
> 
> This patch generates too many followup fixes and it's better to simply drop it
> for now.
> 
> I think we need to use a different approach and, more important, we need to
> clean a lot of .h files before to avoid the include hell problems.

I'm in favour of getting rid of include/asm-generic/pgtable-nopmd.h and
include/asm-generic/pgtable-nopud.h altogether. The folding of page
table levels is hard enough to understand but with the definitions
scattered in five different files it is no fun. At least my brain starts
to hurt everytime I have to look at an architecture that uses the
generic folding. As an example I hacked together the conversion for
sparc64. It compiles, dunno if it works.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


---
diff -urpN linux-2.6/arch/sparc/include/asm/page_64.h linux-2.6-example/arch/sparc/include/asm/page_64.h
--- linux-2.6/arch/sparc/include/asm/page_64.h	2008-10-12 22:12:26.000000000 +0200
+++ linux-2.6-example/arch/sparc/include/asm/page_64.h	2009-02-11 11:03:56.000000000 +0100
@@ -61,18 +61,21 @@ extern void copy_user_page(void *to, voi
 typedef struct { unsigned long pte; } pte_t;
 typedef struct { unsigned long iopte; } iopte_t;
 typedef struct { unsigned int pmd; } pmd_t;
+typedef struct { unsigned int pud; } pud_t;
 typedef struct { unsigned int pgd; } pgd_t;
 typedef struct { unsigned long pgprot; } pgprot_t;
 
 #define pte_val(x)	((x).pte)
 #define iopte_val(x)	((x).iopte)
 #define pmd_val(x)      ((x).pmd)
+#define pud_val(x)	((x).pud)
 #define pgd_val(x)	((x).pgd)
 #define pgprot_val(x)	((x).pgprot)
 
 #define __pte(x)	((pte_t) { (x) } )
 #define __iopte(x)	((iopte_t) { (x) } )
 #define __pmd(x)        ((pmd_t) { (x) } )
+#define __pud(x)	((pud_t) { (x) } )
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
diff -urpN linux-2.6/arch/sparc/include/asm/pgalloc_64.h linux-2.6-example/arch/sparc/include/asm/pgalloc_64.h
--- linux-2.6/arch/sparc/include/asm/pgalloc_64.h	2008-07-29 10:11:30.000000000 +0200
+++ linux-2.6-example/arch/sparc/include/asm/pgalloc_64.h	2009-02-11 11:11:29.000000000 +0100
@@ -24,6 +24,12 @@ static inline void pgd_free(struct mm_st
 	quicklist_free(0, NULL, pgd);
 }
 
+#define pgd_populate(mm, pgd, pud)	do { } while (0)
+
+#define pud_alloc_one(mm, address)	(NULL)
+#define pud_free(mm, x)			do { } while (0)
+#define __pud_free_tlb(tlb, x)		do { } while (0)
+
 #define pud_populate(MM, PUD, PMD)	pud_set(PUD, PMD)
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
diff -urpN linux-2.6/arch/sparc/include/asm/pgtable_64.h linux-2.6-example/arch/sparc/include/asm/pgtable_64.h
--- linux-2.6/arch/sparc/include/asm/pgtable_64.h	2008-10-12 22:12:26.000000000 +0200
+++ linux-2.6-example/arch/sparc/include/asm/pgtable_64.h	2009-02-11 11:07:00.000000000 +0100
@@ -12,8 +12,6 @@
  * the SpitFire page tables.
  */
 
-#include <asm-generic/pgtable-nopud.h>
-
 #include <linux/compiler.h>
 #include <linux/const.h>
 #include <asm/types.h>
@@ -68,6 +66,11 @@
 #define PMD_MASK	(~(PMD_SIZE-1))
 #define PMD_BITS	(PAGE_SHIFT - 2)
 
+#define PUD_SHIFT	(PAGE_SHIFT + (PAGE_SHIFT-3) + PMD_BITS)
+#define PUD_SIZE	(_AC(1,UL) << PUD_SHIFT)
+#define PUD_MASK	(~(PUD_SIZE-1))
+#define PUD_BITS	(PAGE_SHIFT - 2)
+
 /* PGDIR_SHIFT determines what a third-level page table entry can map */
 #define PGDIR_SHIFT	(PAGE_SHIFT + (PAGE_SHIFT-3) + PMD_BITS)
 #define PGDIR_SIZE	(_AC(1,UL) << PGDIR_SHIFT)
@@ -81,6 +84,7 @@
 /* Entries per page directory level. */
 #define PTRS_PER_PTE	(1UL << (PAGE_SHIFT-3))
 #define PTRS_PER_PMD	(1UL << PMD_BITS)
+#define PTRS_PER_PUD	(1UL)
 #define PTRS_PER_PGD	(1UL << PGDIR_BITS)
 
 /* Kernel has a separate 44bit address space. */
@@ -88,6 +92,7 @@
 
 #define pte_ERROR(e)	__builtin_trap()
 #define pmd_ERROR(e)	__builtin_trap()
+#define pud_ERROR(e)	__builtin_trap()
 #define pgd_ERROR(e)	__builtin_trap()
 
 #endif /* !(__ASSEMBLY__) */
@@ -630,6 +635,10 @@ static inline int pte_special(pte_t pte)
 #define pud_bad(pud)			(0)
 #define pud_present(pud)		(pud_val(pud) != 0U)
 #define pud_clear(pudp)			(pud_val(*(pudp)) = 0U)
+#define pgd_none(pgd)			(0)
+#define pgd_bad(pgd)			(0)
+#define pgd_present(pgd)		(1)
+#define pgd_clear(pgd)			do { } while (0)
 
 /* Same in both SUN4V and SUN4U.  */
 #define pte_none(pte) 			(!pte_val(pte))
@@ -641,6 +650,8 @@ static inline int pte_special(pte_t pte)
 /* to find an entry in a kernel page-table-directory */
 #define pgd_offset_k(address) pgd_offset(&init_mm, address)
 
+#define pud_offset(pgdp, address) ((pud_t *) pgdp)
+
 /* Find an entry in the second-level page table.. */
 #define pmd_offset(pudp, address)	\
 	((pmd_t *) pud_page_vaddr(*(pudp)) + \


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
