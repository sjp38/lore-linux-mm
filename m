Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id E60046B0072
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:02:30 -0400 (EDT)
Received: by oihb142 with SMTP id b142so10377471oih.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:02:30 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b12si1194689oes.79.2015.06.11.14.02.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 14:02:30 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v4 PATCH 6/9] mm/hugetlb: alloc_huge_page handle areas hole punched by fallocate
Date: Thu, 11 Jun 2015 14:01:37 -0700
Message-Id: <1434056500-2434-7-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com>
References: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

Areas hole punched by fallocate will not have entries in the
region/reserve map.  However, shared mappings with min_size subpool
reservations may still have reserved pages.  alloc_huge_page needs
to handle this special case and do the proper accounting.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 48 +++++++++++++++++++++++++++---------------------
 1 file changed, 27 insertions(+), 21 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ecbaffe..9c295c9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -692,19 +692,9 @@ static int vma_has_reserves(struct vm_area_struct *vma, long chg)
 			return 0;
 	}
 
-	if (vma->vm_flags & VM_MAYSHARE) {
-		/*
-		 * We know VM_NORESERVE is not set.  Therefore, there SHOULD
-		 * be a region map for all pages.  The only situation where
-		 * there is no region map is if a hole was punched via
-		 * fallocate.  In this case, there really are no reverves to
-		 * use.  This situation is indicated if chg != 0.
-		 */
-		if (chg)
-			return 0;
-		else
-			return 1;
-	}
+	/* Shared mappings always use reserves */
+	if (vma->vm_flags & VM_MAYSHARE)
+		return 1;
 
 	/*
 	 * Only the process that called mmap() has reserves for
@@ -1601,6 +1591,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	struct hstate *h = hstate_vma(vma);
 	struct page *page;
 	long chg, commit;
+	long gbl_chg;
 	int ret, idx;
 	struct hugetlb_cgroup *h_cg;
 
@@ -1608,24 +1599,39 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	/*
 	 * Processes that did not create the mapping will have no
 	 * reserves and will not have accounted against subpool
-	 * limit. Check that the subpool limit can be made before
-	 * satisfying the allocation MAP_NORESERVE mappings may also
-	 * need pages and subpool limit allocated allocated if no reserve
-	 * mapping overlaps.
+	 * limit. Check that the subpool limit will not be exceeded
+	 * before performing the allocation.  Allocations for
+	 * MAP_NORESERVE mappings also need to be checked against
+	 * any subpool limit.
+	 *
+	 * NOTE: Shared mappings with holes punched via fallocate
+	 * may still have reservations, even without entries in the
+	 * reserve map as indicated by vma_needs_reservation.  This
+	 * would be the case if hugepage_subpool_get_pages returns
+	 * zero to indicate no changes to the global reservation count
+	 * are necessary.  In this case, pass the output of
+	 * hugepage_subpool_get_pages (zero) to dequeue_huge_page_vma
+	 * so that the page is not counted against the global limit.
+	 * For MAP_NORESERVE mappings always pass the output of
+	 * vma_needs_reservation.  For race detection and error cleanup
+	 * use output of vma_needs_reservation as well.
 	 */
-	chg = vma_needs_reservation(h, vma, addr);
+	chg = gbl_chg = vma_needs_reservation(h, vma, addr);
 	if (chg < 0)
 		return ERR_PTR(-ENOMEM);
-	if (chg || avoid_reserve)
-		if (hugepage_subpool_get_pages(spool, 1) < 0)
+	if (chg || avoid_reserve) {
+		gbl_chg = hugepage_subpool_get_pages(spool, 1);
+		if (gbl_chg < 0)
 			return ERR_PTR(-ENOSPC);
+	}
 
 	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
 	if (ret)
 		goto out_subpool_put;
 
 	spin_lock(&hugetlb_lock);
-	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
+	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve,
+					avoid_reserve ? chg : gbl_chg);
 	if (!page) {
 		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
