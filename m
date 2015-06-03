Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2CFE8900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 16:31:53 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so104095329wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 13:31:52 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id q14si3216367wju.110.2015.06.03.13.31.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 13:31:51 -0700 (PDT)
Received: by wiga1 with SMTP id a1so27009653wig.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 13:31:51 -0700 (PDT)
Date: Wed, 3 Jun 2015 22:31:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 -mm 1/2] memcg: remove unused mem_cgroup->oom_wakeups
Message-ID: <20150603203148.GA5386@dhcp22.suse.cz>
References: <20150603023824.GA7579@mtj.duckdns.org>
 <20150603151953.GF20091@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150603151953.GF20091@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu 04-06-15 00:19:53, Tejun Heo wrote:
> Since 4942642080ea ("mm: memcg: handle non-error OOM situations more
> gracefully"), nobody uses mem_cgroup->oom_wakeups.  Remove it.
> 
> While at it, also fold memcg_wakeup_oom() into memcg_oom_recover()
> which is its only user.  This cleanup was suggested by Michal.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Michal Hocko <mhocko@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
> Patch updated.  I dropped the comment as it's kinda obvious from the
> context and the use of __wake_up().
> 
> Thanks.
> 
>  mm/memcontrol.c |   10 +---------
>  1 file changed, 1 insertion(+), 9 deletions(-)
> 
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -287,7 +287,6 @@ struct mem_cgroup {
>  
>  	bool		oom_lock;
>  	atomic_t	under_oom;
> -	atomic_t	oom_wakeups;
>  
>  	int	swappiness;
>  	/* OOM-Killer disable */
> @@ -1850,17 +1849,10 @@ static int memcg_oom_wake_function(wait_
>  	return autoremove_wake_function(wait, mode, sync, arg);
>  }
>  
> -static void memcg_wakeup_oom(struct mem_cgroup *memcg)
> -{
> -	atomic_inc(&memcg->oom_wakeups);
> -	/* for filtering, pass "memcg" as argument. */
> -	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
> -}
> -
>  static void memcg_oom_recover(struct mem_cgroup *memcg)
>  {
>  	if (memcg && atomic_read(&memcg->under_oom))
> -		memcg_wakeup_oom(memcg);
> +		__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
>  }
>  
>  static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
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
