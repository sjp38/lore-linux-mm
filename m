Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA72E6B00A1
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 04:57:45 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n0J9vYuO027796
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 15:27:34 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0J9tceE3190848
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 15:25:38 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n0J9vYRF020792
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 20:57:34 +1100
Date: Mon, 19 Jan 2009 15:27:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH] memcg: fix infinite loop
Message-ID: <20090119095738.GG6039@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <496ED2B7.5050902@cn.fujitsu.com> <20090119174922.a30146be.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090119174922.a30146be.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-19 17:49:22]:

> On Thu, 15 Jan 2009 14:07:51 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> > 1. task p1 is in /memcg/0
> > 2. p1 does mmap(4096*2, MAP_LOCKED)
> > 3. echo 4096 > /memcg/0/memory.limit_in_bytes
> > 
> > The above 'echo' will never return, unless p1 exited or freed the memory.
> > The cause is we can't reclaim memory from p1, so the while loop in
> > mem_cgroup_resize_limit() won't break.
> > 
> > This patch fixes it by decrementing retry_count regardless the return value
> > of mem_cgroup_hierarchical_reclaim().
> > 
> 
> Maybe a patch like this is necessary.  But details are not fixed yet. 
> Any comments are welcome.
> 
> (This is base on my CSS ID patch set.)
> 
> -Kame
> ==
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> As Li Zefan pointed out, shrinking memcg's limit should return -EBUSY
> after reasonable retries. This patch tries to fix the current behavior
> of shrink_usage.
> 
> Before looking into "shrink should return -EBUSY" problem, we should fix
> hierarchical reclaim code. It compares current usage and current limit,
> but it only makes sense when the kernel reclaims memory because hit limits.
> This is also a problem.
> 
> What this patch does are.
> 
>   1. add new argument "shrink" to hierarchical reclaim. If "shrink==true",
>      hierarchical reclaim returns immediately and the caller checks the kernel
>      should shrink more or not.
>      (At shrinking memory, usage is always smaller than limit. So check for
>       usage < limit is useless.)
> 
>   2. For adjusting to above change, 2 changes in "shrink"'s retry path.
>      2-a. retry_count depends on # of children because the kernel visits
> 	  the children under hierarchy one by one.
>      2-b. rather than checking return value of hierarchical_reclaim's progress,
> 	  compares usage-before-shrink and usage-after-shrink.
> 	  If usage-before-shrink > usage-after-shrink, retry_count is
> 	  decremented.

The code seems to do the reverse, it checks for
        if (currusage >= oldusage)

> 
> Reported-by: Li Zefan <lizf@cn.fujitsu.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 60 insertions(+), 11 deletions(-)
> 
> Index: mmotm-2.6.29-Jan16/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.29-Jan16.orig/mm/memcontrol.c
> +++ mmotm-2.6.29-Jan16/mm/memcontrol.c
> @@ -696,6 +696,23 @@ static int mem_cgroup_walk_tree(struct m
>  	return ret;
>  }
> 
> +static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
> +{
> +	int *val = data;
> +	(*val)++;
> +	return 0;
> +}
> +
> +static int mem_cgroup_count_children(struct mem_cgroup *mem)
> +{
> +	int num = 0;
> +	rcu_read_lock();
> + 	mem_cgroup_walk_tree(mem, &num, mem_cgroup_count_children_cb);
> +	rcu_read_unlock();
> +
> +	return num;
> +}
> +
>  /*
>   * Visit the first child (need not be the first child as per the ordering
>   * of the cgroup list, since we track last_scanned_child) of @mem and use
> @@ -752,9 +769,12 @@ mem_cgroup_select_victim(struct mem_cgro
>   * We give up and return to the caller when scan_age is increased by 2. This
>   * means try_to_free_mem_cgroup_pages() is called against all children cgroup,
>   * at least once. The caller itself will do further retry if necessary.
> + *
> + * If shrink==true, this routine doesn't check usage < limit, and just return
> + * quickly. It depends on callers whether shrinking is enough or not.
>   */
>  static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> -						gfp_t gfp_mask, bool noswap)
> +				gfp_t gfp_mask, bool noswap, bool shrink)
>  {
>  	struct mem_cgroup *victim;
>  	unsigned long start_age;
> @@ -782,6 +802,13 @@ static int mem_cgroup_hierarchical_recla
>  		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap,
>  						   get_swappiness(victim));
>  		css_put(&victim->css);
> +		/*
> +		 * At shrinking usage, we can't check we should stop here or
> +		 * reclaim more. It's depends on callers. last_scanned_child
> +		 * will work enough for doing round-robin.
> +		 */
> +		if (shrink)
> +			return ret;
>  		total += ret;
>  		if (mem_cgroup_check_under_limit(root_mem))
>  			return 1 + total;
> @@ -867,7 +894,7 @@ static int __mem_cgroup_try_charge(struc
>  			goto nomem;
> 
>  		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> -							noswap);
> +							noswap, false);
>  		if (ret)
>  			continue;
> 
> @@ -1488,6 +1515,7 @@ int mem_cgroup_shrink_usage(struct page 
>  	struct mem_cgroup *mem = NULL;
>  	int progress = 0;
>  	int retry = MEM_CGROUP_RECLAIM_RETRIES;
> +	int children;
> 
>  	if (mem_cgroup_disabled())
>  		return 0;
> @@ -1499,7 +1527,8 @@ int mem_cgroup_shrink_usage(struct page 
>  		return 0;
> 
>  	do {
> -		progress = mem_cgroup_hierarchical_reclaim(mem, gfp_mask, true);
> +		progress = mem_cgroup_hierarchical_reclaim(mem,
> +					gfp_mask, true, false);
>  		progress += mem_cgroup_check_under_limit(mem);
>  	} while (!progress && --retry);
> 
> @@ -1514,11 +1543,21 @@ static DEFINE_MUTEX(set_limit_mutex);
>  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  				unsigned long long val)
>  {
> -
> -	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
> +	int retry_count;
>  	int progress;
>  	u64 memswlimit;
>  	int ret = 0;
> +	int children = mem_cgroup_count_children(memcg);
> +	u64 curusage, oldusage, minusage;
> +
> +	/*
> +	 * For keeping hierarchical_reclaim simple, how long we should retry
> +	 * is depends on callers. We set our retry-count to be function
> +	 * of # of children which we should visit in this loop.
> +	 */
> +	retry_count = MEM_CGROUP_RECLAIM_RETRIES * children;
> +
> +	oldusage = res_counter_read_u64(&memcg->res, RES_USAGE);
> 
>  	while (retry_count) {
>  		if (signal_pending(current)) {
> @@ -1544,8 +1583,13 @@ static int mem_cgroup_resize_limit(struc
>  			break;
> 
>  		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
> -							   false);
> -  		if (!progress)			retry_count--;
> +						   false, true);
> +		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
> +		/* Usage is reduced ? */
> +  		if (curusage >= oldusage)
> +			retry_count--;
> +		else
> +			oldusage = curusage;
>  	}
> 
>  	return ret;
> @@ -1554,13 +1598,16 @@ static int mem_cgroup_resize_limit(struc
>  int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  				unsigned long long val)
>  {
> -	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
> +	int retry_count;
>  	u64 memlimit, oldusage, curusage;
> +	int children = mem_cgroup_count_children(memcg);
>  	int ret;
> 
>  	if (!do_swap_account)
>  		return -EINVAL;
> -
> +	/* see mem_cgroup_resize_res_limit */
> + 	retry_count = children * MEM_CGROUP_RECLAIM_RETRIES;
> +	oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  	while (retry_count) {
>  		if (signal_pending(current)) {
>  			ret = -EINTR;
> @@ -1584,11 +1631,13 @@ int mem_cgroup_resize_memsw_limit(struct
>  		if (!ret)
>  			break;
> 
> -		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> -		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true);
> +		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
>  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> +		/* Usage is reduced ? */
>  		if (curusage >= oldusage)
>  			retry_count--;
> +		else
> +			oldusage = curusage;
>  	}
>  	return ret;
>  }

Has this been tested? It seems OK to the naked eye :)

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
