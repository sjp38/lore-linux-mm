Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA956B0032
	for <linux-mm@kvack.org>; Sat, 21 Feb 2015 16:38:14 -0500 (EST)
Received: by pablf10 with SMTP id lf10so17132780pab.6
        for <linux-mm@kvack.org>; Sat, 21 Feb 2015 13:38:14 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id wr6si24986058pbc.82.2015.02.21.13.38.11
        for <linux-mm@kvack.org>;
        Sat, 21 Feb 2015 13:38:12 -0800 (PST)
Date: Sun, 22 Feb 2015 08:38:07 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150221213807.GI12722@dastard>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
 <20150220231511.GH12722@dastard>
 <20150221032000.GC7922@thunk.org>
 <20150221011907.2d26c979.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150221011907.2d26c979.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org

On Sat, Feb 21, 2015 at 01:19:07AM -0800, Andrew Morton wrote:
> On Fri, 20 Feb 2015 22:20:00 -0500 "Theodore Ts'o" <tytso@mit.edu> wrote:
> 
> > +akpm
> 
> I was hoping not to have to read this thread ;)

ditto....

> And yes, I agree that sites such as xfs's kmem_alloc() should be
> passing __GFP_NOFAIL to tell the page allocator what's going on.  I
> don't think it matters a lot whether kmem_alloc() retains its retry
> loop.  If __GFP_NOFAIL is working correctly then it will never loop
> anyway...

I'm not about to change behaviour "just because". Any sort of change
like this requires a *lot* of low memory regression testing because
we'd be replacing long standing known behaviour with behaviour that
changes without warning. e.g the ext4 low memory failures starting because of
changes made in 3.19-rc6 due to changes in oom-killer behaviour.
Those changes *did not affect XFS* and that's the way I'd like
things to remain.

Put simply: right now I don't trust the mm subsystem to get low memory
behaviour right, and this thread has done nothing to convince me
that it's going to improve any time soon.

> Also, this:
> 
> On Wed, 18 Feb 2015 09:54:30 +1100 Dave Chinner <david@fromorbit.com> wrote:
> 
> > Right now, the oom killer is a liability. Over the past 6 months
> > I've slowly had to exclude filesystem regression tests from running
> > on small memory machines because the OOM killer is now so unreliable
> > that it kills the test harness regularly rather than the process
> > generating memory pressure.
> 
> David, I did not know this!  If you've been telling us about this then
> perhaps it wasn't loud enough.

IME, such bug reports get ignored.

Instead, over the past few months I have been pointing out bugs and
problems in the oom-killer in threads like this because it seems to
be the only way to get any attention to the issues I'm seeing. Bug
reports simply get ignored.  From this process, I've managed to
learn that low order memory allocation now never fails (contrary to
documentation and long standing behavioural expectations) and
pointed out bugs that cause the oom killer to get invoked when the
filesystem is saying "I can handle ENOMEM!" (commit 45f87de ("mm:
get rid of radix tree gfp mask for pagecache_get_page").

And yes, I've definitely mentioned in these discussions that, for
example, xfstests::generic/224 is triggering the oom killer far more
often than it used to on my 1GB RAM vm. The only fix that has been
made recently that's made any difference is 45f87de, so it's a slow
process of raising awareness and trying to ensure things don't get
worse before they get better....

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
