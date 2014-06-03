Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id ACADD6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 08:39:09 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id x48so6593582wes.22
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 05:39:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id au6si32108157wjc.98.2014.06.03.05.38.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 05:38:57 -0700 (PDT)
Date: Tue, 3 Jun 2014 14:38:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 01/10] mm: memcontrol: fold mem_cgroup_do_charge()
Message-ID: <20140603123836.GF1321@dhcp22.suse.cz>
References: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
 <1401380162-24121-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401380162-24121-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 29-05-14 12:15:53, Johannes Weiner wrote:
> This function was split out because mem_cgroup_try_charge() got too
> big.  But having essentially one sequence of operations arbitrarily
> split in half is not good for reworking the code.  Fold it back in.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 166 ++++++++++++++++++++++----------------------------------
>  1 file changed, 64 insertions(+), 102 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4df733e13727..c3c10ab98355 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2552,80 +2552,6 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
>  	return NOTIFY_OK;
>  }
>  
> -
> -/* See mem_cgroup_try_charge() for details */
> -enum {
> -	CHARGE_OK,		/* success */
> -	CHARGE_RETRY,		/* need to retry but retry is not bad */
> -	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
> -	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
> -};
> -
> -static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> -				unsigned int nr_pages, unsigned int min_pages,
> -				bool invoke_oom)
> -{
> -	unsigned long csize = nr_pages * PAGE_SIZE;
> -	struct mem_cgroup *mem_over_limit;
> -	struct res_counter *fail_res;
> -	unsigned long flags = 0;
> -	int ret;
> -
> -	ret = res_counter_charge(&memcg->res, csize, &fail_res);
> -
> -	if (likely(!ret)) {
> -		if (!do_swap_account)
> -			return CHARGE_OK;
> -		ret = res_counter_charge(&memcg->memsw, csize, &fail_res);
> -		if (likely(!ret))
> -			return CHARGE_OK;
> -
> -		res_counter_uncharge(&memcg->res, csize);
> -		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
> -		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
> -	} else
> -		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> -	/*
> -	 * Never reclaim on behalf of optional batching, retry with a
> -	 * single page instead.
> -	 */
> -	if (nr_pages > min_pages)
> -		return CHARGE_RETRY;
> -
> -	if (!(gfp_mask & __GFP_WAIT))
> -		return CHARGE_WOULDBLOCK;
> -
> -	if (gfp_mask & __GFP_NORETRY)
> -		return CHARGE_NOMEM;
> -
> -	ret = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
> -	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
> -		return CHARGE_RETRY;
> -	/*
> -	 * Even though the limit is exceeded at this point, reclaim
> -	 * may have been able to free some pages.  Retry the charge
> -	 * before killing the task.
> -	 *
> -	 * Only for regular pages, though: huge pages are rather
> -	 * unlikely to succeed so close to the limit, and we fall back
> -	 * to regular pages anyway in case of failure.
> -	 */
> -	if (nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER) && ret)
> -		return CHARGE_RETRY;
> -
> -	/*
> -	 * At task move, charge accounts can be doubly counted. So, it's
> -	 * better to wait until the end of task_move if something is going on.
> -	 */
> -	if (mem_cgroup_wait_acct_move(mem_over_limit))
> -		return CHARGE_RETRY;
> -
> -	if (invoke_oom)
> -		mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(csize));
> -
> -	return CHARGE_NOMEM;
> -}
> -
>  /**
>   * mem_cgroup_try_charge - try charging a memcg
>   * @memcg: memcg to charge
> @@ -2642,7 +2568,11 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
>  {
>  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>  	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> -	int ret;
> +	struct mem_cgroup *mem_over_limit;
> +	struct res_counter *fail_res;
> +	unsigned long nr_reclaimed;
> +	unsigned long flags = 0;
> +	unsigned long long size;
>  
>  	if (mem_cgroup_is_root(memcg))
>  		goto done;
> @@ -2662,44 +2592,76 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
>  
>  	if (gfp_mask & __GFP_NOFAIL)
>  		oom = false;
> -again:
> +retry:
>  	if (consume_stock(memcg, nr_pages))
>  		goto done;
>  
> -	do {
> -		bool invoke_oom = oom && !nr_oom_retries;
> +	size = batch * PAGE_SIZE;
> +	if (!res_counter_charge(&memcg->res, size, &fail_res)) {
> +		if (!do_swap_account)
> +			goto done_restock;
> +		if (!res_counter_charge(&memcg->memsw, size, &fail_res))
> +			goto done_restock;
> +		res_counter_uncharge(&memcg->res, size);
> +		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
> +		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
> +	} else
> +		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
>  
> -		/* If killed, bypass charge */
> -		if (fatal_signal_pending(current))
> -			goto bypass;
> +	if (batch > nr_pages) {
> +		batch = nr_pages;
> +		goto retry;
> +	}
>  
> -		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch,
> -					   nr_pages, invoke_oom);
> -		switch (ret) {
> -		case CHARGE_OK:
> -			break;
> -		case CHARGE_RETRY: /* not in OOM situation but retry */
> -			batch = nr_pages;
> -			goto again;
> -		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
> -			goto nomem;
> -		case CHARGE_NOMEM: /* OOM routine works */
> -			if (!oom || invoke_oom)
> -				goto nomem;
> -			nr_oom_retries--;
> -			break;
> -		}
> -	} while (ret != CHARGE_OK);
> +	if (!(gfp_mask & __GFP_WAIT))
> +		goto nomem;
>  
> -	if (batch > nr_pages)
> -		refill_stock(memcg, batch - nr_pages);
> -done:
> -	return 0;
> +	if (gfp_mask & __GFP_NORETRY)
> +		goto nomem;
> +
> +	nr_reclaimed = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
> +
> +	if (mem_cgroup_margin(mem_over_limit) >= batch)
> +		goto retry;
> +	/*
> +	 * Even though the limit is exceeded at this point, reclaim
> +	 * may have been able to free some pages.  Retry the charge
> +	 * before killing the task.
> +	 *
> +	 * Only for regular pages, though: huge pages are rather
> +	 * unlikely to succeed so close to the limit, and we fall back
> +	 * to regular pages anyway in case of failure.
> +	 */
> +	if (nr_reclaimed && batch <= (1 << PAGE_ALLOC_COSTLY_ORDER))
> +		goto retry;
> +	/*
> +	 * At task move, charge accounts can be doubly counted. So, it's
> +	 * better to wait until the end of task_move if something is going on.
> +	 */
> +	if (mem_cgroup_wait_acct_move(mem_over_limit))
> +		goto retry;
> +
> +	if (fatal_signal_pending(current))
> +		goto bypass;
> +
> +	if (!oom)
> +		goto nomem;
> +
> +	if (nr_oom_retries--)
> +		goto retry;
> +
> +	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
>  nomem:
>  	if (!(gfp_mask & __GFP_NOFAIL))
>  		return -ENOMEM;
>  bypass:
>  	return -EINTR;
> +
> +done_restock:
> +	if (batch > nr_pages)
> +		refill_stock(memcg, batch - nr_pages);
> +done:
> +	return 0;
>  }
>  
>  /**
> -- 
> 1.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
