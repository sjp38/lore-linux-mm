Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id A10AE6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 05:30:46 -0500 (EST)
From: Petr Holasek <pholasek@redhat.com>
Subject: [PATCH] KSM: numa awareness sysfs knob
Date: Mon, 23 Jan 2012 11:29:28 +0100
Message-Id: <1327314568-13942-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>, Petr Holasek <pholasek@redhat.com>

This patch is based on RFC

https://lkml.org/lkml/2011/11/30/91

Introduces new sysfs binary knob /sys/kernel/mm/ksm/merge_nodes
which control merging pages across different numa nodes.
When it is set to zero only pages from the same node are merged,
otherwise pages from all nodes can be merged together (default behavior).

Typical use-case could be a lot of KVM guests on NUMA machine
where cpus from more distant nodes would have significant increase
of access latency to the merged ksm page. Switching merge_nodes
to 1 will result into these steps:

	1) unmerging all ksm pages
	2) re-merging all pages from VM_MERGEABLE vmas only within
		their NUMA nodes.
	3) lower average access latency to merged pages at the
	   expense of higher memory usage.

Every numa node has its own stable & unstable trees because
of faster searching and inserting. Changing of merge_nodes
value breaks COW on all current ksm pages.

Signed-off-by: Petr Holasek <pholasek@redhat.com>
---
 Documentation/vm/ksm.txt |    3 +
 mm/ksm.c                 |  124 +++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 108 insertions(+), 19 deletions(-)

diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
index b392e49..ac9fc42 100644
--- a/Documentation/vm/ksm.txt
+++ b/Documentation/vm/ksm.txt
@@ -58,6 +58,9 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
                    e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
                    Default: 20 (chosen for demonstration purposes)
 
+merge_nodes      - specifies if pages from different numa nodes can be merged
+                   Default: 1
+
 run              - set 0 to stop ksmd from running but keep merged pages,
                    set 1 to run ksmd e.g. "echo 1 > /sys/kernel/mm/ksm/run",
                    set 2 to stop ksmd and unmerge all pages currently merged,
diff --git a/mm/ksm.c b/mm/ksm.c
index 1925ffb..402e4bc 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -37,6 +37,7 @@
 #include <linux/hash.h>
 #include <linux/freezer.h>
 #include <linux/oom.h>
+#include <linux/numa.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -121,6 +122,7 @@ struct stable_node {
 	struct rb_node node;
 	struct hlist_head hlist;
 	unsigned long kpfn;
+	struct rb_root *root;
 };
 
 /**
@@ -141,7 +143,10 @@ struct rmap_item {
 	unsigned long address;		/* + low bits used for flags below */
 	unsigned int oldchecksum;	/* when unstable */
 	union {
-		struct rb_node node;	/* when node of unstable tree */
+		struct {
+			struct rb_node node;	/* when node of unstable tree */
+			struct rb_root *root;
+		};
 		struct {		/* when listed from stable tree */
 			struct stable_node *head;
 			struct hlist_node hlist;
@@ -154,8 +159,8 @@ struct rmap_item {
 #define STABLE_FLAG	0x200	/* is listed from the stable tree */
 
 /* The stable and unstable tree heads */
-static struct rb_root root_stable_tree = RB_ROOT;
-static struct rb_root root_unstable_tree = RB_ROOT;
+static struct rb_root root_unstable_tree[MAX_NUMNODES] = { RB_ROOT, };
+static struct rb_root root_stable_tree[MAX_NUMNODES] = { RB_ROOT, };
 
 #define MM_SLOTS_HASH_SHIFT 10
 #define MM_SLOTS_HASH_HEADS (1 << MM_SLOTS_HASH_SHIFT)
@@ -190,6 +195,9 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+/* Zeroed when merging across nodes is not allowed */
+static unsigned int ksm_merge_nodes = 1;
+
 #define KSM_RUN_STOP	0
 #define KSM_RUN_MERGE	1
 #define KSM_RUN_UNMERGE	2
@@ -459,7 +467,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
 		cond_resched();
 	}
 
-	rb_erase(&stable_node->node, &root_stable_tree);
+	rb_erase(&stable_node->node, stable_node->root);
 	free_stable_node(stable_node);
 }
 
@@ -557,7 +565,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
 		BUG_ON(age > 1);
 		if (!age)
-			rb_erase(&rmap_item->node, &root_unstable_tree);
+			rb_erase(&rmap_item->node, rmap_item->root);
 
 		ksm_pages_unshared--;
 		rmap_item->address &= PAGE_MASK;
@@ -986,8 +994,9 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
  */
 static struct page *stable_tree_search(struct page *page)
 {
-	struct rb_node *node = root_stable_tree.rb_node;
+	struct rb_node *node;
 	struct stable_node *stable_node;
+	int nid;
 
 	stable_node = page_stable_node(page);
 	if (stable_node) {			/* ksm page forked */
@@ -995,6 +1004,13 @@ static struct page *stable_tree_search(struct page *page)
 		return page;
 	}
 
+	if (ksm_merge_nodes)
+		nid = 0;
+	else
+		nid = page_to_nid(page);
+
+	node = root_stable_tree[nid].rb_node;
+
 	while (node) {
 		struct page *tree_page;
 		int ret;
@@ -1029,10 +1045,18 @@ static struct page *stable_tree_search(struct page *page)
  */
 static struct stable_node *stable_tree_insert(struct page *kpage)
 {
-	struct rb_node **new = &root_stable_tree.rb_node;
+	int nid;
+	struct rb_node **new = NULL;
 	struct rb_node *parent = NULL;
 	struct stable_node *stable_node;
 
+	if (ksm_merge_nodes)
+		nid = 0;
+	else
+		nid = page_to_nid(kpage);
+
+	new = &root_stable_tree[nid].rb_node;
+
 	while (*new) {
 		struct page *tree_page;
 		int ret;
@@ -1066,12 +1090,14 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 		return NULL;
 
 	rb_link_node(&stable_node->node, parent, new);
-	rb_insert_color(&stable_node->node, &root_stable_tree);
+	rb_insert_color(&stable_node->node, &root_stable_tree[nid]);
 
 	INIT_HLIST_HEAD(&stable_node->hlist);
 
 	stable_node->kpfn = page_to_pfn(kpage);
+	stable_node->root = &root_stable_tree[nid];
 	set_page_stable_node(kpage, stable_node);
+	printk(KERN_DEBUG "Stable node was inserted into tree %d\n", nid);
 
 	return stable_node;
 }
@@ -1094,11 +1120,18 @@ static
 struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 					      struct page *page,
 					      struct page **tree_pagep)
-
 {
-	struct rb_node **new = &root_unstable_tree.rb_node;
+	struct rb_node **new = NULL;
+	struct rb_root *root;
 	struct rb_node *parent = NULL;
 
+	if (ksm_merge_nodes)
+		root = &root_unstable_tree[0];
+	else
+		root = &root_unstable_tree[page_to_nid(page)];
+
+	new = &root->rb_node;
+
 	while (*new) {
 		struct rmap_item *tree_rmap_item;
 		struct page *tree_page;
@@ -1135,8 +1168,9 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 
 	rmap_item->address |= UNSTABLE_FLAG;
 	rmap_item->address |= (ksm_scan.seqnr & SEQNR_MASK);
+	rmap_item->root = root;
 	rb_link_node(&rmap_item->node, parent, new);
-	rb_insert_color(&rmap_item->node, &root_unstable_tree);
+	rb_insert_color(&rmap_item->node, root);
 
 	ksm_pages_unshared++;
 	return NULL;
@@ -1279,6 +1313,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	struct mm_slot *slot;
 	struct vm_area_struct *vma;
 	struct rmap_item *rmap_item;
+	int i;
 
 	if (list_empty(&ksm_mm_head.mm_list))
 		return NULL;
@@ -1297,7 +1332,8 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 		 */
 		lru_add_drain_all();
 
-		root_unstable_tree = RB_ROOT;
+		for (i = 0; i < MAX_NUMNODES; i++)
+			root_unstable_tree[i] = RB_ROOT;
 
 		spin_lock(&ksm_mmlist_lock);
 		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
@@ -1775,15 +1811,19 @@ static struct stable_node *ksm_check_stable_tree(unsigned long start_pfn,
 						 unsigned long end_pfn)
 {
 	struct rb_node *node;
+	int i;
 
-	for (node = rb_first(&root_stable_tree); node; node = rb_next(node)) {
-		struct stable_node *stable_node;
+	for (i = 0; i < MAX_NUMNODES; i++)
+		for (node = rb_first(&root_stable_tree[i]); node;
+				node = rb_next(node)) {
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
 
@@ -1933,6 +1973,49 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
 }
 KSM_ATTR(run);
 
+static ssize_t merge_nodes_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_merge_nodes);
+}
+
+static ssize_t merge_nodes_store(struct kobject *kobj,
+				   struct kobj_attribute *attr,
+				   const char *buf, size_t count)
+{
+	int err;
+	long unsigned int knob;
+
+	err = kstrtoul(buf, 10, &knob);
+	if (err)
+		return err;
+	if (knob > 1)
+		return -EINVAL;
+
+	mutex_lock(&ksm_thread_mutex);
+	if (ksm_merge_nodes != knob) {
+		/* NUMA mode is changing, so re-merge all */
+		int oom_score_adj;
+
+		oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
+		err = unmerge_and_remove_all_rmap_items();
+		compare_swap_oom_score_adj(OOM_SCORE_ADJ_MAX,
+							oom_score_adj);
+		if (err) {
+			ksm_run = KSM_RUN_STOP;
+			count = err;
+		}
+	}
+	ksm_merge_nodes = knob;
+	mutex_unlock(&ksm_thread_mutex);
+
+	if (ksm_run & KSM_RUN_MERGE)
+		wake_up_interruptible(&ksm_thread_wait);
+
+	return count;
+}
+KSM_ATTR(merge_nodes);
+
 static ssize_t pages_shared_show(struct kobject *kobj,
 				 struct kobj_attribute *attr, char *buf)
 {
@@ -1987,6 +2070,9 @@ static struct attribute *ksm_attrs[] = {
 	&pages_unshared_attr.attr,
 	&pages_volatile_attr.attr,
 	&full_scans_attr.attr,
+#ifdef CONFIG_NUMA
+	&merge_nodes_attr.attr,
+#endif
 	NULL,
 };
 
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
