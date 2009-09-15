Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 74B4B6B0092
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:41:40 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 15 Sep 2009 16:45:10 -0400
Message-Id: <20090915204510.4828.10825.sendpatchset@localhost.localdomain>
In-Reply-To: <20090915204327.4828.4349.sendpatchset@localhost.localdomain>
References: <20090915204327.4828.4349.sendpatchset@localhost.localdomain>
Subject: [PATCH 8/11] hugetlb:  Optionally use mempolicy for persistent huge page allocation
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 8/11] hugetlb:  Optionally use mempolicy for persistent huge page allocation

From: Mel Gorman <mel@csn.ul.ie>

Against:  2.6.31-mmotm-090914-0157

Patch "derive huge pages nodes allowed from task mempolicy" brought
huge page support more in line with the core VM in that tuning the size
of the static huge page pool would obey memory policies. Using this,
administrators could interleave allocation of huge pages from a subset
of nodes. This is consistent with how dynamic hugepage pool resizing
works and how hugepages get allocated to applications at run-time.

However, it was pointed out that scripts may exist that depend on being
able to drain all hugepages via /proc/sys/vm/nr_hugepages from processes
that are running within a memory policy. This patch adds
/proc/sys/vm/nr_hugepages_mempolicy which when written to will obey
memory policies. /proc/sys/vm/nr_hugepages continues then to be a
system-wide tunable regardless of memory policy.

Replicate the vm/nr_hugepages_mempolicy sysctl under the sysfs global
hstate attributes directory.

Note:  with this patch, hugeadm will require update to write to the
vm/nr_hugepages_mempolicy sysctl/attribute when one wants to adjust
the hugepage pool on a specific set of nodes.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>


 Documentation/vm/hugetlbpage.txt |   36 ++++++++-------
 include/linux/hugetlb.h          |    6 ++
 kernel/sysctl.c                  |   12 +++++
 mm/hugetlb.c                     |   91 ++++++++++++++++++++++++++++++++-------
 4 files changed, 114 insertions(+), 31 deletions(-)

Index: linux-2.6.31-mmotm-090914-0157/include/linux/hugetlb.h
===================================================================
--- linux-2.6.31-mmotm-090914-0157.orig/include/linux/hugetlb.h	2009-09-15 13:23:01.000000000 -0400
+++ linux-2.6.31-mmotm-090914-0157/include/linux/hugetlb.h	2009-09-15 13:48:11.000000000 -0400
@@ -23,6 +23,12 @@ void reset_vma_resv_huge_pages(struct vm
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+
+#ifdef CONFIG_NUMA
+int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
+				void __user *, size_t *, loff_t *);
+#endif
+
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			struct page **, struct vm_area_struct **,
Index: linux-2.6.31-mmotm-090914-0157/kernel/sysctl.c
===================================================================
--- linux-2.6.31-mmotm-090914-0157.orig/kernel/sysctl.c	2009-09-15 13:23:01.000000000 -0400
+++ linux-2.6.31-mmotm-090914-0157/kernel/sysctl.c	2009-09-15 13:43:36.000000000 -0400
@@ -1170,6 +1170,18 @@ static struct ctl_table vm_table[] = {
 		.extra1		= (void *)&hugetlb_zero,
 		.extra2		= (void *)&hugetlb_infinity,
 	 },
+#ifdef CONFIG_NUMA
+	 {
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nr_hugepages_mempolicy",
+		.data		= NULL,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0644,
+		.proc_handler	= &hugetlb_mempolicy_sysctl_handler,
+		.extra1		= (void *)&hugetlb_zero,
+		.extra2		= (void *)&hugetlb_infinity,
+	 },
+#endif
 	 {
 		.ctl_name	= VM_HUGETLB_GROUP,
 		.procname	= "hugetlb_shm_group",
Index: linux-2.6.31-mmotm-090914-0157/mm/hugetlb.c
===================================================================
--- linux-2.6.31-mmotm-090914-0157.orig/mm/hugetlb.c	2009-09-15 13:43:13.000000000 -0400
+++ linux-2.6.31-mmotm-090914-0157/mm/hugetlb.c	2009-09-15 13:50:28.000000000 -0400
@@ -1243,6 +1243,7 @@ static int adjust_pool_surplus(struct hs
 	return ret;
 }
 
+#define HUGETLB_NO_NODE_OBEY_MEMPOLICY (NUMA_NO_NODE - 1)
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
 static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 								int nid)
@@ -1253,9 +1254,14 @@ static unsigned long set_max_huge_pages(
 	if (h->order >= MAX_ORDER)
 		return h->max_huge_pages;
 
-	if (nid == NUMA_NO_NODE) {
+	switch (nid) {
+	case HUGETLB_NO_NODE_OBEY_MEMPOLICY:
 		nodes_allowed = alloc_nodemask_of_mempolicy();
-	} else {
+		break;
+	case NUMA_NO_NODE:
+		nodes_allowed = &node_online_map;
+		break;
+	default:
 		/*
 		 * incoming 'count' is for node 'nid' only, so
 		 * adjust count to global, but restrict alloc/free
@@ -1354,23 +1360,24 @@ static struct hstate *kobj_to_hstate(str
 
 	for (i = 0; i < HUGE_MAX_HSTATE; i++)
 		if (hstate_kobjs[i] == kobj) {
-			if (nidp)
-				*nidp = NUMA_NO_NODE;
+			/*
+			 * let *nidp default.
+			 */
 			return &hstates[i];
 		}
 
 	return kobj_to_node_hstate(kobj, nidp);
 }
 
-static ssize_t nr_hugepages_show(struct kobject *kobj,
+static ssize_t nr_hugepages_show_common(int nid_default, struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
 	struct hstate *h;
 	unsigned long nr_huge_pages;
-	int nid;
+	int nid = nid_default;
 
 	h = kobj_to_hstate(kobj, &nid);
-	if (nid == NUMA_NO_NODE)
+	if (nid < 0)
 		nr_huge_pages = h->nr_huge_pages;
 	else
 		nr_huge_pages = h->nr_huge_pages_node[nid];
@@ -1378,12 +1385,12 @@ static ssize_t nr_hugepages_show(struct
 	return sprintf(buf, "%lu\n", nr_huge_pages);
 }
 
-static ssize_t nr_hugepages_store(struct kobject *kobj,
+static ssize_t nr_hugepages_store_common(int nid_default, struct kobject *kobj,
 		struct kobj_attribute *attr, const char *buf, size_t len)
 {
 	unsigned long count;
 	struct hstate *h;
-	int nid;
+	int nid = nid_default;
 	int err;
 
 	err = strict_strtoul(buf, 10, &count);
@@ -1395,8 +1402,42 @@ static ssize_t nr_hugepages_store(struct
 
 	return len;
 }
+
+static ssize_t nr_hugepages_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	return nr_hugepages_show_common(NUMA_NO_NODE, kobj, attr, buf);
+}
+
+static ssize_t nr_hugepages_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t len)
+{
+	return nr_hugepages_store_common(NUMA_NO_NODE, kobj, attr, buf, len);
+}
 HSTATE_ATTR(nr_hugepages);
 
+#ifdef CONFIG_NUMA
+
+/*
+ * hstate attribute for optionally mempolicy-based constraint on persistent
+ * huge page alloc/free.
+ */
+static ssize_t nr_hugepages_mempolicy_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	return nr_hugepages_show_common(HUGETLB_NO_NODE_OBEY_MEMPOLICY,
+						kobj, attr, buf);
+}
+
+static ssize_t nr_hugepages_mempolicy_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t len)
+{
+	return nr_hugepages_store_common(HUGETLB_NO_NODE_OBEY_MEMPOLICY,
+					kobj, attr, buf, len);
+}
+HSTATE_ATTR(nr_hugepages_mempolicy);
+#endif
+
 static ssize_t nr_overcommit_hugepages_show(struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
@@ -1429,7 +1470,7 @@ static ssize_t free_hugepages_show(struc
 {
 	struct hstate *h;
 	unsigned long free_huge_pages;
-	int nid;
+	int nid = NUMA_NO_NODE;
 
 	h = kobj_to_hstate(kobj, &nid);
 	if (nid == NUMA_NO_NODE)
@@ -1454,7 +1495,7 @@ static ssize_t surplus_hugepages_show(st
 {
 	struct hstate *h;
 	unsigned long surplus_huge_pages;
-	int nid;
+	int nid = NUMA_NO_NODE;
 
 	h = kobj_to_hstate(kobj, &nid);
 	if (nid == NUMA_NO_NODE)
@@ -1472,6 +1513,9 @@ static struct attribute *hstate_attrs[]
 	&free_hugepages_attr.attr,
 	&resv_hugepages_attr.attr,
 	&surplus_hugepages_attr.attr,
+#ifdef CONFIG_NUMA
+	&nr_hugepages_mempolicy_attr.attr,
+#endif
 	NULL,
 };
 
@@ -1809,9 +1853,9 @@ static unsigned int cpuset_mems_nr(unsig
 }
 
 #ifdef CONFIG_SYSCTL
-int hugetlb_sysctl_handler(struct ctl_table *table, int write,
-			   void __user *buffer,
-			   size_t *length, loff_t *ppos)
+static int hugetlb_sysctl_handler_common(int no_node,
+			 struct ctl_table *table, int write,
+			 void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct hstate *h = &default_hstate;
 	unsigned long tmp;
@@ -1824,7 +1868,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
 	proc_doulongvec_minmax(table, write, buffer, length, ppos);
 
 	if (write)
-		h->max_huge_pages = set_max_huge_pages(h, tmp, NUMA_NO_NODE);
+		h->max_huge_pages = set_max_huge_pages(h, tmp, no_node);
 
 	return 0;
 }
@@ -1864,6 +1908,23 @@ int hugetlb_overcommit_handler(struct ct
 	return 0;
 }
 
+int hugetlb_sysctl_handler(struct ctl_table *table, int write,
+			   void __user *buffer, size_t *length, loff_t *ppos)
+{
+
+	return hugetlb_sysctl_handler_common(NUMA_NO_NODE,
+				table, write, buffer, length, ppos);
+}
+
+#ifdef CONFIG_NUMA
+int hugetlb_mempolicy_sysctl_handler(struct ctl_table *table, int write,
+			   void __user *buffer, size_t *length, loff_t *ppos)
+{
+	return hugetlb_sysctl_handler_common(HUGETLB_NO_NODE_OBEY_MEMPOLICY,
+				table, write, buffer, length, ppos);
+}
+#endif /* CONFIG_NUMA */
+
 #endif /* CONFIG_SYSCTL */
 
 void hugetlb_report_meminfo(struct seq_file *m)
Index: linux-2.6.31-mmotm-090914-0157/Documentation/vm/hugetlbpage.txt
===================================================================
--- linux-2.6.31-mmotm-090914-0157.orig/Documentation/vm/hugetlbpage.txt	2009-09-15 13:43:32.000000000 -0400
+++ linux-2.6.31-mmotm-090914-0157/Documentation/vm/hugetlbpage.txt	2009-09-15 13:43:36.000000000 -0400
@@ -155,6 +155,7 @@ will exist, of the form:
 Inside each of these directories, the same set of files will exist:
 
 	nr_hugepages
+	nr_hugepages_mempolicy
 	nr_overcommit_hugepages
 	free_hugepages
 	resv_hugepages
@@ -166,26 +167,30 @@ which function as described above for th
 Interaction of Task Memory Policy with Huge Page Allocation/Freeing:
 
 Whether huge pages are allocated and freed via the /proc interface or
-the /sysfs interface, the NUMA nodes from which huge pages are allocated
-or freed are controlled by the NUMA memory policy of the task that modifies
-the nr_hugepages parameter.  [nr_overcommit_hugepages is a global limit.]
+the /sysfs interface using the nr_hugepages_mempolicy attribute, the NUMA
+nodes from which huge pages are allocated or freed are controlled by the
+NUMA memory policy of the task that modifies the nr_hugepages_mempolicy
+sysctl or attribute.  When the nr_hugepages attribute is used, mempolicy
+is ignored
 
 The recommended method to allocate or free huge pages to/from the kernel
 huge page pool, using the nr_hugepages example above, is:
 
-    numactl --interleave <node-list> echo 20 >/proc/sys/vm/nr_hugepages
+    numactl --interleave <node-list> echo 20 \
+				>/proc/sys/vm/nr_hugepages_mempolicy
 
 or, more succinctly:
 
-    numactl -m <node-list> echo 20 >/proc/sys/vm/nr_hugepages
+    numactl -m <node-list> echo 20 >/proc/sys/vm/nr_hugepages_mempolicy
 
 This will allocate or free abs(20 - nr_hugepages) to or from the nodes
-specified in <node-list>, depending on whether nr_hugepages is initially
-less than or greater than 20, respectively.  No huge pages will be
+specified in <node-list>, depending on whether number of persistent huge pages
+is initially less than or greater than 20, respectively.  No huge pages will be
 allocated nor freed on any node not included in the specified <node-list>.
 
-Any memory policy mode--bind, preferred, local or interleave--may be
-used.  The effect on persistent huge page allocation is as follows:
+When adjusting the persistent hugepage count via nr_hugepages_mempolicy, any
+memory policy mode--bind, preferred, local or interleave--may be used.  The
+resulting effect on persistent huge page allocation is as follows:
 
 1) Regardless of mempolicy mode [see Documentation/vm/numa_memory_policy.txt],
    persistent huge pages will be distributed across the node or nodes
@@ -201,27 +206,26 @@ used.  The effect on persistent huge pag
    If more than one node is specified with the preferred policy, only the
    lowest numeric id will be used.  Local policy will select the node where
    the task is running at the time the nodes_allowed mask is constructed.
-
-3) For local policy to be deterministic, the task must be bound to a cpu or
+   For local policy to be deterministic, the task must be bound to a cpu or
    cpus in a single node.  Otherwise, the task could be migrated to some
    other node at any time after launch and the resulting node will be
    indeterminate.  Thus, local policy is not very useful for this purpose.
    Any of the other mempolicy modes may be used to specify a single node.
 
-4) The nodes allowed mask will be derived from any non-default task mempolicy,
+3) The nodes allowed mask will be derived from any non-default task mempolicy,
    whether this policy was set explicitly by the task itself or one of its
    ancestors, such as numactl.  This means that if the task is invoked from a
    shell with non-default policy, that policy will be used.  One can specify a
    node list of "all" with numactl --interleave or --membind [-m] to achieve
    interleaving over all nodes in the system or cpuset.
 
-5) Any task mempolicy specifed--e.g., using numactl--will be constrained by
+4) Any task mempolicy specifed--e.g., using numactl--will be constrained by
    the resource limits of any cpuset in which the task runs.  Thus, there will
    be no way for a task with non-default policy running in a cpuset with a
    subset of the system nodes to allocate huge pages outside the cpuset
    without first moving to a cpuset that contains all of the desired nodes.
 
-6) Boot-time huge page allocation attempts to distribute the requested number
+5) Boot-time huge page allocation attempts to distribute the requested number
    of huge pages over all on-lines nodes.
 
 Per Node Hugepages Attributes
@@ -248,8 +252,8 @@ pages on the parent node will be adjuste
 resources exist, regardless of the task's mempolicy or cpuset constraints.
 
 Note that the number of overcommit and reserve pages remain global quantities,
-as we don't know until fault time, when the faulting task's mempolicy is applied,
-from which node the huge page allocation will be attempted.
+as we don't know until fault time, when the faulting task's mempolicy is
+applied, from which node the huge page allocation will be attempted.
 
 
 Using Huge Pages:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
