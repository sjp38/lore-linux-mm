Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DAEEE6B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 07:45:23 -0400 (EDT)
Date: Tue, 3 May 2011 12:45:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/13] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20110503114513.GA9033@suse.de>
References: <1303920491-25302-1-git-send-email-mgorman@suse.de>
 <1303920491-25302-9-git-send-email-mgorman@suse.de>
 <20110428161933.1f1266e6@notabene.brown>
 <20110428100035.GO4658@suse.de>
 <20110428204755.2e07147e@notabene.brown>
 <20110428111854.GV4658@suse.de>
 <20110429125531.22f6e8f1@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110429125531.22f6e8f1@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Apr 29, 2011 at 12:55:31PM +1000, NeilBrown wrote:
> On Thu, 28 Apr 2011 12:18:54 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Thu, Apr 28, 2011 at 08:47:55PM +1000, NeilBrown wrote:
> > > On Thu, 28 Apr 2011 11:05:06 +0100 Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > On Thu, Apr 28, 2011 at 04:19:33PM +1000, NeilBrown wrote:
> > > > > On Wed, 27 Apr 2011 17:08:06 +0100 Mel Gorman <mgorman@suse.de> wrote:
> > > > > 
> > > > > 
> > > > > > @@ -1578,7 +1589,7 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
> > > > > >   */
> > > > > >  static inline struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
> > > > > >  {
> > > > > > -	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, 0);
> > > > > > +	return alloc_pages_node(NUMA_NO_NODE, gfp_mask | __GFP_MEMALLOC, 0);
> > > > > >  }
> > > > > >  
> > > > > 
> > > > > I'm puzzling a bit over this change.
> > > > > __netdev_alloc_page appears to be used to get pages to put in ring buffer
> > > > > for a network card to DMA received packets into.  So it is OK to use
> > > > > __GFP_MEMALLOC for these allocations providing we mark the resulting skb as
> > > > > 'pfmemalloc' if a reserved page was used.
> > > > > 
> > > > > However I don't see where that marking is done.
> > > > > I think it should be in skb_fill_page_desc, something like:
> > > > > 
> > > > >   if (page->pfmemalloc)
> > > > > 	skb->pfmemalloc = true;
> > > > > 
> > > > > Is this covered somewhere else that I am missing?
> > > > > 
> > > > 
> > > > You're not missing anything.
> > > > 
> > > > >From the context of __netdev_alloc_page, we do not know if the skb
> > > > is suitable for marking pfmemalloc or not (we don't have SKB_ALLOC_RX
> > > > flag for example that __alloc_skb has). The reserves are potentially
> > > > being dipped into for an unsuitable packet but it gets dropped in
> > > > __netif_receive_skb() and the memory is returned. If we mark the skb
> > > > pfmemalloc as a result of __netdev_alloc_page using a reserve page, the
> > > > packets would not get dropped as expected.
> > > > 
> > > 
> > > The only code in __netif_receive_skb that seems to drop packets is
> > > 
> > > +	if (skb_pfmemalloc(skb) && !skb_pfmemalloc_protocol(skb))
> > > +		goto drop;
> > > +
> > > 
> > > which requires that the skb have pfmemalloc set before it will be dropped.
> > > 
> > 
> > Yes, I only wanted to drop the packet if we were under pressure
> > when skb was allocated. If we hit pressure between when skb was
> > allocated and when __netdev_alloc_page is called, then the PFMEMALLOC
> > reserves may be used for packet receive unnecessarily but the next skb
> > allocation that grows slab will have the flag set appropriately. There
> > is a window during which we use reserves where we did not have to
> > but it's limited. Again, the throttling if pfmemalloc reserves gets too
> > depleted comes into play.
> 
> I don't find this very convincing...
> It seems inconsistent that you are doing precise accounting inside slab so
> that you know which object used reserved memory and which did not, yet you
> get sloppy with the accounting of whole pages on network receive.
> 

Being more precise about accounting how memory was used in the memory
subsystem rather than the network subsystem didn't seem totally
unreasonable.

> Is there a clear upper bound on how many reserve pages could slip into
> non-reserve skbs before skbs start getting the pfmalloc flag set?
> 

nr_objects_per_slab-1 pages should be the upper bound. i.e. the most
objects that can fit in a partial slab that is managing packets. The
exact value would depend on whether SLUB is used (high order pages) and
what the page size is.

> I just think it is safer to mark an skb as pfmalloc if any part of the memory
> associated with it came from reserves.
> 

I see the point of your concerns and I'll investigate closer if propagating
the pfmemalloc flag to the socket if the page was allocated from reserves
both makes sense and works as expected.

> Also I find the throttling argument hard to reason about.  Certainly
> some things get throttles, but incoming packets don't...
> 

We can't prevent incoming packets and we do not know at allocation
time if the packet can be dropped so there are limited throttling
options there.

> I'm certainly not saying that the code is clearly wrong, but I'm having
> trouble convincing myself that it is clearly right (or at least 'safe').
> 

-- 
Mel Gorman
SUSE Labs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
