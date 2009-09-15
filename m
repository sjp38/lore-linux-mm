Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BD9096B0083
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:41:21 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 15 Sep 2009 16:44:41 -0400
Message-Id: <20090915204441.4828.3312.sendpatchset@localhost.localdomain>
In-Reply-To: <20090915204327.4828.4349.sendpatchset@localhost.localdomain>
References: <20090915204327.4828.4349.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/11] hugetlb:  derive huge pages nodes allowed from task mempolicy
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 4/11] hugetlb:  derive huge pages nodes allowed from task mempolicy

Against:  2.6.31-mmotm-090914-0157

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
      

This patch derives a "nodes_allowed" node mask from the numa
mempolicy of the task modifying the number of persistent huge
pages to control the allocation, freeing and adjusting of surplus
huge pages.  This mask is derived as follows:

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

Notes:

1) This patch introduces a subtle change in behavior:  huge page
   allocation and freeing will be constrained by any mempolicy
   that the task adjusting the huge page pool inherits from its
   parent.  This policy could come from a distant ancestor.  The
   adminstrator adjusting the huge page pool without explicitly
   specifying a mempolicy via numactl might be surprised by this.
   Additionaly, any mempolicy specified by numactl will be
   constrained by the cpuset in which numactl is invoked.
   Using sysfs per node hugepages attributes to adjust the per
   node persistent huge pages count [subsequent patch] ignores
   mempolicy and cpuset constraints.

2) Hugepages allocated at boot time use the node_online_map.
   An additional patch could implement a temporary boot time
   huge pages nodes_allowed command line parameter.

3) Using mempolicy to control persistent huge page allocation
   and freeing requires no change to hugeadm when invoking
   it via numactl, as shown in the examples below.  However,
   hugeadm could be enhanced to take the allowed nodes as an
   argument and set its task mempolicy itself.  This would allow
   it to detect and warn about any non-default mempolicy that it
   inherited from its parent, thus alleviating the issue described
   in Note 1 above.

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

	hugeadm --pool-pages-min=2048Kb:32

yields:

	Node 0 HugePages_Total:     8
	Node 1 HugePages_Total:     8
	Node 2 HugePages_Total:     8
	Node 3 HugePages_Total:     8

Applying mempolicy--e.g., with numactl [using '-m' a.k.a.
'--membind' because it allows multiple nodes to be specified
and it's easy to type]--we can allocate huge pages on
individual nodes or sets of nodes.  So, starting from the 
condition above, with 8 huge pages per node:

	numactl -m 2 hugeadm --pool-pages-min=2048Kb:+8

yields:

	Node 0 HugePages_Total:     8
	Node 1 HugePages_Total:     8
	Node 2 HugePages_Total:    16
	Node 3 HugePages_Total:     8

The incremental 8 huge pages were restricted to node 2 by the
specified mempolicy.

Similarly, we can use mempolicy to free persistent huge pages
from specified nodes:

	numactl -m 0,1 hugeadm --pool-pages-min=2048Kb:-8

yields:

	Node 0 HugePages_Total:     4
	Node 1 HugePages_Total:     4
	Node 2 HugePages_Total:    16
	Node 3 HugePages_Total:     8

The 8 huge pages freed were balanced over nodes 0 and 1.

Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mempolicy.h |    3 ++
 mm/hugetlb.c              |   12 +++++++++-
 mm/mempolicy.c            |   53 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 67 insertions(+), 1 deletion(-)

Index: linux-2.6.31-mmotm-090914-0157/mm/mempolicy.c
===================================================================
--- linux-2.6.31-mmotm-090914-0157.orig/mm/mempolicy.c	2009-09-15 13:19:02.000000000 -0400
+++ linux-2.6.31-mmotm-090914-0157/mm/mempolicy.c	2009-09-15 13:42:18.000000000 -0400
@@ -1564,6 +1564,59 @@ struct zonelist *huge_zonelist(struct vm
 	}
 	return zl;
 }
+
+/*
+ * alloc_nodemask_of_mempolicy
+ *
+ * Returns a [pointer to a] nodelist based on the current task's mempolicy.
+ *
+ * If the task's mempolicy is "default" [NULL], return NULL for default
+ * behavior.  Otherwise, extract the policy nodemask for 'bind'
+ * or 'interleave' policy or construct a nodemask for 'preferred' or
+ * 'local' policy and return a pointer to a kmalloc()ed nodemask_t.
+ *
+ * We don't bother with reference counting the mempolicy [mpol_get/put]
+ * because the current task is examining it's own mempolicy and a task's
+ * mempolicy is only ever changed by the task itself.
+ *
+ * N.B., it is the caller's responsibility to free a returned nodemask.
+ */
+nodemask_t *alloc_nodemask_of_mempolicy(void)
+{
+	nodemask_t *nodes_allowed = NULL;
+	struct mempolicy *mempolicy;
+	int nid;
+
+	if (!current->mempolicy)
+		return NULL;
+
+	nodes_allowed = kmalloc(sizeof(*nodes_allowed), GFP_KERNEL);
+	if (!nodes_allowed)
+		goto out;		/* silently default */
+
+	mempolicy = current->mempolicy;
+	switch (mempolicy->mode) {
+	case MPOL_PREFERRED:
+		if (mempolicy->flags & MPOL_F_LOCAL)
+			nid = numa_node_id();
+		else
+			nid = mempolicy->v.preferred_node;
+		init_nodemask_of_node(nodes_allowed, nid);
+		break;
+
+	case MPOL_BIND:
+		/* Fall through */
+	case MPOL_INTERLEAVE:
+		*nodes_allowed =  mempolicy->v.nodes;
+		break;
+
+	default:
+		BUG();
+	}
+
+out:
+	return nodes_allowed;
+}
 #endif
 
 /* Allocate a page in interleaved policy.
Index: linux-2.6.31-mmotm-090914-0157/include/linux/mempolicy.h
===================================================================
--- linux-2.6.31-mmotm-090914-0157.orig/include/linux/mempolicy.h	2009-09-15 13:19:02.000000000 -0400
+++ linux-2.6.31-mmotm-090914-0157/include/linux/mempolicy.h	2009-09-15 13:42:18.000000000 -0400
@@ -201,6 +201,7 @@ extern void mpol_fix_fork_child_flag(str
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask);
+extern nodemask_t *alloc_nodemask_of_mempolicy(void);
 extern unsigned slab_node(struct mempolicy *policy);
 
 extern enum zone_type policy_zone;
@@ -328,6 +329,8 @@ static inline struct zonelist *huge_zone
 	return node_zonelist(0, gfp_flags);
 }
 
+static inline nodemask_t *alloc_nodemask_of_mempolicy(void) { return NULL; }
+
 static inline int do_migrate_pages(struct mm_struct *mm,
 			const nodemask_t *from_nodes,
 			const nodemask_t *to_nodes, int flags)
Index: linux-2.6.31-mmotm-090914-0157/mm/hugetlb.c
===================================================================
--- linux-2.6.31-mmotm-090914-0157.orig/mm/hugetlb.c	2009-09-15 13:42:17.000000000 -0400
+++ linux-2.6.31-mmotm-090914-0157/mm/hugetlb.c	2009-09-15 13:42:18.000000000 -0400
@@ -1246,11 +1246,19 @@ static int adjust_pool_surplus(struct hs
 static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
 {
 	unsigned long min_count, ret;
-	nodemask_t *nodes_allowed = &node_online_map;
+	nodemask_t *nodes_allowed;
 
 	if (h->order >= MAX_ORDER)
 		return h->max_huge_pages;
 
+	nodes_allowed = alloc_nodemask_of_mempolicy();
+	if (!nodes_allowed) {
+		printk(KERN_WARNING "%s unable to allocate nodes allowed mask "
+			"for huge page allocation.  Falling back to default.\n",
+			current->comm);
+		nodes_allowed = &node_online_map;
+	}
+
 	/*
 	 * Increase the pool size
 	 * First take pages out of surplus state.  Then make up the
@@ -1311,6 +1319,8 @@ static unsigned long set_max_huge_pages(
 out:
 	ret = persistent_huge_pages(h);
 	spin_unlock(&hugetlb_lock);
+	if (nodes_allowed != &node_online_map)
+		kfree(nodes_allowed);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
