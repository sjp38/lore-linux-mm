From: Andi Kleen <andi@firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
In-Reply-To: <20080317258.659191058@firstfloor.org>
Subject: [PATCH] [16/18] Add huge pud support to hugetlbfs
Message-Id: <20080317015830.2473A1B41E0@basil.firstfloor.org>
Date: Mon, 17 Mar 2008 02:58:30 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Straight forward extensions for huge pages located in the PUD
instead of PMDs.

Signed-off-by: Andi Kleen <ak@suse.de>

---
 arch/ia64/mm/hugetlbpage.c    |    6 ++++++
 arch/powerpc/mm/hugetlbpage.c |    5 +++++
 arch/sh/mm/hugetlbpage.c      |    5 +++++
 arch/sparc64/mm/hugetlbpage.c |    5 +++++
 arch/x86/mm/hugetlbpage.c     |   25 ++++++++++++++++++++++++-
 include/linux/hugetlb.h       |    5 +++++
 mm/hugetlb.c                  |    9 +++++++++
 7 files changed, 59 insertions(+), 1 deletion(-)

Index: linux/include/linux/hugetlb.h
===================================================================
--- linux.orig/include/linux/hugetlb.h
+++ linux/include/linux/hugetlb.h
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
Index: linux/arch/ia64/mm/hugetlbpage.c
===================================================================
--- linux.orig/arch/ia64/mm/hugetlbpage.c
+++ linux/arch/ia64/mm/hugetlbpage.c
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
Index: linux/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux.orig/arch/powerpc/mm/hugetlbpage.c
+++ linux/arch/powerpc/mm/hugetlbpage.c
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
Index: linux/arch/sh/mm/hugetlbpage.c
===================================================================
--- linux.orig/arch/sh/mm/hugetlbpage.c
+++ linux/arch/sh/mm/hugetlbpage.c
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
Index: linux/arch/sparc64/mm/hugetlbpage.c
===================================================================
--- linux.orig/arch/sparc64/mm/hugetlbpage.c
+++ linux/arch/sparc64/mm/hugetlbpage.c
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
Index: linux/arch/x86/mm/hugetlbpage.c
===================================================================
--- linux.orig/arch/x86/mm/hugetlbpage.c
+++ linux/arch/x86/mm/hugetlbpage.c
@@ -196,6 +196,11 @@ int pmd_huge(pmd_t pmd)
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
@@ -216,6 +221,11 @@ int pmd_huge(pmd_t pmd)
 	return !!(pmd_val(pmd) & _PAGE_PSE);
 }
 
+int pud_huge(pud_t pud)
+{
+	return !!(pud_val(pud) & _PAGE_PSE);
+}
+
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd, int write)
@@ -224,9 +234,22 @@ follow_huge_pmd(struct mm_struct *mm, un
 
 	page = pte_page(*(pte_t *)pmd);
 	if (page)
-		page += ((address & ~HPAGE_MASK) >> PAGE_SHIFT);
+		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
+	return page;
+}
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
 	return page;
 }
+
 #endif
 
 /* x86_64 also uses this file */
Index: linux/mm/hugetlb.c
===================================================================
--- linux.orig/mm/hugetlb.c
+++ linux/mm/hugetlb.c
@@ -1206,6 +1206,15 @@ int hugetlb_fault(struct mm_struct *mm, 
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
