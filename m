Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA05810
	for <linux-mm@kvack.org>; Fri, 31 Jan 2003 15:14:48 -0800 (PST)
Date: Fri, 31 Jan 2003 15:17:11 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030131151711.7c8aaee7.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2/4



ia32 and others can determine a page's hugeness by inspecting the pmd's value
directly.  No need to perform a VMA lookup against the user's virtual
address.

This patch ifdef's away the VMA-based implementation of
hugepage-aware-follow_page for ia32 and replaces it with a pmd-based
implementation.

The intent is that architectures will implement one or the other.  So the architecture either:

1: Implements hugepage_vma()/follow_huge_addr(), and stubs out
   pmd_huge()/follow_huge_pmd() or

2: Implements pmd_huge()/follow_huge_pmd(), and stubs out
   hugepage_vma()/follow_huge_addr()



 arch/i386/mm/hugetlbpage.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
 include/asm-i386/pgtable.h |    5 +++++
 include/linux/hugetlb.h    |    3 +++
 mm/memory.c                |    6 +++++-
 4 files changed, 58 insertions(+), 1 deletion(-)

diff -puN mm/memory.c~pin_page-pmd mm/memory.c
--- 25/mm/memory.c~pin_page-pmd	Fri Jan 31 14:30:01 2003
+++ 25-akpm/mm/memory.c	Fri Jan 31 14:30:01 2003
@@ -618,7 +618,11 @@ follow_page(struct mm_struct *mm, unsign
 		goto out;
 
 	pmd = pmd_offset(pgd, address);
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
+	if (pmd_none(*pmd))
+		goto out;
+	if (pmd_huge(*pmd))
+		return follow_huge_pmd(mm, address, pmd, write);
+	if (pmd_bad(*pmd))
 		goto out;
 
 	ptep = pte_offset_map(pmd, address);
diff -puN include/linux/hugetlb.h~pin_page-pmd include/linux/hugetlb.h
--- 25/include/linux/hugetlb.h~pin_page-pmd	Fri Jan 31 14:30:01 2003
+++ 25-akpm/include/linux/hugetlb.h	Fri Jan 31 14:30:01 2003
@@ -24,6 +24,8 @@ struct page *follow_huge_addr(struct mm_
 			unsigned long address, int write);
 struct vm_area_struct *hugepage_vma(struct mm_struct *mm,
 					unsigned long address);
+struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
+				pmd_t *pmd, int write);
 extern int htlbpage_max;
 
 static inline void
@@ -51,6 +53,7 @@ static inline int is_vm_hugetlb_page(str
 #define hugetlb_report_meminfo(buf)		0
 #define hugepage_vma(mm, addr)			0
 #define mark_mm_hugetlb(mm, vma)		do { } while (0)
+#define follow_huge_pmd(mm, addr, pmd, write)	0
 
 #endif /* !CONFIG_HUGETLB_PAGE */
 
diff -puN include/asm-i386/pgtable.h~pin_page-pmd include/asm-i386/pgtable.h
--- 25/include/asm-i386/pgtable.h~pin_page-pmd	Fri Jan 31 14:30:01 2003
+++ 25-akpm/include/asm-i386/pgtable.h	Fri Jan 31 14:30:01 2003
@@ -177,6 +177,11 @@ extern unsigned long pg0[1024];
 #define pmd_clear(xp)	do { set_pmd(xp, __pmd(0)); } while (0)
 #define	pmd_bad(x)	((pmd_val(x) & (~PAGE_MASK & ~_PAGE_USER)) != _KERNPG_TABLE)
 
+#ifdef CONFIG_HUGETLB_PAGE
+int pmd_huge(pmd_t pmd);
+#else
+#define pmd_huge(x)	0
+#endif
 
 #define pages_to_mb(x) ((x) >> (20-PAGE_SHIFT))
 
diff -puN arch/i386/mm/hugetlbpage.c~pin_page-pmd arch/i386/mm/hugetlbpage.c
--- 25/arch/i386/mm/hugetlbpage.c~pin_page-pmd	Fri Jan 31 14:30:01 2003
+++ 25-akpm/arch/i386/mm/hugetlbpage.c	Fri Jan 31 14:30:01 2003
@@ -150,6 +150,7 @@ back1:
 	return i;
 }
 
+#if 0	/* This is just for testing */
 struct page *
 follow_huge_addr(struct mm_struct *mm,
 	struct vm_area_struct *vma, unsigned long address, int write)
@@ -179,6 +180,50 @@ struct vm_area_struct *hugepage_vma(stru
 	return NULL;
 }
 
+int pmd_huge(pmd_t pmd)
+{
+	return 0;
+}
+
+struct page *
+follow_huge_pmd(struct mm_struct *mm, unsigned long address,
+		pmd_t *pmd, int write)
+{
+	return NULL;
+}
+
+#else
+
+struct page *
+follow_huge_addr(struct mm_struct *mm,
+	struct vm_area_struct *vma, unsigned long address, int write)
+{
+	return NULL;
+}
+
+struct vm_area_struct *hugepage_vma(struct mm_struct *mm, unsigned long addr)
+{
+	return NULL;
+}
+
+int pmd_huge(pmd_t pmd)
+{
+	return !!(pmd_val(pmd) & _PAGE_PSE);
+}
+
+struct page *
+follow_huge_pmd(struct mm_struct *mm, unsigned long address,
+		pmd_t *pmd, int write)
+{
+	struct page *page;
+
+	page = pte_page(*(pte_t *)pmd);
+	if (page)
+		page += ((address & ~HPAGE_MASK) >> PAGE_SHIFT);
+	return page;
+}
+#endif
+
 void free_huge_page(struct page *page)
 {
 	BUG_ON(page_count(page));

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
