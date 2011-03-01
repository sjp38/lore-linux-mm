Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B70B28D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 04:20:22 -0500 (EST)
Received: by wyi11 with SMTP id 11so5696708wyi.14
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 01:20:17 -0800 (PST)
Subject: Re: [PATCH 4/4 V2] net,rcu: don't assume the size of struct
 rcu_head
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4D6CB414.8050107@cn.fujitsu.com>
References: <4D6CA860.3020409@cn.fujitsu.com>
	 <20110301.001638.104075130.davem@davemloft.net>
	 <4D6CB414.8050107@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Mar 2011 10:20:13 +0100
Message-ID: <1298971213.3284.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu, paulmck@linux.vnet.ibm.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

Le mardi 01 mars 2011 A  16:53 +0800, Lai Jiangshan a A(C)crit :
> On 03/01/2011 04:16 PM, David Miller wrote:
> > From: Lai Jiangshan <laijs@cn.fujitsu.com>
> > Date: Tue, 01 Mar 2011 16:03:44 +0800
> > 
> >>
> >> struct dst_entry assumes the size of struct rcu_head as 2 * sizeof(long)
> >> and manually adds pads for aligning for "__refcnt".
> >>
> >> When the size of struct rcu_head is changed, these manual padding
> >> is wrong. Use __attribute__((aligned (64))) instead.
> >>
> >> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> > 
> > We don't want to use the align if it's going to waste lots of space.
> > 
> > Instead we want to rearrange the structure so that the alignment comes
> > more cheaply.
> 
> Subject: [PATCH 4/4 V2] net,rcu: don't assume the size of struct rcu_head
> 
> struct dst_entry assumes the size of struct rcu_head as 2 * sizeof(long)
> and manually adds pads for aligning for "__refcnt".
> 
> When the size of struct rcu_head is changed, these manual padding
> are hardly suit for the changes. So we rearrange the structure,
> and move the seldom access rcu_head to the end of the structure.
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> ---
> 
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 93b0310..d8c5296 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -37,7 +37,6 @@
>  struct sk_buff;
>  
>  struct dst_entry {
> -	struct rcu_head		rcu_head;
>  	struct dst_entry	*child;
>  	struct net_device       *dev;
>  	short			error;
> @@ -78,6 +77,13 @@ struct dst_entry {
>  	__u32			__pad2;
>  #endif
>  
> +	unsigned long		lastuse;
> +	union {
> +		struct dst_entry	*next;
> +		struct rtable __rcu	*rt_next;
> +		struct rt6_info		*rt6_next;
> +		struct dn_route __rcu	*dn_next;
> +	};
>  
>  	/*
>  	 * Align __refcnt to a 64 bytes alignment
> @@ -92,13 +98,7 @@ struct dst_entry {
>  	 */
>  	atomic_t		__refcnt;	/* client references	*/
>  	int			__use;
> -	unsigned long		lastuse;
> -	union {
> -		struct dst_entry	*next;
> -		struct rtable __rcu	*rt_next;
> -		struct rt6_info		*rt6_next;
> -		struct dn_route __rcu	*dn_next;
> -	};
> +	struct rcu_head		rcu_head;
>  };
>  
>  #ifdef __KERNEL__

Nope...

"lastuse" and "next" must be in this place, or this introduce false
sharing we wanted to avoid in the past.

I suggest you leave this code as is, we will address the problem when
rcu_head changes (assuming we can test a CONFIG_RCU_HEAD_DEBUG or
something)

First part of "struct dst_entry" is mostly read, while part beginning
after refcnt is often written.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
