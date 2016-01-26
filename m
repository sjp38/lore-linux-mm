Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 06F496B0009
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 18:44:42 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id x125so1366806pfb.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:44:42 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id tw5si4993812pac.131.2016.01.26.15.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 15:44:41 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id x125so1366675pfb.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:44:41 -0800 (PST)
Date: Tue, 26 Jan 2016 15:44:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
In-Reply-To: <201601222259.GJB90663.MLOJtFFOQFVHSO@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1601261530250.25141@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1601191502230.7346@chino.kir.corp.google.com> <201601202336.BJC04687.FOFVOQJOLSFtMH@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1601201538070.18155@chino.kir.corp.google.com> <201601212044.AFD30275.OSFFOFJHMVLOQt@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1601211513550.9813@chino.kir.corp.google.com> <201601222259.GJB90663.MLOJtFFOQFVHSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 22 Jan 2016, Tetsuo Handa wrote:

> > >   (1) Design and use a system with appropriate memory capacity in mind.
> > > 
> > >   (2) When (1) failed, the OOM killer is invoked. The OOM killer selects
> > >       an OOM victim and allow that victim access to memory reserves by
> > >       setting TIF_MEMDIE to it.
> > > 
> > >   (3) When (2) did not solve the OOM condition, start allowing all tasks
> > >       access to memory reserves by your approach.
> > > 
> > >   (4) When (3) did not solve the OOM condition, start selecting more OOM
> > >       victims by my approach.
> > > 
> > >   (5) When (4) did not solve the OOM condition, trigger the kernel panic.
> > > 
> > 
> > This was all mentioned previously, and I suggested that the panic only 
> > occur when memory reserves have been depleted, otherwise there is still 
> > the potential for the livelock to be solved.  That is a patch that would 
> > apply today, before any of this work, since we never want to loop 
> > endlessly in the page allocator when memory reserves are fully depleted.
> > 
> > This is all really quite simple.
> > 
> 
> So, David is OK with above approach, right?
> Then, Michal and Johannes, are you OK with above approach?
> 

The first step before implementing access to memory reserves on livelock 
(my patch) and oom killing additional processes on livelock (your patch) 
is to detect the appropriate place to panic() when reserves are depleted.

This has historically been done in the oom killer when there are no oom 
killable processes left.  That's easy to figure out and should still be 
done, but we are now introducing the possibility of memory reserves being 
fully depleted while there are oom killable processes left or victims that
cannot exit.

So we need a patch to the page allocator that would be applicable today 
before any of the above is worked on to detect when reserves are depleted 
and panic() rather than loop forever in the page allocator.  I'd suggest 
that this work be done as a follow-up to Michal's patchset to rework the 
page allocator retry logic.

It's not entirely trivial because we want to detect situations when 
high-order < PAGE_ALLOC_COSTLY_ORDER allocations are looping forever and 
we are failing due to fragmentation as well.  If all cpus are looping 
trying to allocate a task_struct, and there are eligible zones with some 
free memory but it is not allocatable, we still want to panic().

> What I'm not sure about above approach are handling of !__GFP_NOFAIL &&
> !__GFP_FS allocation requests and use of ALLOC_NO_WATERMARKS without
> TIF_MEMDIE.
> 
> Basically, we want to make small allocation requests success unless
> __GFP_NORETRY is given. Currently such allocation requests do not fail
> unless TIF_MEMDIE is given by the OOM killer. But how hard do we want to
> continue looping when we reach (3) by timeout for waiting for TIF_MEMDIE
> task at (2) expires?
> 

In my patch, that is tunable by the user with a new sysctl and defines 
when the oom killer is considered livelocked because the victim cannot 
exit.  I think we'd do *did_some_progress = 1 for !__GFP_FS as is done 
today before this expiration happens and otherwise trigger the oom killer 
livelock detection in my patch to allow the allocation to succeed with 
ALLOC_NO_WATERMARKS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
