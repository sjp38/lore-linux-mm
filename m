Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 59D266B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 19:38:25 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so2229951igb.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 16:38:25 -0700 (PDT)
Received: from mail-ie0-x243.google.com (mail-ie0-x243.google.com. [2607:f8b0:4001:c03::243])
        by mx.google.com with ESMTPS id pg9si1906584icb.5.2015.06.11.16.38.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 16:38:24 -0700 (PDT)
Received: by iebtr6 with SMTP id tr6so6082561ieb.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 16:38:24 -0700 (PDT)
Message-ID: <1434065902.27504.64.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [RFC v2] net: use atomic allocation for order-3 page allocation
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Jun 2015 16:38:22 -0700
In-Reply-To: <20150611233235.GA667489@devbig257.prn2.facebook.com>
References: 
	<71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
	 <1434063184.27504.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150611233235.GA667489@devbig257.prn2.facebook.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com, Eric Dumazet <edumazet@google.com>

On Thu, 2015-06-11 at 16:32 -0700, Shaohua Li wrote:

> 
> Ok, looks similar, added. Didn't trigger this one though.

Probably because you do not use af_unix with big enough messages.

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3cfff2a..9856c7a 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4398,7 +4398,9 @@ struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
>  
>  		while (order) {
>  			if (npages >= 1 << order) {
> -				page = alloc_pages(gfp_mask |

Here, order is > 0 (Look at while (order) right above) 

> +				gfp_t gfp = order > 0 ?
> +					gfp_mask & ~__GFP_WAIT : gfp_mask;
> +				page = alloc_pages(gfp |
>  						   __GFP_COMP |
>  						   __GFP_NOWARN |



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
