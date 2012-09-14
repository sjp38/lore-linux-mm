Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 3FBB16B0062
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 17:22:46 -0400 (EDT)
From: Petr Holasek <pholasek@redhat.com>
Subject: [PATCH v3] KSM: numa awareness sysfs knob
Date: Fri, 14 Sep 2012 23:22:47 +0200
Message-Id: <1347657767-1912-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>, Petr Holasek <pholasek@redhat.com>

Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_nodes
which control merging pages across different numa nodes.
When it is set to zero only pages from the same node are merged,
otherwise pages from all nodes can be merged together (default behavior).

Typical use-case could be a lot of KVM guests on NUMA machine
and cpus from more distant nodes would have significant increase
of access latency to the merged ksm page. Sysfs knob was choosen
for higher scalability.

Every numa node has its own stable & unstable trees because
of faster searching and inserting. Changing of merge_nodes
value is possible only when there are not any ksm shared pages in system.

This patch also adds share_all sysfs knob which can be used for adding
all anon vmas of all processes in system to ksmd scan queue. Knob can be
triggered only when run knob is set to zero.

I've tested this patch on numa machines with 2, 4 and 8 nodes and
measured speed of memory access inside of KVM guests with memory pinned
to one of nodes with this benchmark:

http://pholasek.fedorapeople.org/alloc_pg.c

Population standard deviations of access times in percentage of average
were following:

merge_nodes=1
2 nodes 1.4%
4 nodes 1.6%
8 nodes	1.7%

merge_nodes=0
2 nodes	1%
4 nodes	0.32%
8 nodes	0.018%

RFC: https://lkml.org/lkml/2011/11/30/91
v1: https://lkml.org/lkml/2012/1/23/46
v2: https://lkml.org/lkml/2012/6/29/105

Changelog:

v2: Andrew's objections were reflected:
	- value of merge_nodes can't be changed while there are some ksm
	pages in system
	- merge_nodes sysfs entry appearance depends on CONFIG_NUMA
	- more verbose documentation
	- added some performance testing results

v3:	- more verbose documentation
	- fixed race in merge_nodes store function
	- introduced share_all debugging knob proposed by Andrew
	- minor cleanups

Signed-off-by: Petr Holasek <pholasek@redhat.com>
---
 Documentation/vm/ksm.txt |  12 ++
 mm/ksm.c                 | 326 +++++++++++++++++++++++++++++++++++++----------
 2 files changed, 270 insertions(+), 68 deletions(-)

diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
index b392e49..ccd9e97 100644
--- a/Documentation/vm/ksm.txt
+++ b/Documentation/vm/ksm.txt
@@ -58,6 +58,18 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
                    e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
                    Default: 20 (chosen for demonstration purposes)
 
+merge_nodes      - specifies if pages from different numa nodes can be merged.
+                   When set to 0, ksm merges only pages which physically
+                   reside in the memory area of same NUMA node. It brings
+                   lower latency to access to shared page. Value can be
+                   changed only when there is no ksm shared pages in system.
+                   Default: 1
+
+share_all        - when user write 1 to this file, MADV_MERGEABLE is set for
+                   all possible current memory mappings of all processes. It
+                   can be used only when content of run file is zero.
+                   Default: 0
+
 run              - set 0 to stop ksmd from running but keep merged pages,
                    set 1 to run ksmd e.g. "echo 1 > /sys/kernel/mm/ksm/run",
                    set 2 to stop ksmd and unmerge all pages currently merged,
diff --git a/mm/ksm.c b/mm/ksm.c
index 47c8853..68e0b6d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -36,6 +36,7 @@
 #include <linux/hash.h>
 #include <linux/freezer.h>
 #include <linux/oom.h>
+#include <linux/numa.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -140,7 +141,10 @@ struct rmap_item {
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
@@ -153,8 +157,8 @@ struct rmap_item {
 #define STABLE_FLAG	0x200	/* is listed from the stable tree */
 
 /* The stable and unstable tree heads */
-static struct rb_root root_stable_tree = RB_ROOT;
-static struct rb_root root_unstable_tree = RB_ROOT;
+static struct rb_root root_unstable_tree[MAX_NUMNODES] = { RB_ROOT, };
+static struct rb_root root_stable_tree[MAX_NUMNODES] = { RB_ROOT, };
 
 #define MM_SLOTS_HASH_SHIFT 10
 #define MM_SLOTS_HASH_HEADS (1 << MM_SLOTS_HASH_SHIFT)
@@ -189,6 +193,12 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+/* Zeroed when merging across nodes is not allowed */
+static unsigned int ksm_merge_nodes = 1;
+
+/* Share all pages in system */
+static unsigned int ksm_share_all;
+
 #define KSM_RUN_STOP	0
 #define KSM_RUN_MERGE	1
 #define KSM_RUN_UNMERGE	2
@@ -451,6 +461,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
 {
 	struct rmap_item *rmap_item;
 	struct hlist_node *hlist;
+	int nid;
 
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
 		if (rmap_item->hlist.next)
@@ -462,7 +473,13 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
 		cond_resched();
 	}
 
-	rb_erase(&stable_node->node, &root_stable_tree);
+	if (ksm_merge_nodes)
+		nid = 0;
+	else
+		nid = pfn_to_nid(stable_node->kpfn);
+
+	rb_erase(&stable_node->node,
+			&root_stable_tree[nid]);
 	free_stable_node(stable_node);
 }
 
@@ -560,7 +577,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
 		BUG_ON(age > 1);
 		if (!age)
-			rb_erase(&rmap_item->node, &root_unstable_tree);
+			rb_erase(&rmap_item->node, rmap_item->root);
 
 		ksm_pages_unshared--;
 		rmap_item->address &= PAGE_MASK;
@@ -989,8 +1006,9 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
  */
 static struct page *stable_tree_search(struct page *page)
 {
-	struct rb_node *node = root_stable_tree.rb_node;
+	struct rb_node *node;
 	struct stable_node *stable_node;
+	int nid;
 
 	stable_node = page_stable_node(page);
 	if (stable_node) {			/* ksm page forked */
@@ -998,6 +1016,13 @@ static struct page *stable_tree_search(struct page *page)
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
@@ -1032,10 +1057,18 @@ static struct page *stable_tree_search(struct page *page)
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
@@ -1069,7 +1102,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 		return NULL;
 
 	rb_link_node(&stable_node->node, parent, new);
-	rb_insert_color(&stable_node->node, &root_stable_tree);
+	rb_insert_color(&stable_node->node, &root_stable_tree[nid]);
 
 	INIT_HLIST_HEAD(&stable_node->hlist);
 
@@ -1097,11 +1130,18 @@ static
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
@@ -1138,8 +1178,9 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 
 	rmap_item->address |= UNSTABLE_FLAG;
 	rmap_item->address |= (ksm_scan.seqnr & SEQNR_MASK);
+	rmap_item->root = root;
 	rb_link_node(&rmap_item->node, parent, new);
-	rb_insert_color(&rmap_item->node, &root_unstable_tree);
+	rb_insert_color(&rmap_item->node, root);
 
 	ksm_pages_unshared++;
 	return NULL;
@@ -1282,6 +1323,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	struct mm_slot *slot;
 	struct vm_area_struct *vma;
 	struct rmap_item *rmap_item;
+	int i;
 
 	if (list_empty(&ksm_mm_head.mm_list))
 		return NULL;
@@ -1300,7 +1342,8 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 		 */
 		lru_add_drain_all();
 
-		root_unstable_tree = RB_ROOT;
+		for (i = 0; i < MAX_NUMNODES; i++)
+			root_unstable_tree[i] = RB_ROOT;
 
 		spin_lock(&ksm_mmlist_lock);
 		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
@@ -1407,55 +1450,6 @@ next_mm:
 	return NULL;
 }
 
-/**
- * ksm_do_scan  - the ksm scanner main worker function.
- * @scan_npages - number of pages we want to scan before we return.
- */
-static void ksm_do_scan(unsigned int scan_npages)
-{
-	struct rmap_item *rmap_item;
-	struct page *uninitialized_var(page);
-
-	while (scan_npages-- && likely(!freezing(current))) {
-		cond_resched();
-		rmap_item = scan_get_next_rmap_item(&page);
-		if (!rmap_item)
-			return;
-		if (!PageKsm(page) || !in_stable_tree(rmap_item))
-			cmp_and_merge_page(page, rmap_item);
-		put_page(page);
-	}
-}
-
-static int ksmd_should_run(void)
-{
-	return (ksm_run & KSM_RUN_MERGE) && !list_empty(&ksm_mm_head.mm_list);
-}
-
-static int ksm_scan_thread(void *nothing)
-{
-	set_freezable();
-	set_user_nice(current, 5);
-
-	while (!kthread_should_stop()) {
-		mutex_lock(&ksm_thread_mutex);
-		if (ksmd_should_run())
-			ksm_do_scan(ksm_thread_pages_to_scan);
-		mutex_unlock(&ksm_thread_mutex);
-
-		try_to_freeze();
-
-		if (ksmd_should_run()) {
-			schedule_timeout_interruptible(
-				msecs_to_jiffies(ksm_thread_sleep_millisecs));
-		} else {
-			wait_event_freezable(ksm_thread_wait,
-				ksmd_should_run() || kthread_should_stop());
-		}
-	}
-	return 0;
-}
-
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags)
 {
@@ -1568,6 +1562,119 @@ void __ksm_exit(struct mm_struct *mm)
 	}
 }
 
+static int ksm_madvise_mm(struct mm_struct *mm)
+{
+	/*
+	 * Must be entered with down_write(&mm->mmap_sem)
+	 */
+	struct vm_area_struct *vma;
+	unsigned long new_flags;
+	int err = 0;
+
+	vma = mm->mmap;
+	if (!vma)
+		return err;
+	for (; vma; vma = vma->vm_next) {
+		new_flags = vma->vm_flags;
+
+		VM_BUG_ON(vma->vm_start >= vma->vm_end);
+		err = ksm_madvise(vma, vma->vm_start, vma->vm_end,
+				MADV_MERGEABLE, &new_flags);
+		if (err)
+			break;
+		if (new_flags == vma->vm_flags)
+			continue;
+
+		vma->vm_flags = new_flags;
+		cond_resched();
+	}
+
+	return err;
+}
+
+static int ksmd_should_run(void)
+{
+	return (ksm_run & KSM_RUN_MERGE) && !list_empty(&ksm_mm_head.mm_list);
+}
+
+static int ksmd_should_madvise(void)
+{
+	return ksm_share_all;
+}
+
+static int ksm_madvise_all(void)
+{
+	struct task_struct *p;
+	int err;
+
+	for_each_process(p) {
+		read_lock(&tasklist_lock);
+
+		if (!p->mm)
+			goto out;
+
+		down_write(&p->mm->mmap_sem);
+		err = ksm_madvise_mm(p->mm);
+		up_write(&p->mm->mmap_sem);
+out:
+		read_unlock(&tasklist_lock);
+		if (err)
+			break;
+		cond_resched();
+	}
+	return err;
+}
+
+/**
+ * ksm_do_scan  - the ksm scanner main worker function.
+ * @scan_npages - number of pages we want to scan before we return.
+ */
+static void ksm_do_scan(unsigned int scan_npages)
+{
+	struct rmap_item *rmap_item;
+	struct page *uninitialized_var(page);
+
+	while (scan_npages-- && likely(!freezing(current))) {
+		cond_resched();
+		rmap_item = scan_get_next_rmap_item(&page);
+		if (!rmap_item)
+			return;
+		if (!PageKsm(page) || !in_stable_tree(rmap_item))
+			cmp_and_merge_page(page, rmap_item);
+		put_page(page);
+	}
+}
+
+static int ksm_scan_thread(void *nothing)
+{
+	set_freezable();
+	set_user_nice(current, 5);
+
+	while (!kthread_should_stop()) {
+		mutex_lock(&ksm_thread_mutex);
+		if (ksmd_should_madvise()) {
+			ksm_madvise_all();
+			ksm_share_all = 0;
+		}
+		if (ksmd_should_run())
+			ksm_do_scan(ksm_thread_pages_to_scan);
+		mutex_unlock(&ksm_thread_mutex);
+
+		try_to_freeze();
+
+		if (ksmd_should_run()) {
+			schedule_timeout_interruptible(
+				msecs_to_jiffies(ksm_thread_sleep_millisecs));
+		} else {
+			wait_event_freezable(ksm_thread_wait,
+				ksmd_should_run() ||
+				ksmd_should_madvise() ||
+				kthread_should_stop());
+		}
+	}
+	return 0;
+}
+
 struct page *ksm_does_need_to_copy(struct page *page,
 			struct vm_area_struct *vma, unsigned long address)
 {
@@ -1768,15 +1875,19 @@ static struct stable_node *ksm_check_stable_tree(unsigned long start_pfn,
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
 
@@ -1926,6 +2037,81 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
 }
 KSM_ATTR(run);
 
+#ifdef CONFIG_NUMA
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
+	unsigned long knob;
+
+	err = kstrtoul(buf, 10, &knob);
+	if (err)
+		return err;
+	if (knob > 1)
+		return -EINVAL;
+
+	mutex_lock(&ksm_thread_mutex);
+	if (ksm_run & KSM_RUN_MERGE) {
+		err = -EBUSY;
+	} else {
+		if (ksm_merge_nodes != knob) {
+			if (ksm_pages_shared > 0)
+				err = -EBUSY;
+			else
+				ksm_merge_nodes = knob;
+		}
+	}
+
+	if (err)
+		count = err;
+	mutex_unlock(&ksm_thread_mutex);
+
+	return count;
+}
+KSM_ATTR(merge_nodes);
+#endif
+
+static ssize_t share_all_show(struct kobject *kobj,
+				 struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_share_all);
+}
+
+static ssize_t share_all_store(struct kobject *kobj,
+				 struct kobj_attribute *attr,
+				 const char *buf, size_t count)
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
+	if (ksm_run & KSM_RUN_MERGE) {
+		err = -EBUSY;
+	} else {
+		if (ksm_share_all != knob)
+			ksm_share_all = knob;
+	}
+	if (err)
+		count = err;
+	mutex_unlock(&ksm_thread_mutex);
+
+	return count;
+}
+KSM_ATTR(share_all);
+
 static ssize_t pages_shared_show(struct kobject *kobj,
 				 struct kobj_attribute *attr, char *buf)
 {
@@ -1980,6 +2166,10 @@ static struct attribute *ksm_attrs[] = {
 	&pages_unshared_attr.attr,
 	&pages_volatile_attr.attr,
 	&full_scans_attr.attr,
+	&share_all_attr.attr,
+#ifdef CONFIG_NUMA
+	&merge_nodes_attr.attr,
+#endif
 	NULL,
 };
 
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
