Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB8986B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 04:19:22 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id m138so38649649lfm.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 01:19:22 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v1si14398218wmd.119.2016.05.23.01.19.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 01:19:21 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n129so12612681wmn.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 01:19:21 -0700 (PDT)
Date: Mon, 23 May 2016 10:19:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm,oom: Do oom_task_origin() test in oom_badness().
Message-ID: <20160523081919.GI2278@dhcp22.suse.cz>
References: <1463796090-7948-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1463796090-7948-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org

On Sat 21-05-16 11:01:30, Tetsuo Handa wrote:
> Currently, oom_scan_process_thread() returns OOM_SCAN_SELECT if
> oom_task_origin() returned true. But this might cause OOM livelock.
> 
> If the OOM killer finds a task with oom_task_origin(task) == true,
> it means that that task is either inside try_to_unuse() from swapoff
> path or unmerge_and_remove_all_rmap_items() from ksm's run_store path.
> 
> Let's take a look at try_to_unuse() as an example. Although there is
> signal_pending() test inside the iteration loop, there are operations
> (e.g. mmput(), wait_on_page_*()) which might block in unkillable state
> waiting for other threads which might allocate memory.
> 
> Therefore, sending SIGKILL to a task with oom_task_origin(task) == true
> can not guarantee that that task shall not stuck at unkillable waits.
> Once the OOM reaper reaped that task's memory (or gave up reaping it),
> the OOM killer must not select that task again when oom_task_origin(task)
> returned true. We need to select different victims until that task can
> hit signal_pending() test or finish the iteration loop.
> 
> Since oom_badness() is a function which returns score of the given thread
> group with eligibility/livelock test, it is more natural and safer to let
> oom_badness() return highest score when oom_task_origin(task) == true.
> 
> This patch moves oom_task_origin() test from oom_scan_process_thread() to
> after MMF_OOM_REAPED test inside oom_badness(), changes the callers to
> receive the score using "unsigned long" variable, and eliminates
> OOM_SCAN_SELECT path in the callers.

I do not think this is the right approach. If the problem is real then
the patch just papers over deficiency of the oom_task_origin which
should be addressed instead.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Nacked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/oom.h |  1 -
>  mm/memcontrol.c     |  9 +--------
>  mm/oom_kill.c       | 26 ++++++++++++++------------
>  3 files changed, 15 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index c63de01..f6b37a4 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -47,7 +47,6 @@ enum oom_scan_t {
>  	OOM_SCAN_OK,		/* scan thread and find its badness */
>  	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
>  	OOM_SCAN_ABORT,		/* abort the iteration and return */
> -	OOM_SCAN_SELECT,	/* always select this thread first */
>  };
>  
>  extern struct mutex oom_lock;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 49cee6f..73c8c44 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1263,7 +1263,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	struct mem_cgroup *iter;
>  	unsigned long chosen_points = 0;
>  	unsigned long totalpages;
> -	unsigned int points = 0;
> +	unsigned long points = 0;
>  	struct task_struct *chosen = NULL;
>  
>  	mutex_lock(&oom_lock);
> @@ -1288,13 +1288,6 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  		css_task_iter_start(&iter->css, &it);
>  		while ((task = css_task_iter_next(&it))) {
>  			switch (oom_scan_process_thread(&oc, task)) {
> -			case OOM_SCAN_SELECT:
> -				if (chosen)
> -					put_task_struct(chosen);
> -				chosen = task;
> -				chosen_points = ULONG_MAX;
> -				get_task_struct(chosen);
> -				/* fall through */
>  			case OOM_SCAN_CONTINUE:
>  				continue;
>  			case OOM_SCAN_ABORT:
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 743afdd..c2ed496 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -186,6 +186,19 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	}
>  
>  	/*
> +	 * If task is allocating a lot of memory and has been marked to be
> +	 * killed first if it triggers an oom, then select it.
> +	 *
> +	 * Score ULONG_MAX / 1000 rather than ULONG_MAX is used in order to
> +	 * avoid overflow when the caller multiplies this score later using
> +	 * "1000 / totalpages".
> +	 */
> +	if (oom_task_origin(p)) {
> +		task_unlock(p);
> +		return ULONG_MAX / 1000;
> +	}
> +
> +	/*
>  	 * The baseline for the badness score is the proportion of RAM that each
>  	 * task's rss, pagetable and swap space use.
>  	 */
> @@ -286,13 +299,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
>  		return OOM_SCAN_ABORT;
>  
> -	/*
> -	 * If task is allocating a lot of memory and has been marked to be
> -	 * killed first if it triggers an oom, then select it.
> -	 */
> -	if (oom_task_origin(task))
> -		return OOM_SCAN_SELECT;
> -
>  	return OOM_SCAN_OK;
>  }
>  
> @@ -309,13 +315,9 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
>  
>  	rcu_read_lock();
>  	for_each_process(p) {
> -		unsigned int points;
> +		unsigned long points;
>  
>  		switch (oom_scan_process_thread(oc, p)) {
> -		case OOM_SCAN_SELECT:
> -			chosen = p;
> -			chosen_points = ULONG_MAX;
> -			/* fall through */
>  		case OOM_SCAN_CONTINUE:
>  			continue;
>  		case OOM_SCAN_ABORT:
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
