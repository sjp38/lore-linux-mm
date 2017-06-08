Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 203E36B02C3
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 03:46:10 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k30so4023757wrc.9
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 00:46:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y133sor638256wmg.24.2017.06.08.00.46.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Jun 2017 00:46:08 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/4] hugetlb, memory_hotplug: prefer to use reserved pages for migration
Date: Thu,  8 Jun 2017 09:45:51 +0200
Message-Id: <20170608074553.22152-3-mhocko@kernel.org>
In-Reply-To: <20170608074553.22152-1-mhocko@kernel.org>
References: <20170608074553.22152-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

new_node_page will try to use the origin's next NUMA node as the
migration destination for hugetlb pages. If such a node doesn't have any
preallocated pool it falls back to __alloc_buddy_huge_page_no_mpol to
allocate a surplus page instead. This is quite subotpimal for any
configuration when hugetlb pages are no distributed to all NUMA nodes
evenly. Say we have a hotplugable node 4 and spare hugetlb pages are
node 0
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:10000
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node2/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node3/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node4/hugepages/hugepages-2048kB/nr_hugepages:10000
/sys/devices/system/node/node5/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node6/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node7/hugepages/hugepages-2048kB/nr_hugepages:0

Now we consume the whole pool on node 4 and try to offline this
node. All the allocated pages should be moved to node0 which has enough
preallocated pages to hold them. With the current implementation
offlining very likely fails because hugetlb allocations during runtime
are much less reliable.

Fix this by reusing the nodemask which excludes migration source and try
to find a first node which has a page in the preallocated pool first and
fall back to __alloc_buddy_huge_page_no_mpol only when the whole pool is
consumed.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/hugetlb.h |  2 ++
 mm/hugetlb.c            | 27 +++++++++++++++++++++++++++
 mm/memory_hotplug.c     |  9 ++-------
 3 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index dbb118c566cd..c469191bb13b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -349,6 +349,7 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 struct page *alloc_huge_page_node(struct hstate *h, int nid);
 struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
+struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask);
 int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 			pgoff_t idx);
 
@@ -524,6 +525,7 @@ static inline void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr
 struct hstate {};
 #define alloc_huge_page(v, a, r) NULL
 #define alloc_huge_page_node(h, nid) NULL
+#define alloc_huge_page_nodemask(h, preferred_nid, nmask) NULL
 #define alloc_huge_page_noerr(v, a, r) NULL
 #define alloc_bootmem_huge_page(h) NULL
 #define hstate_file(f) NULL
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 761a669d0b62..01c11ceb47d6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1723,6 +1723,33 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
 	return page;
 }
 
+struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask)
+{
+	struct page *page = NULL;
+	int node;
+
+	spin_lock(&hugetlb_lock);
+	if (h->free_huge_pages - h->resv_huge_pages > 0) {
+		for_each_node_mask(node, *nmask) {
+			page = dequeue_huge_page_node_exact(h, node);
+			if (page)
+				break;
+		}
+	}
+	spin_unlock(&hugetlb_lock);
+	if (page)
+		return page;
+
+	/* No reservations, try to overcommit */
+	for_each_node_mask(node, *nmask) {
+		page = __alloc_buddy_huge_page_no_mpol(h, node);
+		if (page)
+			return page;
+	}
+
+	return NULL;
+}
+
 /*
  * Increase the hugetlb pool such that it can accommodate a reservation
  * of size 'delta'.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1ca373bdffbf..6e0d964ac561 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1442,14 +1442,9 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 	if (nodes_empty(nmask))
 		node_set(nid, nmask);
 
-	/*
-	 * TODO: allocate a destination hugepage from a nearest neighbor node,
-	 * accordance with memory policy of the user process if possible. For
-	 * now as a simple work-around, we use the next node for destination.
-	 */
 	if (PageHuge(page))
-		return alloc_huge_page_node(page_hstate(compound_head(page)),
-					next_node_in(nid, nmask));
+		return alloc_huge_page_nodemask(
+				page_hstate(compound_head(page)), &nmask);
 
 	if (PageHighMem(page)
 	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
