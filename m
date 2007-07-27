From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:44:20 -0400
Message-Id: <20070727194420.18614.735.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 10/14] Memoryless nodes: Update memory policy and page migration
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 10/14] Memoryless nodes: Update memory policy and page migration

Online nodes now may have no memory. The checks and initialization must
therefore be changed to no longer use the online functions.

This will correctly initialize the interleave on bootup to only target
nodes with memory and will make sys_move_pages return an error when a page
is to be moved to a memoryless node. Similarly we will get an error if
MPOL_BIND and MPOL_INTERLEAVE is used on a memoryless node.

These are somewhat new semantics. So far one could specify memoryless nodes
and we would maybe do the right thing and just ignore the node (or we'd do
something strange like with MPOL_INTERLEAVE). If we want to allow the
specification of memoryless nodes via memory policies then we need to keep
checking for online nodes.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 mm/mempolicy.c |   10 +++++-----
 mm/migrate.c   |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

Index: Linux/mm/migrate.c
===================================================================
--- Linux.orig/mm/migrate.c	2007-07-25 11:36:22.000000000 -0400
+++ Linux/mm/migrate.c	2007-07-25 11:37:45.000000000 -0400
@@ -979,7 +979,7 @@ asmlinkage long sys_move_pages(pid_t pid
 				goto out;
 
 			err = -ENODEV;
-			if (!node_online(node))
+			if (!node_state(node, N_MEMORY))
 				goto out;
 
 			err = -EACCES;
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-07-25 11:36:30.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-07-25 11:37:45.000000000 -0400
@@ -494,9 +494,9 @@ static void get_zonemask(struct mempolic
 		*nodes = p->v.nodes;
 		break;
 	case MPOL_PREFERRED:
-		/* or use current node instead of online map? */
+		/* or use current node instead of memory_map? */
 		if (p->v.preferred_node < 0)
-			*nodes = node_online_map;
+			*nodes = node_states[N_MEMORY];
 		else
 			node_set(p->v.preferred_node, *nodes);
 		break;
@@ -1616,7 +1616,7 @@ void __init numa_policy_init(void)
 	 * fall back to the largest node if they're all smaller.
 	 */
 	nodes_clear(interleave_nodes);
-	for_each_online_node(nid) {
+	for_each_node_state(nid, N_MEMORY) {
 		unsigned long total_pages = node_present_pages(nid);
 
 		/* Preserve the largest node */
@@ -1896,7 +1896,7 @@ int show_numa_map(struct seq_file *m, vo
 		seq_printf(m, " huge");
 	} else {
 		check_pgd_range(vma, vma->vm_start, vma->vm_end,
-				&node_online_map, MPOL_MF_STATS, md);
+				&node_states[N_MEMORY], MPOL_MF_STATS, md);
 	}
 
 	if (!md->pages)
@@ -1923,7 +1923,7 @@ int show_numa_map(struct seq_file *m, vo
 	if (md->writeback)
 		seq_printf(m," writeback=%lu", md->writeback);
 
-	for_each_online_node(n)
+	for_each_node_state(n, N_MEMORY)
 		if (md->node[n])
 			seq_printf(m, " N%d=%lu", n, md->node[n]);
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
