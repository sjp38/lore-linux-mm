Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 3F2D36B015F
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 06:00:38 -0400 (EDT)
Date: Fri, 22 Jun 2012 11:00:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20120622100032.GB8271@suse.de>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
 <1340192652-31658-11-git-send-email-mgorman@suse.de>
 <20120621160902.GA6045@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120621160902.GA6045@breakpoint.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Thu, Jun 21, 2012 at 06:09:02PM +0200, Sebastian Andrzej Siewior wrote:
> > <SNIP>
> >
> If merge this chunk
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 6510a5d..2acfec9 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -510,7 +510,7 @@ struct sk_buff {
>  #define SKB_ALLOC_RX		0x02
>  
>  /* Returns true if the skb was allocated from PFMEMALLOC reserves */
> -static inline bool skb_pfmemalloc(struct sk_buff *skb)
> +static inline bool skb_pfmemalloc(const struct sk_buff *skb)
>  {
>  	return unlikely(skb->pfmemalloc);
>  }
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index c44ab68..6ce94b5 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -852,7 +852,7 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>  
>  static inline int skb_alloc_rx_flag(const struct sk_buff *skb)
>  {
> -	if (skb_pfmemalloc((struct sk_buff *)skb))
> +	if (skb_pfmemalloc(skb))
>  		return SKB_ALLOC_RX;
>  	return 0;
>  }
> 
> 
> Then you should be able to drop the case in skb_alloc_rx_flag() without adding
> a warning.
> 

You're right. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
