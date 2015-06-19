Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id A74926B0085
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 03:32:05 -0400 (EDT)
Received: by wguu7 with SMTP id u7so10044739wgu.3
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 00:32:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ib4si18345461wjb.47.2015.06.19.00.32.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 00:32:03 -0700 (PDT)
Date: Fri, 19 Jun 2015 09:32:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/3] mm, oom: pass an oom order of -1 when triggered by
 sysrq
Message-ID: <20150619073202.GD4913@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1506181556180.13736@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506181556180.13736@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 18-06-15 16:00:07, David Rientjes wrote:
> The force_kill member of struct oom_context isn't needed if an order of
> -1 is used instead.

But this doesn't make much sense to me. It is not like we would _have_
to spare few bytes here. The meaning of force_kill is clear while order
with a weird value is a hack. It is harder to follow without any good
reason.

> This patch introduces no functional change.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  drivers/tty/sysrq.c | 3 +--
>  include/linux/oom.h | 1 -
>  mm/memcontrol.c     | 1 -
>  mm/oom_kill.c       | 5 ++---
>  mm/page_alloc.c     | 1 -
>  5 files changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
> --- a/drivers/tty/sysrq.c
> +++ b/drivers/tty/sysrq.c
> @@ -358,8 +358,7 @@ static void moom_callback(struct work_struct *ignored)
>  		.zonelist = node_zonelist(first_memory_node, gfp_mask),
>  		.nodemask = NULL,
>  		.gfp_mask = gfp_mask,
> -		.order = 0,
> -		.force_kill = true,
> +		.order = -1,
>  	};
>  
>  	mutex_lock(&oom_lock);
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -17,7 +17,6 @@ struct oom_control {
>  	nodemask_t	*nodemask;
>  	gfp_t		gfp_mask;
>  	int		order;
> -	bool		force_kill;
>  };
>  
>  /*
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1550,7 +1550,6 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  		.nodemask = NULL,
>  		.gfp_mask = gfp_mask,
>  		.order = order,
> -		.force_kill = false,
>  	};
>  	struct mem_cgroup *iter;
>  	unsigned long chosen_points = 0;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -265,7 +265,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	 * Don't allow any other task to have access to the reserves.
>  	 */
>  	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> -		if (!oc->force_kill)
> +		if (oc->order != -1)
>  			return OOM_SCAN_ABORT;
>  	}
>  	if (!task->mm)
> @@ -278,7 +278,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	if (oom_task_origin(task))
>  		return OOM_SCAN_SELECT;
>  
> -	if (task_will_free_mem(task) && !oc->force_kill)
> +	if (task_will_free_mem(task) && oc->order != -1)
>  		return OOM_SCAN_ABORT;
>  
>  	return OOM_SCAN_OK;
> @@ -718,7 +718,6 @@ void pagefault_out_of_memory(void)
>  		.nodemask = NULL,
>  		.gfp_mask = 0,
>  		.order = 0,
> -		.force_kill = false,
>  	};
>  
>  	if (mem_cgroup_oom_synchronize(true))
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2685,7 +2685,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  		.nodemask = ac->nodemask,
>  		.gfp_mask = gfp_mask,
>  		.order = order,
> -		.force_kill = false,
>  	};
>  	struct page *page;
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
