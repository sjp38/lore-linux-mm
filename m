Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 29F446B00ED
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 14:51:49 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 7 Apr 2012 00:21:46 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q36IpiLB4219012
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 00:21:44 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q370MCtF007967
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 10:22:13 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 11/14] hugetlbfs: Add a list for tracking in-use HugeTLB pages
Date: Sat,  7 Apr 2012 00:20:57 +0530
Message-Id: <1333738260-1329-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

hugepage_activelist will be used to track currently used HugeTLB pages.
We need to find the in-use HugeTLB pages to support memcg removal.
On memcg removal we update the page's memory cgroup to point to
parent cgroup.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h |    1 +
 mm/hugetlb.c            |   12 +++++++-----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index d008342..6bf6afc 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -200,6 +200,7 @@ struct hstate {
 	unsigned long resv_huge_pages;
 	unsigned long surplus_huge_pages;
 	unsigned long nr_overcommit_huge_pages;
+	struct list_head hugepage_activelist;
 	struct list_head hugepage_freelists[MAX_NUMNODES];
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 340e575..8a520b5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -512,7 +512,7 @@ void copy_huge_page(struct page *dst, struct page *src)
 static void enqueue_huge_page(struct hstate *h, struct page *page)
 {
 	int nid = page_to_nid(page);
-	list_add(&page->lru, &h->hugepage_freelists[nid]);
+	list_move(&page->lru, &h->hugepage_freelists[nid]);
 	h->free_huge_pages++;
 	h->free_huge_pages_node[nid]++;
 }
@@ -524,7 +524,7 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
 	if (list_empty(&h->hugepage_freelists[nid]))
 		return NULL;
 	page = list_entry(h->hugepage_freelists[nid].next, struct page, lru);
-	list_del(&page->lru);
+	list_move(&page->lru, &h->hugepage_activelist);
 	set_page_refcounted(page);
 	h->free_huge_pages--;
 	h->free_huge_pages_node[nid]--;
@@ -628,12 +628,13 @@ static void free_huge_page(struct page *page)
 	page->mapping = NULL;
 	BUG_ON(page_count(page));
 	BUG_ON(page_mapcount(page));
-	INIT_LIST_HEAD(&page->lru);
 
 	mem_cgroup_hugetlb_uncharge_page(hstate_index(h),
 					 pages_per_huge_page(h), page);
 	spin_lock(&hugetlb_lock);
 	if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
+		/* remove the page from active list */
+		list_del(&page->lru);
 		update_and_free_page(h, page);
 		h->surplus_huge_pages--;
 		h->surplus_huge_pages_node[nid]--;
@@ -646,6 +647,7 @@ static void free_huge_page(struct page *page)
 
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
 {
+	INIT_LIST_HEAD(&page->lru);
 	set_compound_page_dtor(page, free_huge_page);
 	spin_lock(&hugetlb_lock);
 	h->nr_huge_pages++;
@@ -894,6 +896,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
+		INIT_LIST_HEAD(&page->lru);
 		r_nid = page_to_nid(page);
 		set_compound_page_dtor(page, free_huge_page);
 		/*
@@ -998,7 +1001,6 @@ retry:
 	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
 		if ((--needed) < 0)
 			break;
-		list_del(&page->lru);
 		/*
 		 * This page is now managed by the hugetlb allocator and has
 		 * no users -- drop the buddy allocator's reference.
@@ -1013,7 +1015,6 @@ free:
 	/* Free unnecessary surplus pages to the buddy allocator */
 	if (!list_empty(&surplus_list)) {
 		list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
-			list_del(&page->lru);
 			put_page(page);
 		}
 	}
@@ -1927,6 +1928,7 @@ void __init hugetlb_add_hstate(unsigned order)
 	h->free_huge_pages = 0;
 	for (i = 0; i < MAX_NUMNODES; ++i)
 		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
+	INIT_LIST_HEAD(&h->hugepage_activelist);
 	h->next_nid_to_alloc = first_node(node_states[N_HIGH_MEMORY]);
 	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
 	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
-- 
1.7.10.rc3.3.g19a6c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
