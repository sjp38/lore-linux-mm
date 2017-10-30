Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E51AF6B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 08:03:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d28so11670887pfe.1
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 05:03:21 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 60si9307778plb.622.2017.10.30.05.03.19
        for <linux-mm@kvack.org>;
        Mon, 30 Oct 2017 05:03:20 -0700 (PDT)
From: Kyeongdon Kim <kyeongdon.kim@lge.com>
Subject: [PATCH] ksm : use checksum and memcmp for rb_tree
Date: Mon, 30 Oct 2017 21:03:07 +0900
Message-Id: <1509364987-29608-1-git-send-email-kyeongdon.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, minchan@kernel.org, broonie@kernel.org, mhocko@suse.com, mingo@kernel.org, jglisse@redhat.com, arvind.yadav.cs@gmail.com, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, bongkyu.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyeongdon Kim <kyeongdon.kim@lge.com>

The current ksm is using memcmp to insert and search 'rb_tree'.
It does cause very expensive computation cost.
In order to reduce the time of this operation,
we have added a checksum to traverse before memcmp operation.

Nearly all 'rb_node' in stable_tree_insert() function
can be inserted as a checksum, most of it is possible
in unstable_tree_search_insert() function.
In stable_tree_search() function, the checksum may be an additional.
But, checksum check duration is extremely small.
Considering the time of the whole cmp_and_merge_page() function,
it requires very little cost on average.

Using this patch, we compared the time of ksm_do_scan() function
by adding kernel trace at the start-end position of operation.
(ARM 32bit target android device,
over 1000 sample time gap stamps average)

On original KSM scan avg duration = 0.0166893 sec
24991.975619 : ksm_do_scan_start: START: ksm_do_scan
24991.990975 : ksm_do_scan_end: END: ksm_do_scan
24992.008989 : ksm_do_scan_start: START: ksm_do_scan
24992.016839 : ksm_do_scan_end: END: ksm_do_scan
...

On patch KSM scan avg duration = 0.0041157 sec
41081.461312 : ksm_do_scan_start: START: ksm_do_scan
41081.466364 : ksm_do_scan_end: END: ksm_do_scan
41081.484767 : ksm_do_scan_start: START: ksm_do_scan
41081.487951 : ksm_do_scan_end: END: ksm_do_scan
...

We have tested randomly so many times for the stability
and couldn't see any abnormal issue until now.
Also, we found out this patch can make some good advantage
for the power consumption than KSM default enable.

Signed-off-by: Kyeongdon Kim <kyeongdon.kim@lge.com>
---
 mm/ksm.c | 49 +++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 45 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index be8f457..66ab4f4 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -150,6 +150,7 @@ struct stable_node {
 	struct hlist_head hlist;
 	union {
 		unsigned long kpfn;
+		u32 oldchecksum;
 		unsigned long chain_prune_time;
 	};
 	/*
@@ -1522,7 +1523,7 @@ static __always_inline struct page *chain(struct stable_node **s_n_d,
  * This function returns the stable tree node of identical content if found,
  * NULL otherwise.
  */
-static struct page *stable_tree_search(struct page *page)
+static struct page *stable_tree_search(struct page *page, u32 checksum)
 {
 	int nid;
 	struct rb_root *root;
@@ -1540,6 +1541,8 @@ static struct page *stable_tree_search(struct page *page)
 
 	nid = get_kpfn_nid(page_to_pfn(page));
 	root = root_stable_tree + nid;
+	if (!checksum)
+		return NULL;
 again:
 	new = &root->rb_node;
 	parent = NULL;
@@ -1550,6 +1553,18 @@ static struct page *stable_tree_search(struct page *page)
 
 		cond_resched();
 		stable_node = rb_entry(*new, struct stable_node, node);
+
+		/* first make rb_tree by checksum */
+		if (checksum < stable_node->oldchecksum) {
+			parent = *new;
+			new = &parent->rb_left;
+			continue;
+		} else if (checksum > stable_node->oldchecksum) {
+			parent = *new;
+			new = &parent->rb_right;
+			continue;
+		}
+
 		stable_node_any = NULL;
 		tree_page = chain_prune(&stable_node_dup, &stable_node,	root);
 		/*
@@ -1768,7 +1783,7 @@ static struct page *stable_tree_search(struct page *page)
  * This function returns the stable tree node just allocated on success,
  * NULL otherwise.
  */
-static struct stable_node *stable_tree_insert(struct page *kpage)
+static struct stable_node *stable_tree_insert(struct page *kpage, u32 checksum)
 {
 	int nid;
 	unsigned long kpfn;
@@ -1792,6 +1807,18 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 		cond_resched();
 		stable_node = rb_entry(*new, struct stable_node, node);
 		stable_node_any = NULL;
+
+		/* first make rb_tree by checksum */
+		if (checksum < stable_node->oldchecksum) {
+			parent = *new;
+			new = &parent->rb_left;
+			continue;
+		} else if (checksum > stable_node->oldchecksum) {
+			parent = *new;
+			new = &parent->rb_right;
+			continue;
+		}
+
 		tree_page = chain(&stable_node_dup, stable_node, root);
 		if (!stable_node_dup) {
 			/*
@@ -1850,6 +1877,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 
 	INIT_HLIST_HEAD(&stable_node_dup->hlist);
 	stable_node_dup->kpfn = kpfn;
+	stable_node_dup->oldchecksum = checksum;
 	set_page_stable_node(kpage, stable_node_dup);
 	stable_node_dup->rmap_hlist_len = 0;
 	DO_NUMA(stable_node_dup->nid = nid);
@@ -1907,6 +1935,19 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 
 		cond_resched();
 		tree_rmap_item = rb_entry(*new, struct rmap_item, node);
+
+		/* first make rb_tree by checksum */
+		if (rmap_item->oldchecksum < tree_rmap_item->oldchecksum) {
+			parent = *new;
+			new = &parent->rb_left;
+			continue;
+		} else if (rmap_item->oldchecksum
+					> tree_rmap_item->oldchecksum) {
+			parent = *new;
+			new = &parent->rb_right;
+			continue;
+		}
+
 		tree_page = get_mergeable_page(tree_rmap_item);
 		if (!tree_page)
 			return NULL;
@@ -2031,7 +2072,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	}
 
 	/* We first start with searching the page inside the stable tree */
-	kpage = stable_tree_search(page);
+	kpage = stable_tree_search(page, rmap_item->oldchecksum);
 	if (kpage == page && rmap_item->head == stable_node) {
 		put_page(kpage);
 		return;
@@ -2098,7 +2139,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 			 * node in the stable tree and add both rmap_items.
 			 */
 			lock_page(kpage);
-			stable_node = stable_tree_insert(kpage);
+			stable_node = stable_tree_insert(kpage, checksum);
 			if (stable_node) {
 				stable_tree_append(tree_rmap_item, stable_node,
 						   false);
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
