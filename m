Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9ECE6B0006
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 05:58:36 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id n2so1563134oig.22
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 02:58:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a25si2834753otj.335.2018.02.26.02.58.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Feb 2018 02:58:35 -0800 (PST)
Subject: Re: [PATCH v2] mm,page_alloc: wait for oom_lock than back off
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180220144920.GB21134@dhcp22.suse.cz>
	<201802212327.CAB51013.FOStFVLHFJMOOQ@I-love.SAKURA.ne.jp>
	<20180221145437.GI2231@dhcp22.suse.cz>
	<201802241700.JJB51016.FQOLFJHFOOSVMt@I-love.SAKURA.ne.jp>
	<20180226092725.GB16269@dhcp22.suse.cz>
In-Reply-To: <20180226092725.GB16269@dhcp22.suse.cz>
Message-Id: <201802261958.JDE18780.SFHOFOMOJFQVtL@I-love.SAKURA.ne.jp>
Date: Mon, 26 Feb 2018 19:58:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Sat 24-02-18 17:00:51, Tetsuo Handa wrote:
> > >From d922dd170c2bed01a775e8cca0871098aecc253d Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Sat, 24 Feb 2018 16:49:21 +0900
> > Subject: [PATCH v2] mm,page_alloc: wait for oom_lock than back off
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
> > 
> > We know printk() from OOM situation where a lot of threads are doing almost
> > busy-looping is a nightmare. As a side effect of this patch, printk() with
> > oom_lock held can start utilizing CPU resources saved by this patch (and
> > reduce preemption during printk(), making printk() complete faster).
> > 
> > By changing !mutex_trylock(&oom_lock) with mutex_lock_killable(&oom_lock),
> > it is possible that many threads prevent the OOM reaper from making forward
> > progress. Thus, this patch removes mutex_lock(&oom_lock) from the OOM
> > reaper.
> > 
> > Also, since nobody uses oom_lock serialization when setting MMF_OOM_SKIP
> > and we don't try last second allocation attempt after confirming that there
> > is no !MMF_OOM_SKIP OOM victim, the possibility of needlessly selecting
> > more OOM victims will be increased if we continue using ALLOC_WMARK_HIGH.
> > Thus, this patch changes to use ALLOC_MARK_MIN.
> > 
> > Also, since we don't want to sleep with oom_lock held so that we can allow
> > threads waiting at mutex_lock_killable(&oom_lock) to try last second
> > allocation attempt (because the OOM reaper starts reclaiming memory without
> > waiting for oom_lock) and start selecting next OOM victim if necessary,
> > this patch changes the location of the short sleep from inside of oom_lock
> > to outside of oom_lock.
> 
> This patch does three different things mangled into one patch. All that
> with a patch description which talks a lot but doesn't really explain
> those changes.
> 
> Moreover, you are effectively tunning for an overloaded page allocator
> artifical test case and add a central lock where many tasks would
> block. I have already tried to explain that this is not an universal
> win and you should better have a real life example where this is really
> helpful.
> 
> While I do agree that removing the oom_lock from __oom_reap_task_mm is a
> sensible thing, changing the last allocation attempt to ALLOC_WMARK_MIN
> is not all that straightforward and it would require much more detailed
> explaination.
> 
> So the patch in its current form is not mergeable IMHO.

Your comment is impossible to satisfy.
Please show me your version, for you are keeping me deadlocked.

I'm angry with MM people's attitude that MM people are not friendly to
users who are bothered by lockup / slowdown problems under memory pressure.
They just say "Your system is overloaded" and don't provide enough support
for checking whether they are hitting a real bug other than overloaded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
