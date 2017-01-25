Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 68E806B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:44:41 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so34635983pgj.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:44:41 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id v7si3041830plk.21.2017.01.25.15.44.40
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 15:44:40 -0800 (PST)
Date: Thu, 26 Jan 2017 08:44:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6] mm: Add memory allocation watchdog kernel thread.
Message-ID: <20170125234438.GA20953@bbox>
References: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170125181150.GA16398@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20170125181150.GA16398@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 25, 2017 at 01:11:50PM -0500, Johannes Weiner wrote:
> On Sun, Nov 06, 2016 at 04:15:01PM +0900, Tetsuo Handa wrote:
> > +- Why need to use it?
> > +
> > +Currently, when something went wrong inside memory allocation request,
> > +the system might stall without any kernel messages.
> > +
> > +Although there is khungtaskd kernel thread as an asynchronous monitoring
> > +approach, khungtaskd kernel thread is not always helpful because memory
> > +allocating tasks unlikely sleep in uninterruptible state for
> > +/proc/sys/kernel/hung_task_timeout_secs seconds.
> > +
> > +Although there is warn_alloc() as a synchronous monitoring approach
> > +which emits
> > +
> > +  "%s: page allocation stalls for %ums, order:%u, mode:%#x(%pGg)\n"
> > +
> > +line, warn_alloc() is not bullet proof because allocating tasks can get
> > +stuck before calling warn_alloc() and/or allocating tasks are using
> > +__GFP_NOWARN flag and/or such lines are suppressed by ratelimiting and/or
> > +such lines are corrupted due to collisions.
> 
> I'm not fully convinced by this explanation. Do you have a real life
> example where the warn_alloc() stall info is not enough? If yes, this
> should be included here and in the changelog. If not, the extra code,
> the task_struct overhead etc. don't seem justified.
> 
> __GFP_NOWARN shouldn't suppress stall warnings, IMO. It's for whether
> the caller expects allocation failure and is prepared to handle it; an
> allocation stalling out for 10s is an issue regardless of the callsite.
> 
> ---
> 
> From 6420cae52cac8167bd5fb19f45feed2d540bc11d Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Wed, 25 Jan 2017 12:57:20 -0500
> Subject: [PATCH] mm: page_alloc: __GFP_NOWARN shouldn't suppress stall
>  warnings
> 
> __GFP_NOWARN, which is usually added to avoid warnings from callsites
> that expect to fail and have fallbacks, currently also suppresses
> allocation stall warnings. These trigger when an allocation is stuck
> inside the allocator for 10 seconds or longer.
> 
> But there is no class of allocations that can get legitimately stuck
> in the allocator for this long. This always indicates a problem.
> 
> Always emit stall warnings. Restrict __GFP_NOWARN to alloc failures.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
