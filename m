Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7BB126B006C
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 06:44:46 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so907071pdb.11
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 03:44:46 -0700 (PDT)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id zd3si6268484pac.54.2014.10.25.03.44.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Oct 2014 03:44:45 -0700 (PDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 25 Oct 2014 20:44:42 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id D62B42CE8047
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 21:44:39 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9PAiOBx41156670
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 21:44:24 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9PAidea017937
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 21:44:39 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V3 2/2] arch/powerpc: Switch to generic RCU get_user_pages_fast
Date: Sat, 25 Oct 2014 16:14:20 +0530
Message-Id: <1414233860-7683-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1414233860-7683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1414233860-7683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, benh@kernel.crashing.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch switch the ppc arch to use the generic RCU based
gup implementation.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig                     |   1 +
 arch/powerpc/include/asm/hugetlb.h       |   8 +-
 arch/powerpc/include/asm/page.h          |   3 +-
 arch/powerpc/include/asm/pgtable-ppc64.h |   1 -
 arch/powerpc/include/asm/pgtable.h       |   5 -
 arch/powerpc/mm/Makefile                 |   2 +-
 arch/powerpc/mm/gup.c                    | 235 -------------------------------
 arch/powerpc/mm/hugetlbpage.c            |  27 ++--
 8 files changed, 21 insertions(+), 261 deletions(-)
 delete mode 100644 arch/powerpc/mm/gup.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 88eace4..7af887d 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -148,6 +148,7 @@ config PPC
 	select HAVE_ARCH_AUDITSYSCALL
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select DCACHE_WORD_ACCESS if PPC64 && CPU_LITTLE_ENDIAN
+	select HAVE_GENERIC_RCU_GUP
 
 config GENERIC_CSUM
 	def_bool CPU_LITTLE_ENDIAN
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 766b77d..1d53a65 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -48,7 +48,7 @@ static inline unsigned int hugepd_shift(hugepd_t hpd)
 #endif /* CONFIG_PPC_BOOK3S_64 */
 
 
-static inline pte_t *hugepte_offset(hugepd_t *hpdp, unsigned long addr,
+static inline pte_t *hugepte_offset(hugepd_t hpd, unsigned long addr,
 				    unsigned pdshift)
 {
 	/*
@@ -58,9 +58,9 @@ static inline pte_t *hugepte_offset(hugepd_t *hpdp, unsigned long addr,
 	 */
 	unsigned long idx = 0;
 
-	pte_t *dir = hugepd_page(*hpdp);
+	pte_t *dir = hugepd_page(hpd);
 #ifndef CONFIG_PPC_FSL_BOOK3E
-	idx = (addr & ((1UL << pdshift) - 1)) >> hugepd_shift(*hpdp);
+	idx = (addr & ((1UL << pdshift) - 1)) >> hugepd_shift(hpd);
 #endif
 
 	return dir + idx;
@@ -193,7 +193,7 @@ static inline void flush_hugetlb_page(struct vm_area_struct *vma,
 }
 
 #define hugepd_shift(x) 0
-static inline pte_t *hugepte_offset(hugepd_t *hpdp, unsigned long addr,
+static inline pte_t *hugepte_offset(hugepd_t hpd, unsigned long addr,
 				    unsigned pdshift)
 {
 	return 0;
diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index f973fce..69c0598 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -379,13 +379,14 @@ static inline int hugepd_ok(hugepd_t hpd)
 }
 #endif
 
-#define is_hugepd(pdep)               (hugepd_ok(*((hugepd_t *)(pdep))))
+#define is_hugepd(hpd)               (hugepd_ok(hpd))
 #define pgd_huge pgd_huge
 int pgd_huge(pgd_t pgd);
 #else /* CONFIG_HUGETLB_PAGE */
 #define is_hugepd(pdep)			0
 #define pgd_huge(pgd)			0
 #endif /* CONFIG_HUGETLB_PAGE */
+#define __hugepd(x) ((hugepd_t) { (x) })
 
 struct page;
 extern void clear_user_page(void *page, unsigned long vaddr, struct page *pg);
diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index ae153c4..29c3624 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -575,6 +575,5 @@ static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
 	 */
 	return true;
 }
-
 #endif /* __ASSEMBLY__ */
 #endif /* _ASM_POWERPC_PGTABLE_PPC64_H_ */
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 316f9a5..4a67c1d 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -274,11 +274,6 @@ extern void paging_init(void);
  */
 extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t *);
 
-extern int gup_hugepd(hugepd_t *hugepd, unsigned pdshift, unsigned long addr,
-		      unsigned long end, int write, struct page **pages, int *nr);
-
-extern int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
-		       unsigned long end, int write, struct page **pages, int *nr);
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_large(pmd)		0
 #define has_transparent_hugepage() 0
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 325e861..438dcd3 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -6,7 +6,7 @@ subdir-ccflags-$(CONFIG_PPC_WERROR) := -Werror
 
 ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
 
-obj-y				:= fault.o mem.o pgtable.o gup.o mmap.o \
+obj-y				:= fault.o mem.o pgtable.o mmap.o \
 				   init_$(CONFIG_WORD_SIZE).o \
 				   pgtable_$(CONFIG_WORD_SIZE).o
 obj-$(CONFIG_PPC_MMU_NOHASH)	+= mmu_context_nohash.o tlb_nohash.o \
diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
deleted file mode 100644
index d874668..0000000
--- a/arch/powerpc/mm/gup.c
+++ /dev/null
@@ -1,235 +0,0 @@
-/*
- * Lockless get_user_pages_fast for powerpc
- *
- * Copyright (C) 2008 Nick Piggin
- * Copyright (C) 2008 Novell Inc.
- */
-#undef DEBUG
-
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <linux/hugetlb.h>
-#include <linux/vmstat.h>
-#include <linux/pagemap.h>
-#include <linux/rwsem.h>
-#include <asm/pgtable.h>
-
-#ifdef __HAVE_ARCH_PTE_SPECIAL
-
-/*
- * The performance critical leaf functions are made noinline otherwise gcc
- * inlines everything into a single function which results in too much
- * register pressure.
- */
-static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
-{
-	unsigned long mask, result;
-	pte_t *ptep;
-
-	result = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		result |= _PAGE_RW;
-	mask = result | _PAGE_SPECIAL;
-
-	ptep = pte_offset_kernel(&pmd, addr);
-	do {
-		pte_t pte = ACCESS_ONCE(*ptep);
-		struct page *page;
-		/*
-		 * Similar to the PMD case, NUMA hinting must take slow path
-		 */
-		if (pte_numa(pte))
-			return 0;
-
-		if ((pte_val(pte) & mask) != result)
-			return 0;
-		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-		page = pte_page(pte);
-		if (!page_cache_get_speculative(page))
-			return 0;
-		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
-			put_page(page);
-			return 0;
-		}
-		pages[*nr] = page;
-		(*nr)++;
-
-	} while (ptep++, addr += PAGE_SIZE, addr != end);
-
-	return 1;
-}
-
-static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
-		int write, struct page **pages, int *nr)
-{
-	unsigned long next;
-	pmd_t *pmdp;
-
-	pmdp = pmd_offset(&pud, addr);
-	do {
-		pmd_t pmd = ACCESS_ONCE(*pmdp);
-
-		next = pmd_addr_end(addr, end);
-		/*
-		 * If we find a splitting transparent hugepage we
-		 * return zero. That will result in taking the slow
-		 * path which will call wait_split_huge_page()
-		 * if the pmd is still in splitting state
-		 */
-		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
-			return 0;
-		if (pmd_huge(pmd) || pmd_large(pmd)) {
-			/*
-			 * NUMA hinting faults need to be handled in the GUP
-			 * slowpath for accounting purposes and so that they
-			 * can be serialised against THP migration.
-			 */
-			if (pmd_numa(pmd))
-				return 0;
-
-			if (!gup_hugepte((pte_t *)pmdp, PMD_SIZE, addr, next,
-					 write, pages, nr))
-				return 0;
-		} else if (is_hugepd(pmdp)) {
-			if (!gup_hugepd((hugepd_t *)pmdp, PMD_SHIFT,
-					addr, next, write, pages, nr))
-				return 0;
-		} else if (!gup_pte_range(pmd, addr, next, write, pages, nr))
-			return 0;
-	} while (pmdp++, addr = next, addr != end);
-
-	return 1;
-}
-
-static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
-		int write, struct page **pages, int *nr)
-{
-	unsigned long next;
-	pud_t *pudp;
-
-	pudp = pud_offset(&pgd, addr);
-	do {
-		pud_t pud = ACCESS_ONCE(*pudp);
-
-		next = pud_addr_end(addr, end);
-		if (pud_none(pud))
-			return 0;
-		if (pud_huge(pud)) {
-			if (!gup_hugepte((pte_t *)pudp, PUD_SIZE, addr, next,
-					 write, pages, nr))
-				return 0;
-		} else if (is_hugepd(pudp)) {
-			if (!gup_hugepd((hugepd_t *)pudp, PUD_SHIFT,
-					addr, next, write, pages, nr))
-				return 0;
-		} else if (!gup_pmd_range(pud, addr, next, write, pages, nr))
-			return 0;
-	} while (pudp++, addr = next, addr != end);
-
-	return 1;
-}
-
-int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			  struct page **pages)
-{
-	struct mm_struct *mm = current->mm;
-	unsigned long addr, len, end;
-	unsigned long next;
-	unsigned long flags;
-	pgd_t *pgdp;
-	int nr = 0;
-
-	pr_devel("%s(%lx,%x,%s)\n", __func__, start, nr_pages, write ? "write" : "read");
-
-	start &= PAGE_MASK;
-	addr = start;
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-
-	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
-					start, len)))
-		return 0;
-
-	pr_devel("  aligned: %lx .. %lx\n", start, end);
-
-	/*
-	 * XXX: batch / limit 'nr', to avoid large irq off latency
-	 * needs some instrumenting to determine the common sizes used by
-	 * important workloads (eg. DB2), and whether limiting the batch size
-	 * will decrease performance.
-	 *
-	 * It seems like we're in the clear for the moment. Direct-IO is
-	 * the main guy that batches up lots of get_user_pages, and even
-	 * they are limited to 64-at-a-time which is not so many.
-	 */
-	/*
-	 * This doesn't prevent pagetable teardown, but does prevent
-	 * the pagetables from being freed on powerpc.
-	 *
-	 * So long as we atomically load page table pointers versus teardown,
-	 * we can follow the address down to the the page and take a ref on it.
-	 */
-	local_irq_save(flags);
-
-	pgdp = pgd_offset(mm, addr);
-	do {
-		pgd_t pgd = ACCESS_ONCE(*pgdp);
-
-		pr_devel("  %016lx: normal pgd %p\n", addr,
-			 (void *)pgd_val(pgd));
-		next = pgd_addr_end(addr, end);
-		if (pgd_none(pgd))
-			break;
-		if (pgd_huge(pgd)) {
-			if (!gup_hugepte((pte_t *)pgdp, PGDIR_SIZE, addr, next,
-					 write, pages, &nr))
-				break;
-		} else if (is_hugepd(pgdp)) {
-			if (!gup_hugepd((hugepd_t *)pgdp, PGDIR_SHIFT,
-					addr, next, write, pages, &nr))
-				break;
-		} else if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
-			break;
-	} while (pgdp++, addr = next, addr != end);
-
-	local_irq_restore(flags);
-
-	return nr;
-}
-
-int get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			struct page **pages)
-{
-	struct mm_struct *mm = current->mm;
-	int nr, ret;
-
-	start &= PAGE_MASK;
-	nr = __get_user_pages_fast(start, nr_pages, write, pages);
-	ret = nr;
-
-	if (nr < nr_pages) {
-		pr_devel("  slow path ! nr = %d\n", nr);
-
-		/* Try to get the remaining pages with get_user_pages */
-		start += nr << PAGE_SHIFT;
-		pages += nr;
-
-		down_read(&mm->mmap_sem);
-		ret = get_user_pages(current, mm, start,
-				     nr_pages - nr, write, 0, pages, NULL);
-		up_read(&mm->mmap_sem);
-
-		/* Have to be a bit careful with return values */
-		if (nr > 0) {
-			if (ret < 0)
-				ret = nr;
-			else
-				ret += nr;
-		}
-	}
-
-	return ret;
-}
-
-#endif /* __HAVE_ARCH_PTE_SPECIAL */
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 7e70ae9..03342df 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -230,7 +230,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
 	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr, pdshift, pshift))
 		return NULL;
 
-	return hugepte_offset(hpdp, addr, pdshift);
+	return hugepte_offset(*hpdp, addr, pdshift);
 }
 
 #else
@@ -270,7 +270,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
 	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr, pdshift, pshift))
 		return NULL;
 
-	return hugepte_offset(hpdp, addr, pdshift);
+	return hugepte_offset(*hpdp, addr, pdshift);
 }
 #endif
 
@@ -538,7 +538,7 @@ static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
 	do {
 		pmd = pmd_offset(pud, addr);
 		next = pmd_addr_end(addr, end);
-		if (!is_hugepd(pmd)) {
+		if (!is_hugepd(__hugepd(pmd_val(*pmd)))) {
 			/*
 			 * if it is not hugepd pointer, we should already find
 			 * it cleared.
@@ -587,7 +587,7 @@ static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 	do {
 		pud = pud_offset(pgd, addr);
 		next = pud_addr_end(addr, end);
-		if (!is_hugepd(pud)) {
+		if (!is_hugepd(__hugepd(pud_val(*pud)))) {
 			if (pud_none_or_clear_bad(pud))
 				continue;
 			hugetlb_free_pmd_range(tlb, pud, addr, next, floor,
@@ -653,7 +653,7 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 	do {
 		next = pgd_addr_end(addr, end);
 		pgd = pgd_offset(tlb->mm, addr);
-		if (!is_hugepd(pgd)) {
+		if (!is_hugepd(__hugepd(pgd_val(*pgd)))) {
 			if (pgd_none_or_clear_bad(pgd))
 				continue;
 			hugetlb_free_pud_range(tlb, pgd, addr, next, floor, ceiling);
@@ -713,18 +713,17 @@ static unsigned long hugepte_addr_end(unsigned long addr, unsigned long end,
 	return (__boundary - 1 < end - 1) ? __boundary : end;
 }
 
-int gup_hugepd(hugepd_t *hugepd, unsigned pdshift,
-	       unsigned long addr, unsigned long end,
-	       int write, struct page **pages, int *nr)
+int gup_huge_pd(hugepd_t hugepd, unsigned long addr, unsigned pdshift,
+		unsigned long end, int write, struct page **pages, int *nr)
 {
 	pte_t *ptep;
-	unsigned long sz = 1UL << hugepd_shift(*hugepd);
+	unsigned long sz = 1UL << hugepd_shift(hugepd);
 	unsigned long next;
 
 	ptep = hugepte_offset(hugepd, addr, pdshift);
 	do {
 		next = hugepte_addr_end(addr, end, sz);
-		if (!gup_hugepte(ptep, sz, addr, end, write, pages, nr))
+		if (!gup_huge_pte(*ptep, ptep, addr, sz, end, write, pages, nr))
 			return 0;
 	} while (ptep++, addr = next, addr != end);
 
@@ -961,7 +960,7 @@ pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift
 	else if (pgd_huge(pgd)) {
 		ret_pte = (pte_t *) pgdp;
 		goto out;
-	} else if (is_hugepd(&pgd))
+	} else if (is_hugepd(__hugepd(pgd_val(pgd))))
 		hpdp = (hugepd_t *)&pgd;
 	else {
 		/*
@@ -978,7 +977,7 @@ pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift
 		else if (pud_huge(pud)) {
 			ret_pte = (pte_t *) pudp;
 			goto out;
-		} else if (is_hugepd(&pud))
+		} else if (is_hugepd(__hugepd(pud_val(pud))))
 			hpdp = (hugepd_t *)&pud;
 		else {
 			pdshift = PMD_SHIFT;
@@ -999,7 +998,7 @@ pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift
 			if (pmd_huge(pmd) || pmd_large(pmd)) {
 				ret_pte = (pte_t *) pmdp;
 				goto out;
-			} else if (is_hugepd(&pmd))
+			} else if (is_hugepd(__hugepd(pmd_val(pmd))))
 				hpdp = (hugepd_t *)&pmd;
 			else
 				return pte_offset_kernel(&pmd, ea);
@@ -1008,7 +1007,7 @@ pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift
 	if (!hpdp)
 		return NULL;
 
-	ret_pte = hugepte_offset(hpdp, ea, pdshift);
+	ret_pte = hugepte_offset(*hpdp, ea, pdshift);
 	pdshift = hugepd_shift(*hpdp);
 out:
 	if (shift)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
