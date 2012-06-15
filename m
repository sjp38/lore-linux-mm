Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 1F0A86B0062
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 06:31:31 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 11:18:49 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FAVA7N47579180
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 20:31:11 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FAVAWq018459
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 20:31:10 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 2/2] hugetlb/cgroup: Assign the page hugetlb cgroup when we move the page to active list.
Date: Fri, 15 Jun 2012 16:01:03 +0530
Message-Id: <1339756263-20378-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339756263-20378-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339756263-20378-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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
 mm/hugetlb.c        |   14 +++++++++-----
 mm/hugetlb_cgroup.c |    3 +--
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ec7b86e..10160cb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1150,9 +1150,13 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
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
@@ -1163,14 +1167,14 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		}
 		spin_lock(&hugetlb_lock);
 		list_move(&page->lru, &h->hugepage_activelist);
+		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h),
+					     h_cg, page);
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
