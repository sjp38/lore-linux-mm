Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7856B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 09:21:47 -0400 (EDT)
Date: Thu, 9 Jul 2009 14:38:33 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] hugetlb:  derive huge pages nodes allowed from
	task mempolicy
Message-ID: <20090709133833.GB6324@csn.ul.ie>
References: <20090708192430.20687.30157.sendpatchset@lts-notebook> <20090708192446.20687.55809.sendpatchset@lts-notebook> <20090709133020.GA6324@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090709133020.GA6324@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 09, 2009 at 02:30:20PM +0100, Mel Gorman wrote:
> On Wed, Jul 08, 2009 at 03:24:46PM -0400, Lee Schermerhorn wrote:
> > [PATCH 2/3] hugetlb:  derive huge pages nodes allowed from task mempolicy
> > 
> > Against: 25jun09 mmotm atop the "hugetlb: balance freeing..." series
> > 
> > V2:
> > + cleaned up comments, removed some deemed unnecessary,
> >   add some suggested by review
> > + removed check for !current in huge_mpol_nodes_allowed().
> > + added 'current->comm' to warning message in huge_mpol_nodes_allowed().
> > + added VM_BUG_ON() assertion in hugetlb.c next_node_allowed() to
> >   catch out of range node id.
> > + add examples to patch description
> > 
> > This patch derives a "nodes_allowed" node mask from the numa
> > mempolicy of the task modifying the number of persistent huge
> > pages to control the allocation, freeing and adjusting of surplus
> > huge pages.  This mask is derived as follows:
> > 
> > * For "default" [NULL] task mempolicy, a NULL nodemask_t pointer
> >   is produced.  This will cause the hugetlb subsystem to use
> >   node_online_map as the "nodes_allowed".  This preserves the
> >   behavior before this patch.
> > * For "preferred" mempolicy, including explicit local allocation,
> >   a nodemask with the single preferred node will be produced. 
> >   "local" policy will NOT track any internode migrations of the
> >   task adjusting nr_hugepages.
> > * For "bind" and "interleave" policy, the mempolicy's nodemask
> >   will be used.
> > * Other than to inform the construction of the nodes_allowed node
> >   mask, the actual mempolicy mode is ignored.  That is, all modes
> >   behave like interleave over the resulting nodes_allowed mask
> >   with no "fallback".
> > 
> > Because we may have allocated or freed a huge page with a 
> > different policy/nodes_allowed previously, we always need to
> > check that the next_node_to_{alloc|free} exists in the current
> > nodes_allowed mask.  To avoid duplication of code, this is done
> > in the hstate_next_node_to_{alloc|free}() functions.  So,
> > these functions have been modified to allow them to be called
> > to obtain the "start_nid".  Then, whereas prior to this patch
> > we unconditionally called hstate_next_node_to_{alloc|free}(),
> > whether or not we successfully allocated/freed a huge page on
> > the node, now we only call these functions on failure to alloc/free.
> > 
> > Notes:
> > 
> > 1) This patch introduces a subtle change in behavior:  huge page
> >    allocation and freeing will be constrained by any mempolicy
> >    that the task adjusting the huge page pool inherits from its
> >    parent.  This policy could come from a distant ancestor.  The
> >    adminstrator adjusting the huge page pool without explicitly
> >    specifying a mempolicy via numactl might be surprised by this.
> >    Additionaly, any mempolicy specified by numactl will be
> >    constrained by the cpuset in which numactl is invoked.
> > 
> > 2) Hugepages allocated at boot time use the node_online_map.
> >    An additional patch could implement a temporary boot time
> >    huge pages nodes_allowed command line parameter.
> > 
> > 3) Using mempolicy to control persistent huge page allocation
> >    and freeing requires no change to hugeadm when invoking
> >    it via numactl, as shown in the examples below.  However,
> >    hugeadm could be enhanced to take the allowed nodes as an
> >    argument and set its task mempolicy itself.  This would allow
> >    it to detect and warn about any non-default mempolicy that it
> >    inherited from its parent, thus alleviating the issue described
> >    in Note 1 above.
> > 
> > See the updated documentation [next patch] for more information
> > about the implications of this patch.
> > 
> > Examples:
> > 
> > Starting with:
> > 
> > 	Node 0 HugePages_Total:     0
> > 	Node 1 HugePages_Total:     0
> > 	Node 2 HugePages_Total:     0
> > 	Node 3 HugePages_Total:     0
> > 
> > Default behavior [with or without this patch] balances persistent
> > hugepage allocation across nodes [with sufficient contiguous memory]:
> > 
> > 	hugeadm --pool-pages-min=2048Kb:32
> > 
> > yields:
> > 
> > 	Node 0 HugePages_Total:     8
> > 	Node 1 HugePages_Total:     8
> > 	Node 2 HugePages_Total:     8
> > 	Node 3 HugePages_Total:     8
> > 
> > Applying mempolicy--e.g., with numactl [using '-m' a.k.a.
> > '--membind' because it allows multiple nodes to be specified
> > and it's easy to type]--we can allocate huge pages on
> > individual nodes or sets of nodes.  So, starting from the 
> > condition above, with 8 huge pages per node:
> > 
> > 	numactl -m 2 hugeadm --pool-pages-min=2048Kb:+8
> > 
> > yields:
> > 
> > 	Node 0 HugePages_Total:     8
> > 	Node 1 HugePages_Total:     8
> > 	Node 2 HugePages_Total:    16
> > 	Node 3 HugePages_Total:     8
> > 
> > The incremental 8 huge pages were restricted to node 2 by the
> > specified mempolicy.
> > 
> > Similarly, we can use mempolicy to free persistent huge pages
> > from specified nodes:
> > 
> > 	numactl -m 0,1 hugeadm --pool-pages-min=2048Kb:-8
> > 
> > yields:
> > 
> > 	Node 0 HugePages_Total:     4
> > 	Node 1 HugePages_Total:     4
> > 	Node 2 HugePages_Total:    16
> > 	Node 3 HugePages_Total:     8
> > 
> > The 8 huge pages freed were balanced over nodes 0 and 1.
> > 
> > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> 
> Much better changelog.
> 
> Reading through, the main problem I can see is that the reservation
> calculations are still not nodemask aware. This means that mmap() can return
> successfully and the process that called mmap() get unexpectedly killed
> because while there were enough hugepages overall, there were not enough in
> the pools allowed by the nodemask. This is a stability problem for those that
> create hugepage pools on one set of nodes and run applications on a subset.
> Minimally, can this situation be warned about and a note in the documentation
> about it?
> 
> Testing with it, I couldn't break it as such but libhugetlbfs is showing up
> an anomaly with the counters tests. Some investigation showed that it was
> because when it shrinks the pool, one page gets accounted for as a surplus
> page which was unexpected.
> 
> I only got as far as determining the problem was in the patches that free
> pages in a round-robin fashion but then ran out of time on the machine. I'll
> see can I reproduce using fake-numa on a normal x86-64 instead of a real
> NUMA machine but maybe you have a fix for this problem already?
> 

Bah, you did. After I hit send, I remembered you sent one out and I didn't
pick it up properly. The counters tests works as expected now. I'll keep
testing but other than the stability problem when running on a subset of
nodes with hugepages, this looks good to me.

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

> >  include/linux/mempolicy.h |    3 +
> >  mm/hugetlb.c              |  101 +++++++++++++++++++++++++++++++---------------
> >  mm/mempolicy.c            |   61 +++++++++++++++++++++++++++
> >  3 files changed, 133 insertions(+), 32 deletions(-)
> > 
> > Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/hugetlb.c	2009-07-07 09:58:17.000000000 -0400
> > +++ linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c	2009-07-07 13:25:41.000000000 -0400
> > @@ -621,29 +621,54 @@ static struct page *alloc_fresh_huge_pag
> >  }
> >  
> >  /*
> > + * common helper functions for hstate_next_node_to_{alloc|free}.
> > + * We may have allocated or freed a huge pages based on a different
> > + * nodes_allowed, previously, so h->next_node_to_{alloc|free} might
> > + * be outside of *nodes_allowed.  Ensure that we use the next
> > + * allowed node for alloc or free.
> > + */
> > +static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
> > +{
> > +	nid = next_node(nid, *nodes_allowed);
> > +	if (nid == MAX_NUMNODES)
> > +		nid = first_node(*nodes_allowed);
> > +	VM_BUG_ON(nid >= MAX_NUMNODES);
> > +
> > +	return nid;
> > +}
> > +
> > +static int this_node_allowed(int nid, nodemask_t *nodes_allowed)
> > +{
> > +	if (!node_isset(nid, *nodes_allowed))
> > +		nid = next_node_allowed(nid, nodes_allowed);
> > +	return nid;
> > +}
> > +
> > +/*
> >   * Use a helper variable to find the next node and then
> >   * copy it back to next_nid_to_alloc afterwards:
> >   * otherwise there's a window in which a racer might
> >   * pass invalid nid MAX_NUMNODES to alloc_pages_exact_node.
> >   * But we don't need to use a spin_lock here: it really
> >   * doesn't matter if occasionally a racer chooses the
> > - * same nid as we do.  Move nid forward in the mask even
> > - * if we just successfully allocated a hugepage so that
> > - * the next caller gets hugepages on the next node.
> > + * same nid as we do.  Move nid forward in the mask whether
> > + * or not we just successfully allocated a hugepage so that
> > + * the next allocation addresses the next node.
> >   */
> >  static int hstate_next_node_to_alloc(struct hstate *h,
> >  					nodemask_t *nodes_allowed)
> >  {
> > -	int next_nid;
> > +	int nid, next_nid;
> >  
> >  	if (!nodes_allowed)
> >  		nodes_allowed = &node_online_map;
> >  
> > -	next_nid = next_node(h->next_nid_to_alloc, *nodes_allowed);
> > -	if (next_nid == MAX_NUMNODES)
> > -		next_nid = first_node(*nodes_allowed);
> > +	nid = this_node_allowed(h->next_nid_to_alloc, nodes_allowed);
> > +
> > +	next_nid = next_node_allowed(nid, nodes_allowed);
> >  	h->next_nid_to_alloc = next_nid;
> > -	return next_nid;
> > +
> > +	return nid;
> >  }
> >  
> >  static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
> > @@ -653,15 +678,17 @@ static int alloc_fresh_huge_page(struct 
> >  	int next_nid;
> >  	int ret = 0;
> >  
> > -	start_nid = h->next_nid_to_alloc;
> > +	start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> >  	next_nid = start_nid;
> >  
> >  	do {
> >  		page = alloc_fresh_huge_page_node(h, next_nid);
> > -		if (page)
> > +		if (page) {
> >  			ret = 1;
> > +			break;
> > +		}
> >  		next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> > -	} while (!page && next_nid != start_nid);
> > +	} while (next_nid != start_nid);
> >  
> >  	if (ret)
> >  		count_vm_event(HTLB_BUDDY_PGALLOC);
> > @@ -672,21 +699,23 @@ static int alloc_fresh_huge_page(struct 
> >  }
> >  
> >  /*
> > - * helper for free_pool_huge_page() - find next node
> > - * from which to free a huge page
> > + * helper for free_pool_huge_page() - return the next node
> > + * from which to free a huge page.  Advance the next node id
> > + * whether or not we find a free huge page to free so that the
> > + * next attempt to free addresses the next node.
> >   */
> >  static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
> >  {
> > -	int next_nid;
> > +	int nid, next_nid;
> >  
> >  	if (!nodes_allowed)
> >  		nodes_allowed = &node_online_map;
> >  
> > -	next_nid = next_node(h->next_nid_to_free, *nodes_allowed);
> > -	if (next_nid == MAX_NUMNODES)
> > -		next_nid = first_node(*nodes_allowed);
> > +	nid = this_node_allowed(h->next_nid_to_free, nodes_allowed);
> > +	next_nid = next_node_allowed(nid, nodes_allowed);
> >  	h->next_nid_to_free = next_nid;
> > -	return next_nid;
> > +
> > +	return nid;
> >  }
> >  
> >  /*
> > @@ -702,7 +731,7 @@ static int free_pool_huge_page(struct hs
> >  	int next_nid;
> >  	int ret = 0;
> >  
> > -	start_nid = h->next_nid_to_free;
> > +	start_nid = hstate_next_node_to_free(h, nodes_allowed);
> >  	next_nid = start_nid;
> >  
> >  	do {
> > @@ -724,9 +753,10 @@ static int free_pool_huge_page(struct hs
> >  			}
> >  			update_and_free_page(h, page);
> >  			ret = 1;
> > +			break;
> >  		}
> >   		next_nid = hstate_next_node_to_free(h, nodes_allowed);
> > -	} while (!ret && next_nid != start_nid);
> > +	} while (next_nid != start_nid);
> >  
> >  	return ret;
> >  }
> > @@ -1037,10 +1067,9 @@ int __weak alloc_bootmem_huge_page(struc
> >  		void *addr;
> >  
> >  		addr = __alloc_bootmem_node_nopanic(
> > -				NODE_DATA(h->next_nid_to_alloc),
> > +				NODE_DATA(hstate_next_node_to_alloc(h, NULL)),
> >  				huge_page_size(h), huge_page_size(h), 0);
> >  
> > -		hstate_next_node_to_alloc(h, NULL); /* always advance nid */
> >  		if (addr) {
> >  			/*
> >  			 * Use the beginning of the huge page to store the
> > @@ -1177,29 +1206,33 @@ static int adjust_pool_surplus(struct hs
> >  	VM_BUG_ON(delta != -1 && delta != 1);
> >  
> >  	if (delta < 0)
> > -		start_nid = h->next_nid_to_alloc;
> > +		start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> >  	else
> > -		start_nid = h->next_nid_to_free;
> > +		start_nid = hstate_next_node_to_free(h, nodes_allowed);
> >  	next_nid = start_nid;
> >  
> >  	do {
> >  		int nid = next_nid;
> >  		if (delta < 0)  {
> > -			next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> >  			/*
> >  			 * To shrink on this node, there must be a surplus page
> >  			 */
> > -			if (!h->surplus_huge_pages_node[nid])
> > +			if (!h->surplus_huge_pages_node[nid]) {
> > +				next_nid = hstate_next_node_to_alloc(h,
> > +								nodes_allowed);
> >  				continue;
> > +			}
> >  		}
> >  		if (delta > 0) {
> > -			next_nid = hstate_next_node_to_free(h, nodes_allowed);
> >  			/*
> >  			 * Surplus cannot exceed the total number of pages
> >  			 */
> >  			if (h->surplus_huge_pages_node[nid] >=
> > -						h->nr_huge_pages_node[nid])
> > +						h->nr_huge_pages_node[nid]) {
> > +				next_nid = hstate_next_node_to_free(h,
> > +								nodes_allowed);
> >  				continue;
> > +			}
> >  		}
> >  
> >  		h->surplus_huge_pages += delta;
> > @@ -1215,10 +1248,13 @@ static int adjust_pool_surplus(struct hs
> >  static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
> >  {
> >  	unsigned long min_count, ret;
> > +	nodemask_t *nodes_allowed;
> >  
> >  	if (h->order >= MAX_ORDER)
> >  		return h->max_huge_pages;
> >  
> > +	nodes_allowed = huge_mpol_nodes_allowed();
> > +
> >  	/*
> >  	 * Increase the pool size
> >  	 * First take pages out of surplus state.  Then make up the
> > @@ -1232,7 +1268,7 @@ static unsigned long set_max_huge_pages(
> >  	 */
> >  	spin_lock(&hugetlb_lock);
> >  	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
> > -		if (!adjust_pool_surplus(h, NULL, -1))
> > +		if (!adjust_pool_surplus(h, nodes_allowed, -1))
> >  			break;
> >  	}
> >  
> > @@ -1243,7 +1279,7 @@ static unsigned long set_max_huge_pages(
> >  		 * and reducing the surplus.
> >  		 */
> >  		spin_unlock(&hugetlb_lock);
> > -		ret = alloc_fresh_huge_page(h, NULL);
> > +		ret = alloc_fresh_huge_page(h, nodes_allowed);
> >  		spin_lock(&hugetlb_lock);
> >  		if (!ret)
> >  			goto out;
> > @@ -1269,16 +1305,17 @@ static unsigned long set_max_huge_pages(
> >  	min_count = max(count, min_count);
> >  	try_to_free_low(h, min_count);
> >  	while (min_count < persistent_huge_pages(h)) {
> > -		if (!free_pool_huge_page(h, NULL, 0))
> > +		if (!free_pool_huge_page(h, nodes_allowed, 0))
> >  			break;
> >  	}
> >  	while (count < persistent_huge_pages(h)) {
> > -		if (!adjust_pool_surplus(h, NULL, 1))
> > +		if (!adjust_pool_surplus(h, nodes_allowed, 1))
> >  			break;
> >  	}
> >  out:
> >  	ret = persistent_huge_pages(h);
> >  	spin_unlock(&hugetlb_lock);
> > +	kfree(nodes_allowed);
> >  	return ret;
> >  }
> >  
> > Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/mempolicy.c
> > ===================================================================
> > --- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/mempolicy.c	2009-07-07 09:46:48.000000000 -0400
> > +++ linux-2.6.31-rc1-mmotm-090625-1549/mm/mempolicy.c	2009-07-07 13:48:06.000000000 -0400
> > @@ -1544,6 +1544,67 @@ struct zonelist *huge_zonelist(struct vm
> >  	}
> >  	return zl;
> >  }
> > +
> > +/*
> > + * huge_mpol_nodes_allowed -- mempolicy extension for huge pages.
> > + *
> > + * Returns a [pointer to a] nodelist based on the current task's mempolicy
> > + * to constraing the allocation and freeing of persistent huge pages
> > + * 'Preferred', 'local' and 'interleave' mempolicy will behave more like
> > + * 'bind' policy in this context.  An attempt to allocate a persistent huge
> > + * page will never "fallback" to another node inside the buddy system
> > + * allocator.
> > + *
> > + * If the task's mempolicy is "default" [NULL], just return NULL for
> > + * default behavior.  Otherwise, extract the policy nodemask for 'bind'
> > + * or 'interleave' policy or construct a nodemask for 'preferred' or
> > + * 'local' policy and return a pointer to a kmalloc()ed nodemask_t.
> > + *
> > + * N.B., it is the caller's responsibility to free a returned nodemask.
> > + */
> > +nodemask_t *huge_mpol_nodes_allowed(void)
> > +{
> > +	nodemask_t *nodes_allowed = NULL;
> > +	struct mempolicy *mempolicy;
> > +	int nid;
> > +
> > +	if (!current->mempolicy)
> > +		return NULL;
> > +
> > +	mpol_get(current->mempolicy);
> > +	nodes_allowed = kmalloc(sizeof(*nodes_allowed), GFP_KERNEL);
> > +	if (!nodes_allowed) {
> > +		printk(KERN_WARNING "%s unable to allocate nodes allowed mask "
> > +			"for huge page allocation.\nFalling back to default.\n",
> > +			current->comm);
> > +		goto out;
> > +	}
> > +	nodes_clear(*nodes_allowed);
> > +
> > +	mempolicy = current->mempolicy;
> > +	switch(mempolicy->mode) {
> > +	case MPOL_PREFERRED:
> > +		if (mempolicy->flags & MPOL_F_LOCAL)
> > +			nid = numa_node_id();
> > +		else
> > +			nid = mempolicy->v.preferred_node;
> > +		node_set(nid, *nodes_allowed);
> > +		break;
> > +
> > +	case MPOL_BIND:
> > +		/* Fall through */
> > +	case MPOL_INTERLEAVE:
> > +		*nodes_allowed =  mempolicy->v.nodes;
> > +		break;
> > +
> > +	default:
> > +		BUG();
> > +	}
> > +
> > +out:
> > +	mpol_put(current->mempolicy);
> > +	return nodes_allowed;
> > +}
> >  #endif
> >  
> >  /* Allocate a page in interleaved policy.
> > Index: linux-2.6.31-rc1-mmotm-090625-1549/include/linux/mempolicy.h
> > ===================================================================
> > --- linux-2.6.31-rc1-mmotm-090625-1549.orig/include/linux/mempolicy.h	2009-07-06 13:05:23.000000000 -0400
> > +++ linux-2.6.31-rc1-mmotm-090625-1549/include/linux/mempolicy.h	2009-07-07 09:58:32.000000000 -0400
> > @@ -201,6 +201,7 @@ extern void mpol_fix_fork_child_flag(str
> >  extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
> >  				unsigned long addr, gfp_t gfp_flags,
> >  				struct mempolicy **mpol, nodemask_t **nodemask);
> > +extern nodemask_t *huge_mpol_nodes_allowed(void);
> >  extern unsigned slab_node(struct mempolicy *policy);
> >  
> >  extern enum zone_type policy_zone;
> > @@ -328,6 +329,8 @@ static inline struct zonelist *huge_zone
> >  	return node_zonelist(0, gfp_flags);
> >  }
> >  
> > +static inline nodemask_t *huge_mpol_nodes_allowed(void) { return NULL; }
> > +
> >  static inline int do_migrate_pages(struct mm_struct *mm,
> >  			const nodemask_t *from_nodes,
> >  			const nodemask_t *to_nodes, int flags)
> > 
> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
