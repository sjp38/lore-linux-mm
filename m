Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3F044600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 12:12:23 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 01 Oct 2009 12:58:32 -0400
Message-Id: <20091001165832.32248.32725.sendpatchset@localhost.localdomain>
In-Reply-To: <20091001165721.32248.14861.sendpatchset@localhost.localdomain>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/10] hugetlb:  derive huge pages nodes allowed from task mempolicy
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, clameter@sgi.com, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 4/10] hugetlb:  derive huge pages nodes allowed from task mempolicy

Against:  2.6.31-mmotm-090925-1435

V2: + cleaned up comments, removed some deemed unnecessary,
      add some suggested by review
    + removed check for !current in huge_mpol_nodes_allowed().
    + added 'current->comm' to warning message in huge_mpol_nodes_allowed().
    + added VM_BUG_ON() assertion in hugetlb.c next_node_allowed() to
      catch out of range node id.
    + add examples to patch description

V3: Factored this patch from V2 patch 2/3

V4: added back missing "kfree(nodes_allowed)" in set_max_nr_hugepages()

V5: remove internal '\n' from printk in huge_mpol_nodes_allowed()

V6: + rename 'huge_mpol_nodes_allowed()" to "alloc_nodemask_of_mempolicy()"
    + move the printk() when we can't kmalloc() a nodemask_t to
      set_max_huge_pages(), as alloc_nodemask_of_mempolicy() is no longer
      hugepage specific.
    + handle movement of nodes_allowed initialization:
    ++ Don't kfree() nodes_allowed when it points at node_online_map.

V7: + drop mpol-get/put from alloc_nodemask_of_mempolicy().  Not needed
      here because current task is examining it's own mempolicy.  Add
      comment to that effect.
    + use init_nodemask_of_node() to initialize the nodes_allowed for
      single node policies [preferred/local].

V8:  + fold in subsequent patches to:
       1) define a new sysctl and hugepages sysfs attribute
          nr_hugepages_mempolicy which will modify the huge page pool
          under the current task's mempolicy.  Modifications via the
          existing nr_hugepages will continue to ignore mempolicy.
          NOTE:  This part comes from a patch from Mel Gorman.
       2) reorganize sysctl and sysfs attribute handlers to create
          and pass nodes_allowed mask to set_max_huge_pages().

This patch derives a "nodes_allowed" node mask from the numa
mempolicy of the task modifying the number of persistent huge
pages to control the allocation, freeing and adjusting of surplus
huge pages when the pool page count is modified via the new sysctl
or sysfs attribute "nr_hugepages_mempolicy".  The nodes_allowed
mask is derived as follows:

* For "default" [NULL] task mempolicy, a NULL nodemask_t pointer
  is produced.  This will cause the hugetlb subsystem to use
  node_online_map as the "nodes_allowed".  This preserves the
  behavior before this patch.
* For "preferred" mempolicy, including explicit local allocation,
  a nodemask with the single preferred node will be produced.
  "local" policy will NOT track any internode migrations of the
  task adjusting nr_hugepages.
* For "bind" and "interleave" policy, the mempolicy's nodemask
  will be used.
* Other than to inform the construction of the nodes_allowed node
  mask, the actual mempolicy mode is ignored.  That is, all modes
  behave like interleave over the resulting nodes_allowed mask
  with no "fallback".

See the updated documentation [next patch] for more information
about the implications of this patch.

Examples:

Starting with:

	Node 0 HugePages_Total:     0
	Node 1 HugePages_Total:     0
	Node 2 HugePages_Total:     0
	Node 3 HugePages_Total:     0

Default behavior [with or without this patch] balances persistent
hugepage allocation across nodes [with sufficient contiguous memory]:

	sysctl vm.nr_hugepages[_mempolicy]=32

yields:

	Node 0 HugePages_Total:     8
	Node 1 HugePages_Total:     8
	Node 2 HugePages_Total:     8
	Node 3 HugePages_Total:     8

Of course, we only have nr_hugepages_mempolicy with the patch,
but with default mempolicy, nr_hugepages_mempolicy behaves the
same as nr_hugepages.

Applying mempolicy--e.g., with numactl [using '-m' a.k.a.
'--membind' because it allows multiple nodes to be specified
and it's easy to type]--we can allocate huge pages on
individual nodes or sets of nodes.  So, starting from the
condition above, with 8 huge pages per node, add 8 more to
node 2 using:

	numactl -m 2 sysctl vm.nr_hugepages_mempolicy=40

This yields:

	Node 0 HugePages_Total:     8
	Node 1 HugePages_Total:     8
	Node 2 HugePages_Total:    16
	Node 3 HugePages_Total:     8

The incremental 8 huge pages were restricted to node 2 by the
specified mempolicy.

Similarly, we can use mempolicy to free persistent huge pages
from specified nodes:

	numactl -m 0,1 sysctl vm.nr_hugepages_mempolicy=32

yields:

	Node 0 HugePages_Total:     4
	Node 1 HugePages_Total:     4
	Node 2 HugePages_Total:    16
	Node 3 HugePages_Total:     8

The 8 huge pages freed were balanced over nodes 0 and 1.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>

 include/linux/hugetlb.h   |    6 ++
 include/linux/mempolicy.h |    3 +
 kernel/sysctl.c           |   16 ++++++-
 mm/hugetlb.c              |   97 +++++++++++++++++++++++++++++++++++++++-------
 mm/mempolicy.c            |   47 ++++++++++++++++++++++
 5 files changed, 154 insertions(+), 15 deletions(-)

Index: linux-2.6.31-mmotm-090925-1435/mm/mempolicy.c
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/mm/mempolicy.c	2009-09-30 12:48:45.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/mm/mempolicy.c	2009-09-30 12:48:46.000000000 -0400
@@ -1564,6 +1564,53 @@ struct zonelist *huge_zonelist(struct vm
 	}
 	return zl;
 }
+
+/*
+ * init_nodemask_of_mempolicy
+ *
+ * If the current task's mempolicy is "default" [NULL], return 'false'
+ * to indicate * default policy.  Otherwise, extract the policy nodemask
+ * for 'bind' * or 'interleave' policy into the argument nodemask, or
+ * initialize the argument nodemask to contain the single node for
+ * 'preferred' or * 'local' policy and return 'true' to indicate presence
+ * of non-default mempolicy.
+ *
+ * We don't bother with reference counting the mempolicy [mpol_get/put]
+ * because the current task is examining it's own mempolicy and a task's
+ * mempolicy is only ever changed by the task itself.
+ *
+ * N.B., it is the caller's responsibility to free a returned nodemask.
+ */
+bool init_nodemask_of_mempolicy(nodemask_t *mask)
+{
+	struct mempolicy *mempolicy;
+	int nid;
+
+	if (!current->mempolicy)
+		return false;
+
+	mempolicy = current->mempolicy;
+	switch (mempolicy->mode) {
+	case MPOL_PREFERRED:
+		if (mempolicy->flags & MPOL_F_LOCAL)
+			nid = numa_node_id();
+		else
+			nid = mempolicy->v.preferred_node;
+		init_nodemask_of_node(mask, nid);
+		break;
+
+	case MPOL_BIND:
+		/* Fall through */
+	case MPOL_INTERLEAVE:
+		*mask =  mempolicy->v.nodes;
+		break;
+
+	default:
+		BUG();
+	}
+
+	return true;
+}
 #endif
 
 /* Allocate a page in interleaved policy.
Index: linux-2.6.31-mmotm-090925-1435/include/linux/mempolicy.h
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/include/linux/mempolicy.h	2009-09-30 12:48:45.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/include/linux/mempolicy.h	2009-09-30 12:48:46.000000000 -0400
@@ -201,6 +201,7 @@ extern void mpol_fix_fork_child_flag(str
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask);
+extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
 extern unsigned slab_node(struct mempolicy *policy);
 
 extern enum zone_type policy_zone;
@@ -328,6 +329,8 @@ static inline struct zonelist *huge_zone
 	return node_zonelist(0, gfp_flags);
 }
 
+static inline bool init_nodemask_of_mempolicy(nodemask_t *m) { return false; }
+
 static inline int do_migrate_pages(struct mm_struct *mm,
 			const nodemask_t *from_nodes,
 			const nodemask_t *to_nodes, int flags)
Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-09-30 12:48:45.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-10-01 12:13:25.000000000 -0400
@@ -1334,29 +1334,71 @@ static struct hstate *kobj_to_hstate(str
 	return NULL;
 }
 
-static ssize_t nr_hugepages_show(struct kobject *kobj,
+static ssize_t nr_hugepages_show_common(struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
 	struct hstate *h = kobj_to_hstate(kobj);
 	return sprintf(buf, "%lu\n", h->nr_huge_pages);
 }
-static ssize_t nr_hugepages_store(struct kobject *kobj,
-		struct kobj_attribute *attr, const char *buf, size_t count)
+static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
+			struct kobject *kobj, struct kobj_attribute *attr,
+			const char *buf, size_t len)
 {
 	int err;
-	unsigned long input;
+	unsigned long count;
 	struct hstate *h = kobj_to_hstate(kobj);
+	NODEMASK_ALLOC(nodemask, nodes_allowed);
 
-	err = strict_strtoul(buf, 10, &input);
+	err = strict_strtoul(buf, 10, &count);
 	if (err)
 		return 0;
 
-	h->max_huge_pages = set_max_huge_pages(h, input, &node_online_map);
+	if (!(obey_mempolicy && init_nodemask_of_mempolicy(nodes_allowed))) {
+		NODEMASK_FREE(nodes_allowed);
+		nodes_allowed = &node_states[N_HIGH_MEMORY];
+	}
+	h->max_huge_pages = set_max_huge_pages(h, count, &node_online_map);
 
-	return count;
+	if (nodes_allowed != &node_states[N_HIGH_MEMORY])
+		NODEMASK_FREE(nodes_allowed);
+
+	return len;
+}
+
+static ssize_t nr_hugepages_show(struct kobject *kobj,
+				       struct kobj_attribute *attr, char *buf)
+{
+	return nr_hugepages_show_common(kobj, attr, buf);
+}
+
+static ssize_t nr_hugepages_store(struct kobject *kobj,
+	       struct kobj_attribute *attr, const char *buf, size_t len)
+{
+	return nr_hugepages_store_common(false, kobj, attr, buf, len);
 }
 HSTATE_ATTR(nr_hugepages);
 
+#ifdef CONFIG_NUMA
+
+/*
+ * hstate attribute for optionally mempolicy-based constraint on persistent
+ * huge page alloc/free.
+ */
+static ssize_t nr_hugepages_mempolicy_show(struct kobject *kobj,
+				       struct kobj_attribute *attr, char *buf)
+{
+	return nr_hugepages_show_common(kobj, attr, buf);
+}
+
+static ssize_t nr_hugepages_mempolicy_store(struct kobject *kobj,
+	       struct kobj_attribute *attr, const char *buf, size_t len)
+{
+	return nr_hugepages_store_common(true, kobj, attr, buf, len);
+}
+HSTATE_ATTR(nr_hugepages_mempolicy);
+#endif
+
+
 static ssize_t nr_overcommit_hugepages_show(struct kobject *kobj,
 					struct kobj_attribute *attr, char *buf)
 {
@@ -1412,6 +1454,9 @@ static struct attribute *hstate_attrs[]
 	&free_hugepages_attr.attr,
 	&resv_hugepages_attr.attr,
 	&surplus_hugepages_attr.attr,
+#ifdef CONFIG_NUMA
+	&nr_hugepages_mempolicy_attr.attr,
+#endif
 	NULL,
 };
 
@@ -1578,9 +1623,9 @@ static unsigned int cpuset_mems_nr(unsig
 }
 
 #ifdef CONFIG_SYSCTL
-int hugetlb_sysctl_handler(struct ctl_table *table, int write,
-			   void __user *buffer,
-			   size_t *length, loff_t *ppos)
+static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
+			 struct ctl_table *table, int write,
+			 void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct hstate *h = &default_hstate;
 	unsigned long tmp;
@@ -1592,13 +1637,39 @@ int hugetlb_sysctl_handler(struct ctl_ta
 	table->maxlen = sizeof(unsigned long);
 	proc_doulongvec_minmax(table, write, buffer, length, ppos);
 
-	if (write)
-		h->max_huge_pages = set_max_huge_pages(h, tmp,
-							&node_online_map);
+	if (write) {
+		NODEMASK_ALLOC(nodemask, nodes_allowed);
+		if (!(obey_mempolicy &&
+			       init_nodemask_of_mempolicy(nodes_allowed))) {
+			NODEMASK_FREE(nodes_allowed);
+			nodes_allowed = &node_states[N_HIGH_MEMORY];
+		}
+		h->max_huge_pages = set_max_huge_pages(h, tmp, nodes_allowed);
+
+		if (nodes_allowed != &node_states[N_HIGH_MEMORY])
+			NODEMASK_FREE(nodes_allowed);
+	}
 
 	return 0;
 }
 
+int hugetlb_sysctl_handler(struct ctl_table *table, int write,
+			  void __user *buffer, size_t *length, loff_t *ppos)
+{
+
+	return hugetlb_sysctl_handler_common(false, table, write,
+							buffer, length, ppos);
+}
+
+#ifdef CONFIG_NUMA
+int hugetlb_mempolicy_sysctl_handler(struct ctl_table *table, int write,
+			  void __user *buffer, size_t *length, loff_t *ppos)
+{
+	return hugetlb_sysctl_handler_common(true, table, write,
+							buffer, length, ppos);
+}
+#endif /* CONFIG_NUMA */
+
 int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
 			void __user *buffer,
 			size_t *length, loff_t *ppos)
Index: linux-2.6.31-mmotm-090925-1435/include/linux/hugetlb.h
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/include/linux/hugetlb.h	2009-09-30 12:48:45.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/include/linux/hugetlb.h	2009-09-30 12:48:46.000000000 -0400
@@ -23,6 +23,12 @@ void reset_vma_resv_huge_pages(struct vm
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+
+#ifdef CONFIG_NUMA
+int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
+#endif
+
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			struct page **, struct vm_area_struct **,
Index: linux-2.6.31-mmotm-090925-1435/kernel/sysctl.c
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/kernel/sysctl.c	2009-09-30 12:48:45.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/kernel/sysctl.c	2009-09-30 12:48:46.000000000 -0400
@@ -1164,7 +1164,7 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one_hundred,
 	},
 #ifdef CONFIG_HUGETLB_PAGE
-	 {
+	{
 		.procname	= "nr_hugepages",
 		.data		= NULL,
 		.maxlen		= sizeof(unsigned long),
@@ -1172,7 +1172,19 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= &hugetlb_sysctl_handler,
 		.extra1		= (void *)&hugetlb_zero,
 		.extra2		= (void *)&hugetlb_infinity,
-	 },
+	},
+#ifdef CONFIG_NUMA
+	{
+	       .ctl_name       = CTL_UNNUMBERED,
+	       .procname       = "nr_hugepages_mempolicy",
+	       .data           = NULL,
+	       .maxlen         = sizeof(unsigned long),
+	       .mode           = 0644,
+	       .proc_handler   = &hugetlb_mempolicy_sysctl_handler,
+	       .extra1	 = (void *)&hugetlb_zero,
+	       .extra2	 = (void *)&hugetlb_infinity,
+	},
+#endif
 	 {
 		.ctl_name	= VM_HUGETLB_GROUP,
 		.procname	= "hugetlb_shm_group",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
