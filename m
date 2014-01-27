Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id EA6786B003D
	for <linux-mm@kvack.org>; Sun, 26 Jan 2014 22:53:06 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id vb8so5909966obc.18
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 19:53:06 -0800 (PST)
Received: from g4t0014.houston.hp.com (g4t0014.houston.hp.com. [15.201.24.17])
        by mx.google.com with ESMTPS id us4si4470751obc.135.2014.01.26.19.53.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 26 Jan 2014 19:53:05 -0800 (PST)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 7/8] mm, hugetlb: mm, hugetlb: unify chg and avoid_reserve to use_reserve
Date: Sun, 26 Jan 2014 19:52:25 -0800
Message-Id: <1390794746-16755-8-git-send-email-davidlohr@hp.com>
In-Reply-To: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, dhillf@gmail.com, rientjes@google.com, davidlohr@hp.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, we have two variable to represent whether we can use reserved
page or not, chg and avoid_reserve, respectively. With aggregating these,
we can have more clean code. This makes no functional difference.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 mm/hugetlb.c | 31 +++++++++++--------------------
 1 file changed, 11 insertions(+), 20 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 83bc161..5f3efa5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -508,8 +508,7 @@ static inline gfp_t htlb_alloc_mask(struct hstate *h)
 
 static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
-				unsigned long address, int avoid_reserve,
-				long chg)
+				unsigned long address, bool use_reserve)
 {
 	struct page *page = NULL;
 	struct mempolicy *mpol;
@@ -523,14 +522,10 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	 * A child process with MAP_PRIVATE mappings created by their parent
 	 * have no page reserves. This check ensures that reservations are
 	 * not "stolen". The child may still get SIGKILLed.
-	 * chg represents whether current user has a reserved hugepages or not,
-	 * so that we can use it to ensure that reservations are not "stolen".
+	 * Or, when parent process do COW, we cannot use reserved page.
+	 * In this case, ensure enough pages are in the pool.
 	 */
-	if (chg && h->free_huge_pages - h->resv_huge_pages == 0)
-		goto err;
-
-	/* If reserves cannot be used, ensure enough pages are in the pool */
-	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
+	if (!use_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
 		goto err;
 
 retry_cpuset:
@@ -543,13 +538,7 @@ retry_cpuset:
 		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask(h))) {
 			page = dequeue_huge_page_node(h, zone_to_nid(zone));
 			if (page) {
-				if (avoid_reserve)
-					break;
-				/*
-				 * chg means whether current user allocates
-				 * a hugepage on the reserved pool or not
-				 */
-				if (chg)
+				if (!use_reserve)
 					break;
 
 				SetPagePrivate(page);
@@ -1185,6 +1174,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	struct hstate *h = hstate_vma(vma);
 	struct page *page;
 	long chg;
+	bool use_reserve;
 	int ret, idx;
 	struct hugetlb_cgroup *h_cg;
 
@@ -1200,18 +1190,19 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	chg = vma_needs_reservation(h, vma, addr);
 	if (chg < 0)
 		return ERR_PTR(-ENOMEM);
-	if (chg || avoid_reserve)
+	use_reserve = (!chg && !avoid_reserve);
+	if (!use_reserve)
 		if (hugepage_subpool_get_pages(spool, 1))
 			return ERR_PTR(-ENOSPC);
 
 	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
 	if (ret) {
-		if (chg || avoid_reserve)
+		if (!use_reserve)
 			hugepage_subpool_put_pages(spool, 1);
 		return ERR_PTR(-ENOSPC);
 	}
 	spin_lock(&hugetlb_lock);
-	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
+	page = dequeue_huge_page_vma(h, vma, addr, use_reserve);
 	if (!page) {
 		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
@@ -1219,7 +1210,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 			hugetlb_cgroup_uncharge_cgroup(idx,
 						       pages_per_huge_page(h),
 						       h_cg);
-			if (chg || avoid_reserve)
+			if (!use_reserve)
 				hugepage_subpool_put_pages(spool, 1);
 			return ERR_PTR(-ENOSPC);
 		}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
