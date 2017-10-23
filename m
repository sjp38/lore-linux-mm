Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 767556B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 07:31:00 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c21so999254wrg.16
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 04:31:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b78si5518694wrd.92.2017.10.23.04.30.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 04:30:59 -0700 (PDT)
Date: Mon, 23 Oct 2017 13:30:57 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after
 selecting an OOM victim.
Message-ID: <20171023113057.bdfte7ihtklhjbdy@dhcp22.suse.cz>
References: <201708242340.ICG00066.JtFOFVSMOHOLFQ@I-love.SAKURA.ne.jp>
 <20170825080020.GE25498@dhcp22.suse.cz>
 <201709090955.HFA57316.QFOSVMtFOJLFOH@I-love.SAKURA.ne.jp>
 <201710172204.AGG30740.tVHJFFOQLMSFOO@I-love.SAKURA.ne.jp>
 <20171020124009.joie5neol3gbdmxe@dhcp22.suse.cz>
 <201710202318.IJE26050.SFVFMOLHQJOOtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710202318.IJE26050.SFVFMOLHQJOOtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: aarcange@redhat.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

On Fri 20-10-17 23:18:19, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 17-10-17 22:04:59, Tetsuo Handa wrote:
> > > Below is updated patch. The motivation of this patch is to guarantee that
> > > the thread (it can be SCHED_IDLE priority) calling out_of_memory() can use
> > > enough CPU resource by saving CPU resource wasted by threads (they can be
> > > !SCHED_IDLE priority) waiting for out_of_memory(). Thus, replace
> > > mutex_trylock() with mutex_lock_killable().
> > 
> > So what exactly guanratees SCHED_IDLE running while other high priority
> > processes keep preempting it while it holds the oom lock? Not everybody
> > is inside the allocation path to get out of the way.
> 
> I think that that is a too much worry. If you worry such possibility,
> current assumption
> 
> 	/*
> 	 * Acquire the oom lock.  If that fails, somebody else is
> 	 * making progress for us.
> 	 */
> 
> is horribly broken. Also, high priority threads keep preempting will
> prevent low priority threads from reaching __alloc_pages_may_oom()
> because preemption will occur not only during a low priority thread is
> holding oom_lock but also while oom_lock is not held. We can try to
> reduce preemption while oom_lock is held by scattering around
> preempt_disable()/preempt_enable(). But you said you don't want to
> disable preemption during OOM kill operation when I proposed scattering
> patch, didn't you?
> 
> So, I think that worrying about high priority threads preventing the low
> priority thread with oom_lock held is too much. Preventing high priority
> threads waiting for oom_lock from disturbing the low priority thread with
> oom_lock held by wasting CPU resource will be sufficient.

In other words this is just to paper over an overloaded allocation path
close to OOM. Your changelog is really misleading in that direction
IMHO. I have to think some more about using the full lock rather than
the trylock, because taking the try lock is somehow easier.

> If you don't like it, the only way will be to offload to a dedicated
> kernel thread (like the OOM reaper) so that allocating threads are
> no longer blocked by oom_lock. That's a big change.

This doesn't solve anything as all the tasks would have to somehow wait
for the kernel thread to do its stuff.
 
> > > By replacing mutex_trylock() with mutex_lock_killable(), it might prevent
> > > the OOM reaper from start reaping immediately. Thus, remove mutex_lock() from
> > > the OOM reaper.
> > 
> > oom_lock shouldn't be necessary in oom_reaper anymore and that is worth
> > a separate patch.
> 
> I'll propose as a separate patch after we apply "mm, oom:
> task_will_free_mem(current) should ignore MMF_OOM_SKIP for once." or
> we call __alloc_pages_slowpath() with oom_lock held.
> 
> >  
> > > By removing mutex_lock() from the OOM reaper, the race window of needlessly
> > > selecting next OOM victim becomes wider, for the last second allocation
> > > attempt no longer waits for the OOM reaper. Thus, do the really last
> > > allocation attempt after selecting an OOM victim using the same watermark.
> > > 
> > > Can we go with this direction?
> > 
> > The patch is just too cluttered. You do not want to use
> > __alloc_pages_slowpath. get_page_from_freelist would be more
> > appropriate. Also doing alloc_pages_before_oomkill two times seems to be
> > excessive.
> 
> This patch is intentionally calling __alloc_pages_slowpath() because
> it handles ALLOC_OOM by calling __gfp_pfmemalloc_flags(). If this patch
> calls only get_page_from_freelist(), we will fail to try ALLOC_OOM before
> calling out_of_memory() (when current thread is selected as OOM victim
> while waiting for oom_lock) and just before sending SIGKILL (when
> task_will_free_mem(current) in out_of_memory() returned false because
> MMF_OOM_SKIP was set before ALLOC_OOM allocation is attempted) unless
> we apply "mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP
> for once.".

Nothing really prevents you from re-evaluating alloc_flags which is
definitely preferred to maintaining an already complext allocator slow
path reentrant safe.
 
> > That being said, make sure you adrress all the concerns brought up by
> > Andrea and Johannes in the above email thread first.
> 
> I don't think there are concerns if we wait for oom_lock.
> The only concern will be do not depend on __GFP_DIRECT_RECLAIM allocation
> while oom_lock is held. Andrea and Johannes, what are your concerns?

Read, what they wrote carefully, take their concerns and argument with
each of them. You cannot simply hand wave them like that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
