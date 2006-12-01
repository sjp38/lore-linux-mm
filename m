Date: Fri, 1 Dec 2006 08:37:03 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab: Better fallback allocation behavior
In-Reply-To: <20061201123205.GA3528@skynet.ie>
Message-ID: <Pine.LNX.4.64.0612010832360.17445@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611291659390.18762@schroedinger.engr.sgi.com>
 <20061201123205.GA3528@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Dec 2006, Mel Gorman wrote:

> > @@ -2569,7 +2564,7 @@ static struct slab *alloc_slabmgmt(struc
> >  	if (OFF_SLAB(cachep)) {
> >  		/* Slab management obj is off-slab. */
> >  		slabp = kmem_cache_alloc_node(cachep->slabp_cache,
> > -					      local_flags, nodeid);
> > +					      local_flags & ~GFP_THISNODE, nodeid);
> 
> This also removes the __GFP_NOWARN and __GFP_NORETRY flags. Is that intended
> or did you mean ~__GFP_THISNODE?

Alloc slabmgmt is called in the chain by cache_grow(). cache_grow may have 
been passed GFP_THISNODE. So we need to undo this to insure that 
allocations of the slab management structures do not fail. This introduces 
the risk of the management structures to be on a different node. However, 
the objects will be on the intended node.

> >  	if (unlikely(!ac->avail)) {
> >  		int x;
> > -		x = cache_grow(cachep, flags, node);
> > +		x = cache_grow(cachep, flags | GFP_THISNODE, node, NULL);
> >  
> 
> Ok, so we first try and stick to the current node and there is no
> fallback, reclaim or policy enforcement. As a side-effect (I think,
> slab.c boggles the mind and I'm not as familiar with it as I should be),
> callers of kmem_cache_alloc() now imply __GFP_THISNODE | __GFP_NORETRY and
> __GFP_NORETRY. Again, just checking, is this intentional?

Yes this is mind booglingly complex and one reason why I am working on 
another slab implementation that does not suffer these complications. 

> > +			cache->nodelists[nid] &&
> > +			cache->nodelists[nid]->free_objects)
> > +				obj = ____cache_alloc_node(cache,
> > +					flags | GFP_THISNODE, nid);
> > +	}
> 
> Would we not get similar behavior if you just didn't specify
> GFP_THISNODE?
> 
> Again, GFP_THISNODE vs __GFP_THISNODE, intentional?

Yes __GFP_THISNODE can cause reclaim and we do not want to trigger reclaim  
until we have checked all the queues of all other nodes for available 
slabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
