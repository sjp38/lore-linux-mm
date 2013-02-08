Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 33CEC6B0005
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 11:01:23 -0500 (EST)
Date: Fri, 8 Feb 2013 17:01:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20130208160119.GE7557@dhcp22.suse.cz>
References: <20121230110815.GA12940@dhcp22.suse.cz>
 <20130125160723.FAE73567@pobox.sk>
 <20130125163130.GF4721@dhcp22.suse.cz>
 <20130205134937.GA22804@dhcp22.suse.cz>
 <20130205154947.CD6411E2@pobox.sk>
 <20130205160934.GB22804@dhcp22.suse.cz>
 <20130206021721.1AE9E3C7@pobox.sk>
 <20130206140119.GD10254@dhcp22.suse.cz>
 <51138999.3090006@jp.fujitsu.com>
 <5114577D.70608@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5114577D.70608@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 08-02-13 10:40:13, KAMEZAWA Hiroyuki wrote:
> (2013/02/07 20:01), Kamezawa Hiroyuki wrote:
[...]
> >Hmm. do we need to increase the "limit" virtually at memcg oom until
> >the oom-killed process dies ?
> 
> Here is my naive idea...

and the next step would be
http://en.wikipedia.org/wiki/Credit_default_swap :P

But seriously now. The idea is not bad at all. This implementation
would need some tweaks to work though (e.g. you would need to wake oom
sleepers when you get a loan - because those are ones which can block
the resource).  We should also give the borrowed charges only to those
who would oom to prevent from stealing.
I think that it should be mem_cgroup_out_of_memory who establishes the
loan and it can have a look at how much memory the killed task frees -
e.g. some portion of get_mm_rss() or a more precise but much more
expensive traversing via private vmas and check whether they charged
memory from the target memcg hierarchy (this is a slow path anyway).

But who knows maybe a fixed 2MB would work out as well.

Thanks!

> ==
> From 1a46318cf89e7df94bd4844f29105b61dacf335b Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 8 Feb 2013 10:43:52 +0900
> Subject: [PATCH] [Don't Apply][PATCH] memcg relax resource at OOM situation.
> 
> When an OOM happens, a task is killed and resources will be freed.
> 
> A problem here is that a task, which is oom-killed, may wait for
> some other resource in which memory resource is required. Some thread
> waits for free memory may holds some mutex and oom-killed process
> wait for the mutex.
> 
> To avoid this, relaxing charged memory by giving virtual resource
> can be a help. The system can get back it at uncharge().
> This is a sample native implementation.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   79 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 73 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 25ac5f4..4dea49a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -301,6 +301,9 @@ struct mem_cgroup {
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
> +	/* extra resource at emergency situation */
> +	unsigned long	loan;
> +	spinlock_t	loan_lock;
>  	/* protect arrays of thresholds */
>  	struct mutex thresholds_lock;
> @@ -2034,6 +2037,61 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
>  	mem_cgroup_iter_break(root_memcg, victim);
>  	return total;
>  }
> +/*
> + * When a memcg is in OOM situation, this lack of resource may cause deadlock
> + * because of complicated lock dependency(i_mutex...). To avoid that, we
> + * need extra resource or avoid charging.
> + *
> + * A memcg can request resource in an emergency state. We call it as loan.
> + * A memcg will return a loan when it does uncharge resource. We disallow
> + * double-loan and moving task to other groups until the loan is fully
> + * returned.
> + *
> + * Note: the problem here is that we cannot know what amount resouce should
> + * be necessary to exiting an emergency state.....
> + */
> +#define LOAN_MAX		(2 * 1024 * 1024)
> +
> +static void mem_cgroup_make_loan(struct mem_cgroup *memcg)
> +{
> +	u64 usage;
> +	unsigned long amount;
> +
> +	amount = LOAN_MAX;
> +
> +	usage = res_counter_read_u64(&memcg->res, RES_USAGE);
> +	if (amount > usage /2 )
> +		amount = usage / 2;
> +	spin_lock(&memcg->loan_lock);
> +	if (memcg->loan) {
> +		spin_unlock(&memcg->loan_lock);
> +		return;
> +	}
> +	memcg->loan = amount;
> +	res_counter_uncharge(&memcg->res, amount);
> +	if (do_swap_account)
> +		res_counter_uncharge(&memcg->memsw, amount);
> +	spin_unlock(&memcg->loan_lock);
> +}
> +
> +/* return amount of free resource which can be uncharged */
> +static unsigned long
> +mem_cgroup_may_return_loan(struct mem_cgroup *memcg, unsigned long val)
> +{
> +	unsigned long tmp;
> +	/* we don't care small race here */
> +	if (unlikely(!memcg->loan))
> +		return val;
> +	spin_lock(&memcg->loan_lock);
> +	if (memcg->loan) {
> +		tmp = min(memcg->loan, val);
> +		memcg->loan -= tmp;
> +		val -= tmp;
> +	}
> +	spin_unlock(&memcg->loan_lock);
> +	return val;
> +}
> +
>  /*
>   * Check OOM-Killer is already running under our hierarchy.
> @@ -2182,6 +2240,7 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
>  	if (need_to_kill) {
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  		mem_cgroup_out_of_memory(memcg, mask, order);
> +		mem_cgroup_make_loan(memcg);
>  	} else {
>  		schedule();
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
> @@ -2748,6 +2807,8 @@ static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
>  	if (!mem_cgroup_is_root(memcg)) {
>  		unsigned long bytes = nr_pages * PAGE_SIZE;
> +		bytes = mem_cgroup_may_return_loan(memcg, bytes);
> +
>  		res_counter_uncharge(&memcg->res, bytes);
>  		if (do_swap_account)
>  			res_counter_uncharge(&memcg->memsw, bytes);
> @@ -3989,6 +4050,7 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
>  {
>  	struct memcg_batch_info *batch = NULL;
>  	bool uncharge_memsw = true;
> +	unsigned long val;
>  	/* If swapout, usage of swap doesn't decrease */
>  	if (!do_swap_account || ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> @@ -4029,9 +4091,11 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
>  		batch->memsw_nr_pages++;
>  	return;
>  direct_uncharge:
> -	res_counter_uncharge(&memcg->res, nr_pages * PAGE_SIZE);
> +	val = nr_pages * PAGE_SIZE;
> +	val = mem_cgroup_may_return_loan(memcg, val);
> +	res_counter_uncharge(&memcg->res, val);
>  	if (uncharge_memsw)
> -		res_counter_uncharge(&memcg->memsw, nr_pages * PAGE_SIZE);
> +		res_counter_uncharge(&memcg->memsw, val);
>  	if (unlikely(batch->memcg != memcg))
>  		memcg_oom_recover(memcg);
>  }
> @@ -4182,6 +4246,7 @@ void mem_cgroup_uncharge_start(void)
>  void mem_cgroup_uncharge_end(void)
>  {
>  	struct memcg_batch_info *batch = &current->memcg_batch;
> +	unsigned long val;
>  	if (!batch->do_batch)
>  		return;
> @@ -4192,16 +4257,16 @@ void mem_cgroup_uncharge_end(void)
>  	if (!batch->memcg)
>  		return;
> +	val = batch->nr_pages * PAGE_SIZE;
> +	val = mem_cgroup_may_return_loan(batch->memcg, val);
>  	/*
>  	 * This "batch->memcg" is valid without any css_get/put etc...
>  	 * bacause we hide charges behind us.
>  	 */
>  	if (batch->nr_pages)
> -		res_counter_uncharge(&batch->memcg->res,
> -				     batch->nr_pages * PAGE_SIZE);
> +		res_counter_uncharge(&batch->memcg->res, val);
>  	if (batch->memsw_nr_pages)
> -		res_counter_uncharge(&batch->memcg->memsw,
> -				     batch->memsw_nr_pages * PAGE_SIZE);
> +		res_counter_uncharge(&batch->memcg->memsw, val);
>  	memcg_oom_recover(batch->memcg);
>  	/* forget this pointer (for sanity check) */
>  	batch->memcg = NULL;
> @@ -6291,6 +6356,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  	memcg->move_charge_at_immigrate = 0;
>  	mutex_init(&memcg->thresholds_lock);
>  	spin_lock_init(&memcg->move_lock);
> +	memcg->loan = 0;
> +	spin_lock_init(&memcg->loan_lock);
>  	return &memcg->css;
> -- 
> 1.7.10.2
> 
> 
> 
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
