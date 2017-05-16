Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5106B033C
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x25so131615363pgc.10
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:24:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h89si6084837pld.136.2017.05.16.02.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 02:24:04 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4G9NwJv109457
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:03 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afv7bf2df-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:03 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 May 2017 03:24:01 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v2 6/9] mm/follow_page_mask: Add support for hugepage directory entry
Date: Tue, 16 May 2017 14:53:29 +0530
In-Reply-To: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1494926612-23928-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Architectures like ppc64 supports hugepage size that is not mapped to any of
of the page table levels. Instead they add an alternate page table entry format
called hugepage directory (hugepd). hugepd indicates that the page table entry maps
to a set of hugetlb pages. Add support for this in generic follow_page_mask
code. We already support this format in the generic gup code.

The defaul implementation prints warning and returns NULL. We will add ppc64
support in later patches

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h |  4 ++++
 mm/gup.c                | 33 +++++++++++++++++++++++++++++++++
 mm/hugetlb.c            |  8 ++++++++
 3 files changed, 45 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index f66c1d4e0d1f..caee7c4664c8 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -141,6 +141,9 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
+struct page *follow_huge_pd(struct vm_area_struct *vma,
+			    unsigned long address, hugepd_t hpd,
+			    int flags, int pdshift);
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 				pmd_t *pmd, int flags);
 struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
@@ -175,6 +178,7 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 static inline void hugetlb_show_meminfo(void)
 {
 }
+#define follow_huge_pd(vma, addr, hpd, flags, pdshift) NULL
 #define follow_huge_pmd(mm, addr, pmd, flags)	NULL
 #define follow_huge_pud(mm, addr, pud, flags)	NULL
 #define follow_huge_pgd(mm, addr, pgd, flags)	NULL
diff --git a/mm/gup.c b/mm/gup.c
index 65255389620a..a7f5b82e15f3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -226,6 +226,14 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 			return page;
 		return no_page_table(vma, flags);
 	}
+	if (is_hugepd(__hugepd(pmd_val(*pmd)))) {
+		page = follow_huge_pd(vma, address,
+				      __hugepd(pmd_val(*pmd)), flags,
+				      PMD_SHIFT);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
+	}
 	if (pmd_devmap(*pmd)) {
 		ptl = pmd_lock(mm, pmd);
 		page = follow_devmap_pmd(vma, address, pmd, flags);
@@ -292,6 +300,14 @@ static struct page *follow_pud_mask(struct vm_area_struct *vma,
 			return page;
 		return no_page_table(vma, flags);
 	}
+	if (is_hugepd(__hugepd(pud_val(*pud)))) {
+		page = follow_huge_pd(vma, address,
+				      __hugepd(pud_val(*pud)), flags,
+				      PUD_SHIFT);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
+	}
 	if (pud_devmap(*pud)) {
 		ptl = pud_lock(mm, pud);
 		page = follow_devmap_pud(vma, address, pud, flags);
@@ -311,6 +327,7 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
 				    unsigned int flags, unsigned int *page_mask)
 {
 	p4d_t *p4d;
+	struct page *page;
 
 	p4d = p4d_offset(pgdp, address);
 	if (p4d_none(*p4d))
@@ -319,6 +336,14 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
 	if (unlikely(p4d_bad(*p4d)))
 		return no_page_table(vma, flags);
 
+	if (is_hugepd(__hugepd(p4d_val(*p4d)))) {
+		page = follow_huge_pd(vma, address,
+				      __hugepd(p4d_val(*p4d)), flags,
+				      P4D_SHIFT);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
+	}
 	return follow_pud_mask(vma, address, p4d, flags, page_mask);
 }
 
@@ -363,6 +388,14 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			return page;
 		return no_page_table(vma, flags);
 	}
+	if (is_hugepd(__hugepd(pgd_val(*pgd)))) {
+		page = follow_huge_pd(vma, address,
+				      __hugepd(pgd_val(*pgd)), flags,
+				      PGDIR_SHIFT);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
+	}
 
 	return follow_p4d_mask(vma, address, pgd, flags, page_mask);
 }
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a12d3cab04fe..58307d62ac37 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4643,6 +4643,14 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address,
 }
 
 struct page * __weak
+follow_huge_pd(struct vm_area_struct *vma,
+	       unsigned long address, hugepd_t hpd, int flags, int pdshift)
+{
+	WARN(1, "hugepd follow called with no support for hugepage directory format\n");
+	return NULL;
+}
+
+struct page * __weak
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd, int flags)
 {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
