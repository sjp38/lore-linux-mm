Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BA9D36B0012
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 05:46:20 -0400 (EDT)
Date: Thu, 28 Apr 2011 10:46:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/13] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20110428094613.GN4658@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
 <1303803414-5937-3-git-send-email-mgorman@suse.de>
 <20110426213758.450f6f49@notabene.brown>
 <20110426135940.GE4658@suse.de>
 <20110428092110.608eb354@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110428092110.608eb354@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Thu, Apr 28, 2011 at 09:21:10AM +1000, NeilBrown wrote:
> On Tue, 26 Apr 2011 14:59:40 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Tue, Apr 26, 2011 at 09:37:58PM +1000, NeilBrown wrote:
> > > On Tue, 26 Apr 2011 08:36:43 +0100 Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > +		/*
> > > > +		 * If there are full empty slabs and we were not forced to
> > > > +		 * allocate a slab, mark this one !pfmemalloc
> > > > +		 */
> > > > +		l3 = cachep->nodelists[numa_mem_id()];
> > > > +		if (!list_empty(&l3->slabs_free) && force_refill) {
> > > > +			struct slab *slabp = virt_to_slab(objp);
> > > > +			slabp->pfmemalloc = false;
> > > > +			clear_obj_pfmemalloc(&objp);
> > > > +			check_ac_pfmemalloc(cachep, ac);
> > > > +			return objp;
> > > > +		}
> > > 
> > > The comment doesn't match the code.  I think you need to remove the words
> > > "full" and "not" assuming the code is correct which it probably is...
> > > 
> > 
> > I'll fix up the comment, you're right, it's confusing.
> > 
> > > But the code seems to be much more complex than Peter's original, and I don't
> > > see the gain.
> > > 
> > 
> > You're right, it is more complex.
> > 
> > > Peter's code had only one 'reserved' flag for each kmem_cache. 
> > 
> > The reserve was set in a per-cpu structure so there was a "lag" time
> > before that information was available to other CPUs. Fine on smaller
> > machines but a bit more of a problem today. 
> > 
> > > You seem to
> > > have one for every slab.  I don't see the point.
> > > It is true that yours is in some sense more fair - but I'm not sure the
> > > complexity is worth it.
> > > 
> > 
> > More fairness was one of the objects.
> > 
> > > Was there some particular reason you made the change?
> > > 
> > 
> > This version survives under considerably more stress than Peter's
> > original version did without requiring the additional complexity of
> > memory reserves.
> > 
> 
> That is certainly a very compelling argument .... but I still don't get why.
> I'm sorry if I'm being dense, but I still don't see why the complexity buys
> us better stability and I really would like to understand.
> 
> You don't seem to need the same complexity for SLUB with the justification
> of "SLUB generally maintaining smaller lists than SLAB".
> 

It is an educated guess that the length of the lists was what was
relevant. Even without these patches, SLUB is harder to lockup (minutes
rather than seconds to halt the machine) than SLAB and I assumed it
was because there were fewer pages pinned on per-CPU lists with SLUB.

> Presumably these are per-CPU lists of free objects or slabs? 

The per-cpu lists are of objects (the entry[] array in struct
array_cache). The slab management structure is looked up much less
frequently (when a block of objects are being freed for example).

> If the things
> on those lists could be used by anyone long lists couldn't hurt.

Long lists can hurt in a few ways but I believe the two relevant reasons
for this series are;

1. A remote CPU could be holding the object on its free list
2. Multiple unnecessary caches could be pinning free memory with the
   shrinkers not triggering because everything is waiting on IO to complete

> So the problem must be that the lists get long while the array_cache is still
> marked as 'pfmemalloc'

By marking the array_cache pfmemalloc we can have objects on the list
that are a mix of pfmemalloc and !pfmemalloc objects with very coarse
control over who is accessing them.

For example. In Peters patches, CPU A could allocate from pfmemalloc
reserves and mark its array_cache appropriately. CPU B could be freeing
the objects but not have its array_cache marked. PFMEMALLOC objects
are now available for !PFMEMALLOC uses on that CPU and we dip further
into our reserves. This was managed by the memory reservation patches
which meant that dipping further into the reserves was not that much
of a problem.

> (or 'reserve' in Peter's patches).
> 
> Is that the problem?  That reserve memory gets locked up in SLAB freelists?
> If so - would that be more easily addressed by effectively reducing the
> 'batching' when the array_cache had dipped into reserves, so slabs are
> returned to the VM more promptly?
> 

Pinning objects on long list is one problem but I don't think it's
the most important problem. Indications were that the big problem
was insufficient control over who was accessing objects belonging to
slab pages allocated from the pfmemalloc reserves.

> Probably related, now that you've fixed the comment here (thanks):
> 
> +		/*
> +		 * If there are empty slabs on the slabs_free list and we are
> +		 * being forced to refill the cache, mark this one !pfmemalloc.
> +		 */
> +		l3 = cachep->nodelists[numa_mem_id()];
> +		if (!list_empty(&l3->slabs_free) && force_refill) {
> +			struct slab *slabp = virt_to_slab(objp);
> +			slabp->pfmemalloc = false;
> +			clear_obj_pfmemalloc(&objp);
> +			check_ac_pfmemalloc(cachep, ac);
> +			return objp;
> +		}
> 
> I'm trying to understand it...

Thanks :)

> The context is that a non-MEMALLOC allocation is happening and everything on
> the free lists is reserved for MEMALLOC allocations.

Yep.

> So if in that case there is a completely free slab on the free list we decide
> that it is OK to mark the current slab as non-MEMALLOC.

Yep.

> The logic seems to be that we could just release that free slab to the VM,
> then an alloc_page would be able to get it back. 

We could, it'd be slower and there would need to be some sort of
retry path in a hotter code path to catch the situation but we could.

> But if we are still well
> below the reserve watermark, then there might be some other allocation that
> is more deserving of the page and we shouldn't just assume we can take
> it with actually calling in to alloc_pages to check that we are no longer
> running on reserves..
> 
> So this looks like an optimisation that is wrong.

The problem that is being addressed here is that pfmemalloc slabs
have to made available for general use at some point or slabs can
be artifically large and waste memory. I didn't do a free and retry
path because it'd be more expensive and I wanted to avoid hurting
the common slab paths.

The assumption is that if there are free slab pages while there are
pfmemalloc slabs in use then we cannot be under that much pressure
and the free slab page is safe to use. If we go well below the reserve
watermark as you are concerned about, the throttle logic will trigger
and we'll at least identify that the situation occured without the
system crashing.

> BTW, 
> 
> 
> +	/* Record if ALLOC_PFMEMALLOC was set when allocating the slab */
> +	if (pfmemalloc) {
> +		struct array_cache *ac = cpu_cache_get(cachep);
> +		slabp->pfmemalloc = true;
> +		ac->pfmemalloc = 1;
> +	}
> +
> 
> I think that "= 1"  should be "= true".  :-)
> 

/me slaps self

Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
