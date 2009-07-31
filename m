Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 519B66B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 14:59:15 -0400 (EDT)
Subject: Re: [PATCH 3/4] hugetlb:  add private bit-field to kobject
 structure
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090729182501.GA1699@suse.de>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
	 <20090729181158.23716.41437.sendpatchset@localhost.localdomain>
	 <20090729182501.GA1699@suse.de>
Content-Type: text/plain
Date: Fri, 31 Jul 2009 14:59:04 -0400
Message-Id: <1249066744.4674.224.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2009-07-29 at 11:25 -0700, Greg KH wrote:
> On Wed, Jul 29, 2009 at 02:11:58PM -0400, Lee Schermerhorn wrote:
> > PATCH/RFC 3/4 hugetlb:  add private bitfield to struct kobject
> > 
> > Against: 2.6.31-rc3-mmotm-090716-1432
> > atop the previously posted alloc_bootmem_hugepages fix.
> > [http://marc.info/?l=linux-mm&m=124775468226290&w=4]
> > 
> > For the per node huge page attributes, we want to share
> > as much code as possible with the global huge page attributes,
> > including the show/store functions.  To do this, we'll need a
> > way to back translate from the kobj argument to the show/store
> > function to the node id, when entered via that path.  This
> > patch adds a subsystem/sysdev private bitfield to the kobject
> > structure.  The bitfield uses unused bits in the same unsigned
> > int as the various kobject flags so as not to increase the size
> > of the structure. 
> > 
> > Currently, the bit field is the minimum required for the huge
> > pages per node attributes [plus one extra bit].  The field could
> > be expanded for other usage, should such arise.
> > 
> > Note that this is not absolutely required.  However, using this
> > private field eliminates an inner loop to scan the per node
> > hstate kobjects and eliminates scanning entirely for the global
> > hstate kobjects.
> 
> Ick, no, please don't do that.  That's what the structure you use to
> contain your kobject should be for, right?
> 
> Or are you for some reason using "raw" kobjects?

OK, reworked to remove the private bit field from kobject.  This
replaces patches 3 and 4 of 4 in case anyone wants to test the series
w/o the change to the kobject structure.  I'll be sending out another
version of this patch in response to a thread with David and Mel
shortly.

Lee
---

PATCH/RFC 3/3 hugetlb:  register per node hugepages attributes

Against: 2.6.31-rc3-mmotm-090716-1432
atop the previously posted alloc_bootmem_hugepages fix.
[http://marc.info/?l=linux-mm&m=124775468226290&w=4]

V2:  remove dependency on kobject private bitfield.  Search
     global hstates then all per node hstates for kobject
     match in attribute show/store functions.

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

 drivers/base/node.c     |    2 
 include/linux/hugetlb.h |    6 +
 include/linux/node.h    |    3 
 mm/hugetlb.c            |  274 ++++++++++++++++++++++++++++++++++++++++--------
 4 files changed, 243 insertions(+), 42 deletions(-)

Index: linux-2.6.31-rc4-mmotm-090730-0501/drivers/base/node.c
===================================================================
--- linux-2.6.31-rc4-mmotm-090730-0501.orig/drivers/base/node.c	2009-07-30 16:57:34.000000000 -0400
+++ linux-2.6.31-rc4-mmotm-090730-0501/drivers/base/node.c	2009-07-31 11:01:49.000000000 -0400
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
Index: linux-2.6.31-rc4-mmotm-090730-0501/include/linux/hugetlb.h
===================================================================
--- linux-2.6.31-rc4-mmotm-090730-0501.orig/include/linux/hugetlb.h	2009-07-30 16:57:33.000000000 -0400
+++ linux-2.6.31-rc4-mmotm-090730-0501/include/linux/hugetlb.h	2009-07-31 10:17:37.000000000 -0400
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
Index: linux-2.6.31-rc4-mmotm-090730-0501/mm/hugetlb.c
===================================================================
--- linux-2.6.31-rc4-mmotm-090730-0501.orig/mm/hugetlb.c	2009-07-31 10:15:39.000000000 -0400
+++ linux-2.6.31-rc4-mmotm-090730-0501/mm/hugetlb.c	2009-07-31 10:45:00.000000000 -0400
@@ -24,6 +24,7 @@
 #include <asm/io.h>
 
 #include <linux/hugetlb.h>
+#include <linux/node.h>
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
@@ -1155,14 +1156,22 @@ static void __init report_hugepages(void
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
@@ -1178,7 +1187,8 @@ static void try_to_free_low(struct hstat
 	}
 }
 #else
-static inline void try_to_free_low(struct hstate *h, unsigned long count)
+static inline void try_to_free_low(struct hstate *h, unsigned long count,
+								int nid)
 {
 }
 #endif
@@ -1239,8 +1249,17 @@ static int adjust_pool_surplus(struct hs
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
 
@@ -1259,19 +1278,26 @@ static unsigned long set_max_huge_pages(
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
@@ -1293,19 +1319,51 @@ static unsigned long set_max_huge_pages(
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
@@ -1320,34 +1378,69 @@ out:
 static struct kobject *hugepages_kobj;
 static struct kobject *hstate_kobjs[HUGE_MAX_HSTATE];
 
-static struct hstate *kobj_to_hstate(struct kobject *kobj)
+static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
+{
+	int nid;
+
+	for (nid = 0; nid < nr_node_ids; nid++) {
+		struct node *node = &node_devices[nid];
+		int hi;
+		for (hi = 0; hi < HUGE_MAX_HSTATE; hi++)
+			if (node->hstate_kobjs[hi] == kobj) {
+				if (nidp)
+					*nidp = nid;
+				return &hstates[hi];
+			}
+	}
+
+	BUG();
+	return NULL;
+}
+
+static struct hstate *kobj_to_hstate(struct kobject *kobj, int *nidp)
 {
 	int i;
+
 	for (i = 0; i < HUGE_MAX_HSTATE; i++)
-		if (hstate_kobjs[i] == kobj)
+		if (hstate_kobjs[i] == kobj) {
+			if (nidp)
+				*nidp = -1;
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
-	struct hstate *h = kobj_to_hstate(kobj);
+	struct hstate *h;
+	int nid;
+	int err;
 
 	err = strict_strtoul(buf, 10, &input);
 	if (err)
 		return 0;
 
-	h->max_huge_pages = set_max_huge_pages(h, input);
+	h = kobj_to_hstate(kobj, &nid);
+	h->max_huge_pages = set_max_huge_pages(h, input, nid);
 
 	return count;
 }
@@ -1356,15 +1449,17 @@ HSTATE_ATTR(nr_hugepages);
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
@@ -1381,15 +1476,24 @@ HSTATE_ATTR(nr_overcommit_hugepages);
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
+	if (nid < 0)
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
@@ -1397,8 +1501,17 @@ HSTATE_ATTR_RO(resv_hugepages);
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
+	if (nid < 0)
+		surplus_huge_pages = h->surplus_huge_pages;
+	else
+		surplus_huge_pages = h->surplus_huge_pages_node[nid];
+
+	return sprintf(buf, "%lu\n", surplus_huge_pages);
 }
 HSTATE_ATTR_RO(surplus_hugepages);
 
@@ -1415,19 +1528,21 @@ static struct attribute_group hstate_att
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
@@ -1442,17 +1557,90 @@ static void __init hugetlb_sysfs_init(vo
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
@@ -1487,6 +1675,8 @@ static int __init hugetlb_init(void)
 
 	hugetlb_sysfs_init();
 
+	hugetlb_register_all_nodes();
+
 	return 0;
 }
 module_init(hugetlb_init);
@@ -1589,7 +1779,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
 	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
 
 	if (write)
-		h->max_huge_pages = set_max_huge_pages(h, tmp);
+		h->max_huge_pages = set_max_huge_pages(h, tmp, -1);
 
 	return 0;
 }
Index: linux-2.6.31-rc4-mmotm-090730-0501/include/linux/node.h
===================================================================
--- linux-2.6.31-rc4-mmotm-090730-0501.orig/include/linux/node.h	2009-06-09 23:05:27.000000000 -0400
+++ linux-2.6.31-rc4-mmotm-090730-0501/include/linux/node.h	2009-07-31 10:52:31.000000000 -0400
@@ -21,9 +21,12 @@
 
 #include <linux/sysdev.h>
 #include <linux/cpumask.h>
+#include <linux/hugetlb.h>
 
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
