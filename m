Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 298316B007E
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 10:01:05 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id zm5so91723039pac.0
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 07:01:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f18si7205754pfd.206.2016.04.09.07.01.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 09 Apr 2016 07:01:04 -0700 (PDT)
Subject: Re: [PATCH 5/6] mm,oom: Re-enable OOM killer using timers.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
	<201602171934.DGG57308.FOSFMQVLOtJFHO@I-love.SAKURA.ne.jp>
	<20160217132052.GI29196@dhcp22.suse.cz>
In-Reply-To: <20160217132052.GI29196@dhcp22.suse.cz>
Message-Id: <201604092300.BDI39040.FFSQLJOMHOOVtF@I-love.SAKURA.ne.jp>
Date: Sat, 9 Apr 2016 23:00:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com

Michal Hocko wrote:
> On Wed 17-02-16 19:34:46, Tetsuo Handa wrote:
> > >From 6f07b71c97766ec111d26c3424bded465ca48195 Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Wed, 17 Feb 2016 16:37:01 +0900
> > Subject: [PATCH 5/6] mm,oom: Re-enable OOM killer using timers.
> > 
> > We are trying to reduce the possibility of hitting OOM livelock by
> > introducing the OOM reaper, but there are situations where the OOM reaper
> > cannot reap the victim's memory. We want to introduce the OOM reaper as
> > simple as possible and make the OOM reaper better via incremental
> > development.
> > 
> > This patch adds a timer for handling corner cases where a TIF_MEMDIE
> > thread got stuck by reasons not handled by the initial version of the
> > OOM reaper. Since "mm,oom: exclude TIF_MEMDIE processes from candidates."
> > made sure that we won't choose the same OOM victim forever and this patch
> > makes sure that the kernel automatically presses SysRq-f upon OOM stalls,
> > we will not OOM stall forever as long as the OOM killer is called.
> 
> Can we actually start by incremental changes first and only get to this
> after we cannot find a proper way to fix existing issues?
> 
> I would like to at least make mmap_sem taken for write killable
> first. This should allow the oom_reaper to make a forward progress and
> allow the OOM killer to select another task when necessary (e.g. the
> victim wasn't sitting on a large amount of reclaimable memory). This
> has an advantage that the TIF_MEMDIE release is bound to a clearly
> defined action rather than a $RANDOM timemout which will always be hard
> to justify. We can talk about timeout based solutions after we are able
> to livelock the system even after all well defined actions will have
> failed. I really consider it premature right now.
> 

We can never fix the mmap_sem taken for write issue because

  (1) You hesitate to guarantee sending SIGKILL to all thread groups
      sharing the victim's memory by eliminating the shortcuts which
      do not send SIGKILL.

  (2) Even if you agree on guarantee sending SIGKILL to all thread
      groups sharing the victim's memory by eliminating the shortcuts,
      there might be OOM_SCORE_ADJ_MIN thread groups which means that
      we are not allowed to send SIGKILL after all.

Unlocking TIF_MEMDIE by the OOM reaper upon successful reaping is
the fastpath and unlocking TIF_MEMDIE by the timer is the slowpath.

Also, I think that the OOM reaper would be a too large change to backport
for 3.10-based and 2.6.32-based distributions.

There is no reason to add this patch which handles the slowpath right now.

> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > ---
> >  mm/oom_kill.c | 10 +++++++++-
> >  1 file changed, 9 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index ebc6764..fba2c62 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -45,6 +45,11 @@ int sysctl_oom_dump_tasks = 1;
> >  
> >  DEFINE_MUTEX(oom_lock);
> >  
> > +static void oomkiller_reset(unsigned long arg)
> > +{
> > +}
> > +static DEFINE_TIMER(oomkiller_victim_wait_timer, oomkiller_reset, 0, 0);
> > +
> >  #ifdef CONFIG_NUMA
> >  /**
> >   * has_intersects_mems_allowed() - check task eligiblity for kill
> > @@ -299,7 +304,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> >  	 */
> >  	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> >  		if (!is_sysrq_oom(oc))
> > -			return OOM_SCAN_ABORT;
> > +			return timer_pending(&oomkiller_victim_wait_timer) ?
> > +				OOM_SCAN_ABORT : OOM_SCAN_CONTINUE;
> >  	}
> >  	if (!task->mm)
> >  		return OOM_SCAN_CONTINUE;
> > @@ -452,6 +458,8 @@ void mark_oom_victim(struct task_struct *tsk)
> >  	 */
> >  	__thaw_task(tsk);
> >  	atomic_inc(&oom_victims);
> > +	/* Make sure that we won't wait for this task forever. */
> > +	mod_timer(&oomkiller_victim_wait_timer, jiffies + 5 * HZ);
> >  }
> >  
> >  /**
> > -- 
> > 1.8.3.1
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
