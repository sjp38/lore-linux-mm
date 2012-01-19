Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 54D086B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 09:47:15 -0500 (EST)
Date: Thu, 19 Jan 2012 15:47:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] [PATCH 7/7 v2] memcg: make mem_cgroup_begin_update_stat to
 use global pcpu.
Message-ID: <20120119144712.GG13932@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113174510.5e0f6131.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120113174510.5e0f6131.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri 13-01-12 17:45:10, KAMEZAWA Hiroyuki wrote:
> From 3df71cef5757ee6547916c4952f04a263c1b8ddb Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 13 Jan 2012 17:07:35 +0900
> Subject: [PATCH 7/7] memcg: make mem_cgroup_begin_update_stat to use global pcpu.
> 
> Now, a per-cpu flag to show the memcg is under account moving is
> now implemented as per-memcg-per-cpu.
> 
> So, when accessing this, we need to access memcg 1st. But this
> function is called even when status update doesn't occur. Then,
> accessing struct memcg is an overhead in such case.
> 
> This patch removes per-cpu-per-memcg MEM_CGROUP_ON_MOVE and add
> per-cpu vairable to do the same work. For per-memcg, atomic
> counter is added. By this, mem_cgroup_begin_update_stat() will
> just access percpu variable in usual case and don't need to find & access
> memcg. This reduces overhead.

I agree that move_account is not a hotpath and that we don't have
to optimize for it but I guess we can do better. If we use a cookie
parameter for
mem_cgroup_{begin,end}_update_stat(struct page *page, unsigned long *cookie)
then we can stab page_cgroup inside and use the last bit for
locked.  Then we do not have to call lookup_page_cgroup again in
mem_cgroup_update_page_stat and just replace page by the cookie.
What do you think?

> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |   16 +++++++++-
>  mm/memcontrol.c            |   67 +++++++++++++++++++++----------------------
>  2 files changed, 47 insertions(+), 36 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 976b58c..26a4baa 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -151,12 +151,22 @@ static inline bool mem_cgroup_disabled(void)
>   * 	mem_cgroup_update_page_stat(page, idx, val)
>   * 	mem_cgroup_end_update_page_stat(page, locked);
>   */
> +DECLARE_PER_CPU(int, mem_cgroup_account_moving);
> +static inline bool any_mem_cgroup_stealed(void)
> +{
> +	smp_rmb();
> +	return this_cpu_read(mem_cgroup_account_moving) > 0;
> +}
> +
>  bool __mem_cgroup_begin_update_page_stat(struct page *page);
>  static inline bool mem_cgroup_begin_update_page_stat(struct page *page)
>  {
>  	if (mem_cgroup_disabled())
>  		return false;
> -	return __mem_cgroup_begin_update_page_stat(page);
> +	rcu_read_lock();
> +	if (unlikely(any_mem_cgroup_stealed()))
> +		return __mem_cgroup_begin_update_page_stat(page);
> +	return false;
>  }
>  void mem_cgroup_update_page_stat(struct page *page,
>  				 enum mem_cgroup_page_stat_item idx,
> @@ -167,7 +177,9 @@ mem_cgroup_end_update_page_stat(struct page *page, bool locked)
>  {
>  	if (mem_cgroup_disabled())
>  		return;
> -	__mem_cgroup_end_update_page_stat(page, locked);
> +	if (locked)
> +		__mem_cgroup_end_update_page_stat(page, locked);
> +	rcu_read_unlock();
>  }
>  
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8b67ccf..4836e8d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -89,7 +89,6 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>  	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
> -	MEM_CGROUP_ON_MOVE,	/* someone is moving account between groups */
>  	MEM_CGROUP_STAT_NSTATS,
>  };
>  
> @@ -279,6 +278,8 @@ struct mem_cgroup {
>  	 * mem_cgroup ? And what type of charges should we move ?
>  	 */
>  	unsigned long 	move_charge_at_immigrate;
> +	/* set when a page under this memcg may be moving to other memcg */
> +	atomic_t	account_moving;
>  	/*
>  	 * percpu counter.
>  	 */
> @@ -1250,20 +1251,27 @@ int mem_cgroup_swappiness(struct mem_cgroup *memcg)
>  	return memcg->swappiness;
>  }
>  
> +/*
> + * For quick check, for avoiding looking up memcg, system-wide
> + * per-cpu check is provided.
> + */
> +DEFINE_PER_CPU(int, mem_cgroup_account_moving);
> +DEFINE_SPINLOCK(mem_cgroup_stealed_lock);
> +
>  static void mem_cgroup_start_move(struct mem_cgroup *memcg)
>  {
>  	int cpu;
>  
>  	get_online_cpus();
> -	spin_lock(&memcg->pcp_counter_lock);
> +	spin_lock(&mem_cgroup_stealed_lock);
>  	for_each_online_cpu(cpu) {
> -		per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
> +		per_cpu(mem_cgroup_account_moving, cpu) += 1;
>  		smp_wmb();
>  	}
> -	memcg->nocpu_base.count[MEM_CGROUP_ON_MOVE] += 1;
> -	spin_unlock(&memcg->pcp_counter_lock);
> +	spin_unlock(&mem_cgroup_stealed_lock);
>  	put_online_cpus();
>  
> +	atomic_inc(&memcg->account_moving);
>  	synchronize_rcu();
>  }
>  
> @@ -1274,11 +1282,12 @@ static void mem_cgroup_end_move(struct mem_cgroup *memcg)
>  	if (!memcg)
>  		return;
>  	get_online_cpus();
> -	spin_lock(&memcg->pcp_counter_lock);
> -	for_each_online_cpu(cpu)
> -		per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) -= 1;
> -	memcg->nocpu_base.count[MEM_CGROUP_ON_MOVE] -= 1;
> -	spin_unlock(&memcg->pcp_counter_lock);
> +	spin_lock(&mem_cgroup_stealed_lock);
> +	for_each_online_cpu(cpu) {
> +		per_cpu(mem_cgroup_account_moving, cpu) -= 1;
> +	}
> +	spin_unlock(&mem_cgroup_stealed_lock);
> +	atomic_dec(&memcg->account_moving);
>  	put_online_cpus();
>  }
>  /*
> @@ -1296,8 +1305,7 @@ static void mem_cgroup_end_move(struct mem_cgroup *memcg)
>  static bool mem_cgroup_stealed(struct mem_cgroup *memcg)
>  {
>  	VM_BUG_ON(!rcu_read_lock_held());
> -	smp_rmb();
> -	return this_cpu_read(memcg->stat->count[MEM_CGROUP_ON_MOVE]) > 0;
> +	return atomic_read(&memcg->account_moving) > 0;
>  }
>  
>  static bool mem_cgroup_under_move(struct mem_cgroup *memcg)
> @@ -1343,10 +1351,9 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
>   * page satus accounting. To avoid that, we need some locks. In general,
>   * ading atomic ops to hot path is very bad. We're using 2 level logic.
>   *
> - * When a thread starts moving account information, per-cpu MEM_CGROUP_ON_MOVE
> - * value is set. If MEM_CGROUP_ON_MOVE==0, there are no race and page status
> - * update can be done withou any locks. If MEM_CGROUP_ON_MOVE>0, we use
> - * following hashed rwlocks.
> + * When a thread starts moving account information, memcg->account_moving
> + * value is set. If ==0, there are no race and page status update can be done
> + * without any locks. If account_moving >0, we use following hashed rwlocks.
>   * - At updating information, we hold rlock.
>   * - When a page is picked up and being moved, wlock is held.
>   *
> @@ -1354,7 +1361,7 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
>   */
>  
>  /*
> - * This rwlock is accessed only when MEM_CGROUP_ON_MOVE > 0.
> + * This rwlock is accessed only when account_moving > 0.
>   */
>  #define NR_MOVE_ACCOUNT_LOCKS	(NR_CPUS)
>  #define move_account_hash(page) ((page_to_pfn(page) % NR_MOVE_ACCOUNT_LOCKS))
> @@ -1907,9 +1914,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
>   * if there are race with "uncharge". Statistics itself is properly handled
>   * by flags.
>   *
> - * Considering "move", this is an only case we see a race. To make the race
> - * small, we check MEM_CGROUP_ON_MOVE percpu value and detect there are
> - * possibility of race condition. If there is, we take a lock.
> + * If any_mem_cgroup_stealed() && mem_cgroup_stealed(), there is
> + * a possiblity of race condition and we take a lock.
>   */
>  
>  bool __mem_cgroup_begin_update_page_stat(struct page *page)
> @@ -1918,7 +1924,6 @@ bool __mem_cgroup_begin_update_page_stat(struct page *page)
>  	bool locked = false;
>  	struct mem_cgroup *memcg;
>  
> -	rcu_read_lock();
>  	memcg = pc->mem_cgroup;
>  
>  	if (!memcg || !PageCgroupUsed(pc))
> @@ -1933,9 +1938,7 @@ out:
>  
>  void __mem_cgroup_end_update_page_stat(struct page *page, bool locked)
>  {
> -	if (locked)
> -		mem_cgroup_account_move_runlock(page);
> -	rcu_read_unlock();
> +	mem_cgroup_account_move_runlock(page);
>  }
>  
>  void mem_cgroup_update_page_stat(struct page *page,
> @@ -2133,18 +2136,14 @@ static void mem_cgroup_drain_pcp_counter(struct mem_cgroup *memcg, int cpu)
>  		per_cpu(memcg->stat->events[i], cpu) = 0;
>  		memcg->nocpu_base.events[i] += x;
>  	}
> -	/* need to clear ON_MOVE value, works as a kind of lock. */
> -	per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) = 0;
>  	spin_unlock(&memcg->pcp_counter_lock);
>  }
>  
> -static void synchronize_mem_cgroup_on_move(struct mem_cgroup *memcg, int cpu)
> +static void synchronize_mem_cgroup_on_move(int cpu)
>  {
> -	int idx = MEM_CGROUP_ON_MOVE;
> -
> -	spin_lock(&memcg->pcp_counter_lock);
> -	per_cpu(memcg->stat->count[idx], cpu) = memcg->nocpu_base.count[idx];
> -	spin_unlock(&memcg->pcp_counter_lock);
> +	spin_lock(&mem_cgroup_stealed_lock);
> +	per_cpu(mem_cgroup_account_moving, cpu) = 0;
> +	spin_unlock(&mem_cgroup_stealed_lock);
>  }
>  
>  static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block *nb,
> @@ -2156,8 +2155,7 @@ static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block *nb,
>  	struct mem_cgroup *iter;
>  
>  	if ((action == CPU_ONLINE)) {
> -		for_each_mem_cgroup(iter)
> -			synchronize_mem_cgroup_on_move(iter, cpu);
> +		synchronize_mem_cgroup_on_move(cpu);
>  		return NOTIFY_OK;
>  	}
>  
> @@ -2167,6 +2165,7 @@ static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block *nb,
>  	for_each_mem_cgroup(iter)
>  		mem_cgroup_drain_pcp_counter(iter, cpu);
>  
> +	per_cpu(mem_cgroup_account_moving, cpu) = 0;
>  	stock = &per_cpu(memcg_stock, cpu);
>  	drain_stock(stock);
>  	return NOTIFY_OK;
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
