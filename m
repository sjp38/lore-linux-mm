Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C3500680FED
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 19:58:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 76so4809175pgh.11
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 16:58:27 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id 67si295715ple.596.2017.07.05.16.58.25
        for <linux-mm@kvack.org>;
        Wed, 05 Jul 2017 16:58:27 -0700 (PDT)
Date: Thu, 6 Jul 2017 09:58:23 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170705235823.GV17542@dastard>
References: <20170620024645.GA27702@bbox>
 <20170627135931.GA14097@destiny>
 <20170630021713.GB24520@bbox>
 <20170630150322.GB9743@destiny>
 <20170703013303.GA2567@bbox>
 <20170703135006.GC27097@destiny>
 <20170704030100.GA16432@bbox>
 <20170704132136.GB6807@destiny>
 <20170704225758.GT17542@dastard>
 <20170705045912.GC20079@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170705045912.GC20079@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, mhocko@kernel.org, cl@linux.com

On Wed, Jul 05, 2017 at 01:59:12PM +0900, Minchan Kim wrote:
> Hi Dave,
> 
> On Wed, Jul 05, 2017 at 08:57:58AM +1000, Dave Chinner wrote:
> > On Tue, Jul 04, 2017 at 09:21:37AM -0400, Josef Bacik wrote:
> > > On Tue, Jul 04, 2017 at 12:01:00PM +0900, Minchan Kim wrote:
> > > > 1. slab *page* reclaim
> > > > 
> > > > Your claim is that it's hard to reclaim a page by slab fragmentation so need to
> > > > reclaim objects more aggressively.
> > > > 
> > > > Basically, aggressive scanning doesn't guarantee to reclaim a page but it just
> > > > increases the possibility. Even, if we think slab works with merging feature(i.e.,
> > > > it mixes same size several type objects in a slab), the possibility will be huge
> > > > dropped if you try to bail out on a certain shrinker. So for working well,
> > > > we should increase aggressiveness too much to sweep every objects from all shrinker.
> > > > I guess that's why your patch makes the logic very aggressive.
> > > > In here, my concern with that aggressive is to reclaim all objects too early
> > > > and it ends up making void caching scheme. I'm not sure it's gain in the end.
> > > >
> > > 
> > > Well the fact is what we have doesn't work, and I've been staring at this
> > > problem for a few months and I don't have a better solution.
> > > 
> > > And keep in mind we're talking about a purely slab workload, something that
> > > isn't likely to be a common case.  And even if our scan target is 2x, we aren't
> > > going to reclaim the entire cache before we bail out.  We only scan in
> > > 'batch_size' chunks, which generally is 1024.  In the worst case that we have
> > > one in use object on every slab page we own then yes we're fucked, but we're
> > > still fucked with the current code, only with the current code it'll take us 20
> > > minutes of looping in the vm vs. seconds scanning the whole list twice.
> > 
> > Right - this is where growth/allocation rate based aging scans
> > come into play, rather than waiting for the VM to hit some unknown
> > ceiling and do an unpredictable amount of scanning.
> 
> http://www.spinics.net/lists/linux-mm/msg129470.html
> 
> I suggested static scanning increasement(1/12 + 2/12 + 3/12...) which is
> more aggressive compared to as-is. With this, in a reclaim cycle(priority
> 12..0), we guarantees that scanning of entire objects list four times
> while LRU is two times. Although I believe we don't need four times
> (i.e., it's enough with two times), it's just compromise solution with
> Josef's much too agressive slab reclaim.
> It would be more predictable and aggressive from VM point of view.

Yes, I read and understood that post, but you are talking about
changing reclaim behaviour when there is low memory, not dealing
with the aging problem. It's a brute force big hammer approach, yet
we already know that increasingly aggressive reclaim of caches is a
problem for filesystems in that it drives us into OOM conditions
faster. i.e. agressive shrinker reclaim trashes the working set of
cached filesystem metadata and so increases the GFP_NOFS memory
allocation demand required by the filesystem at times of critically
low memory....

> If some of shrinker cannot be happy with this policy, it would accelerate
> the scanning for only that shrinker under shrink_slab call although I don't
> like it because it's out of control from VM pov so I'm okay your per-shrinker
> aging callback regardless of shrink_slab. My point is if some of shrinker is
> painful to be reclaimed, it should have own model to solve it rather than
> making general slab reclaim strately very aggressive.

We already do this in various filesystems. The issue is that we
don't know that we should reclaim caches until shrinker callbacks
start happening. i.e. there's *no feedback mechanism* that allows us
to age shrinker controlled caches over time. memory reclaim is a
feedback loop but if we never hit low memory, then it's never
invoked until we actually run out of memory and so it drowns in
aging rather than reclaim work when it does get run.

Stop looking at the code and start thinking about the architecture -
how the subsystems connect and what control/feedback mechanisms are
required to allow them to work correctly together. We solve balance
and breakdown problems by identifying the missing/sub-optimal
feedback loops and fixing them. In this case, what we are missing is
the mechanism to detect and control "cache growth in single use
workloads when there is no memory pressure". Sustained cache
allocation should trigger some amount of aging regardless of how
much free memory we have, otherwise we simply fill up memory with
objects we're never going to use again.....

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
