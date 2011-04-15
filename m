Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 04C89900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:38:28 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3FHVZAn013375
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:31:35 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3FHcNW1119418
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:38:23 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3FHcNKv021023
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:38:23 -0600
Subject: [RFC][PATCH 1/3] pass mm in to pgtable ctor/dtor
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 15 Apr 2011 10:38:22 -0700
References: <20110415173821.62660715@kernel>
In-Reply-To: <20110415173821.62660715@kernel>
Message-Id: <20110415173822.40111D3F@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>


The pagetable page constructor and destructor functions are
handy places to hook in our new accounting.  But, if we are
going to store the accounting in the mm, we need the mm
passed in to these functions as well.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/arch/alpha/include/asm/pgalloc.h         |    4 ++--
 linux-2.6.git-dave/arch/arm/include/asm/pgalloc.h           |    4 ++--
 linux-2.6.git-dave/arch/arm/include/asm/tlb.h               |    2 +-
 linux-2.6.git-dave/arch/avr32/include/asm/pgalloc.h         |    6 +++---
 linux-2.6.git-dave/arch/cris/include/asm/pgalloc.h          |    6 +++---
 linux-2.6.git-dave/arch/frv/include/asm/pgalloc.h           |    4 ++--
 linux-2.6.git-dave/arch/frv/mm/pgalloc.c                    |    2 +-
 linux-2.6.git-dave/arch/ia64/include/asm/pgalloc.h          |    4 ++--
 linux-2.6.git-dave/arch/m32r/include/asm/pgalloc.h          |    4 ++--
 linux-2.6.git-dave/arch/m68k/include/asm/motorola_pgalloc.h |    6 +++---
 linux-2.6.git-dave/arch/m68k/include/asm/sun3_pgalloc.h     |    6 +++---
 linux-2.6.git-dave/arch/mips/include/asm/pgalloc.h          |    6 +++---
 linux-2.6.git-dave/arch/parisc/include/asm/pgalloc.h        |    4 ++--
 linux-2.6.git-dave/arch/powerpc/include/asm/pgalloc-64.h    |    2 +-
 linux-2.6.git-dave/arch/powerpc/include/asm/pgalloc.h       |    4 ++--
 linux-2.6.git-dave/arch/powerpc/mm/pgtable_32.c             |    2 +-
 linux-2.6.git-dave/arch/s390/mm/pgtable.c                   |    6 +++---
 linux-2.6.git-dave/arch/score/include/asm/pgalloc.h         |    6 +++---
 linux-2.6.git-dave/arch/sh/include/asm/pgalloc.h            |    6 +++---
 linux-2.6.git-dave/arch/sparc/include/asm/pgalloc_64.h      |    4 ++--
 linux-2.6.git-dave/arch/sparc/mm/srmmu.c                    |    6 +++---
 linux-2.6.git-dave/arch/sparc/mm/sun4c.c                    |    6 +++---
 linux-2.6.git-dave/arch/tile/mm/pgtable.c                   |    6 +++---
 linux-2.6.git-dave/arch/um/include/asm/pgalloc.h            |    4 ++--
 linux-2.6.git-dave/arch/um/kernel/mem.c                     |    2 +-
 linux-2.6.git-dave/arch/unicore32/include/asm/pgalloc.h     |    4 ++--
 linux-2.6.git-dave/arch/unicore32/include/asm/tlb.h         |    2 +-
 linux-2.6.git-dave/arch/x86/include/asm/pgalloc.h           |    2 +-
 linux-2.6.git-dave/arch/x86/mm/pgtable.c                    |    4 ++--
 linux-2.6.git-dave/arch/xtensa/include/asm/pgalloc.h        |    4 ++--
 linux-2.6.git-dave/include/linux/mm.h                       |    4 ++--
 31 files changed, 66 insertions(+), 66 deletions(-)

diff -puN arch/alpha/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/alpha/include/asm/pgalloc.h
--- linux-2.6.git/arch/alpha/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.628833450 -0700
+++ linux-2.6.git-dave/arch/alpha/include/asm/pgalloc.h	2011-04-15 10:37:07.756833406 -0700
@@ -72,14 +72,14 @@ pte_alloc_one(struct mm_struct *mm, unsi
 	if (!pte)
 		return NULL;
 	page = virt_to_page(pte);
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 	return page;
 }
 
 static inline void
 pte_free(struct mm_struct *mm, pgtable_t page)
 {
-	pgtable_page_dtor(page);
+	pgtable_page_dtor(mm, page);
 	__free_page(page);
 }
 
diff -puN arch/arm/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/arm/include/asm/pgalloc.h
--- linux-2.6.git/arch/arm/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.632833448 -0700
+++ linux-2.6.git-dave/arch/arm/include/asm/pgalloc.h	2011-04-15 10:37:07.756833406 -0700
@@ -83,7 +83,7 @@ pte_alloc_one(struct mm_struct *mm, unsi
 	if (pte) {
 		if (!PageHighMem(pte))
 			clean_pte_table(page_address(pte));
-		pgtable_page_ctor(pte);
+		pgtable_page_ctor(mm, pte);
 	}
 
 	return pte;
@@ -100,7 +100,7 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	__free_page(pte);
 }
 
diff -puN arch/arm/include/asm/tlb.h~pass-mm-in-to-pgtable-ctor-dtor arch/arm/include/asm/tlb.h
--- linux-2.6.git/arch/arm/include/asm/tlb.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.636833446 -0700
+++ linux-2.6.git-dave/arch/arm/include/asm/tlb.h	2011-04-15 10:37:07.756833406 -0700
@@ -176,7 +176,7 @@ static inline void tlb_remove_page(struc
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 	unsigned long addr)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	tlb_add_flush(tlb, addr);
 	tlb_remove_page(tlb, pte);
 }
diff -puN arch/avr32/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/avr32/include/asm/pgalloc.h
--- linux-2.6.git/arch/avr32/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.640833445 -0700
+++ linux-2.6.git-dave/arch/avr32/include/asm/pgalloc.h	2011-04-15 10:37:07.756833406 -0700
@@ -68,7 +68,7 @@ static inline pgtable_t pte_alloc_one(st
 		return NULL;
 
 	page = virt_to_page(pg);
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 
 	return page;
 }
@@ -80,13 +80,13 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
 
 #define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_page_dtor((tlb)->mm, pte);		\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
diff -puN arch/cris/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/cris/include/asm/pgalloc.h
--- linux-2.6.git/arch/cris/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.644833444 -0700
+++ linux-2.6.git-dave/arch/cris/include/asm/pgalloc.h	2011-04-15 10:37:07.760833405 -0700
@@ -32,7 +32,7 @@ static inline pgtable_t pte_alloc_one(st
 {
 	struct page *pte;
 	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
-	pgtable_page_ctor(pte);
+	pgtable_page_ctor(mm, pte);
 	return pte;
 }
 
@@ -43,13 +43,13 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	__free_page(pte);
 }
 
 #define __pte_free_tlb(tlb,pte,address)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_page_dtor((tlb)->mm, pte);		\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
diff -puN arch/frv/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/frv/include/asm/pgalloc.h
--- linux-2.6.git/arch/frv/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.648833443 -0700
+++ linux-2.6.git-dave/arch/frv/include/asm/pgalloc.h	2011-04-15 10:37:07.760833405 -0700
@@ -45,13 +45,13 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	__free_page(pte);
 }
 
 #define __pte_free_tlb(tlb,pte,address)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_page_dtor((tlb)->mm, pte);		\
 	tlb_remove_page((tlb),(pte));			\
 } while (0)
 
diff -puN arch/frv/mm/pgalloc.c~pass-mm-in-to-pgtable-ctor-dtor arch/frv/mm/pgalloc.c
--- linux-2.6.git/arch/frv/mm/pgalloc.c~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.652833442 -0700
+++ linux-2.6.git-dave/arch/frv/mm/pgalloc.c	2011-04-15 10:37:07.760833405 -0700
@@ -39,7 +39,7 @@ pgtable_t pte_alloc_one(struct mm_struct
 #endif
 	if (page) {
 		clear_highpage(page);
-		pgtable_page_ctor(page);
+		pgtable_page_ctor(mm, page);
 		flush_dcache_page(page);
 	}
 	return page;
diff -puN arch/ia64/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/ia64/include/asm/pgalloc.h
--- linux-2.6.git/arch/ia64/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.656833441 -0700
+++ linux-2.6.git-dave/arch/ia64/include/asm/pgalloc.h	2011-04-15 10:37:07.760833405 -0700
@@ -91,7 +91,7 @@ static inline pgtable_t pte_alloc_one(st
 	if (!pg)
 		return NULL;
 	page = virt_to_page(pg);
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 	return page;
 }
 
@@ -103,7 +103,7 @@ static inline pte_t *pte_alloc_one_kerne
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	quicklist_free_page(0, NULL, pte);
 }
 
diff -puN arch/m32r/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/m32r/include/asm/pgalloc.h
--- linux-2.6.git/arch/m32r/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.660833440 -0700
+++ linux-2.6.git-dave/arch/m32r/include/asm/pgalloc.h	2011-04-15 10:37:07.760833405 -0700
@@ -43,7 +43,7 @@ static __inline__ pgtable_t pte_alloc_on
 {
 	struct page *pte = alloc_page(GFP_KERNEL|__GFP_ZERO);
 
-	pgtable_page_ctor(pte);
+	pgtable_page_ctor(mm, pte);
 	return pte;
 }
 
@@ -54,7 +54,7 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	__free_page(pte);
 }
 
diff -puN arch/m68k/include/asm/motorola_pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/m68k/include/asm/motorola_pgalloc.h
--- linux-2.6.git/arch/m68k/include/asm/motorola_pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.664833439 -0700
+++ linux-2.6.git-dave/arch/m68k/include/asm/motorola_pgalloc.h	2011-04-15 10:37:07.764833404 -0700
@@ -40,13 +40,13 @@ static inline pgtable_t pte_alloc_one(st
 	flush_tlb_kernel_page(pte);
 	nocache_page(pte);
 	kunmap(page);
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 	return page;
 }
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t page)
 {
-	pgtable_page_dtor(page);
+	pgtable_page_dtor(mm, pte);
 	cache_page(kmap(page));
 	kunmap(page);
 	__free_page(page);
@@ -55,7 +55,7 @@ static inline void pte_free(struct mm_st
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page,
 				  unsigned long address)
 {
-	pgtable_page_dtor(page);
+	pgtable_page_dtor(mm, pte);
 	cache_page(kmap(page));
 	kunmap(page);
 	__free_page(page);
diff -puN arch/m68k/include/asm/sun3_pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/m68k/include/asm/sun3_pgalloc.h
--- linux-2.6.git/arch/m68k/include/asm/sun3_pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.668833438 -0700
+++ linux-2.6.git-dave/arch/m68k/include/asm/sun3_pgalloc.h	2011-04-15 10:37:07.764833404 -0700
@@ -28,13 +28,13 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t page)
 {
-	pgtable_page_dtor(page);
+	pgtable_page_dtor(mm, pte);
         __free_page(page);
 }
 
 #define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_page_dtor((tlb)->mm, pte);		\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
@@ -59,7 +59,7 @@ static inline pgtable_t pte_alloc_one(st
 		return NULL;
 
 	clear_highpage(page);
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 	return page;
 
 }
diff -puN arch/mips/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/mips/include/asm/pgalloc.h
--- linux-2.6.git/arch/mips/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.672833436 -0700
+++ linux-2.6.git-dave/arch/mips/include/asm/pgalloc.h	2011-04-15 10:37:07.764833404 -0700
@@ -82,7 +82,7 @@ static inline struct page *pte_alloc_one
 	pte = alloc_pages(GFP_KERNEL | __GFP_REPEAT, PTE_ORDER);
 	if (pte) {
 		clear_highpage(pte);
-		pgtable_page_ctor(pte);
+		pgtable_page_ctor(mm, pte);
 	}
 	return pte;
 }
@@ -94,13 +94,13 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	__free_pages(pte, PTE_ORDER);
 }
 
 #define __pte_free_tlb(tlb,pte,address)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_page_dtor((tlb)->mm, pte);		\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
diff -puN arch/parisc/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/parisc/include/asm/pgalloc.h
--- linux-2.6.git/arch/parisc/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.676833434 -0700
+++ linux-2.6.git-dave/arch/parisc/include/asm/pgalloc.h	2011-04-15 10:37:07.764833404 -0700
@@ -122,7 +122,7 @@ pte_alloc_one(struct mm_struct *mm, unsi
 {
 	struct page *page = alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
 	if (page)
-		pgtable_page_ctor(page);
+		pgtable_page_ctor(mm, page);
 	return page;
 }
 
@@ -140,7 +140,7 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	pte_free_kernel(mm, page_address(pte));
 }
 
diff -puN arch/powerpc/include/asm/pgalloc-64.h~pass-mm-in-to-pgtable-ctor-dtor arch/powerpc/include/asm/pgalloc-64.h
--- linux-2.6.git/arch/powerpc/include/asm/pgalloc-64.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.680833432 -0700
+++ linux-2.6.git-dave/arch/powerpc/include/asm/pgalloc-64.h	2011-04-15 10:37:07.768833403 -0700
@@ -116,7 +116,7 @@ static inline pgtable_t pte_alloc_one(st
 	if (!pte)
 		return NULL;
 	page = virt_to_page(pte);
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 	return page;
 }
 
diff -puN arch/powerpc/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/powerpc/include/asm/pgalloc.h
--- linux-2.6.git/arch/powerpc/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.684833431 -0700
+++ linux-2.6.git-dave/arch/powerpc/include/asm/pgalloc.h	2011-04-15 10:37:07.768833403 -0700
@@ -20,7 +20,7 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
-	pgtable_page_dtor(ptepage);
+	pgtable_page_dtor(mm, ptepage);
 	__free_page(ptepage);
 }
 
@@ -45,7 +45,7 @@ static inline void __pte_free_tlb(struct
 				  unsigned long address)
 {
 	tlb_flush_pgtable(tlb, address);
-	pgtable_page_dtor(ptepage);
+	pgtable_page_dtor(tlb->mm, ptepage);
 	pgtable_free_tlb(tlb, page_address(ptepage), 0);
 }
 
diff -puN arch/powerpc/mm/pgtable_32.c~pass-mm-in-to-pgtable-ctor-dtor arch/powerpc/mm/pgtable_32.c
--- linux-2.6.git/arch/powerpc/mm/pgtable_32.c~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.688833430 -0700
+++ linux-2.6.git-dave/arch/powerpc/mm/pgtable_32.c	2011-04-15 10:37:07.768833403 -0700
@@ -120,7 +120,7 @@ pgtable_t pte_alloc_one(struct mm_struct
 	ptepage = alloc_pages(flags, 0);
 	if (!ptepage)
 		return NULL;
-	pgtable_page_ctor(ptepage);
+	pgtable_page_ctor(mm, ptepage);
 	return ptepage;
 }
 
diff -puN arch/s390/mm/pgtable.c~pass-mm-in-to-pgtable-ctor-dtor arch/s390/mm/pgtable.c
--- linux-2.6.git/arch/s390/mm/pgtable.c~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.692833429 -0700
+++ linux-2.6.git-dave/arch/s390/mm/pgtable.c	2011-04-15 10:37:07.768833403 -0700
@@ -287,7 +287,7 @@ unsigned long *page_table_alloc(struct m
 		page = alloc_page(GFP_KERNEL|__GFP_REPEAT);
 		if (!page)
 			return NULL;
-		pgtable_page_ctor(page);
+		pgtable_page_ctor(mm, page);
 		page->flags &= ~FRAG_MASK;
 		table = (unsigned long *) page_to_phys(page);
 		if (mm->context.has_pgste)
@@ -319,7 +319,7 @@ static void __page_table_free(struct mm_
 	page = pfn_to_page(__pa(table) >> PAGE_SHIFT);
 	page->flags ^= bits;
 	if (!(page->flags & FRAG_MASK)) {
-		pgtable_page_dtor(page);
+		pgtable_page_dtor(mm, page);
 		__free_page(page);
 	}
 }
@@ -344,7 +344,7 @@ void page_table_free(struct mm_struct *m
 		list_del(&page->lru);
 	spin_unlock_bh(&mm->context.list_lock);
 	if (page) {
-		pgtable_page_dtor(page);
+		pgtable_page_dtor(mm, page);
 		__free_page(page);
 	}
 }
diff -puN arch/score/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/score/include/asm/pgalloc.h
--- linux-2.6.git/arch/score/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.696833428 -0700
+++ linux-2.6.git-dave/arch/score/include/asm/pgalloc.h	2011-04-15 10:37:07.772833402 -0700
@@ -56,7 +56,7 @@ static inline struct page *pte_alloc_one
 	pte = alloc_pages(GFP_KERNEL | __GFP_REPEAT, PTE_ORDER);
 	if (pte) {
 		clear_highpage(pte);
-		pgtable_page_ctor(pte);
+		pgtable_page_ctor(mm, pte);
 	}
 	return pte;
 }
@@ -68,13 +68,13 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, page);
 	__free_pages(pte, PTE_ORDER);
 }
 
 #define __pte_free_tlb(tlb, pte, buf)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_page_dtor((tlb)->mm, pte);		\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
diff -puN arch/sh/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/sh/include/asm/pgalloc.h
--- linux-2.6.git/arch/sh/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.700833427 -0700
+++ linux-2.6.git-dave/arch/sh/include/asm/pgalloc.h	2011-04-15 10:37:07.772833402 -0700
@@ -47,7 +47,7 @@ static inline pgtable_t pte_alloc_one(st
 	if (!pg)
 		return NULL;
 	page = virt_to_page(pg);
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 	return page;
 }
 
@@ -58,13 +58,13 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, page);
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
 
 #define __pte_free_tlb(tlb,pte,addr)			\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_page_dtor((tlb)->mm, pte);		\
 	tlb_remove_page((tlb), (pte));			\
 } while (0)
 
diff -puN arch/sparc/include/asm/pgalloc_64.h~pass-mm-in-to-pgtable-ctor-dtor arch/sparc/include/asm/pgalloc_64.h
--- linux-2.6.git/arch/sparc/include/asm/pgalloc_64.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.704833426 -0700
+++ linux-2.6.git-dave/arch/sparc/include/asm/pgalloc_64.h	2011-04-15 10:37:07.772833402 -0700
@@ -52,7 +52,7 @@ static inline pgtable_t pte_alloc_one(st
 	if (!pg)
 		return NULL;
 	page = virt_to_page(pg);
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 	return page;
 }
 
@@ -63,7 +63,7 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
-	pgtable_page_dtor(ptepage);
+	pgtable_page_dtor(mm, ptepage);
 	quicklist_free_page(0, NULL, ptepage);
 }
 
diff -puN arch/sparc/mm/srmmu.c~pass-mm-in-to-pgtable-ctor-dtor arch/sparc/mm/srmmu.c
--- linux-2.6.git/arch/sparc/mm/srmmu.c~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.708833424 -0700
+++ linux-2.6.git-dave/arch/sparc/mm/srmmu.c	2011-04-15 10:37:07.772833402 -0700
@@ -500,7 +500,7 @@ srmmu_pte_alloc_one(struct mm_struct *mm
 	if ((pte = (unsigned long)srmmu_pte_alloc_one_kernel(mm, address)) == 0)
 		return NULL;
 	page = pfn_to_page( __nocache_pa(pte) >> PAGE_SHIFT );
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 	return page;
 }
 
@@ -509,11 +509,11 @@ static void srmmu_free_pte_fast(pte_t *p
 	srmmu_free_nocache((unsigned long)pte, PTE_SIZE);
 }
 
-static void srmmu_pte_free(pgtable_t pte)
+static void srmmu_pte_free(struct mm_struct *mm, pgtable_t pte)
 {
 	unsigned long p;
 
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	p = (unsigned long)page_address(pte);	/* Cached address (for test) */
 	if (p == 0)
 		BUG();
diff -puN arch/sparc/mm/sun4c.c~pass-mm-in-to-pgtable-ctor-dtor arch/sparc/mm/sun4c.c
--- linux-2.6.git/arch/sparc/mm/sun4c.c~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.712833422 -0700
+++ linux-2.6.git-dave/arch/sparc/mm/sun4c.c	2011-04-15 10:37:07.776833401 -0700
@@ -1842,7 +1842,7 @@ static pgtable_t sun4c_pte_alloc_one(str
 	if (pte == NULL)
 		return NULL;
 	page = virt_to_page(pte);
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 	return page;
 }
 
@@ -1853,9 +1853,9 @@ static inline void sun4c_free_pte_fast(p
 	pgtable_cache_size++;
 }
 
-static void sun4c_pte_free(pgtable_t pte)
+static void sun4c_pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	sun4c_free_pte_fast(page_address(pte));
 }
 
diff -puN arch/tile/mm/pgtable.c~pass-mm-in-to-pgtable-ctor-dtor arch/tile/mm/pgtable.c
--- linux-2.6.git/arch/tile/mm/pgtable.c~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.716833420 -0700
+++ linux-2.6.git-dave/arch/tile/mm/pgtable.c	2011-04-15 10:37:07.780833400 -0700
@@ -316,7 +316,7 @@ struct page *pte_alloc_one(struct mm_str
 	}
 #endif
 
-	pgtable_page_ctor(p);
+	pgtable_page_ctor(mm, p);
 	return p;
 }
 
@@ -329,7 +329,7 @@ void pte_free(struct mm_struct *mm, stru
 {
 	int i;
 
-	pgtable_page_dtor(p);
+	pgtable_page_dtor(mm, p);
 	__free_page(p);
 
 	for (i = 1; i < L2_USER_PGTABLE_PAGES; ++i) {
@@ -343,7 +343,7 @@ void __pte_free_tlb(struct mmu_gather *t
 {
 	int i;
 
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(tlb->mm, pte);
 	tlb_remove_page(tlb, pte);
 
 	for (i = 1; i < L2_USER_PGTABLE_PAGES; ++i) {
diff -puN arch/um/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/um/include/asm/pgalloc.h
--- linux-2.6.git/arch/um/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.720833418 -0700
+++ linux-2.6.git-dave/arch/um/include/asm/pgalloc.h	2011-04-15 10:37:07.780833400 -0700
@@ -36,13 +36,13 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	__free_page(pte);
 }
 
 #define __pte_free_tlb(tlb,pte, address)		\
 do {							\
-	pgtable_page_dtor(pte);				\
+	pgtable_page_dtor((tlb)->mm, pte);		\
 	tlb_remove_page((tlb),(pte));			\
 } while (0)
 
diff -puN arch/um/kernel/mem.c~pass-mm-in-to-pgtable-ctor-dtor arch/um/kernel/mem.c
--- linux-2.6.git/arch/um/kernel/mem.c~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.724833416 -0700
+++ linux-2.6.git-dave/arch/um/kernel/mem.c	2011-04-15 10:37:07.780833400 -0700
@@ -298,7 +298,7 @@ pgtable_t pte_alloc_one(struct mm_struct
 
 	pte = alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
 	if (pte)
-		pgtable_page_ctor(pte);
+		pgtable_page_ctor(mm, pte);
 	return pte;
 }
 
diff -puN arch/unicore32/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/unicore32/include/asm/pgalloc.h
--- linux-2.6.git/arch/unicore32/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.728833415 -0700
+++ linux-2.6.git-dave/arch/unicore32/include/asm/pgalloc.h	2011-04-15 10:37:07.780833400 -0700
@@ -56,7 +56,7 @@ pte_alloc_one(struct mm_struct *mm, unsi
 			void *page = page_address(pte);
 			clean_dcache_area(page, PTRS_PER_PTE * sizeof(pte_t));
 		}
-		pgtable_page_ctor(pte);
+		pgtable_page_ctor(mm, pte);
 	}
 
 	return pte;
@@ -73,7 +73,7 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	__free_page(pte);
 }
 
diff -puN arch/unicore32/include/asm/tlb.h~pass-mm-in-to-pgtable-ctor-dtor arch/unicore32/include/asm/tlb.h
--- linux-2.6.git/arch/unicore32/include/asm/tlb.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.732833415 -0700
+++ linux-2.6.git-dave/arch/unicore32/include/asm/tlb.h	2011-04-15 10:37:07.788833398 -0700
@@ -19,7 +19,7 @@
 
 #define __pte_free_tlb(tlb, pte, addr)				\
 	do {							\
-		pgtable_page_dtor(pte);				\
+		pgtable_page_dtor((tlb)->mm, pte);		\
 		tlb_remove_page((tlb), (pte));			\
 	} while (0)
 
diff -puN arch/x86/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/x86/include/asm/pgalloc.h
--- linux-2.6.git/arch/x86/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.736833415 -0700
+++ linux-2.6.git-dave/arch/x86/include/asm/pgalloc.h	2011-04-15 10:37:07.780833400 -0700
@@ -47,7 +47,7 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	__free_page(pte);
 }
 
diff -puN arch/x86/mm/pgtable.c~pass-mm-in-to-pgtable-ctor-dtor arch/x86/mm/pgtable.c
--- linux-2.6.git/arch/x86/mm/pgtable.c~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.740833414 -0700
+++ linux-2.6.git-dave/arch/x86/mm/pgtable.c	2011-04-15 10:37:07.784833399 -0700
@@ -26,7 +26,7 @@ pgtable_t pte_alloc_one(struct mm_struct
 
 	pte = alloc_pages(__userpte_alloc_gfp, 0);
 	if (pte)
-		pgtable_page_ctor(pte);
+		pgtable_page_ctor(mm, pte);
 	return pte;
 }
 
@@ -49,7 +49,7 @@ early_param("userpte", setup_userpte);
 
 void ___pte_free_tlb(struct mmu_gather *tlb, struct page *pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(tlb->mm, pte);
 	paravirt_release_pte(page_to_pfn(pte));
 	tlb_remove_page(tlb, pte);
 }
diff -puN arch/xtensa/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor arch/xtensa/include/asm/pgalloc.h
--- linux-2.6.git/arch/xtensa/include/asm/pgalloc.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.744833412 -0700
+++ linux-2.6.git-dave/arch/xtensa/include/asm/pgalloc.h	2011-04-15 10:37:07.784833399 -0700
@@ -54,7 +54,7 @@ static inline pgtable_t pte_alloc_one(st
 	struct page *page;
 
 	page = virt_to_page(pte_alloc_one_kernel(mm, addr));
-	pgtable_page_ctor(page);
+	pgtable_page_ctor(mm, page);
 	return page;
 }
 
@@ -65,7 +65,7 @@ static inline void pte_free_kernel(struc
 
 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	pgtable_page_dtor(pte);
+	pgtable_page_dtor(mm, pte);
 	kmem_cache_free(pgtable_cache, page_address(pte));
 }
 #define pmd_pgtable(pmd) pmd_page(pmd)
diff -puN include/linux/mm.h~pass-mm-in-to-pgtable-ctor-dtor include/linux/mm.h
--- linux-2.6.git/include/linux/mm.h~pass-mm-in-to-pgtable-ctor-dtor	2011-04-15 10:37:07.748833410 -0700
+++ linux-2.6.git-dave/include/linux/mm.h	2011-04-15 10:37:07.784833399 -0700
@@ -1242,13 +1242,13 @@ static inline pmd_t *pmd_alloc(struct mm
 #define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
 #endif /* USE_SPLIT_PTLOCKS */
 
-static inline void pgtable_page_ctor(struct page *page)
+static inline void pgtable_page_ctor(struct mm_struct *mm, struct page *page)
 {
 	pte_lock_init(page);
 	inc_zone_page_state(page, NR_PAGETABLE);
 }
 
-static inline void pgtable_page_dtor(struct page *page)
+static inline void pgtable_page_dtor(struct mm_struct *mm, struct page *page)
 {
 	pte_lock_deinit(page);
 	dec_zone_page_state(page, NR_PAGETABLE);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
