Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB686B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 05:39:37 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f73so343429046ioe.1
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 02:39:37 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u188si14852438itd.92.2016.12.27.02.39.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Dec 2016 02:39:36 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
	<201612222233.CBC56295.LFOtMOVQSJOFHF@I-love.SAKURA.ne.jp>
	<20161222192406.GB19898@dhcp22.suse.cz>
	<201612241525.EDB52697.OQSFOLJFFOHVMt@I-love.SAKURA.ne.jp>
	<20161226114935.GB16042@dhcp22.suse.cz>
In-Reply-To: <20161226114935.GB16042@dhcp22.suse.cz>
Message-Id: <201612271939.FFF56780.tOFQOHJSVLMOFF@I-love.SAKURA.ne.jp>
Date: Tue, 27 Dec 2016 19:39:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, pmladek@suse.cz

Michal Hocko wrote:
> On Sat 24-12-16 15:25:43, Tetsuo Handa wrote:
> [...]
> > Michal Hocko wrote:
> > > On Thu 22-12-16 22:33:40, Tetsuo Handa wrote:
> > > > Tetsuo Handa wrote:
> > > > > Now, what options are left other than replacing !mutex_trylock(&oom_lock)
> > > > > with mutex_lock_killable(&oom_lock) which also stops wasting CPU time?
> > > > > Are we waiting for offloading sending to consoles?
> > > > 
> > > >  From http://lkml.kernel.org/r/20161222115057.GH6048@dhcp22.suse.cz :
> > > > > > Although I don't know whether we agree with mutex_lock_killable(&oom_lock)
> > > > > > change, I think this patch alone can go as a cleanup.
> > > > > 
> > > > > No, we don't agree on that part. As this is a printk issue I do not want
> > > > > to workaround it in the oom related code. That is just ridiculous. The
> > > > > very same issue would be possible due to other continous source of log
> > > > > messages.
> > > > 
> > > > I don't think so. Lockup caused by printk() is printk's problem. But printk
> > > > is not the only source of lockup. If CONFIG_PREEMPT=y, it is possible that
> > > > a thread which held oom_lock can sleep for unbounded period depending on
> > > > scheduling priority.
> > > 
> > > Unless there is some runaway realtime process then the holder of the oom
> > > lock shouldn't be preempted for the _unbounded_ amount of time. It might
> > > take quite some time, though. But that is not reduced to the OOM killer.
> > > Any important part of the system (IO flushers and what not) would suffer
> > > from the same issue.
> > 
> > I fail to understand why you assume "realtime process".
> 
> Because then a standard process should get its time slice eventually. It
> can take some time, especially with many cpu hogs....

An "idle process" failed to get its time slice for more than 20 minutes when
we wanted it to sleep for only 1 millisecond. Too long to call it "eventually"
in the real life.

> 
> > This lockup is still triggerable using "normal process" and "idle process".
> 
> if you have too many of them then you are just out of luck and
> everything will take ages.

If "normal processes" were waiting for oom_lock (or wait longer incrementally),
"idle process" would have been able to wake up immediately.

> 
> [...]
> 
> > See? The runaway is occurring inside kernel space due to almost-busy looping
> > direct reclaim against a thread with idle priority with oom_lock held.
> > 
> > My assertion is that we need to make sure that the OOM killer/reaper are given
> > enough CPU time so that they can perform memory reclaim operation and release
> > oom_lock. We can't solve CPU time consumption by sleep-with-oom_lock1.c case
> > but we can solve CPU time consumption by sleep-with-oom_lock2.c case.
> 
> What I am trying to tell you is that it is really hard to do something
> about these situations in general. It is not all that hard to construct
> workloads which will constantly preempt the sync oom path and we can do
> hardly anything about that. OOM handling is quite complex and takes
> considerable amount of time as long as we want to have some
> deterministic behavior (unless that deterministic thing is to
> immediately reboot which is not something everybody would like to see).
> 
> > I think it is waste of CPU time to let all threads try direct reclaim
> > which also bothers them with consistent __GFP_NOFS/__GFP_NOIO usage which
> > might involve dependency to other threads. But changing it is not easy.
> 
> Exactly.
> 
> > Thus, I'm proposing to save CPU time if waiting for the OOM killer/reaper
> > when direct reclaim did not help.
> 
> Which will just move problem somewhere else I am afraid. Now you will
> have hundreds of tasks bouncing on the global mutex. That never turned
> out to be a good thing in the past and I am worried that it will just
> bite us from a different side. What is worse it might hit us in cases
> which do actually happen in the real life.
> 
> I am not saying that the current code works perfectly when we are
> hitting the direct reclaim close to the OOM but improving that requires
> much more than slapping a global lock there.

So, we finally agreed that there are problems when we are hitting the direct
reclaim close to the OOM. Good.

>  
> > > > Then, you call such latency as scheduler's problem?
> > > > mutex_lock_killable(&oom_lock) change helps coping with whatever delays
> > > > OOM killer/reaper might encounter.
> > > 
> > > It helps _your_ particular insane workload. I believe you can construct
> > > many others which which would cause a similar problem and the above
> > > suggestion wouldn't help a bit. Until I can see this is easily
> > > triggerable on a reasonably configured system then I am not convinced
> > > we should add more non trivial changes to the oom killer path.
> > 
> > I'm not using root privileges nor realtime priority nor CONFIG_PREEMPT=y.
> > Why you don't care about the worst situation / corner cases?
> 
> I do care about them! I just do not want to put random hacks which might
> seem to work on this _particular_ workload while it brings risks for
> others. Look, those corner cases you are simulating are _interesting_ to
> see how robust we are but they are no way close to what really happens
> in the real life out there - we call those situations DoS from any
> practical POV. Admins usually do everything to prevent from them by
> configuring their systems and limiting untrusted users as much as
> possible.

I wonder why you introduce "untrusted users" concept. From my experience,
there was no "untrusted users". All users who use their systems are trusted
and innocent, but they _by chance_ hit problems when close to (or already)
the OOM.

> 
> So please try to step back, try to understand that there is a difference
> between interesting and matters_in_the_real_life and do not try to
> _design_ the code on _corner cases_ because that might be more harmful
> then useful.
> 

The reason I continue testing corner cases is that you don't accept catch-all
reporting mechanism. Therefore, I test more harder and harder so that we can
live without catch-all reporting mechanism. But you also say making changes
for handling corner case is bad. Then, I get annoying dilemma.

Based on many reproducers I showed you, problems are categorized to
4 patterns shown below.

  (1) You are aware of bugs, you think they are problems, but you don't
      have solutions.

  (2) You are aware of bugs, you know we can hit these bugs, but you don't
      think they are problems.

  (3) You are aware of bugs, but you don't think we can hit these bugs.

  (4) You are not aware of bugs.

And asynchronous watchdog can catch all patterns which will occur in
the real life. Asynchronous watchdog is far safer than putting random
hacks into allocator path.

My suggestion is that let's allow the kernel to report problems honestly
that something might went wrong with "Somebody else will make progress for
me" approach. I tolerate your "Somebody else will make progress for me"
approach as long as we allow the kernel to report problems honestly.

> Just try to remember how you were pushing really hard for oom timeouts
> one year back because the OOM killer was suboptimal and could lockup. It
> took some redesign and many changes to fix that. The result is
> imho a better, more predictable and robust code which wouldn't be the
> case if we just went your way to have a fix quickly...

I agree that the result is good for users who can update kernels. But that
change was too large to backport. Any approach which did not in time for
customers' deadline of deciding their kernels to use for 10 years is
useless for them. Lack of catch-all reporting/triggering mechanism is
unhappy for both customers and troubleshooting staffs at support centers.

Improving the direct reclaim close to the OOM requires a lot of effort.
We might add new bugs during that effort. So, where is valid reason that
we can not have asynchronous watchdog like kmallocwd? Please do explain
at kmallocwd thread. You have never persuaded me about keeping kmallocwd
out of tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
