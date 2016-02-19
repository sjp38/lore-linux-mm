Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF796B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 09:04:08 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id a4so72172968wme.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 06:04:08 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id j9si18113685wjs.83.2016.02.19.06.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 06:04:07 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id b205so69574342wmb.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 06:04:07 -0800 (PST)
Date: Fri, 19 Feb 2016 15:04:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: Pass NULL memcg for oom_badness() check.
Message-ID: <20160219140406.GF12690@dhcp22.suse.cz>
References: <1455889898-5659-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455889898-5659-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

On Fri 19-02-16 22:51:38, Tetsuo Handa wrote:
> Currently, mem_cgroup_out_of_memory() is calling
> oom_scan_process_thread(&oc, task, totalpages) which includes
> a call to oom_unkillable_task(task, NULL, NULL) and then is
> calling oom_badness(task, memcg, NULL, totalpages) which includes
> a call to oom_unkillable_task(task, memcg, NULL).
> 
> Since for_each_mem_cgroup_tree() iterates on only tasks from the given
> memcg hierarchy, there is no point with passing non-NULL memcg argument
> to oom_unkillable_task() via oom_badness().
> 
> Replace memcg argument with NULL in order to save a call to
> task_in_mem_cgroup(task, memcg) in oom_unkillable_task()
> which is always true.

yes this is true but oom_badness is called from super slow path here so
I am not sure this change will buy anything. It makes the code little
bit more confusing because now you have to think twice (or git blame) to
see why the memcg == NULL is really OK.

So I do not think this is an improvement. If anything wouldn't it be
cleaner to remove memcg parameter from oom_badness altogether and
instead do the task_in_mem_cgroup check where it is really needed?
In other words do the check in oom_kill_process when evaluating children
to sacrifice them?

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ae8b81c..3c96dd3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1290,7 +1290,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  			case OOM_SCAN_OK:
>  				break;
>  			};
> -			points = oom_badness(task, memcg, NULL, totalpages);
> +			points = oom_badness(task, NULL, NULL, totalpages);
>  			if (!points || points < chosen_points)
>  				continue;
>  			/* Prefer thread group leaders for display purposes */
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
