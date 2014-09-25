Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCF26B0038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 11:27:59 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id y10so8300131wgg.2
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 08:27:58 -0700 (PDT)
Received: from mail-we0-x230.google.com (mail-we0-x230.google.com [2a00:1450:400c:c03::230])
        by mx.google.com with ESMTPS id hm9si3210957wjb.40.2014.09.25.08.27.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 08:27:57 -0700 (PDT)
Received: by mail-we0-f176.google.com with SMTP id w61so7266667wes.7
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 08:27:57 -0700 (PDT)
Date: Thu, 25 Sep 2014 17:27:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/3] mm: memcontrol: simplify detecting when the
 memory+swap limit is hit
Message-ID: <20140925152754.GF11080@dhcp22.suse.cz>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
 <1411571338-8178-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411571338-8178-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 24-09-14 11:08:57, Johannes Weiner wrote:
> When attempting to charge pages, we first charge the memory counter
> and then the memory+swap counter.  If one of the counters is at its
> limit, we enter reclaim, but if it's the memory+swap counter, reclaim
> shouldn't swap because that wouldn't change the situation.  However,
> if the counters have the same limits, we never get to the memory+swap
> limit.  To know whether reclaim should swap or not, there is a state
> flag that indicates whether the limits are equal and whether hitting
> the memory limit implies hitting the memory+swap limit.
> 
> Just try the memory+swap counter first.

OK, this makes sense and makes the reclaim code little bit more
readable (). I would just add that the patch shouldn't have any visible
effectes because that is not apparent from the description.

> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 47 +++++++++++++----------------------------------
>  1 file changed, 13 insertions(+), 34 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1ec22bf380d0..89c920156c2a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -315,9 +315,6 @@ struct mem_cgroup {
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
>  
> -	/* set when res.limit == memsw.limit */
> -	bool		memsw_is_minimum;
> -
>  	/* protect arrays of thresholds */
>  	struct mutex thresholds_lock;
>  
> @@ -1804,8 +1801,6 @@ static unsigned long mem_cgroup_reclaim(struct mem_cgroup *memcg,
>  
>  	if (flags & MEM_CGROUP_RECLAIM_NOSWAP)
>  		noswap = true;
> -	if (!(flags & MEM_CGROUP_RECLAIM_SHRINK) && memcg->memsw_is_minimum)
> -		noswap = true;
>  
>  	for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
>  		if (loop)
> @@ -2543,16 +2538,17 @@ retry:
>  		goto done;
>  
>  	size = batch * PAGE_SIZE;
> -	if (!res_counter_charge(&memcg->res, size, &fail_res)) {
> -		if (!do_swap_account)
> +	if (!do_swap_account ||
> +	    !res_counter_charge(&memcg->memsw, size, &fail_res)) {
> +		if (!res_counter_charge(&memcg->res, size, &fail_res))
>  			goto done_restock;
> -		if (!res_counter_charge(&memcg->memsw, size, &fail_res))
> -			goto done_restock;
> -		res_counter_uncharge(&memcg->res, size);
> +		if (do_swap_account)
> +			res_counter_uncharge(&memcg->memsw, size);
> +		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> +	} else {
>  		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
>  		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
> -	} else
> -		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> +	}
>  
>  	if (batch > nr_pages) {
>  		batch = nr_pages;
> @@ -3615,7 +3611,6 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  				unsigned long long val)
>  {
>  	int retry_count;
> -	u64 memswlimit, memlimit;
>  	int ret = 0;
>  	int children = mem_cgroup_count_children(memcg);
>  	u64 curusage, oldusage;
> @@ -3642,24 +3637,16 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
>  		 */
>  		mutex_lock(&set_limit_mutex);
> -		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> -		if (memswlimit < val) {
> +		if (res_counter_read_u64(&memcg->memsw, RES_LIMIT) < val) {
>  			ret = -EINVAL;
>  			mutex_unlock(&set_limit_mutex);
>  			break;
>  		}
>  
> -		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> -		if (memlimit < val)
> +		if (res_counter_read_u64(&memcg->res, RES_LIMIT) < val)
>  			enlarge = 1;
>  
>  		ret = res_counter_set_limit(&memcg->res, val);
> -		if (!ret) {
> -			if (memswlimit == val)
> -				memcg->memsw_is_minimum = true;
> -			else
> -				memcg->memsw_is_minimum = false;
> -		}
>  		mutex_unlock(&set_limit_mutex);
>  
>  		if (!ret)
> @@ -3684,7 +3671,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  					unsigned long long val)
>  {
>  	int retry_count;
> -	u64 memlimit, memswlimit, oldusage, curusage;
> +	u64 oldusage, curusage;
>  	int children = mem_cgroup_count_children(memcg);
>  	int ret = -EBUSY;
>  	int enlarge = 0;
> @@ -3703,22 +3690,14 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
>  		 */
>  		mutex_lock(&set_limit_mutex);
> -		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> -		if (memlimit > val) {
> +		if (res_counter_read_u64(&memcg->res, RES_LIMIT) > val) {
>  			ret = -EINVAL;
>  			mutex_unlock(&set_limit_mutex);
>  			break;
>  		}
> -		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> -		if (memswlimit < val)
> +		if (res_counter_read_u64(&memcg->memsw, RES_LIMIT) < val)
>  			enlarge = 1;
>  		ret = res_counter_set_limit(&memcg->memsw, val);
> -		if (!ret) {
> -			if (memlimit == val)
> -				memcg->memsw_is_minimum = true;
> -			else
> -				memcg->memsw_is_minimum = false;
> -		}
>  		mutex_unlock(&set_limit_mutex);
>  
>  		if (!ret)
> -- 
> 2.1.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
