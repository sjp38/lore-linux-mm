Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 739166B00DF
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 12:38:44 -0400 (EDT)
Received: by eaan1 with SMTP id n1so419872eaa.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 09:38:42 -0700 (PDT)
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20120621163029.GB6045@breakpoint.cc>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
	 <1340192652-31658-11-git-send-email-mgorman@suse.de>
	 <20120621163029.GB6045@breakpoint.cc>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Jun 2012 18:38:39 +0200
Message-ID: <1340296719.4604.5984.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Thu, 2012-06-21 at 18:30 +0200, Sebastian Andrzej Siewior wrote:
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 1d6ecc8..9a58dcc 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -167,14 +206,19 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
> >   *	%GFP_ATOMIC.
> >   */
> >  struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
> > -			    int fclone, int node)
> > +			    int flags, int node)
> >  {
> >  	struct kmem_cache *cache;
> >  	struct skb_shared_info *shinfo;
> >  	struct sk_buff *skb;
> >  	u8 *data;
> > +	bool pfmemalloc;
> >  
> > -	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
> > +	cache = (flags & SKB_ALLOC_FCLONE)
> > +		? skbuff_fclone_cache : skbuff_head_cache;
> > +
> > +	if (sk_memalloc_socks() && (flags & SKB_ALLOC_RX))
> > +		gfp_mask |= __GFP_MEMALLOC;
> >  
> >  	/* Get the HEAD */
> >  	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
> 
> This is mostly used by nic to refil their RX skb pool. You add the
> __GFP_MEMALLOC to the allocation to rise the change of a successfull refill
> for the swap case.
> A few drivers use build_skb() to create the skb. __netdev_alloc_skb()
> shouldn't be affected since the allocation happens with GFP_ATOMIC. Looking at
> TG3 it uses build_skb() and get_pages() / kmalloc(). Shouldn't this be some
> considered?

Please look at net-next, this was changed recently.

In fact most RX allocations are done using netdev_alloc_frag(), because
its called from __netdev_alloc_skb()

So tg3 is not anymore the exception, but the norm.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
