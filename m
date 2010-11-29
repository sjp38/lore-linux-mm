Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8887B6B0088
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 09:02:40 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oATDrqx0011470
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 08:54:38 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7525D728045
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 09:02:37 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oATE2bL9158780
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 09:02:37 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oATE2aEM006731
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 09:02:37 -0500
Date: Mon, 29 Nov 2010 19:32:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Question about cgroup hierarchy and reducing memory limit
Message-ID: <20101129140233.GA4199@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <AANLkTingzd3Pqrip1izfkLm+HCE9jRQL777nu9s3RnLv@mail.gmail.com>
 <20101124094736.3c4ba760.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTimSRJ6GC3=bddNMfnVE3LmMx-9xSY2GX_XNvzCA@mail.gmail.com>
 <20101125100428.24920cd3.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTinQ_sqpEc=-vcCQvpp98ny5HSDVvqD_R6_YE3-C@mail.gmail.com>
 <20101129155858.6af29381.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101129155858.6af29381.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Evgeniy Ivanov <lolkaantimat@gmail.com>, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-11-29 15:58:58]:

> On Thu, 25 Nov 2010 13:51:06 +0300
> Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:
> 
> > That would be great, thanks!
> > For now we decided either to use decreasing limits in script with
> > timeout or controlling the limit just by root group.
> > 
> 
> I wrote a patch as below but I also found that "success" of shrkinking limit 
> means easy OOM Kill because we don't have wait-for-writeback logic.
> 
> Now, -EBUSY seems to be a safe guard logic against OOM KILL.
> I'd like to wait for the merge of dirty_ratio logic and test this again.
> I hope it helps.
> 
> Thanks,
> -Kame
> ==
> At changing limit of memory cgroup, we see many -EBUSY when
>  1. Cgroup is small.
>  2. Some tasks are accessing pages very frequently.
> 
> It's not very covenient. This patch makes memcg to be in "shrinking" mode
> when the limit is shrinking. This patch does,
> 
>  a) block new allocation.
>  b) ignore page reference bit at shrinking.
> 
> The admin should know what he does...
> 
> Need:
>  - dirty_ratio for avoid OOM.
>  - Documentation update.
> 
> Note:
>  - Sudden shrinking of memory limit tends to cause OOM.
>    We need dirty_ratio patch before merging this.
> 
> Reported-by: Evgeniy Ivanov <lolkaantimat@gmail.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    6 +++++
>  mm/memcontrol.c            |   48 +++++++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                |    2 +
>  3 files changed, 56 insertions(+)
> 
> Index: mmotm-1117/mm/memcontrol.c
> ===================================================================
> --- mmotm-1117.orig/mm/memcontrol.c
> +++ mmotm-1117/mm/memcontrol.c
> @@ -239,6 +239,7 @@ struct mem_cgroup {
>  	unsigned int	swappiness;
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
> +	atomic_t	shrinking;
> 
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
> @@ -1814,6 +1815,25 @@ static int __cpuinit memcg_cpu_hotplug_c
>  	return NOTIFY_OK;
>  }
> 
> +static DECLARE_WAIT_QUEUE_HEAD(memcg_shrink_waitq);
> +
> +bool mem_cgroup_shrinking(struct mem_cgroup *mem)

I prefer is_mem_cgroup_shrinking

> +{
> +	return atomic_read(&mem->shrinking) > 0;
> +}
> +
> +void mem_cgroup_shrink_wait(struct mem_cgroup *mem)
> +{
> +	wait_queue_t wait;
> +
> +	init_wait(&wait);
> +	prepare_to_wait(&memcg_shrink_waitq, &wait, TASK_INTERRUPTIBLE);
> +	smp_rmb();

Why the rmb?

> +	if (mem_cgroup_shrinking(mem))
> +		schedule();

We need to check for signals if we sleep with TASK_INTERRUPTIBLE, but
that complicates the entire path as well. May be the question to ask
is - why is this TASK_INTERRUPTIBLE, what is the expected delay. Could
this be a fairness issue as well?

> +	finish_wait(&memcg_shrink_waitq, &wait);
> +}
> +
> 
>  /* See __mem_cgroup_try_charge() for details */
>  enum {
> @@ -1832,6 +1852,17 @@ static int __mem_cgroup_do_charge(struct
>  	unsigned long flags = 0;
>  	int ret;
> 
> +	/*
> + 	 * If shrinking() == true, admin is now reducing limit of memcg and
> + 	 * reclaiming memory eagerly. This _new_ charge will increase usage and
> + 	 * prevents the system from setting new limit. We add delay here and
> + 	 * make reducing size easier.
> + 	 */
> +	if (unlikely(mem_cgroup_shrinking(mem)) && (gfp_mask & __GFP_WAIT)) {
> +		mem_cgroup_shrink_wait(mem);
> +		return CHARGE_RETRY;
> +	}
> +

Oh! oh! I'd hate to do this in the fault path

>  	ret = res_counter_charge(&mem->res, csize, &fail_res);
> 
>  	if (likely(!ret)) {
> @@ -1984,6 +2015,7 @@ again:
>  			csize = PAGE_SIZE;
>  			css_put(&mem->css);
>  			mem = NULL;
> +			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  			goto again;
>  		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
>  			css_put(&mem->css);
> @@ -2938,12 +2970,14 @@ static DEFINE_MUTEX(set_limit_mutex);
>  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  				unsigned long long val)
>  {
> +	struct mem_cgroup *iter;
>  	int retry_count;
>  	u64 memswlimit, memlimit;
>  	int ret = 0;
>  	int children = mem_cgroup_count_children(memcg);
>  	u64 curusage, oldusage;
>  	int enlarge;
> +	int need_unset_shrinking = 0;
> 
>  	/*
>  	 * For keeping hierarchical_reclaim simple, how long we should retry
> @@ -2954,6 +2988,14 @@ static int mem_cgroup_resize_limit(struc
> 
>  	oldusage = res_counter_read_u64(&memcg->res, RES_USAGE);
> 
> +	/*
> +	 * At reducing limit, new charges should be delayed.
> +	 */
> +	if (val < res_counter_read_u64(&memcg->res, RES_LIMIT)) {
> +		need_unset_shrinking = 1;
> +		for_each_mem_cgroup_tree(iter, memcg)
> +			atomic_inc(&iter->shrinking);
> +	}
>  	enlarge = 0;
>  	while (retry_count) {
>  		if (signal_pending(current)) {
> @@ -3001,6 +3043,12 @@ static int mem_cgroup_resize_limit(struc
>  	if (!ret && enlarge)
>  		memcg_oom_recover(memcg);
> 
> +	if (need_unset_shrinking) {
> +		for_each_mem_cgroup_tree(iter, memcg)
> +			atomic_dec(&iter->shrinking);
> +		wake_up_all(&memcg_shrink_waitq);
> +	}
> +
>  	return ret;
>  }
> 
> Index: mmotm-1117/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-1117.orig/include/linux/memcontrol.h
> +++ mmotm-1117/include/linux/memcontrol.h
> @@ -146,6 +146,8 @@ unsigned long mem_cgroup_soft_limit_recl
>  						gfp_t gfp_mask);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> 
> +bool mem_cgroup_shrinking(struct mem_cgroup *mem);
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct mem_cgroup;
> 
> @@ -336,6 +338,10 @@ u64 mem_cgroup_get_limit(struct mem_cgro
>  	return 0;
>  }
> 
> +static inline bool mem_cgroup_shrinking(struct mem_cgroup *mem);
> +{
> +	return false;
> +}
>  #endif /* CONFIG_CGROUP_MEM_CONT */
> 
>  #endif /* _LINUX_MEMCONTROL_H */
> Index: mmotm-1117/mm/vmscan.c
> ===================================================================
> --- mmotm-1117.orig/mm/vmscan.c
> +++ mmotm-1117/mm/vmscan.c
> @@ -617,6 +617,8 @@ static enum page_references page_check_r
>  	/* Lumpy reclaim - ignore references */
>  	if (sc->lumpy_reclaim_mode != LUMPY_MODE_NONE)
>  		return PAGEREF_RECLAIM;
> +	if (!scanning_global_lru(sc) && mem_cgroup_shrinking(sc->mem_cgroup))
> +		return PAGEREF_RECLAIM;
> 
>  	/*
>  	 * Mlock lost the isolation race with us.  Let try_to_unmap()
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
