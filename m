Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id BA8C46B0037
	for <linux-mm@kvack.org>; Wed,  7 May 2014 10:33:40 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so811299eek.41
        for <linux-mm@kvack.org>; Wed, 07 May 2014 07:33:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f45si16539354eet.279.2014.05.07.07.33.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 07:33:39 -0700 (PDT)
Date: Wed, 7 May 2014 16:33:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/9] mm: memcontrol: rearrange charging fast path
Message-ID: <20140507143334.GH9489@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398889543-23671-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 30-04-14 16:25:36, Johannes Weiner wrote:
> The charging path currently starts out with OOM condition checks when
> OOM is the rarest possible case.
> 
> Rearrange this code to run OOM/task dying checks only after trying the
> percpu charge and the res_counter charge and bail out before entering
> reclaim.  Attempting a charge does not hurt an (oom-)killed task as
> much as every charge attempt having to check OOM conditions. 

OK, I've never considered those to be measurable but it is true that the
numbers accumulate over time.

So yes, this makes sense.

> Also, only check __GFP_NOFAIL when the charge would actually fail.

OK, but return ENOMEM as pointed below.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 31 ++++++++++++++++---------------
>  1 file changed, 16 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 75dfeb8fa98b..6ce59146fec7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2598,21 +2598,6 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
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
> -		     fatal_signal_pending(current)))
> -		goto bypass;

This is missing "memcg: do not hang on OOM when killed by userspace OOM
access to memory reserves" - trivial to resolve.

> -
> -	if (unlikely(task_in_memcg_oom(current)))
> -		goto nomem;
> -
> -	if (gfp_mask & __GFP_NOFAIL)
> -		oom = false;
>  retry:
>  	if (consume_stock(memcg, nr_pages))
>  		goto done;
[...]
> @@ -2662,6 +2660,9 @@ retry:
>  	if (mem_cgroup_wait_acct_move(mem_over_limit))
>  		goto retry;
>  
> +	if (gfp_mask & __GFP_NOFAIL)
> +		goto bypass;
> +

This is a behavior change because we have returned ENOMEM previously

>  	if (fatal_signal_pending(current))
>  		goto bypass;
>  
	if (!oom)
		goto nomem;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
