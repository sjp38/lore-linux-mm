Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 107DC6B0078
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 05:00:51 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 9 Jun 2012 14:30:48 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5990iaN15139188
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 14:30:45 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q59EU02x030873
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 00:30:01 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V8 14/16] hugetlb/cgroup: add charge/uncharge calls for HugeTLB alloc/free
Date: Sat,  9 Jun 2012 14:29:59 +0530
Message-Id: <1339232401-14392-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This adds necessary charge/uncharge calls in the HugeTLB code.  We do
hugetlb cgroup charge in page alloc and uncharge in compound page destructor.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c        |   16 +++++++++++++++-
 mm/hugetlb_cgroup.c |    7 +------
 2 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bf79131..4ca92a9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -628,6 +628,8 @@ static void free_huge_page(struct page *page)
 	BUG_ON(page_mapcount(page));
 
 	spin_lock(&hugetlb_lock);
+	hugetlb_cgroup_uncharge_page(hstate_index(h),
+				     pages_per_huge_page(h), page);
 	if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
 		/* remove the page from active list */
 		list_del(&page->lru);
@@ -1116,7 +1118,10 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	struct hstate *h = hstate_vma(vma);
 	struct page *page;
 	long chg;
+	int ret, idx;
+	struct hugetlb_cgroup *h_cg;
 
+	idx = hstate_index(h);
 	/*
 	 * Processes that did not create the mapping will have no
 	 * reserves and will not have accounted against subpool
@@ -1132,6 +1137,11 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		if (hugepage_subpool_get_pages(spool, chg))
 			return ERR_PTR(-ENOSPC);
 
+	ret = hugetlb_cgroup_charge_page(idx, pages_per_huge_page(h), &h_cg);
+	if (ret) {
+		hugepage_subpool_put_pages(spool, chg);
+		return ERR_PTR(-ENOSPC);
+	}
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
 	spin_unlock(&hugetlb_lock);
@@ -1139,6 +1149,9 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	if (!page) {
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
+			hugetlb_cgroup_uncharge_cgroup(idx,
+						       pages_per_huge_page(h),
+						       h_cg);
 			hugepage_subpool_put_pages(spool, chg);
 			return ERR_PTR(-ENOSPC);
 		}
@@ -1147,7 +1160,8 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	set_page_private(page, (unsigned long)spool);
 
 	vma_commit_reservation(h, vma, addr);
-
+	/* update page cgroup details */
+	hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
 	return page;
 }
 
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 2a4881d..c2b7b8e 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -249,15 +249,10 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
 	if (hugetlb_cgroup_disabled())
 		return;
 
-	spin_lock(&hugetlb_lock);
 	h_cg = hugetlb_cgroup_from_page(page);
-	if (unlikely(!h_cg)) {
-		spin_unlock(&hugetlb_lock);
+	if (unlikely(!h_cg))
 		return;
-	}
 	set_hugetlb_cgroup(page, NULL);
-	spin_unlock(&hugetlb_lock);
-
 	res_counter_uncharge(&h_cg->hugepage[idx], csize);
 	return;
 }
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
