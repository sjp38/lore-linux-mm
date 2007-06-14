Message-Id: <20070614075336.187800982@sgi.com>
References: <20070614075026.607300756@sgi.com>
Date: Thu, 14 Jun 2007 00:50:35 -0700
From: clameter@sgi.com
Subject: [RFC 09/13] Memoryless nodes: Update memory policy and page migration
Content-Disposition: inline; filename=nodeless_migrate
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Online nodes now may have no memory. The checks and initialization must therefore
be changed to no longer use the online functions.

This will correctly initialize the interleave on bootup to only target
nodes with memory and will make sys_move_pages return an error when a page
is to be moved to a memoryless node. Similarly we will get an error if
MPOL_BIND and MPOL_INTERLEAVE is used on a memoryless node.

These are somewhat new semantics. So far one could specify memoryless nodes
and we would maybe do the right thing and just ignore the node (or wed do
something strange like with MPOL_INTERLEAVE). If we want to allow the
specification of memoryless nodes via memory policies then we need to keep
checking for online nodes.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/mm/migrate.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/migrate.c	2007-06-13 23:40:38.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/migrate.c	2007-06-13 23:41:26.000000000 -0700
@@ -963,7 +963,7 @@ asmlinkage long sys_move_pages(pid_t pid
 				goto out;
 
 			err = -ENODEV;
-			if (!node_online(node))
+			if (!node_memory(node))
 				goto out;
 
 			err = -EACCES;
Index: linux-2.6.22-rc4-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/mempolicy.c	2007-06-13 23:42:50.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/mempolicy.c	2007-06-13 23:44:57.000000000 -0700
@@ -130,7 +130,7 @@ static int mpol_check_policy(int mode, n
 			return -EINVAL;
 		break;
 	}
-	return nodes_subset(*nodes, node_online_map) ? 0 : -EINVAL;
+	return nodes_subset(*nodes, node_memory_map) ? 0 : -EINVAL;
 }
 
 /* Generate a custom zonelist for the BIND policy. */
@@ -495,9 +495,9 @@ static void get_zonemask(struct mempolic
 		*nodes = p->v.nodes;
 		break;
 	case MPOL_PREFERRED:
-		/* or use current node instead of online map? */
+		/* or use current node instead of memory_map? */
 		if (p->v.preferred_node < 0)
-			*nodes = node_online_map;
+			*nodes = node_memory_map;
 		else
 			node_set(p->v.preferred_node, *nodes);
 		break;
@@ -1606,7 +1606,7 @@ int mpol_parse_options(char *value, int 
 		*nodelist++ = '\0';
 		if (nodelist_parse(nodelist, *policy_nodes))
 			goto out;
-		if (!nodes_subset(*policy_nodes, node_online_map))
+		if (!nodes_subset(*policy_nodes, node_memory_map))
 			goto out;
 	}
 	if (!strcmp(value, "default")) {
@@ -1631,9 +1631,9 @@ int mpol_parse_options(char *value, int 
 			err = 0;
 	} else if (!strcmp(value, "interleave")) {
 		*policy = MPOL_INTERLEAVE;
-		/* Default to nodes online if no nodelist */
+		/* Default to nodes memory map if no nodelist */
 		if (!nodelist)
-			*policy_nodes = node_online_map;
+			*policy_nodes = node_memory_map;
 		err = 0;
 	}
 out:
@@ -1674,14 +1674,14 @@ void __init numa_policy_init(void)
 
 	/*
 	 * Use the specified nodemask for init, or fall back to
-	 * node_online_map.
+	 * node_memory_map.
 	 */
 	if (policy_sysinit == MPOL_DEFAULT)
 		nmask = NULL;
 	else if (!nodes_empty(nmask_sysinit))
 		nmask = &nmask_sysinit;
 	else
-		nmask = &node_online_map;
+		nmask = &node_memory_map;
 
 	if (do_set_mempolicy(policy_sysinit, nmask))
 		printk("numa_policy_init: setting init policy failed\n");
@@ -1945,7 +1945,7 @@ int show_numa_map(struct seq_file *m, vo
 		seq_printf(m, " huge");
 	} else {
 		check_pgd_range(vma, vma->vm_start, vma->vm_end,
-				&node_online_map, MPOL_MF_STATS, md);
+				&node_memory_map, MPOL_MF_STATS, md);
 	}
 
 	if (!md->pages)
@@ -1972,7 +1972,7 @@ int show_numa_map(struct seq_file *m, vo
 	if (md->writeback)
 		seq_printf(m," writeback=%lu", md->writeback);
 
-	for_each_online_node(n)
+	for_each_memory_node(n)
 		if (md->node[n])
 			seq_printf(m, " N%d=%lu", n, md->node[n]);
 out:

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
