Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 735F76B0390
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 23:28:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d79so661848wmi.8
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 20:28:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w62si1458344wrb.207.2017.04.18.20.28.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 20:28:58 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3J3SYda005071
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 23:28:56 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29wqq11hch-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 23:28:56 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 19 Apr 2017 13:28:52 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3J3Sgls63570120
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 13:28:50 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3J3SHx8031205
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 13:28:17 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC] mm/madvise: Enable (soft|hard) offline of HugeTLB pages at PGD level
Date: Wed, 19 Apr 2017 08:57:59 +0530
Message-Id: <20170419032759.29700-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com

Though migrating gigantic HugeTLB pages does not sound much like real
world use case, they can be affected by memory errors. Hence migration
at the PGD level HugeTLB pages should be supported just to enable soft
and hard offline use cases.

While allocating the new gigantic HugeTLB page, it should not matter
whether new page comes from the same node or not. There would be very
few gigantic pages on the system afterall, we should not be bothered
about node locality when trying to save a big page from crashing.

This introduces a new HugeTLB allocator called alloc_gigantic_page()
which will scan over all online nodes on the system and allocate a
single HugeTLB page.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
Tested on a POWER8 machine with 16GB pages along with Aneesh's
recent HugeTLB enablement patch series on powerpc which can
be found here.

https://lkml.org/lkml/2017/4/17/225

Here, we directly call alloc_gigantic_page() which ignores node
locality. But we can also first call normal alloc_huge_page()
with the node number and if that fails to allocate then call
alloc_gigantic_page() as a fallback option.

 include/linux/hugetlb.h |  8 +++++++-
 mm/hugetlb.c            | 17 +++++++++++++++++
 mm/memory-failure.c     |  8 ++++++--
 3 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 04b73a9c8b4b..ee75197e6ed8 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -347,6 +347,7 @@ struct huge_bootmem_page {
 
 struct page *alloc_huge_page(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
+struct page *alloc_gigantic_page(struct hstate *h);
 struct page *alloc_huge_page_node(struct hstate *h, int nid);
 struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
@@ -473,7 +474,11 @@ extern int dissolve_free_huge_pages(unsigned long start_pfn,
 static inline bool hugepage_migration_supported(struct hstate *h)
 {
 #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
-	return huge_page_shift(h) == PMD_SHIFT;
+	if ((huge_page_shift(h) == PMD_SHIFT) ||
+		(huge_page_shift(h) == PGDIR_SHIFT))
+		return true;
+	else
+		return false;
 #else
 	return false;
 #endif
@@ -511,6 +516,7 @@ static inline void hugetlb_count_sub(long l, struct mm_struct *mm)
 #else	/* CONFIG_HUGETLB_PAGE */
 struct hstate {};
 #define alloc_huge_page(v, a, r) NULL
+#define alloc_gigantic_page(h) NULL
 #define alloc_huge_page_node(h, nid) NULL
 #define alloc_huge_page_noerr(v, a, r) NULL
 #define alloc_bootmem_huge_page(h) NULL
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 97a44db06850..f2b31dddb1bc 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1669,6 +1669,23 @@ struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
 	return __alloc_buddy_huge_page(h, vma, addr, NUMA_NO_NODE);
 }
 
+struct page *alloc_gigantic_page(struct hstate *h)
+{
+	struct page *page = NULL;
+	int nid = 0;
+
+	spin_lock(&hugetlb_lock);
+	if (h->free_huge_pages - h->resv_huge_pages > 0) {
+		for_each_online_node(nid) {
+			page = dequeue_huge_page_node(h, nid);
+			if (page)
+				break;
+		}
+	}
+	spin_unlock(&hugetlb_lock);
+	return page;
+}
+
 /*
  * This allocation function is useful in the context where vma is irrelevant.
  * E.g. soft-offlining uses this function because it only cares physical
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index fe64d7729a8e..619650969fe5 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1481,11 +1481,15 @@ EXPORT_SYMBOL(unpoison_memory);
 static struct page *new_page(struct page *p, unsigned long private, int **x)
 {
 	int nid = page_to_nid(p);
-	if (PageHuge(p))
+	if (PageHuge(p)) {
+		if (hstate_is_gigantic(page_hstate(compound_head(p))))
+			return alloc_gigantic_page(page_hstate(compound_head(p)));
+
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
 						   nid);
-	else
+	} else {
 		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
+	}
 }
 
 /*
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
