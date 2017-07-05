Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08CEB6B0292
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 00:59:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p1so151385190pfl.2
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 21:59:15 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 123si11621952pfb.63.2017.07.04.21.59.13
        for <linux-mm@kvack.org>;
        Tue, 04 Jul 2017 21:59:14 -0700 (PDT)
Date: Wed, 5 Jul 2017 13:59:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170705045912.GC20079@bbox>
References: <20170619151120.GA11245@destiny>
 <20170620024645.GA27702@bbox>
 <20170627135931.GA14097@destiny>
 <20170630021713.GB24520@bbox>
 <20170630150322.GB9743@destiny>
 <20170703013303.GA2567@bbox>
 <20170703135006.GC27097@destiny>
 <20170704030100.GA16432@bbox>
 <20170704132136.GB6807@destiny>
 <20170704225758.GT17542@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170704225758.GT17542@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, mhocko@kernel.org, cl@linux.com

Hi Dave,

On Wed, Jul 05, 2017 at 08:57:58AM +1000, Dave Chinner wrote:
> On Tue, Jul 04, 2017 at 09:21:37AM -0400, Josef Bacik wrote:
> > On Tue, Jul 04, 2017 at 12:01:00PM +0900, Minchan Kim wrote:
> > > 1. slab *page* reclaim
> > > 
> > > Your claim is that it's hard to reclaim a page by slab fragmentation so need to
> > > reclaim objects more aggressively.
> > > 
> > > Basically, aggressive scanning doesn't guarantee to reclaim a page but it just
> > > increases the possibility. Even, if we think slab works with merging feature(i.e.,
> > > it mixes same size several type objects in a slab), the possibility will be huge
> > > dropped if you try to bail out on a certain shrinker. So for working well,
> > > we should increase aggressiveness too much to sweep every objects from all shrinker.
> > > I guess that's why your patch makes the logic very aggressive.
> > > In here, my concern with that aggressive is to reclaim all objects too early
> > > and it ends up making void caching scheme. I'm not sure it's gain in the end.
> > >
> > 
> > Well the fact is what we have doesn't work, and I've been staring at this
> > problem for a few months and I don't have a better solution.
> > 
> > And keep in mind we're talking about a purely slab workload, something that
> > isn't likely to be a common case.  And even if our scan target is 2x, we aren't
> > going to reclaim the entire cache before we bail out.  We only scan in
> > 'batch_size' chunks, which generally is 1024.  In the worst case that we have
> > one in use object on every slab page we own then yes we're fucked, but we're
> > still fucked with the current code, only with the current code it'll take us 20
> > minutes of looping in the vm vs. seconds scanning the whole list twice.
> 
> Right - this is where growth/allocation rate based aging scans
> come into play, rather than waiting for the VM to hit some unknown
> ceiling and do an unpredictable amount of scanning.

http://www.spinics.net/lists/linux-mm/msg129470.html

I suggested static scanning increasement(1/12 + 2/12 + 3/12...) which is
more aggressive compared to as-is. With this, in a reclaim cycle(priority
12..0), we guarantees that scanning of entire objects list four times
while LRU is two times. Although I believe we don't need four times
(i.e., it's enough with two times), it's just compromise solution with
Josef's much too agressive slab reclaim.
It would be more predictable and aggressive from VM point of view.

If some of shrinker cannot be happy with this policy, it would accelerate
the scanning for only that shrinker under shrink_slab call although I don't
like it because it's out of control from VM pov so I'm okay your per-shrinker
aging callback regardless of shrink_slab. My point is if some of shrinker is
painful to be reclaimed, it should have own model to solve it rather than
making general slab reclaim strately very aggressive.

However, Josef's current approach changes slab scanning aggressive
by using SLAB/LRU ratio(please, see his patchset 3/4) and bail out until
sc->nr_to_reclaim is meet. To me, it's too much aggressive and breaks fair
aging between shrinkers.

> 
> > > 2. stream-workload
> > > 
> > > Your claim is that every objects can have INUSE flag in that workload so they
> > > need to scan full-cycle with removing the flag and finally, next cycle,
> > > objects can be reclaimed. On the situation, static incremental scanning would
> > > make deep prorioty drop which causes unncessary CPU cycle waste.
> > > 
> > > Actually, there isn't nice solution for that at the moment. Page cache try
> > > to solve it with multi-level LRU and as you said, it would solve the
> > > problem. However, it would be too complicated so you could be okay with
> > > Dave's suggestion which periodic aging(i.e., LFU) but it's not free so that
> > > it could increase runtime latency.
> > > 
> > > The point is that such workload is hard to solve in general and just
> > > general agreessive scanning is not a good solution because it can sweep
> > > other shrinkers which don't have such problem so I hope it should be
> > > solved by a specific shrinker itself rather than general VM level.
> > 
> > The only problem I see here is our shrinker list is just a list, there's no
> > order or anything and we just walk through one at a time.
> 
> That's because we don't really need an ordered list - all shrinkable
> caches needed to have the same amount of work done on them for a
> given memory pressure. That's how we maintain balance between
> caches.

True.

> 
> > We could mitigate
> > this problem by ordering the list based on objects, but this isn't necessarily a
> > good indication of overall size.
> 
> shrinkers don't just run on caches, and some of the this they run
> against have variable object size. Some of them report reclaimable
> memory in bytes rather than object counts to the shrinker
> infrastructure.  i.e. the shrinker infrastrcture is abstracted
> sufficiently that the accounting of memory used/reclaimed is defined
> by the individual subsystems, not the shrinker infrastructure....
> 
> > Consider xfs_buf, where each slab object is also hiding 1 page, so
> > for every slab object we free we also free 1 page.
> 
> Well, that's a very simplistic view - there are objects that hold a
> page, but it's a variable size object cache. an xfs-buf can point to
> heap memory or multiple pages.
> 
> IOWs, the xfs-buf is not a *slab cache*. It's a *buffer cache*, but
> we control it's size via a shrinker because that's the only
> mechanism we have that provides subsystems with memory pressure
> callbacks. This is a clear example of what I said above about
> shrinkers being much more than just a mechanism to control the size
> of a slab...
> 
> > This may
> > appear to be a smaller slab by object measures, but may actually
> > be larger.
> 
> Right, but that's for the subsystem to sort out the working set
> balance against all the other caches - the shrinker infrastructure
> cannot determine how important different subsystems are relative to
> each other, so memory reclaim must try to do the same percentage of
> reclaim work across all of them so that everything remains globally
> balanced.

True.

> 
> My original plan years ago was to make the shrinker infrastructure
> API work on "bytes" rather than "subsystem defined objects", but
> there were so many broken shrinkers I burnt out before I got that
> far....
> 
> My suggestion of allocation based aging callbacks is something for
> specific caches to be able to run based on their own or the users
> size/growth/performance constraints. It's independent of memory
> reclaim behaviour and so can be a strongly biased as the user wants.
> Memory reclaim will just maintain whatever balance that exists
> between the different caches as a result of the subsystem specific
> aging callbacks.

Absolutely agree.

> 
> > We could definitely make this aspect of the shrinker
> > smarter, but these patches here need to still be in place in
> > general to solve the problem of us not being aggressive enough
> > currently.  Thanks,
> 
> Remember that the shrinker callback into a subsystem is just a
> mechanism for scanning a subsystem's reclaim list and performing
> reclaim. We're not limited to only calling them from
> do_shrink_slab() - a historic name that doesn't reflect the reality
> of shrinkers these days - if we have a superblock, we can call the
> shrinker....
> 
> FWIW, we have per-object init callbacks in the slab infrastructure -
> ever thought of maybe using them for controlling cache aging
> behaviour? e.g. accounting to trigger background aging scans...
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
