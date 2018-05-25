Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD136B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 16:16:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b25-v6so3498817pfn.10
        for <linux-mm@kvack.org>; Fri, 25 May 2018 13:16:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x14-v6sor7025020pgq.277.2018.05.25.13.16.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 May 2018 13:16:47 -0700 (PDT)
Date: Fri, 25 May 2018 13:16:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hugetlb_cgroup: suppress SIGBUS when hugetlb_cgroup
 charge fails
Message-ID: <alpine.DEB.2.21.1805251316090.167008@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When charging to a hugetlb_cgroup fails, alloc_huge_page() returns
ERR_PTR(-ENOSPC) which will cause VM_FAULT_SIGBUS to be returned to the
page fault handler.

Instead, return the proper error code, ERR_PTR(-ENOMEM), so VM_FAULT_OOM
is handled correctly.  This is consistent with failing mem cgroup charges
in the non-hugetlb fault path.

At the same time, restructure the return paths of alloc_huge_page() so it
is consistent.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/hugetlb.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2006,8 +2006,10 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	 * code of zero indicates a reservation exists (no change).
 	 */
 	map_chg = gbl_chg = vma_needs_reservation(h, vma, addr);
-	if (map_chg < 0)
-		return ERR_PTR(-ENOMEM);
+	if (map_chg < 0) {
+		ret = -ENOMEM;
+		goto out;
+	}
 
 	/*
 	 * Processes that did not create the mapping will have no
@@ -2019,8 +2021,8 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	if (map_chg || avoid_reserve) {
 		gbl_chg = hugepage_subpool_get_pages(spool, 1);
 		if (gbl_chg < 0) {
-			vma_end_reservation(h, vma, addr);
-			return ERR_PTR(-ENOSPC);
+			ret = -ENOSPC;
+			goto out_reservation;
 		}
 
 		/*
@@ -2049,8 +2051,10 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	if (!page) {
 		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page_with_mpol(h, vma, addr);
-		if (!page)
+		if (!page) {
+			ret = -ENOSPC;
 			goto out_uncharge_cgroup;
+		}
 		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
 			SetPagePrivate(page);
 			h->resv_huge_pages--;
@@ -2087,8 +2091,10 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 out_subpool_put:
 	if (map_chg || avoid_reserve)
 		hugepage_subpool_put_pages(spool, 1);
+out_reservation:
 	vma_end_reservation(h, vma, addr);
-	return ERR_PTR(-ENOSPC);
+out:
+	return ERR_PTR(ret);
 }
 
 int alloc_bootmem_huge_page(struct hstate *h)
