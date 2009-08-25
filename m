Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D99B56B00BA
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:49:03 -0400 (EDT)
Subject: Re: [PATCH 3/5] hugetlb:  derive huge pages nodes allowed from
 task mempolicy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.0908250126280.23660@chino.kir.corp.google.com>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain>
	 <20090824192752.10317.96125.sendpatchset@localhost.localdomain>
	 <alpine.DEB.2.00.0908250126280.23660@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Tue, 25 Aug 2009 16:49:07 -0400
Message-Id: <1251233347.16229.0.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-08-25 at 01:47 -0700, David Rientjes wrote:
> On Mon, 24 Aug 2009, Lee Schermerhorn wrote:
> 
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
> >  include/linux/mempolicy.h |    3 ++
> >  mm/hugetlb.c              |   14 ++++++----
> >  mm/mempolicy.c            |   61 ++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 73 insertions(+), 5 deletions(-)
> > 
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/mm/mempolicy.c
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/mm/mempolicy.c	2009-08-24 12:12:44.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/mm/mempolicy.c	2009-08-24 12:12:53.000000000 -0400
> > @@ -1564,6 +1564,67 @@ struct zonelist *huge_zonelist(struct vm
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
> 
> I don't think using '\n' inside printk's is allowed anymore.

OK, will remove.
> 
> > +		goto out;
> > +	}
> > +	nodes_clear(*nodes_allowed);
> > +
> > +	mempolicy = current->mempolicy;
> > +	switch (mempolicy->mode) {
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
> 
> This should be all unnecessary, see below.
> 
> >  #endif
> >  
> >  /* Allocate a page in interleaved policy.
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/mempolicy.h
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/mempolicy.h	2009-08-24 12:12:44.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/mempolicy.h	2009-08-24 12:12:53.000000000 -0400
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
> > Index: linux-2.6.31-rc6-mmotm-090820-1918/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.31-rc6-mmotm-090820-1918.orig/mm/hugetlb.c	2009-08-24 12:12:50.000000000 -0400
> > +++ linux-2.6.31-rc6-mmotm-090820-1918/mm/hugetlb.c	2009-08-24 12:12:53.000000000 -0400
> > @@ -1257,10 +1257,13 @@ static int adjust_pool_surplus(struct hs
> >  static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
> >  {
> >  	unsigned long min_count, ret;
> > +	nodemask_t *nodes_allowed;
> >  
> >  	if (h->order >= MAX_ORDER)
> >  		return h->max_huge_pages;
> >  
> 
> Why can't you simply do this?
> 
> 	struct mempolicy *pol = NULL;
> 	nodemask_t *nodes_allowed = &node_online_map;
> 
> 	local_irq_disable();
> 	pol = current->mempolicy;
> 	mpol_get(pol);
> 	local_irq_enable();
> 	if (pol) {
> 		switch (pol->mode) {
> 		case MPOL_BIND:
> 		case MPOL_INTERLEAVE:
> 			nodes_allowed = pol->v.nodes;
> 			break;
> 		case MPOL_PREFERRED:
> 			... use NODEMASK_SCRATCH() ...
> 		default:
> 			BUG();
> 		}
> 	}
> 	mpol_put(pol);
> 
> and then use nodes_allowed throughout set_max_huge_pages()?


Well, I do use nodes_allowed [pointer] throughout set_max_huge_pages().
NODEMASK_SCRATCH() didn't exist when I wrote this, and I can't be sure
it will return a kmalloc()'d nodemask, which I need because a NULL
nodemask pointer means "all online nodes" [really all nodes with memory,
I suppose] and I need a pointer to kmalloc()'d nodemask to return from
huge_mpol_nodes_allowed().  I want to keep the access to the internals
of mempolicy in mempolicy.[ch], thus the call out to
huge_mpol_nodes_allowed(), instead of open coding it.  It's not really a
hot path, so I didn't want to fuss with a static inline in the header,
even tho' this is the only call site.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
