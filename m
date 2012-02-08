Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 5785F6B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 10:23:51 -0500 (EST)
Date: Wed, 8 Feb 2012 15:23:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/15] netvm: Propagate page->pfmemalloc from
 netdev_alloc_page to skb
Message-ID: <20120208152346.GJ5938@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
 <1328568978-17553-11-git-send-email-mgorman@suse.de>
 <4F31B604.5070401@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F31B604.5070401@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, Feb 07, 2012 at 03:38:44PM -0800, Alexander Duyck wrote:
> On 02/06/2012 02:56 PM, Mel Gorman wrote:
> > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> > index e91d73c..c062909 100644
> > --- a/drivers/net/ethernet/intel/igb/igb_main.c
> > +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> > @@ -6187,7 +6187,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
> >  		return true;
> >  
> >  	if (!page) {
> > -		page = alloc_page(GFP_ATOMIC | __GFP_COLD);
> > +		page = __netdev_alloc_page(GFP_ATOMIC, bi->skb);
> >  		bi->page = page;
> >  		if (unlikely(!page)) {
> >  			rx_ring->rx_stats.alloc_failed++;
> 
> This takes care of the case where we are allocating the page, but what
> about if we are reusing the page?

Then nothing... You're right, I did not consider that case.

> For this driver it might work better
> to hold of on doing the association between the page and skb either
> somewhere after the skb and the page have both been allocated, or in the
> igb_clean_rx_irq path where we will have both the page and the data
> accessible.

Again, from looking through the code you appear to be right. Thanks for
the suggestion!

> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > index 1ee5d0f..7a011c3 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > @@ -1143,7 +1143,7 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
> >  
> >  		if (ring_is_ps_enabled(rx_ring)) {
> >  			if (!bi->page) {
> > -				bi->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
> > +				bi->page = __netdev_alloc_page(GFP_ATOMIC, skb);
> >  				if (!bi->page) {
> >  					rx_ring->rx_stats.alloc_rx_page_failed++;
> >  					goto no_buffers;
> 
> Same thing for this driver.
> > diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > index bed411b..f6ea14a 100644
> > --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > @@ -366,7 +366,7 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
> >  		if (!bi->page_dma &&
> >  		    (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
> >  			if (!bi->page) {
> > -				bi->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
> > +				bi->page = __netdev_alloc_page(GFP_ATOMIC, NULL);
> >  				if (!bi->page) {
> >  					adapter->alloc_rx_page_failed++;
> >  					goto no_buffers;
> > @@ -400,6 +400,7 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
> >  			 */
> >  			skb_reserve(skb, NET_IP_ALIGN);
> >  
> > +			propagate_pfmemalloc_skb(bi->page_dma, skb);
> >  			bi->skb = skb;
> >  		}
> >  		if (!bi->dma) {
>
> I am pretty sure this is incorrect.  I believe you want bi->page, not
> bi->page_dma.  This one is closer though to what I had in mind for igb
> and ixgbe in terms of making it so there is only one location that
> generates the association.
> 

You are on a roll of being right.

> Also a similar changes would be needed for the igbvf , e1000, and e1000e
> drivers in the Intel tree.
> 
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 17ed022..8da4ca0 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -1696,6 +1696,44 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
> >  }
> >  
> >  /**
> > + *	__netdev_alloc_page - allocate a page for ps-rx on a specific device
> > + *	@gfp_mask: alloc_pages_node mask. Set __GFP_NOMEMALLOC if not for network packet RX
> > + *	@skb: skb to set pfmemalloc on if __GFP_MEMALLOC is used
> > + *
> > + * 	Allocate a new page. dev currently unused.
> > + *
> > + * 	%NULL is returned if there is no free memory.
> > + */
> > +static inline struct page *__netdev_alloc_page(gfp_t gfp_mask,
> > +						struct sk_buff *skb)
> > +{
> > +	struct page *page;
> > +
> > +	gfp_mask |= __GFP_COLD;
> > +
> > +	if (!(gfp_mask & __GFP_NOMEMALLOC))
> > +		gfp_mask |= __GFP_MEMALLOC;
> > +
> > +	page = alloc_pages_node(NUMA_NO_NODE, gfp_mask, 0);
> > +	if (skb && page && page->pfmemalloc)
> > +		skb->pfmemalloc = true;
> > +
> > +	return page;
> > +}
> > +
> > +/**
> > + *	propagate_pfmemalloc_skb - Propagate pfmemalloc if skb is allocated after RX page
> > + *	@page: The page that was allocated from netdev_alloc_page
> > + *	@skb: The skb that may need pfmemalloc set
> > + */
> > +static inline void propagate_pfmemalloc_skb(struct page *page,
> > +						struct sk_buff *skb)
> > +{
> > +	if (page && page->pfmemalloc)
> > +		skb->pfmemalloc = true;
> > +}
> > +
> > +/**
> >   * skb_frag_page - retrieve the page refered to by a paged fragment
> >   * @frag: the paged fragment
> >   *
> 
> Is this function even really needed? 

It's not *really* needed. As noted in the changelog, getting this wrong
has minor consequences. At worst, swap becomes a little slower but it
should not result in hangs.

> It seems like you already have
> this covered in your earlier patches, specifically 9/15, which takes
> care of associating the skb and the page pfmemalloc flags when you use
> skb_fill_page_desc. 

Yes, this patch was an attempt to being thorough but the actual impact
is moving a bunch of complexity into drivers where it is difficult to
test and of marginal benefit.

> It would be useful to narrow things down so that we
> are associating this either at the allocation time or at the
> fill_page_desc call instead of doing it at both.
> 

I think you're right. I'm going to drop this patch entirely as the
benfit is marginal and not necessary for swap over network to work.

Thanks very much for the review.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
