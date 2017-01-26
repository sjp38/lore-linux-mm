Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C31416B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:29:00 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id a194so268918325oib.5
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:29:00 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l187si488973oih.131.2017.01.26.02.28.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 02:28:59 -0800 (PST)
Subject: Re: [PATCH v6] mm: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170125181150.GA16398@cmpxchg.org>
	<20170125184548.GB32041@dhcp22.suse.cz>
In-Reply-To: <20170125184548.GB32041@dhcp22.suse.cz>
Message-Id: <201701261928.DIG05227.OtOVFHOJMFLSQF@I-love.SAKURA.ne.jp>
Date: Thu, 26 Jan 2017 19:28:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 25-01-17 13:11:50, Johannes Weiner wrote:
> [...]
> > >From 6420cae52cac8167bd5fb19f45feed2d540bc11d Mon Sep 17 00:00:00 2001
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Wed, 25 Jan 2017 12:57:20 -0500
> > Subject: [PATCH] mm: page_alloc: __GFP_NOWARN shouldn't suppress stall
> >  warnings
> > 
> > __GFP_NOWARN, which is usually added to avoid warnings from callsites
> > that expect to fail and have fallbacks, currently also suppresses
> > allocation stall warnings. These trigger when an allocation is stuck
> > inside the allocator for 10 seconds or longer.
> > 
> > But there is no class of allocations that can get legitimately stuck
> > in the allocator for this long. This always indicates a problem.
> > 
> > Always emit stall warnings. Restrict __GFP_NOWARN to alloc failures.
> 
> Tetsuo has already suggested something like this and I didn't really

Yes, I already suggested it at
http://lkml.kernel.org/r/1484132120-35288-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

> like it because it makes the semantic of the flag confusing. The mask
> says to not warn while the kernel log might contain an allocation splat.
> You are right that stalling for 10s seconds means a problem on its own
> but on the other hand I can imagine somebody might really want to have
> clean logs and the last thing we want is to have another gfp flag for
> that purpose.

I agree with Johannes about that __GFP_NOWARN should not suppress allocation
stall warnings. But having another gfp flag for that purpose is not useful.
Given that someone really wants not to have allocation stall warnings in the
kernel logs, where is the switch for enabling/disabling allocation stall
warnings (because gfp flags are constant determined at build time)? We will
need to have either a kernel command line option or a sysctl (or sysfs)
variable. khungtaskd uses sysctl variables for those who really wants not
to have TASK_UNINTERRUPTIBLE warnings; so does kmallocwd.

> 
> I also do not think that this change would make a big difference because
> most allocations simply use this flag along with __GFP_NORETRY or
> GFP_NOWAIT resp GFP_ATOMIC. Have we ever seen a stall with this
> allocation requests?

You are totally ignoring what I explained in the "[PATCH] mm: Ignore
__GFP_NOWARN when reporting stalls" thread shown above.

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
> I haven't nacked Tetsuo's patch AFAIR and will not nack this one either
> I just do not think we should tweak __GFP_NOWARN.

Leaving this proposal as it is is counterproductive. I already said

  The discussion at this stage should not be "whether we need such
  watchdog and debugging code" but should be "how we can make the impact
  of watchdog and debugging code as small as possible".

at http://lkml.kernel.org/r/1462630604-23410-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .
And there had been no response.

Johannes Weiner wrote:
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

warn_alloc() stall info cannot provide overall analyses. I said

  If you meant (b), it is because synchronous watchdog is not reliable and
  cannot provide enough diagnostic information. Since allocation livelock
  involves several threads due to dependency, it is important to take a
  snapshot of possibly relevant threads. By using asynchronous watchdog,
  we can not only take a snapshot but also take more actions for obtaining
  diagnostic information (e.g. enabling tracepoints when allocation stalls
  are detected).

in the same thread shown above. For example, the cause of allocation stall
might be due to out of idle workqueue thread; e.g. commit 373ccbe5927034b5
("mm, vmstat: allow WQ concurrency to discover memory reclaim doesn't make
any progress"). Without reporting all possibly relevant threads, we might
fail to obtain enough diagnostic information. Changing warn_alloc() to
also report workqueues/kswapd/locks etc. will be noisy and incomplete
because warn_alloc() cares only current thread.

I welcome suggestions for "how we can make the impact of watchdog and
debugging code as small as possible". But I don't have environment for
evaluating the task_struct overhead. I wonder whether this overhead matters
because this is allocation slowpath which will consume a lot of CPU cycles
for scanning and/or sleep for many jiffies waiting for I/O. It will be far
cheaper than keeping mm related tracepoints enabled until something happens
which might be uptime of months. Sending the v6 patch to linux-next and
start evaluating the overhead will be the way to avoid leaving this proposal
as it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
