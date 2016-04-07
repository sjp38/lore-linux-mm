Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id EEDDC6B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 07:38:53 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id e128so54355593pfe.3
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 04:38:53 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 13si365273pft.59.2016.04.07.04.38.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Apr 2016 04:38:53 -0700 (PDT)
Subject: Re: [PATCH 2/3] oom, oom_reaper: Try to reap tasks which skip regular OOM killer path
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
	<1459951996-12875-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459951996-12875-3-git-send-email-mhocko@kernel.org>
Message-Id: <201604072038.CHC51027.MSJOFVLHOFFtQO@I-love.SAKURA.ne.jp>
Date: Thu, 7 Apr 2016 20:38:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com, oleg@redhat.com

Michal Hocko wrote:
> @@ -563,6 +582,53 @@ static void wake_oom_reaper(struct task_struct *tsk)
>  	wake_up(&oom_reaper_wait);
>  }
>  
> +/* Check if we can reap the given task. This has to be called with stable
> + * tsk->mm
> + */
> +static void try_oom_reaper(struct task_struct *tsk)
> +{
> +	struct mm_struct *mm = tsk->mm;
> +	struct task_struct *p;
> +
> +	if (!mm)
> +		return;
> +
> +	/*
> +	 * There might be other threads/processes which are either not
> +	 * dying or even not killable.
> +	 */
> +	if (atomic_read(&mm->mm_users) > 1) {
> +		rcu_read_lock();
> +		for_each_process(p) {
> +			bool exiting;
> +
> +			if (!process_shares_mm(p, mm))
> +				continue;
> +			if (same_thread_group(p, tsk))
> +				continue;
> +			if (fatal_signal_pending(p))
> +				continue;
> +
> +			/*
> +			 * If the task is exiting make sure the whole thread group
> +			 * is exiting and cannot acces mm anymore.
> +			 */
> +			spin_lock_irq(&p->sighand->siglock);
> +			exiting = signal_group_exit(p->signal);
> +			spin_unlock_irq(&p->sighand->siglock);
> +			if (exiting)
> +				continue;
> +
> +			/* Give up */
> +			rcu_read_unlock();
> +			return;
> +		}
> +		rcu_read_unlock();
> +	}
> +
> +	wake_oom_reaper(tsk);
> +}
> +

I think you want to change "try_oom_reaper() without wake_oom_reaper()"
as mm_is_reapable() and use it from oom_kill_process() in order to skip
p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN test which needlessly makes
can_oom_reap false.

> @@ -694,6 +746,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	task_lock(p);
>  	if (p->mm && task_will_free_mem(p)) {
>  		mark_oom_victim(p);
> +		try_oom_reaper(p);
>  		task_unlock(p);
>  		put_task_struct(p);
>  		return;
> @@ -873,6 +926,7 @@ bool out_of_memory(struct oom_control *oc)
>  	if (current->mm &&
>  	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
>  		mark_oom_victim(current);
> +		try_oom_reaper(current);
>  		return true;
>  	}
>  

Why don't you call try_oom_reaper() from the shortcuts in
mem_cgroup_out_of_memory() as well?

Why don't you embed try_oom_reaper() into mark_oom_victim() like I did at
http://lkml.kernel.org/r/201602052014.HBG52666.HFMOQVLFOSFJtO@I-love.SAKURA.ne.jp ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
