Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AD6496B00CB
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 23:03:16 -0500 (EST)
Date: Tue, 9 Nov 2010 15:03:06 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
Message-ID: <20101109040306.GC3493@amd>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <alpine.DEB.2.00.1010211259360.24115@router.home>
 <20101021235854.GD3270@amd>
 <20101022155513.GA26790@infradead.org>
 <alpine.DEB.2.00.1010221121550.22051@router.home>
 <20101024014256.GD3168@amd>
 <alpine.DEB.2.00.1010250957120.7461@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010250957120.7461@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 09:59:58AM -0500, Christoph Lameter wrote:
> On Sun, 24 Oct 2010, Nick Piggin wrote:
> 
> > > A reclaim that does per zone reclaim (but in reality reclaims all objects
> > > in a node (or worse as most shrinkers do today in the whole system) will
> > > put 3x the pressure on node 0.
> >
> > No it doesn't. This is how it works:
> >
> > node0zoneD has 1% of pagecache for node 0
> > node0zoneD32 has 9% of pagecache
> > node0zoneN has 90% of pagecache
> >
> > If there is a memory shortage in all node0 zones, the first zone will
> > get 1% of the pagecache scanning pressure, dma32 will get 9% and normal
> > will get 90%, for equal pressure on each zone.
> >
> > In my patch, those numbers will pass through to shrinker for each zone,
> > and ask the shrinker to scan and equal proportion of objects in each of
> > its zones.
> 
> Many shrinkers do not implement such a scheme.

And they don't need to.

 
> > If you have a per node shrinker, you will get asymmetries in pressures
> > whenever there is not an equal amount of reclaimable objects in all
> > the zones of a node.
> 
> Sure there would be different amounts allocated in the various nodes but
> you will get an equal amount of calls to the shrinkers. Anyways as you
> pointed out the shrinker can select the zones it will perform reclaim on.
> So for the slab shrinker it would not be an issue.

It can't without either doing the wrong thing, or knowing too much
about what reclaim is doing with zones. zone shrinkers are the right
way to go.

If you only care about nodes, you can easily go zone->node without
losing any information that you would have in a node shrinker scenario.
But with a node shrinker you cannot derive the zone.

Regardless of wheather you call HIGHMEM, DMA, MOVABLE, etc hacks or
bolt ons or not, they are fundamental part of the whole reclaim scheme,
so you really need to change that whole thing in a cohrerent way if you
don't like it, rather than adding bits that don't work well with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
