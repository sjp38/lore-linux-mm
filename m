Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 752966B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 03:32:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 10so15321334wml.4
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 00:32:56 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id l130si1722902wmd.126.2017.06.02.00.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 00:32:55 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id g15so16788322wmc.2
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 00:32:55 -0700 (PDT)
Subject: Re: [PATCH] memcg: refactor mem_cgroup_resize_limit()
References: <20170601230212.30578-1-yuzhao@google.com>
From: Nikolay Borisov <n.borisov.lkml@gmail.com>
Message-ID: <7c1be205-837f-30f9-9161-9c8ed4689216@gmail.com>
Date: Fri, 2 Jun 2017 10:32:52 +0300
MIME-Version: 1.0
In-Reply-To: <20170601230212.30578-1-yuzhao@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On  2.06.2017 02:02, Yu Zhao wrote:
> mem_cgroup_resize_limit() and mem_cgroup_resize_memsw_limit() have
> identical logics. Refactor code so we don't need to keep two pieces
> of code that does same thing.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  mm/memcontrol.c | 71 +++++++++------------------------------------------------
>  1 file changed, 11 insertions(+), 60 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 94172089f52f..a4f0daaff704 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2422,13 +2422,14 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
>  static DEFINE_MUTEX(memcg_limit_mutex);
>  
>  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> -				   unsigned long limit)
> +				   unsigned long limit, bool memsw)
>  {
>  	unsigned long curusage;
>  	unsigned long oldusage;
>  	bool enlarge = false;
>  	int retry_count;
>  	int ret;
> +	struct page_counter *counter = memsw ? &memcg->memsw : &memcg->memory;
>  
>  	/*
>  	 * For keeping hierarchical_reclaim simple, how long we should retry
> @@ -2438,58 +2439,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
>  		      mem_cgroup_count_children(memcg);
>  
> -	oldusage = page_counter_read(&memcg->memory);
> -
> -	do {
> -		if (signal_pending(current)) {
> -			ret = -EINTR;
> -			break;
> -		}
> -
> -		mutex_lock(&memcg_limit_mutex);
> -		if (limit > memcg->memsw.limit) {
> -			mutex_unlock(&memcg_limit_mutex);
> -			ret = -EINVAL;
> -			break;
> -		}
> -		if (limit > memcg->memory.limit)
> -			enlarge = true;
> -		ret = page_counter_limit(&memcg->memory, limit);
> -		mutex_unlock(&memcg_limit_mutex);
> -
> -		if (!ret)
> -			break;
> -
> -		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, true);
> -
> -		curusage = page_counter_read(&memcg->memory);
> -		/* Usage is reduced ? */
> -		if (curusage >= oldusage)
> -			retry_count--;
> -		else
> -			oldusage = curusage;
> -	} while (retry_count);
> -
> -	if (!ret && enlarge)
> -		memcg_oom_recover(memcg);
> -
> -	return ret;
> -}
> -
> -static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> -					 unsigned long limit)
> -{
> -	unsigned long curusage;
> -	unsigned long oldusage;
> -	bool enlarge = false;
> -	int retry_count;
> -	int ret;
> -
> -	/* see mem_cgroup_resize_res_limit */
> -	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
> -		      mem_cgroup_count_children(memcg);
> -
> -	oldusage = page_counter_read(&memcg->memsw);
> +	oldusage = page_counter_read(counter);
>  
>  	do {
>  		if (signal_pending(current)) {
> @@ -2498,22 +2448,23 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  		}
>  
>  		mutex_lock(&memcg_limit_mutex);
> -		if (limit < memcg->memory.limit) {
> +		if (memsw ? limit < memcg->memory.limit :
> +			    limit > memcg->memsw.limit) {

No, just no. Please createa a local variable and use that. Using the
ternary operator in an 'if' statement is just ugly!

>  			mutex_unlock(&memcg_limit_mutex);
>  			ret = -EINVAL;
>  			break;
>  		}
> -		if (limit > memcg->memsw.limit)
> +		if (limit > counter->limit)
>  			enlarge = true;
> -		ret = page_counter_limit(&memcg->memsw, limit);
> +		ret = page_counter_limit(counter, limit);
>  		mutex_unlock(&memcg_limit_mutex);
>  
>  		if (!ret)
>  			break;
>  
> -		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, false);
> +		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, !memsw);
>  
> -		curusage = page_counter_read(&memcg->memsw);
> +		curusage = page_counter_read(counter);
>  		/* Usage is reduced ? */
>  		if (curusage >= oldusage)
>  			retry_count--;
> @@ -2975,10 +2926,10 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
>  		}
>  		switch (MEMFILE_TYPE(of_cft(of)->private)) {
>  		case _MEM:
> -			ret = mem_cgroup_resize_limit(memcg, nr_pages);
> +			ret = mem_cgroup_resize_limit(memcg, nr_pages, false);
>  			break;
>  		case _MEMSWAP:
> -			ret = mem_cgroup_resize_memsw_limit(memcg, nr_pages);
> +			ret = mem_cgroup_resize_limit(memcg, nr_pages, true);
>  			break;
>  		case _KMEM:
>  			ret = memcg_update_kmem_limit(memcg, nr_pages);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
