Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 44CD06B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:21:23 -0400 (EDT)
Date: Thu, 28 Apr 2011 09:21:10 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 02/13] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20110428092110.608eb354@notabene.brown>
In-Reply-To: <20110426135940.GE4658@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
	<1303803414-5937-3-git-send-email-mgorman@suse.de>
	<20110426213758.450f6f49@notabene.brown>
	<20110426135940.GE4658@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, 26 Apr 2011 14:59:40 +0100 Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Apr 26, 2011 at 09:37:58PM +1000, NeilBrown wrote:
> > On Tue, 26 Apr 2011 08:36:43 +0100 Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > +		/*
> > > +		 * If there are full empty slabs and we were not forced to
> > > +		 * allocate a slab, mark this one !pfmemalloc
> > > +		 */
> > > +		l3 = cachep->nodelists[numa_mem_id()];
> > > +		if (!list_empty(&l3->slabs_free) && force_refill) {
> > > +			struct slab *slabp = virt_to_slab(objp);
> > > +			slabp->pfmemalloc = false;
> > > +			clear_obj_pfmemalloc(&objp);
> > > +			check_ac_pfmemalloc(cachep, ac);
> > > +			return objp;
> > > +		}
> > 
> > The comment doesn't match the code.  I think you need to remove the words
> > "full" and "not" assuming the code is correct which it probably is...
> > 
> 
> I'll fix up the comment, you're right, it's confusing.
> 
> > But the code seems to be much more complex than Peter's original, and I don't
> > see the gain.
> > 
> 
> You're right, it is more complex.
> 
> > Peter's code had only one 'reserved' flag for each kmem_cache. 
> 
> The reserve was set in a per-cpu structure so there was a "lag" time
> before that information was available to other CPUs. Fine on smaller
> machines but a bit more of a problem today. 
> 
> > You seem to
> > have one for every slab.  I don't see the point.
> > It is true that yours is in some sense more fair - but I'm not sure the
> > complexity is worth it.
> > 
> 
> More fairness was one of the objects.
> 
> > Was there some particular reason you made the change?
> > 
> 
> This version survives under considerably more stress than Peter's
> original version did without requiring the additional complexity of
> memory reserves.
> 

That is certainly a very compelling argument .... but I still don't get why.
I'm sorry if I'm being dense, but I still don't see why the complexity buys
us better stability and I really would like to understand.

You don't seem to need the same complexity for SLUB with the justification
of "SLUB generally maintaining smaller lists than SLAB".

Presumably these are per-CPU lists of free objects or slabs?  If the things
on those lists could be used by anyone long lists couldn't hurt.
So the problem must be that the lists get long while the array_cache is still
marked as 'pfmemalloc' (or 'reserve' in Peter's patches).

Is that the problem?  That reserve memory gets locked up in SLAB freelists?
If so - would that be more easily addressed by effectively reducing the
'batching' when the array_cache had dipped into reserves, so slabs are
returned to the VM more promptly?

Probably related, now that you've fixed the comment here (thanks):

+		/*
+		 * If there are empty slabs on the slabs_free list and we are
+		 * being forced to refill the cache, mark this one !pfmemalloc.
+		 */
+		l3 = cachep->nodelists[numa_mem_id()];
+		if (!list_empty(&l3->slabs_free) && force_refill) {
+			struct slab *slabp = virt_to_slab(objp);
+			slabp->pfmemalloc = false;
+			clear_obj_pfmemalloc(&objp);
+			check_ac_pfmemalloc(cachep, ac);
+			return objp;
+		}

I'm trying to understand it...
The context is that a non-MEMALLOC allocation is happening and everything on
the free lists is reserved for MEMALLOC allocations.
So if in that case there is a completely free slab on the free list we decide
that it is OK to mark the current slab as non-MEMALLOC.
The logic seems to be that we could just release that free slab to the VM,
then an alloc_page would be able to get it back.  But if we are still well
below the reserve watermark, then there might be some other allocation that
is more deserving of the page and we shouldn't just assume we can take
it with actually calling in to alloc_pages to check that we are no longer
running on reserves..

So this looks like an optimisation that is wrong.



BTW, 


+	/* Record if ALLOC_PFMEMALLOC was set when allocating the slab */
+	if (pfmemalloc) {
+		struct array_cache *ac = cpu_cache_get(cachep);
+		slabp->pfmemalloc = true;
+		ac->pfmemalloc = 1;
+	}
+

I think that "= 1"  should be "= true".  :-)

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
