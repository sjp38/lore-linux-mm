Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E0E0F6B025E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:17:54 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id p65so23378248wmp.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 05:17:54 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id k84si10587490wmc.14.2016.03.17.05.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 05:17:54 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id p65so14614924wmp.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 05:17:53 -0700 (PDT)
Date: Thu, 17 Mar 2016 13:17:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for
 oom_kill_allocating_task
Message-ID: <20160317121751.GE26017@dhcp22.suse.cz>
References: <20160222094105.GD17938@dhcp22.suse.cz>
 <201603152015.JAE86937.VFOLtQFOFJOSHM@I-love.SAKURA.ne.jp>
 <20160315114300.GC6108@dhcp22.suse.cz>
 <20160315115001.GE6108@dhcp22.suse.cz>
 <201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp>
 <201603171949.FHE57319.SMFFtJOHOVOFLQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603171949.FHE57319.SMFFtJOHOVOFLQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Thu 17-03-16 19:49:01, Tetsuo Handa wrote:
[...]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 2199c71..affbb79 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -502,8 +502,26 @@ static void oom_reap_vmas(struct mm_struct *mm)
>  		schedule_timeout_idle(HZ/10);
>  
>  	if (attempts > MAX_OOM_REAP_RETRIES) {
> +		struct task_struct *p;
> +		struct task_struct *t;
> +
>  		pr_info("oom_reaper: unable to reap memory\n");
> -		debug_show_all_locks();
> +		rcu_read_lock();
> +		for_each_process_thread(p, t) {
> +			if (likely(t->mm != mm))
> +				continue;
> +			pr_info("oom_reaper: %s(%u) flags=0x%x%s%s%s%s\n",
> +				t->comm, t->pid, t->flags,
> +				(t->state & TASK_UNINTERRUPTIBLE) ?
> +				" uninterruptible" : "",
> +				(t->flags & PF_EXITING) ? " exiting" : "",
> +				fatal_signal_pending(t) ? " dying" : "",
> +				test_tsk_thread_flag(t, TIF_MEMDIE) ?
> +				" victim" : "");
> +			sched_show_task(t);
> +			debug_show_held_locks(t);
> +		}
> +		rcu_read_unlock();

Isn't this way too much work for a single RCU lock? Also wouldn't it
generate way too much output in the pathological situations a so hide
other potentially more important log messages?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
