Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA1A16B02EE
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 23:58:36 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k57so7014912wrk.6
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 20:58:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k203si6481135wmk.63.2017.04.25.20.58.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 20:58:35 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3Q3tPgc086564
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 23:58:34 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a2ebu3rds-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 23:58:33 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 26 Apr 2017 13:58:28 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3Q3wJBr37814298
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 13:58:27 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3Q3voOS011211
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 13:57:50 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V2] mm/madvise: Enable (soft|hard) offline of HugeTLB pages at PGD level
Date: Wed, 26 Apr 2017 09:27:31 +0530
Message-Id: <20170426035731.6924-1-khandual@linux.vnet.ibm.com>
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

This introduces a new HugeTLB allocator called alloc_huge_page_nonid()
which will scan over all online nodes on the system and allocate a
single HugeTLB page.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
Tested on a POWER8 machine with 16GB pages along with Aneesh's
recent HugeTLB enablement patch series on powerpc which can
be found here.

https://lkml.org/lkml/2017/4/17/225

Here, we directly call alloc_huge_page_nonid() which ignores the
node locality. But we can also first call normal alloc_huge_page()
with the node number and if that fails to allocate only then call
alloc_huge_page_nonid() as a fallback option.

Aneesh mentioned about the waste of memory if we just have to
soft offline a single page. The problem persists both on PGD
as well as PMD level HugeTLB pages. Tried solving the problem
with https://patchwork.kernel.org/patch/9690119/ but right now
madvise splits the entire range of HugeTLB pages (if the page
is HugeTLB one) and calls soft_offline_page() on the head page
of each HugeTLB page as soft_offline_page() acts on the entire
HugeTLB range not just the individual pages. Changing the iterator
in madvise() scan over individual pages solves the problem but
then it creates multiple HugeTLB migrations (HUGE_PAGE_SIZE /
PAGE_SIZE times to be precise) if we really have to soft offline
a single HugeTLB page which is not optimal.

Hence for now, lets just enable PGD level HugeTLB soft offline
at par with the PMD level HugeTLB before we can go back and
address the memory wastage problem comprehensively for both
PGD and PMD level HugeTLB page as mentioned above.

Changes in V2:
 * Added hstate_is_gigantic() definition when !CONFIG_HUGETLB_PAGE
   which takes care of the build failure reported earlier.

 mm/hugetlb.c            | 17 +++++++++++++++++
 mm/memory-failure.c     |  8 ++++++--
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 04b73a9c8b4b..964d964f22c8 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -347,6 +347,7 @@ struct huge_bootmem_page {
 
 struct page *alloc_huge_page(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
+struct page *alloc_huge_page_nonid(struct hstate *h);
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
+#define alloc_huge_page_nonid(h) NULL
 #define alloc_huge_page_node(h, nid) NULL
 #define alloc_huge_page_noerr(v, a, r) NULL
 #define alloc_bootmem_huge_page(h) NULL
@@ -525,6 +531,7 @@ struct hstate {};
 #define vma_mmu_pagesize(v) PAGE_SIZE
 #define huge_page_order(h) 0
 #define huge_page_shift(h) PAGE_SHIFT
+#define hstate_is_gigantic(h) 0
 static inline unsigned int pages_per_huge_page(struct hstate *h)
 {
 	return 1;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 97a44db06850..bd96fff2bc09 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1669,6 +1669,23 @@ struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
 	return __alloc_buddy_huge_page(h, vma, addr, NUMA_NO_NODE);
 }
 
+struct page *alloc_huge_page_nonid(struct hstate *h)
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
index fe64d7729a8e..d4f5710cf3f7 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1481,11 +1481,15 @@ EXPORT_SYMBOL(unpoison_memory);
 static struct page *new_page(struct page *p, unsigned long private, int **x)
 {
 	int nid = page_to_nid(p);
-	if (PageHuge(p))
+	if (PageHuge(p)) {
+		if (hstate_is_gigantic(page_hstate(compound_head(p))))
+			return alloc_huge_page_nonid(page_hstate(compound_head(p)));
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
