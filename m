Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37B446B03A5
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:18 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b10so94572844pgn.8
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 10:12:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w21si11760197pgh.90.2017.04.17.10.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 10:12:17 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3HH92Er079514
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:16 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29vx43tamh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:16 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 17 Apr 2017 13:12:15 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 2/7] mm/follow_page_mask: Split follow_page_mask to smaller functions.
Date: Mon, 17 Apr 2017 22:41:41 +0530
In-Reply-To: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1492449106-27467-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Makes code reading easy. No functional changes in this patch. In a followup
patch, we will be updating the follow_page_mask to handle hugetlb hugepd format
so that archs like ppc64 can switch to the generic version. This split helps
in doing that nicely.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/gup.c | 148 +++++++++++++++++++++++++++++++++++++++------------------------
 1 file changed, 91 insertions(+), 57 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 04aa405350dc..73d46f9f7b81 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -208,68 +208,16 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 	return no_page_table(vma, flags);
 }
 
-/**
- * follow_page_mask - look up a page descriptor from a user-virtual address
- * @vma: vm_area_struct mapping @address
- * @address: virtual address to look up
- * @flags: flags modifying lookup behaviour
- * @page_mask: on output, *page_mask is set according to the size of the page
- *
- * @flags can have FOLL_ flags set, defined in <linux/mm.h>
- *
- * Returns the mapped (struct page *), %NULL if no mapping exists, or
- * an error pointer if there is a mapping to something not represented
- * by a page descriptor (see also vm_normal_page()).
- */
-struct page *follow_page_mask(struct vm_area_struct *vma,
-			      unsigned long address, unsigned int flags,
-			      unsigned int *page_mask)
+static struct page *follow_pmd_mask(struct vm_area_struct *vma,
+				    unsigned long address, pud_t *pudp,
+				    unsigned int flags, unsigned int *page_mask)
 {
-	pgd_t *pgd;
-	p4d_t *p4d;
-	pud_t *pud;
 	pmd_t *pmd;
 	spinlock_t *ptl;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
 
-	*page_mask = 0;
-
-	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
-	if (!IS_ERR(page)) {
-		BUG_ON(flags & FOLL_GET);
-		return page;
-	}
-
-	pgd = pgd_offset(mm, address);
-	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		return no_page_table(vma, flags);
-	p4d = p4d_offset(pgd, address);
-	if (p4d_none(*p4d))
-		return no_page_table(vma, flags);
-	BUILD_BUG_ON(p4d_huge(*p4d));
-	if (unlikely(p4d_bad(*p4d)))
-		return no_page_table(vma, flags);
-	pud = pud_offset(p4d, address);
-	if (pud_none(*pud))
-		return no_page_table(vma, flags);
-	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
-		page = follow_huge_pud(mm, address, pud, flags);
-		if (page)
-			return page;
-		return no_page_table(vma, flags);
-	}
-	if (pud_devmap(*pud)) {
-		ptl = pud_lock(mm, pud);
-		page = follow_devmap_pud(vma, address, pud, flags);
-		spin_unlock(ptl);
-		if (page)
-			return page;
-	}
-	if (unlikely(pud_bad(*pud)))
-		return no_page_table(vma, flags);
-
-	pmd = pmd_offset(pud, address);
+	pmd = pmd_offset(pudp, address);
 	if (pmd_none(*pmd))
 		return no_page_table(vma, flags);
 	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
@@ -319,13 +267,99 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 		return ret ? ERR_PTR(ret) :
 			follow_page_pte(vma, address, pmd, flags);
 	}
-
 	page = follow_trans_huge_pmd(vma, address, pmd, flags);
 	spin_unlock(ptl);
 	*page_mask = HPAGE_PMD_NR - 1;
 	return page;
 }
 
+
+static struct page *follow_pud_mask(struct vm_area_struct *vma,
+				    unsigned long address, p4d_t *p4dp,
+				    unsigned int flags, unsigned int *page_mask)
+{
+	pud_t *pud;
+	spinlock_t *ptl;
+	struct page *page;
+	struct mm_struct *mm = vma->vm_mm;
+
+	pud = pud_offset(p4dp, address);
+	if (pud_none(*pud))
+		return no_page_table(vma, flags);
+	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
+		page = follow_huge_pud(mm, address, pud, flags);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
+	}
+	if (pud_devmap(*pud)) {
+		ptl = pud_lock(mm, pud);
+		page = follow_devmap_pud(vma, address, pud, flags);
+		spin_unlock(ptl);
+		if (page)
+			return page;
+	}
+	if (unlikely(pud_bad(*pud)))
+		return no_page_table(vma, flags);
+
+	return follow_pmd_mask(vma, address, pud, flags, page_mask);
+}
+
+
+static struct page *follow_p4d_mask(struct vm_area_struct *vma,
+				    unsigned long address, pgd_t *pgdp,
+				    unsigned int flags, unsigned int *page_mask)
+{
+	p4d_t *p4d;
+
+	p4d = p4d_offset(pgdp, address);
+	if (p4d_none(*p4d))
+		return no_page_table(vma, flags);
+	BUILD_BUG_ON(p4d_huge(*p4d));
+	if (unlikely(p4d_bad(*p4d)))
+		return no_page_table(vma, flags);
+
+	return follow_pud_mask(vma, address, p4d, flags, page_mask);
+}
+
+/**
+ * follow_page_mask - look up a page descriptor from a user-virtual address
+ * @vma: vm_area_struct mapping @address
+ * @address: virtual address to look up
+ * @flags: flags modifying lookup behaviour
+ * @page_mask: on output, *page_mask is set according to the size of the page
+ *
+ * @flags can have FOLL_ flags set, defined in <linux/mm.h>
+ *
+ * Returns the mapped (struct page *), %NULL if no mapping exists, or
+ * an error pointer if there is a mapping to something not represented
+ * by a page descriptor (see also vm_normal_page()).
+ */
+struct page *follow_page_mask(struct vm_area_struct *vma,
+			      unsigned long address, unsigned int flags,
+			      unsigned int *page_mask)
+{
+	pgd_t *pgd;
+	struct page *page;
+	struct mm_struct *mm = vma->vm_mm;
+
+	*page_mask = 0;
+
+	/* make this handle hugepd */
+	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
+	if (!IS_ERR(page)) {
+		BUG_ON(flags & FOLL_GET);
+		return page;
+	}
+
+	pgd = pgd_offset(mm, address);
+
+	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
+		return no_page_table(vma, flags);
+
+	return follow_p4d_mask(vma, address, pgd, flags, page_mask);
+}
+
 static int get_gate_page(struct mm_struct *mm, unsigned long address,
 		unsigned int gup_flags, struct vm_area_struct **vma,
 		struct page **page)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
