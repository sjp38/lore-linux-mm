Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 803666B004D
	for <linux-mm@kvack.org>; Fri, 11 May 2012 00:57:46 -0400 (EDT)
Date: Fri, 11 May 2012 00:57:40 -0400 (EDT)
Message-Id: <20120511.005740.210437168371869566.davem@davemloft.net>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
From: David Miller <davem@davemloft.net>
In-Reply-To: <1336657510-24378-11-git-send-email-mgorman@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
	<1336657510-24378-11-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 10 May 2012 14:45:03 +0100

> +/* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
> +bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);

I know this gets added in an earlier patch, but it seems slightly
overkill to have a function call just for a simply bit test.

> +extern atomic_t memalloc_socks;
> +static inline int sk_memalloc_socks(void)
> +{
> +	return atomic_read(&memalloc_socks);
> +}

Please change this to be a static branch.

> +	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
> +						SKB_ALLOC_RX, NUMA_NO_NODE);

Please fix the argument indentation.

> +	data = kmalloc_reserve(size + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
> +		       gfp_mask, NUMA_NO_NODE, NULL);

Likewise.

> -	struct sk_buff *n = alloc_skb(newheadroom + skb->len + newtailroom,
> -				      gfp_mask);
> +	struct sk_buff *n = __alloc_skb(newheadroom + skb->len + newtailroom,
> +				      gfp_mask, skb_alloc_rx_flag(skb),
> +				      NUMA_NO_NODE);

Likewise.

> -			nskb = alloc_skb(hsize + doffset + headroom,
> -					 GFP_ATOMIC);
> +			nskb = __alloc_skb(hsize + doffset + headroom,
> +					 GFP_ATOMIC, skb_alloc_rx_flag(skb),
> +					 NUMA_NO_NODE);

Likewise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
