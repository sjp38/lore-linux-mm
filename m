Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id DCE3A6B0072
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 07:09:38 -0400 (EDT)
Date: Tue, 10 Jul 2012 12:09:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 04/16] mm: allow PF_MEMALLOC from softirq context
Message-ID: <20120710110932.GC14154@suse.de>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
 <1340375443-22455-5-git-send-email-mgorman@suse.de>
 <20120626165513.GD6509@breakpoint.cc>
 <20120627082614.GE8271@suse.de>
 <20120708181211.GE2872@breakpoint.cc>
 <20120709100442.GZ14154@suse.de>
 <20120709165710.GC3515@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120709165710.GC3515@breakpoint.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Mon, Jul 09, 2012 at 06:57:10PM +0200, Sebastian Andrzej Siewior wrote:
> On Mon, Jul 09, 2012 at 11:04:42AM +0100, Mel Gorman wrote:
> > > - lets assume your allocation happens with kmalloc() without __GFP_MEMALLOC
> > >   and current->flags has PF_MEMALLOC ORed and your SLAB pool is empty. This
> > >   forces SLAB to allocate more pages from the buddy allocator with it will
> > >   receive more likely (due to ->current->flags + PF_MEMALLOC) but SLAB will
> > >   drop this extra memory because the page has ->pf_memory (or something like
> > >   that) set and the GFP_FLAGS do not have __GFP_MEMALLOC set.
> > > 
> > 
> > It's recorded if the slab page was allocated from PFMEMALLOC reserves (see
> > patch 2 from the swap over NBD series). slab will use this page for objects
> > but only allocate them to callers that pass a gfp_pfmemalloc_allowed() check.
> > kmalloc() users with either __GFP_MEMALLOC or PF_MEMALLOC will get
> > the pages they need but they will not "leak" to !_GFP_MEMALLOC users as
> > that would potentially deadlock.
> 
> Argh, I missed that gfp_to_alloc_flags() is not only called from
> within the buddy allocater but also from slab. So this is fine then :)
> 

Good to hear. I appreciate you taking the time to give it a solid review
like this looking for holes.

> One thing:
> You only get current->flags |= PF_MEMALLOC in softirq _if_ the skb, which is 
> passed to netif_receive_skb(), was allocated with __GFP_MEMALLOC. That
> means if the NIC's RX allocation did not require an allocation from the
> emergency pool (without ->pfmemalloc set) then you never use this extra
> pool, even if this skb would end up in your swap socket. Also, the other way
> around, where you allocate it from the emergency pool but it is a user
> socket and you could drop it.
> 

While there is a possibility that packets may get dropped later like this,
they still get retransmitted and eventually it'll get through.  This is
not optimal but optimised swap-over-network was not the primary goal of
the series, deadlock avoidance was.

> What about extending sk_set_memalloc() to record socket's ips + ports
> in a separate list so that skb_pfmemalloc_protocol() might use that
> information and decide on per-protocol basis if the skb is worth to
> spend more ressource to deliver it. That means you would enable the
> extra pool if the currently received skb is part of your swap socket and
> not if the skb was allocated from the emergency pool.
> 
> That said, there is nothing wrong with the code as of now and this
> optimization could be added later (if at all).
> 

I think it is a good idea but it could also be done later iff a user had
a serious problem with the performance and that this made a measurable
difference. The series is already quite complex and I'd rather not add to
that complexity without strong motivation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
