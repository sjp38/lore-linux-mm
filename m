Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 0EB346B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:55:34 -0400 (EDT)
Date: Tue, 26 Jun 2012 18:55:13 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH 04/16] mm: allow PF_MEMALLOC from softirq context
Message-ID: <20120626165513.GD6509@breakpoint.cc>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
 <1340375443-22455-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340375443-22455-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Fri, Jun 22, 2012 at 03:30:31PM +0100, Mel Gorman wrote:
> This is needed to allow network softirq packet processing to make
> use of PF_MEMALLOC.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b6c0727..5c6d9c6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2265,7 +2265,11 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
>  		if (gfp_mask & __GFP_MEMALLOC)
>  			alloc_flags |= ALLOC_NO_WATERMARKS;
> -		else if (likely(!(gfp_mask & __GFP_NOMEMALLOC)) && !in_interrupt())
> +		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
> +			alloc_flags |= ALLOC_NO_WATERMARKS;
> +		else if (!in_interrupt() &&
> +				((current->flags & PF_MEMALLOC) ||
> +				 unlikely(test_thread_flag(TIF_MEMDIE))))
>  			alloc_flags |= ALLOC_NO_WATERMARKS;
>  	}

You allocate in RX path with __GFP_MEMALLOC and your sk->sk_allocation has
also __GFP_MEMALLOC set. That means you should get ALLOC_NO_WATERMARKS in
alloc_flags. Is this to done to avoid GFP annotations in skb_share_check() and
friends on your __netif_receive_skb() path?

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
