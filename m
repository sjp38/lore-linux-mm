Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 501EA6B026A
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 11:36:31 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id x4so8945671wme.3
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 08:36:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z20si13995145wmz.148.2017.01.30.08.36.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 08:36:30 -0800 (PST)
Subject: Re: [PATCH 6/9] net: use kvmalloc with __GFP_REPEAT rather than open
 coded variant
References: <20170130094940.13546-1-mhocko@kernel.org>
 <20170130094940.13546-7-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9e1f34ef-1038-cf0b-95c2-1df64f1a541b@suse.cz>
Date: Mon, 30 Jan 2017 17:36:27 +0100
MIME-Version: 1.0
In-Reply-To: <20170130094940.13546-7-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org

On 01/30/2017 10:49 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> fq_alloc_node, alloc_netdev_mqs and netif_alloc* open code kmalloc
> with vmalloc fallback. Use the kvmalloc variant instead. Keep the
> __GFP_REPEAT flag based on explanation from Eric:
> "
> At the time, tests on the hardware I had in my labs showed that
> vmalloc() could deliver pages spread all over the memory and that was a
> small penalty (once memory is fragmented enough, not at boot time)
> "
>
> The way how the code is constructed means, however, that we prefer to go
> and hit the OOM killer before we fall back to the vmalloc for requests
> <=32kB (with 4kB pages) in the current code. This is rather disruptive for
> something that can be achived with the fallback. On the other hand
> __GFP_REPEAT doesn't have any useful semantic for these requests. So the
> effect of this patch is that requests smaller than 64kB will fallback to
> vmalloc esier now.

           easier

Although it's somewhat of an euphemism when compared to "basically never" :)

>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  net/core/dev.c     | 24 +++++++++---------------
>  net/sched/sch_fq.c | 12 +-----------
>  2 files changed, 10 insertions(+), 26 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index be11abac89b3..707e730821a6 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -7081,12 +7081,10 @@ static int netif_alloc_rx_queues(struct net_device *dev)
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
> @@ -7123,12 +7121,10 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
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
> @@ -7661,9 +7657,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
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
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
