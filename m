Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 990EE9003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 14:10:55 -0400 (EDT)
Received: by ykax123 with SMTP id x123so173066769yka.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 11:10:55 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n63si17205250ywn.87.2015.07.21.11.10.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 11:10:54 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v4 07/10] mm/hugetlb: alloc_huge_page handle areas hole punched by fallocate
Date: Tue, 21 Jul 2015 11:09:41 -0700
Message-Id: <1437502184-14269-8-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

Areas hole punched by fallocate will not have entries in the
region/reserve map.  However, shared mappings with min_size subpool
reservations may still have reserved pages.  alloc_huge_page needs
to handle this special case and do the proper accounting.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 54 +++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 39 insertions(+), 15 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f9d3faf..efcd58c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1735,34 +1735,58 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	struct hugepage_subpool *spool = subpool_vma(vma);
 	struct hstate *h = hstate_vma(vma);
 	struct page *page;
-	long chg, commit;
+	long map_chg, map_commit;
+	long gbl_chg;
 	int ret, idx;
 	struct hugetlb_cgroup *h_cg;
 
 	idx = hstate_index(h);
 	/*
-	 * Processes that did not create the mapping will have no
-	 * reserves and will not have accounted against subpool
-	 * limit. Check that the subpool limit can be made before
-	 * satisfying the allocation MAP_NORESERVE mappings may also
-	 * need pages and subpool limit allocated allocated if no reserve
-	 * mapping overlaps.
+	 * Examine the region/reserve map to determine if the process
+	 * has a reservation for the page to be allocated.  A return
+	 * code of zero indicates a reservation exists (no change).
 	 */
-	chg = vma_needs_reservation(h, vma, addr);
-	if (chg < 0)
+	map_chg = gbl_chg = vma_needs_reservation(h, vma, addr);
+	if (map_chg < 0)
 		return ERR_PTR(-ENOMEM);
-	if (chg || avoid_reserve)
-		if (hugepage_subpool_get_pages(spool, 1) < 0) {
+
+	/*
+	 * Processes that did not create the mapping will have no
+	 * reserves as indicated by the region/reserve map. Check
+	 * that the allocation will not exceed the subpool limit.
+	 * Allocations for MAP_NORESERVE mappings also need to be
+	 * checked against any subpool limit.
+	 */
+	if (map_chg || avoid_reserve) {
+		gbl_chg = hugepage_subpool_get_pages(spool, 1);
+		if (gbl_chg < 0) {
 			vma_end_reservation(h, vma, addr);
 			return ERR_PTR(-ENOSPC);
 		}
 
+		/*
+		 * Even though there was no reservation in the region/reserve
+		 * map, there could be reservations associated with the
+		 * subpool that can be used.  This would be indicated if the
+		 * return value of hugepage_subpool_get_pages() is zero.
+		 * However, if avoid_reserve is specified we still avoid even
+		 * the subpool reservations.
+		 */
+		if (avoid_reserve)
+			gbl_chg = 1;
+	}
+
 	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
 	if (ret)
 		goto out_subpool_put;
 
 	spin_lock(&hugetlb_lock);
-	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
+	/*
+	 * glb_chg is passed to indicate whether or not a page must be taken
+	 * from the global free pool (global change).  gbl_chg == 0 indicates
+	 * a reservation exists for the allocation.
+	 */
+	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, gbl_chg);
 	if (!page) {
 		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
@@ -1778,8 +1802,8 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 
 	set_page_private(page, (unsigned long)spool);
 
-	commit = vma_commit_reservation(h, vma, addr);
-	if (unlikely(chg > commit)) {
+	map_commit = vma_commit_reservation(h, vma, addr);
+	if (unlikely(map_chg > map_commit)) {
 		/*
 		 * The page was added to the reservation map between
 		 * vma_needs_reservation and vma_commit_reservation.
@@ -1799,7 +1823,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 out_uncharge_cgroup:
 	hugetlb_cgroup_uncharge_cgroup(idx, pages_per_huge_page(h), h_cg);
 out_subpool_put:
-	if (chg || avoid_reserve)
+	if (map_chg || avoid_reserve)
 		hugepage_subpool_put_pages(spool, 1);
 	vma_end_reservation(h, vma, addr);
 	return ERR_PTR(-ENOSPC);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
