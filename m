Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9B35A6B022C
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 16:09:53 -0400 (EDT)
Date: Thu, 29 Apr 2010 15:09:51 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH v3] - Randomize node rotor used in
	cpuset_mem_spread_node()
Message-ID: <20100429200950.GB8929@sgi.com>
References: <20100428131158.GA2648@sgi.com> <20100428150432.GA3137@sgi.com> <20100428154034.fb823484.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428154034.fb823484.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Some workloads that create a large number of small files tend to assign
too many pages to node 0 (multi-node systems). Part of the reason is that
the rotor (in cpuset_mem_spread_node()) used to assign nodes starts
at node 0 for newly created tasks.

This patch changes the rotor to be initialized to a random node number
of the cpuset.

NOTE: this patch is on TOP of the previous patch:
	[PATCH] - New round-robin rotor for SLAB allocations
	http://marc.info/?l=linux-mm&m=127231565321947&w=2

Signed-off-by: Jack Steiner <steiner@sgi.com>


---

V2 - initial patch was generated against the wrong tree. This patch is based
on linux-next.

V3 - Eliminate new function bitmap_find_nth_bit(). Rename bitmap_ord_to_pos()
and export it.



 arch/x86/mm/numa.c       |   17 +++++++++++++++++
 include/linux/bitmap.h   |    1 +
 include/linux/nodemask.h |    5 +++++
 kernel/fork.c            |    4 ++++
 lib/bitmap.c             |    2 +-
 5 files changed, 28 insertions(+), 1 deletion(-)

Index: linux/arch/x86/mm/numa.c
===================================================================
--- linux.orig/arch/x86/mm/numa.c	2010-04-28 09:59:10.158899192 -0500
+++ linux/arch/x86/mm/numa.c	2010-04-29 13:53:48.531783017 -0500
@@ -2,6 +2,7 @@
 #include <linux/topology.h>
 #include <linux/module.h>
 #include <linux/bootmem.h>
+#include <linux/random.h>
 
 #ifdef CONFIG_DEBUG_PER_CPU_MAPS
 # define DBG(x...) printk(KERN_DEBUG x)
@@ -65,3 +66,19 @@ const struct cpumask *cpumask_of_node(in
 }
 EXPORT_SYMBOL(cpumask_of_node);
 #endif
+
+/*
+ * Return the bit number of a random bit set in the nodemask.
+ *   (returns -1 if nodemask is empty)
+ */
+int __node_random(const nodemask_t *maskp)
+{
+	int w, bit = -1;
+
+	w = nodes_weight(*maskp);
+	if (w)
+		bit = bitmap_ord_to_pos(maskp->bits,
+			get_random_int() % w, MAX_NUMNODES);
+	return bit;
+}
+EXPORT_SYMBOL(__node_random);
Index: linux/include/linux/bitmap.h
===================================================================
--- linux.orig/include/linux/bitmap.h	2010-04-28 09:59:10.158899192 -0500
+++ linux/include/linux/bitmap.h	2010-04-29 13:54:04.639408240 -0500
@@ -141,6 +141,7 @@ extern int bitmap_find_free_region(unsig
 extern void bitmap_release_region(unsigned long *bitmap, int pos, int order);
 extern int bitmap_allocate_region(unsigned long *bitmap, int pos, int order);
 extern void bitmap_copy_le(void *dst, const unsigned long *src, int nbits);
+extern int bitmap_ord_to_pos(const unsigned long *bitmap, int n, int bits);
 
 #define BITMAP_LAST_WORD_MASK(nbits)					\
 (									\
Index: linux/include/linux/nodemask.h
===================================================================
--- linux.orig/include/linux/nodemask.h	2010-04-28 09:59:10.158899192 -0500
+++ linux/include/linux/nodemask.h	2010-04-28 10:01:42.878971800 -0500
@@ -66,6 +66,8 @@
  * int num_online_nodes()		Number of online Nodes
  * int num_possible_nodes()		Number of all possible Nodes
  *
+ * int node_random(mask)              Random node with set bit in mask
+ *
  * int node_online(node)		Is some node online?
  * int node_possible(node)		Is some node possible?
  *
@@ -267,6 +269,9 @@ static inline int __first_unset_node(con
 			find_first_zero_bit(maskp->bits, MAX_NUMNODES));
 }
 
+#define node_random(mask) __node_random(&(mask))
+extern int __node_random(const nodemask_t *maskp);
+
 #define NODE_MASK_LAST_WORD BITMAP_LAST_WORD_MASK(MAX_NUMNODES)
 
 #if MAX_NUMNODES <= BITS_PER_LONG
Index: linux/kernel/fork.c
===================================================================
--- linux.orig/kernel/fork.c	2010-04-28 09:59:10.158899192 -0500
+++ linux/kernel/fork.c	2010-04-28 10:03:11.580014823 -0500
@@ -1079,6 +1079,10 @@ static struct task_struct *copy_process(
  	}
 	mpol_fix_fork_child_flag(p);
 #endif
+#ifdef CONFIG_CPUSETS
+	p->cpuset_mem_spread_rotor = node_random(p->mems_allowed);
+	p->cpuset_slab_spread_rotor = node_random(p->mems_allowed);
+#endif
 #ifdef CONFIG_TRACE_IRQFLAGS
 	p->irq_events = 0;
 #ifdef __ARCH_WANT_INTERRUPTS_ON_CTXSW
Index: linux/lib/bitmap.c
===================================================================
--- linux.orig/lib/bitmap.c	2010-04-28 09:59:10.158899192 -0500
+++ linux/lib/bitmap.c	2010-04-29 13:53:28.270906295 -0500
@@ -672,7 +672,7 @@ static int bitmap_pos_to_ord(const unsig
  *
  * The bit positions 0 through @bits are valid positions in @buf.
  */
-static int bitmap_ord_to_pos(const unsigned long *buf, int ord, int bits)
+int bitmap_ord_to_pos(const unsigned long *buf, int ord, int bits)
 {
 	int pos = 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
