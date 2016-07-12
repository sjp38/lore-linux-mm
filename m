Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCD996B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:51:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so15276008wmr.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:51:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l193si21056794wma.4.2016.07.12.07.51.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 07:51:21 -0700 (PDT)
Date: Tue, 12 Jul 2016 16:51:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/8] mm,oom_reaper: Make OOM reaper use list of mm_struct.
Message-ID: <20160712145119.GP14586@dhcp22.suse.cz>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1468330163-4405-6-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468330163-4405-6-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Tue 12-07-16 22:29:20, Tetsuo Handa wrote:
> find_lock_task_mm() is racy when finding an mm because it returns NULL

I would rather s@racy@unreliable@

> when all threads in that thread group passed current->mm == NULL line
> in exit_mm() while that mm might be still waiting for __mmput() (or the
> OOM reaper) to reclaim memory used by that mm.
> 
> Since OOM reaping is per mm_struct operation, it is natural to use
> list of mm_struct used by OOM victims. By using list of mm_struct,
> we can eliminate find_lock_task_mm() usage from the OOM reaper.

Good. This will reduce the code size, simplify the code and make it more
reliable.

> We still have racy find_lock_task_mm() usage in oom_scan_process_thread()
> which can theoretically cause OOM livelock situation when MMF_OOM_REAPED
> was set to OOM victim's mm without putting that mm under the OOM reaper's
> supervision. We must not depend on find_lock_task_mm() not returning NULL.

But I guess this just makes the changelog confusing without adding a
large value.

> Since later patch in the series will change oom_scan_process_thread() not
> to depend on atomic_read(&task->signal->oom_victims) != 0 &&
> find_lock_task_mm(task) != NULL, this patch removes exit_oom_victim()
> on remote thread.

I have already suggested doing this in a separate patch. Because
dropping exit_oom_victim has other side effectes (namely for
oom_killer_disable convergence guarantee).

Also I would suggest doing set_bit(MMF_OOM_REAPED) from exit_oom_mm and
(in a follow up patch) rename it to MMF_SKIP_OOM_MM.

I haven't spotted any other issues.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/oom.h |   8 ----
>  mm/memcontrol.c     |   1 -
>  mm/oom_kill.c       | 117 +++++++++++++++++++++-------------------------------
>  3 files changed, 47 insertions(+), 79 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index bdcb331..cb3f041 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -72,14 +72,6 @@ static inline bool oom_task_origin(const struct task_struct *p)
>  
>  extern void mark_oom_victim(struct task_struct *tsk);
>  
> -#ifdef CONFIG_MMU
> -extern void wake_oom_reaper(struct task_struct *tsk);
> -#else
> -static inline void wake_oom_reaper(struct task_struct *tsk)
> -{
> -}
> -#endif
> -
>  extern unsigned long oom_badness(struct task_struct *p,
>  		struct mem_cgroup *memcg, const nodemask_t *nodemask,
>  		unsigned long totalpages);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8f7a5b7..5043324 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1236,7 +1236,6 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	 */
>  	if (task_will_free_mem(current)) {
>  		mark_oom_victim(current);
> -		wake_oom_reaper(current);
>  		goto unlock;
>  	}
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 0b78133..715f77d 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -286,11 +286,19 @@ static DEFINE_SPINLOCK(oom_mm_lock);
>  
>  void exit_oom_mm(struct mm_struct *mm)
>  {
> +	struct task_struct *victim;
> +
> +	/* __mmput() and oom_reaper() could race. */
>  	spin_lock(&oom_mm_lock);
> -	list_del(&mm->oom_mm.list);
> +	victim = mm->oom_mm.victim;
> +	mm->oom_mm.victim = NULL;
> +	if (victim)
> +		list_del(&mm->oom_mm.list);
>  	spin_unlock(&oom_mm_lock);
> -	put_task_struct(mm->oom_mm.victim);
> -	mmdrop(mm);
> +	if (victim) {
> +		put_task_struct(victim);
> +		mmdrop(mm);
> +	}
>  }
>  
>  bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
> @@ -483,8 +491,6 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
>   */
>  static struct task_struct *oom_reaper_th;
>  static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
> -static struct task_struct *oom_reaper_list;
> -static DEFINE_SPINLOCK(oom_reaper_lock);
>  
>  static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
>  {
> @@ -576,30 +582,27 @@ unlock_oom:
>  }
>  
>  #define MAX_OOM_REAP_RETRIES 10
> -static void oom_reap_task(struct task_struct *tsk)
> +static void oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
>  {
>  	int attempts = 0;
> -	struct mm_struct *mm = NULL;
> -	struct task_struct *p = find_lock_task_mm(tsk);
> +	bool ret;
>  
>  	/*
> -	 * Make sure we find the associated mm_struct even when the particular
> -	 * thread has already terminated and cleared its mm.
> -	 * We might have race with exit path so consider our work done if there
> -	 * is no mm.
> +	 * Check MMF_OOM_REAPED after holding oom_lock in case
> +	 * oom_kill_process() found this mm pinned.
>  	 */
> -	if (!p)
> -		goto done;
> -	mm = p->mm;
> -	atomic_inc(&mm->mm_count);
> -	task_unlock(p);
> +	mutex_lock(&oom_lock);
> +	ret = test_bit(MMF_OOM_REAPED, &mm->flags);
> +	mutex_unlock(&oom_lock);
> +	if (ret)
> +		return;
>  
>  	/* Retry the down_read_trylock(mmap_sem) a few times */
>  	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk, mm))
>  		schedule_timeout_idle(HZ/10);
>  
>  	if (attempts <= MAX_OOM_REAP_RETRIES)
> -		goto done;
> +		return;
>  
>  	/* Ignore this mm because somebody can't call up_write(mmap_sem). */
>  	set_bit(MMF_OOM_REAPED, &mm->flags);
> @@ -607,22 +610,6 @@ static void oom_reap_task(struct task_struct *tsk)
>  	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
>  		task_pid_nr(tsk), tsk->comm);
>  	debug_show_all_locks();
> -
> -done:
> -	/*
> -	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
> -	 * reasonably reclaimable memory anymore or it is not a good candidate
> -	 * for the oom victim right now because it cannot release its memory
> -	 * itself nor by the oom reaper.
> -	 */
> -	tsk->oom_reaper_list = NULL;
> -	exit_oom_victim(tsk);
> -
> -	/* Drop a reference taken by wake_oom_reaper */
> -	put_task_struct(tsk);
> -	/* Drop a reference taken above. */
> -	if (mm)
> -		mmdrop(mm);
>  }
>  
>  static int oom_reaper(void *unused)
> @@ -630,41 +617,35 @@ static int oom_reaper(void *unused)
>  	set_freezable();
>  
>  	while (true) {
> -		struct task_struct *tsk = NULL;
> -
> -		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
> -		spin_lock(&oom_reaper_lock);
> -		if (oom_reaper_list != NULL) {
> -			tsk = oom_reaper_list;
> -			oom_reaper_list = tsk->oom_reaper_list;
> +		struct mm_struct *mm = NULL;
> +		struct task_struct *victim = NULL;
> +
> +		wait_event_freezable(oom_reaper_wait,
> +				     !list_empty(&oom_mm_list));
> +		spin_lock(&oom_mm_lock);
> +		if (!list_empty(&oom_mm_list)) {
> +			mm = list_first_entry(&oom_mm_list, struct mm_struct,
> +					      oom_mm.list);
> +			victim = mm->oom_mm.victim;
> +			/*
> +			 * Take a reference on current victim thread in case
> +			 * oom_reap_task() raced with mark_oom_victim() by
> +			 * other threads sharing this mm.
> +			 */
> +			get_task_struct(victim);
>  		}
> -		spin_unlock(&oom_reaper_lock);
> -
> -		if (tsk)
> -			oom_reap_task(tsk);
> +		spin_unlock(&oom_mm_lock);
> +		if (!mm)
> +			continue;
> +		oom_reap_task(victim, mm);
> +		put_task_struct(victim);
> +		/* Drop references taken by mark_oom_victim() */
> +		exit_oom_mm(mm);
>  	}
>  
>  	return 0;
>  }
>  
> -void wake_oom_reaper(struct task_struct *tsk)
> -{
> -	if (!oom_reaper_th)
> -		return;
> -
> -	/* tsk is already queued? */
> -	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
> -		return;
> -
> -	get_task_struct(tsk);
> -
> -	spin_lock(&oom_reaper_lock);
> -	tsk->oom_reaper_list = oom_reaper_list;
> -	oom_reaper_list = tsk;
> -	spin_unlock(&oom_reaper_lock);
> -	wake_up(&oom_reaper_wait);
> -}
> -
>  static int __init oom_init(void)
>  {
>  	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> @@ -726,6 +707,9 @@ void mark_oom_victim(struct task_struct *tsk)
>  	spin_unlock(&oom_mm_lock);
>  	if (old_tsk)
>  		put_task_struct(old_tsk);
> +#ifdef CONFIG_MMU
> +	wake_up(&oom_reaper_wait);
> +#endif
>  }
>  
>  /**
> @@ -867,7 +851,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	unsigned int victim_points = 0;
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
> -	bool can_oom_reap = true;
>  
>  	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
> @@ -876,7 +859,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	task_lock(p);
>  	if (task_will_free_mem(p)) {
>  		mark_oom_victim(p);
> -		wake_oom_reaper(p);
>  		task_unlock(p);
>  		put_task_struct(p);
>  		return;
> @@ -966,7 +948,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			 * memory might be still used. Hide the mm from the oom
>  			 * killer to guarantee OOM forward progress.
>  			 */
> -			can_oom_reap = false;
>  			set_bit(MMF_OOM_REAPED, &mm->flags);
>  			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
>  					task_pid_nr(victim), victim->comm,
> @@ -977,9 +958,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	}
>  	rcu_read_unlock();
>  
> -	if (can_oom_reap)
> -		wake_oom_reaper(victim);
> -
>  	mmdrop(mm);
>  	put_task_struct(victim);
>  }
> @@ -1055,7 +1033,6 @@ bool out_of_memory(struct oom_control *oc)
>  	 */
>  	if (task_will_free_mem(current)) {
>  		mark_oom_victim(current);
> -		wake_oom_reaper(current);
>  		return true;
>  	}
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
