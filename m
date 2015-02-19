Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 13F4F900015
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 06:01:53 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id hi2so47124328wib.4
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 03:01:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s6si17883622wic.33.2015.02.19.03.01.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Feb 2015 03:01:49 -0800 (PST)
Date: Thu, 19 Feb 2015 06:01:24 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150219110124.GC15569@phnom.home.cmpxchg.org>
References: <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150218082502.GA4478@dhcp22.suse.cz>
 <20150218104859.GM12722@dastard>
 <20150218121602.GC4478@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150218121602.GC4478@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Wed, Feb 18, 2015 at 01:16:02PM +0100, Michal Hocko wrote:
> On Wed 18-02-15 21:48:59, Dave Chinner wrote:
> > On Wed, Feb 18, 2015 at 09:25:02AM +0100, Michal Hocko wrote:
> > > On Wed 18-02-15 09:54:30, Dave Chinner wrote:
> [...]
> > Also, this reads as an excuse for the OOM killer being broken and
> > not fixing it.  Keep in mind that we tell the memory alloc/reclaim
> > subsystem that *we hold locks* when we call into it. That's what
> > GFP_NOFS originally meant, and it's what it still means today in an
> > XFS context.
> 
> Sure, and OOM killer will not be invoked in NOFS context. See
> __alloc_pages_may_oom and __GFP_FS check in there. So I do not see where
> is the OOM killer broken.
> 
> The crucial problem we are dealing with is not GFP_NOFAIL triggering the
> OOM killer but a lock dependency introduced by the following sequence:
> 
> 	taskA			taskB			taskC
> lock(A)							alloc()
> alloc(gfp | __GFP_NOFAIL)	lock(A)			  out_of_memory
> # looping for ever if we				    select_bad_process
> # cannot make any progress				      victim = taskB

You don't even need taskC here.  taskA could invoke the OOM killer
with lock(A) held, and taskB getting selected as the victim while
trying to acquire lock(A).  It'll get the signal and TIF_MEMDIE and
then wait for lock(A) while taskA is waiting for it to exit.

But it doesn't matter who is doing the OOM killing - if the allocating
task with the lock/state is waiting for the OOM victim to free memory,
and the victim is waiting for same the lock/state, we have a deadlock.

> There is no way OOM killer can tell taskB is blocked and that there is
> dependency between A and B (without lockdep). That is why I call NOFAIL
> under a lock as dangerous and a bug.

You keep ignoring that it's also one of the main usecases of this
flag.  The caller has state that it can't unwind and thus needs the
allocation to succeed.  Chances are somebody else can get blocked up
on that same state.  And when that somebody else is the first choice
of the OOM killer, we're screwed.

This is exactly why I'm proposing that the OOM killer should not wait
indefinitely for its first choice to exit, but ultimately move on and
try other tasks.  There is no other way to resolve this deadlock.

Preferrably, we'd get rid of all nofail allocations and replace them
with preallocated reserves.  But this is not going to happen anytime
soon, so what other option do we have than resolving this on the OOM
killer side?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
