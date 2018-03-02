Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D91396B0007
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 09:10:13 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j21so6463061wre.20
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 06:10:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1si4818310wrg.261.2018.03.02.06.10.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Mar 2018 06:10:12 -0800 (PST)
Date: Fri, 2 Mar 2018 15:10:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm,page_alloc: wait for oom_lock than back off
Message-ID: <20180302141000.GB12772@dhcp22.suse.cz>
References: <201802241700.JJB51016.FQOLFJHFOOSVMt@I-love.SAKURA.ne.jp>
 <20180226092725.GB16269@dhcp22.suse.cz>
 <201802261958.JDE18780.SFHOFOMOJFQVtL@I-love.SAKURA.ne.jp>
 <20180226121933.GC16269@dhcp22.suse.cz>
 <201802262216.ADH48949.FtQLFOHJOVSOMF@I-love.SAKURA.ne.jp>
 <201803022010.BJE26043.LtSOOVFQOMJFHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803022010.BJE26043.LtSOOVFQOMJFHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

On Fri 02-03-18 20:10:19, Tetsuo Handa wrote:
> >From e80aeb994a03c3ae108107ea4d4489bbd7d868e9 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 2 Mar 2018 19:56:50 +0900
> Subject: [PATCH v3] mm,page_alloc: wait for oom_lock than back off
> 
> This patch fixes a bug which is essentially same with a bug fixed by
> commit 400e22499dd92613 ("mm: don't warn about allocations which stall for
> too long").
> 
> Currently __alloc_pages_may_oom() is using mutex_trylock(&oom_lock) based
> on an assumption that the owner of oom_lock is making progress for us. But
> it is possible to trigger OOM lockup when many threads concurrently called
> __alloc_pages_slowpath() because all CPU resources are wasted for pointless
> direct reclaim efforts. That is, schedule_timeout_uninterruptible(1) in
> __alloc_pages_may_oom() does not always give enough CPU resource to the
> owner of the oom_lock.
> 
> It is possible that the owner of oom_lock is preempted by other threads.
> Preemption makes the OOM situation much worse. But the page allocator is
> not responsible about wasting CPU resource for something other than memory
> allocation request. Wasting CPU resource for memory allocation request
> without allowing the owner of oom_lock to make forward progress is a page
> allocator's bug.
> 
> Therefore, this patch changes to wait for oom_lock in order to guarantee
> that no thread waiting for the owner of oom_lock to make forward progress
> will not consume CPU resources for pointless direct reclaim efforts.
> 
> We know printk() from OOM situation where a lot of threads are doing almost
> busy-looping is a nightmare. As a side effect of this patch, printk() with
> oom_lock held can start utilizing CPU resources saved by this patch (and
> reduce preemption during printk(), making printk() complete faster).
> 
> By changing !mutex_trylock(&oom_lock) with mutex_lock_killable(&oom_lock),
> it is possible that many threads prevent the OOM reaper from making forward
> progress. Thus, this patch removes mutex_lock(&oom_lock) from the OOM
> reaper.
> 
> Also, since nobody uses oom_lock serialization when setting MMF_OOM_SKIP
> and we don't try last second allocation attempt after confirming that there
> is no !MMF_OOM_SKIP OOM victim, the possibility of needlessly selecting
> more OOM victims will be increased if we continue using ALLOC_WMARK_HIGH.
> Thus, this patch changes to use ALLOC_MARK_MIN.
> 
> Also, since we don't want to sleep with oom_lock held so that we can allow
> threads waiting at mutex_lock_killable(&oom_lock) to try last second
> allocation attempt (because the OOM reaper starts reclaiming memory without
> waiting for oom_lock) and start selecting next OOM victim if necessary,
> this patch changes the location of the short sleep from inside of oom_lock
> to outside of oom_lock.
> 
> But since Michal is still worrying that adding a single synchronization
> point into the OOM path is risky (without showing a real life example
> where lock_killable() in the coldest OOM path hurts), changes made by
> this patch will be enabled only when oom_compat_mode=0 kernel command line
> parameter is specified so that users can test whether their workloads get
> hurt by this patch.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>

Nacked with passion. This is absolutely hideous. First of all there is
absolutely no need for the kernel command line. That is just trying to
dance around the fact that you are not able to argue for the change
and bring reasonable arguments on the table. We definitely do not want
two subtly different modes for the oom handling. Secondly, and repeatedly,
you are squashing multiple changes into a single patch. And finally this
is too big of a hammer for something that even doesn't solve the problem
for PREEMPTIVE kernels which are free to schedule regardless of the
sleep or the reclaim retry you are so passion about.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
