Date: Tue, 8 Aug 2006 23:17:32 +0200
From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Message-ID: <20060808211731.GR14627@postel.suug.ch>
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193345.1396.16773.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060808193345.1396.16773.sendpatchset@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <a.p.zijlstra@chello.nl> 2006-08-08 21:33
> +struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
> +		unsigned length, gfp_t gfp_mask)
> +{
> +	struct sk_buff *skb;
> +
> +	if (dev && (dev->flags & IFF_MEMALLOC)) {
> +		WARN_ON(gfp_mask & (__GFP_NOMEMALLOC | __GFP_MEMALLOC));
> +		gfp_mask &= ~(__GFP_NOMEMALLOC | __GFP_MEMALLOC);
> +
> +		if ((skb = ___netdev_alloc_skb(dev, length,
> +					       gfp_mask | __GFP_NOMEMALLOC)))
> +			goto done;
> +		if (dev_reserve_used(dev) >= dev->rx_reserve)
> +			goto out;
> +		if (!(skb = ___netdev_alloc_skb(dev, length,
> +						gfp_mask | __GFP_MEMALLOC)))
> +			goto out;
> +		atomic_inc(&dev->rx_reserve_used);
> +	} else
> +		if (!(skb = ___netdev_alloc_skb(dev, length, gfp_mask)))
> +			goto out;
> +
> +done:
> +	skb->dev = dev;
> +out:
> +	return skb;
> +}
> +

>  void __kfree_skb(struct sk_buff *skb)
>  {
> +	struct net_device *dev = skb->dev;
> +
>  	dst_release(skb->dst);
>  #ifdef CONFIG_XFRM
>  	secpath_put(skb->sp);
> @@ -389,6 +480,8 @@ void __kfree_skb(struct sk_buff *skb)
>  #endif
>  
>  	kfree_skbmem(skb);
> +	if (dev && (dev->flags & IFF_MEMALLOC))
> +		dev_unreserve_skb(dev);
>  }

skb->dev is not guaranteed to still point to the "allocating" device
once the skb is freed again so reserve/unreserve isn't symmetric.
You'd need skb->alloc_dev or something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
