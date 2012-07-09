Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id AA8A56B005C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:57:31 -0400 (EDT)
Date: Mon, 9 Jul 2012 18:57:10 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH 04/16] mm: allow PF_MEMALLOC from softirq context
Message-ID: <20120709165710.GC3515@breakpoint.cc>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
 <1340375443-22455-5-git-send-email-mgorman@suse.de>
 <20120626165513.GD6509@breakpoint.cc>
 <20120627082614.GE8271@suse.de>
 <20120708181211.GE2872@breakpoint.cc>
 <20120709100442.GZ14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120709100442.GZ14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Mon, Jul 09, 2012 at 11:04:42AM +0100, Mel Gorman wrote:
> > - lets assume your allocation happens with kmalloc() without __GFP_MEMALLOC
> >   and current->flags has PF_MEMALLOC ORed and your SLAB pool is empty. This
> >   forces SLAB to allocate more pages from the buddy allocator with it will
> >   receive more likely (due to ->current->flags + PF_MEMALLOC) but SLAB will
> >   drop this extra memory because the page has ->pf_memory (or something like
> >   that) set and the GFP_FLAGS do not have __GFP_MEMALLOC set.
> > 
> 
> It's recorded if the slab page was allocated from PFMEMALLOC reserves (see
> patch 2 from the swap over NBD series). slab will use this page for objects
> but only allocate them to callers that pass a gfp_pfmemalloc_allowed() check.
> kmalloc() users with either __GFP_MEMALLOC or PF_MEMALLOC will get
> the pages they need but they will not "leak" to !_GFP_MEMALLOC users as
> that would potentially deadlock.

Argh, I missed that gfp_to_alloc_flags() is not only called from
within the buddy allocater but also from slab. So this is fine then :)

One thing:
You only get current->flags |= PF_MEMALLOC in softirq _if_ the skb, which is 
passed to netif_receive_skb(), was allocated with __GFP_MEMALLOC. That
means if the NIC's RX allocation did not require an allocation from the
emergency pool (without ->pfmemalloc set) then you never use this extra
pool, even if this skb would end up in your swap socket. Also, the other way
around, where you allocate it from the emergency pool but it is a user
socket and you could drop it.

What about extending sk_set_memalloc() to record socket's ips + ports
in a separate list so that skb_pfmemalloc_protocol() might use that
information and decide on per-protocol basis if the skb is worth to
spend more ressource to deliver it. That means you would enable the
extra pool if the currently received skb is part of your swap socket and
not if the skb was allocated from the emergency pool.

That said, there is nothing wrong with the code as of now and this
optimization could be added later (if at all).

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
