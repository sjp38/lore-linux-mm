Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 45BC36B0088
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 12:00:46 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 28 Aug 2009 12:03:44 -0400
Message-Id: <20090828160344.11080.20255.sendpatchset@localhost.localdomain>
In-Reply-To: <20090828160314.11080.18541.sendpatchset@localhost.localdomain>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain>
Subject: [PATCH 5/6] hugetlb:  add per node hstate attributes
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 5/6] hugetlb:  register per node hugepages attributes

Against: 2.6.31-rc7-mmotm-090820-1918

V2:  remove dependency on kobject private bitfield.  Search
     global hstates then all per node hstates for kobject
     match in attribute show/store functions.

V3:  rebase atop the mempolicy-based hugepage alloc/free;
     use custom "nodes_allowed" to restrict alloc/free to
     a specific node via per node attributes.  Per node
     attribute overrides mempolicy.  I.e., mempolicy only
     applies to global attributes.

V5:  Fix issues raised by Mel Gorman:
     + add !NUMA versions of hugetlb_[un]register_node()
     + rename 'hi' to 'i' in kobj_to_node_hstate()
     + rename (count, input) to (len, count) in nr_hugepages_store()
     + moved per node hugepages_kobj and hstate_kobjs[] from the
       struct node [sysdev] to hugetlb.c private arrays.
     + changed registration mechanism so that hugetlbfs [a module]
       register its attributes registration callbacks with the node
       driver, eliminating the dependency between the node driver
       and hugetlbfs.  From it's init func, hugetlbfs will register
       all on-line nodes' hugepage sysfs attributes along with
       hugetlbfs' attributes register/unregister functions.  The
       node driver will use these functions to [un]register nodes
       with hugetlbfs on node hot-plug.
     + replaced hugetlb.c private "nodes_allowed_from_node()" with
       [new] generic "alloc_nodemask_of_node()".

V5a: + fix !NUMA register_hugetlbfs_with_node():  don't use
       keyword 'do' as parameter name!

This patch adds the per huge page size control/query attributes
to the per node sysdevs:

/sys/devices/system/node/node<ID>/hugepages/hugepages-<size>/
	nr_hugepages       - r/w
	free_huge_pages    - r/o
	surplus_huge_pages - r/o

The patch attempts to re-use/share as much of the existing
global hstate attribute initialization and handling, and the
"nodes_allowed" constraint processing as possible.
Calling set_max_huge_pages() with no node indicates a change to
global hstate parameters.  In this case, any non-default task
mempolicy will be used to generate the nodes_allowed mask.  A
valid node id indicates an update to that node's hstate 
parameters, and the count argument specifies the target count
for the specified node.  From this info, we compute the target
global count for the hstate and construct a nodes_allowed node
mask contain only the specified node.

Setting the node specific nr_hugepages via the per node attribute
effectively ignores any task mempolicy or cpuset constraints.

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

[Note that this is equivalent to:
	numactl -m 2 hugeadmin --pool-pages-min 2M:+16
]

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

 drivers/base/node.c  |   33 ++++++
 include/linux/node.h |    8 +
 include/linux/numa.h |    2 
 mm/hugetlb.c         |  245 ++++++++++++++++++++++++++++++++++++++++++++-------
 4 files changed, 258 insertions(+), 30 deletions(-)

Index: linux-2.6.31-rc7-mmotm-090827-0057/drivers/base/node.c
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-0057.orig/drivers/base/node.c	2009-08-28 09:21:17.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-0057/drivers/base/node.c	2009-08-28 09:21:31.000000000 -0400
@@ -177,6 +177,37 @@ static ssize_t node_read_distance(struct
 }
 static SYSDEV_ATTR(distance, S_IRUGO, node_read_distance, NULL);
 
+/*
+ * hugetlbfs per node attributes registration interface:
+ * When/if hugetlb[fs] subsystem initializes [sometime after this module],
+ * it will register it's per node attributes for all nodes on-line at that
+ * point.  It will also call register_hugetlbfs_with_node(), below, to
+ * register it's attribute registration functions with this node driver.
+ * Once these hooks have been initialized, the node driver will call into
+ * the hugetlb module to [un]register attributes for hot-plugged nodes.
+ */
+NODE_REGISTRATION_FUNC __hugetlb_register_node;
+NODE_REGISTRATION_FUNC __hugetlb_unregister_node;
+
+static inline void hugetlb_register_node(struct node *node)
+{
+	if (__hugetlb_register_node)
+		__hugetlb_register_node(node);
+}
+
+static inline void hugetlb_unregister_node(struct node *node)
+{
+	if (__hugetlb_unregister_node)
+		__hugetlb_unregister_node(node);
+}
+
+void register_hugetlbfs_with_node(NODE_REGISTRATION_FUNC doregister,
+                                  NODE_REGISTRATION_FUNC unregister)
+{
+	__hugetlb_register_node   = doregister;
+	__hugetlb_unregister_node = unregister;
+}
+
 
 /*
  * register_node - Setup a sysfs device for a node.
@@ -200,6 +231,7 @@ int register_node(struct node *node, int
 		sysdev_create_file(&node->sysdev, &attr_distance);
 
 		scan_unevictable_register_node(node);
+		hugetlb_register_node(node);
 	}
 	return error;
 }
@@ -220,6 +252,7 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_distance);
 
 	scan_unevictable_unregister_node(node);
+	hugetlb_unregister_node(node);
 
 	sysdev_unregister(&node->sysdev);
 }
Index: linux-2.6.31-rc7-mmotm-090827-0057/mm/hugetlb.c
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-0057.orig/mm/hugetlb.c	2009-08-28 09:21:28.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-0057/mm/hugetlb.c	2009-08-28 09:21:31.000000000 -0400
@@ -24,6 +24,7 @@
 #include <asm/io.h>
 
 #include <linux/hugetlb.h>
+#include <linux/node.h>
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
@@ -1245,7 +1246,8 @@ static int adjust_pool_surplus(struct hs
 }
 
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
+static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
+								int nid)
 {
 	unsigned long min_count, ret;
 	nodemask_t *nodes_allowed;
@@ -1253,7 +1255,21 @@ static unsigned long set_max_huge_pages(
 	if (h->order >= MAX_ORDER)
 		return h->max_huge_pages;
 
-	nodes_allowed = huge_mpol_nodes_allowed();
+	if (nid == NO_NODEID_SPECIFIED)
+		nodes_allowed = huge_mpol_nodes_allowed();
+	else {
+		/*
+		 * incoming 'count' is for node 'nid' only, so
+		 * adjust count to global, but restrict alloc/free
+		 * to the specified node.
+		 */
+		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
+		nodes_allowed = alloc_nodemask_of_node(nid);
+		if (!nodes_allowed)
+			printk(KERN_WARNING "%s unable to allocate allowed "
+			       "nodes mask for huge page allocation/free.  "
+			       "Falling back to default.\n", current->comm);
+	}
 
 	/*
 	 * Increase the pool size
@@ -1329,51 +1345,71 @@ out:
 static struct kobject *hugepages_kobj;
 static struct kobject *hstate_kobjs[HUGE_MAX_HSTATE];
 
-static struct hstate *kobj_to_hstate(struct kobject *kobj)
+static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp);
+
+static struct hstate *kobj_to_hstate(struct kobject *kobj, int *nidp)
 {
 	int i;
+
 	for (i = 0; i < HUGE_MAX_HSTATE; i++)
-		if (hstate_kobjs[i] == kobj)
+		if (hstate_kobjs[i] == kobj) {
+			if (nidp)
+				*nidp = NO_NODEID_SPECIFIED;
 			return &hstates[i];
-	BUG();
-	return NULL;
+		}
+
+	return kobj_to_node_hstate(kobj, nidp);
 }
 
 static ssize_t nr_hugepages_show(struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
-	struct hstate *h = kobj_to_hstate(kobj);
-	return sprintf(buf, "%lu\n", h->nr_huge_pages);
+	struct hstate *h;
+	unsigned long nr_huge_pages;
+	int nid;
+
+	h = kobj_to_hstate(kobj, &nid);
+	if (nid == NO_NODEID_SPECIFIED)
+		nr_huge_pages = h->nr_huge_pages;
+	else
+		nr_huge_pages = h->nr_huge_pages_node[nid];
+
+	return sprintf(buf, "%lu\n", nr_huge_pages);
 }
+
 static ssize_t nr_hugepages_store(struct kobject *kobj,
-		struct kobj_attribute *attr, const char *buf, size_t count)
+		struct kobj_attribute *attr, const char *buf, size_t len)
 {
+	unsigned long count;
+	struct hstate *h;
+	int nid;
 	int err;
-	unsigned long input;
-	struct hstate *h = kobj_to_hstate(kobj);
 
-	err = strict_strtoul(buf, 10, &input);
+	err = strict_strtoul(buf, 10, &count);
 	if (err)
 		return 0;
 
-	h->max_huge_pages = set_max_huge_pages(h, input);
+	h = kobj_to_hstate(kobj, &nid);
+	h->max_huge_pages = set_max_huge_pages(h, count, nid);
 
-	return count;
+	return len;
 }
 HSTATE_ATTR(nr_hugepages);
 
 static ssize_t nr_overcommit_hugepages_show(struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
-	struct hstate *h = kobj_to_hstate(kobj);
+	struct hstate *h = kobj_to_hstate(kobj, NULL);
+
 	return sprintf(buf, "%lu\n", h->nr_overcommit_huge_pages);
 }
+
 static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 		struct kobj_attribute *attr, const char *buf, size_t count)
 {
 	int err;
 	unsigned long input;
-	struct hstate *h = kobj_to_hstate(kobj);
+	struct hstate *h = kobj_to_hstate(kobj, NULL);
 
 	err = strict_strtoul(buf, 10, &input);
 	if (err)
@@ -1390,15 +1426,24 @@ HSTATE_ATTR(nr_overcommit_hugepages);
 static ssize_t free_hugepages_show(struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
-	struct hstate *h = kobj_to_hstate(kobj);
-	return sprintf(buf, "%lu\n", h->free_huge_pages);
+	struct hstate *h;
+	unsigned long free_huge_pages;
+	int nid;
+
+	h = kobj_to_hstate(kobj, &nid);
+	if (nid == NO_NODEID_SPECIFIED)
+		free_huge_pages = h->free_huge_pages;
+	else
+		free_huge_pages = h->free_huge_pages_node[nid];
+
+	return sprintf(buf, "%lu\n", free_huge_pages);
 }
 HSTATE_ATTR_RO(free_hugepages);
 
 static ssize_t resv_hugepages_show(struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
-	struct hstate *h = kobj_to_hstate(kobj);
+	struct hstate *h = kobj_to_hstate(kobj, NULL);
 	return sprintf(buf, "%lu\n", h->resv_huge_pages);
 }
 HSTATE_ATTR_RO(resv_hugepages);
@@ -1406,8 +1451,17 @@ HSTATE_ATTR_RO(resv_hugepages);
 static ssize_t surplus_hugepages_show(struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
-	struct hstate *h = kobj_to_hstate(kobj);
-	return sprintf(buf, "%lu\n", h->surplus_huge_pages);
+	struct hstate *h;
+	unsigned long surplus_huge_pages;
+	int nid;
+
+	h = kobj_to_hstate(kobj, &nid);
+	if (nid == NO_NODEID_SPECIFIED)
+		surplus_huge_pages = h->surplus_huge_pages;
+	else
+		surplus_huge_pages = h->surplus_huge_pages_node[nid];
+
+	return sprintf(buf, "%lu\n", surplus_huge_pages);
 }
 HSTATE_ATTR_RO(surplus_hugepages);
 
@@ -1424,19 +1478,21 @@ static struct attribute_group hstate_att
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
+	retval = sysfs_create_group(hstate_kobjs[hi], hstate_attr_group);
 	if (retval)
-		kobject_put(hstate_kobjs[h - hstates]);
+		kobject_put(hstate_kobjs[hi]);
 
 	return retval;
 }
@@ -1451,17 +1507,143 @@ static void __init hugetlb_sysfs_init(vo
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
+
+struct node_hstate {
+	struct kobject		*hugepages_kobj;
+	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
+};
+struct node_hstate node_hstates[MAX_NUMNODES];
+
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
+static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
+{
+	int nid;
+
+	for (nid = 0; nid < nr_node_ids; nid++) {
+		struct node_hstate *nhs = &node_hstates[nid];
+		int i;
+		for (i = 0; i < HUGE_MAX_HSTATE; i++)
+			if (nhs->hstate_kobjs[i] == kobj) {
+				if (nidp)
+					*nidp = nid;
+				return &hstates[i];
+			}
+	}
+
+	BUG();
+	return NULL;
+}
+
+void hugetlb_unregister_node(struct node *node)
+{
+	struct hstate *h;
+	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
+
+	if (!nhs->hugepages_kobj)
+		return;
+
+	for_each_hstate(h)
+		if (nhs->hstate_kobjs[h - hstates]) {
+			kobject_put(nhs->hstate_kobjs[h - hstates]);
+			nhs->hstate_kobjs[h - hstates] = NULL;
+		}
+
+	kobject_put(nhs->hugepages_kobj);
+	nhs->hugepages_kobj = NULL;
+}
+
+static void hugetlb_unregister_all_nodes(void)
+{
+	int nid;
+
+	for (nid = 0; nid < nr_node_ids; nid++)
+		hugetlb_unregister_node(&node_devices[nid]);
+
+	register_hugetlbfs_with_node(NULL, NULL);
+}
+
+void hugetlb_register_node(struct node *node)
+{
+	struct hstate *h;
+	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
+	int err;
+
+	if (nhs->hugepages_kobj)
+		return;		/* already allocated */
+
+	nhs->hugepages_kobj = kobject_create_and_add("hugepages",
+							&node->sysdev.kobj);
+	if (!nhs->hugepages_kobj)
+		return;
+
+	for_each_hstate(h) {
+		err = hugetlb_sysfs_add_hstate(h, nhs->hugepages_kobj,
+						nhs->hstate_kobjs,
+						&per_node_hstate_attr_group);
+		if (err) {
+			printk(KERN_ERR "Hugetlb: Unable to add hstate %s"
+					" for node %d\n",
+						h->name, node->sysdev.id);
+			hugetlb_unregister_node(node);
+			break;
+		}
+	}
+}
+
+static void hugetlb_register_all_nodes(void)
+{
+	int nid;
+
+	for (nid = 0; nid < nr_node_ids; nid++) {
+		struct node *node = &node_devices[nid];
+		if (node->sysdev.id == nid)
+			hugetlb_register_node(node);
+	}
+
+	register_hugetlbfs_with_node(hugetlb_register_node,
+                                     hugetlb_unregister_node);
+}
+#else	/* !CONFIG_NUMA */
+
+static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
+{
+	BUG();
+	if (nidp)
+		*nidp = -1;
+	return NULL;
+}
+
+static void hugetlb_unregister_all_nodes(void) { }
+
+static void hugetlb_register_all_nodes(void) { }
+
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
@@ -1496,6 +1678,8 @@ static int __init hugetlb_init(void)
 
 	hugetlb_sysfs_init();
 
+	hugetlb_register_all_nodes();
+
 	return 0;
 }
 module_init(hugetlb_init);
@@ -1598,7 +1782,8 @@ int hugetlb_sysctl_handler(struct ctl_ta
 	proc_doulongvec_minmax(table, write, buffer, length, ppos);
 
 	if (write)
-		h->max_huge_pages = set_max_huge_pages(h, tmp);
+		h->max_huge_pages = set_max_huge_pages(h, tmp,
+		                                       NO_NODEID_SPECIFIED);
 
 	return 0;
 }
Index: linux-2.6.31-rc7-mmotm-090827-0057/include/linux/numa.h
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-0057.orig/include/linux/numa.h	2009-08-28 09:21:17.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-0057/include/linux/numa.h	2009-08-28 09:21:31.000000000 -0400
@@ -10,4 +10,6 @@
 
 #define MAX_NUMNODES    (1 << NODES_SHIFT)
 
+#define NO_NODEID_SPECIFIED	(-1)
+
 #endif /* _LINUX_NUMA_H */
Index: linux-2.6.31-rc7-mmotm-090827-0057/include/linux/node.h
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-0057.orig/include/linux/node.h	2009-08-28 09:21:17.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-0057/include/linux/node.h	2009-08-28 09:21:31.000000000 -0400
@@ -28,6 +28,7 @@ struct node {
 
 struct memory_block;
 extern struct node node_devices[];
+typedef  void (*NODE_REGISTRATION_FUNC)(struct node *);
 
 extern int register_node(struct node *, int, struct node *);
 extern void unregister_node(struct node *node);
@@ -39,6 +40,8 @@ extern int unregister_cpu_under_node(uns
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						int nid);
 extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk);
+extern void register_hugetlbfs_with_node(NODE_REGISTRATION_FUNC doregister,
+                                         NODE_REGISTRATION_FUNC unregister);
 #else
 static inline int register_one_node(int nid)
 {
@@ -65,6 +68,11 @@ static inline int unregister_mem_sect_un
 {
 	return 0;
 }
+
+static inline void register_hugetlbfs_with_node(NODE_REGISTRATION_FUNC reg,
+                                                NODE_REGISTRATION_FUNC unreg)
+{
+}
 #endif
 
 #define to_node(sys_device) container_of(sys_device, struct node, sysdev)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
