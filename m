Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 26C192803D0
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 06:44:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k10so108285201pgs.11
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 03:44:38 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q15si4472920pgr.71.2017.08.22.03.44.36
        for <linux-mm@kvack.org>;
        Tue, 22 Aug 2017 03:44:37 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v7 6/9] arm64: hugetlb: Override huge_pte_clear() to support contiguous hugepages
Date: Tue, 22 Aug 2017 11:42:46 +0100
Message-Id: <20170822104249.2189-7-punit.agrawal@arm.com>
In-Reply-To: <20170822104249.2189-1-punit.agrawal@arm.com>
References: <20170822104249.2189-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, steve.capper@arm.com, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>

The default huge_pte_clear() implementation does not clear contiguous
page table entries when it encounters contiguous hugepages that are
supported on arm64.

Fix this by overriding the default implementation to clear all the
entries associated with contiguous hugepages.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: David Woods <dwoods@mellanox.com>
---
 arch/arm64/include/asm/hugetlb.h |  6 +++++-
 arch/arm64/mm/hugetlbpage.c      | 38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index 793bd73b0d07..df8c0aea0917 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -18,7 +18,6 @@
 #ifndef __ASM_HUGETLB_H
 #define __ASM_HUGETLB_H
 
-#include <asm-generic/hugetlb.h>
 #include <asm/page.h>
 
 static inline pte_t huge_ptep_get(pte_t *ptep)
@@ -82,6 +81,11 @@ extern void huge_ptep_set_wrprotect(struct mm_struct *mm,
 				    unsigned long addr, pte_t *ptep);
 extern void huge_ptep_clear_flush(struct vm_area_struct *vma,
 				  unsigned long addr, pte_t *ptep);
+extern void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
+			   pte_t *ptep, unsigned long sz);
+#define huge_pte_clear huge_pte_clear
+
+#include <asm-generic/hugetlb.h>
 
 #ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
 static inline bool gigantic_page_supported(void) { return true; }
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index b95e24dc3477..13acc9b47f51 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -68,6 +68,32 @@ static int find_num_contig(struct mm_struct *mm, unsigned long addr,
 	return CONT_PTES;
 }
 
+static inline int num_contig_ptes(unsigned long size, size_t *pgsize)
+{
+	int contig_ptes = 0;
+
+	*pgsize = size;
+
+	switch (size) {
+#ifdef CONFIG_ARM64_4K_PAGES
+	case PUD_SIZE:
+#endif
+	case PMD_SIZE:
+		contig_ptes = 1;
+		break;
+	case CONT_PMD_SIZE:
+		*pgsize = PMD_SIZE;
+		contig_ptes = CONT_PMDS;
+		break;
+	case CONT_PTE_SIZE:
+		*pgsize = PAGE_SIZE;
+		contig_ptes = CONT_PTES;
+		break;
+	}
+
+	return contig_ptes;
+}
+
 /*
  * Changing some bits of contiguous entries requires us to follow a
  * Break-Before-Make approach, breaking the whole contiguous set
@@ -264,6 +290,18 @@ pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 	return entry;
 }
 
+void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
+		    pte_t *ptep, unsigned long sz)
+{
+	int i, ncontig;
+	size_t pgsize;
+
+	ncontig = num_contig_ptes(sz, &pgsize);
+
+	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++)
+		pte_clear(mm, addr, ptep);
+}
+
 pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 			      unsigned long addr, pte_t *ptep)
 {
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
