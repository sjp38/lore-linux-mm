Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B684D8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 07:22:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z30-v6so718062edd.19
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 04:22:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w15-v6si968991edq.75.2018.09.12.04.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 04:22:45 -0700 (PDT)
Date: Wed, 12 Sep 2018 13:22:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
Message-ID: <20180912112244.GD10951@dhcp22.suse.cz>
References: <201809120306.w8C36JbS080965@www262.sakura.ne.jp>
 <20180912071842.GY10951@dhcp22.suse.cz>
 <201809120758.w8C7wrCN068547@www262.sakura.ne.jp>
 <20180912081733.GA10951@dhcp22.suse.cz>
 <dea26bf6-97f9-a443-4563-1d13bc6e2133@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dea26bf6-97f9-a443-4563-1d13bc6e2133@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 12-09-18 19:59:24, Tetsuo Handa wrote:
> On 2018/09/12 17:17, Michal Hocko wrote:
> > On Wed 12-09-18 16:58:53, Tetsuo Handa wrote:
> >> Michal Hocko wrote:
> >>> OK, I will fold the following to the patch
> >>
> >> OK. But at that point, my patch which tries to wait for reclaimed memory
> >> to be re-allocatable addresses a different problem which you are refusing.
> > 
> > I am trying to address a real world example of when the excessive amount
> > of memory is in page tables. As David pointed, this can happen with some
> > userspace allocators.
> 
> My patch or David's patch will address it as well, without scattering
> down_write(&mm->mmap_sem)/up_write(&mm->mmap_sem) like your attempt.

Based on a timeout. I am trying to fit the fix into an existing retry
logic and it seems this is possible.
 
> >> By the way, is it guaranteed that vma->vm_ops->close(vma) in remove_vma() never
> >> sleeps? Since remove_vma() has might_sleep() since 2005, and that might_sleep()
> >> predates the git history, I don't know what that ->close() would do.
> > 
> > Hmm, I am afraid we cannot assume anything so we have to consider it
> > unsafe. A cursory look at some callers shows that they are taking locks.
> > E.g. drm_gem_object_put_unlocked might take a mutex. So MMF_OOM_SKIP
> > would have to set right after releasing page tables.
> 
> I won't be happy unless handed over section can run in atomic context
> (e.g. preempt_disable()/preempt_enable()) because current thread might be
> SCHED_IDLE priority.
> 
> If current thread is SCHED_IDLE priority, it might be difficult to hand over
> because current thread is unlikely able to reach
> 
> +	if (oom) {
> +		/*
> +		 * the exit path is guaranteed to finish without any unbound
> +		 * blocking at this stage so make it clear to the caller.
> +		 */
> +		mm->mmap = NULL;
> +		up_write(&mm->mmap_sem);
> +	}
> 
> before the OOM reaper kernel thread (which is not SCHED_IDLE priority) checks
> whether mm->mmap is already NULL.
> 
> Honestly, I'm not sure whether current thread (even !SCHED_IDLE priority) can
> reach there before the OOM killer checks whether mm->mmap is already NULL, for
> current thread has to do more things than the OOM reaper can do.
> 
> Also, in the worst case,
> 
> +                               /*
> +                                * oom_reaper cannot handle mlocked vmas but we
> +                                * need to serialize it with munlock_vma_pages_all
> +                                * which clears VM_LOCKED, otherwise the oom reaper
> +                                * cannot reliably test it.
> +                                */
> +                               if (oom)
> +                                       down_write(&mm->mmap_sem);
> 
> would cause the OOM reaper to set MMF_OOM_SKIP without reclaiming any memory
> if munlock_vma_pages_all(vma) by current thread did not complete quick enough
> to make down_read_trylock(&mm->mmap_sem) attempt by the OOM reaper succeed.

Which is kind of inherent problem, isn't it? Unless we add some sort of
priority inheritance then this will be always the case. And this is by
far not OOM specific. It is the full memory reclaim path. So I really do
not see this as an argument. More importantly though, no timeout based
solution will handle it better.

As I've said countless times. I do not really consider this to be
interesting case until we see that actual real world workloads really
suffer from this problem.

So can we focus on the practical problems please?
-- 
Michal Hocko
SUSE Labs
