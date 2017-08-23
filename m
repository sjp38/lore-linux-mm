Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 364B42802FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 12:04:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 133so534261wmr.11
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 09:04:07 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id i88si1792039edd.342.2017.08.23.09.04.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 09:04:04 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 602B41C2209
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 17:04:04 +0100 (IST)
Date: Wed, 23 Aug 2017 17:04:03 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Message-ID: <20170823160403.em3umubemgxt2rrn@techsingularity.net>
References: <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 22, 2017 at 11:19:12AM -0700, Linus Torvalds wrote:
> On Tue, Aug 22, 2017 at 10:23 AM, Liang, Kan <kan.liang@intel.com> wrote:
> >
> > Although the patch doesn't trigger watchdog, the spin lock wait time
> > is not small (0.45s).
> > It may get worse again on larger systems.
> 
> Yeah, I don't think Mel's patch is great - because I think we could do
> so much better.
> 
> What I like about Mel's patch is that it recognizes that
> "wait_on_page_locked()" there is special, and replaces it with
> something else. I think that "something else" is worse than my
> "yield()" call, though.
> 

I only partially agree. yield() can be unbound if there are an indefinite
number of lock holders or frequent reacquisitions. yield() also some warnings
around it related to potentially never doing the actual yield. The latter
can cause lockup warnings. I was aiming for was the easiest path to "try
for a bit but give up in a reasonable amount of time". I picked waiting
on the page lock because at least it'll recover. I could have returned
and allowed the fault to retry but thought this may consume excessive CPU.

I spent more time on the test case to try and get some sort of useful
data out of it and that took most of the time I had available again. The
current state of the test case still isn't hitting the worst patterns but
it can at least detect latency problems. It uses multiple threads bound to
different nodes to access thread-private data within a large buffer where
each thread's data is aligned. For example, an alignment of 64 would have
each thread access a private cache line while still sharing a page from
a NUMA balancing point of view. 4K would still share a page if THP was
used. I've a few patches running on a 4-socket machine with 144 I borrowed
for a few hours and hopefully something will fall out that.

> So if we do busy loops, I really think we should also make sure that
> the thing we're waiting for is not preempted.
> 
> HOWEVER, I'm actually starting to think that there is perhaps
> something else going on.
> 
> Let me walk you through my thinking:
> 
> This is the migration logic:
> 
>  (a) migration locks the page
> 
>  (b) migration is supposedly CPU-limited
> 
>  (c) migration then unlocks the page.
> 
> Ignore all the details, that's the 10.000 ft view. Right?
> 

Right.

> Now, if the above is right, then I have a question for people:
> 
>   HOW IN THE HELL DO WE HAVE TIME FOR THOUSANDS OF THREADS TO HIT THAT ONE PAGE?
> 

There are not many explanations. Given that it's thousands of threads, it
may be the case that some are waiting while there are many more contending
on CPU. The migration process can get scheduled out which might compound the
problem. While THP migration gives up quickly after a migration failure,
base page migration does not. If any part of the migration path returns
EAGAIN, it'll retry up to 10 times and depending where it is, that can
mean the migrating process is locking the page 10 times. If it's fast
enough reacquiring the lock, the waiting processes will wait for each of
those 10 attempts because they don't notice that base page migration has
already cleared the NUMA pte.

Given that NUMA balancing is best effort, the 10 attempts for numa balancing
is questionable. A patch to test should be straight-forward so I'll spit
it out after this mail and queue it up.

> That just sounds really sketchy to me. Even if all those thousands of
> threads are runnable, we need to schedule into them just to get them
> to wait on that one page.
> 

The same is true if they are just yielding.

> So that sounds really quite odd when migration is supposed to hold the
> page lock for a relatively short time and get out. Don't you agree?
> 

Yes. As part of that getting out, it shouldn't retry 10 times.

> Which is why I started thinking of what the hell could go on for that
> long wait-queue to happen.
> 
> One thing that strikes me is that the way wait_on_page_bit() works is
> that it will NOT wait until the next bit clearing, it will wait until
> it actively *sees* the page bit being clear.
> 
> Now, work with me on that. What's the difference?
> 
> What we could have is some bad NUMA balancing pattern that actually
> has a page that everybody touches.
> 
> And hey, we pretty much know that everybody touches that page, since
> people get stuck on that wait-queue, right?
> 
> And since everybody touches it, as a result everybody eventually
> thinks that page should be migrated to their NUMA node.
> 

Potentially yes. There is a two-pass filter as mentioned elsewhere in the
thread and the scanner has to update the PTEs for that to happen but it's not
completely impossible. Once a migration starts, other threads shouldn't try
again until the next window. That window can be small but with thousands
of threads potentially scanning (even at a very slow rate), the window
could be tiny. If many threads are doing the scanning one after the other,
it would potentially allow the two-pass check to pass sooner than expected.

Co-incidentally, Rik encountered this class of problem and there is a
patch in Andrew's tree "sched/numa: Scale scan period with tasks in group
and shared/private" that might have an impact on this problem.

> But for all we know, the migration keeps on failing, because one of
> the points of that "lock page - try to move - unlock page" is that
> *TRY* in "try to move". There's a number of things that makes it not
> actually migrate. Like not being movable, or failing to isolate the
> page, or whatever.
> 
> So we could have some situation where we end up locking and unlocking
> the page over and over again (which admittedly is already a sign of
> something wrong in the NUMA balancing, but that's a separate issue).
> 

The retries are part of the picture in the migration side. Multiple
protection updates from large numbers of threads are another potential
source.

> And if we get into that situation, where everybody wants that one hot
> page, what happens to the waiters?
> 
> One of the thousands of waiters is unlucky (remember, this argument
> started with the whole "you shouldn't get that many waiters on one
> single page that isn't even locked for that long"), and goes:
> 
>  (a) Oh, the page is locked, I will wait for the lock bit to clear
> 
>  (b) go to sleep
> 
>  (c) the migration fails, the lock bit is cleared, the waiter is woken
> up but doesn't get the CPU immediately, and one of the other
> *thousands* of threads decides to also try to migrate (see above),
> 
>  (d) the guy waiting for the lock bit to clear will see the page
> "still" locked (really just "locked again") and continue to wait.
> 

Part c may be slightly inaccurate but I think a similar situation can occur
with multiple threads deciding to do change_prot_numa in quick succession
so it's functionally similar.

> In the meantime, one of the other threads happens to be unlucky, also
> hits the race, and now we have one more thread waiting for that page
> lock. It keeps getting unlocked, but it also keeps on getting locked,
> and so the queue can keep growing.
> 
> See where I'm going here? I think it's really odd how *thousands* of
> threads can hit that locked window that is supposed to be pretty
> small. But I think it's much more likely if we have some kind of
> repeated event going on.
> 

Agreed.

> So I'm starting to think that part of the problem may be how stupid
> that "wait_for_page_bit_common()" code is. It really shouldn't wait
> until it sees that the bit is clear. It could have been cleared and
> then re-taken.
> 
> And honestly, we actually have extra code for that "let's go round
> again". That seems pointless. If the bit has been cleared, we've been
> woken up, and nothing else would have done so anyway, so if we're not
> interested in locking, we're simply *done* after we've done the
> "io_scheduler()".
> 
> So I propose testing the attached trivial patch. It may not do
> anything at all. But the existing code is actually doing extra work
> just to be fragile, in case the scenario above can happen.
> 
> Comments?

Nothing useful to add on top of Peter's concerns but I haven't thought
about that aspect of the thread very much. I'm going to try see if a
patch that avoids multiple migration retries or Rik's patch have a
noticable impact in case they are enough on their own.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
