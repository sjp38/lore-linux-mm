Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id BBF626B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 06:44:48 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id yo10so7459268obb.2
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 03:44:48 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j125si804930oia.118.2016.01.21.03.44.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jan 2016 03:44:47 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1601141500370.22665@chino.kir.corp.google.com>
	<201601151936.IJJ09362.OOFLtVFJHSFQMO@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1601191502230.7346@chino.kir.corp.google.com>
	<201601202336.BJC04687.FOFVOQJOLSFtMH@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1601201538070.18155@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1601201538070.18155@chino.kir.corp.google.com>
Message-Id: <201601212044.AFD30275.OSFFOFJHMVLOQt@I-love.SAKURA.ne.jp>
Date: Thu, 21 Jan 2016 20:44:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> On Wed, 20 Jan 2016, Tetsuo Handa wrote:
> 
> > > > My goal is to ask the OOM killer not to toss the OOM killer's duty away.
> > > > What is important for me is that the OOM killer takes next action when
> > > > current action did not solve the OOM situation.
> > > > 
> > > 
> > > What is the "next action" when there are no more processes on your system, 
> > 
> > Just call panic(), as with select_bad_process() from out_of_memory() returned
> > NULL.
> > 
> 
> No way is that a possible solution for a system-wide oom condition.  We 
> could have megabytes of memory available in memory reserves and a simple 
> allocation succeeding could fix the livelock quite easily (and can be 
> demonstrated with my testcase).  A panic is never better than allowing an 
> allocation to succeed through the use of available memory reserves.
> 

While it seems to me that you are really interested in memcg OOM events,
I'm interested in only system-wide OOM events. I'm not using memcg and my
patches are targeted for handling system-wide OOM events.

I consider phases for managing system-wide OOM events as follows.

  (1) Design and use a system with appropriate memory capacity in mind.

  (2) When (1) failed, the OOM killer is invoked. The OOM killer selects
      an OOM victim and allow that victim access to memory reserves by
      setting TIF_MEMDIE to it.

  (3) When (2) did not solve the OOM condition, start allowing all tasks
      access to memory reserves by your approach.

  (4) When (3) did not solve the OOM condition, start selecting more OOM
      victims by my approach.

  (5) When (4) did not solve the OOM condition, trigger the kernel panic.

By introducing the OOM reaper, possibility of solving the OOM condition at
(2) will be increased if the OOM reaper can reap the OOM victim's memory.
But when the OOM reaper did not help, it's time to fall back to (3).

Your approach will open the memory reserves. Therefore, when the memory
reserve depletes, it's time to fall back to (4).

My approach will choose next OOM victim, let the system return from (4) to
(2), allow the OOM reaper to reap the next OOM victim's memory. Therefore,
when there is no more OOM-killable processes, it's time to fall back to (5).

I agree that we might have megabytes of memory available in memory reserves
and a simple allocation succeeding might solve the OOM condition. I posted a
patch ( http://lkml.kernel.org/r/201509102318.GHG18789.OHMSLFJOQFOtFV@I-love.SAKURA.ne.jp )
for that reason.

But when the system arrived at (5), there will be no memory available in
memory reserves, for the condition for falling back to (5) includes (3).
Thus, triggering kernel panic should be OK.

> For the memcg case, we wouldn't panic() when there are no more killable 
> processes, and this livelock problem can easily be exhibited in memcg 
> hierarchy oom conditions as well (and quite easier since it's in 
> isolation and doesn't get interferred with by external process freeing 
> elsewhere on the system).  So, again, your approach offers no solution to 
> this case and you presumably suggest that we should leave the hierarchy 
> livelocked forever.  Again, not a possible solution.
> 

I don't know how to trigger memcg OOM livelock problem after killing all (i.e.
both OOM-killable and OOM-unkillable) tasks in a memcg. If only OOM-unkillable
tasks remained in that memcg after killing all OOM-killable tasks in that memcg,
it's time for administrator to manually send SIGKILL or loosen the quota of that
memcg. Unless the administrator encounters system-wide OOM event when trying to
manually send SIGKILL or loosen the quota, I don't think it is a problem.

Just leave that memcg hierarchy livelocked forever for now. I'm talking about
managing system-wide OOM events now.

> > If we can agree on combining both approaches, I'm OK with it. That will keep
> > the OOM reaper simple, for the OOM reaper will not need to clear TIF_MEMDIE
> > flag which is unfriendly for wait_event() in oom_killer_disable(), and the
> > OOM reaper will not need to care about situations where TIF_MEMDIE flag is
> > set when it is not safe to reap.
> > 
> 
> Please, allow us to review and get the oom reaper merged first and then 
> evaluate the problem afterwards.
> 

Best is we don't need to invoke the OOM killer. Next best is the OOM killer
solves the OOM condition. Next best is the OOM reaper solves the OOM condition.
Worst is we need to trigger the kernel panic. Next worst is we need to kill
all processes. Next worst is the OOM killer needs to kill all OOM-killable
processes.

We are currently violating Linux users' expectations that "the OOM killer
kills the OOM condition". I don't want to violate them again by advertising
the OOM reaper as "a reliable last resort for killing the OOM condition".

Why don't we start from establishing an evacuation route to the worst case
(i.e. make sure that the OOM killer chooses a !TIF_MEMDIE process) before
we make the kernel more difficult to test worse cases?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
