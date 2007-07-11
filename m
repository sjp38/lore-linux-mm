Date: Wed, 11 Jul 2007 11:56:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 10/12] Memoryless nodes: Update memory policy and page
 migration
In-Reply-To: <20070711184643.GA32035@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0707111154360.17503@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com> <20070711182252.138829364@sgi.com>
 <20070711184643.GA32035@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jul 2007, Nishanth Aravamudan wrote:

> > Index: linux-2.6.22-rc6-mm1/mm/migrate.c
> > ===================================================================
> > --- linux-2.6.22-rc6-mm1.orig/mm/migrate.c	2007-07-09 21:23:18.000000000 -0700
> > +++ linux-2.6.22-rc6-mm1/mm/migrate.c	2007-07-11 10:37:03.000000000 -0700
> > @@ -963,7 +963,7 @@ asmlinkage long sys_move_pages(pid_t pid
> >  				goto out;
> > 
> >  			err = -ENODEV;
> > -			if (!node_online(node))
> > +			if (!node_memory(node))
> 
> 			if (!node_state(node, N_MEMORY))
> 
> ?

Next patch fixes it up: :-=

Fixed up version


Memoryless nodes: Update memory policy and page migration

Online nodes now may have no memory. The checks and initialization must therefore
be changed to no longer use the online functions.

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

---
 mm/mempolicy.c |   10 +++++-----
 mm/migrate.c   |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

Index: linux-2.6.22-rc6-mm1/mm/migrate.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/migrate.c	2007-07-11 11:49:33.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/migrate.c	2007-07-11 11:51:34.000000000 -0700
@@ -963,7 +963,7 @@ asmlinkage long sys_move_pages(pid_t pid
 				goto out;
 
 			err = -ENODEV;
-			if (!node_online(node))
+			if (!node_state(node, N_MEMORY))
 				goto out;
 
 			err = -EACCES;
Index: linux-2.6.22-rc6-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/mempolicy.c	2007-07-11 11:49:39.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/mempolicy.c	2007-07-11 11:49:48.000000000 -0700
@@ -496,9 +496,9 @@ static void get_zonemask(struct mempolic
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
@@ -1618,7 +1618,7 @@ void __init numa_policy_init(void)
 	 * fall back to the largest node if they're all smaller.
 	 */
 	nodes_clear(interleave_nodes);
-	for_each_online_node(nid) {
+	for_each_node_state(nid, N_MEMORY) {
 		unsigned long total_pages = node_present_pages(nid);
 
 		/* Preserve the largest node */
@@ -1898,7 +1898,7 @@ int show_numa_map(struct seq_file *m, vo
 		seq_printf(m, " huge");
 	} else {
 		check_pgd_range(vma, vma->vm_start, vma->vm_end,
-				&node_online_map, MPOL_MF_STATS, md);
+				&node_states[N_MEMORY], MPOL_MF_STATS, md);
 	}
 
 	if (!md->pages)
@@ -1925,7 +1925,7 @@ int show_numa_map(struct seq_file *m, vo
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
