Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8FB5B9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:59:47 -0400 (EDT)
Date: Tue, 26 Apr 2011 14:59:40 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/13] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20110426135940.GE4658@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
 <1303803414-5937-3-git-send-email-mgorman@suse.de>
 <20110426213758.450f6f49@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110426213758.450f6f49@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, Apr 26, 2011 at 09:37:58PM +1000, NeilBrown wrote:
> On Tue, 26 Apr 2011 08:36:43 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > +		/*
> > +		 * If there are full empty slabs and we were not forced to
> > +		 * allocate a slab, mark this one !pfmemalloc
> > +		 */
> > +		l3 = cachep->nodelists[numa_mem_id()];
> > +		if (!list_empty(&l3->slabs_free) && force_refill) {
> > +			struct slab *slabp = virt_to_slab(objp);
> > +			slabp->pfmemalloc = false;
> > +			clear_obj_pfmemalloc(&objp);
> > +			check_ac_pfmemalloc(cachep, ac);
> > +			return objp;
> > +		}
> 
> The comment doesn't match the code.  I think you need to remove the words
> "full" and "not" assuming the code is correct which it probably is...
> 

I'll fix up the comment, you're right, it's confusing.

> But the code seems to be much more complex than Peter's original, and I don't
> see the gain.
> 

You're right, it is more complex.

> Peter's code had only one 'reserved' flag for each kmem_cache. 

The reserve was set in a per-cpu structure so there was a "lag" time
before that information was available to other CPUs. Fine on smaller
machines but a bit more of a problem today. 

> You seem to
> have one for every slab.  I don't see the point.
> It is true that yours is in some sense more fair - but I'm not sure the
> complexity is worth it.
> 

More fairness was one of the objects.

> Was there some particular reason you made the change?
> 

This version survives under considerably more stress than Peter's
original version did without requiring the additional complexity of
memory reserves.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
