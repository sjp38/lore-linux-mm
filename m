Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A415E6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 07:08:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u185so20640487oie.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 04:08:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 46si993482oti.234.2016.05.17.04.08.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 May 2016 04:08:21 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160426135402.GB20813@dhcp22.suse.cz>
	<201604271943.GAC60432.FFJHtFVSOQOOLM@I-love.SAKURA.ne.jp>
	<20160427111147.GI2179@dhcp22.suse.cz>
	<201605140939.BFG05745.FJOOOSVQtLFMHF@I-love.SAKURA.ne.jp>
	<20160516141829.GK23146@dhcp22.suse.cz>
In-Reply-To: <20160516141829.GK23146@dhcp22.suse.cz>
Message-Id: <201605172008.FGB26547.OSMFVOQtLFHJOF@I-love.SAKURA.ne.jp>
Date: Tue, 17 May 2016 20:08:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Michal Hocko wrote:
> > I think that clearing TIF_MEMDIE even if the OOM reaper failed to reap the
> > OOM vitctim's memory is confusing for panic_on_oom_timeout timer (which stops
> > itself when TIF_MEMDIE is cleared) and kmallocwd (which prints victim=0 in
> > MemAlloc-Info: line). Until you complete rewriting all functions which could
> > be called with mmap_sem held for write, we should allow the OOM killer to
> > select next OOM victim upon timeout; otherwise calling panic() is premature.
> 
> I would agree if this was an easily triggerable issue in the real life.

Please don't assume that this isn't an easily triggerable issue in the real life.

http://lkml.kernel.org/r/201409192053.IHJ35462.JLOMOSOFFVtQFH@I-love.SAKURA.ne.jp
is a bug which was not identified for 5 years. I was not able to trigger it
in my environment, but the customer was able to trigger it easily in his
environment soon after he started testing his enterprise applications.
Although the bug was fixed and the distributor's kernel was updated, he
gave up using cpuset cgroup because it was too late to update the kernel
for his environment.

I haven't heard response from you about silent hangup bug where all
allocating tasks are trapped at too_many_isolated() loop in shrink_inactive_list()
( http://lkml.kernel.org/r/201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp ).
His cpuset cgroup case was lucky because he had a workaround not to use
cpuset cgroup. But regarding page allocator bugs, no one has a workaround
not to use page allocator. Therefore, proactive detection is important.

You can't determine whether corner case bugs are triggerable before
such bugs bite users. It is too late to wait for feedback from users.

> You are basically DoSing your machine and that leads to corner cases of
> course. We can and should try to plug them but I still do not see any
> reason to rush into any solutions.

My intent of doing what-you-call-DoS stress tests is

   You had better realize that we can't find all corner cases.
   It is not a responsible attitude that you knowingly preserve
   corner cases with "can you trigger it?".

.

The OOM killer is a safety net in case something went wrong (e.g.
a ranaway program). You refuse to care about corner cases. How can it be
called "robust / reliable" without the ability to handle corner cases?
As long as minimal infrastructure for handling the OOM situation (e.g.
scheduler) is alive, we should strive for recovering from the OOM situation
(as with you strive for making the OOM reaper context reliable as much as
possible).

> 
> You seem to be bound to the timeout solution so much that you even
> refuse to think about any other potential ways to move on. I think that
> is counter productive. I have tried to explain many times that once you
> define a _user_ _visible_ knob you should better define a proper semantic
> for it. Do something with a random outcome is not it.

Waiting for feedback without offering a workaround is counterproductive
when we are already aware of bugs. Offering a workaround first and then
trying to fix easily triggerable bugs is appreciated for those who can not
update kernels for their systems due to their constraints. It is up to
users to decide whether to use workarounds.

The reason I insist on the timeout based approach is the robustness.

   (A) It can work on CONFIG_MMU=n kernels.

   (B) It can work even if kthread_run(oom_reaper, NULL, "oom_reaper")
       returned an error.

   (C) It gives more accurately bounded delay (compared to waiting for
       TIF_MEMDIE being sequentially cleared by the OOM reaper) even if
       there are so many threads on the oom_reaper_list list.

   (D) It can work even if the OOM reaper cannot run for long time
       for unknown reasons (e.g. preempted by realtime priority tasks).

   (E) We can handle all corner cases without proving that they are
       triggerable issues in the real life.

> 
> So let's move on and try to think outside of the box:
> ---
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index df8778e72211..027d5bc1e874 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -513,6 +513,7 @@ static inline int get_dumpable(struct mm_struct *mm)
>  #define MMF_HAS_UPROBES		19	/* has uprobes */
>  #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
>  #define MMF_OOM_REAPED		21	/* mm has been already reaped */
> +#define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
>  
>  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index c0e37dd1422f..b1a1e3317231 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -538,8 +538,27 @@ static void oom_reap_task(struct task_struct *tsk)
>  		schedule_timeout_idle(HZ/10);
>  
>  	if (attempts > MAX_OOM_REAP_RETRIES) {
> +		struct task_struct *p;
> +
>  		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
>  				task_pid_nr(tsk), tsk->comm);
> +
> +		/*
> +		 * If we've already tried to reap this task in the past and
> +		 * failed it probably doesn't make much sense to try yet again
> +		 * so hide the mm from the oom killer so that it can move on
> +		 * to another task with a different mm struct.
> +		 */
> +		p = find_lock_task_mm(tsk);
> +		if (p) {
> +			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
> +				pr_info("oom_reaper: giving up pid:%d (%s)\n",
> +						task_pid_nr(tsk), tsk->comm);
> +				set_bit(MMF_OOM_REAPED, &p->mm->flags);
> +			}
> +			task_unlock(p);
> +		}
> +
>  		debug_show_all_locks();
>  	}
>  
> 
> See the difference? This is 11LOC and we do not have export any knobs
> which would tie us for future implementations. We will cap the number
> of times each mm struct is attempted for OOM killer and do not have
> to touch any subtle oom killer paths so the patch would be quite easy
> to review. We can change this implementation if it turns out to be
> impractical, too optimistic or pesimistic.

Oh, this is a drastic change for you. You are trying to be very conservative
and you refused to select next OOM victim unless progress are made.
If you can accept selecting next OOM victim when progress are not made,
I might be able to get away from timeout based approach.

The requirements for getting me away from timeout based approach would be

   (1) The OOM reaper is always invoked even if the OOM victim's mm is
       known to be not reapable. That is, wake up the OOM reaper whenever
       TIF_MEMDIE is set. mark_oom_victim() is a good place for doing so.

   (2) The OOM reaper marks the OOM victim's mm_struct or signal_struct
       as "not suitable for OOM victims" regardless of whether the OOM
       reaper reaped the OOM victim's mm.

       Marking the OOM victim's mm_struct might be unsafe because
       it is possible that the OOM reaper is called without sending
       SIGKILL to all thread groups sharing the OOM victim's mm_struct
       (i.e. a situation where this reproducer tried to attack is
       reproduced).

       Marking the OOM victim's signal_struct might be unsafe unless
       the OOM reaper is called with at least a thread group which
       the OOM victim thread belongs to is guaranteed to be dying or
       exiting. "oom: consider multi-threaded tasks in task_will_free_mem"
       ( http://lkml.kernel.org/r/1460452756-15491-1-git-send-email-mhocko@kernel.org )
       will help.

   (3) The OOM reaper does not defer marking as "not suitable for OOM
       victims" for unbounded duration.

       Imagine a situation where a thread group with 1000 threads was
       OOM killed, 1 thread is holding mmap_sem held for write and 999
       threads are doing allocation. All 1000 threads will be queued to
       the oom_reaper_list and 999 threads are blocked on mmap_sem at
       exit_mm(). Since the OOM reaper waits for 1 second on each OOM
       victim, the allocating task could wait for 1000 seconds.
       If oom_reap_task() checks for "not suitable for OOM victims"
       before calling __oom_reap_task(), we can shorten the delay to
       1 second.

       Imagine a situation where 100 thread groups in different memcg
       are OOM killed, each thread group is holding mmap_sem for write.
       Since the OOM reaper waits for 1 second on each memcg, the last
       OOM victim could wait for 100 seconds. If oom_reap_task() does
       parallel reaping, we can shorten the delay to 1 second.

So, can you accept these requirements?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
