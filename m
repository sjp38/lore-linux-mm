Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 72B3B6B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:11:03 -0400 (EDT)
Subject: Re: [PATCH 4/4] hugetlb: add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090731103632.GB28766@csn.ul.ie>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
	 <20090729181205.23716.25002.sendpatchset@localhost.localdomain>
	 <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com>
	 <20090731103632.GB28766@csn.ul.ie>
Content-Type: text/plain
Date: Fri, 31 Jul 2009 15:10:52 -0400
Message-Id: <1249067452.4674.235.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2009-07-31 at 11:36 +0100, Mel Gorman wrote:
> On Thu, Jul 30, 2009 at 12:39:09PM -0700, David Rientjes wrote:
> > On Wed, Jul 29, 2009 at 11:12 AM, Lee
> > Schermerhorn<lee.schermerhorn@hp.com> wrote:
> > > PATCH/RFC 4/4 hugetlb:  register per node hugepages attributes
> > >
> > > Against: 2.6.31-rc3-mmotm-090716-1432
> > > atop the previously posted alloc_bootmem_hugepages fix.
> > > [http://marc.info/?l=linux-mm&m=124775468226290&w=4]
> > >
> > > This patch adds the per huge page size control/query attributes
> > > to the per node sysdevs:
> > >
> > > /sys/devices/system/node/node<ID>/hugepages/hugepages-<size>/
> > >        nr_hugepages       - r/w
> > >        free_huge_pages    - r/o
> > >        surplus_huge_pages - r/o
> > >
> > > The patch attempts to re-use/share as much of the existing
> > > global hstate attribute initialization and handling as possible.
> > > Throughout, a node id < 0 indicates global hstate parameters.
> > >
> > > Note:  computation of "min_count" in set_max_huge_pages() for a
> > > specified node needs careful review.
> > >
> > > Issue:  dependency of base driver [node] dependency on hugetlbfs module.
> > > We want to keep all of the hstate attribute registration and handling
> > > in the hugetlb module.  However, we need to call into this code to
> > > register the per node hstate attributes on node hot plug.
> > >
> > > With this patch:
> > >
> > > (me):ls /sys/devices/system/node/node0/hugepages/hugepages-2048kB
> > > ./  ../  free_hugepages  nr_hugepages  surplus_hugepages
> > >
> > > Starting from:
> > > Node 0 HugePages_Total:     0
> > > Node 0 HugePages_Free:      0
> > > Node 0 HugePages_Surp:      0
> > > Node 1 HugePages_Total:     0
> > > Node 1 HugePages_Free:      0
> > > Node 1 HugePages_Surp:      0
> > > Node 2 HugePages_Total:     0
> > > Node 2 HugePages_Free:      0
> > > Node 2 HugePages_Surp:      0
> > > Node 3 HugePages_Total:     0
> > > Node 3 HugePages_Free:      0
> > > Node 3 HugePages_Surp:      0
> > > vm.nr_hugepages = 0
> > >
> > > Allocate 16 persistent huge pages on node 2:
> > > (me):echo 16 >/sys/devices/system/node/node2/hugepages/hugepages-2048kB/nr_hugepages
> > >
> > > Yields:
> > > Node 0 HugePages_Total:     0
> > > Node 0 HugePages_Free:      0
> > > Node 0 HugePages_Surp:      0
> > > Node 1 HugePages_Total:     0
> > > Node 1 HugePages_Free:      0
> > > Node 1 HugePages_Surp:      0
> > > Node 2 HugePages_Total:    16
> > > Node 2 HugePages_Free:     16
> > > Node 2 HugePages_Surp:      0
> > > Node 3 HugePages_Total:     0
> > > Node 3 HugePages_Free:      0
> > > Node 3 HugePages_Surp:      0
> > > vm.nr_hugepages = 16
> > >
> > > Global controls work as expected--reduce pool to 8 persistent huge pages:
> > > (me):echo 8 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
> > >
> > > Node 0 HugePages_Total:     0
> > > Node 0 HugePages_Free:      0
> > > Node 0 HugePages_Surp:      0
> > > Node 1 HugePages_Total:     0
> > > Node 1 HugePages_Free:      0
> > > Node 1 HugePages_Surp:      0
> > > Node 2 HugePages_Total:     8
> > > Node 2 HugePages_Free:      8
> > > Node 2 HugePages_Surp:      0
> > > Node 3 HugePages_Total:     0
> > > Node 3 HugePages_Free:      0
> > > Node 3 HugePages_Surp:      0
> > >
> > >
> > >
> > >
> > >
> > > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > >
> > 
> > Thank you very much for doing this.
> > 
> > Google is going to need this support regardless of what finally gets
> > merged into mainline, so I'm thrilled you've implemented this version.
> > 
> 
> The fact that there is a definite use case in mind lends weight to this
> approach but I want to be 100% sure that a hugetlbfs-specific interface
> is required in this case.
> 
> > I hugely (get it? hugely :) favor this approach because it's much
> > simpler to reserve hugepages from this interface than a mempolicy
> > based approach once hugepages have already been allocated before.  For
> > cpusets users in particular, jobs typically get allocated on a subset
> > of nodes that are required for that application and they don't last
> > for the duration of the machine's uptime.  When a job exits and the
> > nodes need to be reallocated to a new cpuset, it may be a very
> > different set of mems based on the memory requirements or interleave
> > optimizations for the new job.  Allocating resources such as hugepages
> > are possible in this scenario via mempolicies, but it would require a
> > temporary mempolicy to then allocate additional hugepages from which
> > seems like an unnecessary requirement, especially if the job scheduler
> > that is governing hugepage allocations already has a mempolicy of its
> > own.
> > 
> 
> I don't know the setup, but lets say something like the following is
> happening
> 
> 1. job scheduler creates cpuset of subset of nodes
> 2. job scheduler creates memory policy for subset of nodes
> 3. initialisation job starts, reserves huge pages. If a memory policy is
>    already in place, it will reserve them in the correct places
> 4. Job completes
> 5. job scheduler frees the pages reserved for the job freeing up pages
>    on the subset of nodes
> 
> i.e. if the job scheduler already has a memory policy of it's own, or
> even some child process of that job scheduler, it should just be able to
> set nr_hugepages and have them reserved on the correct nodes.
> 
> With the per-node-attribute approach, little stops a process going
> outside of it's subset of allowed nodes.
> 
> > So it's my opinion that the mempolicy based approach is very
> > appropriate for tasks that allocate hugepages itself.  Other users,
> > particularly cpusets users, however, would require preallocation of
> > hugepages prior to a job being scheduled in which case a temporary
> > mempolicy would be required for that job scheduler. 
> 
> And why is it such a big difficulty for the job scheduler just to create a
> child that does
> 
> numactl -m $NODES_SUBSET hugeadm --pool-pages-min 2M:+$PAGES_NEEDED
> 
> ?
> 
> > That seems like
> > an inconvenience when the entire state of the system's hugepages could
> > easily be governed with the per-node hstate attributes and a slightly
> > modified user library.
> > 
> 

It occurred to me that I could easily rebase the per node attributes
atop the mempolicy based nodes_allowed series and support both methods
of control.  I'm not saying that I should, just that I could.  So, I
did.  This applies atop the V3 mempolicy based nodes_allowed series.
[You'll want the patch to restore the kfree of nodes_allowed that I just
sent out.]

I'll be offline for most/all of next week, so perhaps David and Mel
could have a look at this and sort out how they want to proceed.
Andrew is holding off on these series until we can decide on one.

Lee
---

PATCH/RFC 5/4 hugetlb:  register per node hugepages attributes

Against: 2.6.31-rc4-mmotm-090730-0510
and the hugetlb rework and mempolicy-based nodes_allowed
series

V2:  remove dependency on kobject private bitfield.  Search
     global hstates then all per node hstates for kobject
     match in attribute show/store functions.

V3:  rebase atop the mempolicy-based hugepage alloc/free;
     use custom "nodes_allowed" to restrict alloc/free to
     a specific node via per node attributes.  Per node
     attribute overrides mempolicy.  I.e., mempolicy only
     applies to global attributes.

To demonstrate feasibility--if not advisability--of supporting
both mempolicy-based persistent huge page management with per
node "override" attributes.

This patch adds the per huge page size control/query attributes
to the per node sysdevs:

/sys/devices/system/node/node<ID>/hugepages/hugepages-<size>/
	nr_hugepages       - r/w
	free_huge_pages    - r/o
	surplus_huge_pages - r/o

The patch attempts to re-use/share as much of the existing
global hstate attribute initialization and handling, and the
"nodes_allowed" constraint processing as possible.
In set_max_huge_pages(), a node id < 0 indicates a change to
global hstate parameters.  In this case, any non-default task
mempolicy will be used to generate the nodes_allowed mask.  A
node id > 0 indicates a node specific update and the count 
argument specifies the target count for the node.  From this
info, we compute the target global count for the hstate and
construct a nodes_allowed node mask contain only the specified
node.  Thus, setting the node specific nr_hugepages via the
per node attribute effectively overrides any task mempolicy.


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

 drivers/base/node.c     |    2 
 include/linux/hugetlb.h |    6 +
 include/linux/node.h    |    3 
 mm/hugetlb.c            |  213 +++++++++++++++++++++++++++++++++++++++++-------
 4 files changed, 197 insertions(+), 27 deletions(-)

Index: linux-2.6.31-rc4-mmotm-090730-0501/drivers/base/node.c
===================================================================
--- linux-2.6.31-rc4-mmotm-090730-0501.orig/drivers/base/node.c	2009-07-31 12:06:28.000000000 -0400
+++ linux-2.6.31-rc4-mmotm-090730-0501/drivers/base/node.c	2009-07-31 12:39:23.000000000 -0400
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
--- linux-2.6.31-rc4-mmotm-090730-0501.orig/include/linux/hugetlb.h	2009-07-31 12:06:28.000000000 -0400
+++ linux-2.6.31-rc4-mmotm-090730-0501/include/linux/hugetlb.h	2009-07-31 12:39:23.000000000 -0400
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
--- linux-2.6.31-rc4-mmotm-090730-0501.orig/mm/hugetlb.c	2009-07-31 12:07:16.000000000 -0400
+++ linux-2.6.31-rc4-mmotm-090730-0501/mm/hugetlb.c	2009-07-31 12:59:57.000000000 -0400
@@ -24,6 +24,7 @@
 #include <asm/io.h>
 
 #include <linux/hugetlb.h>
+#include <linux/node.h>
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
@@ -1253,8 +1254,24 @@ static int adjust_pool_surplus(struct hs
 	return ret;
 }
 
+static nodemask_t *nodes_allowed_from_node(int nid)
+{
+	nodemask_t *nodes_allowed;
+	nodes_allowed = kmalloc(sizeof(*nodes_allowed), GFP_KERNEL);
+	if (!nodes_allowed) {
+		printk(KERN_WARNING "%s unable to allocate nodes allowed mask "
+			"for huge page allocation.\nFalling back to default.\n",
+			current->comm);
+	} else {
+		nodes_clear(*nodes_allowed);
+		node_set(nid, *nodes_allowed);
+	}
+	return nodes_allowed;
+}
+
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
+static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
+								int nid)
 {
 	unsigned long min_count, ret;
 	nodemask_t *nodes_allowed;
@@ -1262,7 +1279,17 @@ static unsigned long set_max_huge_pages(
 	if (h->order >= MAX_ORDER)
 		return h->max_huge_pages;
 
-	nodes_allowed = huge_mpol_nodes_allowed();
+	if (nid < 0)
+		nodes_allowed = huge_mpol_nodes_allowed();
+	else {
+		/*
+		 * incoming 'count' is for node 'nid' only, so
+		 * adjust count to global, but restrict alloc/free
+		 * to the specified node.
+		 */
+		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
+		nodes_allowed = nodes_allowed_from_node(nid);
+	}
 
 	/*
 	 * Increase the pool size
@@ -1338,34 +1365,69 @@ out:
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
@@ -1374,15 +1436,17 @@ HSTATE_ATTR(nr_hugepages);
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
@@ -1399,15 +1463,24 @@ HSTATE_ATTR(nr_overcommit_hugepages);
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
@@ -1415,8 +1488,17 @@ HSTATE_ATTR_RO(resv_hugepages);
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
 
@@ -1433,19 +1515,21 @@ static struct attribute_group hstate_att
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
@@ -1460,17 +1544,90 @@ static void __init hugetlb_sysfs_init(vo
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
@@ -1505,6 +1662,8 @@ static int __init hugetlb_init(void)
 
 	hugetlb_sysfs_init();
 
+	hugetlb_register_all_nodes();
+
 	return 0;
 }
 module_init(hugetlb_init);
@@ -1607,7 +1766,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
 	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
 
 	if (write)
-		h->max_huge_pages = set_max_huge_pages(h, tmp);
+		h->max_huge_pages = set_max_huge_pages(h, tmp, -1);
 
 	return 0;
 }
Index: linux-2.6.31-rc4-mmotm-090730-0501/include/linux/node.h
===================================================================
--- linux-2.6.31-rc4-mmotm-090730-0501.orig/include/linux/node.h	2009-07-31 12:06:28.000000000 -0400
+++ linux-2.6.31-rc4-mmotm-090730-0501/include/linux/node.h	2009-07-31 12:39:23.000000000 -0400
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
