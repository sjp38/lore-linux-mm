Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1Imyew-0006VU-HZ
	for linux-mm@kvack.org; Tue, 30 Oct 2007 21:30:02 +0000
Received: from 069-064-229-129.pdx.net ([69.64.229.129])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 30 Oct 2007 21:30:02 +0000
Received: from shemminger by 069-064-229-129.pdx.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 30 Oct 2007 21:30:02 +0000
From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 23/33] netvm: skb processing
Date: Tue, 30 Oct 2007 14:26:34 -0700
Message-ID: <20071030142634.0f00b492@freepuppy.rosehill>
References: <20071030160401.296770000@chello.nl>
	<20071030160914.749995000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
In-Reply-To: <20071030160914.749995000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Oct 2007 17:04:24 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> In order to make sure emergency packets receive all memory needed to proceed
> ensure processing of emergency SKBs happens under PF_MEMALLOC.
> 
> Use the (new) sk_backlog_rcv() wrapper to ensure this for backlog processing.
> 
> Skip taps, since those are user-space again.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/net/sock.h |    5 +++++
>  net/core/dev.c     |   44 ++++++++++++++++++++++++++++++++++++++------
>  net/core/sock.c    |   18 ++++++++++++++++++
>  3 files changed, 61 insertions(+), 6 deletions(-)
> 
> Index: linux-2.6/net/core/dev.c
> ===================================================================
> --- linux-2.6.orig/net/core/dev.c
> +++ linux-2.6/net/core/dev.c
> @@ -1976,10 +1976,23 @@ int netif_receive_skb(struct sk_buff *sk
>  	struct net_device *orig_dev;
>  	int ret = NET_RX_DROP;
>  	__be16 type;
> +	unsigned long pflags = current->flags;
> +
> +	/* Emergency skb are special, they should
> +	 *  - be delivered to SOCK_MEMALLOC sockets only
> +	 *  - stay away from userspace
> +	 *  - have bounded memory usage
> +	 *
> +	 * Use PF_MEMALLOC as a poor mans memory pool - the grouping kind.
> +	 * This saves us from propagating the allocation context down to all
> +	 * allocation sites.
> +	 */
> +	if (skb_emergency(skb))
> +		current->flags |= PF_MEMALLOC;
>  
>  	/* if we've gotten here through NAPI, check netpoll */
>  	if (netpoll_receive_skb(skb))
> -		return NET_RX_DROP;
> +		goto out;

Why the change? doesn't gcc optimize the common exit case anyway?

>  
>  	if (!skb->tstamp.tv64)
>  		net_timestamp(skb);
> @@ -1990,7 +2003,7 @@ int netif_receive_skb(struct sk_buff *sk
>  	orig_dev = skb_bond(skb);
>  
>  	if (!orig_dev)
> -		return NET_RX_DROP;
> +		goto out;
>  
>  	__get_cpu_var(netdev_rx_stat).total++;
>  
> @@ -2009,6 +2022,9 @@ int netif_receive_skb(struct sk_buff *sk
>  	}
>  #endif
>  
> +	if (skb_emergency(skb))
> +		goto skip_taps;
> +
>  	list_for_each_entry_rcu(ptype, &ptype_all, list) {
>  		if (!ptype->dev || ptype->dev == skb->dev) {
>  			if (pt_prev)
> @@ -2017,6 +2033,7 @@ int netif_receive_skb(struct sk_buff *sk
>  		}
>  	}
>  
> +skip_taps:
>  #ifdef CONFIG_NET_CLS_ACT
>  	if (pt_prev) {
>  		ret = deliver_skb(skb, pt_prev, orig_dev);
> @@ -2029,19 +2046,31 @@ int netif_receive_skb(struct sk_buff *sk
>  
>  	if (ret == TC_ACT_SHOT || (ret == TC_ACT_STOLEN)) {
>  		kfree_skb(skb);
> -		goto out;
> +		goto unlock;
>  	}
>  
>  	skb->tc_verd = 0;
>  ncls:
>  #endif
>  
> +	if (skb_emergency(skb))
> +		switch(skb->protocol) {
> +			case __constant_htons(ETH_P_ARP):
> +			case __constant_htons(ETH_P_IP):
> +			case __constant_htons(ETH_P_IPV6):
> +			case __constant_htons(ETH_P_8021Q):
> +				break;

Indentation is wrong, and hard coding protocol values as spcial case
seems bad here. What about vlan's, etc?

> +			default:
> +				goto drop;
> +		}
> +
>  	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
>  	if (!skb)
> -		goto out;
> +		goto unlock;
>  	skb = handle_macvlan(skb, &pt_prev, &ret, orig_dev);
>  	if (!skb)
> -		goto out;
> +		goto unlock;
>  
>  	type = skb->protocol;
>  	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15], list) {
> @@ -2056,6 +2085,7 @@ ncls:
>  	if (pt_prev) {
>  		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
>  	} else {
> +drop:
>  		kfree_skb(skb);
>  		/* Jamal, now you will not able to escape explaining
>  		 * me how you were going to use this. :-)
> @@ -2063,8 +2093,10 @@ ncls:
>  		ret = NET_RX_DROP;
>  	}
>  
> -out:
> +unlock:
>  	rcu_read_unlock();
> +out:
> +	tsk_restore_flags(current, pflags, PF_MEMALLOC);
>  	return ret;
>  }
>  
> Index: linux-2.6/include/net/sock.h
> ===================================================================
> --- linux-2.6.orig/include/net/sock.h
> +++ linux-2.6/include/net/sock.h
> @@ -523,8 +523,13 @@ static inline void sk_add_backlog(struct
>  	skb->next = NULL;
>  }
>  
> +extern int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb);
> +
>  static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
>  {
> +	if (skb_emergency(skb))
> +		return __sk_backlog_rcv(sk, skb);
> +
>  	return sk->sk_backlog_rcv(sk, skb);
>  }
>  
> Index: linux-2.6/net/core/sock.c
> ===================================================================
> --- linux-2.6.orig/net/core/sock.c
> +++ linux-2.6/net/core/sock.c
> @@ -319,6 +319,24 @@ int sk_clear_memalloc(struct sock *sk)
>  }
>  EXPORT_SYMBOL_GPL(sk_clear_memalloc);
>  
> +#ifdef CONFIG_NETVM
> +int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
> +{
> +	int ret;
> +	unsigned long pflags = current->flags;
> +
> +	/* these should have been dropped before queueing */
> +	BUG_ON(!sk_has_memalloc(sk));
> +
> +	current->flags |= PF_MEMALLOC;
> +	ret = sk->sk_backlog_rcv(sk, skb);
> +	tsk_restore_flags(current, pflags, PF_MEMALLOC);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(__sk_backlog_rcv);
> +#endif
> +
>  static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
>  {
>  	struct timeval tv;


I am still not convinced that this solves the problem well enough
to be useful.  Can you really survive a heavy memory overcommit?
In other words, can you prove that the added complexity causes the system
to survive a real test where otherwise it would not?


-- 
Stephen Hemminger <shemminger@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
