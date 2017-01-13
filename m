Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC15E6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:00:26 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id v96so59047918ioi.5
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:00:26 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e82si10816322ioi.193.2017.01.13.03.00.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 03:00:25 -0800 (PST)
Subject: Re: [PATCH] mm: Ignore __GFP_NOWARN when reporting stalls
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1484132120-35288-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170111161228.GE16365@dhcp22.suse.cz>
In-Reply-To: <20170111161228.GE16365@dhcp22.suse.cz>
Message-Id: <201701132000.HJB81754.VOQtFMSJOFFHLO@I-love.SAKURA.ne.jp>
Date: Fri, 13 Jan 2017 20:00:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 11-01-17 19:55:20, Tetsuo Handa wrote:
> > Currently, warn_alloc() prints warning messages only if __GFP_NOWARN
> > is not specified. When warn_alloc() was proposed, I asserted that
> > warn_alloc() should print stall warning messages even if __GFP_NOWARN
> > is specified, but that assertion was not accepted [1].
> > 
> > Compared to asynchronous watchdog [2], warn_alloc() for reporting stalls
> > is broken in many aspects. First of all, we can't guarantee forward
> > progress of memory allocation request. It is important to understand that
> > the reason is not limited to the "too small to fail" memory-allocation
> > rule [3]. We need to learn that the caller may fail to call warn_alloc()
> >  from page allocator whereas warn_alloc() assumes that stalling threads
> > can call warn_alloc() from page allocator.
> > 
> > An easily reproducible situation is that kswapd is blocked on other
> > threads doing memory allocations while other threads doing memory
> > allocations are blocked on kswapd [4].
> 
> This all is unrelated to whether we should or shouldn't warn when
> __GFP_NOWARN is specified.
> 
> > But what is silly is that, even
> > if some allocation request was lucky enough to escape from
> > too_many_isolated() loop because it was GFP_NOIO or GFP_NOFS, it fails
> > to print warning messages because it was __GFP_NOWARN when all other
> > allocations were looping inside too_many_isolated() loop (an example [5]
> > is shown below). We are needlessly discarding a chance to know that
> > the system got livelocked.
> 
> But the caller had some reason to not warn. So why should we ignore
> that? The reason this flag is usually added is that the allocation
> failure is tolerable and it shouldn't alarm the admin to do any action.

Majority of __GFP_DIRECT_RECLAIM allocation requests are tolerable with
allocation failure (and they will be willing to give up upon SIGKILL if
they are from syscall) and do not need to alarm the admin to do any action.
If they are not tolerable with allocation failure, they will add __GFP_NOFAIL.

Apart from the reality that they are not tested well because they are
currently protected by the "too small to fail" memory-allocation rule,
they are ready to add __GFP_NOWARN. And current behavior (i.e. !costly
__GFP_DIRECT_RECLAIM allocation requests won't fail unless __GFP_NORETRY
is set or TIF_MEMDIE is set after SIGKILL was delivered) keeps them away
 from adding __GFP_NOFAIL.

> 
> So rather than repeating why you think that warn_alloc is worse than a
> different solution which you are trying to push through you should in
> fact explain why we should handle stall and allocation failure warnings
> differently and how are we going to handle potential future users who
> would like to disable warning for both. Because once you change the
> semantic we will have problems to change it like for other gfp flags.

Oh, thank you very much for positive (or at least neutral) response to
asynchronous watchdog. I don't mean to change the semantic of GFP flags
if we can go with asynchronous watchdog. I'm posting this patch because
there is no progress with asynchronous watchdog.

I'm not sure what "why we should handle stall and allocation failure
warnings differently" means. Which one did you mean?

  (a) "why we should handle stall warning by synchronous watchdog
      (e.g. warn_alloc()) and allocation failure warnings differently"

  (b) "why we should handle stall warning by asynchronous watchdog
      (e.g. kmallocwd) and allocation failure warnings differently"

If you meant (a), it is because allocation livelock is a problem which
current GFP flags semantics cannot handle. We had been considering only
allocation failures. We have never considered allocation livelock which
is observed as allocation stalls. (The allocation livelock after the OOM
killer is invoked was solved by the OOM reaper. But I'm talking about
allocation livelock before the OOM killer is invoked, and I don't think
this problem can be solved within a few years because this problem is
caused by optimistic direct reclaim. Thus, I'm proposing to start from
checking whether this problem is occurring and providing diagnostic
information.)

__GFP_NOWARN considers only about allocation failures. It is legal to set
both __GFP_NOFAIL and __GFP_NOWARN despite __GFP_NOWARN is pointless from
the point of view of allocation failures because __GFP_NOFAIL never fails.
But __GFP_NOWARN is an intruder from the point of view of reporting
allocation livelock (regardless of whether __GFP_NOFAIL is also set).

If you meant (b), it is because synchronous watchdog is not reliable and
cannot provide enough diagnostic information. Since allocation livelock
involves several threads due to dependency, it is important to take a
snapshot of possibly relevant threads. By using asynchronous watchdog,
we can not only take a snapshot but also take more actions for obtaining
diagnostic information (e.g. enabling tracepoints when allocation stalls
are detected).

I'm not sure what "how are we going to handle potential future users who
would like to disable warning for both" means. Which one did you mean?

  (c) "how are we going to handle potential future system administrators
      who would like to disable warning for both allocation failures and
      allocation stalls"

  (d) "how are we going to handle potential future kernel developers
      who would like to disable warning for both allocation failures and
      allocation stalls"

If you meant (c), kmallocwd v6 allows system administrators to disable
stall warnings by setting /proc/sys/kernel/memalloc_task_timeout_secs to 0.

If you meant (d), I don't think we need to worry about it. Current
warn_alloc() implementation for reporting allocation stalls (i.e. report
unless __GFP_NOWARN is set) is already preventing system administrators
and kernel developers from disabling allocation stall warnings. We will be
able to get rid of warn_alloc() for reporting stalls and asynchronous
watchdog when we managed to guarantee forward progress of memory allocation
and prove that allocation livelock is impossible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
