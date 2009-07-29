Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E6A116B009A
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 14:09:51 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 29 Jul 2009 14:12:05 -0400
Message-Id: <20090729181205.23716.25002.sendpatchset@localhost.localdomain>
In-Reply-To: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/4] hugetlb:  add per node hstate attributes
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 4/4 hugetlb:  register per node hugepages attributes

Against: 2.6.31-rc3-mmotm-090716-1432
atop the previously posted alloc_bootmem_hugepages fix.
[http://marc.info/?l=linux-mm&m=124775468226290&w=4]

This patch adds the per huge page size control/query attributes
to the per node sysdevs:

/sys/devices/system/node/node<ID>/hugepages/hugepages-<size>/
	nr_hugepages       - r/w
	free_huge_pages    - r/o
	surplus_huge_pages - r/o

The patch attempts to re-use/share as much of the existing
global hstate attribute initialization and handling as possible.
Throughout, a node id < 0 indicates global hstate parameters.

Note:  computation of "min_count" in set_max_huge_pages() for a
specified node needs careful review. 

Issue:  dependency of base driver [node] dependency on hugetlbfs module.
We want to keep all of the hstate attribute registration and handling
in the hugetlb module.  However, we need to call into this code to
register the per node hstate attributes on node hot plug.

With this patch:

(me):ls /sys/devices/system/node/node0/hugepages/hugepages-2048kB
./  ../  free_hugepages  nr_hugepages  surplus_hugepages

Starting from:
Node 0 HugePages_Total:     0
Node 0 HugePages_Free:      0
Node 0 HugePages_Surp:      0
Node 1 HugePages_Total:     0
Node 1 HugePages_Free:      0
Node 1 HugePages_Surp:      0
Node 2 HugePages_Total:     0
Node 2 HugePages_Free:      0
Node 2 HugePages_Surp:      0
Node 3 HugePages_Total:     0
Node 3 HugePages_Free:      0
Node 3 HugePages_Surp:      0
vm.nr_hugepages = 0

Allocate 16 persistent huge pages on node 2:
(me):echo 16 >/sys/devices/system/node/node2/hugepages/hugepages-2048kB/nr_hugepages

Yields:
Node 0 HugePages_Total:     0
Node 0 HugePages_Free:      0
Node 0 HugePages_Surp:      0
Node 1 HugePages_Total:     0
Node 1 HugePages_Free:      0
Node 1 HugePages_Surp:      0
Node 2 HugePages_Total:    16
Node 2 HugePages_Free:     16
Node 2 HugePages_Surp:      0
Node 3 HugePages_Total:     0
Node 3 HugePages_Free:      0
Node 3 HugePages_Surp:      0
vm.nr_hugepages = 16

Global controls work as expected--reduce pool to 8 persistent huge pages:
(me):echo 8 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

Node 0 HugePages_Total:     0
Node 0 HugePages_Free:      0
Node 0 HugePages_Surp:      0
Node 1 HugePages_Total:     0
Node 1 HugePages_Free:      0
Node 1 HugePages_Surp:      0
Node 2 HugePages_Total:     8
Node 2 HugePages_Free:      8
Node 2 HugePages_Surp:      0
Node 3 HugePages_Total:     0
Node 3 HugePages_Free:      0
Node 3 HugePages_Surp:      0





Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

---
 drivers/base/node.c     |    2 
 include/linux/hugetlb.h |    6 +
 include/linux/node.h    |    2 
 mm/hugetlb.c            |  266 +++++++++++++++++++++++++++++++++++++++++-------
 4 files changed, 239 insertions(+), 37 deletions(-)

Index: linux-2.6.31-rc3-mmotm-090716-1432/drivers/base/node.c
===================================================================
--- linux-2.6.31-rc3-mmotm-090716-1432.orig/drivers/base/node.c	2009-07-27 16:23:27.000000000 -0400
+++ linux-2.6.31-rc3-mmotm-090716-1432/drivers/base/node.c	2009-07-27 16:23:28.000000000 -0400
@@ -200,6 +200,7 @@ int register_node(struct node *node, int
 		sysdev_create_file(&node->sysdev, &attr_distance);
 
 		scan_unevictable_register_node(node);
+		hugetlb_register_node(node);
 	}
 	return error;
 }
@@ -220,6 +221,7 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_distance);
 
 	scan_unevictable_unregister_node(node);
+	hugetlb_unregister_node(node);
 
 	sysdev_unregister(&node->sysdev);
 }
Index: linux-2.6.31-rc3-mmotm-090716-1432/include/linux/hugetlb.h
===================================================================
--- linux-2.6.31-rc3-mmotm-090716-1432.orig/include/linux/hugetlb.h	2009-07-27 16:23:27.000000000 -0400
+++ linux-2.6.31-rc3-mmotm-090716-1432/include/linux/hugetlb.h	2009-07-27 16:23:28.000000000 -0400
@@ -278,6 +278,10 @@ static inline struct hstate *page_hstate
 	return size_to_hstate(PAGE_SIZE << compound_order(page));
 }
 
+struct node;
+extern void hugetlb_register_node(struct node *);
+extern void hugetlb_unregister_node(struct node *);
+
 #else
 struct hstate {};
 #define alloc_bootmem_huge_page(h) NULL
@@ -294,6 +298,8 @@ static inline unsigned int pages_per_hug
 {
 	return 1;
 }
+#define hugetlb_register_node(NP)
+#define hugetlb_unregister_node(NP)
 #endif
 
 #endif /* _LINUX_HUGETLB_H */
Index: linux-2.6.31-rc3-mmotm-090716-1432/mm/hugetlb.c
===================================================================
--- linux-2.6.31-rc3-mmotm-090716-1432.orig/mm/hugetlb.c	2009-07-27 16:23:27.000000000 -0400
+++ linux-2.6.31-rc3-mmotm-090716-1432/mm/hugetlb.c	2009-07-27 16:23:28.000000000 -0400
@@ -18,6 +18,7 @@
 #include <linux/mutex.h>
 #include <linux/bootmem.h>
 #include <linux/sysfs.h>
+#include <linux/node.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -26,6 +27,10 @@
 #include <linux/hugetlb.h>
 #include "internal.h"
 
+#if (HUGE_MAX_HSTATE > (1 << (KOBJ_PRIVATE_BITS - 1)))
+#error KOBJ_PRIVATE_BITS too small for HUGE_MAX_HSTATE hstates
+#endif
+
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
@@ -1155,14 +1160,22 @@ static void __init report_hugepages(void
 }
 
 #ifdef CONFIG_HIGHMEM
-static void try_to_free_low(struct hstate *h, unsigned long count)
+static void try_to_free_low(struct hstate *h, unsigned long count, int nid)
 {
-	int i;
+	int i, start_i, max_i;
 
 	if (h->order >= MAX_ORDER)
 		return;
 
-	for (i = 0; i < MAX_NUMNODES; ++i) {
+	if (nid < 0) {
+		start_i = 0;
+		max_i = MAX_NUMNODES;
+	} else {
+		start_i = nid;
+		max_i = nid + 1;
+	}
+
+	for (i = start_i; i < max_i; ++i) {
 		struct page *page, *next;
 		struct list_head *freel = &h->hugepage_freelists[i];
 		list_for_each_entry_safe(page, next, freel, lru) {
@@ -1178,7 +1191,8 @@ static void try_to_free_low(struct hstat
 	}
 }
 #else
-static inline void try_to_free_low(struct hstate *h, unsigned long count)
+static inline void try_to_free_low(struct hstate *h, unsigned long count,
+								int nid)
 {
 }
 #endif
@@ -1239,8 +1253,17 @@ static int adjust_pool_surplus(struct hs
 	return ret;
 }
 
-#define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
+static unsigned long persistent_huge_pages(struct hstate *h, int nid)
+{
+	if (nid < 0)
+		return h->nr_huge_pages - h->surplus_huge_pages;
+	else
+		return h->nr_huge_pages_node[nid] -
+			h->surplus_huge_pages_node[nid];
+}
+
+static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
+					int nid)
 {
 	unsigned long min_count, ret;
 
@@ -1259,19 +1282,26 @@ static unsigned long set_max_huge_pages(
 	 * within all the constraints specified by the sysctls.
 	 */
 	spin_lock(&hugetlb_lock);
-	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
-		if (!adjust_pool_surplus(h, -1))
+	while (h->surplus_huge_pages && count > persistent_huge_pages(h, nid)) {
+		if (nid < 0)
+			ret = adjust_pool_surplus(h, -1);
+		else
+			ret = adjust_pool_surplus_node(h, -1, nid);
+		if (!ret)
 			break;
 	}
 
-	while (count > persistent_huge_pages(h)) {
+	while (count > persistent_huge_pages(h, nid)) {
 		/*
 		 * If this allocation races such that we no longer need the
 		 * page, free_huge_page will handle it by freeing the page
 		 * and reducing the surplus.
 		 */
 		spin_unlock(&hugetlb_lock);
-		ret = alloc_fresh_huge_page(h);
+		if (nid < 0)
+			ret = alloc_fresh_huge_page(h);
+		else
+			ret = alloc_fresh_huge_page_node(h, nid);
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
@@ -1293,19 +1323,51 @@ static unsigned long set_max_huge_pages(
 	 * and won't grow the pool anywhere else. Not until one of the
 	 * sysctls are changed, or the surplus pages go out of use.
 	 */
-	min_count = h->resv_huge_pages + h->nr_huge_pages - h->free_huge_pages;
+	if (nid < 0) {
+		/*
+		 * global min_count = reserve + in-use
+		 */
+		min_count = h->resv_huge_pages +
+				 h->nr_huge_pages - h->free_huge_pages;
+	} else {
+		/*
+		 * per node min_count = "min share of global reserve" +
+		 *     in-use
+		 */
+		long need_reserve = (long)h->resv_huge_pages -
+		         (h->free_huge_pages - h->free_huge_pages_node[nid]);
+		if (need_reserve < 0)
+			need_reserve = 0;
+		min_count =
+		    h->nr_huge_pages_node[nid] - h->free_huge_pages_node[nid] +
+		    need_reserve;
+	}
 	min_count = max(count, min_count);
-	try_to_free_low(h, min_count);
-	while (min_count < persistent_huge_pages(h)) {
-		if (!free_pool_huge_page(h, 0))
+	try_to_free_low(h, min_count, nid);
+	while (min_count < persistent_huge_pages(h, nid)) {
+		if (nid < 0)
+			ret = free_pool_huge_page(h, 0);
+		else
+			ret = hstate_free_huge_page_node(h, 0, nid);
+
+		if (!ret)
 			break;
 	}
-	while (count < persistent_huge_pages(h)) {
-		if (!adjust_pool_surplus(h, 1))
+
+	while (count < persistent_huge_pages(h, nid)) {
+		if (nid < 0)
+			ret = adjust_pool_surplus(h, 1);
+		else
+			ret = adjust_pool_surplus_node(h, 1, nid);
+		if (!ret)
 			break;
 	}
 out:
-	ret = persistent_huge_pages(h);
+
+	/*
+	 * return global persistent huge pages
+	 */
+	ret = persistent_huge_pages(h, -1);
 	spin_unlock(&hugetlb_lock);
 	return ret;
 }
@@ -1320,34 +1382,64 @@ out:
 static struct kobject *hugepages_kobj;
 static struct kobject *hstate_kobjs[HUGE_MAX_HSTATE];
 
+static int kobj_to_hstate_index(struct kobject *kobj)
+{
+	return kobj->private >> 1;
+}
+
+static int kobj_to_node_id(struct kobject *kobj)
+{
+	int nid = -1;
+
+	if (kobj->private & 1) {
+		int hi = kobj_to_hstate_index(kobj);
+
+		for (nid = 0; nid < nr_node_ids; nid++) {
+			struct node *node = &node_devices[nid];
+			if (node->hstate_kobjs[hi] == kobj)
+				break;
+		}
+		if (nid == nr_node_ids) {
+			BUG();
+			nid = -1;
+		}
+	}
+	return nid;
+}
+
 static struct hstate *kobj_to_hstate(struct kobject *kobj)
 {
-	int i;
-	for (i = 0; i < HUGE_MAX_HSTATE; i++)
-		if (hstate_kobjs[i] == kobj)
-			return &hstates[i];
-	BUG();
-	return NULL;
+	return &hstates[kobj_to_hstate_index(kobj)];
 }
 
 static ssize_t nr_hugepages_show(struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
 	struct hstate *h = kobj_to_hstate(kobj);
-	return sprintf(buf, "%lu\n", h->nr_huge_pages);
+	unsigned long nr_huge_pages;
+	int nid = kobj_to_node_id(kobj);
+
+	if (nid < 0)
+		nr_huge_pages = h->nr_huge_pages;
+	else
+		nr_huge_pages = h->nr_huge_pages_node[nid];
+
+	return sprintf(buf, "%lu\n", nr_huge_pages);
 }
+
 static ssize_t nr_hugepages_store(struct kobject *kobj,
 		struct kobj_attribute *attr, const char *buf, size_t count)
 {
-	int err;
 	unsigned long input;
 	struct hstate *h = kobj_to_hstate(kobj);
+	int nid = kobj_to_node_id(kobj);
+	int err;
 
 	err = strict_strtoul(buf, 10, &input);
 	if (err)
 		return 0;
 
-	h->max_huge_pages = set_max_huge_pages(h, input);
+	h->max_huge_pages = set_max_huge_pages(h, input, nid);
 
 	return count;
 }
@@ -1359,6 +1451,7 @@ static ssize_t nr_overcommit_hugepages_s
 	struct hstate *h = kobj_to_hstate(kobj);
 	return sprintf(buf, "%lu\n", h->nr_overcommit_huge_pages);
 }
+
 static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 		struct kobj_attribute *attr, const char *buf, size_t count)
 {
@@ -1382,7 +1475,15 @@ static ssize_t free_hugepages_show(struc
 					struct kobj_attribute *attr, char *buf)
 {
 	struct hstate *h = kobj_to_hstate(kobj);
-	return sprintf(buf, "%lu\n", h->free_huge_pages);
+	unsigned long free_huge_pages;
+	int nid = kobj_to_node_id(kobj);
+
+	if (nid < 0)
+		free_huge_pages = h->free_huge_pages;
+	else
+		free_huge_pages = h->free_huge_pages_node[nid];
+
+	return sprintf(buf, "%lu\n", free_huge_pages);
 }
 HSTATE_ATTR_RO(free_hugepages);
 
@@ -1398,7 +1499,15 @@ static ssize_t surplus_hugepages_show(st
 					struct kobj_attribute *attr, char *buf)
 {
 	struct hstate *h = kobj_to_hstate(kobj);
-	return sprintf(buf, "%lu\n", h->surplus_huge_pages);
+	unsigned long surplus_huge_pages;
+	int nid = kobj_to_node_id(kobj);
+
+	if (nid < 0)
+		surplus_huge_pages = h->surplus_huge_pages;
+	else
+		surplus_huge_pages = h->surplus_huge_pages_node[nid];
+
+	return sprintf(buf, "%lu\n", surplus_huge_pages);
 }
 HSTATE_ATTR_RO(surplus_hugepages);
 
@@ -1415,19 +1524,27 @@ static struct attribute_group hstate_att
 	.attrs = hstate_attrs,
 };
 
-static int __init hugetlb_sysfs_add_hstate(struct hstate *h)
+static int __init hugetlb_sysfs_add_hstate(struct hstate *h,
+				struct kobject *parent,
+				struct kobject **hstate_kobjs,
+				struct attribute_group *hstate_attr_group)
 {
 	int retval;
+	int hi = h - hstates;
 
-	hstate_kobjs[h - hstates] = kobject_create_and_add(h->name,
-							hugepages_kobj);
-	if (!hstate_kobjs[h - hstates])
+	hstate_kobjs[hi] = kobject_create_and_add(h->name, parent);
+	if (!hstate_kobjs[hi])
 		return -ENOMEM;
 
-	retval = sysfs_create_group(hstate_kobjs[h - hstates],
-							&hstate_attr_group);
+	/*
+	 * Use kobject private bitfield to save hstate index and to
+	 * indicate per node hstate_kobj for show/store functions
+	 */
+	hstate_kobjs[hi]->private = (hi << 1) | (parent != hugepages_kobj);
+
+	retval = sysfs_create_group(hstate_kobjs[hi], hstate_attr_group);
 	if (retval)
-		kobject_put(hstate_kobjs[h - hstates]);
+		kobject_put(hstate_kobjs[hi]);
 
 	return retval;
 }
@@ -1442,17 +1559,90 @@ static void __init hugetlb_sysfs_init(vo
 		return;
 
 	for_each_hstate(h) {
-		err = hugetlb_sysfs_add_hstate(h);
+		err = hugetlb_sysfs_add_hstate(h, hugepages_kobj,
+					 hstate_kobjs, &hstate_attr_group);
 		if (err)
 			printk(KERN_ERR "Hugetlb: Unable to add hstate %s",
 								h->name);
 	}
 }
 
+#ifdef CONFIG_NUMA
+static struct attribute *per_node_hstate_attrs[] = {
+	&nr_hugepages_attr.attr,
+	&free_hugepages_attr.attr,
+	&surplus_hugepages_attr.attr,
+	NULL,
+};
+
+static struct attribute_group per_node_hstate_attr_group = {
+	.attrs = per_node_hstate_attrs,
+};
+
+
+void hugetlb_unregister_node(struct node *node)
+{
+	struct hstate *h;
+
+	for_each_hstate(h) {
+		kobject_put(node->hstate_kobjs[h - hstates]);
+		node->hstate_kobjs[h - hstates] = NULL;
+	}
+
+	kobject_put(node->hugepages_kobj);
+	node->hugepages_kobj = NULL;
+}
+
+static void hugetlb_unregister_all_nodes(void)
+{
+	int nid;
+
+	for (nid = 0; nid < nr_node_ids; nid++)
+		hugetlb_unregister_node(&node_devices[nid]);
+}
+
+void hugetlb_register_node(struct node *node)
+{
+	struct hstate *h;
+	int err;
+
+	if (!hugepages_kobj)
+		return;		/* too early */
+
+	node->hugepages_kobj = kobject_create_and_add("hugepages",
+							&node->sysdev.kobj);
+	if (!node->hugepages_kobj)
+		return;
+
+	for_each_hstate(h) {
+		err = hugetlb_sysfs_add_hstate(h, node->hugepages_kobj,
+						node->hstate_kobjs,
+						&per_node_hstate_attr_group);
+		if (err)
+			printk(KERN_ERR "Hugetlb: Unable to add hstate %s"
+					" for node %d\n",
+						h->name, node->sysdev.id);
+	}
+}
+
+static void hugetlb_register_all_nodes(void)
+{
+	int nid;
+
+	for (nid = 0; nid < nr_node_ids; nid++) {
+		struct node *node = &node_devices[nid];
+		if (node->sysdev.id == nid && !node->hugepages_kobj)
+			hugetlb_register_node(node);
+	}
+}
+#endif
+
 static void __exit hugetlb_exit(void)
 {
 	struct hstate *h;
 
+	hugetlb_unregister_all_nodes();
+
 	for_each_hstate(h) {
 		kobject_put(hstate_kobjs[h - hstates]);
 	}
@@ -1487,6 +1677,8 @@ static int __init hugetlb_init(void)
 
 	hugetlb_sysfs_init();
 
+	hugetlb_register_all_nodes();
+
 	return 0;
 }
 module_init(hugetlb_init);
@@ -1589,7 +1781,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
 	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
 
 	if (write)
-		h->max_huge_pages = set_max_huge_pages(h, tmp);
+		h->max_huge_pages = set_max_huge_pages(h, tmp, -1);
 
 	return 0;
 }
Index: linux-2.6.31-rc3-mmotm-090716-1432/include/linux/node.h
===================================================================
--- linux-2.6.31-rc3-mmotm-090716-1432.orig/include/linux/node.h	2009-07-27 16:23:27.000000000 -0400
+++ linux-2.6.31-rc3-mmotm-090716-1432/include/linux/node.h	2009-07-27 16:23:28.000000000 -0400
@@ -24,6 +24,8 @@
 
 struct node {
 	struct sys_device	sysdev;
+	struct kobject		*hugepages_kobj;
+	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
 };
 
 struct memory_block;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
