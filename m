Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 24B316B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 13:14:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id k133so31121905ita.3
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 10:14:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 5si22352675iob.195.2017.06.02.10.14.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 10:14:02 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170601132808.GD9091@dhcp22.suse.cz>
	<20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
	<20170602071818.GA29840@dhcp22.suse.cz>
	<201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
	<20170602121533.GH29840@dhcp22.suse.cz>
In-Reply-To: <20170602121533.GH29840@dhcp22.suse.cz>
Message-Id: <201706030213.JFI39513.FFOSVFOJLQMHtO@I-love.SAKURA.ne.jp>
Date: Sat, 3 Jun 2017 02:13:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

Michal Hocko wrote:
> On Fri 02-06-17 20:13:32, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
> > >> Michal Hocko wrote:
> > >>> On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> > >>>> Cong Wang has reported a lockup when running LTP memcg_stress test [1].
> > >>>
> > >>> This seems to be on an old and not pristine kernel. Does it happen also
> > >>> on the vanilla up-to-date kernel?
> > >>
> > >> 4.9 is not an old kernel! It might be close to the kernel version which
> > >> enterprise distributions would choose for their next long term supported
> > >> version.
> > >>
> > >> And please stop saying "can you reproduce your problem with latest
> > >> linux-next (or at least latest linux)?" Not everybody can use the vanilla
> > >> up-to-date kernel!
> > >
> > > The changelog mentioned that the source of stalls is not clear so this
> > > might be out-of-tree patches doing something wrong and dump_stack
> > > showing up just because it is called often. This wouldn't be the first
> > > time I have seen something like that. I am not really keen on adding
> > > heavy lifting for something that is not clearly debugged and based on
> > > hand waving and speculations.
> > 
> > You are asking users to prove that the problem is indeed in the MM subsystem,
> > but you are thinking that kmallocwd which helps users to check whether the
> > problem is indeed in the MM subsystem is not worth merging into mainline.
> > As a result, we have to try things based on what you think handwaving and
> > speculations. This is a catch-22. If you don't want handwaving/speculations,
> > please please do provide a mechanism for checking (a) and (b) shown later.
> 
> configure watchdog to bug on soft lockup, take a crash dump, see what
> is going on there and you can draw a better picture of what is going on
> here. Seriously I am fed up with all the "let's do the async thing
> because it would tell much more" side discussions. You are trying to fix
> a soft lockup which alone is not a deadly condition.

Wrong and unacceptable. I'm trying to collect information for not only the
cause of allocation stall reported by Cong Wang but also any allocation stalls
(e.g. infinite too_many_isolated() trap from shrink_inactive_list() and
infinite mempool_alloc() loop case).

I was indeed surprised to know how severe a race condition on a system with
many CPUs at http://lkml.kernel.org/r/201409192053.IHJ35462.JLOMOSOFFVtQFH@I-love.SAKURA.ne.jp .
Therefore, like you suspect, it is possible that dump_stack() serialization
might be unfair on some hardware, especially when a lot of allocating threads
are calling warn_alloc(). But if you read Cong's report, you will find that
allocation stalls began before the first detection of soft lockup due to
dump_stack() serialization. This suggests that allocation stalls already began
before the system enters into a state where a lot of allocating threads started
calling warn_alloc(). Then, I think that it is natural to suspect that the
first culprit is MM subsystem. If you believe that you can debug and explain
why the OOM killer was not invoked in Cong's case without comparing how situation
changes over time (i.e. with a crash dump only), please explain it in that thread.

>                                                      If the system is
> overwhelmed it can happen and if that is the case then we should care
> whether it gets resolved or it is a permanent livelock situation.

What I'm trying to check is exactly whether the stall gets resolved or
the stall is a permanent livelock situation, via allowing users to take
multiple snapshots of memory image and compare how situation changes over
time. Taking a crash dump via kernel panic cannot allow users to take
multiple snapshots of memory image.

>                                                                   If yes
> then we need to isolate which path is not preempting and why and place
> the cond_resched there. The page allocator contains preemption points,
> if we are lacking some for some pathological paths let's add them.

What I'm talking about is not the lack of cond_resched(). As far as we know,
cond_resched() is inserted whereever necessary. What I'm talking about is
that cond_resched() cannot yield enough CPU time.

Looping with calling cond_resched() can yield only e.g. 1% of CPU time
compared to looping without calling cond_resched(). But if e.g. 100 threads
are looping with only cond_resched(), some thread waiting for wake up from
schedule_timeout_killable(1) can delay a lot. If that some thread has idle
priority, the delay can become too long to wait.

>                                                                    For
> some reason you seem to be focused only on the warn_alloc path, though,
> while the real issue might be somewhere completely else.

Not only because uncontrolled concurrent warn_alloc() causes flooding of
printk() and prevents users from knowing what is going on, but also
warn_alloc() cannot be called when we hit e.g. infinite too_many_isolated()
loop case or infinite mempool_alloc() loop case which after all prevents
users from knowing what is going on.

You are not providing users means to skip warn_alloc() when flooding of
printk() is just a junk (i.e. the real issue is somewhere completely else)
or call warn_alloc() when all printk() messages are needed (i.e. the issue
is in the MM subsystem). Current implementation of warn_alloc() can act as
launcher of corrupted spam messages. Without comparing how situation changes
over time, via reliably saving all printk() messages which might potentially
be relevant, we can't judge whether warn_alloc() flooding is just a collateral
phenomenon of a real issue somewhere completely else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
