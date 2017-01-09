Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5434A6B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 05:22:22 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id dh1so71787167wjb.0
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 02:22:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 89si7845403wrp.109.2017.01.09.02.22.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 02:22:20 -0800 (PST)
Date: Mon, 9 Jan 2017 11:22:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
Message-ID: <20170109102219.GF7495@dhcp22.suse.cz>
References: <20170106152052.GS5556@dhcp22.suse.cz>
 <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
 <20170106160743.GU5556@dhcp22.suse.cz>
 <20170106161944.GW5556@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170106161944.GW5556@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 06-01-17 17:19:44, Michal Hocko wrote:
[...]
> From 8eadf8774daecdd6c4de37339216282a16920458 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 6 Jan 2017 17:03:31 +0100
> Subject: [PATCH] net: use kvmalloc rather than open coded variant
> 
> fq_alloc_node, alloc_netdev_mqs and netif_alloc* open code kmalloc
> with vmalloc fallback. Use the kvmalloc variant instead. Keep the
> __GFP_REPEAT flag based on explanation from
> Eric:
> "
> At the time, tests on the hardware I had in my labs showed that
> vmalloc() could deliver pages spread all over the memory and that was a
> small penalty (once memory is fragmented enough, not at boot time)
> "

the changelog doesn't mention it but this, unlike other kvmalloc
conversions is not without functional changes. The kmalloc part
will be weaker than it is with the original code for !costly (<64kB)
requests, because we are enforcing __GFP_NORETRY to break out from the
page allocator which doesn't really fail such a small requests.

Now the question is what those code paths really prefer. Do they really
want to potentially loop in the page allocator and invoke the OOM killer
when the memory is short/fragmeted? I mean we can get into a situation
when no order-3 pages can be compacted and shooting the system down just
for that reason sounds quite dangerous to me.

So the main question is how hard should we try before falling back to
vmalloc here?
 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  net/core/dev.c     | 24 +++++++++---------------
>  net/sched/sch_fq.c | 12 +-----------
>  2 files changed, 10 insertions(+), 26 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 56818f7eab2b..5cf2762387aa 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -7111,12 +7111,10 @@ static int netif_alloc_rx_queues(struct net_device *dev)
>  
>  	BUG_ON(count < 1);
>  
> -	rx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> -	if (!rx) {
> -		rx = vzalloc(sz);
> -		if (!rx)
> -			return -ENOMEM;
> -	}
> +	rx = kvzalloc(sz, GFP_KERNEL | __GFP_REPEAT);
> +	if (!rx)
> +		return -ENOMEM;
> +
>  	dev->_rx = rx;
>  
>  	for (i = 0; i < count; i++)
> @@ -7153,12 +7151,10 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
>  	if (count < 1 || count > 0xffff)
>  		return -EINVAL;
>  
> -	tx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> -	if (!tx) {
> -		tx = vzalloc(sz);
> -		if (!tx)
> -			return -ENOMEM;
> -	}
> +	tx = kvzalloc(sz, GFP_KERNEL | __GFP_REPEAT);
> +	if (!tx)
> +		return -ENOMEM;
> +
>  	dev->_tx = tx;
>  
>  	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
> @@ -7691,9 +7687,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
>  	/* ensure 32-byte alignment of whole construct */
>  	alloc_size += NETDEV_ALIGN - 1;
>  
> -	p = kzalloc(alloc_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> -	if (!p)
> -		p = vzalloc(alloc_size);
> +	p = kvzalloc(alloc_size, GFP_KERNEL | __GFP_REPEAT);
>  	if (!p)
>  		return NULL;
>  
> diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
> index a4f738ac7728..594f77d89f6c 100644
> --- a/net/sched/sch_fq.c
> +++ b/net/sched/sch_fq.c
> @@ -624,16 +624,6 @@ static void fq_rehash(struct fq_sched_data *q,
>  	q->stat_gc_flows += fcnt;
>  }
>  
> -static void *fq_alloc_node(size_t sz, int node)
> -{
> -	void *ptr;
> -
> -	ptr = kmalloc_node(sz, GFP_KERNEL | __GFP_REPEAT | __GFP_NOWARN, node);
> -	if (!ptr)
> -		ptr = vmalloc_node(sz, node);
> -	return ptr;
> -}
> -
>  static void fq_free(void *addr)
>  {
>  	kvfree(addr);
> @@ -650,7 +640,7 @@ static int fq_resize(struct Qdisc *sch, u32 log)
>  		return 0;
>  
>  	/* If XPS was setup, we can allocate memory on right NUMA node */
> -	array = fq_alloc_node(sizeof(struct rb_root) << log,
> +	array = kvmalloc_node(sizeof(struct rb_root) << log, GFP_KERNEL | __GFP_REPEAT,
>  			      netdev_queue_numa_node_read(sch->dev_queue));
>  	if (!array)
>  		return -ENOMEM;
> -- 
> 2.11.0
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
