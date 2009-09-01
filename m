Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9796B004F
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 10:47:16 -0400 (EDT)
Date: Tue, 1 Sep 2009 15:47:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/6] hugetlb:  derive huge pages nodes allowed from
	task mempolicy
Message-ID: <20090901144719.GA7548@csn.ul.ie>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160332.11080.74896.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090828160332.11080.74896.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, Aug 28, 2009 at 12:03:32PM -0400, Lee Schermerhorn wrote:
> [PATCH 3/6] hugetlb:  derive huge pages nodes allowed from task mempolicy
> 
> Against: 2.6.31-rc7-mmotm-090827-0057
> 
> V2:
> + cleaned up comments, removed some deemed unnecessary,
>   add some suggested by review
> + removed check for !current in huge_mpol_nodes_allowed().
> + added 'current->comm' to warning message in huge_mpol_nodes_allowed().
> + added VM_BUG_ON() assertion in hugetlb.c next_node_allowed() to
>   catch out of range node id.
> + add examples to patch description
> 
> V3: Factored this patch from V2 patch 2/3
> 
> V4: added back missing "kfree(nodes_allowed)" in set_max_nr_hugepages()
> 
> V5: remove internal '\n' from printk in huge_mpol_nodes_allowed()
> 
> This patch derives a "nodes_allowed" node mask from the numa
> mempolicy of the task modifying the number of persistent huge
> pages to control the allocation, freeing and adjusting of surplus
> huge pages.  This mask is derived as follows:
> 
> * For "default" [NULL] task mempolicy, a NULL nodemask_t pointer
>   is produced.  This will cause the hugetlb subsystem to use
>   node_online_map as the "nodes_allowed".  This preserves the
>   behavior before this patch.
> * For "preferred" mempolicy, including explicit local allocation,
>   a nodemask with the single preferred node will be produced. 
>   "local" policy will NOT track any internode migrations of the
>   task adjusting nr_hugepages.
> * For "bind" and "interleave" policy, the mempolicy's nodemask
>   will be used.
> * Other than to inform the construction of the nodes_allowed node
>   mask, the actual mempolicy mode is ignored.  That is, all modes
>   behave like interleave over the resulting nodes_allowed mask
>   with no "fallback".
> 
> Notes:
> 
> 1) This patch introduces a subtle change in behavior:  huge page
>    allocation and freeing will be constrained by any mempolicy
>    that the task adjusting the huge page pool inherits from its
>    parent.  This policy could come from a distant ancestor.  The
>    adminstrator adjusting the huge page pool without explicitly
>    specifying a mempolicy via numactl might be surprised by this.
>    Additionaly, any mempolicy specified by numactl will be
>    constrained by the cpuset in which numactl is invoked.
>    Using sysfs per node hugepages attributes to adjust the per
>    node persistent huge pages count [subsequent patch] ignores
>    mempolicy and cpuset constraints.
> 
> 2) Hugepages allocated at boot time use the node_online_map.
>    An additional patch could implement a temporary boot time
>    huge pages nodes_allowed command line parameter.
> 
> 3) Using mempolicy to control persistent huge page allocation
>    and freeing requires no change to hugeadm when invoking
>    it via numactl, as shown in the examples below.  However,
>    hugeadm could be enhanced to take the allowed nodes as an
>    argument and set its task mempolicy itself.  This would allow
>    it to detect and warn about any non-default mempolicy that it
>    inherited from its parent, thus alleviating the issue described
>    in Note 1 above.
> 
> See the updated documentation [next patch] for more information
> about the implications of this patch.
> 
> Examples:
> 
> Starting with:
> 
> 	Node 0 HugePages_Total:     0
> 	Node 1 HugePages_Total:     0
> 	Node 2 HugePages_Total:     0
> 	Node 3 HugePages_Total:     0
> 
> Default behavior [with or without this patch] balances persistent
> hugepage allocation across nodes [with sufficient contiguous memory]:
> 
> 	hugeadm --pool-pages-min=2048Kb:32
> 
> yields:
> 
> 	Node 0 HugePages_Total:     8
> 	Node 1 HugePages_Total:     8
> 	Node 2 HugePages_Total:     8
> 	Node 3 HugePages_Total:     8
> 
> Applying mempolicy--e.g., with numactl [using '-m' a.k.a.
> '--membind' because it allows multiple nodes to be specified
> and it's easy to type]--we can allocate huge pages on
> individual nodes or sets of nodes.  So, starting from the 
> condition above, with 8 huge pages per node:
> 
> 	numactl -m 2 hugeadm --pool-pages-min=2048Kb:+8
> 
> yields:
> 
> 	Node 0 HugePages_Total:     8
> 	Node 1 HugePages_Total:     8
> 	Node 2 HugePages_Total:    16
> 	Node 3 HugePages_Total:     8
> 
> The incremental 8 huge pages were restricted to node 2 by the
> specified mempolicy.
> 
> Similarly, we can use mempolicy to free persistent huge pages
> from specified nodes:
> 
> 	numactl -m 0,1 hugeadm --pool-pages-min=2048Kb:-8
> 
> yields:
> 
> 	Node 0 HugePages_Total:     4
> 	Node 1 HugePages_Total:     4
> 	Node 2 HugePages_Total:    16
> 	Node 3 HugePages_Total:     8
> 
> The 8 huge pages freed were balanced over nodes 0 and 1.
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 

This seems to behave as advertised and I could spot no other problems in
the code so make that a;

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

As an aside, I think the ordering of the signed-offs, acks and reviews
are in the wrong order. The ordering of the lines is the order people
were involved in. You are the first as the author and I'm the second so
it should be

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reviewed-by: Mel Gorman <mel@csn.ul.ie>

rather than the other way around.

>  include/linux/mempolicy.h |    3 ++
>  mm/hugetlb.c              |   14 ++++++----
>  mm/mempolicy.c            |   61 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 73 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.31-rc7-mmotm-090827-0057/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.31-rc7-mmotm-090827-0057.orig/mm/mempolicy.c	2009-08-28 09:21:20.000000000 -0400
> +++ linux-2.6.31-rc7-mmotm-090827-0057/mm/mempolicy.c	2009-08-28 09:21:28.000000000 -0400
> @@ -1564,6 +1564,67 @@ struct zonelist *huge_zonelist(struct vm
>  	}
>  	return zl;
>  }
> +
> +/*
> + * huge_mpol_nodes_allowed -- mempolicy extension for huge pages.
> + *
> + * Returns a [pointer to a] nodelist based on the current task's mempolicy
> + * to constraing the allocation and freeing of persistent huge pages
> + * 'Preferred', 'local' and 'interleave' mempolicy will behave more like
> + * 'bind' policy in this context.  An attempt to allocate a persistent huge
> + * page will never "fallback" to another node inside the buddy system
> + * allocator.
> + *
> + * If the task's mempolicy is "default" [NULL], just return NULL for
> + * default behavior.  Otherwise, extract the policy nodemask for 'bind'
> + * or 'interleave' policy or construct a nodemask for 'preferred' or
> + * 'local' policy and return a pointer to a kmalloc()ed nodemask_t.
> + *
> + * N.B., it is the caller's responsibility to free a returned nodemask.
> + */
> +nodemask_t *huge_mpol_nodes_allowed(void)
> +{
> +	nodemask_t *nodes_allowed = NULL;
> +	struct mempolicy *mempolicy;
> +	int nid;
> +
> +	if (!current->mempolicy)
> +		return NULL;
> +
> +	mpol_get(current->mempolicy);
> +	nodes_allowed = kmalloc(sizeof(*nodes_allowed), GFP_KERNEL);
> +	if (!nodes_allowed) {
> +		printk(KERN_WARNING "%s unable to allocate nodes allowed mask "
> +			"for huge page allocation.  Falling back to default.\n",
> +			current->comm);
> +		goto out;
> +	}
> +	nodes_clear(*nodes_allowed);
> +
> +	mempolicy = current->mempolicy;
> +	switch (mempolicy->mode) {
> +	case MPOL_PREFERRED:
> +		if (mempolicy->flags & MPOL_F_LOCAL)
> +			nid = numa_node_id();
> +		else
> +			nid = mempolicy->v.preferred_node;
> +		node_set(nid, *nodes_allowed);
> +		break;
> +
> +	case MPOL_BIND:
> +		/* Fall through */
> +	case MPOL_INTERLEAVE:
> +		*nodes_allowed =  mempolicy->v.nodes;
> +		break;
> +
> +	default:
> +		BUG();
> +	}
> +
> +out:
> +	mpol_put(current->mempolicy);
> +	return nodes_allowed;
> +}
>  #endif
>  
>  /* Allocate a page in interleaved policy.
> Index: linux-2.6.31-rc7-mmotm-090827-0057/include/linux/mempolicy.h
> ===================================================================
> --- linux-2.6.31-rc7-mmotm-090827-0057.orig/include/linux/mempolicy.h	2009-08-28 09:21:20.000000000 -0400
> +++ linux-2.6.31-rc7-mmotm-090827-0057/include/linux/mempolicy.h	2009-08-28 09:21:28.000000000 -0400
> @@ -201,6 +201,7 @@ extern void mpol_fix_fork_child_flag(str
>  extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
>  				unsigned long addr, gfp_t gfp_flags,
>  				struct mempolicy **mpol, nodemask_t **nodemask);
> +extern nodemask_t *huge_mpol_nodes_allowed(void);
>  extern unsigned slab_node(struct mempolicy *policy);
>  
>  extern enum zone_type policy_zone;
> @@ -328,6 +329,8 @@ static inline struct zonelist *huge_zone
>  	return node_zonelist(0, gfp_flags);
>  }
>  
> +static inline nodemask_t *huge_mpol_nodes_allowed(void) { return NULL; }
> +
>  static inline int do_migrate_pages(struct mm_struct *mm,
>  			const nodemask_t *from_nodes,
>  			const nodemask_t *to_nodes, int flags)
> Index: linux-2.6.31-rc7-mmotm-090827-0057/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-rc7-mmotm-090827-0057.orig/mm/hugetlb.c	2009-08-28 09:21:26.000000000 -0400
> +++ linux-2.6.31-rc7-mmotm-090827-0057/mm/hugetlb.c	2009-08-28 09:21:28.000000000 -0400
> @@ -1248,10 +1248,13 @@ static int adjust_pool_surplus(struct hs
>  static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
>  {
>  	unsigned long min_count, ret;
> +	nodemask_t *nodes_allowed;
>  
>  	if (h->order >= MAX_ORDER)
>  		return h->max_huge_pages;
>  
> +	nodes_allowed = huge_mpol_nodes_allowed();
> +
>  	/*
>  	 * Increase the pool size
>  	 * First take pages out of surplus state.  Then make up the
> @@ -1265,7 +1268,7 @@ static unsigned long set_max_huge_pages(
>  	 */
>  	spin_lock(&hugetlb_lock);
>  	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
> -		if (!adjust_pool_surplus(h, NULL, -1))
> +		if (!adjust_pool_surplus(h, nodes_allowed, -1))
>  			break;
>  	}
>  
> @@ -1276,7 +1279,7 @@ static unsigned long set_max_huge_pages(
>  		 * and reducing the surplus.
>  		 */
>  		spin_unlock(&hugetlb_lock);
> -		ret = alloc_fresh_huge_page(h, NULL);
> +		ret = alloc_fresh_huge_page(h, nodes_allowed);
>  		spin_lock(&hugetlb_lock);
>  		if (!ret)
>  			goto out;
> @@ -1300,18 +1303,19 @@ static unsigned long set_max_huge_pages(
>  	 */
>  	min_count = h->resv_huge_pages + h->nr_huge_pages - h->free_huge_pages;
>  	min_count = max(count, min_count);
> -	try_to_free_low(h, min_count, NULL);
> +	try_to_free_low(h, min_count, nodes_allowed);
>  	while (min_count < persistent_huge_pages(h)) {
> -		if (!free_pool_huge_page(h, NULL, 0))
> +		if (!free_pool_huge_page(h, nodes_allowed, 0))
>  			break;
>  	}
>  	while (count < persistent_huge_pages(h)) {
> -		if (!adjust_pool_surplus(h, NULL, 1))
> +		if (!adjust_pool_surplus(h, nodes_allowed, 1))
>  			break;
>  	}
>  out:
>  	ret = persistent_huge_pages(h);
>  	spin_unlock(&hugetlb_lock);
> +	kfree(nodes_allowed);
>  	return ret;
>  }
>  
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
