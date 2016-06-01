Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81DF56B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 08:43:38 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o70so9166805lfg.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 05:43:38 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id d5si48633391wjz.233.2016.06.01.05.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 05:43:37 -0700 (PDT)
Received: by mail-wm0-f48.google.com with SMTP id n184so29893495wmn.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 05:43:36 -0700 (PDT)
Date: Wed, 1 Jun 2016 14:43:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm, oom: fortify task_will_free_mem
Message-ID: <20160601124335.GM26601@dhcp22.suse.cz>
References: <1464613556-16708-7-git-send-email-mhocko@kernel.org>
 <201606010003.CAH18706.LFHOFVOJtQOSFM@I-love.SAKURA.ne.jp>
 <20160531151019.GN26128@dhcp22.suse.cz>
 <201606010029.AHH64521.SOOQFMJFLOVFHt@I-love.SAKURA.ne.jp>
 <20160601072549.GD26601@dhcp22.suse.cz>
 <201606012104.FIC12458.FOFHtOFMOSLVJQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606012104.FIC12458.FOFHtOFMOSLVJQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

On Wed 01-06-16 21:04:18, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 01-06-16 00:29:45, Tetsuo Handa wrote:
> > > I'm fine with task_will_free_mem(current) == true case. My question is that
> > > "doesn't this patch break task_will_free_mem(current) == false case when there is
> > > already TIF_MEMDIE thread" ?
> > 
> > OK, I see your point now. This is certainly possible, albeit unlikely. I
> > think calling this a regression would be a bit an overstatement. We are
> > basically replacing one unreliable heuristic by another one which is
> > more likely to lead to a deterministic behavior.
> > 
> > If you are worried about locking up the oom killer I have another 2
> > patches on top of this series which should deal with that (one of them
> > was already posted [1] and another one was drafted in [2]. Both of them
> > on top of this series should remove the concern of the lockup. I just
> > wait to post them until this thread settles down.
> > 
> > [1] http://lkml.kernel.org/r/1464276476-25136-1-git-send-email-mhocko@kernel.org
> > [2] http://lkml.kernel.org/r/20160527133502.GN27686@dhcp22.suse.cz
> 
> I want [1] though I don't know we should try twice. But I still can't
> understand why [2] works. Setting MMF_OOM_REAPED on victim's mm_struct
> allows oom_scan_process_thread() to call oom_badness() only after TIF_MEMDIE
> was removed from that victim. Since oom_reap_task() is not called due to
> can_oom_reap == false, nobody will be able to remove TIF_MEMDIE from that
> victim if that victim got stuck at unkillable wait.
> down_write_killable(&mm->mmap_sem) might not reduce possibility of lockup
> when oom_reap_task() is not called.

You are right of course. I didn't say [2] is complete. That's why I've said
"was drafted in". Let's discuss this further when I send the actual
patch, ok?

> Quoting from http://lkml.kernel.org/r/20160530115551.GU22928@dhcp22.suse.cz :

And we are yet again conflating different threads which will end up in a
mess. :/ Please not I won't follow up to any comments which are not
related to the discussed patch.

> > But your bottom half would just decide to back off the same way I do
> > here. And as for the bonus your bottom half would have to do the rather
> > costly process iteration to find that out.
> 
> Doing the rather costly process iteration for up to one second (though most
> of duration is schedule_timeout_idle(HZ/10)) gives that victim some reasonable
> grace period for termination before the OOM killer selects next OOM victim.

we have that short sleep in out_of_memory path already. Btw. we do not
do costly operations just to emulate a short sleep...
 
> If we set MMF_OOM_REAPED as of oom_kill_process() while also setting
> TIF_MEMDIE, the OOM killer can lock up like described above.
> If we set MMF_OOM_REAPED as of oom_kill_process() while not setting
> TIF_MEMDIE, the OOM killer will immediately select next OOM victim
> which is almost

I would rather risk a next OOM victim than risk a lockup in a highly
unlikely scenario. This is simply a trade off.

[...]

> situation when we hit can_oom_reap == false. Since not many thread groups
> will hit can_oom_reap == false condition, above situation won't kill all
> thread groups. But I think that waiting for one second before backing off
> is acceptable from the point of view of least killing. This resembles
> 
> Quoting from http://lkml.kernel.org/r/20160601073441.GE26601@dhcp22.suse.cz :
> > > > > Third is that oom_kill_process() chooses a thread group which already
> > > > > has a TIF_MEMDIE thread when the candidate select_bad_process() chose
> > > > > has children because oom_badness() does not take TIF_MEMDIE into account.
> > > > > This patch checks child->signal->oom_victims before calling oom_badness()
> > > > > if oom_kill_process() was called by SysRq-f case. This resembles making
> > > > > sure that oom_badness() is skipped by returning OOM_SCAN_CONTINUE.
> > > > 
> > > > This makes sense to me as well but why should be limit this to sysrq case?
> > > > Does it make any sense to select a child which already got killed for
> > > > normal OOM killer? Anyway I think it would be better to split this into
> > > > its own patch as well.
> > > 
> > > The reason is described in next paragraph.
> > > Do we prefer immediately killing all children of the allocating task?
> > 
> > I do not think we want to select them _all_. We haven't been doing that
> > and I do not see a reason we should start now. But it surely doesn't
> > make any sense to select a task which has already TIF_MEMDIE set.
> 
> "although selecting a TIF_MEMDIE thread group forever does not make any
> sense, we haven't tried selecting next thread group as soon as some thread
> group got TIF_MEMDIE".

Note that we are talking about sysctl_oom_kill_allocating_task and that
kills tasks randomly without trying to wait for other victims to release
their memory. I do not _really_ there is anything to optimize for here
with some timeouts.
 
> Setting MMF_OOM_REAPED and clearing TIF_MEMDIE after some period is the key.
> 
> My bottom half does not require user visible changes. If some programs use
> clone(CLONE_VM without CLONE_SIGHAND) and mix OOM_SCORE_ADJ_MIN /
> OOM_SCORE_ADJ_MAX, I think they have reason they want to do so (e.g.
> shrink memory usage when OOM_SCORE_ADJ_MAX thread group was OOM-killed).

If there is such a use case then I would really like to hear about that.
I do not want to make the already obscure code more complicated just for
some usecase that even might not exist.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
