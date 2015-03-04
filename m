Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 22B216B006C
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 07:52:53 -0500 (EST)
Received: by pablj1 with SMTP id lj1so24110971pab.10
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 04:52:52 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id uw4si4905983pac.154.2015.03.04.04.52.50
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 04:52:51 -0800 (PST)
Date: Wed, 4 Mar 2015 23:52:46 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150304125246.GT18360@dastard>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150302151832.GE26334@dhcp22.suse.cz>
 <20150302163913.GL3287@thunk.org>
 <20150302165823.GH26334@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150302165823.GH26334@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Mon, Mar 02, 2015 at 05:58:23PM +0100, Michal Hocko wrote:
> On Mon 02-03-15 11:39:13, Theodore Ts'o wrote:
> > On Mon, Mar 02, 2015 at 04:18:32PM +0100, Michal Hocko wrote:
> > > The idea is sound. But I am pretty sure we will find many corner
> > > cases. E.g. what if the mere reservation attempt causes the system
> > > to go OOM and trigger the OOM killer?
> > 
> > Doctor, doctor, it hurts when I do that....
> > 
> > So don't trigger the OOM killer.  We can let the caller decide whether
> > the reservation request should block or return ENOMEM, but the whole
> > point of the reservation request idea is that this happens *before*
> > we've taken any mutexes, so blocking won't prevent forward progress.
> 
> Maybe I wasn't clear. I wasn't concerned about the context which
> is doing to reservation. I was more concerned about all the other
> allocation requests which might fail now (becasuse they do not have
> access to the reserves). So you think that we should simply disable OOM
> killer while there is any reservation active? Wouldn't that be even more
> fragile when something goes terribly wrong?

That's a silly strawman.  Why wouldn't you simply block them until
the reserves are released when the transaction completes and the
unused memory goes back to the free pool?

Let me try another tack. My qualifications are as a
distributed control system engineer, not a computer scientist. I
see everything as a system of interconnected feedback loops: an
operating system is nothing but a set of very complex, tightly
interconnected control systems.

Precedence? IO-less dirty throttling - that came about after I'd
been advocating a control theory based algorithm for several years
to solve the breakdown problems of dirty page throttling.  We look
at the code Fenguang Wu wrote as one of the major success stories of
Linux - the writeback code just works and nobody ever has to tune it
anymore.

I see the problem of direct memory reclaim as being very similar to
the problems the old IO based write throttling had: it has unbound
concurrency, severe unfairness and breaks down badly when heavily
loaded.  As a control system, it has the same terrible design
as the IO-based write throttling had.

There are other many similarities, too.

Allocation can only take place at the rate at which reclaim occurs,
and we only have a limited budget of allocatable pages. This is the
same as the dirty page throttling - dirtying pages is limited to the
rate we can clean pages, and there are a limited budget of dirty
pages in the system.

Reclaiming pages is also done most efficiently by a single thread
per zone where lots of internal context can be kept (kswapd). This
is similar to optimal writeback of dirty pages requires a
single thread with internal context per block device..

Waiting for free pages to arrive can be done by an ordered queuing
system, and we can account for the number of pages each allocation
requires in the queueing system and hence only need wake the number
of waiters that will consume the memory just freed. Just like we do
with the the dirty page throttling queue.

As such, the same solutions could be applied. As the allocation
demand exceeds the supply of free pages, we throttle allocation by
sleeping on an ordered queue and only waking waiters at the rate
at which kswapd reclaim can free pages. It's trivial to account
accurately, and the feedback loop is relatively simple, too.

We can also easily maintain a reserve of free pages this way, usable
only by allocation marked with special flags.  The reserve threshold
can be dynamic, and tasks that request it to change can be blocked
until the reserve has been built up to meet caler requirements.
Allocations that are allowed to dip into the reserve may do so
rather than being added to the queue that waits for reclaim.

Reclaim would always fill the reserve back up to it's limits first,
and tasks that have reservations can release them gradually as they
mark them as consumed by the reservation context (e.g. when a
filesystem joins an object to a transaction and modifies it),
thereby reducing the reserve that task has available as it
progresses.

So, there's yet another possible solution to the allocation
reservation problem, and one that solves several other problems that
are being described as making reservation pools difficult or even
impossible to implement.

Seriously, I'm not expecting this problem to be solved tomorrow;
what I want is reliable, deterministic memory allocation behaviour
from the mm subsystem. I want people to be thinking about how to
acheive that rather than limiting their solutions by what we have
now and can hack into the current code, because otherwise we'll
never end up with a reliable memory allocation reservation system....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
