Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF476B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 08:25:20 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so9554949pab.5
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 05:25:19 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id nm4si5153186pdb.73.2015.03.04.05.25.17
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 05:25:18 -0800 (PST)
Date: Thu, 5 Mar 2015 00:25:14 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150304132514.GW4251@dastard>
References: <20150224210244.GA13666@dastard>
 <201502252331.IEJ78629.OOOFSLFMHQtFVJ@I-love.SAKURA.ne.jp>
 <20150227073949.GJ4251@dastard>
 <201502272142.BFJ09388.OLOMFFFVSQJOtH@I-love.SAKURA.ne.jp>
 <20150227131209.GK4251@dastard>
 <201503042141.FIC48980.OFFtVSQFOOMHJL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201503042141.FIC48980.OFFtVSQFOOMHJL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: tytso@mit.edu, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

On Wed, Mar 04, 2015 at 09:41:01PM +0900, Tetsuo Handa wrote:
> Dave Chinner wrote:
> > On Fri, Feb 27, 2015 at 09:42:55PM +0900, Tetsuo Handa wrote:
> > > If kswapd0 is blocked forever at e.g. mutex_lock() inside shrinker
> > > functions, who else can make forward progress?
> > 
> > You can't get into these filesystem shrinkers when you do GFP_NOIO
> > allocations, as the IO path does.
> > 
> > > Shouldn't we avoid calling functions which could potentially block for
> > > unpredictable duration (e.g. unkillable locks and/or completion) from
> > > shrinker functions?
> > 
> > No, because otherwise we can't throttle allocation and reclaim to
> > the rate at which IO can clean dirty objects. i.e. we do this for
> > the same reason we throttle page cache dirtying to the rate at which
> > we can clean dirty pages....
> 
> I'm misunderstanding something. The description for kswapd() function
> in mm/vmscan.c says "This basically trickles out pages so that we have
> _some_ free memory available even if there is no other activity that frees
> anything up".

Sure.

> Forever blocking kswapd0 somewhere inside filesystem shrinker functions is
> equivalent with removing kswapd() function because it also prevents non
> filesystem shrinker functions from being called by kswapd0, doesn't it?

Yes, but that's not intentional. Remember, we keep talking about the
filesystem not being able to guarantee forwards progress if
allocations block forever? Well...

> Then, the description will become "We won't have _some_ free memory available
> if there is no other activity that frees anything up", won't it?

... we've ended up blocking kswapd because it's waiting on a journal
commit to complete, and that journal commit is blocked waiting for
forwards progress in memory allocation...

Yes, it's another one of those nasty dependencies I keep pointing
out that filesystems have, and that can only be solved by
guaranteeing we can always make forwards allocation progress from
transaction reserve to transaction commit.

> Does kswapd0 exist only for reducing the delay caused by reclaiming
> synchronously? Disabling kswapd0 affects nothing about functionality?
> The system can make forward progress even if nobody can call non filesystem
> shrinkers, can't it?

The throttling is required to control the unbound parallelism of
direct reclaim. If we don't do this, inode cache reclaim causes
random inode writeback and thrashes the disks with random IO,
causing severe degradation in performance under heavy memory
pressure. So we throttle inode reclaim to a single thread per AG so
we get nice sequential IO patterns from inode cache reclaim - the
difference is that we can reclaim several hundred thousand dirty
inodes per second versus a few hundred...

And because memory allocation is bound by reclaim speed, we throttle
the direct reclaimers to prevent IO breakdown conditions from
occurring and hence keep performance under memory pressure
relatively high and mostly predictable.

It's rare that kswapd actually gets stuck like this - I've only ever
seen it once, and I've never had anyone running a production system
report deadlocks like this...

> I can't understand the difference between "kswapd0 sleeping forever at
> too_many_isolated() loop inside shrink_inactive_list()" and "kswapd0
> sleeping forever at mutex_lock() inside xfs_reclaim_inodes_ag()".

I don't really care.

The direct reclaim behaviour is a much bigger problem, and the risk
of occasionally having problems with kswapd is miniscule in
comparison. Sure, you can provoke it, but unless you are intentially
doing nasty things to production systems, it will never be a problem
that you trip over.

We can't solve every problem with the current memory
allcoatin/reclaim design - we've chosen the lesser evil here, and
we're going to have to live with it until we get a more robust
memory allocation subsystem implementation.

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
