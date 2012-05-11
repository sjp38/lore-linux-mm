Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 559D58D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 10:32:24 -0400 (EDT)
Date: Fri, 11 May 2012 15:32:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20120511143218.GS11435@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
 <1336657510-24378-11-git-send-email-mgorman@suse.de>
 <20120511.005740.210437168371869566.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120511.005740.210437168371869566.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

On Fri, May 11, 2012 at 12:57:40AM -0400, David Miller wrote:
> From: Mel Gorman <mgorman@suse.de>
> Date: Thu, 10 May 2012 14:45:03 +0100
> 
> > +/* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
> > +bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);
> 
> I know this gets added in an earlier patch, but it seems slightly
> overkill to have a function call just for a simply bit test.
> 

It's not that simple. gfp_pfmemalloc_allowed calls gfp_to_alloc_flags()
which is quite involved and probably should not be duplicated. In the slab
case, it's called from slow paths where we are already under memory pressure
and swapping to network so it's not a major problem. In the network case,
it is called when kmalloc() has already failed and also a slow path.

> > +extern atomic_t memalloc_socks;
> > +static inline int sk_memalloc_socks(void)
> > +{
> > +	return atomic_read(&memalloc_socks);
> > +}
> 
> Please change this to be a static branch.
> 

Will do. I renamed memalloc_socks to sk_memalloc_socks, made it a int as
atomics are unnecessary and I check it directly in a branch instead of a
static inline. It should be relatively easy for the branch predictor.

> > +	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
> > +						SKB_ALLOC_RX, NUMA_NO_NODE);
> 
> Please fix the argument indentation.
> 

Done.

> > +	data = kmalloc_reserve(size + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
> > +		       gfp_mask, NUMA_NO_NODE, NULL);
> 
> Likewise.

Done

> 
> > -	struct sk_buff *n = alloc_skb(newheadroom + skb->len + newtailroom,
> > -				      gfp_mask);
> > +	struct sk_buff *n = __alloc_skb(newheadroom + skb->len + newtailroom,
> > +				      gfp_mask, skb_alloc_rx_flag(skb),
> > +				      NUMA_NO_NODE);
> 
> Likewise.
> 

Done.

> > -			nskb = alloc_skb(hsize + doffset + headroom,
> > -					 GFP_ATOMIC);
> > +			nskb = __alloc_skb(hsize + doffset + headroom,
> > +					 GFP_ATOMIC, skb_alloc_rx_flag(skb),
> > +					 NUMA_NO_NODE);
> 
> Likewise.

Done.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
