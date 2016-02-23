Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B8EBB82F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 19:47:25 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fy10so99720757pac.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 16:47:25 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id 65si43151181pfi.145.2016.02.22.16.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 16:47:25 -0800 (PST)
Received: by mail-pa0-x236.google.com with SMTP id ho8so102529626pac.2
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 16:47:25 -0800 (PST)
Date: Mon, 22 Feb 2016 16:47:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: remove shortcuts for SIGKILL and PF_EXITING
 cases
In-Reply-To: <1456038869-7874-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1602221645260.4688@chino.kir.corp.google.com>
References: <1456038869-7874-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 21 Feb 2016, Tetsuo Handa wrote:

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ae8b81c..390ec2c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1253,16 +1253,6 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  
>  	mutex_lock(&oom_lock);
>  
> -	/*
> -	 * If current has a pending SIGKILL or is exiting, then automatically
> -	 * select it.  The goal is to allow it to allocate so that it may
> -	 * quickly exit and free its memory.
> -	 */
> -	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
> -		mark_oom_victim(current);
> -		goto unlock;
> -	}
> -
>  	check_panic_on_oom(&oc, CONSTRAINT_MEMCG, memcg);
>  	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
>  	for_each_mem_cgroup_tree(iter, memcg) {
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index d7bb9c1..5e8563a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -684,19 +684,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  					      DEFAULT_RATELIMIT_BURST);
>  	bool can_oom_reap = true;
>  
> -	/*
> -	 * If the task is already exiting, don't alarm the sysadmin or kill
> -	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> -	 */
> -	task_lock(p);
> -	if (p->mm && task_will_free_mem(p)) {
> -		mark_oom_victim(p);
> -		task_unlock(p);
> -		put_task_struct(p);
> -		return;
> -	}
> -	task_unlock(p);
> -
>  	if (__ratelimit(&oom_rs))
>  		dump_header(oc, p, memcg);
>  
> @@ -759,20 +746,15 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
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
> +	 * Kill all user processes sharing victim->mm. This reduces possibility
> +	 * of hitting mm->mmap_sem livelock when an oom killed thread cannot
> +	 * exit because it requires the semaphore and its contended by another
> +	 * thread trying to allocate memory itself.
>  	 */
>  	rcu_read_lock();
>  	for_each_process(p) {
>  		if (!process_shares_mm(p, mm))
>  			continue;
> -		if (same_thread_group(p, victim))
> -			continue;
>  		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
>  		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
>  			/*
> @@ -784,6 +766,12 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			continue;
>  		}
>  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> +		for_each_thread(p, t) {
> +			task_lock(t);
> +			if (t->mm)
> +				mark_oom_victim(t);
> +			task_unlock(t);
> +		}
>  	}
>  	rcu_read_unlock();
>  
> @@ -860,20 +848,6 @@ bool out_of_memory(struct oom_control *oc)
>  		return true;
>  
>  	/*
> -	 * If current has a pending SIGKILL or is exiting, then automatically
> -	 * select it.  The goal is to allow it to allocate so that it may
> -	 * quickly exit and free its memory.
> -	 *
> -	 * But don't select if current has already released its mm and cleared
> -	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
> -	 */
> -	if (current->mm &&
> -	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> -		mark_oom_victim(current);
> -		return true;
> -	}
> -
> -	/*
>  	 * Check if there were limitations on the allocation (only relevant for
>  	 * NUMA) that may require different handling.
>  	 */

No, NACK.  You cannot prohibit an exiting process from gaining access to 
memory reserves and randomly killing another process without additional 
chances of a livelock.  The goal is for an exiting or killed process to 
be able to exit so it can free its memory, not kill additional processes.

Please start trimming your cc list, I seriously doubt all these people are 
interested in this thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
