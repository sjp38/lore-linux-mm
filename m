Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7636C6B0313
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 05:00:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g76so28212066wrd.3
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 02:00:54 -0700 (PDT)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id r195si5491757wmd.24.2017.06.13.02.00.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 02:00:53 -0700 (PDT)
Received: by mail-wr0-f195.google.com with SMTP id v104so27755460wrb.0
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 02:00:52 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 2/4] hugetlb: add support for preferred node to alloc_huge_page_nodemask
Date: Tue, 13 Jun 2017 11:00:37 +0200
Message-Id: <20170613090039.14393-3-mhocko@kernel.org>
In-Reply-To: <20170613090039.14393-1-mhocko@kernel.org>
References: <20170613090039.14393-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

alloc_huge_page_nodemask tries to allocate from any numa node in the
allowed node mask starting from lower numa nodes. This might lead to
filling up those low NUMA nodes while others are not used. We can reduce
this risk by introducing a concept of the preferred node similar to what
we have in the regular page allocator. We will start allocating from the
preferred nid and then iterate over all allowed nodes in the zonelist
order until we try them all.

This is mimicking the page allocator logic except it operates on
per-node mempools. dequeue_huge_page_vma already does this so distill
the zonelist logic into a more generic dequeue_huge_page_nodemask
and use it in alloc_huge_page_nodemask.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/hugetlb.h |   3 +-
 include/linux/migrate.h |   2 +-
 mm/hugetlb.c            | 106 +++++++++++++++++++++++++-----------------------
 3 files changed, 59 insertions(+), 52 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 016831fcdca1..d4c33a8583be 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -349,7 +349,8 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 struct page *alloc_huge_page_node(struct hstate *h, int nid);
 struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
-struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask);
+struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
+				nodemask_t *nmask);
 int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 			pgoff_t idx);
 
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f80c9882403a..af3ccf93efaa 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -38,7 +38,7 @@ static inline struct page *new_page_nodemask(struct page *page, int preferred_ni
 
 	if (PageHuge(page))
 		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
-				nodemask);
+				preferred_nid, nodemask);
 
 	if (PageHighMem(page)
 	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3d5f25d589b3..696de029f0fa 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -897,29 +897,58 @@ static struct page *dequeue_huge_page_node_exact(struct hstate *h, int nid)
 	return page;
 }
 
-static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
+/* Movability of hugepages depends on migration support. */
+static inline gfp_t htlb_alloc_mask(struct hstate *h)
 {
-	struct page *page;
-	int node;
+	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
+		return GFP_HIGHUSER_MOVABLE;
+	else
+		return GFP_HIGHUSER;
+}
 
-	if (nid != NUMA_NO_NODE)
-		return dequeue_huge_page_node_exact(h, nid);
+static struct page *dequeue_huge_page_nodemask(struct hstate *h, int nid,
+		nodemask_t *nmask)
+{
+	unsigned int cpuset_mems_cookie;
+	struct zonelist *zonelist;
+	struct page *page = NULL;
+	struct zone *zone;
+	struct zoneref *z;
+	gfp_t gfp_mask;
+	int node = -1;
+
+	gfp_mask = htlb_alloc_mask(h);
+	zonelist = node_zonelist(nid, gfp_mask);
+
+retry_cpuset:
+	cpuset_mems_cookie = read_mems_allowed_begin();
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), nmask) {
+		if (!cpuset_zone_allowed(zone, gfp_mask))
+			continue;
+		/*
+		 * no need to ask again on the same node. Pool is node rather than
+		 * zone aware
+		 */
+		if (zone_to_nid(zone) == node)
+			continue;
+		node = zone_to_nid(zone);
 
-	for_each_online_node(node) {
 		page = dequeue_huge_page_node_exact(h, node);
 		if (page)
-			return page;
+			break;
 	}
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
+		goto retry_cpuset;
+
 	return NULL;
 }
 
-/* Movability of hugepages depends on migration support. */
-static inline gfp_t htlb_alloc_mask(struct hstate *h)
+static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
 {
-	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
-		return GFP_HIGHUSER_MOVABLE;
-	else
-		return GFP_HIGHUSER;
+	if (nid != NUMA_NO_NODE)
+		return dequeue_huge_page_node_exact(h, nid);
+
+	return dequeue_huge_page_nodemask(h, nid, NULL);
 }
 
 static struct page *dequeue_huge_page_vma(struct hstate *h,
@@ -927,15 +956,10 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 				unsigned long address, int avoid_reserve,
 				long chg)
 {
-	struct page *page = NULL;
+	struct page *page;
 	struct mempolicy *mpol;
 	nodemask_t *nodemask;
-	gfp_t gfp_mask;
 	int nid;
-	struct zonelist *zonelist;
-	struct zone *zone;
-	struct zoneref *z;
-	unsigned int cpuset_mems_cookie;
 
 	/*
 	 * A child process with MAP_PRIVATE mappings created by their parent
@@ -950,32 +974,14 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
 		goto err;
 
-retry_cpuset:
-	cpuset_mems_cookie = read_mems_allowed_begin();
-	gfp_mask = htlb_alloc_mask(h);
-	nid = huge_node(vma, address, gfp_mask, &mpol, &nodemask);
-	zonelist = node_zonelist(nid, gfp_mask);
-
-	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-						MAX_NR_ZONES - 1, nodemask) {
-		if (cpuset_zone_allowed(zone, gfp_mask)) {
-			page = dequeue_huge_page_node(h, zone_to_nid(zone));
-			if (page) {
-				if (avoid_reserve)
-					break;
-				if (!vma_has_reserves(vma, chg))
-					break;
-
-				SetPagePrivate(page);
-				h->resv_huge_pages--;
-				break;
-			}
-		}
+	nid = huge_node(vma, address, htlb_alloc_mask(h), &mpol, &nodemask);
+	page = dequeue_huge_page_nodemask(h, nid, nodemask);
+	if (page && !avoid_reserve && vma_has_reserves(vma, chg)) {
+		SetPagePrivate(page);
+		h->resv_huge_pages--;
 	}
 
 	mpol_cond_put(mpol);
-	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
-		goto retry_cpuset;
 	return page;
 
 err:
@@ -1655,25 +1661,25 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
 	return page;
 }
 
-struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask)
+
+struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
+		nodemask_t *nmask)
 {
 	struct page *page = NULL;
-	int node;
 
 	spin_lock(&hugetlb_lock);
 	if (h->free_huge_pages - h->resv_huge_pages > 0) {
-		for_each_node_mask(node, *nmask) {
-			page = dequeue_huge_page_node_exact(h, node);
-			if (page)
-				break;
-		}
+		page = dequeue_huge_page_nodemask(h, preferred_nid, nmask);
+		if (page)
+			goto unlock;
 	}
+unlock:
 	spin_unlock(&hugetlb_lock);
 	if (page)
 		return page;
 
 	/* No reservations, try to overcommit */
-	return __alloc_buddy_huge_page(h, NUMA_NO_NODE, nmask);
+	return __alloc_buddy_huge_page(h, preferred_nid, nmask);
 }
 
 /*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
