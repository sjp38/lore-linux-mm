Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F13776B025E
	for <linux-mm@kvack.org>; Wed, 25 May 2016 10:30:42 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id g6so78437300obn.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 07:30:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j66si176435oia.77.2016.05.25.07.30.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 May 2016 07:30:42 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, oom_reaper: do not mmput synchronously from the oom reaper context
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1461679470-8364-3-git-send-email-mhocko@kernel.org>
	<201605192329.ABB17132.LFHOFJMVtOSFQO@I-love.SAKURA.ne.jp>
	<20160519172056.GA5290@dhcp22.suse.cz>
	<201605251952.EJF87514.SOJQMOVFOFHFLt@I-love.SAKURA.ne.jp>
	<20160525135002.GI20132@dhcp22.suse.cz>
In-Reply-To: <20160525135002.GI20132@dhcp22.suse.cz>
Message-Id: <201605252330.IAC82384.OOSQHVtFFFLOMJ@I-love.SAKURA.ne.jp>
Date: Wed, 25 May 2016 23:30:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Wed 25-05-16 19:52:18, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > Just a random thought, but after this patch is applied, do we still need to use
> > > > a dedicated kernel thread for OOM-reap operation? If I recall correctly, the
> > > > reason we decided to use a dedicated kernel thread was that calling
> > > > down_read(&mm->mmap_sem) / mmput() from the OOM killer context is unsafe due to
> > > > dependency. By replacing mmput() with mmput_async(), since __oom_reap_task() will
> > > > no longer do operations that might block, can't we try OOM-reap operation from
> > > > current thread which called mark_oom_victim() or oom_scan_process_thread() ?
> > > 
> > > I was already thinking about that. It is true that the main blocker
> > > was the mmput, as you say, but the dedicated kernel thread seems to be
> > > more robust locking and stack wise. So I would prefer staying with the
> > > current approach until we see that it is somehow limitting. One pid and
> > > kernel stack doesn't seem to be a terrible price to me. But as I've said
> > > I am not bound to the kernel thread approach...
> > > 
> > 
> > It seems to me that async OOM reaping widens race window for needlessly
> > selecting next OOM victim, for the OOM reaper holding a reference of a
> > TIF_MEMDIE thread's mm expedites clearing TIF_MEMDIE from that thread
> > by making atomic_dec_and_test() in mmput() from exit_mm() false.
>  
> AFAIU you mean
> __oom_reap_task			exit_mm
>   atomic_inc_not_zero
> 				  tsk->mm = NULL
> 				  mmput
>   				    atomic_dec_and_test # > 0
> 				  exit_oom_victim # New victim will be
> 				  		  # selected
> 				<OOM killer invoked>
> 				  # no TIF_MEMDIE task so we can select a new one
>   unmap_page_range # to release the memory
> 

Yes.

> Previously we were kind of protected by PF_EXITING check in
> oom_scan_process_thread which is not there anymore. The race is possible
> even without the oom reaper because many other call sites might pin
> the address space and be preempted for an unbounded amount of time. We

It is true that there has been a race window even without the OOM reaper
(and I tried to mitigate it using oomkiller_holdoff_timer).
But until the OOM reaper kernel thread was introduced, the sequence

 				  mmput
   				    atomic_dec_and_test # > 0
 				  exit_oom_victim # New victim will be
 				  		  # selected

was able to select another thread sharing that mm (with noisy dump_header()
messages which I think should be suppressed after that thread group received
SIGKILL from oom_kill_process()). Since the OOM reaper is a kernel thread,
this sequence will simply select a different thread group not sharing that mm.
In this regard, I think that async OOM reaping increased possibility of
needlessly selecting next OOM victim.

> could widen the race window by reintroducing the check or moving
> exit_oom_victim later in do_exit after exit_notify which then removes
> the task from the task_list (in __unhash_process) so the OOM killer
> wouldn't see it anyway. Sounds ugly to me though.
> 
> > Maybe we should wait for first OOM reap attempt from the OOM killer context
> > before releasing oom_lock mutex (sync OOM reaping) ?
> 
> I do not think we want to wait inside the oom_lock as it is a global
> lock shared by all OOM killer contexts. Another option would be to use
> the oom_lock inside __oom_reap_task. It is not super cool either because
> now we have a dependency on the lock but looks like reasonably easy
> solution.

It would be nice if we can wait until memory reclaimed from the OOM victim's
mm is queued to freelist for allocation. But I don't have idea other than
oomkiller_holdoff_timer.

I think this problem should be discussed another day in a new thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
