Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D158D6B005D
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 20:46:31 -0500 (EST)
Subject: [patch v3]numa: add a sysctl to control interleave allocation
 granularity from each node to improve I/O performance
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 12 Dec 2011 09:58:45 +0800
Message-ID: <1323655125.22361.376.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@linux.intel.com, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, lee.schermerhorn@hp.com, David Rientjes <rientjes@google.com>

If mem plicy is interleaves, we will allocated pages from nodes in a round
robin way. This surely can do interleave fairly, but not optimal.

Say the pages will be used for I/O later. Interleave allocation for two pages
are allocated from two nodes, so the pages are not physically continuous. Later
each page needs one segment for DMA scatter-gathering. But maxium hardware
segment number is limited. The non-continuous pages will use up maxium
hardware segment number soon and we can't merge I/O to bigger DMA. Allocating
pages from one node hasn't such issue. The memory allocator pcp list makes
we can get physically continuous pages in several alloc quite likely.

Below patch adds a sysctl to control the allocation granularity from each node.
The default behavior isn't changed.

Run a sequential read workload which accesses disk sdc - sdf. The test uses
a LSI SAS1068E card. iostat -x -m 5 shows:

without numactl --interleave=0,1:
Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await  svctm  %util
sdc              13.40     0.00  259.00    0.00    67.05     0.00   530.19     5.00   19.38   3.86 100.00
sdd              13.00     0.00  249.00    0.00    64.95     0.00   534.21     5.05   19.73   4.02 100.00
sde              13.60     0.00  258.60    0.00    67.40     0.00   533.78     4.96   18.98   3.87 100.00
sdf              13.00     0.00  261.60    0.00    67.50     0.00   528.44     5.24   19.77   3.82 100.00

with numactl --interleave=0,1:
sdc               6.80     0.00  419.60    0.00    64.90     0.00   316.77    14.17   34.04   2.38 100.00
sdd               6.00     0.00  423.40    0.00    65.58     0.00   317.23    17.33   41.14   2.36 100.00
sde               5.60     0.00  419.60    0.00    64.90     0.00   316.77    17.29   40.94   2.38 100.00
sdf               5.20     0.00  417.80    0.00    64.17     0.00   314.55    16.69   39.42   2.39 100.00

with numactl --interleave=0,1 and below patch, setting numa_interleave_granularity to 3
(setting it to 1 gives similar result in this hardware, I only recorded the data with 3):
sdc              13.00     0.00  261.20    0.00    68.20     0.00   534.74     5.05   19.19   3.83 100.00
sde              13.40     0.00  259.00    0.00    67.85     0.00   536.52     4.85   18.80   3.86 100.00
sdf              13.00     0.00  260.60    0.00    68.20     0.00   535.97     4.85   18.61   3.84 100.00
sdd              13.20     0.00  251.60    0.00    66.00     0.00   537.23     4.95   19.45   3.97 100.00

The avgrq-sz is increased a lot. performance boost a little too.

V3: the new sysctl uses allocation size to determine if switching node as suggested by David.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 Documentation/sysctl/vm.txt |   15 +++++++++++++++
 include/linux/mempolicy.h   |    2 +-
 include/linux/sched.h       |    1 +
 kernel/sysctl.c             |   10 ++++++++++
 mm/mempolicy.c              |   40 ++++++++++++++++++++++++++++++++--------
 mm/slab.c                   |    5 +++--
 mm/slub.c                   |    3 ++-
 7 files changed, 64 insertions(+), 12 deletions(-)

Index: linux/include/linux/sched.h
===================================================================
--- linux.orig/include/linux/sched.h	2011-12-12 09:21:15.000000000 +0800
+++ linux/include/linux/sched.h	2011-12-12 09:35:40.000000000 +0800
@@ -1506,6 +1506,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_NUMA
 	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
+	int il_allocated_pages;
 	short il_next;
 	short pref_node_fork;
 #endif
Index: linux/mm/mempolicy.c
===================================================================
--- linux.orig/mm/mempolicy.c	2011-12-12 09:21:15.000000000 +0800
+++ linux/mm/mempolicy.c	2011-12-12 09:35:40.000000000 +0800
@@ -97,6 +97,18 @@
 
 #include "internal.h"
 
+unsigned int il_granularity_pages_order __read_mostly;
+static inline int il_granularity_pages(void)
+{
+	/*
+	 * 0 means switching interleave node for every allocation (not just
+	 * every page), so we don't change old behavior
+	 */
+	if (il_granularity_pages_order == 0)
+		return 0;
+	return 1 << il_granularity_pages_order;
+}
+
 /* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
@@ -341,6 +353,7 @@ static void mpol_rebind_nodemask(struct
 			current->il_next = first_node(tmp);
 		if (current->il_next >= MAX_NUMNODES)
 			current->il_next = numa_node_id();
+		current->il_allocated_pages = 0;
 	}
 }
 
@@ -743,8 +756,10 @@ static long do_set_mempolicy(unsigned sh
 	current->mempolicy = new;
 	mpol_set_task_struct_flag();
 	if (new && new->mode == MPOL_INTERLEAVE &&
-	    nodes_weight(new->v.nodes))
+	    nodes_weight(new->v.nodes)) {
 		current->il_next = first_node(new->v.nodes);
+		current->il_allocated_pages = 0;
+	}
 	task_unlock(current);
 	if (mm)
 		up_write(&mm->mmap_sem);
@@ -1548,17 +1563,23 @@ static struct zonelist *policy_zonelist(
 }
 
 /* Do dynamic interleaving for a process */
-static unsigned interleave_nodes(struct mempolicy *policy)
+static unsigned interleave_nodes(struct mempolicy *policy, int order)
 {
 	unsigned nid, next;
 	struct task_struct *me = current;
 
 	nid = me->il_next;
+	me->il_allocated_pages += 1 << order;
+	if (me->il_allocated_pages < il_granularity_pages())
+		return nid;
+
 	next = next_node(nid, policy->v.nodes);
 	if (next >= MAX_NUMNODES)
 		next = first_node(policy->v.nodes);
-	if (next < MAX_NUMNODES)
+	if (next < MAX_NUMNODES) {
 		me->il_next = next;
+		me->il_allocated_pages = 0;
+	}
 	return nid;
 }
 
@@ -1570,7 +1591,7 @@ static unsigned interleave_nodes(struct
  * task can change it's policy.  The system default policy requires no
  * such protection.
  */
-unsigned slab_node(struct mempolicy *policy)
+unsigned slab_node(struct mempolicy *policy, int order)
 {
 	if (!policy || policy->flags & MPOL_F_LOCAL)
 		return numa_node_id();
@@ -1583,7 +1604,7 @@ unsigned slab_node(struct mempolicy *pol
 		return policy->v.preferred_node;
 
 	case MPOL_INTERLEAVE:
-		return interleave_nodes(policy);
+		return interleave_nodes(policy, order);
 
 	case MPOL_BIND: {
 		/*
@@ -1629,6 +1650,7 @@ static unsigned offset_il_node(struct me
 static inline unsigned interleave_nid(struct mempolicy *pol,
 		 struct vm_area_struct *vma, unsigned long addr, int shift)
 {
+	BUG_ON(shift < PAGE_SHIFT);
 	if (vma) {
 		unsigned long off;
 
@@ -1639,12 +1661,13 @@ static inline unsigned interleave_nid(st
 		 * pages, we need to shift off the always 0 bits to get
 		 * a useful offset.
 		 */
-		BUG_ON(shift < PAGE_SHIFT);
+		if ((shift - PAGE_SHIFT) < il_granularity_pages_order)
+			shift = PAGE_SHIFT + il_granularity_pages_order;
 		off = vma->vm_pgoff >> (shift - PAGE_SHIFT);
 		off += (addr - vma->vm_start) >> shift;
 		return offset_il_node(pol, vma, off);
 	} else
-		return interleave_nodes(pol);
+		return interleave_nodes(pol, shift - PAGE_SHIFT);
 }
 
 /*
@@ -1901,7 +1924,8 @@ struct page *alloc_pages_current(gfp_t g
 	 * nor system default_policy
 	 */
 	if (pol->mode == MPOL_INTERLEAVE)
-		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
+		page = alloc_page_interleave(gfp, order,
+			interleave_nodes(pol, order));
 	else
 		page = __alloc_pages_nodemask(gfp, order,
 				policy_zonelist(gfp, pol, numa_node_id()),
Index: linux/kernel/sysctl.c
===================================================================
--- linux.orig/kernel/sysctl.c	2011-12-12 09:21:15.000000000 +0800
+++ linux/kernel/sysctl.c	2011-12-12 09:35:40.000000000 +0800
@@ -109,6 +109,9 @@ extern int sysctl_nr_trim_pages;
 #ifdef CONFIG_BLOCK
 extern int blk_iopoll_enabled;
 #endif
+#ifdef CONFIG_NUMA
+extern unsigned int il_granularity_pages_order;
+#endif
 
 /* Constants used for minimum and  maximum */
 #ifdef CONFIG_LOCKUP_DETECTOR
@@ -1313,6 +1316,13 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= numa_zonelist_order_handler,
 	},
+	{
+		.procname	= "numa_interleave_granularity",
+		.data		= &il_granularity_pages_order,
+		.maxlen		= sizeof(il_granularity_pages_order),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #endif
 #if (defined(CONFIG_X86_32) && !defined(CONFIG_UML))|| \
    (defined(CONFIG_SUPERH) && defined(CONFIG_VSYSCALL))
Index: linux/Documentation/sysctl/vm.txt
===================================================================
--- linux.orig/Documentation/sysctl/vm.txt	2011-12-12 09:21:15.000000000 +0800
+++ linux/Documentation/sysctl/vm.txt	2011-12-12 09:35:40.000000000 +0800
@@ -56,6 +56,7 @@ Currently, these files are in /proc/sys/
 - swappiness
 - vfs_cache_pressure
 - zone_reclaim_mode
+- numa_interleave_granularity
 
 ==============================================================
 
@@ -698,4 +699,18 @@ Allowing regular swap effectively restri
 node unless explicitly overridden by memory policies or cpuset
 configurations.
 
+==============================================================
+
+numa_interleave_granularity:
+
+In numa interleave mempolicy, page allocation switches from one node to
+another after (1 << numa_interleave_granularity) pages allocated from the
+node. It allows to change memory allocation granularity from each node
+in interleave mode. Big granularity allows to allocate physical continuous
+memory from each node. This can benefit I/O device doing DMA. On the other
+hand, big granularity could potentially cause memory imbalance between nodes.
+
+The default value is 0, which is a little special. It means allocation
+switches interleave node for every allocation (not just every page).
+
 ============ End of Document =================================
Index: linux/include/linux/mempolicy.h
===================================================================
--- linux.orig/include/linux/mempolicy.h	2011-12-12 09:21:15.000000000 +0800
+++ linux/include/linux/mempolicy.h	2011-12-12 09:35:40.000000000 +0800
@@ -215,7 +215,7 @@ extern struct zonelist *huge_zonelist(st
 extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
 extern bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 				const nodemask_t *mask);
-extern unsigned slab_node(struct mempolicy *policy);
+extern unsigned slab_node(struct mempolicy *policy, int order);
 
 extern enum zone_type policy_zone;
 
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2011-12-12 09:21:15.000000000 +0800
+++ linux/mm/slub.c	2011-12-12 09:35:40.000000000 +0800
@@ -1603,7 +1603,8 @@ static struct page *get_any_partial(stru
 		return NULL;
 
 	get_mems_allowed();
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+	zonelist = node_zonelist(slab_node(current->mempolicy, oo_order(s->oo)),
+			flags);
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		struct kmem_cache_node *n;
 
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2011-12-12 09:21:15.000000000 +0800
+++ linux/mm/slab.c	2011-12-12 09:35:40.000000000 +0800
@@ -3271,7 +3271,7 @@ static void *alternate_node_alloc(struct
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
 		nid_alloc = cpuset_slab_spread_node();
 	else if (current->mempolicy)
-		nid_alloc = slab_node(current->mempolicy);
+		nid_alloc = slab_node(current->mempolicy, cachep->gfporder);
 	put_mems_allowed();
 	if (nid_alloc != nid_here)
 		return ____cache_alloc_node(cachep, flags, nid_alloc);
@@ -3300,7 +3300,8 @@ static void *fallback_alloc(struct kmem_
 		return NULL;
 
 	get_mems_allowed();
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+	zonelist = node_zonelist(slab_node(current->mempolicy,
+		cache->gfporder), flags);
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
 retry:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
