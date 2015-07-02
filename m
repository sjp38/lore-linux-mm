Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 688B29003CE
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 02:01:17 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so185460569wiw.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 23:01:16 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id je11si7786932wic.40.2015.07.01.23.01.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 23:01:15 -0700 (PDT)
Received: by wguu7 with SMTP id u7so53595968wgu.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 23:01:14 -0700 (PDT)
Date: Thu, 2 Jul 2015 08:01:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 2/3] mm, oom: organize oom context into struct
Message-ID: <20150702060111.GB3989@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1507011435150.14014@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1507011436080.14014@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507011436080.14014@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 01-07-15 14:37:14, David Rientjes wrote:
> The force_kill member of struct oom_control isn't needed if an order of
> -1 is used instead.  This is the same as order == -1 in
> struct compact_control which requires full memory compaction.
> 
> This patch introduces no functional change.

But it obscures the code and I really dislike this change as pointed out
previously.

> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v2: fix changelog typo per Sergey
> 
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
