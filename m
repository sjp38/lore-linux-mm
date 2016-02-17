Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DC49E828DF
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 15:56:05 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id fl4so17403343pad.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 12:56:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l62si4129033pfi.125.2016.02.17.12.56.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 12:56:04 -0800 (PST)
Subject: Re: [PATCH 1/6] mm,oom: exclude TIF_MEMDIE processes from candidates.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
	<201602171929.IFG12927.OVFJOQHOSMtFFL@I-love.SAKURA.ne.jp>
	<20160217124100.GE29196@dhcp22.suse.cz>
	<201602180140.IHH21322.OSJFHOMtFFOQVL@I-love.SAKURA.ne.jp>
	<20160217173317.GA29370@dhcp22.suse.cz>
In-Reply-To: <20160217173317.GA29370@dhcp22.suse.cz>
Message-Id: <201602180555.EGB24050.HtJFSOLOFFVQMO@I-love.SAKURA.ne.jp>
Date: Thu, 18 Feb 2016 05:55:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > From 4d305f92e2527b6d86cd366952d598f9e95f095b Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Thu, 18 Feb 2016 01:16:54 +0900
> > Subject: [PATCH v2] mm,oom: exclude TIF_MEMDIE processes from candidates.
> > 
> > It is possible that a TIF_MEMDIE thread gets stuck at
> > down_read(&mm->mmap_sem) in exit_mm() called from do_exit() due to
> > one of !TIF_MEMDIE threads doing a GFP_KERNEL allocation between
> > down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem) (e.g. mmap()).
> > In that case, we need to use SysRq-f (manual invocation of the OOM
> > killer) for making progress.
> > 
> > However, it is possible that the OOM killer chooses the same OOM victim
> > forever which already has TIF_MEMDIE. This is effectively disabling
> > SysRq-f. This patch excludes processes which has a TIF_MEMDIE thread
> > from OOM victim candidates.
> > 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > ---
> >  mm/oom_kill.c | 21 ++++++++++++++++++++-
> >  1 file changed, 20 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 6e6abaf..f6f6b47 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -268,6 +268,21 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
> >  }
> >  #endif
> >  
> > +/*
> > + * To determine whether a task is an OOM victim, we examine all the task's
> > + * threads: if one of those has TIF_MEMDIE then the task is an OOM victim.
> > + */
> > +static bool is_oom_victim(struct task_struct *p)
> > +{
> > +	struct task_struct *t;
> > +
> > +	for_each_thread(p, t) {
> > +		if (test_tsk_thread_flag(t, TIF_MEMDIE))
> > +			return true;
> > +	}
> > +	return false;
> > +}
> > +
> >  enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> >  			struct task_struct *task, unsigned long totalpages)
> >  {
> > @@ -278,9 +293,11 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> >  	 * This task already has access to memory reserves and is being killed.
> >  	 * Don't allow any other task to have access to the reserves.
> >  	 */
> > -	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> > +	if (is_oom_victim(task)) {
> 
> This will make the scanning much more time consuming (you will check
> all the threads in the same thread group for each scanned thread!). I
> do not think this is acceptable and it is not really needed for the
> !is_sysrq_oom because we are scanning all the threads anyway.
> 

Yes, I know. What looks complicating to me is that select_bad_process()
uses for_each_process_thread() when has_intersects_mems_allowed() and
task_in_mem_cgroup() are using for_each_thread().

Can't we change select_bad_process() to use for_each_process() ?
What are cases where for_each_process_thread() makes difference from
for_each_process() ?

> Regarding the is_sysrq_oom case we might indeed select a thread
> which doesn't have TIF_MEMDIE but it has been already (group) killed
> but an attempt to catch that case is exactly what has been Nacked
> previously when I tried to achieve the same thing and had TIF_MEMDIE ||
> fatal_signal_pending check
> (http://lkml.kernel.org/r/alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com).
> This change will basically achieve the same (just in much more expansive
> way) so I am not sure it overcomes the previous feedback.
> 
> >  		if (!is_sysrq_oom(oc))
> >  			return OOM_SCAN_ABORT;
> > +		else
> > +			return OOM_SCAN_CONTINUE;
> >  	}
> >  	if (!task->mm || task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> >  		return OOM_SCAN_CONTINUE;
> > @@ -711,6 +728,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  
> >  			if (process_shares_mm(child, p->mm))
> >  				continue;
> > +			if (is_oom_victim(child))
> > +				continue;
> >  			/*
> >  			 * oom_badness() returns 0 if the thread is unkillable
> >  			 */
> > -- 
> > 1.8.3.1
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
