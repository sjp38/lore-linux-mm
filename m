Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 239696B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:54:46 -0400 (EDT)
Received: by wixm2 with SMTP id m2so9787989wix.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:54:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xz6si9598206wjc.1.2015.03.26.04.54.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 04:54:44 -0700 (PDT)
Date: Thu, 26 Mar 2015 12:54:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 02/12] mm: oom_kill: clean up victim marking and exiting
 interfaces
Message-ID: <20150326115442.GD15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427264236-17249-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Wed 25-03-15 02:17:06, Johannes Weiner wrote:
> Rename unmark_oom_victim() to exit_oom_victim().  Marking and
> unmarking are related in functionality, but the interface is not
> symmetrical at all: one is an internal OOM killer function used during
> the killing, the other is for an OOM victim to signal its own death on
> exit later on.  This has locking implications, see follow-up changes.
> 
> While at it, rename mark_tsk_oom_victim() to mark_oom_victim(), which
> is easier on the eye.

The reason _tsk_ was used was to be in sync with *tsk_thread_flag API.
I do not mind changing that though.

> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  drivers/staging/android/lowmemorykiller.c |  2 +-
>  include/linux/oom.h                       |  7 ++++---
>  kernel/exit.c                             |  2 +-
>  mm/memcontrol.c                           |  2 +-
>  mm/oom_kill.c                             | 16 +++++++---------
>  5 files changed, 14 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
> index feafa172b155..2345ee7342d9 100644
> --- a/drivers/staging/android/lowmemorykiller.c
> +++ b/drivers/staging/android/lowmemorykiller.c
> @@ -165,7 +165,7 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
>  		 * infrastructure. There is no real reason why the selected
>  		 * task should have access to the memory reserves.
>  		 */
> -		mark_tsk_oom_victim(selected);
> +		mark_oom_victim(selected);
>  		send_sig(SIGKILL, selected, 0);
>  		rem += selected_tasksize;
>  	}
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 44b2f6f7bbd8..a8e6a498cbcb 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -47,9 +47,7 @@ static inline bool oom_task_origin(const struct task_struct *p)
>  	return !!(p->signal->oom_flags & OOM_FLAG_ORIGIN);
>  }
>  
> -extern void mark_tsk_oom_victim(struct task_struct *tsk);
> -
> -extern void unmark_oom_victim(void);
> +extern void mark_oom_victim(struct task_struct *tsk);
>  
>  extern unsigned long oom_badness(struct task_struct *p,
>  		struct mem_cgroup *memcg, const nodemask_t *nodemask,
> @@ -75,6 +73,9 @@ extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
>  
>  extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		int order, nodemask_t *mask, bool force_kill);
> +
> +extern void exit_oom_victim(void);
> +
>  extern int register_oom_notifier(struct notifier_block *nb);
>  extern int unregister_oom_notifier(struct notifier_block *nb);
>  
> diff --git a/kernel/exit.c b/kernel/exit.c
> index feff10bbb307..4089c2fd373e 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -436,7 +436,7 @@ static void exit_mm(struct task_struct *tsk)
>  	mm_update_next_owner(mm);
>  	mmput(mm);
>  	if (test_thread_flag(TIF_MEMDIE))
> -		unmark_oom_victim();
> +		exit_oom_victim();
>  }
>  
>  static struct task_struct *find_alive_thread(struct task_struct *p)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 74a9641d8f9f..aab5604e0ac4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1536,7 +1536,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	 * quickly exit and free its memory.
>  	 */
>  	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
> -		mark_tsk_oom_victim(current);
> +		mark_oom_victim(current);
>  		return;
>  	}
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 73763e489e86..b2f081fe4b1a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -408,13 +408,13 @@ bool oom_killer_disabled __read_mostly;
>  static DECLARE_RWSEM(oom_sem);
>  
>  /**
> - * mark_tsk_oom_victim - marks the given task as OOM victim.
> + * mark_oom_victim - mark the given task as OOM victim
>   * @tsk: task to mark
>   *
>   * Has to be called with oom_sem taken for read and never after
>   * oom has been disabled already.
>   */
> -void mark_tsk_oom_victim(struct task_struct *tsk)
> +void mark_oom_victim(struct task_struct *tsk)
>  {
>  	WARN_ON(oom_killer_disabled);
>  	/* OOM killer might race with memcg OOM */
> @@ -431,11 +431,9 @@ void mark_tsk_oom_victim(struct task_struct *tsk)
>  }
>  
>  /**
> - * unmark_oom_victim - unmarks the current task as OOM victim.
> - *
> - * Wakes up all waiters in oom_killer_disable()
> + * exit_oom_victim - note the exit of an OOM victim
>   */
> -void unmark_oom_victim(void)
> +void exit_oom_victim(void)
>  {
>  	if (!test_and_clear_thread_flag(TIF_MEMDIE))
>  		return;
> @@ -515,7 +513,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	 */
>  	task_lock(p);
>  	if (p->mm && task_will_free_mem(p)) {
> -		mark_tsk_oom_victim(p);
> +		mark_oom_victim(p);
>  		task_unlock(p);
>  		put_task_struct(p);
>  		return;
> @@ -570,7 +568,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  
>  	/* mm cannot safely be dereferenced after task_unlock(victim) */
>  	mm = victim->mm;
> -	mark_tsk_oom_victim(victim);
> +	mark_oom_victim(victim);
>  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
>  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
>  		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> @@ -728,7 +726,7 @@ static void __out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	 */
>  	if (current->mm &&
>  	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> -		mark_tsk_oom_victim(current);
> +		mark_oom_victim(current);
>  		return;
>  	}
>  
> -- 
> 2.3.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
