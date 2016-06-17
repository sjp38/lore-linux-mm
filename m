Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4EF26B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:12:36 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g13so151124767ioj.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:12:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v7si23147270pae.206.2016.06.17.06.12.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 06:12:35 -0700 (PDT)
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160616142940.GK6836@dhcp22.suse.cz>
	<201606170040.FGC21882.FMLHOtVSFFJOQO@I-love.SAKURA.ne.jp>
	<20160616155347.GO6836@dhcp22.suse.cz>
	<201606172038.IIE43237.FtLMVSFOOHJFQO@I-love.SAKURA.ne.jp>
	<20160617122647.GF21670@dhcp22.suse.cz>
In-Reply-To: <20160617122647.GF21670@dhcp22.suse.cz>
Message-Id: <201606172212.FHJ78143.FJSVFLQOOMtFHO@I-love.SAKURA.ne.jp>
Date: Fri, 17 Jun 2016 22:12:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 17-06-16 20:38:01, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > > Anyway, would you be OK with the patch if I added the current->mm check
> > > > > and resolve its necessity in a separate patch?
> > > > 
> > > > Please correct task_will_free_mem() in oom_kill_process() as well.
> > > 
> > > We cannot hold task_lock over all task_will_free_mem I am even not sure
> > > we have to develop an elaborate way to make it raceless just for the nommu
> > > case. The current case is simple as we cannot race here. Is that
> > > sufficient for you?
> > 
> > We can use find_lock_task_mm() inside mark_oom_victim().
> > That is, call wake_oom_reaper() from mark_oom_victim() like
> > 
> > void mark_oom_victim(struct task_struct *tsk, bool can_use_oom_reaper)
> > {
> > 	WARN_ON(oom_killer_disabled);
> > 	/* OOM killer might race with memcg OOM */
> > 	tsk = find_lock_task_mm(tsk);
> > 	if (!tsk)
> > 		return;
> > 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE)) {
> > 		task_unlock(tsk);
> > 		return;
> > 	}
> > 	task_unlock(tsk);
> > 	atomic_inc(&tsk->signal->oom_victims);
> > 	/*
> > 	 * Make sure that the task is woken up from uninterruptible sleep
> > 	 * if it is frozen because OOM killer wouldn't be able to free
> > 	 * any memory and livelock. freezing_slow_path will tell the freezer
> > 	 * that TIF_MEMDIE tasks should be ignored.
> > 	 */
> > 	__thaw_task(tsk);
> > 	atomic_inc(&oom_victims);
> > 	if (can_use_oom_reaper)
> > 		wake_oom_reaper(tsk);
> > }
> > 
> > and move mark_oom_victim() by normal path to after task_unlock(victim).
> > 
> >  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> > -	mark_oom_victim(victim);
> > 
> > -	if (can_oom_reap)
> > -		wake_oom_reaper(victim);
> > +	wake_oom_reaper(victim, can_oom_reap);
> 
> I do not like this because then we would have to check the reapability
> from inside the oom_reaper again.

I didn't understand why you think so. But strictly speaking, can_oom_reap calculation
in oom_kill_process() is always racy, and [PATCH 10/10] is not safe.

  CPU0 (memory allocating task)       CPU1 (kthread)                    CPU2 (OOM victim)

                                      Calls use_mm(victim->mm).
                                      Starts some worker.
  Enters out_of_memory().
  Enters oom_kill_process().
                                      Finishes some worker.
  Calls rcu_read_lock().
  Sets can_oom_reap = false due to process_shares_mm() && !same_thread_group() && (p->flags & PF_KTHREAD).
                                      Calls unuse_mm(victim->mm).
  Continues scanning other processes.
                                      Calls mmput(victim->mm).
  Sends SIGKILL to victim.
  Calls rcu_read_unlock().
  Leaves oom_kill_process().
                                                                        Calls do_exit().
  Leaves out_of_memory().
                                                                        Sets victim->mm = NULL from exit_mm().
                                                                        Calls mmput() from exit_mm().
                                                                        __mmput() is called because victim was the last user.
  Enters out_of_memory().
  oom_scan_process_thread() returns OOM_SCAN_ABORT.
  Leaves out_of_memory().
                                                                        __mmput() stalls but the oom_reaper is not called.

For correctness, can_oom_reap needs to be calculated inside the oom_reaper.

> 
> But let me ask again. Does this really matter so much just because of
> nommu where we can fall in different traps? Can we simply focus on mmu
> (aka vast majority of cases) make it work reliably and see what we can
> do with nommu later?

To me, timeout based one is sufficient for handling any traps that hit
nommu kernels after the OOM killer is invoked. 

Anyway, I don't like this series because this series ignores theoretical cases.
I can't make progress as long as you repeat "does it really matter/occur".
Please go ahead without Reviewed-by: or Acked-by: from me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
