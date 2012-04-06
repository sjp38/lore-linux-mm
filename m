Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 272596B00E9
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 14:51:44 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 7 Apr 2012 00:21:41 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q36IpbqB3629268
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 00:21:38 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q370M6Gh007768
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 10:22:06 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 08/14] hugetlb: add charge/uncharge calls for HugeTLB alloc/free
Date: Sat,  7 Apr 2012 00:20:54 +0530
Message-Id: <1333738260-1329-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This adds necessary charge/uncharge calls in the HugeTLB code. We do
memcg charge in page alloc and uncharge in compound page destructor.
We also need to ignore HugeTLB pages in __mem_cgroup_uncharge_common
because that get called from delete_from_page_cache

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Hillf Danton <dhillf@gmail.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c    |   20 +++++++++++++++++++-
 mm/memcontrol.c |    5 +++++
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8cd89b4..dd00087 100644
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
@@ -628,6 +630,8 @@ static void free_huge_page(struct page *page)
 	BUG_ON(page_mapcount(page));
 	INIT_LIST_HEAD(&page->lru);
 
+	mem_cgroup_hugetlb_uncharge_page(hstate_index(h),
+					 pages_per_huge_page(h), page);
 	spin_lock(&hugetlb_lock);
 	if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
 		update_and_free_page(h, page);
@@ -1113,7 +1117,10 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	struct hstate *h = hstate_vma(vma);
 	struct page *page;
 	long chg;
+	int ret, idx;
+	struct mem_cgroup *memcg;
 
+	idx = hstate_index(h);
 	/*
 	 * Processes that did not create the mapping will have no
 	 * reserves and will not have accounted against subpool
@@ -1129,6 +1136,12 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		if (hugepage_subpool_get_pages(spool, chg))
 			return ERR_PTR(-ENOSPC);
 
+	ret = mem_cgroup_hugetlb_charge_page(idx, pages_per_huge_page(h),
+					     &memcg);
+	if (ret) {
+		hugepage_subpool_put_pages(spool, chg);
+		return ERR_PTR(-ENOSPC);
+	}
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
 	spin_unlock(&hugetlb_lock);
@@ -1136,6 +1149,9 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	if (!page) {
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
+			mem_cgroup_hugetlb_uncharge_memcg(idx,
+							  pages_per_huge_page(h),
+							  memcg);
 			hugepage_subpool_put_pages(spool, chg);
 			return ERR_PTR(-ENOSPC);
 		}
@@ -1144,7 +1160,9 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	set_page_private(page, (unsigned long)spool);
 
 	vma_commit_reservation(h, vma, addr);
-
+	/* update page cgroup details */
+	mem_cgroup_hugetlb_commit_charge(idx, pages_per_huge_page(h),
+					 memcg, page);
 	return page;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1a2e041..0a1f776 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2966,6 +2966,11 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 
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
1.7.10.rc3.3.g19a6c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
