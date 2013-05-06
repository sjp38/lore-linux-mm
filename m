Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D83216B00EA
	for <linux-mm@kvack.org>; Mon,  6 May 2013 16:52:44 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 7 May 2013 02:16:38 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id AA8AB1258023
	for <linux-mm@kvack.org>; Tue,  7 May 2013 02:24:24 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r46KqXoP66191432
	for <linux-mm@kvack.org>; Tue, 7 May 2013 02:22:33 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r46KqbTJ012218
	for <linux-mm@kvack.org>; Tue, 7 May 2013 06:52:37 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm/THP: Don't use HPAGE_SHIFT in transparent hugepage code
Date: Tue,  7 May 2013 02:22:32 +0530
Message-Id: <1367873552-12904-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

For architectures like powerpc that support multiple explicit hugepage
sizes, HPAGE_SHIFT indicate the default explicit hugepage shift. For
THP to work the hugepage size should be same as PMD_SIZE. So use
PMD_SHIFT directly. So move the define outside CONFIG_TRANSPARENT_HUGEPAGE
#ifdef because we want to use these defines in generic code with
if (pmd_trans_huge()) conditional.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/huge_mm.h | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 528454c..cc276d2 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -58,12 +58,11 @@ extern pmd_t *page_check_address_pmd(struct page *page,
 
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
+#define HPAGE_PMD_SHIFT PMD_SHIFT
+#define HPAGE_PMD_SIZE	((1UL) << HPAGE_PMD_SHIFT)
+#define HPAGE_PMD_MASK	(~(HPAGE_PMD_SIZE - 1))
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#define HPAGE_PMD_SHIFT HPAGE_SHIFT
-#define HPAGE_PMD_MASK HPAGE_MASK
-#define HPAGE_PMD_SIZE HPAGE_SIZE
-
 extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 #define transparent_hugepage_enabled(__vma)				\
@@ -181,9 +180,6 @@ extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vm
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
-#define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
-#define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
-#define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
 
 #define hpage_nr_pages(x) 1
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
