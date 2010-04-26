Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A2CCC6B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 17:00:17 -0400 (EDT)
Date: Mon, 26 Apr 2010 16:00:41 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] - New round-robin rotor for SLAB allocations
Message-ID: <20100426210041.GA6580@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

We have observed several workloads running on multi-node systems where
memory is assigned unevenly across the nodes in the system. There are
numerous reasons for this but one is the round-robin rotor in
cpuset_mem_spread_node().

For example, a simple test that writes a multi-page file will allocate pages
on nodes 0 2 4 6 ... Odd nodes are skipped.  (Sometimes it allocates on
odd nodes & skips even nodes).

An example is shown below. The program "lfile" writes a file consisting of
10 pages. The program then mmaps the file & uses get_mempolicy(...,
MPOL_F_NODE) to determine the nodes where the file pages were allocated.
The output is shown below:

	# ./lfile
	 allocated on nodes: 2 4 6 0 1 2 6 0 2



There is a single rotor that is used for allocating both file pages & slab
pages.  Writing the file allocates both a data page & a slab page
(buffer_head).  This advances the RR rotor 2 nodes for each page
allocated.

A quick confirmation seems to confirm this is the cause of the uneven
allocation:

	# echo 0 >/dev/cpuset/memory_spread_slab
	# ./lfile
	 allocated on nodes: 6 7 8 9 0 1 2 3 4 5


This patch introduces a second rotor that is used for slab allocations.


Signed-off-by: Jack Steiner <steiner@sgi.com>


---
 include/linux/cpuset.h |    6 ++++++
 include/linux/sched.h  |    1 +
 kernel/cpuset.c        |   20 ++++++++++++++++----
 mm/slab.c              |    2 +-
 4 files changed, 24 insertions(+), 5 deletions(-)

Index: linux/include/linux/cpuset.h
===================================================================
--- linux.orig/include/linux/cpuset.h	2010-04-26 14:03:40.000000000 -0500
+++ linux/include/linux/cpuset.h	2010-04-26 15:05:02.574948748 -0500
@@ -69,6 +69,7 @@ extern void cpuset_task_status_allowed(s
 					struct task_struct *task);
 
 extern int cpuset_mem_spread_node(void);
+extern int cpuset_slab_spread_node(void);
 
 static inline int cpuset_do_page_mem_spread(void)
 {
@@ -158,6 +159,11 @@ static inline int cpuset_mem_spread_node
 {
 	return 0;
 }
+
+static inline int cpuset_slab_spread_node(void)
+{
+	return 0;
+}
 
 static inline int cpuset_do_page_mem_spread(void)
 {
Index: linux/include/linux/sched.h
===================================================================
--- linux.orig/include/linux/sched.h	2010-04-26 14:03:40.000000000 -0500
+++ linux/include/linux/sched.h	2010-04-26 15:04:38.208227585 -0500
@@ -1421,6 +1421,7 @@ struct task_struct {
 #ifdef CONFIG_CPUSETS
 	nodemask_t mems_allowed;	/* Protected by alloc_lock */
 	int cpuset_mem_spread_rotor;
+	int cpuset_slab_spread_rotor;
 #endif
 #ifdef CONFIG_CGROUPS
 	/* Control Group info protected by css_set_lock */
Index: linux/kernel/cpuset.c
===================================================================
--- linux.orig/kernel/cpuset.c	2010-04-26 14:03:40.000000000 -0500
+++ linux/kernel/cpuset.c	2010-04-26 15:04:38.246928404 -0500
@@ -2427,7 +2427,8 @@ void cpuset_unlock(void)
 }
 
 /**
- * cpuset_mem_spread_node() - On which node to begin search for a page
+ * cpuset_mem_spread_node() - On which node to begin search for a file page
+ * cpuset_slab_spread_node() - On which node to begin search for a slab page
  *
  * If a task is marked PF_SPREAD_PAGE or PF_SPREAD_SLAB (as for
  * tasks in a cpuset with is_spread_page or is_spread_slab set),
@@ -2452,16 +2453,27 @@ void cpuset_unlock(void)
  * See kmem_cache_alloc_node().
  */
 
-int cpuset_mem_spread_node(void)
+static int cpuset_spread_node(int *rotor)
 {
 	int node;
 
-	node = next_node(current->cpuset_mem_spread_rotor, current->mems_allowed);
+	node = next_node(*rotor, current->mems_allowed);
 	if (node == MAX_NUMNODES)
 		node = first_node(current->mems_allowed);
-	current->cpuset_mem_spread_rotor = node;
+	*rotor = node;
 	return node;
 }
+
+int cpuset_mem_spread_node(void)
+{
+	return cpuset_spread_node(&current->cpuset_mem_spread_rotor);
+}
+
+int cpuset_slab_spread_node(void)
+{
+	return cpuset_spread_node(&current->cpuset_slab_spread_rotor);
+}
+
 EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);
 
 /**
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2010-04-26 14:03:40.000000000 -0500
+++ linux/mm/slab.c	2010-04-26 15:05:34.343755521 -0500
@@ -3242,7 +3242,7 @@ static void *alternate_node_alloc(struct
 		return NULL;
 	nid_alloc = nid_here = numa_node_id();
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
-		nid_alloc = cpuset_mem_spread_node();
+		nid_alloc = cpuset_slab_spread_node();
 	else if (current->mempolicy)
 		nid_alloc = slab_node(current->mempolicy);
 	if (nid_alloc != nid_here)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
