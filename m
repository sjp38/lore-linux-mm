Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id BCDFA6B0038
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 05:27:10 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 03/20] mm, hugetlb: fix subpool accounting handling
Date: Fri,  9 Aug 2013 18:26:21 +0900
Message-Id: <1376040398-11212-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If we alloc hugepage with avoid_reserve, we don't dequeue reserved one.
So, we should check subpool counter when avoid_reserve.
This patch implement it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 12b6581..ea1ae0a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1144,13 +1144,14 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	chg = vma_needs_reservation(h, vma, addr);
 	if (chg < 0)
 		return ERR_PTR(-ENOMEM);
-	if (chg)
-		if (hugepage_subpool_get_pages(spool, chg))
+	if (chg || avoid_reserve)
+		if (hugepage_subpool_get_pages(spool, 1))
 			return ERR_PTR(-ENOSPC);
 
 	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
 	if (ret) {
-		hugepage_subpool_put_pages(spool, chg);
+		if (chg || avoid_reserve)
+			hugepage_subpool_put_pages(spool, 1);
 		return ERR_PTR(-ENOSPC);
 	}
 	spin_lock(&hugetlb_lock);
@@ -1162,7 +1163,8 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 			hugetlb_cgroup_uncharge_cgroup(idx,
 						       pages_per_huge_page(h),
 						       h_cg);
-			hugepage_subpool_put_pages(spool, chg);
+			if (chg || avoid_reserve)
+				hugepage_subpool_put_pages(spool, 1);
 			return ERR_PTR(-ENOSPC);
 		}
 		spin_lock(&hugetlb_lock);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
