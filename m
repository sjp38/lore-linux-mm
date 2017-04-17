Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B5DA86B03AA
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r129so93984630pgr.18
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 10:12:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u3si11768940pfd.324.2017.04.17.10.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 10:12:25 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3HH928U120948
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:25 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29w0p637w3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:25 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 17 Apr 2017 13:12:23 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 4/7] mm/follow_page_mask: Add support for hugetlb pgd entries.
Date: Mon, 17 Apr 2017 22:41:43 +0530
In-Reply-To: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1492449106-27467-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>

From: Anshuman Khandual <khandual@linux.vnet.ibm.com>

ppc64 supports pgd hugetlb entries. Add code to handle hugetlb pgd entries to
follow_page_mask so that ppc64 can switch to it to handle hugetlbe entries.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h | 4 ++++
 mm/gup.c                | 7 +++++++
 mm/hugetlb.c            | 9 +++++++++
 3 files changed, 20 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index fddf6cf403d5..edab98f0a7b8 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -121,6 +121,9 @@ struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 				pmd_t *pmd, int flags);
 struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
 				pud_t *pud, int flags);
+struct page *follow_huge_pgd(struct mm_struct *mm, unsigned long address,
+			     pgd_t *pgd, int flags);
+
 int pmd_huge(pmd_t pmd);
 int pud_huge(pud_t pud);
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
@@ -150,6 +153,7 @@ static inline void hugetlb_show_meminfo(void)
 }
 #define follow_huge_pmd(mm, addr, pmd, flags)	NULL
 #define follow_huge_pud(mm, addr, pud, flags)	NULL
+#define follow_huge_pgd(mm, addr, pgd, flags)	NULL
 #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
 #define pmd_huge(x)	0
 #define pud_huge(x)	0
diff --git a/mm/gup.c b/mm/gup.c
index 73d46f9f7b81..65255389620a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -357,6 +357,13 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
 		return no_page_table(vma, flags);
 
+	if (pgd_huge(*pgd)) {
+		page = follow_huge_pgd(mm, address, pgd, flags);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
+	}
+
 	return follow_p4d_mask(vma, address, pgd, flags, page_mask);
 }
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9b630e2195d5..83f39cf5162a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4694,6 +4694,15 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 	return pte_page(*(pte_t *)pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
 }
 
+struct page * __weak
+follow_huge_pgd(struct mm_struct *mm, unsigned long address, pgd_t *pgd, int flags)
+{
+	if (flags & FOLL_GET)
+		return NULL;
+
+	return pte_page(*(pte_t *)pgd) + ((address & ~PGDIR_MASK) >> PAGE_SHIFT);
+}
+
 #ifdef CONFIG_MEMORY_FAILURE
 
 /*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
