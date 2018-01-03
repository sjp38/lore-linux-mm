Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C45FC6B031E
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 04:32:29 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id y36so601502plh.10
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 01:32:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33sor179170ply.83.2018.01.03.01.32.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 01:32:28 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/6] mm, hugetlb: unify core page allocation accounting and initialization
Date: Wed,  3 Jan 2018 10:32:08 +0100
Message-Id: <20180103093213.26329-2-mhocko@kernel.org>
In-Reply-To: <20180103093213.26329-1-mhocko@kernel.org>
References: <20180103093213.26329-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

hugetlb allocator has two entry points to the page allocator
- alloc_fresh_huge_page_node
- __hugetlb_alloc_buddy_huge_page

The two differ very subtly in two aspects. The first one doesn't care
about HTLB_BUDDY_* stats and it doesn't initialize the huge page.
prep_new_huge_page is not used because it not only initializes hugetlb
specific stuff but because it also put_page and releases the page to
the hugetlb pool which is not what is required in some contexts. This
makes things more complicated than necessary.

Simplify things by a) removing the page allocator entry point duplicity
and only keep __hugetlb_alloc_buddy_huge_page and b) make
prep_new_huge_page more reusable by removing the put_page which moves
the page to the allocator pool. All current callers are updated to call
put_page explicitly. Later patches will add new callers which won't
need it.

This patch shouldn't introduce any functional change.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/hugetlb.c | 61 +++++++++++++++++++++++++++++-------------------------------
 1 file changed, 29 insertions(+), 32 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4137fb67cd79..a8959667f539 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1157,6 +1157,7 @@ static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
 	if (page) {
 		prep_compound_gigantic_page(page, huge_page_order(h));
 		prep_new_huge_page(h, page, nid);
+		put_page(page); /* free it into the hugepage allocator */
 	}
 
 	return page;
@@ -1304,7 +1305,6 @@ static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
 	h->nr_huge_pages++;
 	h->nr_huge_pages_node[nid]++;
 	spin_unlock(&hugetlb_lock);
-	put_page(page); /* free it into the hugepage allocator */
 }
 
 static void prep_compound_gigantic_page(struct page *page, unsigned int order)
@@ -1381,41 +1381,49 @@ pgoff_t __basepage_index(struct page *page)
 	return (index << compound_order(page_head)) + compound_idx;
 }
 
-static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
+static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
+		gfp_t gfp_mask, int nid, nodemask_t *nmask)
 {
+	int order = huge_page_order(h);
 	struct page *page;
 
-	page = __alloc_pages_node(nid,
-		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
-						__GFP_RETRY_MAYFAIL|__GFP_NOWARN,
-		huge_page_order(h));
-	if (page) {
-		prep_new_huge_page(h, page, nid);
-	}
+	gfp_mask |= __GFP_COMP|__GFP_RETRY_MAYFAIL|__GFP_NOWARN;
+	if (nid == NUMA_NO_NODE)
+		nid = numa_mem_id();
+	page = __alloc_pages_nodemask(gfp_mask, order, nid, nmask);
+	if (page)
+		__count_vm_event(HTLB_BUDDY_PGALLOC);
+	else
+		__count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
 
 	return page;
 }
 
+/*
+ * Allocates a fresh page to the hugetlb allocator pool in the node interleaved
+ * manner.
+ */
 static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
 {
 	struct page *page;
 	int nr_nodes, node;
-	int ret = 0;
+	gfp_t gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
-		page = alloc_fresh_huge_page_node(h, node);
-		if (page) {
-			ret = 1;
+		page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask,
+				node, nodes_allowed);
+		if (page)
 			break;
-		}
+
 	}
 
-	if (ret)
-		count_vm_event(HTLB_BUDDY_PGALLOC);
-	else
-		count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
+	if (!page)
+		return 0;
 
-	return ret;
+	prep_new_huge_page(h, page, page_to_nid(page));
+	put_page(page); /* free it into the hugepage allocator */
+
+	return 1;
 }
 
 /*
@@ -1523,17 +1531,6 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 	return rc;
 }
 
-static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
-		gfp_t gfp_mask, int nid, nodemask_t *nmask)
-{
-	int order = huge_page_order(h);
-
-	gfp_mask |= __GFP_COMP|__GFP_RETRY_MAYFAIL|__GFP_NOWARN;
-	if (nid == NUMA_NO_NODE)
-		nid = numa_mem_id();
-	return __alloc_pages_nodemask(gfp_mask, order, nid, nmask);
-}
-
 static struct page *__alloc_buddy_huge_page(struct hstate *h, gfp_t gfp_mask,
 		int nid, nodemask_t *nmask)
 {
@@ -1589,11 +1586,9 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h, gfp_t gfp_mask,
 		 */
 		h->nr_huge_pages_node[r_nid]++;
 		h->surplus_huge_pages_node[r_nid]++;
-		__count_vm_event(HTLB_BUDDY_PGALLOC);
 	} else {
 		h->nr_huge_pages--;
 		h->surplus_huge_pages--;
-		__count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
 	}
 	spin_unlock(&hugetlb_lock);
 
@@ -2148,6 +2143,8 @@ static void __init gather_bootmem_prealloc(void)
 		prep_compound_huge_page(page, h->order);
 		WARN_ON(PageReserved(page));
 		prep_new_huge_page(h, page, page_to_nid(page));
+		put_page(page); /* free it into the hugepage allocator */
+
 		/*
 		 * If we had gigantic hugepages allocated at boot time, we need
 		 * to restore the 'stolen' pages to totalram_pages in order to
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
