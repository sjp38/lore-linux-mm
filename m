Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC476B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:56:11 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id mc6so1350188lab.2
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 08:56:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7si3211795lae.93.2014.10.23.08.56.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 08:56:09 -0700 (PDT)
Date: Thu, 23 Oct 2014 17:56:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: fold
 mem_cgroup_start_move()/mem_cgroup_end_move()
Message-ID: <20141023155607.GN23011@dhcp22.suse.cz>
References: <1414075327-15039-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414075327-15039-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 23-10-14 10:42:07, Johannes Weiner wrote:
> Having these functions and their documentation split out and somewhere
> makes it harder, not easier, to follow what's going on.
> 
> Inline them directly where charge moving is prepared and finished, and
> put an explanation right next to it.

I do not see the open coded version much more readable or maintainable to be
honest. mem_cgroup_{start,end}_move are a good markers of the transaction.
But I do not have strong opinion about this. The preparation and
move_lock parts are so far from each other that either way would be
non-trivial to follow. That being said, I do not really care much.

Your comment is better and more clear though.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 40 ++++++++++++----------------------------
>  1 file changed, 12 insertions(+), 28 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3cd4f1e0bfb3..5b5c784dc39d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1447,32 +1447,6 @@ int mem_cgroup_swappiness(struct mem_cgroup *memcg)
>  }
>  
>  /*
> - * memcg->moving_account is used for checking possibility that some thread is
> - * calling move_account(). When a thread on CPU-A starts moving pages under
> - * a memcg, other threads should check memcg->moving_account under
> - * rcu_read_lock(), like this:
> - *
> - *         CPU-A                                    CPU-B
> - *                                              rcu_read_lock()
> - *         memcg->moving_account+1              if (memcg->mocing_account)
> - *                                                   take heavy locks.
> - *         synchronize_rcu()                    update something.
> - *                                              rcu_read_unlock()
> - *         start move here.
> - */
> -
> -static void mem_cgroup_start_move(struct mem_cgroup *memcg)
> -{
> -	atomic_inc(&memcg->moving_account);
> -	synchronize_rcu();
> -}
> -
> -static void mem_cgroup_end_move(struct mem_cgroup *memcg)
> -{
> -	atomic_dec(&memcg->moving_account);
> -}
> -
> -/*
>   * A routine for checking "mem" is under move_account() or not.
>   *
>   * Checking a cgroup is mc.from or mc.to or under hierarchy of
> @@ -5431,7 +5405,8 @@ static void mem_cgroup_clear_mc(void)
>  	mc.from = NULL;
>  	mc.to = NULL;
>  	spin_unlock(&mc.lock);
> -	mem_cgroup_end_move(from);
> +
> +	atomic_dec(&memcg->moving_account);
>  }
>  
>  static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
> @@ -5464,7 +5439,16 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
>  			VM_BUG_ON(mc.precharge);
>  			VM_BUG_ON(mc.moved_charge);
>  			VM_BUG_ON(mc.moved_swap);
> -			mem_cgroup_start_move(from);
> +
> +			/*
> +			 * Signal mem_cgroup_begin_page_stat() to take
> +			 * the memcg's move_lock while we're moving
> +			 * its pages to another memcg.  Then wait for
> +			 * already started RCU-only updates to finish.
> +			 */
> +			atomic_inc(&memcg->moving_account);
> +			synchronize_rcu();
> +
>  			spin_lock(&mc.lock);
>  			mc.from = from;
>  			mc.to = memcg;
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
