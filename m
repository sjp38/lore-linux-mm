Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 863A86B0078
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 00:40:53 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 02/10] hugetlb: add allocate function for hugepage migration
Date: Fri,  3 Sep 2010 13:37:30 +0900
Message-Id: <1283488658-23137-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1283488658-23137-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1283488658-23137-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

We can't use existing hugepage allocation functions to allocate hugepage
for page migration, because page migration can happen asynchronously with
the running processes and page migration users should call the allocation
function with physical addresses (not virtual addresses) as arguments.

ChangeLog since v3:
- unify alloc_buddy_huge_page() and alloc_buddy_huge_page_node()

ChangeLog since v2:
- remove unnecessary get/put_mems_allowed() (thanks to David Rientjes)

ChangeLog since v1:
- add comment on top of alloc_huge_page_no_vma()

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 include/linux/hugetlb.h |    3 ++
 mm/hugetlb.c            |   78 ++++++++++++++++++++++++++++++++---------------
 2 files changed, 56 insertions(+), 25 deletions(-)

diff --git v2.6.36-rc2/include/linux/hugetlb.h v2.6.36-rc2/include/linux/hugetlb.h
index f479700..0b73c53 100644
--- v2.6.36-rc2/include/linux/hugetlb.h
+++ v2.6.36-rc2/include/linux/hugetlb.h
@@ -228,6 +228,8 @@ struct huge_bootmem_page {
 	struct hstate *hstate;
 };
 
+struct page *alloc_huge_page_node(struct hstate *h, int nid);
+
 /* arch callback */
 int __init alloc_bootmem_huge_page(struct hstate *h);
 
@@ -303,6 +305,7 @@ static inline struct hstate *page_hstate(struct page *page)
 
 #else
 struct hstate {};
+#define alloc_huge_page_node(h, nid) NULL
 #define alloc_bootmem_huge_page(h) NULL
 #define hstate_file(f) NULL
 #define hstate_vma(v) NULL
diff --git v2.6.36-rc2/mm/hugetlb.c v2.6.36-rc2/mm/hugetlb.c
index 6871b41..d12431b 100644
--- v2.6.36-rc2/mm/hugetlb.c
+++ v2.6.36-rc2/mm/hugetlb.c
@@ -466,11 +466,22 @@ static void enqueue_huge_page(struct hstate *h, struct page *page)
 	h->free_huge_pages_node[nid]++;
 }
 
+static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
+{
+	struct page *page;
+	if (list_empty(&h->hugepage_freelists[nid]))
+		return NULL;
+	page = list_entry(h->hugepage_freelists[nid].next, struct page, lru);
+	list_del(&page->lru);
+	h->free_huge_pages--;
+	h->free_huge_pages_node[nid]--;
+	return page;
+}
+
 static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
 				unsigned long address, int avoid_reserve)
 {
-	int nid;
 	struct page *page = NULL;
 	struct mempolicy *mpol;
 	nodemask_t *nodemask;
@@ -496,19 +507,13 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
-		nid = zone_to_nid(zone);
-		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask) &&
-		    !list_empty(&h->hugepage_freelists[nid])) {
-			page = list_entry(h->hugepage_freelists[nid].next,
-					  struct page, lru);
-			list_del(&page->lru);
-			h->free_huge_pages--;
-			h->free_huge_pages_node[nid]--;
-
-			if (!avoid_reserve)
-				decrement_hugepage_resv_vma(h, vma);
-
-			break;
+		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
+			page = dequeue_huge_page_node(h, zone_to_nid(zone));
+			if (page) {
+				if (!avoid_reserve)
+					decrement_hugepage_resv_vma(h, vma);
+				break;
+			}
 		}
 	}
 err:
@@ -770,11 +775,10 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 	return ret;
 }
 
-static struct page *alloc_buddy_huge_page(struct hstate *h,
-			struct vm_area_struct *vma, unsigned long address)
+static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 {
 	struct page *page;
-	unsigned int nid;
+	unsigned int r_nid;
 
 	if (h->order >= MAX_ORDER)
 		return NULL;
@@ -812,9 +816,14 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
 	}
 	spin_unlock(&hugetlb_lock);
 
-	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
-					__GFP_REPEAT|__GFP_NOWARN,
-					huge_page_order(h));
+	if (nid == NUMA_NO_NODE)
+		page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
+				   __GFP_REPEAT|__GFP_NOWARN,
+				   huge_page_order(h));
+	else
+		page = alloc_pages_exact_node(nid,
+			htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
+			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
 
 	if (page && arch_prepare_hugepage(page)) {
 		__free_pages(page, huge_page_order(h));
@@ -829,13 +838,13 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
 		 */
 		put_page_testzero(page);
 		VM_BUG_ON(page_count(page));
-		nid = page_to_nid(page);
+		r_nid = page_to_nid(page);
 		set_compound_page_dtor(page, free_huge_page);
 		/*
 		 * We incremented the global counters already
 		 */
-		h->nr_huge_pages_node[nid]++;
-		h->surplus_huge_pages_node[nid]++;
+		h->nr_huge_pages_node[r_nid]++;
+		h->surplus_huge_pages_node[r_nid]++;
 		__count_vm_event(HTLB_BUDDY_PGALLOC);
 	} else {
 		h->nr_huge_pages--;
@@ -848,6 +857,25 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
 }
 
 /*
+ * This allocation function is useful in the context where vma is irrelevant.
+ * E.g. soft-offlining uses this function because it only cares physical
+ * address of error page.
+ */
+struct page *alloc_huge_page_node(struct hstate *h, int nid)
+{
+	struct page *page;
+
+	spin_lock(&hugetlb_lock);
+	page = dequeue_huge_page_node(h, nid);
+	spin_unlock(&hugetlb_lock);
+
+	if (!page)
+		page = alloc_buddy_huge_page(h, nid);
+
+	return page;
+}
+
+/*
  * Increase the hugetlb pool such that it can accomodate a reservation
  * of size 'delta'.
  */
@@ -871,7 +899,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
-		page = alloc_buddy_huge_page(h, NULL, 0);
+		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
 			/*
 			 * We were not able to allocate enough pages to
@@ -1052,7 +1080,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	spin_unlock(&hugetlb_lock);
 
 	if (!page) {
-		page = alloc_buddy_huge_page(h, vma, addr);
+		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
 			hugetlb_put_quota(inode->i_mapping, chg);
 			return ERR_PTR(-VM_FAULT_SIGBUS);
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
