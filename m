Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id E7BBB6B0037
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 04:04:08 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id u57so11346085wes.19
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 01:04:08 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id jw2si790785wjc.74.2014.09.05.01.04.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 01:04:07 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id z2so2466225wiv.9
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 01:04:06 -0700 (PDT)
Date: Fri, 5 Sep 2014 10:04:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140905080404.GA26243@dhcp22.suse.cz>
References: <54061505.8020500@sr71.net>
 <20140902221814.GA18069@cmpxchg.org>
 <5406466D.1020000@sr71.net>
 <20140903001009.GA25970@cmpxchg.org>
 <5406612E.8040802@sr71.net>
 <20140904150846.GA10794@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140904150846.GA10794@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Hansen <dave@sr71.net>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linuxfoundation.org>, Linus Torvalds <torvalds@linuxfoundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 04-09-14 11:08:46, Johannes Weiner wrote:
[...]
> From 6fa7599054868cd0df940d7b0973dd64f8acb0b5 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Thu, 4 Sep 2014 10:04:34 -0400
> Subject: [patch] mm: memcontrol: revert use of root_mem_cgroup res_counter
> 
> Dave Hansen reports a massive scalability regression in an uncontained
> page fault benchmark with more than 30 concurrent threads, which he
> bisected down to 05b843012335 ("mm: memcontrol: use root_mem_cgroup
> res_counter") and pin-pointed on res_counter spinlock contention.
> 
> That change relied on the per-cpu charge caches to mostly swallow the
> res_counter costs, but it's apparent that the caches don't scale yet.
> 
> Revert memcg back to bypassing res_counters on the root level in order
> to restore performance for uncontained workloads.
> 
> Reported-by: Dave Hansen <dave@sr71.net>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

The revert looks good to me.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 103 ++++++++++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 78 insertions(+), 25 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ec4dcf1b9562..085dc6d2f876 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2534,6 +2534,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	unsigned long long size;
>  	int ret = 0;
>  
> +	if (mem_cgroup_is_root(memcg))
> +		goto done;
>  retry:
>  	if (consume_stock(memcg, nr_pages))
>  		goto done;
> @@ -2611,9 +2613,7 @@ nomem:
>  	if (!(gfp_mask & __GFP_NOFAIL))
>  		return -ENOMEM;
>  bypass:
> -	memcg = root_mem_cgroup;
> -	ret = -EINTR;
> -	goto retry;
> +	return -EINTR;
>  
>  done_restock:
>  	if (batch > nr_pages)
> @@ -2626,6 +2626,9 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
>  {
>  	unsigned long bytes = nr_pages * PAGE_SIZE;
>  
> +	if (mem_cgroup_is_root(memcg))
> +		return;
> +
>  	res_counter_uncharge(&memcg->res, bytes);
>  	if (do_swap_account)
>  		res_counter_uncharge(&memcg->memsw, bytes);
> @@ -2640,6 +2643,9 @@ static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
>  {
>  	unsigned long bytes = nr_pages * PAGE_SIZE;
>  
> +	if (mem_cgroup_is_root(memcg))
> +		return;
> +
>  	res_counter_uncharge_until(&memcg->res, memcg->res.parent, bytes);
>  	if (do_swap_account)
>  		res_counter_uncharge_until(&memcg->memsw,
> @@ -4093,6 +4099,46 @@ out:
>  	return retval;
>  }
>  
> +static unsigned long mem_cgroup_recursive_stat(struct mem_cgroup *memcg,
> +					       enum mem_cgroup_stat_index idx)
> +{
> +	struct mem_cgroup *iter;
> +	long val = 0;
> +
> +	/* Per-cpu values can be negative, use a signed accumulator */
> +	for_each_mem_cgroup_tree(iter, memcg)
> +		val += mem_cgroup_read_stat(iter, idx);
> +
> +	if (val < 0) /* race ? */
> +		val = 0;
> +	return val;
> +}
> +
> +static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
> +{
> +	u64 val;
> +
> +	if (!mem_cgroup_is_root(memcg)) {
> +		if (!swap)
> +			return res_counter_read_u64(&memcg->res, RES_USAGE);
> +		else
> +			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
> +	}
> +
> +	/*
> +	 * Transparent hugepages are still accounted for in MEM_CGROUP_STAT_RSS
> +	 * as well as in MEM_CGROUP_STAT_RSS_HUGE.
> +	 */
> +	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
> +	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
> +
> +	if (swap)
> +		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_SWAP);
> +
> +	return val << PAGE_SHIFT;
> +}
> +
> +
>  static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
>  			       struct cftype *cft)
>  {
> @@ -4102,8 +4148,12 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
>  
>  	switch (type) {
>  	case _MEM:
> +		if (name == RES_USAGE)
> +			return mem_cgroup_usage(memcg, false);
>  		return res_counter_read_u64(&memcg->res, name);
>  	case _MEMSWAP:
> +		if (name == RES_USAGE)
> +			return mem_cgroup_usage(memcg, true);
>  		return res_counter_read_u64(&memcg->memsw, name);
>  	case _KMEM:
>  		return res_counter_read_u64(&memcg->kmem, name);
> @@ -4572,10 +4622,7 @@ static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
>  	if (!t)
>  		goto unlock;
>  
> -	if (!swap)
> -		usage = res_counter_read_u64(&memcg->res, RES_USAGE);
> -	else
> -		usage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> +	usage = mem_cgroup_usage(memcg, swap);
>  
>  	/*
>  	 * current_threshold points to threshold just below or equal to usage.
> @@ -4673,10 +4720,10 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
>  
>  	if (type == _MEM) {
>  		thresholds = &memcg->thresholds;
> -		usage = res_counter_read_u64(&memcg->res, RES_USAGE);
> +		usage = mem_cgroup_usage(memcg, false);
>  	} else if (type == _MEMSWAP) {
>  		thresholds = &memcg->memsw_thresholds;
> -		usage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> +		usage = mem_cgroup_usage(memcg, true);
>  	} else
>  		BUG();
>  
> @@ -4762,10 +4809,10 @@ static void __mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
>  
>  	if (type == _MEM) {
>  		thresholds = &memcg->thresholds;
> -		usage = res_counter_read_u64(&memcg->res, RES_USAGE);
> +		usage = mem_cgroup_usage(memcg, false);
>  	} else if (type == _MEMSWAP) {
>  		thresholds = &memcg->memsw_thresholds;
> -		usage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> +		usage = mem_cgroup_usage(memcg, true);
>  	} else
>  		BUG();
>  
> @@ -5525,9 +5572,9 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  		 * core guarantees its existence.
>  		 */
>  	} else {
> -		res_counter_init(&memcg->res, &root_mem_cgroup->res);
> -		res_counter_init(&memcg->memsw, &root_mem_cgroup->memsw);
> -		res_counter_init(&memcg->kmem, &root_mem_cgroup->kmem);
> +		res_counter_init(&memcg->res, NULL);
> +		res_counter_init(&memcg->memsw, NULL);
> +		res_counter_init(&memcg->kmem, NULL);
>  		/*
>  		 * Deeper hierachy with use_hierarchy == false doesn't make
>  		 * much sense so let cgroup subsystem know about this
> @@ -5969,8 +6016,9 @@ static void __mem_cgroup_clear_mc(void)
>  	/* we must fixup refcnts and charges */
>  	if (mc.moved_swap) {
>  		/* uncharge swap account from the old cgroup */
> -		res_counter_uncharge(&mc.from->memsw,
> -				     PAGE_SIZE * mc.moved_swap);
> +		if (!mem_cgroup_is_root(mc.from))
> +			res_counter_uncharge(&mc.from->memsw,
> +					     PAGE_SIZE * mc.moved_swap);
>  
>  		for (i = 0; i < mc.moved_swap; i++)
>  			css_put(&mc.from->css);
> @@ -5979,8 +6027,9 @@ static void __mem_cgroup_clear_mc(void)
>  		 * we charged both to->res and to->memsw, so we should
>  		 * uncharge to->res.
>  		 */
> -		res_counter_uncharge(&mc.to->res,
> -				     PAGE_SIZE * mc.moved_swap);
> +		if (!mem_cgroup_is_root(mc.to))
> +			res_counter_uncharge(&mc.to->res,
> +					     PAGE_SIZE * mc.moved_swap);
>  		/* we've already done css_get(mc.to) */
>  		mc.moved_swap = 0;
>  	}
> @@ -6345,7 +6394,8 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
>  	rcu_read_lock();
>  	memcg = mem_cgroup_lookup(id);
>  	if (memcg) {
> -		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> +		if (!mem_cgroup_is_root(memcg))
> +			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
>  		mem_cgroup_swap_statistics(memcg, false);
>  		css_put(&memcg->css);
>  	}
> @@ -6509,12 +6559,15 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
>  {
>  	unsigned long flags;
>  
> -	if (nr_mem)
> -		res_counter_uncharge(&memcg->res, nr_mem * PAGE_SIZE);
> -	if (nr_memsw)
> -		res_counter_uncharge(&memcg->memsw, nr_memsw * PAGE_SIZE);
> -
> -	memcg_oom_recover(memcg);
> +	if (!mem_cgroup_is_root(memcg)) {
> +		if (nr_mem)
> +			res_counter_uncharge(&memcg->res,
> +					     nr_mem * PAGE_SIZE);
> +		if (nr_memsw)
> +			res_counter_uncharge(&memcg->memsw,
> +					     nr_memsw * PAGE_SIZE);
> +		memcg_oom_recover(memcg);
> +	}
>  
>  	local_irq_save(flags);
>  	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS], nr_anon);
> -- 
> 2.0.4
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
