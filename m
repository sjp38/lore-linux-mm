Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 89FC56B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 02:02:20 -0500 (EST)
Subject: [RFC]numa: improve I/O performance by optimizing numa interleave
 allocation
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Nov 2011 15:12:12 +0800
Message-ID: <1321600332.22361.309.camel@sli10-conroe>
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

So can we make both interleave fairness and continuous allocation happy?
Simplily we can adjust the round robin algorithm. We switch to another node
after several (N) allocation happens. If N isn't too big, we can still get
fair allocation. And we get N continuous pages. I use N=8 in below patch.
I thought 8 isn't too big for modern NUMA machine. Applications which use
interleave are unlikely run short time, so I thought fairness still works.

Run a sequential read workload which accesses disk sdc - sdf,
iostat -x -m 5 shows:

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

with numactl --interleave=0,1 and below patch:
sdc              13.00     0.00  261.20    0.00    68.20     0.00   534.74     5.05   19.19   3.83 100.00
sde              13.40     0.00  259.00    0.00    67.85     0.00   536.52     4.85   18.80   3.86 100.00
sdf              13.00     0.00  260.60    0.00    68.20     0.00   535.97     4.85   18.61   3.84 100.00
sdd              13.20     0.00  251.60    0.00    66.00     0.00   537.23     4.95   19.45   3.97 100.00

The avgrq-sz is increased a lot. performance boost a little too.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 include/linux/sched.h |    2 +-
 mm/mempolicy.c        |   33 +++++++++++++++++++++++----------
 2 files changed, 24 insertions(+), 11 deletions(-)

Index: linux/include/linux/sched.h
===================================================================
--- linux.orig/include/linux/sched.h	2011-11-18 13:38:50.000000000 +0800
+++ linux/include/linux/sched.h	2011-11-18 13:42:41.000000000 +0800
@@ -1506,7 +1506,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_NUMA
 	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
-	short il_next;
+	int il_alloc_cnt;
 	short pref_node_fork;
 #endif
 	struct rcu_head rcu;
Index: linux/mm/mempolicy.c
===================================================================
--- linux.orig/mm/mempolicy.c	2011-11-18 13:38:50.000000000 +0800
+++ linux/mm/mempolicy.c	2011-11-18 13:44:57.000000000 +0800
@@ -97,6 +97,10 @@
 
 #include "internal.h"
 
+#define IL_ALLOC_STRIP (8)
+#define IL_CNT_TO_NODE(il_alloc_cnt) ((il_alloc_cnt) / IL_ALLOC_STRIP)
+#define IL_NODE_TO_CNT(node) ((node) * IL_ALLOC_STRIP)
+
 /* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
@@ -335,12 +339,15 @@ static void mpol_rebind_nodemask(struct
 	else
 		BUG();
 
-	if (!node_isset(current->il_next, tmp)) {
-		current->il_next = next_node(current->il_next, tmp);
-		if (current->il_next >= MAX_NUMNODES)
-			current->il_next = first_node(tmp);
-		if (current->il_next >= MAX_NUMNODES)
-			current->il_next = numa_node_id();
+	if (!node_isset(IL_CNT_TO_NODE(current->il_alloc_cnt), tmp)) {
+		int newnode;
+
+		newnode = next_node(IL_CNT_TO_NODE(current->il_alloc_cnt), tmp);
+		if (newnode >= MAX_NUMNODES)
+			newnode = first_node(tmp);
+		if (newnode >= MAX_NUMNODES)
+			newnode = numa_node_id();
+		current->il_alloc_cnt = IL_NODE_TO_CNT(newnode);
 	}
 }
 
@@ -744,7 +751,8 @@ static long do_set_mempolicy(unsigned sh
 	mpol_set_task_struct_flag();
 	if (new && new->mode == MPOL_INTERLEAVE &&
 	    nodes_weight(new->v.nodes))
-		current->il_next = first_node(new->v.nodes);
+		current->il_alloc_cnt =
+			IL_NODE_TO_CNT(first_node(new->v.nodes));
 	task_unlock(current);
 	if (mm)
 		up_write(&mm->mmap_sem);
@@ -849,7 +857,7 @@ static long do_get_mempolicy(int *policy
 			*policy = err;
 		} else if (pol == current->mempolicy &&
 				pol->mode == MPOL_INTERLEAVE) {
-			*policy = current->il_next;
+			*policy = IL_CNT_TO_NODE(current->il_alloc_cnt);
 		} else {
 			err = -EINVAL;
 			goto out;
@@ -1553,12 +1561,17 @@ static unsigned interleave_nodes(struct
 	unsigned nid, next;
 	struct task_struct *me = current;
 
-	nid = me->il_next;
+	if (((me->il_alloc_cnt + 1) % IL_ALLOC_STRIP) != 0) {
+		me->il_alloc_cnt++;
+		return IL_CNT_TO_NODE(me->il_alloc_cnt);
+	}
+
+	nid = IL_CNT_TO_NODE(me->il_alloc_cnt);
 	next = next_node(nid, policy->v.nodes);
 	if (next >= MAX_NUMNODES)
 		next = first_node(policy->v.nodes);
 	if (next < MAX_NUMNODES)
-		me->il_next = next;
+		me->il_alloc_cnt = IL_NODE_TO_CNT(next);
 	return nid;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
