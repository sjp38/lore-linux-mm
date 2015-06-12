Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2ED6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 05:36:55 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so12915352wiw.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 02:36:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ds10si2412367wib.15.2015.06.12.02.36.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Jun 2015 02:36:54 -0700 (PDT)
Message-ID: <557AA834.8070503@suse.cz>
Date: Fri, 12 Jun 2015 11:36:52 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
In-Reply-To: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>, netdev@vger.kernel.org
Cc: davem@davemloft.net, Kernel-team@fb.com, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com, Eric Dumazet <edumazet@google.com>

On 06/12/2015 01:50 AM, Shaohua Li wrote:
> We saw excessive direct memory compaction triggered by skb_page_frag_refill.
> This causes performance issues and add latency. Commit 5640f7685831e0
> introduces the order-3 allocation. According to the changelog, the order-3
> allocation isn't a must-have but to improve performance. But direct memory
> compaction has high overhead. The benefit of order-3 allocation can't
> compensate the overhead of direct memory compaction.
>
> This patch makes the order-3 page allocation atomic. If there is no memory
> pressure and memory isn't fragmented, the alloction will still success, so we
> don't sacrifice the order-3 benefit here. If the atomic allocation fails,
> direct memory compaction will not be triggered, skb_page_frag_refill will
> fallback to order-0 immediately, hence the direct memory compaction overhead is
> avoided. In the allocation failure case, kswapd is waken up and doing
> compaction, so chances are allocation could success next time.
>
> alloc_skb_with_frags is the same.
>
> The mellanox driver does similar thing, if this is accepted, we must fix
> the driver too.
>
> V3: fix the same issue in alloc_skb_with_frags as pointed out by Eric
> V2: make the changelog clearer
>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Chris Mason <clm@fb.com>
> Cc: Debabrata Banerjee <dbavatar@gmail.com>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   net/core/skbuff.c | 2 +-
>   net/core/sock.c   | 2 +-
>   2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3cfff2a..41ec022 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4398,7 +4398,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
>
>   		while (order) {
>   			if (npages >= 1 << order) {
> -				page = alloc_pages(gfp_mask |
> +				page = alloc_pages((gfp_mask & ~__GFP_WAIT) |
>   						   __GFP_COMP |
>   						   __GFP_NOWARN |
>   						   __GFP_NORETRY,

Note that __GFP_NORETRY is weaker than ~__GFP_WAIT and thus redundant. 
But it won't hurt anything leaving it there. And you might consider 
__GFP_NO_KSWAPD instead, as I said in the other thread.

> diff --git a/net/core/sock.c b/net/core/sock.c
> index 292f422..e9855a4 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
>
>   	pfrag->offset = 0;
>   	if (SKB_FRAG_PAGE_ORDER) {
> -		pfrag->page = alloc_pages(gfp | __GFP_COMP |
> +		pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
>   					  __GFP_NOWARN | __GFP_NORETRY,
>   					  SKB_FRAG_PAGE_ORDER);
>   		if (likely(pfrag->page)) {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
