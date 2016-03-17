Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 919246B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 10:54:36 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id l68so229447433wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 07:54:36 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id m205si37402676wma.5.2016.03.17.07.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 07:54:35 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id x188so7230333wmg.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 07:54:35 -0700 (PDT)
Date: Thu, 17 Mar 2016 15:54:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for
 oom_kill_allocating_task
Message-ID: <20160317145433.GG26017@dhcp22.suse.cz>
References: <201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp>
 <201603171949.FHE57319.SMFFtJOHOVOFLQ@I-love.SAKURA.ne.jp>
 <20160317121751.GE26017@dhcp22.suse.cz>
 <201603172200.CIE52148.QOVSOHJFMLOFtF@I-love.SAKURA.ne.jp>
 <20160317132335.GF26017@dhcp22.suse.cz>
 <201603172334.EGD54504.OLFQVJFOtMHFOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603172334.EGD54504.OLFQVJFOtMHFOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Thu 17-03-16 23:34:13, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 17-03-16 22:00:34, Tetsuo Handa wrote:
> > [...]
> > > If you worry about too much work for a single RCU, you can do like
> > > what kmallocwd does. kmallocwd adds a marker to task_struct so that
> > > kmallocwd can reliably resume reporting.
> > 
> > It is you who is trying to add a different debugging output so you
> > should better make sure you won't swamp the user by something that might
> > be not helpful after all by _default_. I would care much less if this
> > was hidden by the debugging option like the current
> > debug_show_all_locks.
> 
> Then, we can do something like this.
> 
> ----------
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index affbb79..76b5c67 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -502,26 +502,20 @@ static void oom_reap_vmas(struct mm_struct *mm)
>  		schedule_timeout_idle(HZ/10);
>  
>  	if (attempts > MAX_OOM_REAP_RETRIES) {
> +#ifdef CONFIG_PROVE_LOCKING
>  		struct task_struct *p;
>  		struct task_struct *t;
> +#endif
>  
>  		pr_info("oom_reaper: unable to reap memory\n");
> -		rcu_read_lock();
> +#ifdef CONFIG_PROVE_LOCKING
> +		read_lock(&tasklist_lock);
>  		for_each_process_thread(p, t) {
> -			if (likely(t->mm != mm))
> -				continue;
> -			pr_info("oom_reaper: %s(%u) flags=0x%x%s%s%s%s\n",
> -				t->comm, t->pid, t->flags,
> -				(t->state & TASK_UNINTERRUPTIBLE) ?
> -				" uninterruptible" : "",
> -				(t->flags & PF_EXITING) ? " exiting" : "",
> -				fatal_signal_pending(t) ? " dying" : "",
> -				test_tsk_thread_flag(t, TIF_MEMDIE) ?
> -				" victim" : "");
> -			sched_show_task(t);
> -			debug_show_held_locks(t);
> +			if (t->mm == mm && t->state != TASK_RUNNING)
> +				debug_show_held_locks(t);
>  		}
> -		rcu_read_unlock();
> +		read_unlock(&tasklist_lock);
> +#endif
>  	}
>  
>  	/* Drop a reference taken by wake_oom_reaper */
> ----------

Please send a separate patch with a full description, ideally with the
example output and clarification why you think this is an improvement
over the current situation. I do not think the patch you are replying to
needs to be changed in any way. It seems correct and provides a useful
information already. If you believe you can provide something more
useful do it in an incremental change.

Making a lot of fuzz with something that doesn't point to a _real_ issue
in the patch to be merged is not particularly useful when we are in the
merge window already.

> Strictly speaking, neither debug_show_all_locks() nor debug_show_held_locks()
> are safe enough to guarantee that the system won't crash.
> 
>   commit 856848737bd944c1 "lockdep: fix debug_show_all_locks()"
>   commit 82a1fcb90287052a "softlockup: automatically detect hung TASK_UNINTERRUPTIBLE tasks"
> 
> They are convenient but we should avoid using them if we care about
> possibility of crash.

I really fail to see your point. debug_show_all_locks doesn't mention
any restriction of the risk nor it is restricted to a particular
context. Were there some bugs in that area? Probably yes, so what?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
