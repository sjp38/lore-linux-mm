Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 990F56B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:00:09 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id qs7so2680710wjc.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 02:00:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o76si1419721wmi.60.2017.01.12.02.00.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 02:00:08 -0800 (PST)
Date: Thu, 12 Jan 2017 11:00:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, memcg: do not retry precharge charges
Message-ID: <20170112100006.GG2264@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 11-01-17 20:32:12, David Rientjes wrote:
> When memory.move_charge_at_immigrate is enabled and precharges are
> depleted during move, mem_cgroup_move_charge_pte_range() will attempt to
> increase the size of the precharge.
> 
> This livelocks if reclaim fails and if an oom killed process attached to
> the destination memcg is trying to exit, which requires 
> cgroup_threadgroup_rwsem, since we're holding the mutex (we also livelock
> while holding mm->mmap_sem for read).

Is this really the case? try_charge will return with ENOMEM for
GFP_KERNEL requests and mem_cgroup_do_precharge will bail out. So how
exactly do we livelock? We do not depend on the exiting task to make a
forward progress. Or am I missing something?

> Prevent precharges from ever looping by setting __GFP_NORETRY.  This was
> probably the intention of the GFP_KERNEL & ~__GFP_NORETRY, which is
> pointless as written.

Yes the current code is clearly bogus, I really do not remember why we
ended up with this rather than GFP_KERNEL | __GFP_NORETRY.
 
> This also restructures mem_cgroup_wait_acct_move() since it is not
> possible for mc.moving_task to be current.

Please separate this out to its own patch.

> Fixes: 0029e19ebf84 ("mm: memcontrol: remove explicit OOM parameter in charge path")
> Signed-off-by: David Rientjes <rientjes@google.com>

For the mem_cgroup_do_precharge part
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 32 +++++++++++++++++++-------------
>  1 file changed, 19 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1125,18 +1125,19 @@ static bool mem_cgroup_under_move(struct mem_cgroup *memcg)
>  
>  static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
>  {
> -	if (mc.moving_task && current != mc.moving_task) {
> -		if (mem_cgroup_under_move(memcg)) {
> -			DEFINE_WAIT(wait);
> -			prepare_to_wait(&mc.waitq, &wait, TASK_INTERRUPTIBLE);
> -			/* moving charge context might have finished. */
> -			if (mc.moving_task)
> -				schedule();
> -			finish_wait(&mc.waitq, &wait);
> -			return true;
> -		}
> +	DEFINE_WAIT(wait);
> +
> +	if (likely(!mem_cgroup_under_move(memcg)))
> +		return false;
> +
> +	prepare_to_wait(&mc.waitq, &wait, TASK_INTERRUPTIBLE);
> +	/* moving charge context might have finished. */
> +	if (mc.moving_task) {
> +		WARN_ON_ONCE(mc.moving_task == current);
> +		schedule();
>  	}
> -	return false;
> +	finish_wait(&mc.waitq, &wait);
> +	return true;
>  }
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
> @@ -4355,9 +4356,14 @@ static int mem_cgroup_do_precharge(unsigned long count)
>  		return ret;
>  	}
>  
> -	/* Try charges one by one with reclaim */
> +	/*
> +	 * Try charges one by one with reclaim, but do not retry.  This avoids
> +	 * looping forever when try_charge() cannot reclaim memory and the oom
> +	 * killer defers while waiting for a process to exit which is trying to
> +	 * acquire cgroup_threadgroup_rwsem in the exit path.
> +	 */
>  	while (count--) {
> -		ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_NORETRY, 1);
> +		ret = try_charge(mc.to, GFP_KERNEL | __GFP_NORETRY, 1);
>  		if (ret)
>  			return ret;
>  		mc.precharge++;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
