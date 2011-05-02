Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA6A9900121
	for <linux-mm@kvack.org>; Mon,  2 May 2011 06:36:30 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id p42AZ14l010215
	for <linux-mm@kvack.org>; Mon, 2 May 2011 16:05:01 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p42AaLQX3363050
	for <linux-mm@kvack.org>; Mon, 2 May 2011 16:06:21 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p42AaKD0001161
	for <linux-mm@kvack.org>; Mon, 2 May 2011 20:36:21 +1000
Date: Mon, 2 May 2011 14:37:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-ID: <20110502090741.GP6547@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
 <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-04-25 18:28:49]:

> There are two watermarks added per-memcg including "high_wmark" and "low_wmark".
> The per-memcg kswapd is invoked when the memcg's memory usage(usage_in_bytes)
> is higher than the low_wmark. Then the kswapd thread starts to reclaim pages
> until the usage is lower than the high_wmark.
> 
> Each watermark is calculated based on the hard_limit(limit_in_bytes) for each
> memcg. Each time the hard_limit is changed, the corresponding wmarks are
> re-calculated. Since memory controller charges only user pages, there is
> no need for a "min_wmark". The current calculation of wmarks is based on
> individual tunable high_wmark_distance, which are set to 0 by default.
> low_wmark is calculated in automatic way.
> 
> Changelog:v8b...v7
> 1. set low_wmark_distance in automatic using fixed HILOW_DISTANCE.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h  |    1 
>  include/linux/res_counter.h |   78 ++++++++++++++++++++++++++++++++++++++++++++
>  kernel/res_counter.c        |    6 +++
>  mm/memcontrol.c             |   69 ++++++++++++++++++++++++++++++++++++++
>  4 files changed, 154 insertions(+)
> 
> Index: memcg/include/linux/memcontrol.h
> ===================================================================
> --- memcg.orig/include/linux/memcontrol.h
> +++ memcg/include/linux/memcontrol.h
> @@ -84,6 +84,7 @@ int task_in_mem_cgroup(struct task_struc
> 
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> +extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
> 
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> Index: memcg/include/linux/res_counter.h
> ===================================================================
> --- memcg.orig/include/linux/res_counter.h
> +++ memcg/include/linux/res_counter.h
> @@ -39,6 +39,14 @@ struct res_counter {
>  	 */
>  	unsigned long long soft_limit;
>  	/*
> +	 * the limit that reclaim triggers.
> +	 */
> +	unsigned long long low_wmark_limit;
> +	/*
> +	 * the limit that reclaim stops.
> +	 */
> +	unsigned long long high_wmark_limit;
> +	/*
>  	 * the number of unsuccessful attempts to consume the resource
>  	 */
>  	unsigned long long failcnt;
> @@ -55,6 +63,9 @@ struct res_counter {
> 
>  #define RESOURCE_MAX (unsigned long long)LLONG_MAX
> 
> +#define CHARGE_WMARK_LOW	0x01
> +#define CHARGE_WMARK_HIGH	0x02
> +
>  /**
>   * Helpers to interact with userspace
>   * res_counter_read_u64() - returns the value of the specified member.
> @@ -92,6 +103,8 @@ enum {
>  	RES_LIMIT,
>  	RES_FAILCNT,
>  	RES_SOFT_LIMIT,
> +	RES_LOW_WMARK_LIMIT,
> +	RES_HIGH_WMARK_LIMIT
>  };
> 
>  /*
> @@ -147,6 +160,24 @@ static inline unsigned long long res_cou
>  	return margin;
>  }
> 
> +static inline bool
> +res_counter_under_high_wmark_limit_check_locked(struct res_counter *cnt)
> +{
> +	if (cnt->usage < cnt->high_wmark_limit)
> +		return true;
> +
> +	return false;
> +}
> +
> +static inline bool
> +res_counter_under_low_wmark_limit_check_locked(struct res_counter *cnt)
> +{
> +	if (cnt->usage < cnt->low_wmark_limit)
> +		return true;
> +
> +	return false;
> +}
> +
>  /**
>   * Get the difference between the usage and the soft limit
>   * @cnt: The counter
> @@ -169,6 +200,30 @@ res_counter_soft_limit_excess(struct res
>  	return excess;
>  }
> 
> +static inline bool
> +res_counter_under_low_wmark_limit(struct res_counter *cnt)
> +{
> +	bool ret;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	ret = res_counter_under_low_wmark_limit_check_locked(cnt);
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return ret;
> +}
> +
> +static inline bool
> +res_counter_under_high_wmark_limit(struct res_counter *cnt)
> +{
> +	bool ret;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	ret = res_counter_under_high_wmark_limit_check_locked(cnt);
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return ret;
> +}
> +
>  static inline void res_counter_reset_max(struct res_counter *cnt)
>  {
>  	unsigned long flags;
> @@ -214,4 +269,27 @@ res_counter_set_soft_limit(struct res_co
>  	return 0;
>  }
> 
> +static inline int
> +res_counter_set_high_wmark_limit(struct res_counter *cnt,
> +				unsigned long long wmark_limit)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	cnt->high_wmark_limit = wmark_limit;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return 0;
> +}
> +
> +static inline int
> +res_counter_set_low_wmark_limit(struct res_counter *cnt,
> +				unsigned long long wmark_limit)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	cnt->low_wmark_limit = wmark_limit;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return 0;
> +}
>  #endif
> Index: memcg/kernel/res_counter.c
> ===================================================================
> --- memcg.orig/kernel/res_counter.c
> +++ memcg/kernel/res_counter.c
> @@ -19,6 +19,8 @@ void res_counter_init(struct res_counter
>  	spin_lock_init(&counter->lock);
>  	counter->limit = RESOURCE_MAX;
>  	counter->soft_limit = RESOURCE_MAX;
> +	counter->low_wmark_limit = RESOURCE_MAX;
> +	counter->high_wmark_limit = RESOURCE_MAX;
>  	counter->parent = parent;
>  }
> 
> @@ -103,6 +105,10 @@ res_counter_member(struct res_counter *c
>  		return &counter->failcnt;
>  	case RES_SOFT_LIMIT:
>  		return &counter->soft_limit;
> +	case RES_LOW_WMARK_LIMIT:
> +		return &counter->low_wmark_limit;
> +	case RES_HIGH_WMARK_LIMIT:
> +		return &counter->high_wmark_limit;
>  	};
> 
>  	BUG();
> Index: memcg/mm/memcontrol.c
> ===================================================================
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -278,6 +278,11 @@ struct mem_cgroup {
>  	 */
>  	struct mem_cgroup_stat_cpu nocpu_base;
>  	spinlock_t pcp_counter_lock;
> +
> +	/*
> +	 * used to calculate the low/high_wmarks based on the limit_in_bytes.
> +	 */
> +	u64 high_wmark_distance;
>  };
> 
>  /* Stuffs for move charges at task migration. */
> @@ -867,6 +872,44 @@ out:
>  EXPORT_SYMBOL(mem_cgroup_count_vm_event);
>

Hmm... I wonder if we can start looking at the read side of
usage_in_bytes using RCU and reduce lock contention on cnt->lock. May
be an optimization for later. I still have my old per cpu counter
patches for usage_in_bytes that add some fuzz factor, but help improve
speed. I should rebase them and try.

 
>  /*
> + * If Hi-Low distance is too big, background reclaim tend to be cpu hogging.
> + * If Hi-Low distance is too small, small memory usage spike (by temporal
> + * shell scripts) causes background reclaim and make thing worse. But memory
> + * spike can be avoided by setting high-wmark a bit higier. We use fixed size
> + * size of HiLow Distance, this will be easy to use.
> + */
> +#ifdef CONFIG_64BIT /* object size tend do be twice */
> +#define HILOW_DISTANCE	(4 * 1024 * 1024)
> +#else
> +#define HILOW_DISTANCE	(2 * 1024 * 1024)
> +#endif
> +
> +static void setup_per_memcg_wmarks(struct mem_cgroup *mem)
> +{
> +	u64 limit;
> +
> +	limit = res_counter_read_u64(&mem->res, RES_LIMIT);
> +	if (mem->high_wmark_distance == 0) {
> +		res_counter_set_low_wmark_limit(&mem->res, limit);
> +		res_counter_set_high_wmark_limit(&mem->res, limit);
> +	} else {
> +		u64 low_wmark, high_wmark, low_distance;
> +		if (mem->high_wmark_distance <= HILOW_DISTANCE)
> +			low_distance = mem->high_wmark_distance / 2;
> +		else
> +			low_distance = HILOW_DISTANCE;
> +		if (low_distance < PAGE_SIZE * 2)
> +			low_distance = PAGE_SIZE * 2;
> +
> +		low_wmark = limit - low_distance;
> +		high_wmark = limit - mem->high_wmark_distance;
> +
> +		res_counter_set_low_wmark_limit(&mem->res, low_wmark);
> +		res_counter_set_high_wmark_limit(&mem->res, high_wmark);
> +	}
> +}
> +

I've not seen the documentation patch, but it might be good to have
some comments with what to expect the watermarks to be and who sets up
up high_wmark_distance. 

> +/*
>   * Following LRU functions are allowed to be used without PCG_LOCK.
>   * Operations are called by routine of global LRU independently from memcg.
>   * What we have to take care of here is validness of pc->mem_cgroup.
> @@ -3264,6 +3307,7 @@ static int mem_cgroup_resize_limit(struc
>  			else
>  				memcg->memsw_is_minimum = false;
>  		}
> +		setup_per_memcg_wmarks(memcg);
>  		mutex_unlock(&set_limit_mutex);
> 
>  		if (!ret)
> @@ -3324,6 +3368,7 @@ static int mem_cgroup_resize_memsw_limit
>  			else
>  				memcg->memsw_is_minimum = false;
>  		}
> +		setup_per_memcg_wmarks(memcg);
>  		mutex_unlock(&set_limit_mutex);
> 
>  		if (!ret)
> @@ -4603,6 +4648,30 @@ static void __init enable_swap_cgroup(vo
>  }
>  #endif
> 
> +/*
> + * We use low_wmark and high_wmark for triggering per-memcg kswapd.
> + * The reclaim is triggered by low_wmark (usage > low_wmark) and stopped
> + * by high_wmark (usage < high_wmark).
> + */
> +int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
> +				int charge_flags)
> +{
> +	long ret = 0;
> +	int flags = CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;
> +
> +	if (!mem->high_wmark_distance)
> +		return 1;
> +
> +	VM_BUG_ON((charge_flags & flags) == flags);
> +
> +	if (charge_flags & CHARGE_WMARK_LOW)
> +		ret = res_counter_under_low_wmark_limit(&mem->res);
> +	if (charge_flags & CHARGE_WMARK_HIGH)
> +		ret = res_counter_under_high_wmark_limit(&mem->res);
> +
> +	return ret;
> +}
> +
>  static int mem_cgroup_soft_limit_tree_init(void)
>  {
>  	struct mem_cgroup_tree_per_node *rtpn;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
