Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6787E6B0069
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 06:08:37 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 15:38:33 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FA8VHM9830868
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 15:38:31 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FFd92V021069
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 01:39:09 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 2/2] hugetlb/cgroup: Assign the page hugetlb cgroup when we move the page to active list.
Date: Fri, 15 Jun 2012 15:38:22 +0530
Message-Id: <1339754902-17779-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339754902-17779-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <87k3z8nb3h.fsf@skywalker.in.ibm.com>
 <1339754902-17779-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, akpm@linux-foundation.org
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

page's hugetlb cgroup assign and moving to active list should happen with
hugetlb_lock held. Otherwise when we remove the hugetlb cgroup we would
iterate the active list and will find page with NULL hugetlb cgroup values.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c        |   12 +++++++-----
 mm/hugetlb_cgroup.c |    3 +--
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ee4da3b..b90dfb4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1146,9 +1146,12 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	}
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
-	spin_unlock(&hugetlb_lock);
-
-	if (!page) {
+	if (page) {
+		/* update page cgroup details */
+		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
+		spin_unlock(&hugetlb_lock);
+	} else {
+		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
 			hugetlb_cgroup_uncharge_cgroup(idx,
@@ -1159,14 +1162,13 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		}
 		spin_lock(&hugetlb_lock);
 		list_move(&page->lru, &h->hugepage_activelist);
+		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
 		spin_unlock(&hugetlb_lock);
 	}
 
 	set_page_private(page, (unsigned long)spool);
 
 	vma_commit_reservation(h, vma, addr);
-	/* update page cgroup details */
-	hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
 	return page;
 }
 
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 8e7ca0a..d4f3f7b 100644
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
 
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
