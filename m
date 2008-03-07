Date: Fri, 7 Mar 2008 11:50:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/8] slub: Fallback to order 0 and variable order slab
 support
In-Reply-To: <20080307121748.GF26229@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0803071147370.6815@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com> <20080304122008.GB19606@csn.ul.ie>
 <Pine.LNX.4.64.0803041044520.13957@schroedinger.engr.sgi.com>
 <20080305182834.GA10678@csn.ul.ie> <Pine.LNX.4.64.0803051051190.29794@schroedinger.engr.sgi.com>
 <20080306220402.GC20085@csn.ul.ie> <Pine.LNX.4.64.0803061409150.15083@schroedinger.engr.sgi.com>
 <20080307121748.GF26229@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Mel Gorman wrote:

> I don't think it would reduce them unless everyone was always using the
> same order. Once slub is using a higher order than everywhere else, it
> is possible it will use an alternative pageblock type just for the high
> order.

Hmmm... Maybe just order 0 and huge page order?

> The only tuning of the page allocator I can think of is to teach
> rmqueue_bulk() to use the fewer high-order allocations to batch refill
> the pcp queues. It's not very straight-forward though as when I tried
> this a bit over a year ago, it cause fragmentation problems of its own.
> I'll see about trying again.

The simplest solution would be to remove the pcps and put something else 
around the slow paths that does not check the limits etc.

> > Well in that case there is something going on very strange performance
> > wise. The results should be equal to upstream since the same orders 
> > are used.
> 
> Really, order-1 is used by default by SLUB upstream? I missed that and
> it doesn't appear to be the case on 2.6.25-rc2-mm1 at least according to
> slabinfo. If it was the difference between order-0 and order-1, it may be
> explained by the pcp allocator being bypassed.

Order 1 is the maximum that slub can use. We are not talking defaults 
here but what orders slub is allowed to use. The overwhelming majority of 
slab caches use order 0.

Even if you specify slub_max_order=4 there will still be lots of slab 
caches that use order 0 alloc. The higher orders are only used if the 
small order cannot fit more than slub_min_objects into one slab.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
