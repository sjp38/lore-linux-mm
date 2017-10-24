Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 940EF6B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:07:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l24so14185166pgu.17
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 05:07:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y3si88910pfk.622.2017.10.24.05.07.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 05:07:49 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201709090955.HFA57316.QFOSVMtFOJLFOH@I-love.SAKURA.ne.jp>
	<201710172204.AGG30740.tVHJFFOQLMSFOO@I-love.SAKURA.ne.jp>
	<20171020124009.joie5neol3gbdmxe@dhcp22.suse.cz>
	<201710202318.IJE26050.SFVFMOLHQJOOtF@I-love.SAKURA.ne.jp>
	<20171023113057.bdfte7ihtklhjbdy@dhcp22.suse.cz>
In-Reply-To: <20171023113057.bdfte7ihtklhjbdy@dhcp22.suse.cz>
Message-Id: <201710242024.EDH13579.VQLFtFFMOOHSOJ@I-love.SAKURA.ne.jp>
Date: Tue, 24 Oct 2017 20:24:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: aarcange@redhat.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> > > That being said, make sure you adrress all the concerns brought up by
> > > Andrea and Johannes in the above email thread first.
> > 
> > I don't think there are concerns if we wait for oom_lock.
> > The only concern will be do not depend on __GFP_DIRECT_RECLAIM allocation
> > while oom_lock is held. Andrea and Johannes, what are your concerns?
> 
> Read, what they wrote carefully, take their concerns and argument with
> each of them. You cannot simply hand wave them like that.

I'm not hand waving at all. I really can't figure out what are valid concerns.
Below are summary of changes regarding OOM killer serialization.

  As of linux-2.6.11, nothing prevented from concurrently calling out_of_memory().
  TIF_MEMDIE test in select_bad_process() tried to avoid needless OOM killing.
  Thus, it was safe to do __GFP_DIRECT_RECLAIM allocation (apart from which watermark
  should be used) just before calling out_of_memory().

  As of linux-2.6.14, nothing prevented from concurrently calling out_of_memory().
  But unsafe cpuset_lock() call was added to out_of_memory() by ef08e3b4981aebf2
  ("[PATCH] cpusets: confine oom_killer to mem_exclusive cpuset").

  As of linux-2.6.16, cpuset_lock() effectively started acting as today's
  mutex_lock(&oom_lock) by 505970b96e3b7d22 ("[PATCH] cpuset oom lock fix").

  As of linux-2.6.24, cpuset_lock() was removed from out_of_memory() by 3ff566963ce80480
  ("oom: do not take callback_mutex"), and try_set_zone_oom() was added to
  __alloc_pages_may_oom() by ff0ceb9deb6eb017 ("oom: serialize out of memory calls")
  which effectively started acting as a kind of today's mutex_trylock(&oom_lock).

  As of linux-3.19, the ordering of __GFP_FS versus try_set_zone_oom() test was inverted by
  9879de7373fcfb46 ("mm: page_alloc: embed OOM killing naturally into allocation slowpath")
  and was repaired by cc87317726f85153 ("mm: page_alloc: revert inadvertent !__GFP_FS retry
  behavior change").

  As of linux-4.2, try_set_zone_oom() was replaced with oom_lock by dc56401fc9f25e8f
  ("mm: oom_kill: simplify OOM killer locking"). At least by this time, it became
  no longer safe to do __GFP_DIRECT_RECLAIM allocation with oom_lock held, didn't it?

  As of linux-4.9, warn_alloc() for reporting allocation stalls was introduced by
  63f53dea0c9866e9 ("mm: warn about allocations which stall for too long"), and we have
  been discussing how to avoid printk() versus oom_lock deadlock since last December (
  http://lkml.kernel.org/r/1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp )
  by making sure that the thread holding oom_lock can use enough CPU resource and
  the threads not holding oom_lock can refrain from appending to printk() buffer
  and yield enough CPU resource to the thread holding oom_lock.

So, I really cannot figure out why we can compare the concerns of 2.6.11 and 4.14.
Andrea and Johannes, please do come out and explain what your concerns are.

> > > > Below is updated patch. The motivation of this patch is to guarantee that
> > > > the thread (it can be SCHED_IDLE priority) calling out_of_memory() can use
> > > > enough CPU resource by saving CPU resource wasted by threads (they can be
> > > > !SCHED_IDLE priority) waiting for out_of_memory(). Thus, replace
> > > > mutex_trylock() with mutex_lock_killable().
> > > 
> > > So what exactly guanratees SCHED_IDLE running while other high priority
> > > processes keep preempting it while it holds the oom lock? Not everybody
> > > is inside the allocation path to get out of the way.
> > 
> > I think that that is a too much worry. If you worry such possibility,
> > current assumption
> > 
> > 	/*
> > 	 * Acquire the oom lock.  If that fails, somebody else is
> > 	 * making progress for us.
> > 	 */
> > 
> > is horribly broken. Also, high priority threads keep preempting will
> > prevent low priority threads from reaching __alloc_pages_may_oom()
> > because preemption will occur not only during a low priority thread is
> > holding oom_lock but also while oom_lock is not held. We can try to
> > reduce preemption while oom_lock is held by scattering around
> > preempt_disable()/preempt_enable(). But you said you don't want to
> > disable preemption during OOM kill operation when I proposed scattering
> > patch, didn't you?
> > 
> > So, I think that worrying about high priority threads preventing the low
> > priority thread with oom_lock held is too much. Preventing high priority
> > threads waiting for oom_lock from disturbing the low priority thread with
> > oom_lock held by wasting CPU resource will be sufficient.
> 
> In other words this is just to paper over an overloaded allocation path
> close to OOM. Your changelog is really misleading in that direction
> IMHO. I have to think some more about using the full lock rather than
> the trylock, because taking the try lock is somehow easier.

Somehow easier to what? Please don't omit.

I consider that the OOM killer is a safety mechanism in case a system got
overloaded. Therefore, I really hate your comments like "Your system is already
DOSed". It is stupid thing that safety mechanism drives the overloaded system
worse and defunctional when it should rescue.

Current code is somehow easier to OOM lockup due to printk() versus oom_lock
dependency, and I'm proposing a patch for mitigating printk() versus oom_lock
dependency using oom_printk_lock because I can hardly examine OOM related
problems since linux-4.9, and your response was "Hell no!".

> > If you don't like it, the only way will be to offload to a dedicated
> > kernel thread (like the OOM reaper) so that allocating threads are
> > no longer blocked by oom_lock. That's a big change.
> 
> This doesn't solve anything as all the tasks would have to somehow wait
> for the kernel thread to do its stuff.

Which direction are you looking at?

You said "Hell no!" to an attempt which preserves mutex_trylock(&oom_lock).

You said "violent NAK!" to an attempt which effectively replaces
mutex_trylock(&oom_lock) with mutex_lock_killable(&oom_lock) while allow
retrying __GFP_DIRECT_RECLAIM allocation attempt which would more likely
succeed than alloc_pages_before_oomkill(). If their concerns are that we
should retry __GFP_DIRECT_RECLAIM allocation before calling out_of_memory(),
this is a preferred choice (because we can't try __GFP_DIRECT_RECLAIM allocation
with oom_lock held). If their concerns are that we should not delay calling
out_of_memory() too much, alloc_pages_before_oomkill() is a preferred choice.
If their concerns are neither one, please do come out and explain.

You admit that all the threads will have to wait for a thread which does the
OOM-kill operation, and you have even suggested replacing mutex_trylock(&oom_lock)
with mutex_lock_killable(&oom_lock) in the thread above. Despite we have used
mutex_lock(&callback_mutex) for linux-2.6.16 to linux-2.6.23, you don't want to
use mutex_lock_killable(&oom_lock) !?

Are we on the same page that we are seeking for a solution which can allow
a thread doing the OOM-kill operation to use enough CPU resources?

Instead of postponing with comments like "Hell no!" and "violent NAK!", please
explain us your approach and show us your patches which we can apply _now_.
Are you planning to remove oom_lock and go back to linux-2.6.11 so that we
don't need to worry about printk() versus oom_lock deadlock? Are you planning
to completely rewrite the page allocator so that __GFP_DIRECT_RECLAIM
allocating threads are throttled before calling __alloc_pages_may_oom() ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
