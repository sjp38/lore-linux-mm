Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id DA5916B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 22:19:12 -0500 (EST)
Subject: [patch v2]numa: add a sysctl to control interleave allocation
 granularity from each node
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 05 Dec 2011 11:30:46 +0800
Message-ID: <1323055846.22361.362.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@linux.intel.com, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, lee.schermerhorn@hp.com

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

with numactl --interleave=0,1 and below patch, setting numa_interleave_granularity to 8
(setting it to 2 gives similar result, I only recorded the data with 8):
sdc              13.00     0.00  261.20    0.00    68.20     0.00   534.74     5.05   19.19   3.83 100.00
sde              13.40     0.00  259.00    0.00    67.85     0.00   536.52     4.85   18.80   3.86 100.00
sdf              13.00     0.00  260.60    0.00    68.20     0.00   535.97     4.85   18.61   3.84 100.00
sdd              13.20     0.00  251.60    0.00    66.00     0.00   537.23     4.95   19.45   3.97 100.00

The avgrq-sz is increased a lot. performance boost a little too.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 Documentation/sysctl/vm.txt |   13 +++++++++++++
 include/linux/sched.h       |    1 +
 kernel/sysctl.c             |   11 +++++++++++
 mm/mempolicy.c              |   15 +++++++++++++--
 4 files changed, 38 insertions(+), 2 deletions(-)

Index: linux/include/linux/sched.h
===================================================================
--- linux.orig/include/linux/sched.h	2011-12-05 11:12:10.000000000 +0800
+++ linux/include/linux/sched.h	2011-12-05 11:14:34.000000000 +0800
@@ -1506,6 +1506,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_NUMA
 	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
+	int il_alloc_cnt;
 	short il_next;
 	short pref_node_fork;
 #endif
Index: linux/mm/mempolicy.c
===================================================================
--- linux.orig/mm/mempolicy.c	2011-12-05 11:12:10.000000000 +0800
+++ linux/mm/mempolicy.c	2011-12-05 11:13:19.000000000 +0800
@@ -97,6 +97,8 @@
 
 #include "internal.h"
 
+int il_granularity __read_mostly = 1;
+
 /* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
@@ -341,6 +343,7 @@ static void mpol_rebind_nodemask(struct
 			current->il_next = first_node(tmp);
 		if (current->il_next >= MAX_NUMNODES)
 			current->il_next = numa_node_id();
+		current->il_alloc_cnt = 0;
 	}
 }
 
@@ -743,8 +746,10 @@ static long do_set_mempolicy(unsigned sh
 	current->mempolicy = new;
 	mpol_set_task_struct_flag();
 	if (new && new->mode == MPOL_INTERLEAVE &&
-	    nodes_weight(new->v.nodes))
+	    nodes_weight(new->v.nodes)) {
 		current->il_next = first_node(new->v.nodes);
+		current->il_alloc_cnt = 0;
+	}
 	task_unlock(current);
 	if (mm)
 		up_write(&mm->mmap_sem);
@@ -1554,11 +1559,17 @@ static unsigned interleave_nodes(struct
 	struct task_struct *me = current;
 
 	nid = me->il_next;
+	me->il_alloc_cnt++;
+	if (me->il_alloc_cnt < il_granularity)
+		return nid;
+
 	next = next_node(nid, policy->v.nodes);
 	if (next >= MAX_NUMNODES)
 		next = first_node(policy->v.nodes);
-	if (next < MAX_NUMNODES)
+	if (next < MAX_NUMNODES) {
 		me->il_next = next;
+		me->il_alloc_cnt = 0;
+	}
 	return nid;
 }
 
Index: linux/kernel/sysctl.c
===================================================================
--- linux.orig/kernel/sysctl.c	2011-12-05 11:12:10.000000000 +0800
+++ linux/kernel/sysctl.c	2011-12-05 11:13:19.000000000 +0800
@@ -109,6 +109,9 @@ extern int sysctl_nr_trim_pages;
 #ifdef CONFIG_BLOCK
 extern int blk_iopoll_enabled;
 #endif
+#ifdef CONFIG_NUMA
+extern int il_granularity;
+#endif
 
 /* Constants used for minimum and  maximum */
 #ifdef CONFIG_LOCKUP_DETECTOR
@@ -1313,6 +1316,14 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= numa_zonelist_order_handler,
 	},
+	{
+		.procname	= "numa_interleave_granularity",
+		.data		= &il_granularity,
+		.maxlen		= sizeof(il_granularity),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
+	},
 #endif
 #if (defined(CONFIG_X86_32) && !defined(CONFIG_UML))|| \
    (defined(CONFIG_SUPERH) && defined(CONFIG_VSYSCALL))
Index: linux/Documentation/sysctl/vm.txt
===================================================================
--- linux.orig/Documentation/sysctl/vm.txt	2011-12-05 11:12:10.000000000 +0800
+++ linux/Documentation/sysctl/vm.txt	2011-12-05 11:14:54.000000000 +0800
@@ -56,6 +56,7 @@ Currently, these files are in /proc/sys/
 - swappiness
 - vfs_cache_pressure
 - zone_reclaim_mode
+- numa_interleave_granularity
 
 ==============================================================
 
@@ -698,4 +699,16 @@ Allowing regular swap effectively restri
 node unless explicitly overridden by memory policies or cpuset
 configurations.
 
+==============================================================
+
+numa_interleave_granularity:
+
+numa_interleave_granularity allows to change memory allocation granularity
+from each node in interleave mode. Big granularity allows to allocate physical
+continuous memory from each node. This can benefit I/O device doing DMA. On the
+other hand, big granularity could potentially cause memory imbalance between
+nodes.
+
+The default value is 1.
+
 ============ End of Document =================================


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
