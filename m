Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 094EC6B025E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:03:44 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hb4so94301317pac.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:03:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y80si7699664pfb.47.2016.04.14.08.03.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 08:03:42 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Clarify reason to kill other threads sharing thevitctim's memory.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1460631391-8628-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160414113108.GE2850@dhcp22.suse.cz>
In-Reply-To: <20160414113108.GE2850@dhcp22.suse.cz>
Message-Id: <201604150003.GAI13041.MLHFOtOFOQSJVF@I-love.SAKURA.ne.jp>
Date: Fri, 15 Apr 2016 00:03:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Thu 14-04-16 19:56:31, Tetsuo Handa wrote:
> > Current comment for "Kill all user processes sharing victim->mm in other
> > thread groups" is not clear that doing so is a best effort avoidance.
> > 
> > I tried to update that logic along with TIF_MEMDIE for several times
> > but not yet accepted. Therefore, this patch changes only comment so that
> > we can apply now.
> > 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > ---
> >  mm/oom_kill.c | 29 ++++++++++++++++++++++-------
> >  1 file changed, 22 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index e78818d..43d0002 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -814,13 +814,28 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  	task_unlock(victim);
> >  
> >  	/*
> > -	 * Kill all user processes sharing victim->mm in other thread groups, if
> > -	 * any.  They don't get access to memory reserves, though, to avoid
> > -	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
>            ^^^^^^^^^
> this was an useful information which you have dropped. Why?
> 

Because I don't think setting TIF_MEMDIE to all threads sharing the victim's
memory at oom_kill_process() increases the risk of depleting the memory
reserves, for TIF_MEMDIE helps only if that thread is doing memory allocation.
I explained it at
http://lkml.kernel.org/r/201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp .

> > -	 * oom killed thread cannot exit because it requires the semaphore and
> > -	 * its contended by another thread trying to allocate memory itself.
> > -	 * That thread will now get access to memory reserves since it has a
> > -	 * pending fatal signal.
> > +	 * Kill all user processes sharing victim->mm in other thread groups,
> > +	 * if any. This reduces possibility of hitting mm->mmap_sem livelock
> > +	 * when an OOM victim thread cannot exit because it requires the
> > +	 * mm->mmap_sem for read at exit_mm() while another thread is trying
> > +	 * to allocate memory with that mm->mmap_sem held for write.
> > +	 *
> > +	 * Any thread except the victim thread itself which is killed by
> > +	 * this heuristic does not get access to memory reserves as of now,
> > +	 * but it will get access to memory reserves by calling out_of_memory()
> > +	 * or mem_cgroup_out_of_memory() since it has a pending fatal signal.
> > +	 *
> > +	 * Note that this heuristic is not perfect because it is possible that
> > +	 * a thread which shares victim->mm and is doing memory allocation with
> > +	 * victim->mm->mmap_sem held for write is marked as OOM_SCORE_ADJ_MIN.
> 
> Is this really helpful? I would rather be explicit that we _do not care_
> about these configurations. It is just PITA maintain and it doesn't make
> any sense. So rather than trying to document all the weird thing that
> might happen I would welcome a warning "mm shared with OOM_SCORE_ADJ_MIN
> task. Something is broken in your configuration!"

Would you please stop rejecting configurations which do not match your values?
The OOM killer provides a safety net against accidental memory usage.
A properly configured system should not call out_of_memory() from the beginning.
Systems you call properly configured should use panic_on_oom > 0.
What I'm asking for is a workaround for rescuing current users from unexplained
silent hangups.

> 
> > +	 * Also, it is possible that a thread which shares victim->mm and is
> > +	 * doing memory allocation with victim->mm->mmap_sem held for write
> > +	 * (possibly the victim thread itself which got TIF_MEMDIE) is blocked
> > +	 * at unkillable locks from direct reclaim paths because nothing
> > +	 * prevents TIF_MEMDIE threads which already started direct reclaim
> > +	 * paths from being blocked at unkillable locks. In such cases, the
> > +	 * OOM reaper will be unable to reap victim->mm and we will need to
> > +	 * select a different OOM victim.
> 
> This is a more general problem and not related to this particular code.
> Whenever we select a victim and call mark_oom_victim we hope it will
> eventually get out of its kernel code path (unless it was running in the
> userspace) so I am not sure this is placed properly.

To be able to act as a safety net, we should not ignore corner cases.
Please explain your approach for handling the slowpath.

> 
> >  	 */
> >  	rcu_read_lock();
> >  	for_each_process(p) {
> > -- 
> > 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
