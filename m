Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id D08816B0069
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 11:15:43 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id fb4so8209136wid.12
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 08:15:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t19si14501877wiv.68.2014.10.07.08.15.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 08:15:42 -0700 (PDT)
Date: Tue, 7 Oct 2014 17:15:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20141007151543.GE14243@dhcp22.suse.cz>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 24-09-14 11:43:08, Johannes Weiner wrote:
> Memory is internally accounted in bytes, using spinlock-protected
> 64-bit counters, even though the smallest accounting delta is a page.
> The counter interface is also convoluted and does too many things.
> 
> Introduce a new lockless word-sized page counter API, then change all
> memory accounting over to it and remove the old one.  The translation
> from and to bytes then only happens when interfacing with userspace.
> 
> Aside from the locking costs, this gets rid of the icky unsigned long
> long types in the very heart of memcg, which is great for 32 bit and
> also makes the code a lot more readable.
> 

I only now got to the res_counter -> page_counter change. It looks
correct to me. Some really minor comments below.

[...]
>  static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
>  					      unsigned long amt)
>  {
> -	res_counter_uncharge(&prot->memory_allocated, amt << PAGE_SHIFT);
> -}
> -
> -static inline u64 memcg_memory_allocated_read(struct cg_proto *prot)
> -{
> -	u64 ret;
> -	ret = res_counter_read_u64(&prot->memory_allocated, RES_USAGE);
> -	return ret >> PAGE_SHIFT;
> +	page_counter_uncharge(&prot->memory_allocated, amt);
>  }

There is only one caller of memcg_memory_allocated_sub and the caller
can use the counter directly same as memcg_memory_allocated_read
original users.

[...]
> diff --git a/init/Kconfig b/init/Kconfig
> index ed4f42d79bd1..88b56940cb9e 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -983,9 +983,12 @@ config RESOURCE_COUNTERS
>  	  This option enables controller independent resource accounting
>  	  infrastructure that works with cgroups.
>  
> +config PAGE_COUNTER
> +       bool
> +
>  config MEMCG
>  	bool "Memory Resource Controller for Control Groups"
> -	depends on RESOURCE_COUNTERS
> +	select PAGE_COUNTER
>  	select EVENTFD
>  	help
>  	  Provides a memory resource controller that manages both anonymous

Thanks for this!

[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c2c75262a209..52c24119be69 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -1490,12 +1495,23 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
>   */
>  static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
>  {
> -	unsigned long long margin;
> +	unsigned long margin = 0;
> +	unsigned long count;
> +	unsigned long limit;
>  
> -	margin = res_counter_margin(&memcg->res);
> -	if (do_swap_account)
> -		margin = min(margin, res_counter_margin(&memcg->memsw));
> -	return margin >> PAGE_SHIFT;
> +	count = page_counter_read(&memcg->memory);
> +	limit = ACCESS_ONCE(memcg->memory.limit);
> +	if (count < limit)
> +		margin = limit - count;
> +
> +	if (do_swap_account) {
> +		count = page_counter_read(&memcg->memsw);
> +		limit = ACCESS_ONCE(memcg->memsw.limit);
> +		if (count < limit)

I guess you wanted (count <= limit) here?

> +			margin = min(margin, limit - count);
> +	}
> +
> +	return margin;
>  }
>  
>  int mem_cgroup_swappiness(struct mem_cgroup *memcg)
[...]
> @@ -2293,33 +2295,31 @@ static DEFINE_MUTEX(percpu_charge_mutex);
>  static bool consume_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
>  {
>  	struct memcg_stock_pcp *stock;
> -	bool ret = true;
> +	bool ret = false;
>  
>  	if (nr_pages > CHARGE_BATCH)
> -		return false;
> +		return ret;
>  
>  	stock = &get_cpu_var(memcg_stock);
> -	if (memcg == stock->cached && stock->nr_pages >= nr_pages)
> +	if (memcg == stock->cached && stock->nr_pages >= nr_pages) {
>  		stock->nr_pages -= nr_pages;
> -	else /* need to call res_counter_charge */
> -		ret = false;
> +		ret = true;
> +	}
>  	put_cpu_var(memcg_stock);
>  	return ret;

This change is not really needed but at least it woke me up after some
monotonic and mechanical changes...

[...]
> @@ -4389,14 +4346,16 @@ static int memcg_stat_show(struct seq_file *m, void *v)
>  			   mem_cgroup_nr_lru_pages(memcg, BIT(i)) * PAGE_SIZE);
>  
>  	/* Hierarchical information */
> -	{
> -		unsigned long long limit, memsw_limit;
> -		memcg_get_hierarchical_limit(memcg, &limit, &memsw_limit);
> -		seq_printf(m, "hierarchical_memory_limit %llu\n", limit);
> -		if (do_swap_account)
> -			seq_printf(m, "hierarchical_memsw_limit %llu\n",
> -				   memsw_limit);
> +	memory = memsw = PAGE_COUNTER_MAX;
> +	for (mi = memcg; mi; mi = parent_mem_cgroup(mi)) {
> +		memory = min(memory, mi->memory.limit);
> +		memsw = min(memsw, mi->memsw.limit);
>  	}

This looks much better!

> +	seq_printf(m, "hierarchical_memory_limit %llu\n",
> +		   (u64)memory * PAGE_SIZE);
> +	if (do_swap_account)
> +		seq_printf(m, "hierarchical_memsw_limit %llu\n",
> +			   (u64)memsw * PAGE_SIZE);
>  
>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>  		long long val = 0;

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
