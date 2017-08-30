Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3E66B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 10:24:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p37so9088417wrc.5
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 07:24:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b11si4656342wrd.141.2017.08.30.07.24.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Aug 2017 07:24:20 -0700 (PDT)
Date: Wed, 30 Aug 2017 16:24:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: use per-cpu stocks for socket memory
 uncharging
Message-ID: <20170830142418.x2nnbljsczfjrdel@dhcp22.suse.cz>
References: <20170829100150.4580-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829100150.4580-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue 29-08-17 11:01:50, Roman Gushchin wrote:
> We've noticed a quite sensible performance overhead on some hosts
> with significant network traffic when socket memory accounting
> is enabled.
> 
> Perf top shows that socket memory uncharging path is hot:
>   2.13%  [kernel]                [k] page_counter_cancel
>   1.14%  [kernel]                [k] __sk_mem_reduce_allocated
>   1.14%  [kernel]                [k] _raw_spin_lock
>   0.87%  [kernel]                [k] _raw_spin_lock_irqsave
>   0.84%  [kernel]                [k] tcp_ack
>   0.84%  [kernel]                [k] ixgbe_poll
>   0.83%  < workload >
>   0.82%  [kernel]                [k] enqueue_entity
>   0.68%  [kernel]                [k] __fget
>   0.68%  [kernel]                [k] tcp_delack_timer_handler
>   0.67%  [kernel]                [k] __schedule
>   0.60%  < workload >
>   0.59%  [kernel]                [k] __inet6_lookup_established
>   0.55%  [kernel]                [k] __switch_to
>   0.55%  [kernel]                [k] menu_select
>   0.54%  libc-2.20.so            [.] __memcpy_avx_unaligned
> 
> To address this issue, the existing per-cpu stock infrastructure
> can be used.
> 
> refill_stock() can be called from mem_cgroup_uncharge_skmem()
> to move charge to a per-cpu stock instead of calling atomic
> page_counter_uncharge().
> 
> To prevent the uncontrolled growth of per-cpu stocks,
> refill_stock() will explicitly drain the cached charge,
> if the cached value exceeds CHARGE_BATCH.
> 
> This allows significantly optimize the load:
>   1.21%  [kernel]                [k] _raw_spin_lock
>   1.01%  [kernel]                [k] ixgbe_poll
>   0.92%  [kernel]                [k] _raw_spin_lock_irqsave
>   0.90%  [kernel]                [k] enqueue_entity
>   0.86%  [kernel]                [k] tcp_ack
>   0.85%  < workload >
>   0.74%  perf-11120.map          [.] 0x000000000061bf24
>   0.73%  [kernel]                [k] __schedule
>   0.67%  [kernel]                [k] __fget
>   0.63%  [kernel]                [k] __inet6_lookup_established
>   0.62%  [kernel]                [k] menu_select
>   0.59%  < workload >
>   0.59%  [kernel]                [k] __switch_to
>   0.57%  libc-2.20.so            [.] __memcpy_avx_unaligned
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: cgroups@vger.kernel.org
> Cc: kernel-team@fb.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b9cf3cf4a3d0..a69d23082abf 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1792,6 +1792,9 @@ static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
>  	}
>  	stock->nr_pages += nr_pages;
>  
> +	if (stock->nr_pages > CHARGE_BATCH)
> +		drain_stock(stock);
> +
>  	local_irq_restore(flags);
>  }
>  
> @@ -5886,8 +5889,7 @@ void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
>  
>  	this_cpu_sub(memcg->stat->count[MEMCG_SOCK], nr_pages);
>  
> -	page_counter_uncharge(&memcg->memory, nr_pages);
> -	css_put_many(&memcg->css, nr_pages);
> +	refill_stock(memcg, nr_pages);
>  }
>  
>  static int __init cgroup_memory(char *s)
> -- 
> 2.13.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
