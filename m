Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54EA86B0311
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 05:00:52 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n18so28281125wra.11
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 02:00:52 -0700 (PDT)
Received: from mail-wr0-f193.google.com (mail-wr0-f193.google.com. [209.85.128.193])
        by mx.google.com with ESMTPS id x201si10490547wmd.149.2017.06.13.02.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 02:00:50 -0700 (PDT)
Received: by mail-wr0-f193.google.com with SMTP id u101so27934167wrc.1
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 02:00:50 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/4] mm, hugetlb: unclutter hugetlb allocation layers
Date: Tue, 13 Jun 2017 11:00:36 +0200
Message-Id: <20170613090039.14393-2-mhocko@kernel.org>
In-Reply-To: <20170613090039.14393-1-mhocko@kernel.org>
References: <20170613090039.14393-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Hugetlb allocation path for fresh huge pages is unnecessarily complex
and it mixes different interfaces between layers. __alloc_buddy_huge_page
is the central place to perform a new allocation. It checks for the
hugetlb overcommit and then relies on __hugetlb_alloc_buddy_huge_page to
invoke the page allocator. This is all good except that
__alloc_buddy_huge_page pushes vma and address down the callchain and
so __hugetlb_alloc_buddy_huge_page has to deal with two different
allocation modes - one for memory policy and other node specific (or to
make it more obscure node non-specific) requests. This just screams for a
reorganization.

This patch pulls out all the vma specific handling up to
__alloc_buddy_huge_page_with_mpol where it belongs.
__alloc_buddy_huge_page will get nodemask argument and
__hugetlb_alloc_buddy_huge_page will become a trivial wrapper over the
page allocator.

In short:
__alloc_buddy_huge_page_with_mpol - memory policy handling
  __alloc_buddy_huge_page - overcommit handling and accounting
    __hugetlb_alloc_buddy_huge_page - page allocator layer

Also note that __hugetlb_alloc_buddy_huge_page and its cpuset retry loop
is not really needed because the page allocator already handles the
cpusets update.

Finally __hugetlb_alloc_buddy_huge_page had a special case for node
specific allocations (when no policy is applied and there is a node
given). This has relied on __GFP_THISNODE to not fallback to a different
node. alloc_huge_page_node is the only caller which relies on this
behavior. Keep it for now and emulate it by a proper nodemask.

Not only this removes quite some code it also should make those layers
easier to follow and clear wrt responsibilities.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/hugetlb.h |   2 +-
 mm/hugetlb.c            | 134 +++++++++++-------------------------------------
 2 files changed, 31 insertions(+), 105 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index c469191bb13b..016831fcdca1 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -349,7 +349,7 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 struct page *alloc_huge_page_node(struct hstate *h, int nid);
 struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
-struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask);
+struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask);
 int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 			pgoff_t idx);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 01c11ceb47d6..3d5f25d589b3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1531,82 +1531,18 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 	return rc;
 }
 
-/*
- * There are 3 ways this can get called:
- * 1. With vma+addr: we use the VMA's memory policy
- * 2. With !vma, but nid=NUMA_NO_NODE:  We try to allocate a huge
- *    page from any node, and let the buddy allocator itself figure
- *    it out.
- * 3. With !vma, but nid!=NUMA_NO_NODE.  We allocate a huge page
- *    strictly from 'nid'
- */
 static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
-		struct vm_area_struct *vma, unsigned long addr, int nid)
+		int nid, nodemask_t *nmask)
 {
 	int order = huge_page_order(h);
 	gfp_t gfp = htlb_alloc_mask(h)|__GFP_COMP|__GFP_REPEAT|__GFP_NOWARN;
-	unsigned int cpuset_mems_cookie;
-
-	/*
-	 * We need a VMA to get a memory policy.  If we do not
-	 * have one, we use the 'nid' argument.
-	 *
-	 * The mempolicy stuff below has some non-inlined bits
-	 * and calls ->vm_ops.  That makes it hard to optimize at
-	 * compile-time, even when NUMA is off and it does
-	 * nothing.  This helps the compiler optimize it out.
-	 */
-	if (!IS_ENABLED(CONFIG_NUMA) || !vma) {
-		/*
-		 * If a specific node is requested, make sure to
-		 * get memory from there, but only when a node
-		 * is explicitly specified.
-		 */
-		if (nid != NUMA_NO_NODE)
-			gfp |= __GFP_THISNODE;
-		/*
-		 * Make sure to call something that can handle
-		 * nid=NUMA_NO_NODE
-		 */
-		return alloc_pages_node(nid, gfp, order);
-	}
-
-	/*
-	 * OK, so we have a VMA.  Fetch the mempolicy and try to
-	 * allocate a huge page with it.  We will only reach this
-	 * when CONFIG_NUMA=y.
-	 */
-	do {
-		struct page *page;
-		struct mempolicy *mpol;
-		int nid;
-		nodemask_t *nodemask;
-
-		cpuset_mems_cookie = read_mems_allowed_begin();
-		nid = huge_node(vma, addr, gfp, &mpol, &nodemask);
-		mpol_cond_put(mpol);
-		page = __alloc_pages_nodemask(gfp, order, nid, nodemask);
-		if (page)
-			return page;
-	} while (read_mems_allowed_retry(cpuset_mems_cookie));
 
-	return NULL;
+	if (nid == NUMA_NO_NODE)
+		nid = numa_mem_id();
+	return __alloc_pages_nodemask(gfp, order, nid, nmask);
 }
 
-/*
- * There are two ways to allocate a huge page:
- * 1. When you have a VMA and an address (like a fault)
- * 2. When you have no VMA (like when setting /proc/.../nr_hugepages)
- *
- * 'vma' and 'addr' are only for (1).  'nid' is always NUMA_NO_NODE in
- * this case which signifies that the allocation should be done with
- * respect for the VMA's memory policy.
- *
- * For (2), we ignore 'vma' and 'addr' and use 'nid' exclusively. This
- * implies that memory policies will not be taken in to account.
- */
-static struct page *__alloc_buddy_huge_page(struct hstate *h,
-		struct vm_area_struct *vma, unsigned long addr, int nid)
+static struct page *__alloc_buddy_huge_page(struct hstate *h, int nid, nodemask_t *nmask)
 {
 	struct page *page;
 	unsigned int r_nid;
@@ -1615,15 +1551,6 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h,
 		return NULL;
 
 	/*
-	 * Make sure that anyone specifying 'nid' is not also specifying a VMA.
-	 * This makes sure the caller is picking _one_ of the modes with which
-	 * we can call this function, not both.
-	 */
-	if (vma || (addr != -1)) {
-		VM_WARN_ON_ONCE(addr == -1);
-		VM_WARN_ON_ONCE(nid != NUMA_NO_NODE);
-	}
-	/*
 	 * Assume we will successfully allocate the surplus page to
 	 * prevent racing processes from causing the surplus to exceed
 	 * overcommit
@@ -1656,7 +1583,7 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h,
 	}
 	spin_unlock(&hugetlb_lock);
 
-	page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
+	page = __hugetlb_alloc_buddy_huge_page(h, nid, nmask);
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
@@ -1681,26 +1608,22 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h,
 }
 
 /*
- * Allocate a huge page from 'nid'.  Note, 'nid' may be
- * NUMA_NO_NODE, which means that it may be allocated
- * anywhere.
- */
-static
-struct page *__alloc_buddy_huge_page_no_mpol(struct hstate *h, int nid)
-{
-	unsigned long addr = -1;
-
-	return __alloc_buddy_huge_page(h, NULL, addr, nid);
-}
-
-/*
  * Use the VMA's mpolicy to allocate a huge page from the buddy.
  */
 static
 struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
 		struct vm_area_struct *vma, unsigned long addr)
 {
-	return __alloc_buddy_huge_page(h, vma, addr, NUMA_NO_NODE);
+	struct page *page;
+	struct mempolicy *mpol;
+	int nid;
+	nodemask_t *nodemask;
+
+	nid = huge_node(vma, addr, htlb_alloc_mask(h), &mpol, &nodemask);
+	page = __alloc_buddy_huge_page(h, nid, nodemask);
+	mpol_cond_put(mpol);
+
+	return page;
 }
 
 /*
@@ -1717,13 +1640,22 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
 		page = dequeue_huge_page_node(h, nid);
 	spin_unlock(&hugetlb_lock);
 
-	if (!page)
-		page = __alloc_buddy_huge_page_no_mpol(h, nid);
+	if (!page) {
+		nodemask_t nmask;
+
+		if (nid != NUMA_NO_NODE) {
+			nmask = NODE_MASK_NONE;
+			node_set(nid, nmask);
+		} else {
+			nmask = node_states[N_MEMORY];
+		}
+		page = __alloc_buddy_huge_page(h, nid, &nmask);
+	}
 
 	return page;
 }
 
-struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask)
+struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask)
 {
 	struct page *page = NULL;
 	int node;
@@ -1741,13 +1673,7 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask)
 		return page;
 
 	/* No reservations, try to overcommit */
-	for_each_node_mask(node, *nmask) {
-		page = __alloc_buddy_huge_page_no_mpol(h, node);
-		if (page)
-			return page;
-	}
-
-	return NULL;
+	return __alloc_buddy_huge_page(h, NUMA_NO_NODE, nmask);
 }
 
 /*
@@ -1775,7 +1701,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
-		page = __alloc_buddy_huge_page_no_mpol(h, NUMA_NO_NODE);
+		page = __alloc_buddy_huge_page(h, NUMA_NO_NODE, NULL);
 		if (!page) {
 			alloc_ok = false;
 			break;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
