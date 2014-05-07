Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 64FA46B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 10:43:42 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so841816eek.1
        for <linux-mm@kvack.org>; Wed, 07 May 2014 07:43:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s46si16574236eeg.165.2014.05.07.07.43.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 07:43:40 -0700 (PDT)
Date: Wed, 7 May 2014 16:43:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/9] mm: memcontrol: retry reclaim for oom-disabled and
 __GFP_NOFAIL charges
Message-ID: <20140507144339.GI9489@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398889543-23671-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 30-04-14 16:25:37, Johannes Weiner wrote:
> There is no reason why oom-disabled and __GFP_NOFAIL charges should
> try to reclaim only once when every other charge tries several times
> before giving up.  Make them all retry the same number of times.

I guess the idea whas that oom disabled (THP) allocation can fallback to
a smaller allocation. I would suspect this would increase latency for
THP page faults.

__GFP_NOFAIL is a different story and it can be retried.
 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6ce59146fec7..c431a30280ac 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2589,7 +2589,7 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
>  				 bool oom)
>  {
>  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
> -	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  	struct mem_cgroup *mem_over_limit;
>  	struct res_counter *fail_res;
>  	unsigned long nr_reclaimed;
> @@ -2660,6 +2660,9 @@ retry:
>  	if (mem_cgroup_wait_acct_move(mem_over_limit))
>  		goto retry;
>  
> +	if (nr_retries--)
> +		goto retry;
> +
>  	if (gfp_mask & __GFP_NOFAIL)
>  		goto bypass;
>  
> @@ -2669,9 +2672,6 @@ retry:
>  	if (!oom)
>  		goto nomem;
>  
> -	if (nr_oom_retries--)
> -		goto retry;
> -
>  	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
>  nomem:
>  	if (!(gfp_mask & __GFP_NOFAIL))
> -- 
> 1.9.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
