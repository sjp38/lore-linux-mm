Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 886416B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 07:07:58 -0500 (EST)
Received: by igcmv3 with SMTP id mv3so99786719igc.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 04:07:58 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j3si28354437igx.20.2015.12.08.04.07.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 04:07:57 -0800 (PST)
Subject: Why can't we use __GFP_KILLABLE?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201512082107.HIH90660.MQVFFSLHOFOtJO@I-love.SAKURA.ne.jp>
Date: Tue, 8 Dec 2015 21:07:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org

Forking from http://lkml.kernel.org/r/20151207160718.GA20774@dhcp22.suse.cz .

Michal Hocko wrote:
> On Sat 05-12-15 21:33:47, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Sun 29-11-15 01:10:10, Tetsuo Handa wrote:
> > > > Tetsuo Handa wrote:
> > > > > > Users of mmap_sem which need it for write should be carefully reviewed
> > > > > > to use _killable waiting as much as possible and reduce allocations
> > > > > > requests done with the lock held to absolute minimum to reduce the risk
> > > > > > even further.
> > > > > 
> > > > > It will be nice if we can have down_write_killable()/down_read_killable().
> > > > 
> > > > It will be nice if we can also have __GFP_KILLABLE.
> > > 
> > > Well, we already do this implicitly because OOM killer will
> > > automatically do mark_oom_victim if it has fatal_signal_pending and then
> > > __alloc_pages_slowpath fails the allocation if the memory reserves do
> > > not help to finish the allocation.
> > 
> > I don't think so because !__GFP_FS && !__GFP_NOFAIL allocations do not do
> > mark_oom_victim() even if fatal_signal_pending() is true because
> > out_of_memory() is not called.
> 
> OK you are right about GFP_NOFS allocations. I didn't consider them
> because I still think that GFP_NOFS needs a separate solution. Ideally
> systematic one but if this is really urgent and cannot wait for it then
> we can at least check for fatal_signal_pending in __alloc_pages_may_oom.

Really urgent patch for me is kmallocwd kernel thread. I showed you that
it is not difficult to defeat oom_reaper kernel thread. Without a watchdog
mechanism, we will continue failing to catch problems caused by memory
allocators.

> Something like:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 728b7a129df3..42a78aee36f3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2754,9 +2754,11 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  			/*
>  			 * XXX: Page reclaim didn't yield anything,
>  			 * and the OOM killer can't be invoked, but
> -			 * keep looping as per tradition.
> +			 * keep looping as per tradition. Do not bother
> +			 * if we are killed already though
>  			 */
> -			*did_some_progress = 1;
> +			if (!fatal_signal_pending(current))
> +				*did_some_progress = 1;
>  			goto out;
>  		}
>  		if (pm_suspended_storage())
> 

I don't think this change is acceptable. This change is almost same with
commit 9879de7373fc ("mm: page_alloc: embed OOM killing naturally into
allocation slowpath") because it exposes any !__GFP_FS && !__GFP_NOFAIL
allocations by killable tasks to risk of triggering filesystem errors
and/or disk I/O errors due to -ENOMEM when SIGKILL is delivered under
almost OOM and/or OOM-livelock.

> __GFP_KILLABLE sounds like adding more mess to the current situation
> to me. Weak reclaim context which is unkillable is simply a bad
> design. Putting __GFP_KILLABLE doesn't make it work properly.

I think it is quite opposite. __GFP_KILLABLE allows __GFP_FS allocations
to leave the memory allocation loop regardless of whether we are in OOM
livelock trouble or not. If we are in OOM livelock trouble, voluntarily
leaving the memory allocator (than burning CPU cycles) should be welcomed.
Imagine a situation where one of 1000 tasks sharing the same memory got
TIF_MEMDIE + SIGKILL while the remaining 999 tasks got only SIGKILL. If
999 tasks voluntarily leave the memory allocator upon SIGKILL and releases
the lock which the TIF_MEMDIE + SIGKILL task is waiting for, it helps
resolving OOM livelock trouble because we don't need to allow 999 tasks
to access memory reserves.

Many of memory allocations which are associated with current thread (e.g.
system calls) can bail out upon SIGKILL because current thread is allowed
to die without completing the request. Many of memory allocations which
are not associated with current thread (e.g. flushing buffered write data
to storage) should not bail out upon SIGKILL because it means loss of data
which is too late to notify the thread which requested the buffered write.
Administrators should be able to choose from "(A) Buffered I/O looses data
upon OOM (possibly with filesystem errors, because the kernel does not
allocate memory used by I/O, by not invoking the OOM killer" and "(B)
Buffered I/O does not loose data upon OOM (no filesystem errors, because
the kernel allocates memory used by I/O, by invoking the OOM killer)".

 From the point of view of the memory allocator callers, majority of the
callers are not willing to use weaker reclaim context. Some of the callers
which are willing to give up use __GFP_NORETRY. Speak of syscall checkers
like my module, I'm not willing to give up by using __GFP_NORETRY, but I'm
willing to give up if current thread received SIGKILL.

Use of __GFP_KILLABLE is similar to use of _killable version of lock
primitives. That is, the caller decides whether it is safe to bail out
upon SIGKILL. I want to use __GFP_KILLABLE which is between __GFP_NORETRY
and __GFP_NOFAIL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
