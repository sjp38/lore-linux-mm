Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3824C828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 05:36:20 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id n128so115944548pfn.3
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 02:36:20 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v13si15732291pas.108.2016.01.15.02.36.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jan 2016 02:36:19 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160113180147.GL17512@dhcp22.suse.cz>
	<201601142026.BHI87005.FSOFJVFQMtHOOL@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1601141400170.16227@chino.kir.corp.google.com>
	<20160114225850.GA23382@cmpxchg.org>
	<alpine.DEB.2.10.1601141500370.22665@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1601141500370.22665@chino.kir.corp.google.com>
Message-Id: <201601151936.IJJ09362.OOFLtVFJHSFQMO@I-love.SAKURA.ne.jp>
Date: Fri, 15 Jan 2016 19:36:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, hannes@cmpxchg.org
Cc: mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> On Thu, 14 Jan 2016, Tetsuo Handa wrote:
>
> > I know. What I'm proposing is try to recover by killing more OOM-killable
> > tasks because I think impact of crashing the kernel is larger than impact
> > of killing all OOM-killable tasks. We should at least try OOM-kill all
> > OOM-killable processes before crashing the kernel. Some servers take many
> > minutes to reboot whereas restarting OOM-killed services takes only a few
> > seconds. Also, SysRq-i is inconvenient because it kills OOM-unkillable ssh
> > daemon process.
> >
>
> This is where me and you disagree; the goal should not be to continue to
> oom kill more and more processes since there is no guarantee that further
> kills will result in forward progress.

Leaving a system OOM-livelocked forever is very very annoying thing.
My goal is to ask the OOM killer not to toss the OOM killer's duty away.
What is important for me is that the OOM killer takes next action when
current action did not solve the OOM situation.

For me, when and whether to allow global access to memory reserves is not
critical, for that is nothing but one of actions administrators might want
the OOM killer to take.

>                                         These additional kills can result
> in the same livelock that is already problematic, and killing additional
> processes has made the situation worse since memory reserves are more
> depleted.

Why are you still assuming that memory reserves are more depleted if we kill
additional processes? We are introducing the OOM reaper which can compensate
memory reserves if we kill additional processes. We can make the OOM reaper
update oom priority of all processes that use a mm the OOM killer chose
( http://lkml.kernel.org/r/201601131915.BCI35488.FHSFQtVMJOOOLF@I-love.SAKURA.ne.jp )
so that we can help the OOM reaper compensate memory reserves by helping
the OOM killer to select a different mm.

Current rule for allowing access to memory reserves is "Pick and Pray" (like
"Plug and Pray"), for only TIF_MEMDIE threads can access all of memory reserves
whereas !TIF_MEMDIE SIGKILL threads can access none of memory reserves.
The OOM killer picks up the first thread from all threads which use a mm
the OOM killer chose, without taking into account that which thread is doing
a __GFP_FS || __GFP_NOFAIL allocation request, with an assumption that
!TIF_MEMDIE SIGKILL tasks can access all of memory reserves even if they are
doing a !__GFP_FS && !__GFP_NOFAIL allocation request. If we want SIGKILL tasks
to access all of memory reserves, we would need below change.

----------
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2744,7 +2744,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
 		/* The OOM killer does not compensate for IO-less reclaim */
-		if (!(gfp_mask & __GFP_FS)) {
+		if (!(gfp_mask & __GFP_FS) && !fatal_signal_pending(current)) {
 			/*
 			 * XXX: Page reclaim didn't yield anything,
 			 * and the OOM killer can't be invoked, but
----------

But from my examination results, in most cases we don't need to allow
TIF_MEMDIE tasks to access all of memory reserves. They are likely able to
satisfy their memory allocation requests using watermarks for GFP_ATOMIC
allocations. There are cases where evenly treating all SIGKILL tasks can
solve the OOM condition without allowing access to all of memory reserves.

----------
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2955,10 +2955,10 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
-		else if (!in_interrupt() &&
-				((current->flags & PF_MEMALLOC) ||
-				 unlikely(test_thread_flag(TIF_MEMDIE))))
+		else if (!in_interrupt() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (fatal_signal_pending(current))
+			alloc_flags |= ALLOC_HARDER | ALLOC_HIGH;
 	}
 #ifdef CONFIG_CMA
 	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
----------

>
> I believe what is better is to exhaust reclaim, check if the page
> allocator is constantly looping due to waiting for the same victim to
> exit, and then allowing that allocation with memory reserves, see the
> attached patch which I have proposed before.
>
> The livelock often occurs when a single thread is holding a kernel mutex
> and is allocating memory and the oom victim requires that mutex to exit.
> This approach allows that holder to allocate and (hopefully) eventually
> drop the mutex.

That "hopefully" is bad. It causes losing all the work by leaving the system
OOM-livelocked forever when that "hopefully" did not help.

>                  It doesn't require that we randomly oom kill processes
> that don't requrie the mutex, which the oom killer can't know, and it also
> avoids losing the most amount of work.  Oom killing many threads is never
> a solution to anything since reserves are a finite resource.

Are you aware of the OOM reaper?

>
> I know you'll object to this and propose some theory or usecase that shows
> a mutex holder can allocate a ton of memory while holding that mutex and
> memory reserves get depleted.  If you can show such a case in the kernel
> where that happens, we can fix that.  However, the patch also allows for
> identifying such processes by showing their stack trace so these issues
> can be fixed.

I already tried your patch but "global access to memory reserves ended" message
was not always printed
( http://lkml.kernel.org/r/201509221433.ICI00012.VFOQMFHLFJtSOO@I-love.SAKURA.ne.jp ).
What I don't like is that your patch gives up when your patch failed to
solve the OOM situation.

Your patch might be good for kernel developers who want to identify what
the cause is, but is bad for administrators who want to give priority to
not leaving a system OOM-livelocked forever.

>
> Remember, we can never recover 100% of the time, and arguing that this is
> not a perfect solution is not going to help us make forward progress in
> this discussion.

I know. What I'm trying to do is to let the OOM killer take next action
when current action did not solve the OOM situation. I don't object your
patch if a mechanism that guarantees that the OOM killer takes next action
when current action did not solve the OOM situation is implemented. The
simplest way is to re-enable the OOM killer and choose more OOM victims,
thanks to introducing the OOM reaper.



David Rientjes wrote:
> On Thu, 14 Jan 2016, Johannes Weiner wrote:
>
> > > This is where me and you disagree; the goal should not be to continue to
> > > oom kill more and more processes since there is no guarantee that further
> > > kills will result in forward progress.  These additional kills can result
> > > in the same livelock that is already problematic, and killing additional
> > > processes has made the situation worse since memory reserves are more
> > > depleted.
> > >
> > > I believe what is better is to exhaust reclaim, check if the page
> > > allocator is constantly looping due to waiting for the same victim to
> > > exit, and then allowing that allocation with memory reserves, see the
> > > attached patch which I have proposed before.
> >
> > If giving the reserves to another OOM victim is bad, how is giving
> > them to the *allocating* task supposed to be better?
>
> Unfortunately, due to rss and oom priority, it is possible to repeatedly
> select processes which are all waiting for the same mutex.  This is
> possible when loading shards, for example, and all processes have the same
> oom priority and are livelocked on i_mutex which is the most common
> occurrence in our environments.  The livelock came about because we
> selected a process that could not make forward progress, there is no
> guarantee that we will not continue to select such processes.

RSS and oom_score_adj can affect the OOM killer regarding which process is
selected. But I wonder how RSS and oom_score_adj can affect the OOM killer
regarding select processes which are all waiting for the same mutex.

>
> Giving access to the memory allocator eventually allows all allocators to
> successfully allocate, giving the holder of i_mutex the ability to
> eventually drop it.  This happens in a very rate-limited manner depending
> on how you define when the page allocator has looped enough waiting for
> the same process to exit in my patch.

Not always true. See serial-20150922-1.txt.xz and serial-20150922-2.txt.xz
in the link above. The "global access to memory reserves ended" message was
not always printed.

>
> In the past, we have even increased the scheduling priority of oom killed
> processes so that they have a greater likelihood of picking up i_mutex and
> exiting.

That was also "Pick and Pray", an optimistic bet without thinking about the
worst case.

>
> > We need to make the OOM killer conclude in a fixed amount of time, no
> > matter what happens. If the system is irrecoverably deadlocked on
> > memory it needs to panic (and reboot) so we can get on with it. And
> > it's silly to panic while there are still killable tasks available.
> >

I agree with Johannes. Leaving the system OOM-livelocked forever
(even if we allowed global access to memory reserves) is bad.

>
> What is the solution when there are no additional processes that may be
> killed?  It is better to give access to memory reserves so a single
> stalling allocation can succeed so the livelock can be resolved rather
> than panicking.

How can your patch become a solution when memory reserves are depleted
due to your patch? I'm proposing this "re-enable the OOM killer" patch
in case the OOM reaper failed to reclaim memory enough to terminate the
first OOM victim. Since your patch does not choose the second OOM victim,
the OOM reaper cannot compensate memory reserves by choosing the second
OOM victim which is not using a mm used by the first OOM victim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
