Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E3AF86B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 09:27:35 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id o22so1858209itc.9
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 06:27:35 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p129si12866014itd.33.2018.02.21.06.27.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Feb 2018 06:27:34 -0800 (PST)
Subject: Re: [PATCH] mm,page_alloc: wait for oom_lock than back off
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180123124245.GK1526@dhcp22.suse.cz>
	<201801242228.FAD52671.SFFLQMOVOFHOtJ@I-love.SAKURA.ne.jp>
	<201802132058.HAG51540.QFtSLOJFOOFVMH@I-love.SAKURA.ne.jp>
	<201802202232.IEC26597.FOQtMFOFJHOSVL@I-love.SAKURA.ne.jp>
	<20180220144920.GB21134@dhcp22.suse.cz>
In-Reply-To: <20180220144920.GB21134@dhcp22.suse.cz>
Message-Id: <201802212327.CAB51013.FOStFVLHFJMOOQ@I-love.SAKURA.ne.jp>
Date: Wed, 21 Feb 2018 23:27:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Tue 20-02-18 22:32:56, Tetsuo Handa wrote:
> > >From c3b6616238fcd65d5a0fdabcb4577c7e6f40d35e Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Tue, 20 Feb 2018 11:07:23 +0900
> > Subject: [PATCH] mm,page_alloc: wait for oom_lock than back off
> > 
> > This patch fixes a bug which is essentially same with a bug fixed by
> > commit 400e22499dd92613 ("mm: don't warn about allocations which stall for
> > too long").
> > 
> > Currently __alloc_pages_may_oom() is using mutex_trylock(&oom_lock) based
> > on an assumption that the owner of oom_lock is making progress for us. But
> > it is possible to trigger OOM lockup when many threads concurrently called
> > __alloc_pages_slowpath() because all CPU resources are wasted for pointless
> > direct reclaim efforts. That is, schedule_timeout_uninterruptible(1) in
> > __alloc_pages_may_oom() does not always give enough CPU resource to the
> > owner of the oom_lock.
> > 
> > It is possible that the owner of oom_lock is preempted by other threads.
> > Preemption makes the OOM situation much worse. But the page allocator is
> > not responsible about wasting CPU resource for something other than memory
> > allocation request. Wasting CPU resource for memory allocation request
> > without allowing the owner of oom_lock to make forward progress is a page
> > allocator's bug.
> > 
> > Therefore, this patch changes to wait for oom_lock in order to guarantee
> > that no thread waiting for the owner of oom_lock to make forward progress
> > will not consume CPU resources for pointless direct reclaim efforts.
> 
> So instead we will have many tasks sleeping on the lock and prevent the
> oom reaper to make any forward progress. This is not a solution without
> further steps. Also I would like to see a real life workload that would
> benefit from this.

Of course I will propose follow-up patches. We already discussed that it is
safe to use ALLOC_WMARK_MIN for last second allocation attempt with oom_lock
held and ALLOC_OOM for OOM victim's last second allocation attempt with
oom_lock held. We don't need to serialize whole __oom_reap_task_mm() using
oom_lock; we need to serialize only setting of MMF_OOM_SKIP using oom_lock.
(We won't need oom_lock serialization for setting MMF_OOM_SKIP if everyone
can agree with doing last second allocation attempt with oom_lock held after
confirming that there is no !MMF_OOM_SKIP mm. But we could not agree it.)
Even more, we could try direct OOM reaping than schedule_timeout_killable(1)
if preventing the OOM reaper kernel thread is a problem, for we should be
able to concurrently run __oom_reap_task_mm() because we allow exit_mmap()
and __oom_reap_task_mm() to run concurrently.

We know printk() from OOM situation where a lot of threads are doing almost
busy-looping is a nightmare. printk() with oom_lock held can start utilizing
CPU resources saved by this patch (and reduce preemption during printk(),
making printk() complete faster) is already a benefit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
