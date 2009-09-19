Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0ACB76B0100
	for <linux-mm@kvack.org>; Sat, 19 Sep 2009 07:46:17 -0400 (EDT)
Date: Sat, 19 Sep 2009 12:46:21 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] slqb: Treat pages freed on a memoryless node as
	local node
Message-ID: <20090919114621.GC1225@csn.ul.ie>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie> <1253302451-27740-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0909181657280.9490@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909181657280.9490@V090114053VZO-1>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 18, 2009 at 05:01:14PM -0400, Christoph Lameter wrote:
> On Fri, 18 Sep 2009, Mel Gorman wrote:
> 
> > --- a/mm/slqb.c
> > +++ b/mm/slqb.c
> > @@ -1726,6 +1726,7 @@ static __always_inline void __slab_free(struct kmem_cache *s,
> >  	struct kmem_cache_cpu *c;
> >  	struct kmem_cache_list *l;
> >  	int thiscpu = smp_processor_id();
> > +	int thisnode = numa_node_id();
> 
> thisnode must be the first reachable node with usable RAM. Not the current
> node. cpu 0 may be on node 0 but there is no memory on 0. Instead
> allocations fall back to node 2 (depends on policy effective as well. The
> round robin meory policy default on bootup may result in allocations from
> different nodes as well).
> 

Agreed. Note that this is the free path and the point was to illustrate
that SLQB is always trying to allocate full pages locally and always
freeing them remotely. It always going to the allocator instead of going
to the remote lists first. On a memoryless system, this acts as a leak.

A more appropriate fix may be for the kmem_cache_cpu to remember what it
considers a local node. Ordinarily it'll be numa_node_id() but on memoryless
node it would be the closest reachable node. How would that sound?

> >  	c = get_cpu_slab(s, thiscpu);
> >  	l = &c->list;
> > @@ -1733,12 +1734,14 @@ static __always_inline void __slab_free(struct kmem_cache *s,
> >  	slqb_stat_inc(l, FREE);
> >
> >  	if (!NUMA_BUILD || !slab_numa(s) ||
> > -			likely(slqb_page_to_nid(page) == numa_node_id())) {
> > +			likely(slqb_page_to_nid(page) == numa_node_id() ||
> > +			!node_state(thisnode, N_HIGH_MEMORY))) {
> 
> Same here.
> 
> Note that page_to_nid can yield surprising results if you are trying to
> allocate from a node that has no memory and you get some fallback node.
> 
> SLAB for some time had a bug that caused list corruption because of this.
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
