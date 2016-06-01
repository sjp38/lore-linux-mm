Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5A46B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 08:04:31 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id lp2so32536753igb.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 05:04:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t83si13963966oig.89.2016.06.01.05.04.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 05:04:30 -0700 (PDT)
Subject: Re: [PATCH 6/6] mm, oom: fortify task_will_free_mem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464613556-16708-7-git-send-email-mhocko@kernel.org>
	<201606010003.CAH18706.LFHOFVOJtQOSFM@I-love.SAKURA.ne.jp>
	<20160531151019.GN26128@dhcp22.suse.cz>
	<201606010029.AHH64521.SOOQFMJFLOVFHt@I-love.SAKURA.ne.jp>
	<20160601072549.GD26601@dhcp22.suse.cz>
In-Reply-To: <20160601072549.GD26601@dhcp22.suse.cz>
Message-Id: <201606012104.FIC12458.FOFHtOFMOSLVJQ@I-love.SAKURA.ne.jp>
Date: Wed, 1 Jun 2016 21:04:18 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

Michal Hocko wrote:
> On Wed 01-06-16 00:29:45, Tetsuo Handa wrote:
> > I'm fine with task_will_free_mem(current) == true case. My question is that
> > "doesn't this patch break task_will_free_mem(current) == false case when there is
> > already TIF_MEMDIE thread" ?
> 
> OK, I see your point now. This is certainly possible, albeit unlikely. I
> think calling this a regression would be a bit an overstatement. We are
> basically replacing one unreliable heuristic by another one which is
> more likely to lead to a deterministic behavior.
> 
> If you are worried about locking up the oom killer I have another 2
> patches on top of this series which should deal with that (one of them
> was already posted [1] and another one was drafted in [2]. Both of them
> on top of this series should remove the concern of the lockup. I just
> wait to post them until this thread settles down.
> 
> [1] http://lkml.kernel.org/r/1464276476-25136-1-git-send-email-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/20160527133502.GN27686@dhcp22.suse.cz

I want [1] though I don't know we should try twice. But I still can't
understand why [2] works. Setting MMF_OOM_REAPED on victim's mm_struct
allows oom_scan_process_thread() to call oom_badness() only after TIF_MEMDIE
was removed from that victim. Since oom_reap_task() is not called due to
can_oom_reap == false, nobody will be able to remove TIF_MEMDIE from that
victim if that victim got stuck at unkillable wait.
down_write_killable(&mm->mmap_sem) might not reduce possibility of lockup
when oom_reap_task() is not called.

Quoting from http://lkml.kernel.org/r/20160530115551.GU22928@dhcp22.suse.cz :
> But your bottom half would just decide to back off the same way I do
> here. And as for the bonus your bottom half would have to do the rather
> costly process iteration to find that out.

Doing the rather costly process iteration for up to one second (though most
of duration is schedule_timeout_idle(HZ/10)) gives that victim some reasonable
grace period for termination before the OOM killer selects next OOM victim.

If we set MMF_OOM_REAPED as of oom_kill_process() while also setting
TIF_MEMDIE, the OOM killer can lock up like described above.
If we set MMF_OOM_REAPED as of oom_kill_process() while not setting
TIF_MEMDIE, the OOM killer will immediately select next OOM victim
which is almost

 enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 			struct task_struct *task, unsigned long totalpages)
 {
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
 		return OOM_SCAN_CONTINUE;
 
-	/*
-	 * This task already has access to memory reserves and is being killed.
-	 * Don't allow any other task to have access to the reserves.
-	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
-		return OOM_SCAN_ABORT;
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.
 	 */
 	if (oom_task_origin(task))
 		return OOM_SCAN_SELECT;
 
 	return OOM_SCAN_OK;
 }

situation when we hit can_oom_reap == false. Since not many thread groups
will hit can_oom_reap == false condition, above situation won't kill all
thread groups. But I think that waiting for one second before backing off
is acceptable from the point of view of least killing. This resembles

Quoting from http://lkml.kernel.org/r/20160601073441.GE26601@dhcp22.suse.cz :
> > > > Third is that oom_kill_process() chooses a thread group which already
> > > > has a TIF_MEMDIE thread when the candidate select_bad_process() chose
> > > > has children because oom_badness() does not take TIF_MEMDIE into account.
> > > > This patch checks child->signal->oom_victims before calling oom_badness()
> > > > if oom_kill_process() was called by SysRq-f case. This resembles making
> > > > sure that oom_badness() is skipped by returning OOM_SCAN_CONTINUE.
> > > 
> > > This makes sense to me as well but why should be limit this to sysrq case?
> > > Does it make any sense to select a child which already got killed for
> > > normal OOM killer? Anyway I think it would be better to split this into
> > > its own patch as well.
> > 
> > The reason is described in next paragraph.
> > Do we prefer immediately killing all children of the allocating task?
> 
> I do not think we want to select them _all_. We haven't been doing that
> and I do not see a reason we should start now. But it surely doesn't
> make any sense to select a task which has already TIF_MEMDIE set.

"although selecting a TIF_MEMDIE thread group forever does not make any
sense, we haven't tried selecting next thread group as soon as some thread
group got TIF_MEMDIE".

Setting MMF_OOM_REAPED and clearing TIF_MEMDIE after some period is the key.

My bottom half does not require user visible changes. If some programs use
clone(CLONE_VM without CLONE_SIGHAND) and mix OOM_SCORE_ADJ_MIN /
OOM_SCORE_ADJ_MAX, I think they have reason they want to do so (e.g.
shrink memory usage when OOM_SCORE_ADJ_MAX thread group was OOM-killed).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
