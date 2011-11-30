Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB416B004D
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 05:37:36 -0500 (EST)
From: Petr Holasek <pholasek@redhat.com>
Subject: [PATCH] [RFC] KSM: numa awareness sysfs knob
Date: Wed, 30 Nov 2011 11:37:26 +0100
Message-Id: <1322649446-11437-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>, Petr Holasek <pholasek@redhat.com>

Introduce a new sysfs knob /sys/kernel/mm/ksm/max_node_dist, whose
value will be used as the limitation for node distance of merged pages.

Signed-off-by: Petr Holasek <pholasek@redhat.com>
---
 Documentation/vm/ksm.txt |    4 ++
 mm/ksm.c                 |  122 +++++++++++++++++++++++++++++++++++----------
 2 files changed, 99 insertions(+), 27 deletions(-)

diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
index b392e49..b882140 100644
--- a/Documentation/vm/ksm.txt
+++ b/Documentation/vm/ksm.txt
@@ -58,6 +58,10 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
                    e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
                    Default: 20 (chosen for demonstration purposes)
 
+max_node_dist    - maximum node distance between two pages which could be
+                   merged.
+                   Default: 255 (without any limitations)
+
 run              - set 0 to stop ksmd from running but keep merged pages,
                    set 1 to run ksmd e.g. "echo 1 > /sys/kernel/mm/ksm/run",
                    set 2 to stop ksmd and unmerge all pages currently merged,
diff --git a/mm/ksm.c b/mm/ksm.c
index 310544a..ea33040 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -36,6 +36,7 @@
 #include <linux/hash.h>
 #include <linux/freezer.h>
 #include <linux/oom.h>
+#include <linux/numa.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -120,6 +121,7 @@ struct stable_node {
 	struct rb_node node;
 	struct hlist_head hlist;
 	unsigned long kpfn;
+	int nid;
 };
 
 /**
@@ -153,8 +155,8 @@ struct rmap_item {
 #define STABLE_FLAG	0x200	/* is listed from the stable tree */
 
 /* The stable and unstable tree heads */
-static struct rb_root root_stable_tree = RB_ROOT;
 static struct rb_root root_unstable_tree = RB_ROOT;
+static struct rb_root root_stable_tree[MAX_NUMNODES] = { RB_ROOT, };
 
 #define MM_SLOTS_HASH_SHIFT 10
 #define MM_SLOTS_HASH_HEADS (1 << MM_SLOTS_HASH_SHIFT)
@@ -189,6 +191,9 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+/* Maximum distance of nodes in which pages are merged */
+static unsigned int ksm_node_distance = 255;
+
 #define KSM_RUN_STOP	0
 #define KSM_RUN_MERGE	1
 #define KSM_RUN_UNMERGE	2
@@ -302,6 +307,25 @@ static inline int in_stable_tree(struct rmap_item *rmap_item)
 	return rmap_item->address & STABLE_FLAG;
 }
 
+#ifdef CONFIG_NUMA
+static inline int node_dist(int from, int to)
+{
+	int dist = node_distance(from, to);
+
+	return dist == -1 ? 0 : dist;
+}
+#else
+static inline int node_dist(int from, int to)
+{
+	return 0;
+}
+#endif
+
+static inline int page_distance(struct page *from, struct page *to)
+{
+	return node_dist(page_to_nid(from), page_to_nid(to));
+}
+
 /*
  * ksmd, and unmerge_and_remove_all_rmap_items(), must not touch an mm's
  * page tables after it has passed through ksm_exit() - which, if necessary,
@@ -458,7 +482,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
 		cond_resched();
 	}
 
-	rb_erase(&stable_node->node, &root_stable_tree);
+	rb_erase(&stable_node->node, &root_stable_tree[stable_node->nid]);
+	printk(KERN_DEBUG "Node erased from tree %d\n", stable_node->nid);
 	free_stable_node(stable_node);
 }
 
@@ -960,6 +985,9 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
 {
 	int err;
 
+	if (page_distance(page, tree_page) > ksm_node_distance)
+		return NULL;
+
 	err = try_to_merge_with_ksm_page(rmap_item, page, NULL);
 	if (!err) {
 		err = try_to_merge_with_ksm_page(tree_rmap_item,
@@ -983,10 +1011,11 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
  * This function returns the stable tree node of identical content if found,
  * NULL otherwise.
  */
-static struct page *stable_tree_search(struct page *page)
+static struct page *stable_tree_search(struct page *page, int tree_nid)
 {
-	struct rb_node *node = root_stable_tree.rb_node;
+	struct rb_node *node = root_stable_tree[tree_nid].rb_node;
 	struct stable_node *stable_node;
+	int page_nid = page_to_nid(page);
 
 	stable_node = page_stable_node(page);
 	if (stable_node) {			/* ksm page forked */
@@ -994,6 +1023,10 @@ static struct page *stable_tree_search(struct page *page)
 		return page;
 	}
 
+	/* Pages are too far for merge */
+	if (node_dist(tree_nid, page_nid) > ksm_node_distance)
+		return NULL;
+
 	while (node) {
 		struct page *tree_page;
 		int ret;
@@ -1028,7 +1061,8 @@ static struct page *stable_tree_search(struct page *page)
  */
 static struct stable_node *stable_tree_insert(struct page *kpage)
 {
-	struct rb_node **new = &root_stable_tree.rb_node;
+	int nid = page_to_nid(kpage);
+	struct rb_node **new = &root_stable_tree[nid].rb_node;
 	struct rb_node *parent = NULL;
 	struct stable_node *stable_node;
 
@@ -1065,12 +1099,14 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 		return NULL;
 
 	rb_link_node(&stable_node->node, parent, new);
-	rb_insert_color(&stable_node->node, &root_stable_tree);
+	rb_insert_color(&stable_node->node, &root_stable_tree[nid]);
 
 	INIT_HLIST_HEAD(&stable_node->hlist);
 
 	stable_node->kpfn = page_to_pfn(kpage);
+	stable_node->nid = nid;
 	set_page_stable_node(kpage, stable_node);
+	printk(KERN_DEBUG "Stable node was inserted into tree %d\n", nid);
 
 	return stable_node;
 }
@@ -1173,27 +1209,32 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	struct rmap_item *tree_rmap_item;
 	struct page *tree_page = NULL;
 	struct stable_node *stable_node;
-	struct page *kpage;
+	struct page *kpage = NULL;
 	unsigned int checksum;
 	int err;
+	int i;
+	int nid = page_to_nid(page);
 
 	remove_rmap_item_from_tree(rmap_item);
 
 	/* We first start with searching the page inside the stable tree */
-	kpage = stable_tree_search(page);
-	if (kpage) {
-		err = try_to_merge_with_ksm_page(rmap_item, page, kpage);
-		if (!err) {
-			/*
-			 * The page was successfully merged:
-			 * add its rmap_item to the stable tree.
-			 */
-			lock_page(kpage);
-			stable_tree_append(rmap_item, page_stable_node(kpage));
-			unlock_page(kpage);
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		if (node_distance(i, nid) <= ksm_node_distance)
+			kpage = stable_tree_search(page, nid);
+		if (kpage) {
+			err = try_to_merge_with_ksm_page(rmap_item, page, kpage);
+			if (!err) {
+				/*
+				 * The page was successfully merged:
+				 * add its rmap_item to the stable tree.
+				 */
+				lock_page(kpage);
+				stable_tree_append(rmap_item, page_stable_node(kpage));
+				unlock_page(kpage);
+			}
+			put_page(kpage);
+			return;
 		}
-		put_page(kpage);
-		return;
 	}
 
 	/*
@@ -1764,15 +1805,18 @@ static struct stable_node *ksm_check_stable_tree(unsigned long start_pfn,
 						 unsigned long end_pfn)
 {
 	struct rb_node *node;
+	int i;
 
-	for (node = rb_first(&root_stable_tree); node; node = rb_next(node)) {
-		struct stable_node *stable_node;
+	for (i = 0; i < MAX_NUMNODES; i++)
+		for (node = rb_first(&root_stable_tree[i]); node; node = rb_next(node)) {
+			struct stable_node *stable_node;
+
+			stable_node = rb_entry(node, struct stable_node, node);
+			if (stable_node->kpfn >= start_pfn &&
+			    stable_node->kpfn < end_pfn)
+				return stable_node;
+		}
 
-		stable_node = rb_entry(node, struct stable_node, node);
-		if (stable_node->kpfn >= start_pfn &&
-		    stable_node->kpfn < end_pfn)
-			return stable_node;
-	}
 	return NULL;
 }
 
@@ -1922,6 +1966,29 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
 }
 KSM_ATTR(run);
 
+static ssize_t max_node_dist_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_node_distance);
+}
+
+static ssize_t max_node_dist_store(struct kobject *kobj,
+				   struct kobj_attribute *attr,
+				   const char *buf, size_t count)
+{
+	int err;
+	unsigned long node_dist;
+
+	err = kstrtoul(buf, 10, &node_dist);
+	if (err || node_dist > 255)
+		return -EINVAL;
+
+	ksm_node_distance = node_dist;
+
+	return count;
+}
+KSM_ATTR(max_node_dist);
+
 static ssize_t pages_shared_show(struct kobject *kobj,
 				 struct kobj_attribute *attr, char *buf)
 {
@@ -1976,6 +2043,7 @@ static struct attribute *ksm_attrs[] = {
 	&pages_unshared_attr.attr,
 	&pages_volatile_attr.attr,
 	&full_scans_attr.attr,
+	&max_node_dist_attr.attr,
 	NULL,
 };
 
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
