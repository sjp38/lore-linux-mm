Date: Mon, 11 Jun 2007 11:29:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some
 are unpopulated
In-Reply-To: <20070611171201.GB3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111122010.18327@schroedinger.engr.sgi.com>
References: <20070607150425.GA15776@us.ibm.com>
 <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com>
 <20070607220149.GC15776@us.ibm.com> <466D44C6.6080105@shadowen.org>
 <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com>
 <20070611171201.GB3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Lee.Schermerhorn@hp.com, ak@suse.de, anton@samba.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> These are the exact semantics, I expected. so I'll be happy to test/work
> on these fixes.
> 
> This would also make it unnecessary to add the populated checks in
> various places, I think, as THISNODE will mean ONLYTHISNODE (and perhaps
> should be renamed in the series).

Here is a draft on how this could work:

It seems that MPOL_BIND already has the fixes needed. Adding empty zones 
does not look that easy. 
So I added a check interleave_nodes to verify that the selected node has
memory. If not skip it.

This does not work for the address based interleaving for anonymous vmas.
I am not sure what to do there. We could change the calculation of the
node to be based only on nodes with memory and then skip the memoryless 
ones. I have only added a comment to describe its brokennes for now.

Then there is the original issue of GFP_THISNODE. I added a check in 
alloc_pages_node to verify that the node has memory. If not then fail.
This will fix the alloc_pages_node case but not the alloc_pages() case.

In the alloc_pages() case we do not specify a node. Implicitly it is 
understood that we (in the case of no memory policy / cpuset options) 
allocate from the nearest node. So it may be argued there that the 
GFP_THISNODE behavior of taking the first node from the zonelist is okay.

There is some reason to worry about the performance impact from adding the 
check in alloc_pages_node and interleave. If the code is left in 
alloc_pages_node then alloc_pages_node should be uninlined and moved to 
mempolicy.c

Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c	2007-06-11 11:13:09.000000000 -0700
+++ linux-2.6/mm/mempolicy.c	2007-06-11 11:19:03.000000000 -0700
@@ -1125,9 +1125,11 @@ static unsigned interleave_nodes(struct 
 	struct task_struct *me = current;
 
 	nid = me->il_next;
-	next = next_node(nid, policy->v.nodes);
-	if (next >= MAX_NUMNODES)
-		next = first_node(policy->v.nodes);
+	do {
+		next = next_node(nid, policy->v.nodes);
+		if (next >= MAX_NUMNODES)
+			next = first_node(policy->v.nodes);
+	} while (!NODE_DATA(node)->present_pages);
 	me->il_next = next;
 	return nid;
 }
@@ -1191,6 +1193,11 @@ static inline unsigned interleave_nid(st
 		 * for huge pages, since vm_pgoff is in units of small
 		 * pages, we need to shift off the always 0 bits to get
 		 * a useful offset.
+		 *
+		 * For configurations with memoryless nodes this is broken
+		 * since the allocation attempts on that node will fall
+		 * back to other nodes and thus one neighboring node
+		 * will be overallocated from.
 		 */
 		BUG_ON(shift < PAGE_SHIFT);
 		off = vma->vm_pgoff >> (shift - PAGE_SHIFT);
Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2007-06-11 11:19:32.000000000 -0700
+++ linux-2.6/include/linux/gfp.h	2007-06-11 11:21:33.000000000 -0700
@@ -134,6 +134,9 @@ static inline struct page *alloc_pages_n
 	if (nid < 0)
 		nid = numa_node_id();
 
+	if ((gfp_mask & __GFP_THISNODE) && !NODE_DATA(nid)->present_pages)
+		return NULL;
+
 	return __alloc_pages(gfp_mask, order,
 		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
