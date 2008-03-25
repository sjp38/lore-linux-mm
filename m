Message-Id: <20080325023121.889696000@polaris-admin.engr.sgi.com>
References: <20080325023120.859257000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:31:26 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 06/12] cpumask: create pointer to node_to_cpumask array element
Content-Disposition: inline; filename=node_to_cpumask_ptr
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, "David S. Miller" <davem@davemloft.net>, "William L. Irwin" <wli@holomorphy.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Create a simple macro to always return a pointer to the 
node_to_cpumask(node) value.  This relies on compiler optimization
to remove the extra indirection:

#define	node_to_cpumask_ptr(v, node) 		\
		cpumask_t _##v = node_to_cpumask(node), *v = &_##v

For those systems with a large cpumask size, then a true pointer
to the array element is used:

#define node_to_cpumask_ptr(v, node)		\
		cpumask_t *v = &(node_to_cpumask_map[node])

A node_to_cpumask_ptr_next() macro is provided to access another
node_to_cpumask value.

This removes 9824 bytes of stack usage.

Based on linux-2.6.25-rc5-mm1

# alpha
Cc: Richard Henderson <rth@twiddle.net>

# fujitsu
Cc: David Howells <dhowells@redhat.com>

# ia64
Cc: Tony Luck <tony.luck@intel.com>

# powerpc
Cc: Paul Mackerras <paulus@samba.org>
Cc: Anton Blanchard <anton@samba.org>

# sparc
Cc: David S. Miller <davem@davemloft.net>
Cc: William L. Irwin <wli@holomorphy.com>

# x86
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: H. Peter Anvin <hpa@zytor.com>


Signed-off-by: Mike Travis <travis@sgi.com>
---
One checkpatch error that I don't think can be fixed (was already in source):

ERROR: Macros with complex values should be enclosed in parenthesis
#230: FILE: include/linux/topology.h:49:

#define for_each_node_with_cpus(node)			\
        for_each_online_node(node)                      \
		if (nr_cpus_node(node))

total: 1 errors, 0 warnings, 315 lines checked

---
 drivers/base/node.c            |    4 ++--
 drivers/pci/pci-driver.c       |    4 ++--
 include/asm-alpha/topology.h   |    3 +--
 include/asm-frv/topology.h     |    4 +---
 include/asm-generic/topology.h |   14 ++++++++++++++
 include/asm-ia64/topology.h    |    5 +++++
 include/asm-powerpc/topology.h |    3 +--
 include/asm-x86/topology.h     |   15 +++++++++++++--
 include/linux/topology.h       |   13 ++++++-------
 kernel/sched.c                 |   29 ++++++++++++++---------------
 mm/page_alloc.c                |    6 +++---
 mm/slab.c                      |    5 ++---
 mm/vmscan.c                    |   18 ++++++++----------
 net/sunrpc/svc.c               |    4 ++--
 14 files changed, 74 insertions(+), 53 deletions(-)

--- linux-2.6.25-rc5.orig/drivers/base/node.c
+++ linux-2.6.25-rc5/drivers/base/node.c
@@ -22,13 +22,13 @@ static struct sysdev_class node_class = 
 static ssize_t node_read_cpumap(struct sys_device * dev, char * buf)
 {
 	struct node *node_dev = to_node(dev);
-	cpumask_t mask = node_to_cpumask(node_dev->sysdev.id);
+	node_to_cpumask_ptr(mask, node_dev->sysdev.id);
 	int len;
 
 	/* 2004/06/03: buf currently PAGE_SIZE, need > 1 char per 4 bits. */
 	BUILD_BUG_ON(MAX_NUMNODES/4 > PAGE_SIZE/2);
 
-	len = cpumask_scnprintf(buf, PAGE_SIZE-1, mask);
+	len = cpumask_scnprintf(buf, PAGE_SIZE-1, *mask);
 	len += sprintf(buf + len, "\n");
 	return len;
 }
--- linux-2.6.25-rc5.orig/drivers/pci/pci-driver.c
+++ linux-2.6.25-rc5/drivers/pci/pci-driver.c
@@ -184,8 +184,8 @@ static int pci_call_probe(struct pci_dri
 	int node = pcibus_to_node(dev->bus);
 
 	if (node >= 0 && node_online(node)) {
-		cpumask_t nodecpumask = node_to_cpumask(node);
-		set_cpus_allowed(current, &nodecpumask);
+		node_to_cpumask_ptr(nodecpumask, node);
+		set_cpus_allowed(current, nodecpumask);
 	}
 	/* And set default memory allocation policy */
 	oldpol = current->mempolicy;
--- linux-2.6.25-rc5.orig/include/asm-alpha/topology.h
+++ linux-2.6.25-rc5/include/asm-alpha/topology.h
@@ -41,8 +41,7 @@ static inline cpumask_t node_to_cpumask(
 
 #define pcibus_to_cpumask(bus)	(cpu_online_map)
 
-#else /* CONFIG_NUMA */
-# include <asm-generic/topology.h>
 #endif /* !CONFIG_NUMA */
+# include <asm-generic/topology.h>
 
 #endif /* _ASM_ALPHA_TOPOLOGY_H */
--- linux-2.6.25-rc5.orig/include/asm-frv/topology.h
+++ linux-2.6.25-rc5/include/asm-frv/topology.h
@@ -5,10 +5,8 @@
 
 #error NUMA not supported yet
 
-#else /* !CONFIG_NUMA */
+#endif /* CONFIG_NUMA */
 
 #include <asm-generic/topology.h>
 
-#endif /* CONFIG_NUMA */
-
 #endif /* _ASM_TOPOLOGY_H */
--- linux-2.6.25-rc5.orig/include/asm-generic/topology.h
+++ linux-2.6.25-rc5/include/asm-generic/topology.h
@@ -27,6 +27,8 @@
 #ifndef _ASM_GENERIC_TOPOLOGY_H
 #define _ASM_GENERIC_TOPOLOGY_H
 
+#ifndef	CONFIG_NUMA
+
 /* Other architectures wishing to use this simple topology API should fill
    in the below functions as appropriate in their own <asm/topology.h> file. */
 #ifndef cpu_to_node
@@ -52,4 +54,16 @@
 				)
 #endif
 
+#endif	/* CONFIG_NUMA */
+
+/* returns pointer to cpumask for specified node */
+#ifndef node_to_cpumask_ptr
+
+#define	node_to_cpumask_ptr(v, node) 					\
+		cpumask_t _##v = node_to_cpumask(node), *v = &_##v
+
+#define node_to_cpumask_ptr_next(v, node)				\
+			  _##v = node_to_cpumask(node)
+#endif
+
 #endif /* _ASM_GENERIC_TOPOLOGY_H */
--- linux-2.6.25-rc5.orig/include/asm-ia64/topology.h
+++ linux-2.6.25-rc5/include/asm-ia64/topology.h
@@ -116,6 +116,11 @@ void build_cpu_to_node_map(void);
 #define smt_capable() 				(smp_num_siblings > 1)
 #endif
 
+#define pcibus_to_cpumask(bus)	(pcibus_to_node(bus) == -1 ? \
+					CPU_MASK_ALL : \
+					node_to_cpumask(pcibus_to_node(bus)) \
+				)
+
 #include <asm-generic/topology.h>
 
 #endif /* _ASM_IA64_TOPOLOGY_H */
--- linux-2.6.25-rc5.orig/include/asm-powerpc/topology.h
+++ linux-2.6.25-rc5/include/asm-powerpc/topology.h
@@ -96,11 +96,10 @@ static inline void sysfs_remove_device_f
 {
 }
 
+#endif /* CONFIG_NUMA */
 
 #include <asm-generic/topology.h>
 
-#endif /* CONFIG_NUMA */
-
 #ifdef CONFIG_SMP
 #include <asm/cputable.h>
 #define smt_capable()		(cpu_has_feature(CPU_FTR_SMT))
--- linux-2.6.25-rc5.orig/include/asm-x86/topology.h
+++ linux-2.6.25-rc5/include/asm-x86/topology.h
@@ -89,6 +89,17 @@ static inline int cpu_to_node(int cpu)
 #endif
 	return per_cpu(x86_cpu_to_node_map, cpu);
 }
+
+#ifdef	CONFIG_NUMA
+
+/* Returns a pointer to the cpumask of CPUs on Node 'node'. */
+#define node_to_cpumask_ptr(v, node)		\
+		cpumask_t *v = &(node_to_cpumask_map[node])
+
+#define node_to_cpumask_ptr_next(v, node)	\
+			   v = &(node_to_cpumask_map[node])
+#endif
+
 #endif /* CONFIG_X86_64 */
 
 /*
@@ -175,10 +186,10 @@ extern int __node_distance(int, int);
 
 #else /* CONFIG_NUMA */
 
-#include <asm-generic/topology.h>
-
 #endif
 
+#include <asm-generic/topology.h>
+
 extern cpumask_t cpu_coregroup_map(int cpu);
 
 #ifdef ENABLE_TOPO_DEFINES
--- linux-2.6.25-rc5.orig/include/linux/topology.h
+++ linux-2.6.25-rc5/include/linux/topology.h
@@ -38,16 +38,15 @@
 #endif
 
 #ifndef nr_cpus_node
-#define nr_cpus_node(node)							\
-	({									\
-		cpumask_t __tmp__;						\
-		__tmp__ = node_to_cpumask(node);				\
-		cpus_weight(__tmp__);						\
+#define nr_cpus_node(node)				\
+	({						\
+		node_to_cpumask_ptr(__tmp__, node);	\
+		cpus_weight(*__tmp__);			\
 	})
 #endif
 
-#define for_each_node_with_cpus(node)						\
-	for_each_online_node(node)						\
+#define for_each_node_with_cpus(node)			\
+	for_each_online_node(node)			\
 		if (nr_cpus_node(node))
 
 /* Conform to ACPI 2.0 SLIT distance definitions */
--- linux-2.6.25-rc5.orig/kernel/sched.c
+++ linux-2.6.25-rc5/kernel/sched.c
@@ -6304,7 +6304,7 @@ init_sched_build_groups(cpumask_t span, 
  *
  * Should use nodemask_t.
  */
-static int find_next_best_node(int node, unsigned long *used_nodes)
+static int find_next_best_node(int node, nodemask_t *used_nodes)
 {
 	int i, n, val, min_val, best_node = 0;
 
@@ -6318,7 +6318,7 @@ static int find_next_best_node(int node,
 			continue;
 
 		/* Skip already used nodes */
-		if (test_bit(n, used_nodes))
+		if (node_isset(n, *used_nodes))
 			continue;
 
 		/* Simple min distance search */
@@ -6330,14 +6330,13 @@ static int find_next_best_node(int node,
 		}
 	}
 
-	set_bit(best_node, used_nodes);
+	node_set(best_node, *used_nodes);
 	return best_node;
 }
 
 /**
  * sched_domain_node_span - get a cpumask for a node's sched_domain
  * @node: node whose cpumask we're constructing
- * @size: number of nodes to include in this span
  *
  * Given a node, construct a good cpumask for its sched_domain to span. It
  * should be one that prevents unnecessary balancing, but also spreads tasks
@@ -6345,22 +6344,22 @@ static int find_next_best_node(int node,
  */
 static cpumask_t sched_domain_node_span(int node)
 {
-	DECLARE_BITMAP(used_nodes, MAX_NUMNODES);
-	cpumask_t span, nodemask;
+	nodemask_t used_nodes;
+	cpumask_t span;
+	node_to_cpumask_ptr(nodemask, node);
 	int i;
 
 	cpus_clear(span);
-	bitmap_zero(used_nodes, MAX_NUMNODES);
+	nodes_clear(used_nodes);
 
-	nodemask = node_to_cpumask(node);
-	cpus_or(span, span, nodemask);
-	set_bit(node, used_nodes);
+	cpus_or(span, span, *nodemask);
+	node_set(node, used_nodes);
 
 	for (i = 1; i < SD_NODES_PER_DOMAIN; i++) {
-		int next_node = find_next_best_node(node, used_nodes);
+		int next_node = find_next_best_node(node, &used_nodes);
 
-		nodemask = node_to_cpumask(next_node);
-		cpus_or(span, span, nodemask);
+		node_to_cpumask_ptr_next(nodemask, next_node);
+		cpus_or(span, span, *nodemask);
 	}
 
 	return span;
@@ -6757,6 +6756,7 @@ static int build_sched_domains(const cpu
 		for (j = 0; j < MAX_NUMNODES; j++) {
 			cpumask_t tmp, notcovered;
 			int n = (i + j) % MAX_NUMNODES;
+			node_to_cpumask_ptr(nodemask, n);
 
 			cpus_complement(notcovered, covered);
 			cpus_and(tmp, notcovered, *cpu_map);
@@ -6764,8 +6764,7 @@ static int build_sched_domains(const cpu
 			if (cpus_empty(tmp))
 				break;
 
-			nodemask = node_to_cpumask(n);
-			cpus_and(tmp, tmp, nodemask);
+			cpus_and(tmp, tmp, *nodemask);
 			if (cpus_empty(tmp))
 				continue;
 
--- linux-2.6.25-rc5.orig/mm/page_alloc.c
+++ linux-2.6.25-rc5/mm/page_alloc.c
@@ -2115,6 +2115,7 @@ static int find_next_best_node(int node,
 	int n, val;
 	int min_val = INT_MAX;
 	int best_node = -1;
+	node_to_cpumask_ptr(tmp, 0);
 
 	/* Use the local node if we haven't already */
 	if (!node_isset(node, *used_node_mask)) {
@@ -2123,7 +2124,6 @@ static int find_next_best_node(int node,
 	}
 
 	for_each_node_state(n, N_HIGH_MEMORY) {
-		cpumask_t tmp;
 
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
@@ -2136,8 +2136,8 @@ static int find_next_best_node(int node,
 		val += (n < node);
 
 		/* Give preference to headless and unused nodes */
-		tmp = node_to_cpumask(n);
-		if (!cpus_empty(tmp))
+		node_to_cpumask_ptr_next(tmp, n);
+		if (!cpus_empty(*tmp))
 			val += PENALTY_FOR_NODE_WITH_CPUS;
 
 		/* Slight preference for less loaded node */
--- linux-2.6.25-rc5.orig/mm/slab.c
+++ linux-2.6.25-rc5/mm/slab.c
@@ -1156,14 +1156,13 @@ static void __cpuinit cpuup_canceled(lon
 	struct kmem_cache *cachep;
 	struct kmem_list3 *l3 = NULL;
 	int node = cpu_to_node(cpu);
+	node_to_cpumask_ptr(mask, node);
 
 	list_for_each_entry(cachep, &cache_chain, next) {
 		struct array_cache *nc;
 		struct array_cache *shared;
 		struct array_cache **alien;
-		cpumask_t mask;
 
-		mask = node_to_cpumask(node);
 		/* cpu is dead; no one can alloc from it. */
 		nc = cachep->array[cpu];
 		cachep->array[cpu] = NULL;
@@ -1179,7 +1178,7 @@ static void __cpuinit cpuup_canceled(lon
 		if (nc)
 			free_block(cachep, nc->entry, nc->avail, node);
 
-		if (!cpus_empty(mask)) {
+		if (!cpus_empty(*mask)) {
 			spin_unlock_irq(&l3->list_lock);
 			goto free_array_cache;
 		}
--- linux-2.6.25-rc5.orig/mm/vmscan.c
+++ linux-2.6.25-rc5/mm/vmscan.c
@@ -1674,11 +1674,10 @@ static int kswapd(void *p)
 	struct reclaim_state reclaim_state = {
 		.reclaimed_slab = 0,
 	};
-	cpumask_t cpumask;
+	node_to_cpumask_ptr(cpumask, pgdat->node_id);
 
-	cpumask = node_to_cpumask(pgdat->node_id);
-	if (!cpus_empty(cpumask))
-		set_cpus_allowed(tsk, &cpumask);
+	if (!cpus_empty(*cpumask))
+		set_cpus_allowed(tsk, cpumask);
 	current->reclaim_state = &reclaim_state;
 
 	/*
@@ -1907,17 +1906,16 @@ out:
 static int __devinit cpu_callback(struct notifier_block *nfb,
 				  unsigned long action, void *hcpu)
 {
-	pg_data_t *pgdat;
-	cpumask_t mask;
 	int nid;
 
 	if (action == CPU_ONLINE || action == CPU_ONLINE_FROZEN) {
 		for_each_node_state(nid, N_HIGH_MEMORY) {
-			pgdat = NODE_DATA(nid);
-			mask = node_to_cpumask(pgdat->node_id);
-			if (any_online_cpu(mask) < nr_cpu_ids)
+			pg_data_t *pgdat = NODE_DATA(nid);
+			node_to_cpumask_ptr(mask, pgdat->node_id);
+
+			if (any_online_cpu(*mask) < nr_cpu_ids)
 				/* One of our CPUs online: restore mask */
-				set_cpus_allowed(pgdat->kswapd, &mask);
+				set_cpus_allowed(pgdat->kswapd, mask);
 		}
 	}
 	return NOTIFY_OK;
--- linux-2.6.25-rc5.orig/net/sunrpc/svc.c
+++ linux-2.6.25-rc5/net/sunrpc/svc.c
@@ -323,10 +323,10 @@ svc_pool_map_set_cpumask(unsigned int pi
 	case SVC_POOL_PERNODE:
 	{
 		unsigned int node = m->pool_to[pidx];
-		cpumask_t nodecpumask = node_to_cpumask(node);
+		node_to_cpumask_ptr(nodecpumask, node);
 
 		*oldmask = current->cpus_allowed;
-		set_cpus_allowed(current, &nodecpumask);
+		set_cpus_allowed(current, nodecpumask);
 		return 1;
 	}
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
