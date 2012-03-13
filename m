Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A141D6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 03:08:28 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 13 Mar 2012 12:38:24 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2D78I5u3911818
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 12:38:20 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2DCc4a5007891
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 18:08:05 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V3 3/8] hugetlb: add charge/uncharge calls for HugeTLB alloc/free
Date: Tue, 13 Mar 2012 12:37:07 +0530
Message-Id: <1331622432-24683-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This adds necessary charge/uncharge calls in the HugeTLB code

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c    |   21 ++++++++++++++++++++-
 mm/memcontrol.c |    5 +++++
 2 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index fe7aefd..b7152d1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -21,6 +21,8 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/memcontrol.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -542,6 +544,9 @@ static void free_huge_page(struct page *page)
 	BUG_ON(page_mapcount(page));
 	INIT_LIST_HEAD(&page->lru);
 
+	if (mapping)
+		mem_cgroup_hugetlb_uncharge_page(h - hstates,
+						 pages_per_huge_page(h), page);
 	spin_lock(&hugetlb_lock);
 	if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
 		update_and_free_page(h, page);
@@ -1019,12 +1024,15 @@ static void vma_commit_reservation(struct hstate *h,
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr, int avoid_reserve)
 {
+	int ret, idx;
 	struct hstate *h = hstate_vma(vma);
 	struct page *page;
+	struct mem_cgroup *memcg = NULL;
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
 	long chg;
 
+	idx = h - hstates;
 	/*
 	 * Processes that did not create the mapping will have no reserves and
 	 * will not have accounted against quota. Check that the quota can be
@@ -1039,6 +1047,12 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		if (hugetlb_get_quota(inode->i_mapping, chg))
 			return ERR_PTR(-VM_FAULT_SIGBUS);
 
+	ret = mem_cgroup_hugetlb_charge_page(idx, pages_per_huge_page(h),
+					     &memcg);
+	if (ret) {
+		hugetlb_put_quota(inode->i_mapping, chg);
+		return ERR_PTR(-VM_FAULT_SIGBUS);
+	}
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
 	spin_unlock(&hugetlb_lock);
@@ -1046,6 +1060,9 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	if (!page) {
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
+			mem_cgroup_hugetlb_uncharge_memcg(idx,
+							 pages_per_huge_page(h),
+							 memcg);
 			hugetlb_put_quota(inode->i_mapping, chg);
 			return ERR_PTR(-VM_FAULT_SIGBUS);
 		}
@@ -1054,7 +1071,9 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	set_page_private(page, (unsigned long) mapping);
 
 	vma_commit_reservation(h, vma, addr);
-
+	/* update page cgroup details */
+	mem_cgroup_hugetlb_commit_charge(idx, pages_per_huge_page(h),
+					 memcg, page);
 	return page;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8cac77b..f4aa11c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2901,6 +2901,11 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 
 	if (PageSwapCache(page))
 		return NULL;
+	/*
+	 * HugeTLB page uncharge happen in the HugeTLB compound page destructor
+	 */
+	if (PageHuge(page))
+		return NULL;
 
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
