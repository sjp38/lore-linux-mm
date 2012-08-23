Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 6266B6B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 10:28:06 -0400 (EDT)
Date: Thu, 23 Aug 2012 10:17:40 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] netvm: check for page == NULL when propogating the
 skb->pfmemalloc flag
Message-ID: <20120823141740.GA30305@phenom.dumpdata.com>
References: <20120807085554.GF29814@suse.de>
 <20120808.155046.820543563969484712.davem@davemloft.net>
 <1345631207.6821.140.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345631207.6821.140.camel@zakaz.uk.xensource.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Cc: David Miller <davem@davemloft.net>, "mgorman@suse.de" <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "konrad@darnok.org" <konrad@darnok.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, Aug 22, 2012 at 11:26:47AM +0100, Ian Campbell wrote:
> On Wed, 2012-08-08 at 23:50 +0100, David Miller wrote:
> > Just use something like a call to __pskb_pull_tail(skb, len) and all
> > that other crap around that area can simply be deleted.
> 
> I think you mean something like this, which works for me, although I've
> only lightly tested it.
> 

I've tested it heavily and works great.

Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
and I took a look at it too and:

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Ian.
> 
> 8<----------------------------------------
> 
> >From 9e47e3e87a33b45974448649a97859a479183041 Mon Sep 17 00:00:00 2001
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Wed, 22 Aug 2012 10:15:29 +0100
> Subject: [PATCH] xen-netfront: use __pskb_pull_tail to ensure linear area is big enough on RX
> 
> I'm slightly concerned by the "only in exceptional circumstances"
> comment on __pskb_pull_tail but the structure of an skb just created
> by netfront shouldn't hit any of the especially slow cases.
> 
> This approach still does slightly more work than the old way, since if
> we pull up the entire first frag we now have to shuffle everything
> down where before we just received into the right place in the first
> place.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: xen-devel@lists.xensource.com
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/xen-netfront.c |   39 ++++++++++-----------------------------
>  1 files changed, 10 insertions(+), 29 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 3089990..650f79a 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -57,8 +57,7 @@
>  static const struct ethtool_ops xennet_ethtool_ops;
>  
>  struct netfront_cb {
> -	struct page *page;
> -	unsigned offset;
> +	int pull_to;
>  };
>  
>  #define NETFRONT_SKB_CB(skb)	((struct netfront_cb *)((skb)->cb))
> @@ -867,15 +866,9 @@ static int handle_incoming_queue(struct net_device *dev,
>  	struct sk_buff *skb;
>  
>  	while ((skb = __skb_dequeue(rxq)) != NULL) {
> -		struct page *page = NETFRONT_SKB_CB(skb)->page;
> -		void *vaddr = page_address(page);
> -		unsigned offset = NETFRONT_SKB_CB(skb)->offset;
> -
> -		memcpy(skb->data, vaddr + offset,
> -		       skb_headlen(skb));
> +		int pull_to = NETFRONT_SKB_CB(skb)->pull_to;
>  
> -		if (page != skb_frag_page(&skb_shinfo(skb)->frags[0]))
> -			__free_page(page);
> +		__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
>  
>  		/* Ethernet work: Delayed to here as it peeks the header. */
>  		skb->protocol = eth_type_trans(skb, dev);
> @@ -913,7 +906,6 @@ static int xennet_poll(struct napi_struct *napi, int budget)
>  	struct sk_buff_head errq;
>  	struct sk_buff_head tmpq;
>  	unsigned long flags;
> -	unsigned int len;
>  	int err;
>  
>  	spin_lock(&np->rx_lock);
> @@ -955,24 +947,13 @@ err:
>  			}
>  		}
>  
> -		NETFRONT_SKB_CB(skb)->page =
> -			skb_frag_page(&skb_shinfo(skb)->frags[0]);
> -		NETFRONT_SKB_CB(skb)->offset = rx->offset;
> -
> -		len = rx->status;
> -		if (len > RX_COPY_THRESHOLD)
> -			len = RX_COPY_THRESHOLD;
> -		skb_put(skb, len);
> +		NETFRONT_SKB_CB(skb)->pull_to = rx->status;
> +		if (NETFRONT_SKB_CB(skb)->pull_to > RX_COPY_THRESHOLD)
> +			NETFRONT_SKB_CB(skb)->pull_to = RX_COPY_THRESHOLD;
>  
> -		if (rx->status > len) {
> -			skb_shinfo(skb)->frags[0].page_offset =
> -				rx->offset + len;
> -			skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx->status - len);
> -			skb->data_len = rx->status - len;
> -		} else {
> -			__skb_fill_page_desc(skb, 0, NULL, 0, 0);
> -			skb_shinfo(skb)->nr_frags = 0;
> -		}
> +		skb_shinfo(skb)->frags[0].page_offset = rx->offset;
> +		skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx->status);
> +		skb->data_len = rx->status;
>  
>  		i = xennet_fill_frags(np, skb, &tmpq);
>  
> @@ -999,7 +980,7 @@ err:
>  		 * receive throughout using the standard receive
>  		 * buffer size was cut by 25%(!!!).
>  		 */
> -		skb->truesize += skb->data_len - (RX_COPY_THRESHOLD - len);
> +		skb->truesize += skb->data_len - RX_COPY_THRESHOLD;
>  		skb->len += skb->data_len;
>  
>  		if (rx->flags & XEN_NETRXF_csum_blank)
> -- 
> 1.7.2.5
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
