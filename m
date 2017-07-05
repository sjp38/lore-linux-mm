Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 180B96B037C
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 09:33:49 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n42so13940857qtn.10
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 06:33:49 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id d191si20584668qkb.226.2017.07.05.06.33.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 06:33:47 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id m54so28073539qtb.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 06:33:47 -0700 (PDT)
Date: Wed, 5 Jul 2017 09:33:45 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170705133344.GB16179@destiny>
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
Cc: Josef Bacik <josef@toxicpanda.com>, Minchan Kim <minchan@kernel.org>, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, mhocko@kernel.org, cl@linux.com

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
> 
> My original plan years ago was to make the shrinker infrastructure
> API work on "bytes" rather than "subsystem defined objects", but
> there were so many broken shrinkers I burnt out before I got that
> far....
> 

Ha I ran into the same problem.  The device-mapper ones were particularly
tricky.  This would make it easier for the vm to be fairer, so maybe I just need
to suck it up and do this work.

> My suggestion of allocation based aging callbacks is something for
> specific caches to be able to run based on their own or the users
> size/growth/performance constraints. It's independent of memory
> reclaim behaviour and so can be a strongly biased as the user wants.
> Memory reclaim will just maintain whatever balance that exists
> between the different caches as a result of the subsystem specific
> aging callbacks.
> 

Ok so how does a scheme like this look?  The shrinking stuff can be relatively
heavy because generally speaking it's always run asynchronously by kswapd, so
the only latency it induces to normal workloads is the CPU time it takes away
from processes we care about.

With an aging callback at allocation time we're inducing latency for the user at
allocation time.  So we want to do as little as possible here, but what do we
need to determine if there's something to do?  Do we just have a static "I'm
over limit X objects, start a worker thread to check if we need to reclaim"?  Or
do we have it be actually smart, checking the overall count and checking it
against some configurable growth rate?  That's going to be expensive on a per
allocation basis.

I'm having a hard time envisioning how this works that doesn't induce a bunch of
latency.

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

I suppose we could keep track of how often we're allocating pages per slab cache
that has a shrinker, and use that as a basis for when to kick off background
aging.  I'm fixing to go on vacation for a few days, I'll think about this some
more and come up with something when I get home next week.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
