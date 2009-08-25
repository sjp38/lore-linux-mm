Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D4A9D6B00B5
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:35:21 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n7PKZH1E009306
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 21:35:17 +0100
Received: from pxi32 (pxi32.prod.google.com [10.243.27.32])
	by spaceape11.eur.corp.google.com with ESMTP id n7P8lsqW004038
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 01:49:51 -0700
Received: by pxi32 with SMTP id 32so5132985pxi.25
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 01:47:53 -0700 (PDT)
Date: Tue, 25 Aug 2009 01:47:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/5] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <20090824192752.10317.96125.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.0908250126280.23660@chino.kir.corp.google.com>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain> <20090824192752.10317.96125.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 24 Aug 2009, Lee Schermerhorn wrote:

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
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  include/linux/mempolicy.h |    3 ++
>  mm/hugetlb.c              |   14 ++++++----
>  mm/mempolicy.c            |   61 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 73 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.31-rc6-mmotm-090820-1918/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.31-rc6-mmotm-090820-1918.orig/mm/mempolicy.c	2009-08-24 12:12:44.000000000 -0400
> +++ linux-2.6.31-rc6-mmotm-090820-1918/mm/mempolicy.c	2009-08-24 12:12:53.000000000 -0400
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
> +			"for huge page allocation.\nFalling back to default.\n",
> +			current->comm);

I don't think using '\n' inside printk's is allowed anymore.

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

This should be all unnecessary, see below.

>  #endif
>  
>  /* Allocate a page in interleaved policy.
> Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/mempolicy.h
> ===================================================================
> --- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/mempolicy.h	2009-08-24 12:12:44.000000000 -0400
> +++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/mempolicy.h	2009-08-24 12:12:53.000000000 -0400
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
> Index: linux-2.6.31-rc6-mmotm-090820-1918/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-rc6-mmotm-090820-1918.orig/mm/hugetlb.c	2009-08-24 12:12:50.000000000 -0400
> +++ linux-2.6.31-rc6-mmotm-090820-1918/mm/hugetlb.c	2009-08-24 12:12:53.000000000 -0400
> @@ -1257,10 +1257,13 @@ static int adjust_pool_surplus(struct hs
>  static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
>  {
>  	unsigned long min_count, ret;
> +	nodemask_t *nodes_allowed;
>  
>  	if (h->order >= MAX_ORDER)
>  		return h->max_huge_pages;
>  

Why can't you simply do this?

	struct mempolicy *pol = NULL;
	nodemask_t *nodes_allowed = &node_online_map;

	local_irq_disable();
	pol = current->mempolicy;
	mpol_get(pol);
	local_irq_enable();
	if (pol) {
		switch (pol->mode) {
		case MPOL_BIND:
		case MPOL_INTERLEAVE:
			nodes_allowed = pol->v.nodes;
			break;
		case MPOL_PREFERRED:
			... use NODEMASK_SCRATCH() ...
		default:
			BUG();
		}
	}
	mpol_put(pol);

and then use nodes_allowed throughout set_max_huge_pages()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
