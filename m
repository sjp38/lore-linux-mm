Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id CDA6D6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 20:54:51 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb11so576664pad.38
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 17:54:51 -0800 (PST)
Date: Fri, 25 Jan 2013 17:54:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/11] ksm: allow trees per NUMA node
In-Reply-To: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1301251753380.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Petr Holasek <pholasek@redhat.com>

Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_across_nodes
which control merging pages across different numa nodes.
When it is set to zero only pages from the same node are merged,
otherwise pages from all nodes can be merged together (default behavior).

Typical use-case could be a lot of KVM guests on NUMA machine
and cpus from more distant nodes would have significant increase
of access latency to the merged ksm page. Sysfs knob was choosen
for higher variability when some users still prefers higher amount
of saved physical memory regardless of access latency.

Every numa node has its own stable & unstable trees because of faster
searching and inserting. Changing of merge_across_nodes value is possible
only when there are not any ksm shared pages in system.

I've tested this patch on numa machines with 2, 4 and 8 nodes and
measured speed of memory access inside of KVM guests with memory pinned
to one of nodes with this benchmark:

http://pholasek.fedorapeople.org/alloc_pg.c

Population standard deviations of access times in percentage of average
were following:

merge_across_nodes=1
2 nodes 1.4%
4 nodes 1.6%
8 nodes	1.7%

merge_across_nodes=0
2 nodes	1%
4 nodes	0.32%
8 nodes	0.018%

RFC: https://lkml.org/lkml/2011/11/30/91
v1: https://lkml.org/lkml/2012/1/23/46
v2: https://lkml.org/lkml/2012/6/29/105
v3: https://lkml.org/lkml/2012/9/14/550
v4: https://lkml.org/lkml/2012/9/23/137
v5: https://lkml.org/lkml/2012/12/10/540
v6: https://lkml.org/lkml/2012/12/23/154
v7: https://lkml.org/lkml/2012/12/27/225

Hugh notes that this patch brings two problems, whose solution needs
further support in mm/ksm.c, which follows in subsequent patches:
1) switching merge_across_nodes after running KSM is liable to oops
   on stale nodes still left over from the previous stable tree;
2) memory hotremove may migrate KSM pages, but there is no provision
   here for !merge_across_nodes to migrate nodes to the proper tree.

Signed-off-by: Petr Holasek <pholasek@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 Documentation/vm/ksm.txt |    7 +
 mm/ksm.c                 |  151 ++++++++++++++++++++++++++++++++-----
 2 files changed, 139 insertions(+), 19 deletions(-)

--- mmotm.orig/Documentation/vm/ksm.txt	2013-01-25 14:36:31.724205455 -0800
+++ mmotm/Documentation/vm/ksm.txt	2013-01-25 14:36:38.608205618 -0800
@@ -58,6 +58,13 @@ sleep_millisecs  - how many milliseconds
                    e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
                    Default: 20 (chosen for demonstration purposes)
 
+merge_across_nodes - specifies if pages from different numa nodes can be merged.
+                   When set to 0, ksm merges only pages which physically
+                   reside in the memory area of same NUMA node. It brings
+                   lower latency to access to shared page. Value can be
+                   changed only when there is no ksm shared pages in system.
+                   Default: 1
+
 run              - set 0 to stop ksmd from running but keep merged pages,
                    set 1 to run ksmd e.g. "echo 1 > /sys/kernel/mm/ksm/run",
                    set 2 to stop ksmd and unmerge all pages currently merged,
--- mmotm.orig/mm/ksm.c	2013-01-25 14:36:31.724205455 -0800
+++ mmotm/mm/ksm.c	2013-01-25 14:36:38.608205618 -0800
@@ -36,6 +36,7 @@
 #include <linux/hashtable.h>
 #include <linux/freezer.h>
 #include <linux/oom.h>
+#include <linux/numa.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -139,6 +140,9 @@ struct rmap_item {
 	struct mm_struct *mm;
 	unsigned long address;		/* + low bits used for flags below */
 	unsigned int oldchecksum;	/* when unstable */
+#ifdef CONFIG_NUMA
+	unsigned int nid;
+#endif
 	union {
 		struct rb_node node;	/* when node of unstable tree */
 		struct {		/* when listed from stable tree */
@@ -153,8 +157,8 @@ struct rmap_item {
 #define STABLE_FLAG	0x200	/* is listed from the stable tree */
 
 /* The stable and unstable tree heads */
-static struct rb_root root_stable_tree = RB_ROOT;
-static struct rb_root root_unstable_tree = RB_ROOT;
+static struct rb_root root_unstable_tree[MAX_NUMNODES];
+static struct rb_root root_stable_tree[MAX_NUMNODES];
 
 #define MM_SLOTS_HASH_BITS 10
 static DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
@@ -188,6 +192,9 @@ static unsigned int ksm_thread_pages_to_
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+/* Zeroed when merging across nodes is not allowed */
+static unsigned int ksm_merge_across_nodes = 1;
+
 #define KSM_RUN_STOP	0
 #define KSM_RUN_MERGE	1
 #define KSM_RUN_UNMERGE	2
@@ -441,10 +448,25 @@ out:		page = NULL;
 	return page;
 }
 
+/*
+ * This helper is used for getting right index into array of tree roots.
+ * When merge_across_nodes knob is set to 1, there are only two rb-trees for
+ * stable and unstable pages from all nodes with roots in index 0. Otherwise,
+ * every node has its own stable and unstable tree.
+ */
+static inline int get_kpfn_nid(unsigned long kpfn)
+{
+	if (ksm_merge_across_nodes)
+		return 0;
+	else
+		return pfn_to_nid(kpfn);
+}
+
 static void remove_node_from_stable_tree(struct stable_node *stable_node)
 {
 	struct rmap_item *rmap_item;
 	struct hlist_node *hlist;
+	int nid;
 
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
 		if (rmap_item->hlist.next)
@@ -456,7 +478,9 @@ static void remove_node_from_stable_tree
 		cond_resched();
 	}
 
-	rb_erase(&stable_node->node, &root_stable_tree);
+	nid = get_kpfn_nid(stable_node->kpfn);
+
+	rb_erase(&stable_node->node, &root_stable_tree[nid]);
 	free_stable_node(stable_node);
 }
 
@@ -554,7 +578,12 @@ static void remove_rmap_item_from_tree(s
 		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
 		BUG_ON(age > 1);
 		if (!age)
-			rb_erase(&rmap_item->node, &root_unstable_tree);
+#ifdef CONFIG_NUMA
+			rb_erase(&rmap_item->node,
+					&root_unstable_tree[rmap_item->nid]);
+#else
+			rb_erase(&rmap_item->node, &root_unstable_tree[0]);
+#endif
 
 		ksm_pages_unshared--;
 		rmap_item->address &= PAGE_MASK;
@@ -990,8 +1019,9 @@ static struct page *try_to_merge_two_pag
  */
 static struct page *stable_tree_search(struct page *page)
 {
-	struct rb_node *node = root_stable_tree.rb_node;
+	struct rb_node *node;
 	struct stable_node *stable_node;
+	int nid;
 
 	stable_node = page_stable_node(page);
 	if (stable_node) {			/* ksm page forked */
@@ -999,6 +1029,9 @@ static struct page *stable_tree_search(s
 		return page;
 	}
 
+	nid = get_kpfn_nid(page_to_pfn(page));
+	node = root_stable_tree[nid].rb_node;
+
 	while (node) {
 		struct page *tree_page;
 		int ret;
@@ -1033,10 +1066,16 @@ static struct page *stable_tree_search(s
  */
 static struct stable_node *stable_tree_insert(struct page *kpage)
 {
-	struct rb_node **new = &root_stable_tree.rb_node;
+	int nid;
+	unsigned long kpfn;
+	struct rb_node **new;
 	struct rb_node *parent = NULL;
 	struct stable_node *stable_node;
 
+	kpfn = page_to_pfn(kpage);
+	nid = get_kpfn_nid(kpfn);
+	new = &root_stable_tree[nid].rb_node;
+
 	while (*new) {
 		struct page *tree_page;
 		int ret;
@@ -1070,11 +1109,11 @@ static struct stable_node *stable_tree_i
 		return NULL;
 
 	rb_link_node(&stable_node->node, parent, new);
-	rb_insert_color(&stable_node->node, &root_stable_tree);
+	rb_insert_color(&stable_node->node, &root_stable_tree[nid]);
 
 	INIT_HLIST_HEAD(&stable_node->hlist);
 
-	stable_node->kpfn = page_to_pfn(kpage);
+	stable_node->kpfn = kpfn;
 	set_page_stable_node(kpage, stable_node);
 
 	return stable_node;
@@ -1098,10 +1137,15 @@ static
 struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 					      struct page *page,
 					      struct page **tree_pagep)
-
 {
-	struct rb_node **new = &root_unstable_tree.rb_node;
+	struct rb_node **new;
+	struct rb_root *root;
 	struct rb_node *parent = NULL;
+	int nid;
+
+	nid = get_kpfn_nid(page_to_pfn(page));
+	root = &root_unstable_tree[nid];
+	new = &root->rb_node;
 
 	while (*new) {
 		struct rmap_item *tree_rmap_item;
@@ -1122,6 +1166,18 @@ struct rmap_item *unstable_tree_search_i
 			return NULL;
 		}
 
+		/*
+		 * If tree_page has been migrated to another NUMA node, it
+		 * will be flushed out and put into the right unstable tree
+		 * next time: only merge with it if merge_across_nodes.
+		 * Just notice, we don't have similar problem for PageKsm
+		 * because their migration is disabled now. (62b61f611e)
+		 */
+		if (!ksm_merge_across_nodes && page_to_nid(tree_page) != nid) {
+			put_page(tree_page);
+			return NULL;
+		}
+
 		ret = memcmp_pages(page, tree_page);
 
 		parent = *new;
@@ -1139,8 +1195,11 @@ struct rmap_item *unstable_tree_search_i
 
 	rmap_item->address |= UNSTABLE_FLAG;
 	rmap_item->address |= (ksm_scan.seqnr & SEQNR_MASK);
+#ifdef CONFIG_NUMA
+	rmap_item->nid = nid;
+#endif
 	rb_link_node(&rmap_item->node, parent, new);
-	rb_insert_color(&rmap_item->node, &root_unstable_tree);
+	rb_insert_color(&rmap_item->node, root);
 
 	ksm_pages_unshared++;
 	return NULL;
@@ -1154,6 +1213,13 @@ struct rmap_item *unstable_tree_search_i
 static void stable_tree_append(struct rmap_item *rmap_item,
 			       struct stable_node *stable_node)
 {
+#ifdef CONFIG_NUMA
+	/*
+	 * Usually rmap_item->nid is already set correctly,
+	 * but it may be wrong after switching merge_across_nodes.
+	 */
+	rmap_item->nid = get_kpfn_nid(stable_node->kpfn);
+#endif
 	rmap_item->head = stable_node;
 	rmap_item->address |= STABLE_FLAG;
 	hlist_add_head(&rmap_item->hlist, &stable_node->hlist);
@@ -1283,6 +1349,7 @@ static struct rmap_item *scan_get_next_r
 	struct mm_slot *slot;
 	struct vm_area_struct *vma;
 	struct rmap_item *rmap_item;
+	int nid;
 
 	if (list_empty(&ksm_mm_head.mm_list))
 		return NULL;
@@ -1301,7 +1368,8 @@ static struct rmap_item *scan_get_next_r
 		 */
 		lru_add_drain_all();
 
-		root_unstable_tree = RB_ROOT;
+		for (nid = 0; nid < nr_node_ids; nid++)
+			root_unstable_tree[nid] = RB_ROOT;
 
 		spin_lock(&ksm_mmlist_lock);
 		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
@@ -1770,15 +1838,19 @@ static struct stable_node *ksm_check_sta
 						 unsigned long end_pfn)
 {
 	struct rb_node *node;
+	int nid;
 
-	for (node = rb_first(&root_stable_tree); node; node = rb_next(node)) {
-		struct stable_node *stable_node;
+	for (nid = 0; nid < nr_node_ids; nid++)
+		for (node = rb_first(&root_stable_tree[nid]); node;
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
 
@@ -1925,6 +1997,40 @@ static ssize_t run_store(struct kobject
 }
 KSM_ATTR(run);
 
+#ifdef CONFIG_NUMA
+static ssize_t merge_across_nodes_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_merge_across_nodes);
+}
+
+static ssize_t merge_across_nodes_store(struct kobject *kobj,
+				   struct kobj_attribute *attr,
+				   const char *buf, size_t count)
+{
+	int err;
+	unsigned long knob;
+
+	err = kstrtoul(buf, 10, &knob);
+	if (err)
+		return err;
+	if (knob > 1)
+		return -EINVAL;
+
+	mutex_lock(&ksm_thread_mutex);
+	if (ksm_merge_across_nodes != knob) {
+		if (ksm_pages_shared)
+			err = -EBUSY;
+		else
+			ksm_merge_across_nodes = knob;
+	}
+	mutex_unlock(&ksm_thread_mutex);
+
+	return err ? err : count;
+}
+KSM_ATTR(merge_across_nodes);
+#endif
+
 static ssize_t pages_shared_show(struct kobject *kobj,
 				 struct kobj_attribute *attr, char *buf)
 {
@@ -1979,6 +2085,9 @@ static struct attribute *ksm_attrs[] = {
 	&pages_unshared_attr.attr,
 	&pages_volatile_attr.attr,
 	&full_scans_attr.attr,
+#ifdef CONFIG_NUMA
+	&merge_across_nodes_attr.attr,
+#endif
 	NULL,
 };
 
@@ -1992,11 +2101,15 @@ static int __init ksm_init(void)
 {
 	struct task_struct *ksm_thread;
 	int err;
+	int nid;
 
 	err = ksm_slab_init();
 	if (err)
 		goto out;
 
+	for (nid = 0; nid < nr_node_ids; nid++)
+		root_stable_tree[nid] = RB_ROOT;
+
 	ksm_thread = kthread_run(ksm_scan_thread, NULL, "ksmd");
 	if (IS_ERR(ksm_thread)) {
 		printk(KERN_ERR "ksm: creating kthread failed\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
