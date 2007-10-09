Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l993HQr5015223
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 23:17:26 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l993HQsN502796
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 21:17:26 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l993HP0C025233
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 21:17:26 -0600
Date: Mon, 8 Oct 2007 20:17:24 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
Message-ID: <20071009031724.GB26472@us.ibm.com>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie> <20070928142526.16783.97067.sendpatchset@skynet.skynet.ie> <20071009011143.GC14670@us.ibm.com> <Pine.LNX.4.64.0710081854370.28455@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710081854370.28455@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On 08.10.2007 [18:56:05 -0700], Christoph Lameter wrote:
> On Mon, 8 Oct 2007, Nishanth Aravamudan wrote:
> 
> > >  struct page * fastcall
> > >  __alloc_pages(gfp_t gfp_mask, unsigned int order,
> > >  		struct zonelist *zonelist)
> > >  {
> > > +	/*
> > > +	 * Use a temporary nodemask for __GFP_THISNODE allocations. If the
> > > +	 * cost of allocating on the stack or the stack usage becomes
> > > +	 * noticable, allocate the nodemasks per node at boot or compile time
> > > +	 */
> > > +	if (unlikely(gfp_mask & __GFP_THISNODE)) {
> > > +		nodemask_t nodemask;
> > > +
> > > +		return __alloc_pages_internal(gfp_mask, order,
> > > +				zonelist, nodemask_thisnode(&nodemask));
> > > +	}
> > > +
> > >  	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);
> > >  }
> > 
> > <snip>
> > 
> > So alloc_pages_node() calls here and for THISNODE allocations, we go ask
> > nodemask_thisnode() for a nodemask...
> 
> Hmmmm... nodemask_thisnode needs to be passed the zonelist.
> 
> > And nodemask_thisnode() always gives us a nodemask with only the node
> > the current process is running on set, I think?
> 
> Right.
> 
> 
> > That seems really wrong -- and would explain what Lee was seeing while
> > using my patches for the hugetlb pool allocator to use THISNODE
> > allocations. All the allocations would end up coming from whatever node
> > the process happened to be running on. This obviously messes up hugetlb
> > accounting, as I rely on THISNODE requests returning NULL if they go
> > off-node.
> > 
> > I'm not sure how this would be fixed, as __alloc_pages() no longer has
> > the nid to set in the mask.
> > 
> > Am I wrong in my analysis?
> 
> No you are right on target. The thisnode function must determine the
> node from the first zone of the zonelist.

It seems like I would zonelist_node_idx() for this, along the lines of:

	static nodemask_t *nodemask_thisnode(nodemask_t *nodemask,
		struct zonelist *zonelist)
	{
		int nid = zonelist_node_idx(zonelist);
		/* Build a nodemask for just this node */
		nodes_clear(*nodemask);
		node_set(nid, *nodemask);

		return nodemask;
	}

But I think I need to check that zonelist->_zonerefs->zone is !NULL, given this
definition of zonelist_node_idx()

	static inline int zonelist_node_idx(struct zoneref *zoneref)
	{
	#ifdef CONFIG_NUMA
		/* zone_to_nid not available in this context */
		return zoneref->zone->node;
	#else
		return 0;
	#endif /* CONFIG_NUMA */
	}

and this comment in __alloc_pages_internal():

	....
	z = zonelist->_zonerefs;  /* the list of zones suitable for gfp_mask */

	if (unlikely(!z->zone)) {
		/*
		 * Happens if we have an empty zonelist as a result of
		 * GFP_THISNODE being used on a memoryless node
		 */
		return NULL;
	}
	...

It seems like zoneref->zone may be NULL in zonelist_node_idx()? Maybe
someone else should look into resolving this :)

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
