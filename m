Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4404B6B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 06:58:58 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id z6so17047502iob.3
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 03:58:58 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y80si715746iod.4.2018.02.13.03.58.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Feb 2018 03:58:56 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1516628782-3524-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180123083806.GF1526@dhcp22.suse.cz>
	<201801232107.HJB48975.OHJFFOOLFQMVSt@I-love.SAKURA.ne.jp>
	<20180123124245.GK1526@dhcp22.suse.cz>
	<201801242228.FAD52671.SFFLQMOVOFHOtJ@I-love.SAKURA.ne.jp>
In-Reply-To: <201801242228.FAD52671.SFFLQMOVOFHOtJ@I-love.SAKURA.ne.jp>
Message-Id: <201802132058.HAG51540.QFtSLOJFOOFVMH@I-love.SAKURA.ne.jp>
Date: Tue, 13 Feb 2018 20:58:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Michal, if you are busy, can I test my version until you get time?

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 23-01-18 21:07:03, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > To be completely host, I am not in love with this
> > > > schedule_timeout_uninterruptible(1). It is an ugly hack. It used to be
> > > > much more important in the past when the oom victim test was too
> > > > fragile. I strongly suspect that it is not needed this days so rather
> > > > than moving the sleep around I would try to remove it altogether.
> > > 
> > > But this schedule_timeout_uninterruptible(1) serves as a guaranteed
> > > sleep for PF_WQ_WORKER threads
> > > ( http://lkml.kernel.org/r/20170830064019.mfihbeu3mm5ygcrb@dhcp22.suse.cz ).
> > > 
> > >     > If we are under memory pressure, __zone_watermark_ok() can return false.
> > >     > If __zone_watermark_ok() == false, when is schedule_timeout_*() called explicitly?
> > > 
> > >     If all zones fail with the watermark check then we should hit the oom
> > >     path and sleep there. We do not do so for all cases though.
> > > 
> > > Thus, you cannot simply remove it.
> > 
> > Then I would rather make should_reclaim_retry more robust.
> 
> I'm OK with that if we can remove schedule_timeout_*() with oom_lock held.
> 
> > 
> > > > Also, your changelog silently skips over some important details. The
> > > > system must be really overloaded when a short sleep can take minutes.
> > > 
> > > Yes, the system was really overloaded, for I was testing below reproducer
> > > on a x86_32 kernel.
> > [...]
> > > > I would trongly suspect that such an overloaded system doesn't need
> > > > a short sleep to hold the oom lock for too long. All you need is to be
> > > > preempted. So this patch doesn't really solve any _real_ problem.
> > > 
> > > Preemption makes the OOM situation much worse. The only way to avoid all OOM
> > > lockups caused by lack of CPU resource is to replace mutex_trylock(&oom_lock)
> > > in __alloc_pages_may_oom() with mutex_lock(&oom_lock) (or similar) in order to
> > > guarantee that all threads waiting for the OOM killer/reaper to make forward
> > > progress shall give enough CPU resource.
> > 
> > And how exactly does that help when the page allocator gets preempted by
> > somebody not doing any allocation?
> 
> The page allocator is not responsible for wasting CPU resource for something
> other than memory allocation request. Wasting CPU resource due to unable to
> allow the OOM killer/reaper to make forward progress is the page allocator's
> bug.
> 
> There are currently ways to artificially choke the OOM killer/reaper (e.g. let
> a SCHED_IDLE priority thread which is allowed to run on only one specific CPU
> invoke the OOM killer). To mitigate it, offloading the OOM killer to a dedicated
> kernel thread (like the OOM reaper) which has reasonable scheduling priority and
> is allowed to run on any idle CPU will help. But such enhancement is out of scope
> for this patch. This patch is intended for avoid sleeping for minutes at
> schedule_timeout_killable(1) with oom_lock held which can be reproduced without
> using SCHED_IDLE priority and/or runnable CPU restrictions.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
