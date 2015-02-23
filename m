Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 544E26B0032
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 19:45:27 -0500 (EST)
Received: by pablf10 with SMTP id lf10so23244573pab.6
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 16:45:26 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id do3si19919107pbb.158.2015.02.22.16.45.24
        for <linux-mm@kvack.org>;
        Sun, 22 Feb 2015 16:45:26 -0800 (PST)
Date: Mon, 23 Feb 2015 11:45:21 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150223004521.GK12722@dastard>
References: <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150221235227.GA25079@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Sat, Feb 21, 2015 at 06:52:27PM -0500, Johannes Weiner wrote:
> On Fri, Feb 20, 2015 at 09:52:17AM +1100, Dave Chinner wrote:
> > I will actively work around aanything that causes filesystem memory
> > pressure to increase the chance of oom killer invocations. The OOM
> > killer is not a solution - it is, by definition, a loose cannon and
> > so we should be reducing dependencies on it.
> 
> Once we have a better-working alternative, sure.

Great, but first a simple request: please stop writing code and
instead start architecting a solution to the problem. i.e. we need a
design and have that documented before code gets written. If you
watched my recent LCA talk, then you'll understand what I mean
when I say: stop programming and start engineering.

> > I really don't care about the OOM Killer corner cases - it's
> > completely the wrong way line of development to be spending time on
> > and you aren't going to convince me otherwise. The OOM killer a
> > crutch used to justify having a memory allocation subsystem that
> > can't provide forward progress guarantee mechanisms to callers that
> > need it.
> 
> We can provide this.  Are all these callers able to preallocate?

Anything that allocates in transaction context (and therefor is
GFP_NOFS by definition) can preallocate at transaction reservation
time. However, preallocation is dumb, complex, CPU and memory
intensive and will have a *massive* impact on performance.
Allocating 10-100 pages to a reserve which we will almost *never
use* and then free them again *on every single transaction* is a lot
of unnecessary additional fast path overhead.  Hence a "preallocate
for every context" reserve pool is not a viable solution.

And, really, "reservation" != "preallocation".

Maybe it's my filesystem background, but those to things are vastly
different things.

Reservations are simply an *accounting* of the maximum amount of a
reserve required by an operation to guarantee forwards progress. In
filesystems, we do this for log space (transactions) and some do it
for filesystem space (e.g. delayed allocation needs correct ENOSPC
detection so we don't overcommit disk space).  The VM already has
such concepts (e.g. watermarks and things like min_free_kbytes) that
it uses to ensure that there are sufficient reserves for certain
types of allocations to succeed.

A reserve memory pool is no different - every time a memory reserve
occurs, a watermark is lifted to accommodate it, and the transaction
is not allowed to proceed until the amount of free memory exceeds
that watermark. The memory allocation subsystem then only allows
*allocations* marked correctly to allocate pages from that the
reserve that watermark protects. e.g. only allocations using
__GFP_RESERVE are allowed to dip into the reserve pool.

By using watermarks, freeing of memory will automatically top
up the reserve pool which means that we guarantee that reclaimable
memory allocated for demand paging during transacitons doesn't
deplete the reserve pool permanently.  As a result, when there is
plenty of free and/or reclaimable memory, the reserve pool
watermarks will have almost zero impact on performance and
behaviour.

Further, because it's just accounting and behavioural thresholds,
this allows the mm subsystem to control how the reserve pool is
accounted internally. e.g. clean, reclaimable pages in the page
cache could serve as reserve pool pages as they can be immediately
reclaimed for allocation. This could be acheived by setting reclaim
targets first to the reserve pool watermark, then the second target
is enough pages to satisfy the current allocation.

And, FWIW, there's nothing stopping this mechanism from have order
based reserve thresholds. e.g. IB could really do with a 64k reserve
pool threshold and hence help solve the long standing problems they
have with filling the receive ring in GFP_ATOMIC context...

Sure, that's looking further down the track, but my point still
remains: we need a viable long term solution to this problem. Maybe
reservations are not the solution, but I don't see anyone else who
is thinking of how to address this architectural problem at a system
level right now.  We need to design and document the model first,
then review it, then we can start working at the code level to
implement the solution we've designed.

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
