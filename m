Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 569016B0260
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 04:06:18 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id yr2so4114281wjc.4
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 01:06:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x74si5064204wmd.166.2017.01.14.01.06.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 01:06:16 -0800 (PST)
Date: Sat, 14 Jan 2017 10:06:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Ignore __GFP_NOWARN when reporting stalls
Message-ID: <20170114090613.GD9962@dhcp22.suse.cz>
References: <1484132120-35288-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170111161228.GE16365@dhcp22.suse.cz>
 <201701132000.HJB81754.VOQtFMSJOFFHLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701132000.HJB81754.VOQtFMSJOFFHLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-01-17 20:00:11, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 11-01-17 19:55:20, Tetsuo Handa wrote:
> > > Currently, warn_alloc() prints warning messages only if __GFP_NOWARN
> > > is not specified. When warn_alloc() was proposed, I asserted that
> > > warn_alloc() should print stall warning messages even if __GFP_NOWARN
> > > is specified, but that assertion was not accepted [1].
> > > 
> > > Compared to asynchronous watchdog [2], warn_alloc() for reporting stalls
> > > is broken in many aspects. First of all, we can't guarantee forward
> > > progress of memory allocation request. It is important to understand that
> > > the reason is not limited to the "too small to fail" memory-allocation
> > > rule [3]. We need to learn that the caller may fail to call warn_alloc()
> > >  from page allocator whereas warn_alloc() assumes that stalling threads
> > > can call warn_alloc() from page allocator.
> > > 
> > > An easily reproducible situation is that kswapd is blocked on other
> > > threads doing memory allocations while other threads doing memory
> > > allocations are blocked on kswapd [4].
> > 
> > This all is unrelated to whether we should or shouldn't warn when
> > __GFP_NOWARN is specified.
> > 
> > > But what is silly is that, even
> > > if some allocation request was lucky enough to escape from
> > > too_many_isolated() loop because it was GFP_NOIO or GFP_NOFS, it fails
> > > to print warning messages because it was __GFP_NOWARN when all other
> > > allocations were looping inside too_many_isolated() loop (an example [5]
> > > is shown below). We are needlessly discarding a chance to know that
> > > the system got livelocked.
> > 
> > But the caller had some reason to not warn. So why should we ignore
> > that? The reason this flag is usually added is that the allocation
> > failure is tolerable and it shouldn't alarm the admin to do any action.
> 
> Majority of __GFP_DIRECT_RECLAIM allocation requests are tolerable with
> allocation failure (and they will be willing to give up upon SIGKILL if
> they are from syscall) and do not need to alarm the admin to do any action.
> If they are not tolerable with allocation failure, they will add __GFP_NOFAIL.
> 
> Apart from the reality that they are not tested well because they are
> currently protected by the "too small to fail" memory-allocation rule,
> they are ready to add __GFP_NOWARN. And current behavior (i.e. !costly
> __GFP_DIRECT_RECLAIM allocation requests won't fail unless __GFP_NORETRY
> is set or TIF_MEMDIE is set after SIGKILL was delivered) keeps them away
>  from adding __GFP_NOFAIL.
> 
> > 
> > So rather than repeating why you think that warn_alloc is worse than a
> > different solution which you are trying to push through you should in
> > fact explain why we should handle stall and allocation failure warnings
> > differently and how are we going to handle potential future users who
> > would like to disable warning for both. Because once you change the
> > semantic we will have problems to change it like for other gfp flags.
> 
> Oh, thank you very much for positive (or at least neutral) response to
> asynchronous watchdog. I don't mean to change the semantic of GFP flags
> if we can go with asynchronous watchdog. I'm posting this patch because
> there is no progress with asynchronous watchdog.
> 
> I'm not sure what "why we should handle stall and allocation failure
> warnings differently" means. Which one did you mean?
> 
>   (a) "why we should handle stall warning by synchronous watchdog
>       (e.g. warn_alloc()) and allocation failure warnings differently"
> 
>   (b) "why we should handle stall warning by asynchronous watchdog
>       (e.g. kmallocwd) and allocation failure warnings differently"
> 
> If you meant (a), it is because allocation livelock is a problem which
> current GFP flags semantics cannot handle. We had been considering only
> allocation failures. We have never considered allocation livelock which
> is observed as allocation stalls. (The allocation livelock after the OOM
> killer is invoked was solved by the OOM reaper. But I'm talking about
> allocation livelock before the OOM killer is invoked,

I am not going to allow defining a weird __GFP_NOWARN semantic which
allows warnings but only sometimes. At least not without having a proper
way to silence both failures _and_ stalls or just stalls. I do not
really thing this is worth the additional gfp flag.

> and I don't think
> this problem can be solved within a few years because this problem is
> caused by optimistic direct reclaim.

And again your are trying to define a weird semantic just because the
original problem seems too hard. This is a really wrong way to do
the development. And again the oom repear should serve you as an example
that things can be done _properly_ rather than tweaked around with
"sometimes works but not always" solutions.

I plan to address the too_many_isolated problem. In fact I already have
some preliminary work done which I plan to post next week. An unbound
loop inside the reclaim is certainly something to get rid of and AFAIK
this is the only problem which can prevent reasonable return to the page
allocator.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
