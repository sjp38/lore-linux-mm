Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 925386B0062
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 06:04:49 -0400 (EDT)
Date: Mon, 9 Jul 2012 11:04:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 04/16] mm: allow PF_MEMALLOC from softirq context
Message-ID: <20120709100442.GZ14154@suse.de>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
 <1340375443-22455-5-git-send-email-mgorman@suse.de>
 <20120626165513.GD6509@breakpoint.cc>
 <20120627082614.GE8271@suse.de>
 <20120708181211.GE2872@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120708181211.GE2872@breakpoint.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Sun, Jul 08, 2012 at 08:12:11PM +0200, Sebastian Andrzej Siewior wrote:
> On Wed, Jun 27, 2012 at 09:26:14AM +0100, Mel Gorman wrote:
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index b6c0727..5c6d9c6 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -2265,7 +2265,11 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> > > >  	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
> > > >  		if (gfp_mask & __GFP_MEMALLOC)
> > > >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > > > -		else if (likely(!(gfp_mask & __GFP_NOMEMALLOC)) && !in_interrupt())
> > > > +		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
> > > > +			alloc_flags |= ALLOC_NO_WATERMARKS;
> > > > +		else if (!in_interrupt() &&
> > > > +				((current->flags & PF_MEMALLOC) ||
> > > > +				 unlikely(test_thread_flag(TIF_MEMDIE))))
> > > >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > > >  	}
> > > 
> > > You allocate in RX path with __GFP_MEMALLOC and your sk->sk_allocation has
> > > also __GFP_MEMALLOC set. That means you should get ALLOC_NO_WATERMARKS in
> > > alloc_flags.
> > 
> > In the cases where they are annotated correctly, yes. It is recordeed if
> > the page gets allocated from the PFMEMALLOC reserves. If the received
> > packet is not SOCK_MEMALLOC and the page was allocated from PFMEMALLOC
> > reserves it is then discarded and the packet must be retransmitted.
> 
> Let me try again:
> - lets assume your allocation happens with alloc_page(), without
>   __GFP_MEMALLOC in GFP_FLAGS and with PF_MEMALLOC in current->flags. Now
>   you may get memory which you wouldn't receive otherwise (without
>   PF_MEMALLOC). Okay, understood. So you don't have to annotate each page
>   allocation in your receive path for instance as long as the process has the
>   flag set.

Yes.

> - lets assume your allocation happens with kmalloc() without __GFP_MEMALLOC
>   and current->flags has PF_MEMALLOC ORed and your SLAB pool is empty. This
>   forces SLAB to allocate more pages from the buddy allocator with it will
>   receive more likely (due to ->current->flags + PF_MEMALLOC) but SLAB will
>   drop this extra memory because the page has ->pf_memory (or something like
>   that) set and the GFP_FLAGS do not have __GFP_MEMALLOC set.
> 

It's recorded if the slab page was allocated from PFMEMALLOC reserves (see
patch 2 from the swap over NBD series). slab will use this page for objects
but only allocate them to callers that pass a gfp_pfmemalloc_allowed() check.
kmalloc() users with either __GFP_MEMALLOC or PF_MEMALLOC will get
the pages they need but they will not "leak" to !_GFP_MEMALLOC users as
that would potentially deadlock.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
