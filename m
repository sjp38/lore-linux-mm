Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id AA4076B0081
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:52:03 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:15:46 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 8D522394002D
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:21:59 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJpqUh12976616
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:21:52 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJpw57002310
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:51:58 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 03/10] powerpc: move find_linux_pte_or_hugepte and gup_hugepte to common code
Date: Mon, 29 Apr 2013 01:21:44 +0530
Message-Id: <1367178711-8232-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will use this in the later patch for handling THP pages

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/hugetlb.h       |   8 +-
 arch/powerpc/include/asm/pgtable-ppc64.h |  11 --
 arch/powerpc/mm/Makefile                 |   2 +-
 arch/powerpc/mm/hugetlbpage.c            | 251 ++++++++++++++++---------------
 4 files changed, 136 insertions(+), 136 deletions(-)

diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 4daf7e6..91aba46 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -190,8 +190,14 @@ static inline void flush_hugetlb_page(struct vm_area_struct *vma,
 				      unsigned long vmaddr)
 {
 }
-#endif /* CONFIG_HUGETLB_PAGE */
 
+#define hugepd_shift(x) 0
+static inline pte_t *hugepte_offset(hugepd_t *hpdp, unsigned long addr,
+				    unsigned pdshift)
+{
+	return 0;
+}
+#endif /* CONFIG_HUGETLB_PAGE */
 
 /*
  * FSL Book3E platforms require special gpage handling - the gpages
diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 20133c1..f0effab 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -367,19 +367,8 @@ static inline pte_t *find_linux_pte(pgd_t *pgdir, unsigned long ea)
 	return pt;
 }
 
-#ifdef CONFIG_HUGETLB_PAGE
 pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
 				 unsigned *shift);
-#else
-static inline pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
-					       unsigned *shift)
-{
-	if (shift)
-		*shift = 0;
-	return find_linux_pte(pgdir, ea);
-}
-#endif /* !CONFIG_HUGETLB_PAGE */
-
 #endif /* __ASSEMBLY__ */
 
 #ifndef _PAGE_SPLITTING
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index cf16b57..fde36e6 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -28,8 +28,8 @@ obj-$(CONFIG_44x)		+= 44x_mmu.o
 obj-$(CONFIG_PPC_FSL_BOOK3E)	+= fsl_booke_mmu.o
 obj-$(CONFIG_NEED_MULTIPLE_NODES) += numa.o
 obj-$(CONFIG_PPC_MM_SLICES)	+= slice.o
-ifeq ($(CONFIG_HUGETLB_PAGE),y)
 obj-y				+= hugetlbpage.o
+ifeq ($(CONFIG_HUGETLB_PAGE),y)
 obj-$(CONFIG_PPC_STD_MMU_64)	+= hugetlbpage-hash64.o
 obj-$(CONFIG_PPC_BOOK3E_MMU)	+= hugetlbpage-book3e.o
 endif
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index fbe6be7..8601f2d 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -21,6 +21,9 @@
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
 #include <asm/setup.h>
+#include <asm/hugetlb.h>
+
+#ifdef CONFIG_HUGETLB_PAGE
 
 #define PAGE_SHIFT_64K	16
 #define PAGE_SHIFT_16M	24
@@ -100,66 +103,6 @@ int pgd_huge(pgd_t pgd)
 }
 #endif
 
-/*
- * We have 4 cases for pgds and pmds:
- * (1) invalid (all zeroes)
- * (2) pointer to next table, as normal; bottom 6 bits == 0
- * (3) leaf pte for huge page, bottom two bits != 00
- * (4) hugepd pointer, bottom two bits == 00, next 4 bits indicate size of table
- */
-pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift)
-{
-	pgd_t *pg;
-	pud_t *pu;
-	pmd_t *pm;
-	pte_t *ret_pte;
-	hugepd_t *hpdp = NULL;
-	unsigned pdshift = PGDIR_SHIFT;
-
-	if (shift)
-		*shift = 0;
-
-	pg = pgdir + pgd_index(ea);
-
-	if (pgd_huge(*pg)) {
-		ret_pte = (pte_t *) pg;
-		goto out;
-	} else if (is_hugepd(pg))
-		hpdp = (hugepd_t *)pg;
-	else if (!pgd_none(*pg)) {
-		pdshift = PUD_SHIFT;
-		pu = pud_offset(pg, ea);
-
-		if (pud_huge(*pu)) {
-			ret_pte = (pte_t *) pu;
-			goto out;
-		} else if (is_hugepd(pu))
-			hpdp = (hugepd_t *)pu;
-		else if (!pud_none(*pu)) {
-			pdshift = PMD_SHIFT;
-			pm = pmd_offset(pu, ea);
-
-			if (pmd_huge(*pm)) {
-				ret_pte = (pte_t *) pm;
-				goto out;
-			} else if (is_hugepd(pm))
-				hpdp = (hugepd_t *)pm;
-			else if (!pmd_none(*pm))
-				return pte_offset_kernel(pm, ea);
-		}
-	}
-	if (!hpdp)
-		return NULL;
-
-	ret_pte = hugepte_offset(hpdp, ea, pdshift);
-	pdshift = hugepd_shift(*hpdp);
-out:
-	if (shift)
-		*shift = pdshift;
-	return ret_pte;
-}
-EXPORT_SYMBOL_GPL(find_linux_pte_or_hugepte);
-
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 {
 	return find_linux_pte_or_hugepte(mm->pgd, addr, NULL);
@@ -753,69 +696,6 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 	return NULL;
 }
 
-int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
-{
-	unsigned long mask;
-	unsigned long pte_end;
-	struct page *head, *page, *tail;
-	pte_t pte;
-	int refs;
-
-	pte_end = (addr + sz) & ~(sz-1);
-	if (pte_end < end)
-		end = pte_end;
-
-	pte = *ptep;
-	mask = _PAGE_PRESENT | _PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
-
-	if ((pte_val(pte) & mask) != mask)
-		return 0;
-
-	/* hugepages are never "special" */
-	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-
-	refs = 0;
-	head = pte_page(pte);
-
-	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
-	tail = page;
-	do {
-		VM_BUG_ON(compound_head(page) != head);
-		pages[*nr] = page;
-		(*nr)++;
-		page++;
-		refs++;
-	} while (addr += PAGE_SIZE, addr != end);
-
-	if (!page_cache_add_speculative(head, refs)) {
-		*nr -= refs;
-		return 0;
-	}
-
-	if (unlikely(pte_val(pte) != pte_val(*ptep))) {
-		/* Could be optimized better */
-		*nr -= refs;
-		while (refs--)
-			put_page(head);
-		return 0;
-	}
-
-	/*
-	 * Any tail page need their mapcount reference taken before we
-	 * return.
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
 static unsigned long hugepte_addr_end(unsigned long addr, unsigned long end,
 				      unsigned long sz)
 {
@@ -1032,3 +912,128 @@ void flush_dcache_icache_hugepage(struct page *page)
 		}
 	}
 }
+
+#endif /* CONFIG_HUGETLB_PAGE */
+
+/*
+ * We have 4 cases for pgds and pmds:
+ * (1) invalid (all zeroes)
+ * (2) pointer to next table, as normal; bottom 6 bits == 0
+ * (3) leaf pte for huge page, bottom two bits != 00
+ * (4) hugepd pointer, bottom two bits == 00, next 4 bits indicate size of table
+ */
+pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift)
+{
+	pgd_t *pg;
+	pud_t *pu;
+	pmd_t *pm;
+	pte_t *ret_pte;
+	hugepd_t *hpdp = NULL;
+	unsigned pdshift = PGDIR_SHIFT;
+
+	if (shift)
+		*shift = 0;
+
+	pg = pgdir + pgd_index(ea);
+
+	if (pgd_huge(*pg)) {
+		ret_pte = (pte_t *) pg;
+		goto out;
+	} else if (is_hugepd(pg))
+		hpdp = (hugepd_t *)pg;
+	else if (!pgd_none(*pg)) {
+		pdshift = PUD_SHIFT;
+		pu = pud_offset(pg, ea);
+
+		if (pud_huge(*pu)) {
+			ret_pte = (pte_t *) pu;
+			goto out;
+		} else if (is_hugepd(pu))
+			hpdp = (hugepd_t *)pu;
+		else if (!pud_none(*pu)) {
+			pdshift = PMD_SHIFT;
+			pm = pmd_offset(pu, ea);
+
+			if (pmd_huge(*pm)) {
+				ret_pte = (pte_t *) pm;
+				goto out;
+			} else if (is_hugepd(pm))
+				hpdp = (hugepd_t *)pm;
+			else if (!pmd_none(*pm))
+				return pte_offset_kernel(pm, ea);
+		}
+	}
+	if (!hpdp)
+		return NULL;
+
+	ret_pte = hugepte_offset(hpdp, ea, pdshift);
+	pdshift = hugepd_shift(*hpdp);
+out:
+	if (shift)
+		*shift = pdshift;
+	return ret_pte;
+}
+EXPORT_SYMBOL_GPL(find_linux_pte_or_hugepte);
+
+int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
+		unsigned long end, int write, struct page **pages, int *nr)
+{
+	unsigned long mask;
+	unsigned long pte_end;
+	struct page *head, *page, *tail;
+	pte_t pte;
+	int refs;
+
+	pte_end = (addr + sz) & ~(sz-1);
+	if (pte_end < end)
+		end = pte_end;
+
+	pte = *ptep;
+	mask = _PAGE_PRESENT | _PAGE_USER;
+	if (write)
+		mask |= _PAGE_RW;
+
+	if ((pte_val(pte) & mask) != mask)
+		return 0;
+
+	/* hugepages are never "special" */
+	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+
+	refs = 0;
+	head = pte_page(pte);
+
+	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
+	tail = page;
+	do {
+		VM_BUG_ON(compound_head(page) != head);
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (addr += PAGE_SIZE, addr != end);
+
+	if (!page_cache_add_speculative(head, refs)) {
+		*nr -= refs;
+		return 0;
+	}
+
+	if (unlikely(pte_val(pte) != pte_val(*ptep))) {
+		/* Could be optimized better */
+		*nr -= refs;
+		while (refs--)
+			put_page(head);
+		return 0;
+	}
+
+	/*
+	 * Any tail page need their mapcount reference taken before we
+	 * return.
+	 */
+	while (refs--) {
+		if (PageTail(tail))
+			get_huge_page_tail(tail);
+		tail++;
+	}
+
+	return 1;
+}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
