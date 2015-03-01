Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id D17396B0032
	for <linux-mm@kvack.org>; Sun,  1 Mar 2015 11:15:20 -0500 (EST)
Received: by wgha1 with SMTP id a1so29066047wgh.5
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 08:15:20 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w8si18006661wjf.122.2015.03.01.08.15.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Mar 2015 08:15:19 -0800 (PST)
Date: Sun, 1 Mar 2015 11:15:06 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150301161506.GA1854@phnom.home.cmpxchg.org>
References: <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150228162943.GA17989@phnom.home.cmpxchg.org>
 <20150228164158.GE5404@thunk.org>
 <20150228221558.GA23028@phnom.home.cmpxchg.org>
 <20150301134322.GA3287@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150301134322.GA3287@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Sun, Mar 01, 2015 at 08:43:22AM -0500, Theodore Ts'o wrote:
> On Sat, Feb 28, 2015 at 05:15:58PM -0500, Johannes Weiner wrote:
> > Overestimating should be fine, the result would a bit of false memory
> > pressure.  But underestimating and looping can't be an option or the
> > original lockups will still be there.  We need to guarantee forward
> > progress or the problem is somewhat mitigated at best - only now with
> > quite a bit more complexity in the allocator and the filesystems.
> 
> We've lived with looping as it is and in practice it's actually worked
> well.  I can only speak for ext4, but I do a lot of testing under very
> high memory pressure situations, and it is used in *production* under
> very high stress situations --- and the only time we'e run into
> trouble is when the looping behaviour somehow got accidentally
> *removed*.
> 
> There have been MM experts who have been worrying about this situation
> for a very long time, but honestly, it seems to be much more of a
> theoretical than actual concern.

Well, looping is a valid thing to do in most situations because on a
loaded system there is a decent chance that an unrelated thread will
volunteer some unreclaimable memory, or exit altogether.  Right now,
we rely on this happening, and it works most of the time.  Maybe all
the time, depending on how your machine is used.  But when it does't,
machines do lock up in practice.

We had these lockups in cgroups with just a handful of threads, which
all got stuck in the allocator and there was nobody left to volunteer
unreclaimable memory.  When this was being addressed, we knew that the
same can theoretically happen on the system-level but weren't aware of
any reports.  Well now, here we are.

It's been argued in this thread that systems shouldn't be pushed to
such extremes in real life and that we simply expect failure at some
point.  If that's the consensus, then yes, we can stop this and tell
users that they should scale back.  But I'm not convinced just yet
that this is the best we can do.

> So if you don't want to get hints/estimates about how much memory
> the file system is about to use, when the file system is willing to
> wait or even potentially return ENOMEM (although I suspect starting
> to return ENOMEM where most user space application don't expect it
> will cause more problems), I'm personally happy to just use
> GFP_NOFAIL everywhere --- or to hard code my own infinite loops if
> the MM developers want to take GFP_NOFAIL away.  Because in my
> experience, looping simply hasn't been as awful as some folks on
> this thread have made it out to be.

As I've said before, I'd be happy to get estimates from the filesystem
so that we can adjust our reserves, instead of simply running against
the wall at some point and hoping that the OOM killer heuristics will
save the day.

Until then, I'd much prefer __GFP_NOFAIL over open-coded loops.  If
the OOM killer is too aggressive, we can tone it down, but as it
stands that mechanism is the last attempt at forward progress if
looping doesn't work out.  In addition, when we finally transition to
private memory reserves, we can easily find the callsites that need to
be annotated with __GFP_MAY_DIP_INTO_PRIVATE_RESERVES.

> So if you don't like the complexity because the perfect is the enemy
> of the good, we can just drop this and the file systems can simply
> continue to loop around their memory allocation calls...  or if that
> fails we can start adding subsystem specific mempools, which would be
> even more wasteful of memory and probably at least as complicated.

It really depends on what the goal here is.  You don't have to be
perfectly accurate, but if you can give us a worst-case estimate we
can actually guarantee forward progress and eliminate these lockups
entirely, like in the block layer.  Sure, there will be bugs and the
estimates won't be right from the start, but we can converge towards
the right answer.  If the allocations which are allowed to dip into
the reserves - the current nofail sites? - can be annotated with a gfp
flag, we can easily verify the estimates by serving those sites
exclusively from the private reserve pool and emit warnings when that
runs dry.  We wouldn't even have to stress the system for that.

But there are legitimate concerns that this might never work.  For
example, the requirements could be so unpredictable, or assessing them
with reasonable accuracy could be so expensive, that the margin of
error would make the worst case estimate too big to be useful.  Big
enough that the reserves would harm well-behaved systems.  And if
useful worst-case estimates are unattainable, I don't think we need to
bother with reserves.  We can just stick with looping and OOM killing,
that works most of the time, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
