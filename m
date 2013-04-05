Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 1B8AE6B0005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 01:57:17 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9BF8F3EE0B6
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:57:15 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D47B45DE54
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:57:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A28945DE51
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:57:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B3331DB803F
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:57:15 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E6F8A1DB8037
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:57:14 +0900 (JST)
Message-ID: <515E679F.2030901@jp.fujitsu.com>
Date: Fri, 05 Apr 2013 14:56:47 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/7] memcg: use css_get/put for swap memcg
References: <515BF233.6070308@huawei.com> <515BF296.3080406@huawei.com>
In-Reply-To: <515BF296.3080406@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/04/03 18:12), Li Zefan wrote:
> Use css_get/put instead of mem_cgroup_get/put.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>   mm/memcontrol.c | 26 ++++++++++++++++----------
>   1 file changed, 16 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 877551d..ad576e8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4137,12 +4137,12 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
>   	unlock_page_cgroup(pc);
>   	/*
>   	 * even after unlock, we have memcg->res.usage here and this memcg
> -	 * will never be freed.
> +	 * will never be freed, so it's safe to call css_get().
>   	 */
>   	memcg_check_events(memcg, page);
>   	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
>   		mem_cgroup_swap_statistics(memcg, true);
> -		mem_cgroup_get(memcg);
> +		css_get(&memcg->css);
>   	}
>   	/*
>   	 * Migration does not charge the res_counter for the
> @@ -4242,7 +4242,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>   
>   	/*
>   	 * record memcg information,  if swapout && memcg != NULL,
> -	 * mem_cgroup_get() was called in uncharge().
> +	 * css_get() was called in uncharge().
>   	 */
>   	if (do_swap_account && swapout && memcg)
>   		swap_cgroup_record(ent, css_id(&memcg->css));
> @@ -4273,7 +4273,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
>   		if (!mem_cgroup_is_root(memcg))
>   			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
>   		mem_cgroup_swap_statistics(memcg, false);
> -		mem_cgroup_put(memcg);
> +		css_put(&memcg->css);
>   	}
>   	rcu_read_unlock();
>   }
> @@ -4307,11 +4307,14 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
>   		 * This function is only called from task migration context now.
>   		 * It postpones res_counter and refcount handling till the end
>   		 * of task migration(mem_cgroup_clear_mc()) for performance
> -		 * improvement. But we cannot postpone mem_cgroup_get(to)
> -		 * because if the process that has been moved to @to does
> -		 * swap-in, the refcount of @to might be decreased to 0.
> +		 * improvement. But we cannot postpone css_get(to)  because if
> +		 * the process that has been moved to @to does swap-in, the
> +		 * refcount of @to might be decreased to 0.
> +		 *
> +		 * We are in attach() phase, so the cgroup is guaranteed to be
> +		 * alive, so we can just call css_get().
>   		 */
> -		mem_cgroup_get(to);
> +		css_get(&to->css);
>   		return 0;
>   	}
>   	return -EINVAL;
> @@ -6597,6 +6600,7 @@ static void __mem_cgroup_clear_mc(void)
>   {
>   	struct mem_cgroup *from = mc.from;
>   	struct mem_cgroup *to = mc.to;
> +	int i;
>   
>   	/* we must uncharge all the leftover precharges from mc.to */
>   	if (mc.precharge) {
> @@ -6617,7 +6621,9 @@ static void __mem_cgroup_clear_mc(void)
>   		if (!mem_cgroup_is_root(mc.from))
>   			res_counter_uncharge(&mc.from->memsw,
>   						PAGE_SIZE * mc.moved_swap);
> -		__mem_cgroup_put(mc.from, mc.moved_swap);
> +
> +		for (i = 0; i < mc.moved_swap; i++)
> +			css_put(&mc.from->css);
>   
>   		if (!mem_cgroup_is_root(mc.to)) {
>   			/*
> @@ -6627,7 +6633,7 @@ static void __mem_cgroup_clear_mc(void)
>   			res_counter_uncharge(&mc.to->res,
>   						PAGE_SIZE * mc.moved_swap);
>   		}
> -		/* we've already done mem_cgroup_get(mc.to) */
> +		/* we've already done css_get(mc.to) */
>   		mc.moved_swap = 0;
>   	}
>   	memcg_oom_recover(from);
> 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
