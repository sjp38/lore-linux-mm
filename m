Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id DFD2290008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 13:07:04 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id gm9so4853621lab.13
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 10:07:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si13020097lbd.20.2014.10.30.10.07.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 10:07:02 -0700 (PDT)
Date: Thu, 30 Oct 2014 18:07:00 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: shorten the page statistics update
 slowpath
Message-ID: <20141030170700.GC3639@dhcp22.suse.cz>
References: <1414158020-25347-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414158020-25347-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 24-10-14 09:40:20, Johannes Weiner wrote:
> While moving charges from one memcg to another, page stat updates must
> acquire the old memcg's move_lock to prevent double accounting.  That
> situation is denoted by an increased memcg->move_accounting.  However,
> the charge moving code declares this way too early for now, even
> before summing up the RSS and pre-allocating destination charges.

It is also much better to have the inc and dec in the same function
rather than in callbacks.

> 
> Shorten this slowpath mode by increasing memcg->move_accounting only
> right before walking the task's address space with the intention of
> actually moving the pages.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 21 ++++++++-------------
>  1 file changed, 8 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c50176429fa3..23cf27cca370 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5263,8 +5263,6 @@ static void __mem_cgroup_clear_mc(void)
>  
>  static void mem_cgroup_clear_mc(void)
>  {
> -	struct mem_cgroup *from = mc.from;
> -
>  	/*
>  	 * we must clear moving_task before waking up waiters at the end of
>  	 * task migration.
> @@ -5275,8 +5273,6 @@ static void mem_cgroup_clear_mc(void)
>  	mc.from = NULL;
>  	mc.to = NULL;
>  	spin_unlock(&mc.lock);
> -
> -	atomic_dec(&from->moving_account);
>  }
>  
>  static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
> @@ -5310,15 +5306,6 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
>  			VM_BUG_ON(mc.moved_charge);
>  			VM_BUG_ON(mc.moved_swap);
>  
> -			/*
> -			 * Signal mem_cgroup_begin_page_stat() to take
> -			 * the memcg's move_lock while we're moving
> -			 * its pages to another memcg.  Then wait for
> -			 * already started RCU-only updates to finish.
> -			 */
> -			atomic_inc(&from->moving_account);
> -			synchronize_rcu();
> -
>  			spin_lock(&mc.lock);
>  			mc.from = from;
>  			mc.to = memcg;
> @@ -5450,6 +5437,13 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
>  	struct vm_area_struct *vma;
>  
>  	lru_add_drain_all();
> +	/*
> +	 * Signal mem_cgroup_begin_page_stat() to take the memcg's
> +	 * move_lock while we're moving its pages to another memcg.
> +	 * Then wait for already started RCU-only updates to finish.
> +	 */
> +	atomic_inc(&mc.from->moving_account);
> +	synchronize_rcu();
>  retry:
>  	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
>  		/*
> @@ -5482,6 +5476,7 @@ retry:
>  			break;
>  	}
>  	up_read(&mm->mmap_sem);
> +	atomic_dec(&mc.from->moving_account);
>  }
>  
>  static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
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
