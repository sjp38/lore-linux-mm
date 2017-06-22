From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [v3 1/6] mm, oom: use oom_victims counter to synchronize oom victim selection
Date: Fri, 23 Jun 2017 05:37:50 +0900
Message-ID: <201706230537.IDB21366.SQHJVFOOFOMFLt@I-love.SAKURA.ne.jp>
References: <1498079956-24467-1-git-send-email-guro@fb.com>
        <1498079956-24467-2-git-send-email-guro@fb.com>
        <201706220040.v5M0eSnK074332@www262.sakura.ne.jp>
        <20170622165858.GA30035@castle>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170622165858.GA30035@castle>
Sender: linux-kernel-owner@vger.kernel.org
To: guro@fb.com
Cc: linux-mm@kvack.org, mhocko@kernel.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org, tj@kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Roman Gushchin wrote:
> On Thu, Jun 22, 2017 at 09:40:28AM +0900, Tetsuo Handa wrote:
> > Roman Gushchin wrote:
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -992,6 +992,13 @@ bool out_of_memory(struct oom_control *oc)
> > >  	if (oom_killer_disabled)
> > >  		return false;
> > >  
> > > +	/*
> > > +	 * If there are oom victims in flight, we don't need to select
> > > +	 * a new victim.
> > > +	 */
> > > +	if (atomic_read(&oom_victims) > 0)
> > > +		return true;
> > > +
> > >  	if (!is_memcg_oom(oc)) {
> > >  		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> > >  		if (freed > 0)
> > 
> > Above in this patch and below in patch 5 are wrong.
> > 
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -665,7 +672,13 @@ static void mark_oom_victim(struct task_struct *tsk)
> > >  	 * that TIF_MEMDIE tasks should be ignored.
> > >  	 */
> > >  	__thaw_task(tsk);
> > > -	atomic_inc(&oom_victims);
> > > +
> > > +	/*
> > > +	 * If there are no oom victims in flight,
> > > +	 * give the task an access to the memory reserves.
> > > +	 */
> > > +	if (atomic_inc_return(&oom_victims) == 1)
> > > +		set_tsk_thread_flag(tsk, TIF_MEMDIE);
> > >  }
> > >  
> > >  /**
> > 
> > The OOM reaper is not available for CONFIG_MMU=n kernels, and timeout based
> > giveup is not permitted, but a multithreaded process might be selected as
> > an OOM victim. Not setting TIF_MEMDIE to all threads sharing an OOM victim's
> > mm increases possibility of preventing some OOM victim thread from terminating
> > (e.g. one of them cannot leave __alloc_pages_slowpath() with mmap_sem held for
> > write due to waiting for the TIF_MEMDIE thread to call exit_oom_victim() when
> > the TIF_MEMDIE thread is waiting for the thread with mmap_sem held for write).
> 
> I agree, that CONFIG_MMU=n is a special case, and the proposed approach can't
> be used directly. But can you, please, why do you find the first  chunk wrong?

Since you are checking oom_victims before checking task_will_free_mem(current),
only one thread can get TIF_MEMDIE. This is where a multithreaded OOM victim without
the OOM reaper can get stuck forever.

> Basically, it's exactly what we do now: we increment oom_victims for every oom
> victim, and every process decrements this counter during it's exit path.
> If there is at least one existing victim, we will select it again, so it's just
> an optimization. Am I missing something? Why should we start new victim selection
> if there processes that will likely quit and release memory soon?

If you check oom_victims like
http://lkml.kernel.org/r/201706220053.v5M0rmOU078764@www262.sakura.ne.jp does,
all threads in a multithreaded OOM victim will have a chance to get TIF_MEMDIE.



By the way, below in patch 5 is also wrong.
You are not permitted to set TIF_MEMDIE if oom_killer_disabled == true.

--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -556,8 +556,18 @@ static void oom_reap_task(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->signal->oom_mm;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
+	while (attempts++ < MAX_OOM_REAP_RETRIES &&
+	       !__oom_reap_task_mm(tsk, mm)) {
+
+		/*
+		 * If the task has no access to the memory reserves,
+		 * grant it to help the task to exit.
+		 */
+		if (!test_tsk_thread_flag(tsk, TIF_MEMDIE))
+			set_tsk_thread_flag(tsk, TIF_MEMDIE);
+
 		schedule_timeout_idle(HZ/10);
+	}
 
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
