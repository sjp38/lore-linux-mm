Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBF96B007E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 01:37:58 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id 184so48817052pff.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 22:37:58 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [125.16.236.1])
        by mx.google.com with ESMTPS id d10si9339007pap.88.2016.04.06.22.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 22:37:57 -0700 (PDT)
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 7 Apr 2016 11:07:55 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u375c9Lg15991070
	for <linux-mm@kvack.org>; Thu, 7 Apr 2016 11:08:09 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u375bjNK006015
	for <linux-mm@kvack.org>; Thu, 7 Apr 2016 11:07:50 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 02/10] mm/hugetlb: Add PGD based implementation awareness
Date: Thu,  7 Apr 2016 11:07:36 +0530
Message-Id: <1460007464-26726-3-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

Currently the config ARCH_WANT_GENERAL_HUGETLB enabled functions like
'huge_pte_alloc' and 'huge_pte_offset' dont take into account HugeTLB
page implementation at the PGD level. This is also true for functions
like 'follow_page_mask' which is called from move_pages() system call.
This lack of PGD level huge page support prohibits some architectures
to use these generic HugeTLB functions.

This change adds the required PGD based implementation awareness and
with that, more architectures like POWER which implements 16GB pages
at the PGD level along with the 16MB pages at the PMD level can now
use ARCH_WANT_GENERAL_HUGETLB config option.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h |  3 +++
 mm/gup.c                |  6 ++++++
 mm/hugetlb.c            | 20 ++++++++++++++++++++
 3 files changed, 29 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 7d953c2..71832e1 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -115,6 +115,8 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 				pmd_t *pmd, int flags);
 struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
 				pud_t *pud, int flags);
+struct page *follow_huge_pgd(struct mm_struct *mm, unsigned long address,
+				pgd_t *pgd, int flags);
 int pmd_huge(pmd_t pmd);
 int pud_huge(pud_t pmd);
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
@@ -143,6 +145,7 @@ static inline void hugetlb_show_meminfo(void)
 }
 #define follow_huge_pmd(mm, addr, pmd, flags)	NULL
 #define follow_huge_pud(mm, addr, pud, flags)	NULL
+#define follow_huge_pgd(mm, addr, pgd, flags)	NULL
 #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
 #define pmd_huge(x)	0
 #define pud_huge(x)	0
diff --git a/mm/gup.c b/mm/gup.c
index fb87aea..9bac78c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -234,6 +234,12 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	pgd = pgd_offset(mm, address);
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
 		return no_page_table(vma, flags);
+	if (pgd_huge(*pgd) && vma->vm_flags & VM_HUGETLB) {
+		page = follow_huge_pgd(mm, address, pgd, flags);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
+	}
 
 	pud = pud_offset(pgd, address);
 	if (pud_none(*pud))
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 19d0d08..5ea3158 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4250,6 +4250,11 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, addr);
+	if (sz == PGDIR_SIZE) {
+		pte = (pte_t *)pgd;
+		goto huge_pgd;
+	}
+
 	pud = pud_alloc(mm, pgd, addr);
 	if (pud) {
 		if (sz == PUD_SIZE) {
@@ -4262,6 +4267,8 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 				pte = (pte_t *)pmd_alloc(mm, pud, addr);
 		}
 	}
+
+huge_pgd:
 	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
 
 	return pte;
@@ -4275,6 +4282,8 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 
 	pgd = pgd_offset(mm, addr);
 	if (pgd_present(*pgd)) {
+		if (pgd_huge(*pgd))
+			return (pte_t *)pgd;
 		pud = pud_offset(pgd, addr);
 		if (pud_present(*pud)) {
 			if (pud_huge(*pud))
@@ -4343,6 +4352,17 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 	return pte_page(*(pte_t *)pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
 }
 
+struct page * __weak
+follow_huge_pgd(struct mm_struct *mm, unsigned long address,
+		pgd_t *pgd, int flags)
+{
+	if (flags & FOLL_GET)
+		return NULL;
+
+	return pte_page(*(pte_t *)pgd) +
+				((address & ~PGDIR_MASK) >> PAGE_SHIFT);
+}
+
 #ifdef CONFIG_MEMORY_FAILURE
 
 /*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
