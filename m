Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 730FB6B0069
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 06:44:43 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so2853709pdi.30
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 03:44:43 -0700 (PDT)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id xn3si6190736pab.146.2014.10.25.03.44.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Oct 2014 03:44:42 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 25 Oct 2014 20:44:38 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 200B8357804C
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 21:44:36 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9PAkZ7E34865196
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 21:46:35 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9PAiZqX017908
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 21:44:35 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V3 1/2] mm: Update generic gup implementation to handle hugepage directory
Date: Sat, 25 Oct 2014 16:14:19 +0530
Message-Id: <1414233860-7683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, benh@kernel.crashing.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Update generic gup implementation with powerpc specific details.
On powerpc at pmd level we can have hugepte, normal pmd pointer
or a pointer to the hugepage directory.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
Changes from V3:
* Explain pgd_huge, also move the definition to linux/hugetlb.h.
  Both pgd_huge and is_hugepd are related to hugepages and hugetlb.h
  is the right header

 arch/arm/include/asm/pgtable.h   |   2 +
 arch/arm64/include/asm/pgtable.h |   2 +
 arch/powerpc/include/asm/page.h  |   1 +
 include/linux/hugetlb.h          |  30 +++++++++++
 include/linux/mm.h               |   7 +++
 mm/gup.c                         | 113 +++++++++++++++++++--------------------
 6 files changed, 96 insertions(+), 59 deletions(-)

diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index 3b30062..c52d261 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -181,6 +181,8 @@ extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 /* to find an entry in a kernel page-table-directory */
 #define pgd_offset_k(addr)	pgd_offset(&init_mm, addr)
 
+#define pgd_huge(pgd)		(0)
+
 #define pmd_none(pmd)		(!pmd_val(pmd))
 #define pmd_present(pmd)	(pmd_val(pmd))
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 41a43bf..f532a14 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -464,6 +464,8 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 extern pgd_t idmap_pg_dir[PTRS_PER_PGD];
 
+#define pgd_huge(pgd)		(0)
+
 /*
  * Encode and decode a swap entry:
  *	bits 0-1:	present (must be zero)
diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index 26fe1ae..f973fce 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -380,6 +380,7 @@ static inline int hugepd_ok(hugepd_t hpd)
 #endif
 
 #define is_hugepd(pdep)               (hugepd_ok(*((hugepd_t *)(pdep))))
+#define pgd_huge pgd_huge
 int pgd_huge(pgd_t pgd);
 #else /* CONFIG_HUGETLB_PAGE */
 #define is_hugepd(pdep)			0
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6e6d338..de63dbc 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -175,6 +175,36 @@ static inline void __unmap_hugepage_range(struct mmu_gather *tlb,
 }
 
 #endif /* !CONFIG_HUGETLB_PAGE */
+/*
+ * hugepages at page global directory. If arch support
+ * hugepages at pgd level, they need to define this.
+ */
+#ifndef pgd_huge
+#define pgd_huge(x)	0
+#endif
+
+#ifndef is_hugepd
+/*
+ * Some architectures requires a hugepage directory format that is
+ * required to support multiple hugepage sizes. For example
+ * a4fe3ce7699bfe1bd88f816b55d42d8fe1dac655 introduced the same
+ * on powerpc. This allows for a more flexible hugepage pagetable
+ * layout.
+ */
+typedef struct { unsigned long pd; } hugepd_t;
+#define is_hugepd(hugepd) (0)
+#define __hugepd(x) ((hugepd_t) { (x) })
+static inline int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
+			      unsigned pdshift, unsigned long end,
+			      int write, struct page **pages, int *nr)
+{
+	return 0;
+}
+#else
+extern int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
+		       unsigned pdshift, unsigned long end,
+		       int write, struct page **pages, int *nr);
+#endif
 
 #define HUGETLB_ANON_FILE "anon_hugepage"
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 02d11ee..31d7fac 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1219,6 +1219,13 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		    struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
+
+#ifdef CONFIG_HAVE_GENERIC_RCU_GUP
+extern int gup_huge_pte(pte_t orig, pte_t *ptep, unsigned long addr,
+			unsigned long sz, unsigned long end, int write,
+			struct page **pages, int *nr);
+#endif
+
 struct kvec;
 int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
 			struct page **pages);
diff --git a/mm/gup.c b/mm/gup.c
index cd62c8c..30773f3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -786,65 +786,31 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 }
 #endif /* __HAVE_ARCH_PTE_SPECIAL */
 
-static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
+int gup_huge_pte(pte_t orig, pte_t *ptep, unsigned long addr,
+		 unsigned long sz, unsigned long end, int write,
+		 struct page **pages, int *nr)
 {
-	struct page *head, *page, *tail;
 	int refs;
+	unsigned long pte_end;
+	struct page *head, *page, *tail;
 
-	if (write && !pmd_write(orig))
-		return 0;
-
-	refs = 0;
-	head = pmd_page(orig);
-	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	tail = page;
-	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
-		pages[*nr] = page;
-		(*nr)++;
-		page++;
-		refs++;
-	} while (addr += PAGE_SIZE, addr != end);
 
-	if (!page_cache_add_speculative(head, refs)) {
-		*nr -= refs;
+	if (write && !pte_write(orig))
 		return 0;
-	}
 
-	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
-		*nr -= refs;
-		while (refs--)
-			put_page(head);
+	if (!pte_present(orig))
 		return 0;
-	}
 
-	/*
-	 * Any tail pages need their mapcount reference taken before we
-	 * return. (This allows the THP code to bump their ref count when
-	 * they are split into base pages).
-	 */
-	while (refs--) {
-		if (PageTail(tail))
-			get_huge_page_tail(tail);
-		tail++;
-	}
-
-	return 1;
-}
-
-static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
-{
-	struct page *head, *page, *tail;
-	int refs;
+	pte_end = (addr + sz) & ~(sz-1);
+	if (pte_end < end)
+		end = pte_end;
 
-	if (write && !pud_write(orig))
-		return 0;
+	/* hugepages are never "special" */
+	VM_BUG_ON(!pfn_valid(pte_pfn(orig)));
 
 	refs = 0;
-	head = pud_page(orig);
-	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+	head = pte_page(orig);
+	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
 	tail = page;
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
@@ -859,13 +825,18 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		return 0;
 	}
 
-	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
+	if (unlikely(pte_val(orig) != pte_val(*ptep))) {
 		*nr -= refs;
 		while (refs--)
 			put_page(head);
 		return 0;
 	}
 
+	/*
+	 * Any tail pages need their mapcount reference taken before we
+	 * return. (This allows the THP code to bump their ref count when
+	 * they are split into base pages).
+	 */
 	while (refs--) {
 		if (PageTail(tail))
 			get_huge_page_tail(tail);
@@ -898,10 +869,19 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			if (pmd_numa(pmd))
 				return 0;
 
-			if (!gup_huge_pmd(pmd, pmdp, addr, next, write,
-				pages, nr))
+			if (!gup_huge_pte(__pte(pmd_val(pmd)), (pte_t *)pmdp,
+					  addr, PMD_SIZE, next,
+					  write, pages, nr))
 				return 0;
 
+		} else if (unlikely(is_hugepd(__hugepd(pmd_val(pmd))))) {
+			/*
+			 * architecture have different format for hugetlbfs
+			 * pmd format and THP pmd format
+			 */
+			if (!gup_huge_pd(__hugepd(pmd_val(pmd)), addr,
+					 PMD_SHIFT, next, write, pages, nr))
+				return 0;
 		} else if (!gup_pte_range(pmd, addr, next, write, pages, nr))
 				return 0;
 	} while (pmdp++, addr = next, addr != end);
@@ -909,22 +889,27 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 	return 1;
 }
 
-static int gup_pud_range(pgd_t *pgdp, unsigned long addr, unsigned long end,
+static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
 		int write, struct page **pages, int *nr)
 {
 	unsigned long next;
 	pud_t *pudp;
 
-	pudp = pud_offset(pgdp, addr);
+	pudp = pud_offset(&pgd, addr);
 	do {
 		pud_t pud = ACCESS_ONCE(*pudp);
 
 		next = pud_addr_end(addr, end);
 		if (pud_none(pud))
 			return 0;
-		if (pud_huge(pud)) {
-			if (!gup_huge_pud(pud, pudp, addr, next, write,
-					pages, nr))
+		if (unlikely(pud_huge(pud))) {
+			if (!gup_huge_pte(__pte(pud_val(pud)), (pte_t *)pudp,
+					  addr, PUD_SIZE, next,
+					  write, pages, nr))
+				return 0;
+		} else if (unlikely(is_hugepd(__hugepd(pud_val(pud))))) {
+			if (!gup_huge_pd(__hugepd(pud_val(pud)), addr,
+					 PUD_SHIFT, next, write, pages, nr))
 				return 0;
 		} else if (!gup_pmd_range(pud, addr, next, write, pages, nr))
 			return 0;
@@ -970,10 +955,21 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	local_irq_save(flags);
 	pgdp = pgd_offset(mm, addr);
 	do {
+		pgd_t pgd = ACCESS_ONCE(*pgdp);
+
 		next = pgd_addr_end(addr, end);
-		if (pgd_none(*pgdp))
+		if (pgd_none(pgd))
 			break;
-		else if (!gup_pud_range(pgdp, addr, next, write, pages, &nr))
+		if (unlikely(pgd_huge(pgd))) {
+			if (!gup_huge_pte(__pte(pgd_val(pgd)), (pte_t *)pgdp,
+					  addr, PGDIR_SIZE, next,
+					  write, pages, &nr))
+				break;
+		} else if (unlikely(is_hugepd(__hugepd(pgd_val(pgd))))) {
+			if (!gup_huge_pd(__hugepd(pgd_val(pgd)), addr,
+					 PGDIR_SHIFT, next, write, pages, &nr))
+				break;
+		} else if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
 			break;
 	} while (pgdp++, addr = next, addr != end);
 	local_irq_restore(flags);
@@ -1028,5 +1024,4 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	return ret;
 }
-
 #endif /* CONFIG_HAVE_GENERIC_RCU_GUP */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
