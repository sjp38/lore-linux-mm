Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 409176B0374
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:06:13 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s62so132675228pgc.2
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:06:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w73si13290341pfd.89.2017.05.16.03.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 03:06:12 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4GA3nvw060295
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:06:12 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afnmhs3ev-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:06:11 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 16 May 2017 20:06:08 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4GA5x2856033494
	for <linux-mm@kvack.org>; Tue, 16 May 2017 20:06:07 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4GA5Ske025930
	for <linux-mm@kvack.org>; Tue, 16 May 2017 20:05:28 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V3] mm/madvise: Enable (soft|hard) offline of HugeTLB pages at PGD level
Date: Tue, 16 May 2017 15:35:09 +0530
In-Reply-To: <20170426035731.6924-1-khandual@linux.vnet.ibm.com>
References: <20170426035731.6924-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170516100509.20122-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org

Though migrating gigantic HugeTLB pages does not sound much like real
world use case, they can be affected by memory errors. Hence migration
at the PGD level HugeTLB pages should be supported just to enable soft
and hard offline use cases.

While allocating the new gigantic HugeTLB page, it should not matter
whether new page comes from the same node or not. There would be very
few gigantic pages on the system afterall, we should not be bothered
about node locality when trying to save a big page from crashing.

This change renames dequeu_huge_page_node() function as dequeue_huge
_page_node_exact() preserving it's original functionality. Now the new
dequeue_huge_page_node() function scans through all available online
nodes to allocate a huge page for the NUMA_NO_NODE case and just falls
back calling dequeu_huge_page_node_exact() for all other cases.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
Changes in V3:
* Dropped alloc_huge_page_nonid() as per Andrew
* Changed dequeue_huge_page_node() to accommodate NUMA_NO_NODE as per Andrew
* Added dequeue_huge_page_node_exact() which implements functionality for the
  previous dequeue_huge_page_node() function

Changes in V2:
 * Added hstate_is_gigantic() definition when !CONFIG_HUGETLB_PAGE
   which takes care of the build failure reported earlier.

 include/linux/hugetlb.h |  7 ++++++-
 mm/hugetlb.c            | 18 +++++++++++++++++-
 mm/memory-failure.c     | 13 +++++++++----
 3 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index b857fc8cc2ec..614a0a40f1ef 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -466,7 +466,11 @@ extern int dissolve_free_huge_pages(unsigned long start_pfn,
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
@@ -518,6 +522,7 @@ struct hstate {};
 #define vma_mmu_pagesize(v) PAGE_SIZE
 #define huge_page_order(h) 0
 #define huge_page_shift(h) PAGE_SHIFT
+#define hstate_is_gigantic(h) 0
 static inline unsigned int pages_per_huge_page(struct hstate *h)
 {
 	return 1;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e5828875f7bb..7cd0f09b8dd0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -867,7 +867,7 @@ static void enqueue_huge_page(struct hstate *h, struct page *page)
 	h->free_huge_pages_node[nid]++;
 }
 
-static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
+static struct page *dequeue_huge_page_node_exact(struct hstate *h, int nid)
 {
 	struct page *page;
 
@@ -887,6 +887,22 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
 	return page;
 }
 
+static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
+{
+	struct page *page;
+	int node;
+
+	if (nid != NUMA_NO_NODE)
+		return dequeue_huge_page_node_exact(h, nid);
+
+	for_each_online_node(node) {
+		page = dequeue_huge_page_node_exact(h, node);
+		if (page)
+			return page;
+	}
+	return NULL;
+}
+
 /* Movability of hugepages depends on migration support. */
 static inline gfp_t htlb_alloc_mask(struct hstate *h)
 {
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 2527dfeddb00..f71efae2e494 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1489,11 +1489,16 @@ EXPORT_SYMBOL(unpoison_memory);
 static struct page *new_page(struct page *p, unsigned long private, int **x)
 {
 	int nid = page_to_nid(p);
-	if (PageHuge(p))
-		return alloc_huge_page_node(page_hstate(compound_head(p)),
-						   nid);
-	else
+	if (PageHuge(p)) {
+		struct hstate *hstate = page_hstate(compound_head(p));
+
+		if (hstate_is_gigantic(hstate))
+			return alloc_huge_page_node(hstate, NUMA_NO_NODE);
+
+		return alloc_huge_page_node(hstate, nid);
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
