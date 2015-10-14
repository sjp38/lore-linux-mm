Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 351DC6B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 08:21:37 -0400 (EDT)
Received: by iofl186 with SMTP id l186so52967370iof.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 05:21:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i10si6904777ioo.115.2015.10.14.05.21.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Oct 2015 05:21:36 -0700 (PDT)
Subject: Re: Silent hang up caused by pages being not scanned?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
	<201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
	<CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com>
	<201510132121.GDE13044.FOSHLJOMFOtQVF@I-love.SAKURA.ne.jp>
	<CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com>
In-Reply-To: <CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com>
Message-Id: <201510142121.IDE86954.SOVOFFQOFMJHtL@I-love.SAKURA.ne.jp>
Date: Wed, 14 Oct 2015 21:21:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: mhocko@kernel.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Linus Torvalds wrote:
> On Tue, Oct 13, 2015 at 5:21 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >
> > If I remove
> >
> >         /* Any of the zones still reclaimable?  Don't OOM. */
> >         if (zones_reclaimable)
> >                 return 1;
> >
> > the OOM killer is invoked even when there are so much memory which can be
> > reclaimed after written to disk. This is definitely premature invocation of
> > the OOM killer.
> 
> Right. The rest of the code knows that the return value right now
> means "there is no memory at all" rather than "I made progress".
> 
> > Yes. But we can't simply do
> >
> >         if (order <= PAGE_ALLOC_COSTLY_ORDER || ..
> >
> > because we won't be able to call out_of_memory(), can we?
> 
> So I think that whole thing is kind of senseless. Not just that
> particular conditional, but what it *does* too.
> 
> What can easily happen is that we are a blocking allocation, but
> because we're __GFP_FS or something, the code doesn't actually start
> writing anything out. Nor is anything congested. So the thing just
> loops.

congestion_wait() sounds like a source of silent hang up.
http://lkml.kernel.org/r/201406052145.CIB35534.OQLVMSJFOHtFOF@I-love.SAKURA.ne.jp

> 
> And looping is stupid, because we may be not able to actually free
> anything exactly because of limitations like __GFP_FS.
> 
> So
> 
>  (a) the looping condition is senseless
> 
>  (b) what we do when looping is senseless
> 
> and we actually do try to wake up kswapd in the loop, but we never
> *wait* for it, so that's largely pointless too.

Aren't we waiting for kswapd forever?
In other words, we never check whether kswapd can make some progress.
http://lkml.kernel.org/r/20150812091104.GA14940@dhcp22.suse.cz

> 
> So *of*course* the direct reclaim code has to set "I made progress",
> because if it doesn't lie and say so, then the code will randomly not
> loop, and will oom, and things go to hell.
> 
> But I hate the "let's tweak the zone_reclaimable" idea, because it
> doesn't actually fix anything. It just perpetuates this "the code
> doesn't make sense, so let's add *more* senseless heusristics to this
> whole loop".

I also don't think that tweaking current reclaim logic solves bugs
which bothered me via unexplained hangups / reboots.
To me, current memory allocator is too puzzling that it is as if

   if (there_is_much_free_memory() == TRUE)
       goto OK;
   if (do_some_heuristic1() == SUCCESS)
       goto OK;
   if (do_some_heuristic2() == SUCCESS)
       goto OK;
   if (do_some_heuristic3() == SUCCESS)
       goto OK;
   (...snipped...)
   if (do_some_heuristicN() == SUCCESS)
       goto OK;
   while (1);

and we don't know how many heuristics we need to add in order to avoid
reaching the "while (1);". (We are reaching the "while (1);" before

   if (out_of_memory() == SUCCESS)
       goto OK;

is called.)

> 
> So instead of that senseless thing, how about trying something
> *sensible*. Make the code do something that we can actually explain as
> making sense.
> 
> I'd suggest something like:
> 
>  - add a "retry count"
> 
>  - if direct reclaim made no progress, or made less progress than the target:
> 
>       if (order > PAGE_ALLOC_COSTLY_ORDER) goto noretry;

Yes.

> 
>  - regardless of whether we made progress or not:
> 
>       if (retry count < X) goto retry;
> 
>       if (retry count < 2*X) yield/sleep 10ms/wait-for-kswapd and then
> goto retry

I tried sleeping for reducing CPU usage and reporting via SysRq-w.
http://lkml.kernel.org/r/201411231353.BDE90173.FQOMJtHOLVFOFS@I-love.SAKURA.ne.jp

I complained at http://lkml.kernel.org/r/201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp

| Oh, why every thread trying to allocate memory has to repeat
| the loop that might defer somebody who can make progress if CPU time was
| given? I wish only somebody like kswapd repeats the loop on behalf of all
| threads waiting at memory allocation slowpath...

Direct reclaim can defer termination upon SIGKILL if blocked at unkillable
lock. If performance were not a problem, is direct reclaim mandatory?

Of course, performance is the problem. Thus we would try direct reclaim
for at least once. But I wish memory allocation logic were as simple as

  (1) If there are enough free memory, allocate it.

  (2) If there are not enough free memory, join on the
      waitqueue list

        wait_event_timeout(waiter, memory_reclaimed, timeout)

      and wait for reclaiming kernel threads (e.g. kswapd) to wake
      the waiters up. If the caller is willing to give up upon SIGKILL
      (e.g. __GFP_KILLABLE) then

        wait_event_killable_timeout(waiter, memory_reclaimed, timeout)

      and return NULL upon SIGKILL.

  (3) Whenever reclaiming kernel threads reclaimed memory and there are
      waiters, wake the waiters up.

  (4) If reclaiming kernel threads cannot reclaim memory,
      the caller will wake up due to timeout, and invoke the OOM
      killer unless the caller does not want (e.g. __GFP_NO_OOMKILL).

> 
>    where 'X" is something sane that limits our CPU use, but also
> guarantees that we don't end up waiting *too* long (if a single
> allocation takes more than a big fraction of a second, we should
> probably stop trying).

Isn't a second too short for waiting for swapping / writeback?

> 
> The whole time-based thing might even be explicit. There's nothing
> wrong with doing something like
> 
>     unsigned long timeout = jiffies + HZ/4;
> 
> at the top of the function, and making the whole retry logic actually
> say something like
> 
>     if (time_after(timeout, jiffies)) goto noretry;
> 
> (or make *that* trigger the oom logic, or whatever).

I prefer time-based thing, for my customer's usage (where watchdog timeout
is configured to 10 seconds) will require kernel messages (maybe OOM killer
messages) printed within a few seconds.

> 
> Now, I realize the above suggestions are big changes, and they'll
> likely break things and we'll still need to tweak things, but dammit,
> wouldn't that be better than just randomly tweaking the insane
> zone_reclaimable logic?
> 
>                     Linus

Yes, this will be big changes. But this change will be better than living
with "no means for understanding what was happening are available" v.s.
"really interesting things are observed if means are available".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
