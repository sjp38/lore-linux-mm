Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 1C0EC6B00B0
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:52:52 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/9] mm, hugetlb: clean-up alloc_huge_page()
Date: Mon, 15 Jul 2013 18:52:41 +0900
Message-Id: <1373881967-16153-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can unify some codes for succeed allocation.
This makes code more readable.
There is no functional difference.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d21a33a..0067cf4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1144,29 +1144,25 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		hugepage_subpool_put_pages(spool, chg);
 		return ERR_PTR(-ENOSPC);
 	}
+
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
-	if (page) {
-		/* update page cgroup details */
-		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h),
-					     h_cg, page);
-		spin_unlock(&hugetlb_lock);
-	} else {
+	if (!page) {
 		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
 			hugetlb_cgroup_uncharge_cgroup(idx,
-						       pages_per_huge_page(h),
-						       h_cg);
+						pages_per_huge_page(h), h_cg);
 			hugepage_subpool_put_pages(spool, chg);
 			return ERR_PTR(-ENOSPC);
 		}
+
 		spin_lock(&hugetlb_lock);
-		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h),
-					     h_cg, page);
 		list_move(&page->lru, &h->hugepage_activelist);
-		spin_unlock(&hugetlb_lock);
+		/* Fall through */
 	}
+	hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
+	spin_unlock(&hugetlb_lock);
 
 	set_page_private(page, (unsigned long)spool);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
