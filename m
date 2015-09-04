Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 85C346B0256
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 14:47:18 -0400 (EDT)
Received: by iofb144 with SMTP id b144so34029196iof.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 11:47:18 -0700 (PDT)
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com. [209.85.223.178])
        by mx.google.com with ESMTPS id b2si3322207igb.24.2015.09.04.11.47.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 11:47:17 -0700 (PDT)
Received: by iofh134 with SMTP id h134so33964531iof.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 11:47:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150904170046.4312.38018.stgit@devil>
References: <20150904165944.4312.32435.stgit@devil>
	<20150904170046.4312.38018.stgit@devil>
Date: Fri, 4 Sep 2015 11:47:17 -0700
Message-ID: <CALx6S36R2zGwj5XF0GZWPOC1Ng5HviPWxBM-cn=DDMXU9Auoxg@mail.gmail.com>
Subject: Re: [RFC PATCH 1/3] net: introduce kfree_skb_bulk() user of kmem_cache_free_bulk()
From: Tom Herbert <tom@herbertland.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, aravinda@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com

On Fri, Sep 4, 2015 at 10:00 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> Introduce the first user of SLAB bulk free API kmem_cache_free_bulk(),
> in the network stack in form of function kfree_skb_bulk() which bulk
> free SKBs (not skb clones or skb->head, yet).
>
> As this is the third user of SKB reference decrementing, split out
> refcnt decrement into helper function and use this in all call points.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  include/linux/skbuff.h |    1 +
>  net/core/skbuff.c      |   87 +++++++++++++++++++++++++++++++++++++++---------
>  2 files changed, 71 insertions(+), 17 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index b97597970ce7..e5f1e007723b 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -762,6 +762,7 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
>  }
>
>  void kfree_skb(struct sk_buff *skb);
> +void kfree_skb_bulk(struct sk_buff **skbs, unsigned int size);
>  void kfree_skb_list(struct sk_buff *segs);
>  void skb_tx_error(struct sk_buff *skb);
>  void consume_skb(struct sk_buff *skb);
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 429b407b4fe6..034545934158 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -661,26 +661,83 @@ void __kfree_skb(struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL(__kfree_skb);
>
> +/*
> + *     skb_dec_and_test - Helper to drop ref to SKB and see is ready to free
> + *     @skb: buffer to decrement reference
> + *
> + *     Drop a reference to the buffer, and return true if it is ready
> + *     to free. Which is if the usage count has hit zero or is equal to 1.
> + *
> + *     This is performance critical code that should be inlined.
> + */
> +static inline bool skb_dec_and_test(struct sk_buff *skb)
> +{
> +       if (unlikely(!skb))
> +               return false;
> +       if (likely(atomic_read(&skb->users) == 1))
> +               smp_rmb();
> +       else if (likely(!atomic_dec_and_test(&skb->users)))
> +               return false;
> +       /* If reaching here SKB is ready to free */
> +       return true;
> +}
> +
>  /**
>   *     kfree_skb - free an sk_buff
>   *     @skb: buffer to free
>   *
>   *     Drop a reference to the buffer and free it if the usage count has
> - *     hit zero.
> + *     hit zero or is equal to 1.
>   */
>  void kfree_skb(struct sk_buff *skb)
>  {
> -       if (unlikely(!skb))
> -               return;
> -       if (likely(atomic_read(&skb->users) == 1))
> -               smp_rmb();
> -       else if (likely(!atomic_dec_and_test(&skb->users)))
> -               return;
> -       trace_kfree_skb(skb, __builtin_return_address(0));
> -       __kfree_skb(skb);
> +       if (skb_dec_and_test(skb)) {
> +               trace_kfree_skb(skb, __builtin_return_address(0));
> +               __kfree_skb(skb);
> +       }
>  }
>  EXPORT_SYMBOL(kfree_skb);
>
> +/**
> + *     kfree_skb_bulk - bulk free SKBs when refcnt allows to
> + *     @skbs: array of SKBs to free
> + *     @size: number of SKBs in array
> + *
> + *     If SKB refcnt allows for free, then release any auxiliary data
> + *     and then bulk free SKBs to the SLAB allocator.
> + *
> + *     Note that interrupts must be enabled when calling this function.
> + */
> +void kfree_skb_bulk(struct sk_buff **skbs, unsigned int size)
> +{
What not pass a list of skbs (e.g. using skb->next)?

> +       int i;
> +       size_t cnt = 0;
> +
> +       for (i = 0; i < size; i++) {
> +               struct sk_buff *skb = skbs[i];
> +
> +               if (!skb_dec_and_test(skb))
> +                       continue; /* skip skb, not ready to free */
> +
> +               /* Construct an array of SKBs, ready to be free'ed and
> +                * cleanup all auxiliary, before bulk free to SLAB.
> +                * For now, only handle non-cloned SKBs, related to
> +                * SLAB skbuff_head_cache
> +                */
> +               if (skb->fclone == SKB_FCLONE_UNAVAILABLE) {
> +                       skb_release_all(skb);
> +                       skbs[cnt++] = skb;
> +               } else {
> +                       /* SKB was a clone, don't handle this case */
> +                       __kfree_skb(skb);
> +               }
> +       }
> +       if (likely(cnt)) {
> +               kmem_cache_free_bulk(skbuff_head_cache, cnt, (void **) skbs);
> +       }
> +}
> +EXPORT_SYMBOL(kfree_skb_bulk);
> +
>  void kfree_skb_list(struct sk_buff *segs)
>  {
>         while (segs) {
> @@ -722,14 +779,10 @@ EXPORT_SYMBOL(skb_tx_error);
>   */
>  void consume_skb(struct sk_buff *skb)
>  {
> -       if (unlikely(!skb))
> -               return;
> -       if (likely(atomic_read(&skb->users) == 1))
> -               smp_rmb();
> -       else if (likely(!atomic_dec_and_test(&skb->users)))
> -               return;
> -       trace_consume_skb(skb);
> -       __kfree_skb(skb);
> +       if (skb_dec_and_test(skb)) {
> +               trace_consume_skb(skb);
> +               __kfree_skb(skb);
> +       }
>  }
>  EXPORT_SYMBOL(consume_skb);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
