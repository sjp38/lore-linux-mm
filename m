Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2443A9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 08:22:13 -0400 (EDT)
Date: Tue, 26 Apr 2011 22:21:57 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 09/13] netvm: Set PF_MEMALLOC as appropriate during SKB
 processing
Message-ID: <20110426222157.33a461f8@notabene.brown>
In-Reply-To: <1303803414-5937-10-git-send-email-mgorman@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
	<1303803414-5937-10-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, 26 Apr 2011 08:36:50 +0100 Mel Gorman <mgorman@suse.de> wrote:

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3871bf6..2d79a20 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3095,6 +3095,27 @@ static void vlan_on_bond_hook(struct sk_buff *skb)
>  	}
>  }
>  
> +/*
> + * Limit which protocols can use the PFMEMALLOC reserves to those that are
> + * expected to be used for communication with swap.
> + */
> +static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
> +{
> +	if (skb_pfmemalloc(skb))
> +		switch (skb->protocol) {
> +		case __constant_htons(ETH_P_ARP):
> +		case __constant_htons(ETH_P_IP):
> +		case __constant_htons(ETH_P_IPV6):
> +		case __constant_htons(ETH_P_8021Q):
> +			break;
> +
> +		default:
> +			return false;
> +		}
> +
> +	return true;
> +}

This sort of thing really bugs me :-)
Neither the comment nor the function name actually describe what the function
is doing.  The function is checking *2* things.
   is_pfmemalloc_skb_or_pfmemalloc_protocol()
might be a more correct name, but is too verbose.

I would prefer the skb_pfmemalloc test were removed from here and ....

> +	if (!skb_pfmemalloc_protocol(skb))
> +		goto drop;
> +

...added here so this becomes:

      if (!skb_pfmemalloc(skb) && !skb_pfmemalloc_protocol(skb))
                goto drop;

which actually makes sense.

Thanks,
NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
