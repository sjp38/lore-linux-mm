Subject: [PATCH/RFC] Allow selected nodes to be excluded from
	MPOL_INTERLEAVE masks
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 16:07:57 -0400
Message-Id: <1185566878.5069.123.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <clameter@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>, kxr@sgi.com, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Allow selected nodes to be excluded from MPOL_INTERLEAVE masks

Against:  2.6.23-rc1-mm1 atop Christoph Lameter's memoryless
	  node patch set.

This patch implements a new node state, N_INTERLEAVE, to specify
the subset of nodes with memory [state N_MEMORY] that are valid
for MPOL_INTERLEAVE node masks.  The new state mask is populated
from the N_MEMORY state mask, less any nodes excluded by a new
command line option, "no_interleave_nodes=<NodeList>".  Any nodemask
specified for an interleave policy is then masked by the N_INTERLEAVE
mask, including the temporary boot-time interleave policy.

Rationale:  some architectures and platforms include nodes with
memory that, in some cases, should never appear in MPOL_INTERLEAVE
node masks.  For example, the 'sh' architecture contains a small
amount of SRAM that is local to each cpu.  In some applications,
this memory should be reserved for explicit usage.  Another example
is the pseudo-node on HP ia64 platforms that is already interleaved
on a cache-line granularity by hardware.  Again, in some cases, we
want to reserve this for explicit usage, as it has bandwidth and
[average] latency characteristics quite different from the "real"
nodes.

Note that allocation of fresh hugepages in response to increases
in /proc/sys/vm/nr_hugepages is a form of interleaving.  I would
like to propose that allocate_fresh_huge_page() use the 
N_INTERLEAVE state as well as MPOL_INTERLEAVE.  Then, one can
explicity allocate hugepages on the excluded nodes, when needed,
using Nish Aravamundan's per node huge page sysfs attribute.
NOT in this patch.

Questions:

* do we need/want a sysctl for run time modifications?  IMO, no.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/kernel-parameters.txt |    9 +++++++++
 include/linux/nodemask.h            |    1 +
 mm/mempolicy.c                      |    9 +++++----
 mm/page_alloc.c                     |   24 +++++++++++++++++++++++-
 4 files changed, 38 insertions(+), 5 deletions(-)

Index: Linux/include/linux/nodemask.h
===================================================================
--- Linux.orig/include/linux/nodemask.h	2007-07-27 11:25:36.000000000 -0400
+++ Linux/include/linux/nodemask.h	2007-07-27 11:36:15.000000000 -0400
@@ -345,6 +345,7 @@ enum node_states {
 	N_ONLINE,	/* The node is online */
 	N_MEMORY,	/* The node has memory */
 	N_CPU,		/* The node has cpus */
+	N_INTERLEAVE,	/* The node is valid for MPOL_INTERLEAVE */
 	NR_NODE_STATES
 };
 
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-07-27 11:25:36.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-07-27 12:03:29.000000000 -0400
@@ -2003,6 +2003,21 @@ static char zonelist_order_name[3][8] = 
 
 
 #ifdef CONFIG_NUMA
+/*
+ * Command line:  no_interleave_nodes=<NodeList>
+ * Specify nodes to exclude from MPOL_INTERLEAVE masks.
+ */
+static nodemask_t no_interleave_nodes;	/* default:  none */
+
+static __init int setup_no_interleave_nodes(char *nodelist)
+{
+	if (nodelist) {
+		return nodelist_parse(nodelist, no_interleave_nodes);
+	}
+	return 0;
+}
+early_param("no_interleave_nodes", setup_no_interleave_nodes);
+
 /* The value user specified ....changed by config */
 static int user_zonelist_order = ZONELIST_ORDER_DEFAULT;
 /* string for sysctl */
@@ -2410,8 +2425,15 @@ static int __build_all_zonelists(void *d
 		build_zonelists(pgdat);
 		build_zonelist_cache(pgdat);
 
-		if (pgdat->node_present_pages)
+		if (pgdat->node_present_pages) {
 			node_set_state(nid, N_MEMORY);
+			/*
+			 * Only nodes with memory are valid for MPOL_INTERLEAVE,
+			 * but maybe not all of them?
+			 */
+			if (!node_isset(nid, no_interleave_nodes))
+				node_set_state(nid, N_INTERLEAVE);
+		}
 	}
 	return 0;
 }
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-07-27 11:25:36.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-07-27 11:50:01.000000000 -0400
@@ -184,7 +184,7 @@ static struct mempolicy *mpol_new(int mo
 	case MPOL_INTERLEAVE:
 		policy->v.nodes = *nodes;
 		nodes_and(policy->v.nodes, policy->v.nodes,
-					node_states[N_MEMORY]);
+					node_states[N_INTERLEAVE]);
 		if (nodes_weight(policy->v.nodes) == 0) {
 			kmem_cache_free(policy_cache, policy);
 			return ERR_PTR(-EINVAL);
@@ -1612,11 +1612,12 @@ void __init numa_policy_init(void)
 
 	/*
 	 * Set interleaving policy for system init. Interleaving is only
-	 * enabled across suitably sized nodes (default is >= 16MB), or
-	 * fall back to the largest node if they're all smaller.
+	 * enabled across suitably sized nodes (hard coded >= 16MB) on which
+	 * interleaving is allowed  Fall back to the largest node if all
+	 * allowable nodes are smaller than the hard coded limit.
 	 */
 	nodes_clear(interleave_nodes);
-	for_each_node_state(nid, N_MEMORY) {
+	for_each_node_state(nid, N_INTERLEAVE) {
 		unsigned long total_pages = node_present_pages(nid);
 
 		/* Preserve the largest node */
Index: Linux/Documentation/kernel-parameters.txt
===================================================================
--- Linux.orig/Documentation/kernel-parameters.txt	2007-07-25 09:29:48.000000000 -0400
+++ Linux/Documentation/kernel-parameters.txt	2007-07-27 11:43:54.000000000 -0400
@@ -1181,6 +1181,15 @@ and is between 256 and 4096 characters. 
 	noinitrd	[RAM] Tells the kernel not to load any configured
 			initial RAM disk.
 
+	no_interleave_nodes [KNL, BOOT] Specifies a list of nodes to exclude
+			[remove] from any nodemask specified with the
+			MPOL_INTERLEAVE policy.  Some platforms have nodes
+			that are "special" in some way and should not be
+			used for policy based interleaving.
+			Format:  no_interleave_nodes=<NodeList>
+			NodeList format is described in
+				Documentation/filesystems/tmpfs.txt
+
 	nointroute	[IA-64]
 
 	nojitter	[IA64] Disables jitter checking for ITC timers.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
