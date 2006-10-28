Date: Fri, 27 Oct 2006 19:46:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Avoid allocating interleave from almost full nodes
Message-ID: <Pine.LNX.4.64.0610271943540.10933@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Interleave allocation often go over large sets of nodes. Some of the nodes 
may have tasks on them that heavily use memory. Overallocating those nodes 
may reduce performance of those tasks. It is better if we try to avoid 
nodes that have most of its memory used.

This patch checks for the amount of free pages on a node. If it is lower
than a predefined limit (in /proc/sys/kernel/min_interleave_ratio) then
we avoid allocating from that node. We keep a bitmap of full nodes
that is cleared every 2 seconds when the drain the pagesets for
node 0.

Should we find that all nodes are marked as full then we disregard
the limit and allocate from the next node without any checks.

This is only effective for interleave pages that are placed without
regard to the address in a process (anonymous pages are typically
placed depending on an interleave node generated from the address). This
means it applies mainly to slab interleave and page cache interleave.

We operate on full_interleave_nodes without any locking which means
that the nodemask may take on an undefined value at times. That does
not matter though since we always can fall back to operating without
full_interleave_nodes. As a result of the racyness we may uselessly
skip a node or retest a node.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc3/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.19-rc3.orig/Documentation/sysctl/vm.txt	2006-10-26 16:26:57.841817361 -0500
+++ linux-2.6.19-rc3/Documentation/sysctl/vm.txt	2006-10-26 16:57:48.075164708 -0500
@@ -195,6 +195,28 @@ and may not be fast.
 
 =============================================================
 
+min_interleave_ratio:
+
+This is available only on NUMA kernels.
+
+A percentage of the free pages in each zone.  If less than this
+percentage of pages are in use then interleave will attempt to
+leave this zone alone and allocate from other zones. This results
+in a balancing effect on the system if interleave and node local allocations
+are mixed throughout the system. Interleave pages will not cause zone
+reclaim and leave some memory on node to allow node local allocation to
+occur. Interleave allocations will allocate all over the system until global
+reclaim kicks in.
+
+The mininum does not apply to pages that are placed using interleave
+based on an address such as implemented for anonymous pages. It is
+effective for slab allocations, huge page allocations and page cache
+allocations.
+
+The default ratio is 10 percent.
+
+=============================================================
+
 panic_on_oom
 
 This enables or disables panic on out-of-memory feature.  If this is set to 1,
Index: linux-2.6.19-rc3/include/linux/mmzone.h
===================================================================
--- linux-2.6.19-rc3.orig/include/linux/mmzone.h	2006-10-26 16:26:57.850611036 -0500
+++ linux-2.6.19-rc3/include/linux/mmzone.h	2006-10-26 16:27:03.427755246 -0500
@@ -174,6 +174,12 @@ struct zone {
 	 */
 	unsigned long		min_unmapped_pages;
 	unsigned long		min_slab_pages;
+	/*
+	 * If a zone has less pages free then interleave will
+	 * attempt to bypass the zone
+	 */
+	unsigned long 		min_interleave_pages;
+
 	struct per_cpu_pageset	*pageset[NR_CPUS];
 #else
 	struct per_cpu_pageset	pageset[NR_CPUS];
@@ -465,6 +471,8 @@ int sysctl_min_unmapped_ratio_sysctl_han
 			struct file *, void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
+int sysctl_min_interleave_ratio_sysctl_handler(struct ctl_table *, int,
+			struct file *, void __user *, size_t *, loff_t *);
 
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
Index: linux-2.6.19-rc3/include/linux/swap.h
===================================================================
--- linux-2.6.19-rc3.orig/include/linux/swap.h	2006-10-26 16:26:57.858427636 -0500
+++ linux-2.6.19-rc3/include/linux/swap.h	2006-10-26 16:27:03.448273821 -0500
@@ -196,6 +196,7 @@ extern long vm_total_pages;
 extern int zone_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
 extern int sysctl_min_slab_ratio;
+extern int sysctl_min_interleave_ratio;
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 #else
 #define zone_reclaim_mode 0
Index: linux-2.6.19-rc3/include/linux/sysctl.h
===================================================================
--- linux-2.6.19-rc3.orig/include/linux/sysctl.h	2006-10-26 16:26:57.866244236 -0500
+++ linux-2.6.19-rc3/include/linux/sysctl.h	2006-10-26 16:27:03.467815322 -0500
@@ -193,7 +193,8 @@ enum
 	VM_MIN_UNMAPPED=32,	/* Set min percent of unmapped pages */
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
-	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
+	VM_MIN_SLAB=35,		/* Percent pages ignored by zone reclaim */
+	VM_MIN_INTERLEAVE=36,	/* Limit for interleave */
 };
 
 
Index: linux-2.6.19-rc3/kernel/sysctl.c
===================================================================
--- linux-2.6.19-rc3.orig/kernel/sysctl.c	2006-10-26 16:26:57.886762811 -0500
+++ linux-2.6.19-rc3/kernel/sysctl.c	2006-10-26 16:27:03.501035872 -0500
@@ -1021,6 +1021,17 @@ static ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+	{
+		.ctl_name	= VM_MIN_INTERLEAVE,
+		.procname	= "min_interleave_ratio",
+		.data		= &sysctl_min_interleave_ratio,
+		.maxlen		= sizeof(sysctl_min_interleave_ratio),
+		.mode		= 0644,
+		.proc_handler	= &sysctl_min_interleave_ratio_sysctl_handler,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 #endif
 #ifdef CONFIG_X86_32
 	{
Index: linux-2.6.19-rc3/mm/mempolicy.c
===================================================================
--- linux-2.6.19-rc3.orig/mm/mempolicy.c	2006-10-26 16:26:57.903373087 -0500
+++ linux-2.6.19-rc3/mm/mempolicy.c	2006-10-26 17:06:13.975215615 -0500
@@ -1116,16 +1116,60 @@ static struct zonelist *zonelist_policy(
 	return NODE_DATA(nd)->node_zonelists + gfp_zone(gfp);
 }
 
+/*
+ * Generic interleave function to be used by cpusets and memory policies.
+ */
+nodemask_t full_interleave_nodes = NODE_MASK_NONE;
+
+/*
+ * Called when draining the pagesets of node 0
+ */
+void clear_full_interleave_nodes(void) {
+	nodes_clear(full_interleave_nodes);
+}
+
+int __interleave(int current_node, nodemask_t *nodes)
+{
+	unsigned next;
+	struct zone *z;
+	nodemask_t nmask;
+
+redo:
+	nodes_andnot(nmask, *nodes, full_interleave_nodes);
+	if (unlikely(nodes_empty(nmask))) {
+		/*
+		 * All allowed nodes are overallocated.
+		 * Ignore interleave limit.
+		 */
+		next = next_node(current_node, *nodes);
+		if (next >= MAX_NUMNODES)
+			next = first_node(*nodes);
+		return next;
+	}
+
+	next = next_node(current_node, nmask);
+	if (next >= MAX_NUMNODES)
+		next = first_node(nmask);
+
+	/*
+	 * Check if node is overallocated. If so the set it to full.
+	 */
+	z = &NODE_DATA(next)->node_zones[policy_zone];
+	if (unlikely(z->free_pages <= z->min_interleave_pages)) {
+		node_set(next, full_interleave_nodes);
+		goto redo;
+	}
+	return next;
+}
+
 /* Do dynamic interleaving for a process */
-static unsigned interleave_nodes(struct mempolicy *policy)
+static int interleave_nodes(struct mempolicy *policy)
 {
 	unsigned nid, next;
 	struct task_struct *me = current;
 
 	nid = me->il_next;
-	next = next_node(nid, policy->v.nodes);
-	if (next >= MAX_NUMNODES)
-		next = first_node(policy->v.nodes);
+	next = __interleave(nid, &policy->v.nodes);
 	me->il_next = next;
 	return nid;
 }
Index: linux-2.6.19-rc3/mm/page_alloc.c
===================================================================
--- linux-2.6.19-rc3.orig/mm/page_alloc.c	2006-10-26 16:26:57.914120912 -0500
+++ linux-2.6.19-rc3/mm/page_alloc.c	2006-10-26 16:50:21.114929605 -0500
@@ -697,6 +697,8 @@ void drain_node_pages(int nodeid)
 			}
 		}
 	}
+	if (!nodeid)
+		clear_full_interleave_nodes();
 }
 #endif
 
@@ -1804,6 +1806,9 @@ static void setup_pagelist_highmark(stru
 
 
 #ifdef CONFIG_NUMA
+
+int sysctl_min_interleave_ratio = 10;
+
 /*
  * Boot pageset table. One per cpu which is going to be used for all
  * zones and all nodes. The parameters will be set in such a way
@@ -2399,6 +2404,7 @@ static void __meminit free_area_init_cor
 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
 						/ 100;
 		zone->min_slab_pages = (realsize * sysctl_min_slab_ratio) / 100;
+		zone->min_interleave_pages = (realsize + sysctl_min_interleave_ratio) / 100;
 #endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
@@ -2975,6 +2981,21 @@ int sysctl_min_slab_ratio_sysctl_handler
 				sysctl_min_slab_ratio) / 100;
 	return 0;
 }
+int sysctl_min_interleave_ratio_sysctl_handler(ctl_table *table, int write,
+	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+{
+	struct zone *zone;
+	int rc;
+
+	rc = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+	if (rc)
+		return rc;
+
+	for_each_zone(zone)
+		zone->min_interleave_pages = (zone->present_pages *
+				sysctl_min_interleave_ratio) / 100;
+	return 0;
+}
 #endif
 
 /*
Index: linux-2.6.19-rc3/include/linux/mempolicy.h
===================================================================
--- linux-2.6.19-rc3.orig/include/linux/mempolicy.h	2006-10-26 16:26:57.878946211 -0500
+++ linux-2.6.19-rc3/include/linux/mempolicy.h	2006-10-26 16:49:44.040339764 -0500
@@ -156,6 +156,8 @@ extern void mpol_fix_fork_child_flag(str
 #else
 #define current_cpuset_is_being_rebound() 0
 #endif
+extern int __interleave(int node, nodemask_t *nodes);
+extern void clear_full_interleave_nodes(void);
 
 extern struct mempolicy default_policy;
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
Index: linux-2.6.19-rc3/kernel/cpuset.c
===================================================================
--- linux-2.6.19-rc3.orig/kernel/cpuset.c	2006-10-26 16:26:57.895556487 -0500
+++ linux-2.6.19-rc3/kernel/cpuset.c	2006-10-26 16:27:03.614376574 -0500
@@ -2476,9 +2476,8 @@ int cpuset_mem_spread_node(void)
 {
 	int node;
 
-	node = next_node(current->cpuset_mem_spread_rotor, current->mems_allowed);
-	if (node == MAX_NUMNODES)
-		node = first_node(current->mems_allowed);
+	node = __interleave(current->cpuset_mem_spread_rotor,
+			&current->mems_allowed);
 	current->cpuset_mem_spread_rotor = node;
 	return node;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
