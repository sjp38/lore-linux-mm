Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D19586B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 08:01:36 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y6so37137735lff.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 05:01:36 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id fz2si17691481wjb.206.2016.09.19.05.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 05:01:35 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w84so7418387wmg.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 05:01:35 -0700 (PDT)
Date: Mon, 19 Sep 2016 14:01:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: memcontrol: make per-cpu charge cache IRQ-safe
 for socket accounting
Message-ID: <20160919120133.GM10785@dhcp22.suse.cz>
References: <20160914194846.11153-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914194846.11153-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vladimir Davydov <vdavydov.dev@gmail.com>

[Fixup Vladimir's email]

On Wed 14-09-16 15:48:44, Johannes Weiner wrote:
> From: Johannes Weiner <jweiner@fb.com>
> 
> During cgroup2 rollout into production, we started encountering css
> refcount underflows and css access crashes in the memory controller.
> Splitting the heavily shared css reference counter into logical users
> narrowed the imbalance down to the cgroup2 socket memory accounting.
> 
> The problem turns out to be the per-cpu charge cache. Cgroup1 had a
> separate socket counter, but the new cgroup2 socket accounting goes
> through the common charge path that uses a shared per-cpu cache for
> all memory that is being tracked. Those caches are safe against
> scheduling preemption, but not against interrupts - such as the newly
> added packet receive path. When cache draining is interrupted by
> network RX taking pages out of the cache, the resuming drain operation
> will put references of in-use pages, thus causing the imbalance.
> 
> Disable IRQs during all per-cpu charge cache operations.
> 
> Fixes: f7e1cb6ec51b ("mm: memcontrol: account socket memory in unified hierarchy memory controller")
> Cc: <stable@vger.kernel.org> # 4.5+
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 31 ++++++++++++++++++++++---------
>  1 file changed, 22 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7a8d6624758a..60bb830abc34 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1710,17 +1710,22 @@ static DEFINE_MUTEX(percpu_charge_mutex);
>  static bool consume_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
>  {
>  	struct memcg_stock_pcp *stock;
> +	unsigned long flags;
>  	bool ret = false;
>  
>  	if (nr_pages > CHARGE_BATCH)
>  		return ret;
>  
> -	stock = &get_cpu_var(memcg_stock);
> +	local_irq_save(flags);
> +
> +	stock = this_cpu_ptr(&memcg_stock);
>  	if (memcg == stock->cached && stock->nr_pages >= nr_pages) {
>  		stock->nr_pages -= nr_pages;
>  		ret = true;
>  	}
> -	put_cpu_var(memcg_stock);
> +
> +	local_irq_restore(flags);
> +
>  	return ret;
>  }
>  
> @@ -1741,15 +1746,18 @@ static void drain_stock(struct memcg_stock_pcp *stock)
>  	stock->cached = NULL;
>  }
>  
> -/*
> - * This must be called under preempt disabled or must be called by
> - * a thread which is pinned to local cpu.
> - */
>  static void drain_local_stock(struct work_struct *dummy)
>  {
> -	struct memcg_stock_pcp *stock = this_cpu_ptr(&memcg_stock);
> +	struct memcg_stock_pcp *stock;
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +
> +	stock = this_cpu_ptr(&memcg_stock);
>  	drain_stock(stock);
>  	clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);
> +
> +	local_irq_restore(flags);
>  }
>  
>  /*
> @@ -1758,14 +1766,19 @@ static void drain_local_stock(struct work_struct *dummy)
>   */
>  static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
>  {
> -	struct memcg_stock_pcp *stock = &get_cpu_var(memcg_stock);
> +	struct memcg_stock_pcp *stock;
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
>  
> +	stock = this_cpu_ptr(&memcg_stock);
>  	if (stock->cached != memcg) { /* reset if necessary */
>  		drain_stock(stock);
>  		stock->cached = memcg;
>  	}
>  	stock->nr_pages += nr_pages;
> -	put_cpu_var(memcg_stock);
> +
> +	local_irq_restore(flags);
>  }
>  
>  /*
> -- 
> 2.9.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
