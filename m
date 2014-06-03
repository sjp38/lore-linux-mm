Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5856B0037
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 08:54:41 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id l18so6613166wgh.11
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 05:54:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ez12si2112994wid.26.2014.06.03.05.54.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 05:54:40 -0700 (PDT)
Date: Tue, 3 Jun 2014 14:54:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 02/10] mm: memcontrol: rearrange charging fast path
Message-ID: <20140603125438.GG1321@dhcp22.suse.cz>
References: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
 <1401380162-24121-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401380162-24121-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 29-05-14 12:15:54, Johannes Weiner wrote:
> The charging path currently starts out with OOM condition checks when
> OOM is the rarest possible case.
> 
> Rearrange this code to run OOM/task dying checks only after trying the
> percpu charge and the res_counter charge and bail out before entering
> reclaim.  Attempting a charge does not hurt an (oom-)killed task as
> much as every charge attempt having to check OOM conditions.  Also,
> only check __GFP_NOFAIL when the charge would actually fail.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 33 +++++++++++++++++----------------
>  1 file changed, 17 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c3c10ab98355..46b3e37542ad 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2576,22 +2576,6 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
>  
>  	if (mem_cgroup_is_root(memcg))
>  		goto done;
> -	/*
> -	 * Unlike in global OOM situations, memcg is not in a physical
> -	 * memory shortage.  Allow dying and OOM-killed tasks to
> -	 * bypass the last charges so that they can exit quickly and
> -	 * free their memory.
> -	 */
> -	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
> -		     fatal_signal_pending(current) ||
> -		     current->flags & PF_EXITING))
> -		goto bypass;
> -
> -	if (unlikely(task_in_memcg_oom(current)))
> -		goto nomem;
> -
> -	if (gfp_mask & __GFP_NOFAIL)
> -		oom = false;
>  retry:
>  	if (consume_stock(memcg, nr_pages))
>  		goto done;
> @@ -2613,6 +2597,20 @@ retry:
>  		goto retry;
>  	}
>  
> +	/*
> +	 * Unlike in global OOM situations, memcg is not in a physical
> +	 * memory shortage.  Allow dying and OOM-killed tasks to
> +	 * bypass the last charges so that they can exit quickly and
> +	 * free their memory.
> +	 */
> +	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
> +		     fatal_signal_pending(current) ||
> +		     current->flags & PF_EXITING))
> +		goto bypass;
> +
> +	if (unlikely(task_in_memcg_oom(current)))
> +		goto nomem;
> +
>  	if (!(gfp_mask & __GFP_WAIT))
>  		goto nomem;
>  
> @@ -2641,6 +2639,9 @@ retry:
>  	if (mem_cgroup_wait_acct_move(mem_over_limit))
>  		goto retry;
>  
> +	if (gfp_mask & __GFP_NOFAIL)
> +		goto bypass;
> +
>  	if (fatal_signal_pending(current))
>  		goto bypass;
>  
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
