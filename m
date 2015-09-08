Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id F07C66B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 17:01:13 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so49122843pad.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 14:01:13 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id tf1si2592036pac.5.2015.09.08.14.01.12
        for <linux-mm@kvack.org>;
        Tue, 08 Sep 2015 14:01:13 -0700 (PDT)
Date: Tue, 08 Sep 2015 14:01:10 -0700 (PDT)
Message-Id: <20150908.140110.899240065088272758.davem@davemloft.net>
Subject: Re: [RFC PATCH 1/3] net: introduce kfree_skb_bulk() user of
 kmem_cache_free_bulk()
From: David Miller <davem@davemloft.net>
In-Reply-To: <20150904170046.4312.38018.stgit@devil>
References: <20150904165944.4312.32435.stgit@devil>
	<20150904170046.4312.38018.stgit@devil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: brouer@redhat.com
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, aravinda@linux.vnet.ibm.com, cl@linux.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 04 Sep 2015 19:00:53 +0200

> +/**
> + *	kfree_skb_bulk - bulk free SKBs when refcnt allows to
> + *	@skbs: array of SKBs to free
> + *	@size: number of SKBs in array
> + *
> + *	If SKB refcnt allows for free, then release any auxiliary data
> + *	and then bulk free SKBs to the SLAB allocator.
> + *
> + *	Note that interrupts must be enabled when calling this function.
> + */
> +void kfree_skb_bulk(struct sk_buff **skbs, unsigned int size)
> +{
> +	int i;
> +	size_t cnt = 0;
> +
> +	for (i = 0; i < size; i++) {
> +		struct sk_buff *skb = skbs[i];
> +
> +		if (!skb_dec_and_test(skb))
> +			continue; /* skip skb, not ready to free */
> +
> +		/* Construct an array of SKBs, ready to be free'ed and
> +		 * cleanup all auxiliary, before bulk free to SLAB.
> +		 * For now, only handle non-cloned SKBs, related to
> +		 * SLAB skbuff_head_cache
> +		 */
> +		if (skb->fclone == SKB_FCLONE_UNAVAILABLE) {
> +			skb_release_all(skb);
> +			skbs[cnt++] = skb;
> +		} else {
> +			/* SKB was a clone, don't handle this case */
> +			__kfree_skb(skb);
> +		}
> +	}
> +	if (likely(cnt)) {
> +		kmem_cache_free_bulk(skbuff_head_cache, cnt, (void **) skbs);
> +	}
> +}

You're going to have to do a trace_kfree_skb() or trace_consume_skb() for
these things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
