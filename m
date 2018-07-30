Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF3C6B000A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 05:33:02 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id s14-v6so9365282wra.0
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:33:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a187-v6si1842045wma.145.2018.07.30.02.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 02:33:00 -0700 (PDT)
Date: Mon, 30 Jul 2018 11:32:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180730093257.GG24267@dhcp22.suse.cz>
References: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
 <20180726113958.GE28386@dhcp22.suse.cz>
 <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat 28-07-18 00:47:40, Tetsuo Handa wrote:
> On 2018/07/26 20:39, Michal Hocko wrote:
> > On Thu 26-07-18 20:06:24, Tetsuo Handa wrote:
> >> Before applying "an OOM lockup mitigation patch", I want to apply this
> >> "another OOM lockup avoidance" patch.
> > 
> > I do not really see why. All these are borderline interesting as the
> > system is basically dead by the time you reach this state.
> 
> I don't like your "borderline interesting". We still don't have a watchdog
> which tells something went wrong. Thus, "borderline interesting" has to be
> examined and fixed.

No question about that. Bugs should be fixed. But this doesn't look like
something we should panic about and rush a half baked or not fully
understood fixes.
 
> >> Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20180726.txt.xz
> >> (which was captured with
> >>
> >>   --- a/mm/oom_kill.c
> >>   +++ b/mm/oom_kill.c
> >>   @@ -1071,6 +1071,12 @@ bool out_of_memory(struct oom_control *oc)
> >>    {
> >>    	unsigned long freed = 0;
> >>    	bool delay = false; /* if set, delay next allocation attempt */
> >>   +	static unsigned long last_warned;
> >>   +	if (!last_warned || time_after(jiffies, last_warned + 10 * HZ)) {
> >>   +		pr_warn("%s(%d) gfp_mask=%#x(%pGg), order=%d\n", current->comm,
> >>   +			current->pid, oc->gfp_mask, &oc->gfp_mask, oc->order);
> >>   +		last_warned = jiffies;
> >>   +	}
> >>    
> >>    	oc->constraint = CONSTRAINT_NONE;
> >>    	if (oom_killer_disabled)
> >>
> >> in order to demonstrate that the GFP_NOIO allocation from disk_events_workfn() is
> >> calling out_of_memory() rather than by error failing to give up direct reclaim).
> >>
> >> [  258.619119] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
> >> [  268.622732] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
> >> [  278.635344] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
> >> [  288.639360] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
> >> [  298.642715] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
> > 
> > Hmm, so there is no other memory allocation to trigger the oom or they
> > all just back off on the oom_lock trylock? In other words what is
> > preventing from the oom killer invocation?
> 
> All __GFP_FS allocations got stuck at direct reclaim or workqueue.

OK, I see. This is important information which was missing in the
previous examination.

[...]

> >> Since the patch shown below was suggested by Michal Hocko at
> >> https://marc.info/?l=linux-mm&m=152723708623015 , it is from Michal Hocko.
> >>
> >> >From cd8095242de13ace61eefca0c3d6f2a5a7b40032 Mon Sep 17 00:00:00 2001
> >> From: Michal Hocko <mhocko@suse.com>
> >> Date: Thu, 26 Jul 2018 14:40:03 +0900
> >> Subject: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at should_reclaim_retry().
> >>
> >> Tetsuo Handa has reported that it is possible to bypass the short sleep
> >> for PF_WQ_WORKER threads which was introduced by commit 373ccbe5927034b5
> >> ("mm, vmstat: allow WQ concurrency to discover memory reclaim doesn't make
> >> any progress") and moved by commit ede37713737834d9 ("mm: throttle on IO
> >> only when there are too many dirty and writeback pages") and lock up the
> >> system if OOM.
> >>
> >> This is because we are implicitly counting on falling back to
> >> schedule_timeout_uninterruptible() in __alloc_pages_may_oom() when
> >> schedule_timeout_uninterruptible() in should_reclaim_retry() was not
> >> called due to __zone_watermark_ok() == false.
> > 
> > How do we rely on that?
> 
> Unless disk_events_workfn() (PID=5) sleeps at schedule_timeout_uninterruptible()
> in __alloc_pages_may_oom(), drain_local_pages_wq() which a thread doing __GFP_FS
> allocation (PID=498) is waiting for cannot be started.

Now you are losing me again. What is going on about
drain_local_pages_wq? I can see that all __GFP_FS allocations are
waiting for a completion which depends on the kworker context to run but
I fail to see why drain_local_pages_wq matters. The memory on the pcp
lists is not accounted to NR_FREE_PAGES IIRC but that should be a
relatively small amount of memory so this cannot be a fundamental
problem here.

> >> However, schedule_timeout_uninterruptible() in __alloc_pages_may_oom() is
> >> not called if all allocating threads but a PF_WQ_WORKER thread got stuck at
> >> __GFP_FS direct reclaim, for mutex_trylock(&oom_lock) by that PF_WQ_WORKER
> >> thread succeeds and out_of_memory() remains no-op unless that PF_WQ_WORKER
> >> thread is doing __GFP_FS allocation.
> > 
> > I have really hard time to parse and understand this.
> 
> You can write as you like.

I can as soon as I understand what is going on.

> >> Tetsuo is observing that GFP_NOIO
> >> allocation request from disk_events_workfn() is preventing other pending
> >> works from starting.
> > 
> > What about any other allocation from !PF_WQ_WORKER context? Why those do
> > not jump in?
> 
> All __GFP_FS allocations got stuck at direct reclaim or workqueue.
> 
> > 
> >> Since should_reclaim_retry() should be a natural reschedule point,
> >> let's do the short sleep for PF_WQ_WORKER threads unconditionally
> >> in order to guarantee that other pending works are started.
> > 
> > OK, this is finally makes some sense. But it doesn't explain why it
> > handles the live lock.
> 
> As explained above, if disk_events_workfn() (PID=5) explicitly sleeps,
> vmstat_update and drain_local_pages_wq from WQ_MEM_RECLAIM workqueue will
> start, and unblock PID=498 which is waiting for drain_local_pages_wq and
> allow PID=498 to invoke the OOM killer.

[  313.714537] systemd-journal D12600   498      1 0x00000000
[  313.716538] Call Trace:
[  313.717683]  ? __schedule+0x245/0x7f0
[  313.719221]  schedule+0x23/0x80
[  313.720586]  schedule_timeout+0x21f/0x400
[  313.722163]  wait_for_completion+0xb2/0x130
[  313.723750]  ? wake_up_q+0x70/0x70
[  313.725134]  flush_work+0x1db/0x2b0
[  313.726535]  ? flush_workqueue_prep_pwqs+0x1b0/0x1b0
[  313.728336]  ? page_alloc_cpu_dead+0x30/0x30
[  313.729936]  drain_all_pages+0x174/0x1e0
[  313.731446]  __alloc_pages_slowpath+0x428/0xc50
[  313.733120]  __alloc_pages_nodemask+0x2a6/0x2c0
[  313.734826]  filemap_fault+0x437/0x8e0
[  313.736296]  ? lock_acquire+0x51/0x70
[  313.737769]  ? xfs_ilock+0x86/0x190 [xfs]
[  313.739309]  __xfs_filemap_fault.constprop.21+0x37/0xc0 [xfs]
[  313.741291]  __do_fault+0x13/0x126
[  313.742667]  __handle_mm_fault+0xc8d/0x11c0
[  313.744245]  handle_mm_fault+0x17a/0x390
[  313.745755]  __do_page_fault+0x24c/0x4d0
[  313.747290]  do_page_fault+0x2a/0x70
[  313.748728]  ? page_fault+0x8/0x30
[  313.750148]  page_fault+0x1e/0x30

This one is waiting for draining and we are in mm_percpu_wq WQ context
which has its rescuer so no other activity can block us for ever. So
this certainly shouldn't deadlock. It can be dead slow but well, this is
what you will get when your shoot your system to death.

So there must be something more going on...
 
> >> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >> Signed-off-by: Michal Hocko <mhocko@suse.com>
> > 
> > Your s-o-b is missing again. I have already told you that previously
> > when you were posting the patch.
> 
> I'm waiting for you to post this change with your wording.
> 
> > 
> > I do not mind this change per se but I am not happy about _your_ changelog.
> > It doesn't explain the underlying problem IMHO. Having a natural and
> > unconditional scheduling point in should_reclaim_retry is a reasonable
> > thing. But how the hack it relates to the livelock you are seeing. So
> > namely the changelog should explain
> > 1) why nobody is able to make forward progress during direct reclaim
> 
> Because GFP_NOIO allocation from one workqueue prevented WQ_MEM_RECLAIM
> workqueues from starting, for it did not call schedule_timeout_*() because
> mutex_trylock(&oom_lock) did not fail because nobody else could call
> __alloc_pages_may_oom().

Why hasn't the rescuer helped here?

> > 2) why nobody is able to trigger oom killer as the last resort
> 
> Because only one !__GFP_FS allocating thread which did not get stuck at
> direct reclaim was able to call __alloc_pages_may_oom().

All the remaining allocations got stuck waiting for completion which
depends on !WQ_MEM_RECLAIM workers right?

-- 
Michal Hocko
SUSE Labs
