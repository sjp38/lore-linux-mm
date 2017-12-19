Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC42A6B0069
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:40:14 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y23so11184778wra.16
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:40:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si1088798wmc.276.2017.12.19.03.40.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 03:40:13 -0800 (PST)
Date: Tue, 19 Dec 2017 12:40:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Set ->signal->oom_mm to all thread groups
 sharing victim's memory.
Message-ID: <20171219114012.GK2787@dhcp22.suse.cz>
References: <1513682774-4416-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513682774-4416-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue 19-12-17 20:26:14, Tetsuo Handa wrote:
> When the OOM reaper set MMF_OOM_SKIP on the victim's mm before threads
> sharing that mm get ->signal->oom_mm, the comment "That thread will now
> get access to memory reserves since it has a pending fatal signal." no
> longer stands. Also, since we introduced ALLOC_OOM watermark, the comment
> "They don't get access to memory reserves, though, to avoid depletion of
> all memory." no longer stands.
> 
> This patch treats all thread groups sharing the victim's mm evenly,
> and updates the outdated comment.

Nack with a real life example where this matters.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> ---
>  mm/oom_kill.c | 58 ++++++++++++++++++++++++++++------------------------------
>  1 file changed, 28 insertions(+), 30 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 2b99e02..19028bd 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -833,7 +833,7 @@ static bool task_will_free_mem(struct task_struct *task)
>  	return ret;
>  }
>  
> -static void __oom_kill_process(struct task_struct *victim)
> +static void __oom_kill_process(struct task_struct *victim, const bool silent)
>  {
>  	struct task_struct *p;
>  	struct mm_struct *mm;
> @@ -868,35 +868,19 @@ static void __oom_kill_process(struct task_struct *victim)
>  	count_vm_event(OOM_KILL);
>  	count_memcg_event_mm(mm, OOM_KILL);
>  
> -	/*
> -	 * We should send SIGKILL before granting access to memory reserves
> -	 * in order to prevent the OOM victim from depleting the memory
> -	 * reserves from the user space under its control.
> -	 */
> -	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> -	mark_oom_victim(victim);
> -	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> -		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
> -		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> -		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> -		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
>  	task_unlock(victim);
>  
>  	/*
> -	 * Kill all user processes sharing victim->mm in other thread groups, if
> -	 * any.  They don't get access to memory reserves, though, to avoid
> -	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
> -	 * oom killed thread cannot exit because it requires the semaphore and
> -	 * its contended by another thread trying to allocate memory itself.
> -	 * That thread will now get access to memory reserves since it has a
> -	 * pending fatal signal.
> +	 * Kill all user processes sharing this mm. This helps the OOM reaper
> +	 * to reclaim memory by interrupting threads waiting or holding
> +	 * mm->mmap_sem for write.
>  	 */
>  	rcu_read_lock();
>  	for_each_process(p) {
> +		struct task_struct *t;
> +
>  		if (!process_shares_mm(p, mm))
>  			continue;
> -		if (same_thread_group(p, victim))
> -			continue;
>  		if (is_global_init(p)) {
>  			can_oom_reap = false;
>  			set_bit(MMF_OOM_SKIP, &mm->flags);
> @@ -911,10 +895,26 @@ static void __oom_kill_process(struct task_struct *victim)
>  		 */
>  		if (unlikely(p->flags & PF_KTHREAD))
>  			continue;
> +		/*
> +		 * We should send SIGKILL before granting access to memory
> +		 * reserves in order to prevent the OOM victim from depleting
> +		 * the memory reserves from the user space under its control.
> +		 */
>  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> +		t = find_lock_task_mm(p);
> +		if (t) {
> +			mark_oom_victim(t);
> +			task_unlock(t);
> +		}
>  	}
>  	rcu_read_unlock();
>  
> +	if (!silent)
> +		pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> +		       task_pid_nr(victim), victim->comm, K(mm->total_vm),
> +		       K(get_mm_counter(mm, MM_ANONPAGES)),
> +		       K(get_mm_counter(mm, MM_FILEPAGES)),
> +		       K(get_mm_counter(mm, MM_SHMEMPAGES)));
>  	if (can_oom_reap)
>  		wake_oom_reaper(victim);
>  
> @@ -941,10 +941,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	 */
>  	task_lock(p);
>  	if (task_will_free_mem(p)) {
> -		mark_oom_victim(p);
> -		wake_oom_reaper(p);
>  		task_unlock(p);
> -		put_task_struct(p);
> +		__oom_kill_process(p, true);
>  		return;
>  	}
>  	task_unlock(p);
> @@ -983,13 +981,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	}
>  	read_unlock(&tasklist_lock);
>  
> -	__oom_kill_process(victim);
> +	__oom_kill_process(victim, false);
>  }
>  
>  static int oom_kill_memcg_member(struct task_struct *task, void *unused)
>  {
>  	get_task_struct(task);
> -	__oom_kill_process(task);
> +	__oom_kill_process(task, false);
>  	return 0;
>  }
>  
> @@ -1017,7 +1015,7 @@ static bool oom_kill_memcg_victim(struct oom_control *oc)
>  		    oc->chosen_task == INFLIGHT_VICTIM)
>  			goto out;
>  
> -		__oom_kill_process(oc->chosen_task);
> +		__oom_kill_process(oc->chosen_task, false);
>  	}
>  
>  out:
> @@ -1095,8 +1093,8 @@ bool out_of_memory(struct oom_control *oc)
>  	 * quickly exit and free its memory.
>  	 */
>  	if (task_will_free_mem(current)) {
> -		mark_oom_victim(current);
> -		wake_oom_reaper(current);
> +		get_task_struct(current);
> +		__oom_kill_process(current, true);
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
