Message-Id: <20080423015431.239900000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
Date: Wed, 23 Apr 2008 11:53:17 +1000
From: npiggin@suse.de
Subject: [patch 15/18] hugetlb: introduce huge_pud
Content-Disposition: inline; filename=hugetlbfs-huge_pud.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Straight forward extensions for huge pages located in the PUD
instead of PMDs.

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 arch/ia64/mm/hugetlbpage.c    |    6 ++++++
 arch/powerpc/mm/hugetlbpage.c |    5 +++++
 arch/sh/mm/hugetlbpage.c      |    5 +++++
 arch/sparc64/mm/hugetlbpage.c |    5 +++++
 arch/x86/mm/hugetlbpage.c     |   25 ++++++++++++++++++++++++-
 include/linux/hugetlb.h       |    5 +++++
 mm/hugetlb.c                  |    9 +++++++++
 mm/memory.c                   |   10 +++++++++-
 8 files changed, 68 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h
+++ linux-2.6/include/linux/hugetlb.h
@@ -45,7 +45,10 @@ struct page *follow_huge_addr(struct mm_
 			      int write);
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 				pmd_t *pmd, int write);
+struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
+				pud_t *pud, int write);
 int pmd_huge(pmd_t pmd);
+int pud_huge(pud_t pmd);
 void hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot);
 
@@ -112,8 +115,10 @@ static inline unsigned long hugetlb_tota
 #define hugetlb_report_meminfo(buf)		0
 #define hugetlb_report_node_meminfo(n, buf)	0
 #define follow_huge_pmd(mm, addr, pmd, write)	NULL
+#define follow_huge_pud(mm, addr, pud, write)	NULL
 #define prepare_hugepage_range(addr,len)	(-EINVAL)
 #define pmd_huge(x)	0
+#define pud_huge(x)	0
 #define is_hugepage_only_range(mm, addr, len)	0
 #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
 #define hugetlb_fault(mm, vma, addr, write)	({ BUG(); 0; })
Index: linux-2.6/arch/ia64/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/ia64/mm/hugetlbpage.c
+++ linux-2.6/arch/ia64/mm/hugetlbpage.c
@@ -106,6 +106,12 @@ int pmd_huge(pmd_t pmd)
 {
 	return 0;
 }
+
+int pud_huge(pud_t pud)
+{
+	return 0;
+}
+
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd, int write)
 {
Index: linux-2.6/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/hugetlbpage.c
+++ linux-2.6/arch/powerpc/mm/hugetlbpage.c
@@ -368,6 +368,11 @@ int pmd_huge(pmd_t pmd)
 	return 0;
 }
 
+int pud_huge(pud_t pud)
+{
+	return 0;
+}
+
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd, int write)
Index: linux-2.6/arch/sh/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/hugetlbpage.c
+++ linux-2.6/arch/sh/mm/hugetlbpage.c
@@ -78,6 +78,11 @@ int pmd_huge(pmd_t pmd)
 	return 0;
 }
 
+int pud_huge(pud_t pud)
+{
+	return 0;
+}
+
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmd, int write)
 {
Index: linux-2.6/arch/sparc64/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/sparc64/mm/hugetlbpage.c
+++ linux-2.6/arch/sparc64/mm/hugetlbpage.c
@@ -294,6 +294,11 @@ int pmd_huge(pmd_t pmd)
 	return 0;
 }
 
+int pud_huge(pud_t pud)
+{
+	return 0;
+}
+
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmd, int write)
 {
Index: linux-2.6/arch/x86/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
+++ linux-2.6/arch/x86/mm/hugetlbpage.c
@@ -188,6 +188,11 @@ int pmd_huge(pmd_t pmd)
 	return 0;
 }
 
+int pud_huge(pud_t pud)
+{
+	return 0;
+}
+
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd, int write)
@@ -208,6 +213,11 @@ int pmd_huge(pmd_t pmd)
 	return !!(pmd_val(pmd) & _PAGE_PSE);
 }
 
+int pud_huge(pud_t pud)
+{
+	return 0;
+}
+
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd, int write)
@@ -216,9 +226,22 @@ follow_huge_pmd(struct mm_struct *mm, un
 
 	page = pte_page(*(pte_t *)pmd);
 	if (page)
-		page += ((address & ~HPAGE_MASK) >> PAGE_SHIFT);
+		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
 	return page;
 }
+
+struct page *
+follow_huge_pud(struct mm_struct *mm, unsigned long address,
+		pud_t *pud, int write)
+{
+	struct page *page;
+
+	page = pte_page(*(pte_t *)pud);
+	if (page)
+		page += ((address & ~PUD_MASK) >> PAGE_SHIFT);
+	return page;
+}
+
 #endif
 
 /* x86_64 also uses this file */
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -1236,6 +1236,15 @@ int hugetlb_fault(struct mm_struct *mm, 
 	return ret;
 }
 
+/* Can be overriden by architectures */
+__attribute__((weak)) struct page *
+follow_huge_pud(struct mm_struct *mm, unsigned long address,
+	       pud_t *pud, int write)
+{
+	BUG();
+	return NULL;
+}
+
 int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			struct page **pages, struct vm_area_struct **vmas,
 			unsigned long *position, int *length, int i,
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -945,7 +945,13 @@ struct page *follow_page(struct vm_area_
 	pud = pud_offset(pgd, address);
 	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
 		goto no_page_table;
-	
+
+	if (pud_huge(*pud)) {
+		BUG_ON(flags & FOLL_GET);
+		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
+		goto out;
+	}
+
 	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto no_page_table;
@@ -1436,6 +1442,8 @@ static int apply_to_pmd_range(struct mm_
 	unsigned long next;
 	int err;
 
+	BUG_ON(pud_huge(*pud));
+
 	pmd = pmd_alloc(mm, pud, addr);
 	if (!pmd)
 		return -ENOMEM;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
