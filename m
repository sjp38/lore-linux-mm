Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 548CE6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 06:48:08 -0400 (EDT)
Date: Thu, 28 Apr 2011 20:47:55 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 08/13] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20110428204755.2e07147e@notabene.brown>
In-Reply-To: <20110428100035.GO4658@suse.de>
References: <1303920491-25302-1-git-send-email-mgorman@suse.de>
	<1303920491-25302-9-git-send-email-mgorman@suse.de>
	<20110428161933.1f1266e6@notabene.brown>
	<20110428100035.GO4658@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Thu, 28 Apr 2011 11:05:06 +0100 Mel Gorman <mgorman@suse.de> wrote:

> On Thu, Apr 28, 2011 at 04:19:33PM +1000, NeilBrown wrote:
> > On Wed, 27 Apr 2011 17:08:06 +0100 Mel Gorman <mgorman@suse.de> wrote:
> > 
> > 
> > > @@ -1578,7 +1589,7 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
> > >   */
> > >  static inline struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
> > >  {
> > > -	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, 0);
> > > +	return alloc_pages_node(NUMA_NO_NODE, gfp_mask | __GFP_MEMALLOC, 0);
> > >  }
> > >  
> > 
> > I'm puzzling a bit over this change.
> > __netdev_alloc_page appears to be used to get pages to put in ring buffer
> > for a network card to DMA received packets into.  So it is OK to use
> > __GFP_MEMALLOC for these allocations providing we mark the resulting skb as
> > 'pfmemalloc' if a reserved page was used.
> > 
> > However I don't see where that marking is done.
> > I think it should be in skb_fill_page_desc, something like:
> > 
> >   if (page->pfmemalloc)
> > 	skb->pfmemalloc = true;
> > 
> > Is this covered somewhere else that I am missing?
> > 
> 
> You're not missing anything.
> 
> >From the context of __netdev_alloc_page, we do not know if the skb
> is suitable for marking pfmemalloc or not (we don't have SKB_ALLOC_RX
> flag for example that __alloc_skb has). The reserves are potentially
> being dipped into for an unsuitable packet but it gets dropped in
> __netif_receive_skb() and the memory is returned. If we mark the skb
> pfmemalloc as a result of __netdev_alloc_page using a reserve page, the
> packets would not get dropped as expected.
> 

The only code in __netif_receive_skb that seems to drop packets is

+	if (skb_pfmemalloc(skb) && !skb_pfmemalloc_protocol(skb))
+		goto drop;
+

which requires that the skb have pfmemalloc set before it will be dropped.

Actually ... I'm expecting to find code that says:
   if (skb_pfmalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
	drop_packet();

but I cannot find it.  Where is the code that discard pfmalloc packets for
non-memalloc sockets?

I can see similar code in sk_filter but that doesn't drop the packet, it just
avoids filtering it.

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
