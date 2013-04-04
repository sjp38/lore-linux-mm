Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A293C6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 07:25:11 -0400 (EDT)
Date: Thu, 4 Apr 2013 13:25:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 4/7] memcg: use css_get/put for swap memcg
Message-ID: <20130404112505.GG29911@dhcp22.suse.cz>
References: <515BF233.6070308@huawei.com>
 <515BF296.3080406@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515BF296.3080406@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed 03-04-13 17:12:54, Li Zefan wrote:
> Use css_get/put instead of mem_cgroup_get/put.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Looks good to me. Swapped in pages still use css_tryget so they would
fallback to recharge in __mem_cgroup_try_charge_swapin if the group was
removed.

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  mm/memcontrol.c | 26 ++++++++++++++++----------
>  1 file changed, 16 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 877551d..ad576e8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4137,12 +4137,12 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
>  	unlock_page_cgroup(pc);
>  	/*
>  	 * even after unlock, we have memcg->res.usage here and this memcg
> -	 * will never be freed.
> +	 * will never be freed, so it's safe to call css_get().
>  	 */
>  	memcg_check_events(memcg, page);
>  	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
>  		mem_cgroup_swap_statistics(memcg, true);
> -		mem_cgroup_get(memcg);
> +		css_get(&memcg->css);
>  	}
>  	/*
>  	 * Migration does not charge the res_counter for the
> @@ -4242,7 +4242,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>  
>  	/*
>  	 * record memcg information,  if swapout && memcg != NULL,
> -	 * mem_cgroup_get() was called in uncharge().
> +	 * css_get() was called in uncharge().
>  	 */
>  	if (do_swap_account && swapout && memcg)
>  		swap_cgroup_record(ent, css_id(&memcg->css));
> @@ -4273,7 +4273,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
>  		if (!mem_cgroup_is_root(memcg))
>  			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
>  		mem_cgroup_swap_statistics(memcg, false);
> -		mem_cgroup_put(memcg);
> +		css_put(&memcg->css);
>  	}
>  	rcu_read_unlock();
>  }
> @@ -4307,11 +4307,14 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
>  		 * This function is only called from task migration context now.
>  		 * It postpones res_counter and refcount handling till the end
>  		 * of task migration(mem_cgroup_clear_mc()) for performance
> -		 * improvement. But we cannot postpone mem_cgroup_get(to)
> -		 * because if the process that has been moved to @to does
> -		 * swap-in, the refcount of @to might be decreased to 0.
> +		 * improvement. But we cannot postpone css_get(to)  because if
> +		 * the process that has been moved to @to does swap-in, the
> +		 * refcount of @to might be decreased to 0.
> +		 *
> +		 * We are in attach() phase, so the cgroup is guaranteed to be
> +		 * alive, so we can just call css_get().
>  		 */
> -		mem_cgroup_get(to);
> +		css_get(&to->css);
>  		return 0;
>  	}
>  	return -EINVAL;
> @@ -6597,6 +6600,7 @@ static void __mem_cgroup_clear_mc(void)
>  {
>  	struct mem_cgroup *from = mc.from;
>  	struct mem_cgroup *to = mc.to;
> +	int i;
>  
>  	/* we must uncharge all the leftover precharges from mc.to */
>  	if (mc.precharge) {
> @@ -6617,7 +6621,9 @@ static void __mem_cgroup_clear_mc(void)
>  		if (!mem_cgroup_is_root(mc.from))
>  			res_counter_uncharge(&mc.from->memsw,
>  						PAGE_SIZE * mc.moved_swap);
> -		__mem_cgroup_put(mc.from, mc.moved_swap);
> +
> +		for (i = 0; i < mc.moved_swap; i++)
> +			css_put(&mc.from->css);
>  
>  		if (!mem_cgroup_is_root(mc.to)) {
>  			/*
> @@ -6627,7 +6633,7 @@ static void __mem_cgroup_clear_mc(void)
>  			res_counter_uncharge(&mc.to->res,
>  						PAGE_SIZE * mc.moved_swap);
>  		}
> -		/* we've already done mem_cgroup_get(mc.to) */
> +		/* we've already done css_get(mc.to) */
>  		mc.moved_swap = 0;
>  	}
>  	memcg_oom_recover(from);
> -- 
> 1.8.0.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
