Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D18366B028D
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 09:01:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v184so5068394wmf.1
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 06:01:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x73sor814397wmf.38.2017.12.04.06.01.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 06:01:34 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 5/5] mm, hugetlb: further simplify hugetlb allocation API
Date: Mon,  4 Dec 2017 15:01:17 +0100
Message-Id: <20171204140117.7191-6-mhocko@kernel.org>
In-Reply-To: <20171204140117.7191-1-mhocko@kernel.org>
References: <20171204140117.7191-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Hugetlb allocator has several layer of allocation functions depending
and the purpose of the allocation. There are two allocators depending
on whether the page can be allocated from the page allocator or we need
a contiguous allocator. This is currently opencoded in alloc_fresh_huge_page
which is the only path that might allocate giga pages which require the
later allocator. Create alloc_fresh_huge_page which hides this
implementation detail and use it in all callers which hardcoded the
buddy allocator path (__hugetlb_alloc_buddy_huge_page). This shouldn't
introduce any funtional change because both migration and surplus
allocators exlude giga pages explicitly.

While we are at it let's do some renaming. The current scheme is not
consistent and overly painfull to read and understand. Get rid of prefix
underscores from most functions. There is no real reason to make names
longer.
* alloc_fresh_huge_page is the new layer to abstract underlying
  allocator
* __hugetlb_alloc_buddy_huge_page becomes shorter and neater
  alloc_buddy_huge_page.
* Former alloc_fresh_huge_page becomes alloc_pool_huge_page because we put
  the new page directly to the pool
* alloc_surplus_huge_page can drop the opencoded prep_new_huge_page code
  as it uses alloc_fresh_huge_page now
* others lose their excessive prefix underscores to make names shorter

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/hugetlb.c | 74 +++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 41 insertions(+), 33 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0c7dc269b6c0..73c74851a304 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1376,7 +1376,7 @@ pgoff_t __basepage_index(struct page *page)
 	return (index << compound_order(page_head)) + compound_idx;
 }
 
-static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
+static struct page *alloc_buddy_huge_page(struct hstate *h,
 		gfp_t gfp_mask, int nid, nodemask_t *nmask)
 {
 	int order = huge_page_order(h);
@@ -1394,34 +1394,49 @@ static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
 	return page;
 }
 
+/*
+ * Common helper to allocate a fresh hugetlb page. All specific allocators
+ * should use this function to get new hugetlb pages
+ */
+static struct page *alloc_fresh_huge_page(struct hstate *h,
+		gfp_t gfp_mask, int nid, nodemask_t *nmask)
+{
+	struct page *page;
+
+	if (hstate_is_gigantic(h))
+		page = alloc_gigantic_page(h, gfp_mask, nid, nmask);
+	else
+		page = alloc_buddy_huge_page(h, gfp_mask,
+				nid, nmask);
+	if (!page)
+		return NULL;
+
+	if (hstate_is_gigantic(h))
+		prep_compound_gigantic_page(page, huge_page_order(h));
+	prep_new_huge_page(h, page, page_to_nid(page));
+
+	return page;
+}
+
 /*
  * Allocates a fresh page to the hugetlb allocator pool in the node interleaved
  * manner.
  */
-static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
+static int alloc_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
 {
 	struct page *page;
 	int nr_nodes, node;
 	gfp_t gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
-		if (hstate_is_gigantic(h))
-			page = alloc_gigantic_page(h, gfp_mask,
-					node, nodes_allowed);
-		else
-			page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask,
-					node, nodes_allowed);
+		page = alloc_fresh_huge_page(h, gfp_mask, node, nodes_allowed);
 		if (page)
 			break;
-
 	}
 
 	if (!page)
 		return 0;
 
-	if (hstate_is_gigantic(h))
-		prep_compound_gigantic_page(page, huge_page_order(h));
-	prep_new_huge_page(h, page, page_to_nid(page));
 	put_page(page); /* free it into the hugepage allocator */
 
 	return 1;
@@ -1535,7 +1550,7 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 /*
  * Allocates a fresh surplus page from the page allocator.
  */
-static struct page *__alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
+static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 		int nid, nodemask_t *nmask)
 {
 	struct page *page = NULL;
@@ -1548,7 +1563,7 @@ static struct page *__alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 		goto out_unlock;
 	spin_unlock(&hugetlb_lock);
 
-	page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask, nid, nmask);
+	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask);
 	if (!page)
 		goto out_unlock;
 
@@ -1567,12 +1582,6 @@ static struct page *__alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 	} else {
 		h->surplus_huge_pages_node[page_to_nid(page)]++;
 		h->surplus_huge_pages++;
-		INIT_LIST_HEAD(&page->lru);
-		r_nid = page_to_nid(page);
-		set_compound_page_dtor(page, HUGETLB_PAGE_DTOR);
-		set_hugetlb_cgroup(page, NULL);
-		h->nr_huge_pages_node[r_nid]++;
-		h->surplus_huge_pages_node[r_nid]++;
 	}
 
 out_unlock:
@@ -1581,7 +1590,7 @@ static struct page *__alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 	return page;
 }
 
-static struct page *__alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
+static struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
 		int nid, nodemask_t *nmask)
 {
 	struct page *page;
@@ -1589,7 +1598,7 @@ static struct page *__alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
 	if (hstate_is_gigantic(h))
 		return NULL;
 
-	page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask, nid, nmask);
+	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask);
 	if (!page)
 		return NULL;
 
@@ -1597,7 +1606,6 @@ static struct page *__alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
 	 * We do not account these pages as surplus because they are only
 	 * temporary and will be released properly on the last reference
 	 */
-	prep_new_huge_page(h, page, page_to_nid(page));
 	SetPageHugeTemporary(page);
 
 	return page;
@@ -1607,7 +1615,7 @@ static struct page *__alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
  * Use the VMA's mpolicy to allocate a huge page from the buddy.
  */
 static
-struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
+struct page *alloc_buddy_huge_page_with_mpol(struct hstate *h,
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	struct page *page;
@@ -1617,7 +1625,7 @@ struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
 	nodemask_t *nodemask;
 
 	nid = huge_node(vma, addr, gfp_mask, &mpol, &nodemask);
-	page = __alloc_surplus_huge_page(h, gfp_mask, nid, nodemask);
+	page = alloc_surplus_huge_page(h, gfp_mask, nid, nodemask);
 	mpol_cond_put(mpol);
 
 	return page;
@@ -1638,7 +1646,7 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
 	spin_unlock(&hugetlb_lock);
 
 	if (!page)
-		page = __alloc_migrate_huge_page(h, gfp_mask, nid, NULL);
+		page = alloc_migrate_huge_page(h, gfp_mask, nid, NULL);
 
 	return page;
 }
@@ -1661,7 +1669,7 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 	}
 	spin_unlock(&hugetlb_lock);
 
-	return __alloc_migrate_huge_page(h, gfp_mask, preferred_nid, nmask);
+	return alloc_migrate_huge_page(h, gfp_mask, preferred_nid, nmask);
 }
 
 /*
@@ -1689,7 +1697,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
-		page = __alloc_surplus_huge_page(h, htlb_alloc_mask(h),
+		page = alloc_surplus_huge_page(h, htlb_alloc_mask(h),
 				NUMA_NO_NODE, NULL);
 		if (!page) {
 			alloc_ok = false;
@@ -2026,7 +2034,7 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, gbl_chg);
 	if (!page) {
 		spin_unlock(&hugetlb_lock);
-		page = __alloc_buddy_huge_page_with_mpol(h, vma, addr);
+		page = alloc_buddy_huge_page_with_mpol(h, vma, addr);
 		if (!page)
 			goto out_uncharge_cgroup;
 		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
@@ -2166,7 +2174,7 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 		if (hstate_is_gigantic(h)) {
 			if (!alloc_bootmem_huge_page(h))
 				break;
-		} else if (!alloc_fresh_huge_page(h,
+		} else if (!alloc_pool_huge_page(h,
 					 &node_states[N_MEMORY]))
 			break;
 		cond_resched();
@@ -2286,7 +2294,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * First take pages out of surplus state.  Then make up the
 	 * remaining difference by allocating fresh huge pages.
 	 *
-	 * We might race with __alloc_surplus_huge_page() here and be unable
+	 * We might race with alloc_surplus_huge_page() here and be unable
 	 * to convert a surplus huge page to a normal huge page. That is
 	 * not critical, though, it just means the overall size of the
 	 * pool might be one hugepage larger than it needs to be, but
@@ -2309,7 +2317,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 		/* yield cpu to avoid soft lockup */
 		cond_resched();
 
-		ret = alloc_fresh_huge_page(h, nodes_allowed);
+		ret = alloc_pool_huge_page(h, nodes_allowed);
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
@@ -2329,7 +2337,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * By placing pages into the surplus state independent of the
 	 * overcommit value, we are allowing the surplus pool size to
 	 * exceed overcommit. There are few sane options here. Since
-	 * __alloc_surplus_huge_page() is checking the global counter,
+	 * alloc_surplus_huge_page() is checking the global counter,
 	 * though, we'll note that we're not allowed to exceed surplus
 	 * and won't grow the pool anywhere else. Not until one of the
 	 * sysctls are changed, or the surplus pages go out of use.
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
