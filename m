Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFFE6B0253
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:54:53 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l68so15017234wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:54:53 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id v82si2285309wmv.63.2016.03.11.03.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 03:54:52 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id l68so14456379wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:54:51 -0800 (PST)
Date: Fri, 11 Mar 2016 12:54:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: zap
 task_struct->memcg_oom_{gfp_mask,order}
Message-ID: <20160311115450.GH27701@dhcp22.suse.cz>
References: <1457691167-22756-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457691167-22756-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 11-03-16 13:12:47, Vladimir Davydov wrote:
> These fields are used for dumping info about allocation that triggered
> OOM. For cgroup this information doesn't make much sense, because OOM
> killer is always invoked from page fault handler.

The oom killer is indeed invoked in a different context but why printing
the original mask and order doesn't make any sense? Doesn't it help to
see that the reclaim has failed because of GFP_NOFS?

> It isn't worth the
> space these fields occupy in the task_struct.

        struct mem_cgroup *        memcg_in_oom;         /*  8456     8 */
        gfp_t                      memcg_oom_gfp_mask;   /*  8464     4 */
        int                        memcg_oom_order;      /*  8468     4 */
        unsigned int               memcg_nr_pages_over_high; /*  8472     4 */

        /* XXX 4 bytes hole, try to pack */

        struct uprobe_task *       utask;                /*  8480     8 */
        int                        pagefault_disabled;   /*  8488     4 */

        /* XXX 20 bytes hole, try to pack */

        /* --- cacheline 133 boundary (8512 bytes) --- */
        struct thread_struct       thread;               /*  8512  4352 */
        /* --- cacheline 201 boundary (12864 bytes) --- */
        /* size: 12864, cachelines: 201, members: 185 */

vs.
        struct mem_cgroup *        memcg_in_oom;         /*  8456     8 */
        unsigned int               memcg_nr_pages_over_high; /*  8464     4 */

        /* XXX 4 bytes hole, try to pack */

        struct uprobe_task *       utask;                /*  8472     8 */
        int                        pagefault_disabled;   /*  8480     4 */

        /* XXX 4 bytes hole, try to pack */

        struct task_struct *       oom_reaper_list;      /*  8488     8 */

        /* XXX 16 bytes hole, try to pack */

        /* --- cacheline 133 boundary (8512 bytes) --- */
        struct thread_struct       thread;               /*  8512  4352 */
        /* --- cacheline 201 boundary (12864 bytes) --- */

        /* size: 12864, cachelines: 201, members: 184 */

So it doesn't even seem to save any space in the config I am using. Does
it shrink the size of the structure for you?

> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> ---
>  include/linux/sched.h |  2 --
>  mm/memcontrol.c       | 14 +++++---------
>  2 files changed, 5 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index ba8d8355c93a..626f5da5c43e 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1839,8 +1839,6 @@ struct task_struct {
>  #endif
>  #ifdef CONFIG_MEMCG
>  	struct mem_cgroup *memcg_in_oom;
> -	gfp_t memcg_oom_gfp_mask;
> -	int memcg_oom_order;
>  
>  	/* number of pages to reclaim on returning to userland */
>  	unsigned int memcg_nr_pages_over_high;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 36db05fa8acb..a217b1374c32 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1232,14 +1232,13 @@ static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
>  	return limit;
>  }
>  
> -static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> -				     int order)
> +static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg)
>  {
>  	struct oom_control oc = {
>  		.zonelist = NULL,
>  		.nodemask = NULL,
> -		.gfp_mask = gfp_mask,
> -		.order = order,
> +		.gfp_mask = GFP_KERNEL,
> +		.order = 0,
>  	};
>  	struct mem_cgroup *iter;
>  	unsigned long chosen_points = 0;
> @@ -1605,8 +1604,6 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>  	 */
>  	css_get(&memcg->css);
>  	current->memcg_in_oom = memcg;
> -	current->memcg_oom_gfp_mask = mask;
> -	current->memcg_oom_order = order;
>  }
>  
>  /**
> @@ -1656,8 +1653,7 @@ bool mem_cgroup_oom_synchronize(bool handle)
>  	if (locked && !memcg->oom_kill_disable) {
>  		mem_cgroup_unmark_under_oom(memcg);
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
> -		mem_cgroup_out_of_memory(memcg, current->memcg_oom_gfp_mask,
> -					 current->memcg_oom_order);
> +		mem_cgroup_out_of_memory(memcg);
>  	} else {
>  		schedule();
>  		mem_cgroup_unmark_under_oom(memcg);
> @@ -5063,7 +5059,7 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
>  		}
>  
>  		mem_cgroup_events(memcg, MEMCG_OOM, 1);
> -		if (!mem_cgroup_out_of_memory(memcg, GFP_KERNEL, 0))
> +		if (!mem_cgroup_out_of_memory(memcg))
>  			break;
>  	}
>  
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
