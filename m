Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 28DFC6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 03:11:15 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1309142pab.36
        for <linux-mm@kvack.org>; Wed, 14 May 2014 00:11:14 -0700 (PDT)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id rw8si512705pbc.147.2014.05.14.00.11.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 00:11:14 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so1336480pbb.3
        for <linux-mm@kvack.org>; Wed, 14 May 2014 00:11:14 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] mm, hugetlb: move the error handle logic out of normal code path
Date: Wed, 14 May 2014 15:10:59 +0800
Message-Id: <1400051459-20578-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.cz, aarcange@redhat.com, steve.capper@linaro.org, davidlohr@hp.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

alloc_huge_page() now mixes normal code path with error handle logic.
This patches move out the error handle logic, to make normal code
path more clean and redue code duplicate.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/hugetlb.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 26b1464..e81c69e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1246,24 +1246,17 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 			return ERR_PTR(-ENOSPC);
 
 	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
-	if (ret) {
-		if (chg || avoid_reserve)
-			hugepage_subpool_put_pages(spool, 1);
-		return ERR_PTR(-ENOSPC);
-	}
+	if (ret)
+		goto out_subpool_put;
+
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
 	if (!page) {
 		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
-		if (!page) {
-			hugetlb_cgroup_uncharge_cgroup(idx,
-						       pages_per_huge_page(h),
-						       h_cg);
-			if (chg || avoid_reserve)
-				hugepage_subpool_put_pages(spool, 1);
-			return ERR_PTR(-ENOSPC);
-		}
+		if (!page)
+			goto out_uncharge_cgroup;
+
 		spin_lock(&hugetlb_lock);
 		list_move(&page->lru, &h->hugepage_activelist);
 		/* Fall through */
@@ -1275,6 +1268,13 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 
 	vma_commit_reservation(h, vma, addr);
 	return page;
+
+out_uncharge_cgroup:
+	hugetlb_cgroup_uncharge_cgroup(idx, pages_per_huge_page(h), h_cg);
+out_subpool_put:
+	if (chg || avoid_reserve)
+		hugepage_subpool_put_pages(spool, 1);
+	return ERR_PTR(-ENOSPC);
 }
 
 /*
-- 
2.0.0-rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
