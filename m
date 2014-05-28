Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id EB1376B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 21:37:58 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so10199159pbb.25
        for <linux-mm@kvack.org>; Tue, 27 May 2014 18:37:58 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:6])
        by mx.google.com with ESMTP id py12si12799548pab.17.2014.05.27.18.37.56
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 18:37:57 -0700 (PDT)
Date: Wed, 28 May 2014 11:37:04 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/3] Shrinkers and proportional reclaim
Message-ID: <20140528013704.GI8554@dastard>
References: <1400749779-24879-1-git-send-email-mgorman@suse.de>
 <alpine.LSU.2.11.1405261441320.7154@eggly.anvils>
 <20140527023751.GB8554@dastard>
 <alpine.LSU.2.11.1405271406520.4317@eggly.anvils>
 <CALYGNiPZXnTG+vxg5tr+jnaDSvHRArJq=fmQ4bPD-m-iJU9jqA@mail.gmail.com>
 <alpine.LSU.2.11.1405271618360.5019@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1405271618360.5019@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 27, 2014 at 04:19:12PM -0700, Hugh Dickins wrote:
> On Wed, 28 May 2014, Konstantin Khlebnikov wrote:
> > On Wed, May 28, 2014 at 1:17 AM, Hugh Dickins <hughd@google.com> wrote:
> > > On Tue, 27 May 2014, Dave Chinner wrote:
> > >> On Mon, May 26, 2014 at 02:44:29PM -0700, Hugh Dickins wrote:
> > >> >
> > >> > [PATCH 4/3] fs/superblock: Avoid counting without __GFP_FS
> > >> >
> > >> > Don't waste time counting objects in super_cache_count() if no __GFP_FS:
> > >> > super_cache_scan() would only back out with SHRINK_STOP in that case.
> > >> >
> > >> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > >>
> > >> While you might think that's a good thing, it's not.  The act of
> > >> shrinking is kept separate from the accounting of how much shrinking
> > >> needs to take place.  The amount of work the shrinker can't do due
> > >> to the reclaim context is deferred until the shrinker is called in a
> > >> context where it can do work (eg. kswapd)
> > >>
> > >> Hence not accounting for work that can't be done immediately will
> > >> adversely impact the balance of the system under memory intensive
> > >> filesystem workloads. In these worklaods, almost all allocations are
> > >> done in the GFP_NOFS or GFP_NOIO contexts so not deferring the work
> > >> will will effectively stop superblock cache reclaim entirely....
> > >
> > > Thanks for filling me in on that.  At first I misunderstood you,
> > > and went off looking in the wrong direction.  Now I see what you're
> > > referring to: the quantity that shrink_slab_node() accumulates in
> > > and withdraws from shrinker->nr_deferred[nid].
> > 
> > Maybe shrinker could accumulate fraction nr_pages_scanned / lru_pages
> > instead of exact amount of required work? Count of shrinkable objects
> > might be calculated later, when shrinker is called from a suitable context
> > and can actualy do something.
> 
> Good idea, probably a worthwhile optimization to think through further.
> (Though experience says that Dave will explain how that can never work.)

Heh. :)

Two things, neither are show-stoppers but would need to be handled
in some way.

First: it would remove a lot of the policy flexibility from the
shrinker implementations that we currently have. i.e. the "work to
do" policy is current set by the shrinker, not by the shrinker
infrastructure. The shrinker infrastructure only determines whether
it can be done immediately of whether it shoul dbe deferred....

e.g. there are shrinkers that don't do work unless they are
over certain thresholds. For these shrinkers, they need to have the
work calculated by the callout as they may decide nothing
can/should/needs to be done, and that decision may have nothing to
do with the current reclaim context. You can't really do this
without a callout to determine the cache size.

The other thing I see is that deferring the ratio of work rather
than the actual work is that it doesn't take into account the fact
that the cache sizes might be changing in a different way to memory
pressure. i.e. a sudden increase in cache size just before deferred
reclaim occurred would cause much more reclaim than the current
code, even though the cache wasn't contributing to the original
deferred memory pressure.

This will lead to bursty/peaky reclaim behaviour because we then
can't distinguish an large instantenous change in memory pressure
from "wind up" caused by lots of small increments of deferred work.
We specifically damp the second case:

        /*
         * We need to avoid excessive windup on filesystem shrinkers
         * due to large numbers of GFP_NOFS allocations causing the
         * shrinkers to return -1 all the time. This results in a large
         * nr being built up so when a shrink that can do some work
         * comes along it empties the entire cache due to nr >>>
         * freeable. This is bad for sustaining a working set in
         * memory.
         *
         * Hence only allow the shrinker to scan the entire cache when
         * a large delta change is calculated directly.
         */

Hence we'd need a different mechanism to prevent such defered work
wind up from occurring. We can probably do better than the current
SWAG if we design a new algorithm that has this damping built in.
The current algorithm is all based around the "seek penalty"
reinstantiating a reclaimed object has, and that simply does not
match for many shrinker users now as they aren't spinning disk
based. Hence I think we really need to look at improving the entire
shrinker "work" algorithm rather than just tinkering around the
edges...

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
