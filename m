Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 26A2F6B027A
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 11:44:49 -0400 (EDT)
Received: by ykcf206 with SMTP id f206so47350050ykc.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:44:48 -0700 (PDT)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id g190si19069289ywf.175.2015.09.03.08.44.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 08:44:48 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so47310167ykd.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:44:47 -0700 (PDT)
Date: Thu, 3 Sep 2015 11:44:45 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [RFD] memory pressure and sizing problem
Message-ID: <20150903154445.GA10394@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hello,

It's bothering that we don't have a good mechanism to detect and
expose memory pressure and it doesn't seem to be for want of trying.
I've been thinking about it for several days and would like to find
out whether it makes sense.  Not being a mm person, I'm likely
mistaken in a lot of details, if not the core concept.  Please point
out whenever I wander into the lala land.


1. Background

AFAIK, there currently are two metrics in use.  One is scan ratio -
how many pages are being scanned for reclaim per unit time.  This is
what paces the different reclaimers.  While it is related to memory
pressure, it involves enough of other factors to be useful as a
measure of pressure - e.g. a high-bandwidth streaming workload would
cause high scan ratio but can't be said to be under memory pressure.

The other metric measures how much reclaimer is struggling - the ratio
of the number of pages which couldn't be reclaimed against total
scanned.  As memory requirement rises, more and more would try to
allocate memory making reclaimer cycle faster and encounter more pages
which can't be reclaimed yet.  This actually is a measure of pressure
and what's exposed by vmpressure.

However, what a specific number means is unclear.  The system would be
struggling if 95% of pages couldn't be reclaimed but what would 20%
mean?  How about 15%?  Also, depending on how often the reclaimer does
its rounds, which in large part is dependent on implementation
details, the resulting number can be widely different while the system
is showing about the same behavior overall.  These are why vmpressure
is exposed as a three-level state but even with such coarse scale, the
semantics isn't clear and too much is left to implementation details.

There also have been other attempts.  Vladimir recently posted a
patchset which allows userland to monitor physical page usage -
userland can clear used state on pages and then read it back after a
while so that it can tell which pages have been used inbetween.  While
this allows detecting unused pages, this doesn't represent memory
pressure.  If we go back to the streamer example above, high-enough
bandwidth streamer would happily consume all the memory that's given
to it and looking at used bits won't tell much.


2. Memory pressure and sizing problem

Memory pressure sounds intuitive but isn't actually that well defined.
It's closely tied to answering the sizing problem - "how much memory
does a given workload need to run smoothly?" and answering that has
become more important with cgroup and containerization.

Sizing is inherently tricky because mm only tracks a small portion of
all memory accesses.  We can't tell "this process referenced this page
twice, 2mins and 18secs ago".  Deciding whether a page is actively
used costs and we only track enough information to make reclaim work
reasonably.  Consequently, it's impossible to tell the working set
size of a workload without subjecting it to memory reclaim.

Once a workload is subject to memory reclaim, we need a way to tell
whether it needs more memory and that measure can be called memory
pressure - a workload is under memory pressure if it needs more memory
to execute smoothly.  More precisely, I think it can be defined as the
following.


3. Memory pressure

  In a given amount of time, the proportion of time that the execution
  duration of the workload has been lengthened due to lack of memory.

I used "lengthened" instead of "delayed" because delays don't
necessarily indicate that the workload can benefit from more memory.
Consider the following execution pattern where '_' is idle and '+' is
running.  Let's assume that each CPU burst is caused by receiving a
request over network.

  W0: ++____++____++____

Let's say the workload now needs to fault in some memory during each
CPU burst - represented by 'm'.

  W1: +mm+__+mm+__+mm+__

While delays due to memory shortage have occurred, the duration of the
execution stayed the same.  In terms of amount of work done, the
workload wouldn't have benefited from more memory.  Now, consider the
following workload where 'i' represents direct IO from filesystem.

  W2: ++iiii++iiii++iiii

If the workload experiences the same page faults,

  W3: +mm+iiii+mm+iiii+mm+iiii

The entire workload has been lengthened by 6 slots or 25%.  According
to the above definition, it's under 25% memory pressure.  This is a
well-defined metric which doesn't depend on implementation details and
enables immediate intuitive understanding of the current state.


4. Inherent limitations

It'd be great if we can calculate the proportion exactly;
unfortunately, we can't because there are things we don't know about
the workload.  Let's go back to W2.  Let's say it now accesses more
memory and thus causes extra faults before each CPU burst.

  W4: mm+mm+mm+mm+mm+mm+

It still hasn't lost any amount of work; however, we can no longer
tell that whether the pattern without faults would be W0 or

  W5: ++++++++++++++++++

Another issue is that W0's idle periods may not be collapsible.  For
example, if the idle periods are latencies from executing RPC calls,
injecting page faults would make it look like the following but it'd
be difficult to tell the nature of the idle periods from outside.

  W6: mm++____mm++____mm++____

So, there are inherent limitations in what can be determined; however,
even with the above inaccuracies, the proportion should be able to
function as a pretty good indicator of whether the workload is likely
to benefit from more memory.  Also, the incollapsible idle issue is
likely to be much less of a problem for larger scalable workloads.


5. Details

We need to make more concessions to make it implementable.  I probably
missed quite a bit but here are what I've thought about.


5-1. Calculable definition

 Running average of the proportion of CPU time a workload couldn't
 consume due to memory shortage in a given time unit.

A workload, whether a thread or multiple processes, can be in one of
the following states on a CPU.

  R1) READY or RUNNING
  R2) IO
  M1) READY or RUNNING due to memory shortage
  M2) IO due to memory shortage
  I ) IDLE

R1 and R2 count as the execution time.  M1 and M2 are CPU time which
couldn't be spent due to memory shortage which gets reset by I and the
pressure P in a given time unit is calculated as

  R = R1 + R2
  M = M1 + M2 after the last I
  P = M / (R + M)


5-2. Telling Ms from Rs

If a task is in one of the following states, it is in a M state.

  * Performing or waiting for memory reclaim.

  * Reading back pages from swap.

  * Faulting in pages which have been faulted before.

The first two are clear.  We can use refault distance for the last.
I've flipped on this several times now but currently think that we
want to set maximum refault distance beyond which a fault is
considered new - e.g. if refault distance is larger than 4x currently
available memory, count it as R2 instead of M2.  There are several
things to consider.

  * There are practical limits to tracking refault distance.  Once the
    inode itself is reclaimed, we lose track of it.

  * It likely isn't useful to indicate that more memory would be
    beneficial for a workload which requires orders of magnitude more
    memory than available.  That workload is either infeasible or
    simply IO bound.

  * The larger refault distance gets, the less precise its meaning
    becomes.  A page at 8x distance may really need 8x memory to stay
    in memory or just 10% more.

This does create a boundary artifact although I doubt it's likely to
be a problem in practice.  If anyone has a better idea, please be my
guest.

If a workload comprises multiple tasks, if any task is in a R state on
a CPU, the workload is in R state on that CPU.  If none is in a R
state and more than one are in a M, M.  If all are in I, I.


5-3. IDLE

Theoretically, we can consider all TASK_INTERRUPTIBLE sleeps as IDLE
points and clear the accumulated M durations in that time unit;
however, ignoring sleeps shorter than certain percentage of the unit
time or accumulated R durations is likely to lead to better and more
forgiving behavior while not really affecting the effectiveness of the
metric.

So, what do you think?

Thanks.

--
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
