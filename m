Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E4E216B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 08:53:31 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c3so13220198wrd.0
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 05:53:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l43si2185966wrl.470.2017.12.20.05.53.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 05:53:30 -0800 (PST)
Date: Wed, 20 Dec 2017 14:53:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
Message-ID: <20171220135329.GS4831@dhcp22.suse.cz>
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
 <20171220132114.6883-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171220132114.6883-1-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 20-12-17 16:21:13, Andrey Ryabinin wrote:
> mem_cgroup_resize_[memsw]_limit() tries to free only 32 (SWAP_CLUSTER_MAX)
> pages on each iteration. This makes practically impossible to decrease
> limit of memory cgroup. Tasks could easily allocate back 32 pages,
> so we can't reduce memory usage, and once retry_count reaches zero we return
> -EBUSY.
> 
> Easy to reproduce the problem by running the following commands:
> 
>   mkdir /sys/fs/cgroup/memory/test
>   echo $$ >> /sys/fs/cgroup/memory/test/tasks
>   cat big_file > /dev/null &
>   sleep 1 && echo $((100*1024*1024)) > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
>   -bash: echo: write error: Device or resource busy
> 
> Instead of relying on retry_count, keep trying to free required amount of pages
> until reclaimer makes any progress.

The wording of the changelog has some room for improvements. The last
sentence should read something like "Instead of relying on retry_count,
keep retrying the reclaim until the desired limit is reached or fail
if the reclaim doesn't make any progress or a signal is pending."

I am bussy as hell today so I will look closer tomorrow or on Friday.
But from a very quick glance the patch seems reasonable.
 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  mm/memcontrol.c | 70 +++++++++++++--------------------------------------------
>  1 file changed, 16 insertions(+), 54 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f40b5ad3f959..0d26db9a665d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1176,20 +1176,6 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  }
>  
>  /*
> - * This function returns the number of memcg under hierarchy tree. Returns
> - * 1(self count) if no children.
> - */
> -static int mem_cgroup_count_children(struct mem_cgroup *memcg)
> -{
> -	int num = 0;
> -	struct mem_cgroup *iter;
> -
> -	for_each_mem_cgroup_tree(iter, memcg)
> -		num++;
> -	return num;
> -}
> -
> -/*
>   * Return the memory (and swap, if configured) limit for a memcg.
>   */
>  unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
> @@ -2462,22 +2448,10 @@ static DEFINE_MUTEX(memcg_limit_mutex);
>  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  				   unsigned long limit)
>  {
> -	unsigned long curusage;
> -	unsigned long oldusage;
> +	unsigned long usage;
>  	bool enlarge = false;
> -	int retry_count;
>  	int ret;
>  
> -	/*
> -	 * For keeping hierarchical_reclaim simple, how long we should retry
> -	 * is depends on callers. We set our retry-count to be function
> -	 * of # of children which we should visit in this loop.
> -	 */
> -	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
> -		      mem_cgroup_count_children(memcg);
> -
> -	oldusage = page_counter_read(&memcg->memory);
> -
>  	do {
>  		if (signal_pending(current)) {
>  			ret = -EINTR;
> @@ -2498,15 +2472,13 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, true);
> -
> -		curusage = page_counter_read(&memcg->memory);
> -		/* Usage is reduced ? */
> -		if (curusage >= oldusage)
> -			retry_count--;
> -		else
> -			oldusage = curusage;
> -	} while (retry_count);
> +		usage = page_counter_read(&memcg->memory);
> +		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
> +					GFP_KERNEL, true)) {
> +			ret = -EBUSY;
> +			break;
> +		}
> +	} while (true);
>  
>  	if (!ret && enlarge)
>  		memcg_oom_recover(memcg);
> @@ -2517,18 +2489,10 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  					 unsigned long limit)
>  {
> -	unsigned long curusage;
> -	unsigned long oldusage;
> +	unsigned long usage;
>  	bool enlarge = false;
> -	int retry_count;
>  	int ret;
>  
> -	/* see mem_cgroup_resize_res_limit */
> -	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
> -		      mem_cgroup_count_children(memcg);
> -
> -	oldusage = page_counter_read(&memcg->memsw);
> -
>  	do {
>  		if (signal_pending(current)) {
>  			ret = -EINTR;
> @@ -2549,15 +2513,13 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, false);
> -
> -		curusage = page_counter_read(&memcg->memsw);
> -		/* Usage is reduced ? */
> -		if (curusage >= oldusage)
> -			retry_count--;
> -		else
> -			oldusage = curusage;
> -	} while (retry_count);
> +		usage = page_counter_read(&memcg->memsw);
> +		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
> +					GFP_KERNEL, false)) {
> +			ret = -EBUSY;
> +			break;
> +		}
> +	} while (true);
>  
>  	if (!ret && enlarge)
>  		memcg_oom_recover(memcg);
> -- 
> 2.13.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
