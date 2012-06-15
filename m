Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 409D46B0078
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 08:41:45 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 18:11:42 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FCfReo10355154
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 18:11:27 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FIB1bF024897
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 23:41:02 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V3 3/4] hugetlb/cgroup: Assign the page hugetlb cgroup when we move the page to active list.
Date: Fri, 15 Jun 2012 18:11:21 +0530
Message-Id: <1339764082-1611-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339764082-1611-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339764082-1611-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

page's hugetlb cgroup assign and moving to active list should happen with
hugetlb_lock held. Otherwise when we remove the hugetlb cgroup we would
iterate the active list and will find page with NULL hugetlb cgroup values.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c        |   22 ++++++++++------------
 mm/hugetlb_cgroup.c |    5 +++--
 2 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ec7b86e..c39e4be 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -928,14 +928,8 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
 	page = dequeue_huge_page_node(h, nid);
 	spin_unlock(&hugetlb_lock);
 
-	if (!page) {
+	if (!page)
 		page = alloc_buddy_huge_page(h, nid);
-		if (page) {
-			spin_lock(&hugetlb_lock);
-			list_move(&page->lru, &h->hugepage_activelist);
-			spin_unlock(&hugetlb_lock);
-		}
-	}
 
 	return page;
 }
@@ -1150,9 +1144,13 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	}
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
-	spin_unlock(&hugetlb_lock);
-
-	if (!page) {
+	if (page) {
+		/* update page cgroup details */
+		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h),
+					     h_cg, page);
+		spin_unlock(&hugetlb_lock);
+	} else {
+		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
 			hugetlb_cgroup_uncharge_cgroup(idx,
@@ -1162,6 +1160,8 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 			return ERR_PTR(-ENOSPC);
 		}
 		spin_lock(&hugetlb_lock);
+		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h),
+					     h_cg, page);
 		list_move(&page->lru, &h->hugepage_activelist);
 		spin_unlock(&hugetlb_lock);
 	}
@@ -1169,8 +1169,6 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	set_page_private(page, (unsigned long)spool);
 
 	vma_commit_reservation(h, vma, addr);
-	/* update page cgroup details */
-	hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
 	return page;
 }
 
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 8e7ca0a..55e109a 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -218,6 +218,7 @@ done:
 	return ret;
 }
 
+/* Should be called with hugetlb_lock held */
 void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
 				  struct hugetlb_cgroup *h_cg,
 				  struct page *page)
@@ -225,9 +226,7 @@ void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
 	if (hugetlb_cgroup_disabled() || !h_cg)
 		return;
 
-	spin_lock(&hugetlb_lock);
 	set_hugetlb_cgroup(page, h_cg);
-	spin_unlock(&hugetlb_lock);
 	return;
 }
 
@@ -391,6 +390,7 @@ int __init hugetlb_cgroup_file_init(int idx)
 void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 {
 	struct hugetlb_cgroup *h_cg;
+	struct hstate *h = page_hstate(oldhpage);
 
 	if (hugetlb_cgroup_disabled())
 		return;
@@ -403,6 +403,7 @@ void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 
 	/* move the h_cg details to new cgroup */
 	set_hugetlb_cgroup(newhpage, h_cg);
+	list_move(&newhpage->lru, &h->hugepage_activelist);
 	spin_unlock(&hugetlb_lock);
 	cgroup_release_and_wakeup_rmdir(&h_cg->css);
 	return;
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
