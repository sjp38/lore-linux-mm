Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C509A6B02B4
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 09:52:39 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id h47so86877665qta.12
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 06:52:39 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id 12si3472207qtf.152.2017.07.03.06.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 06:52:38 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id v143so11225614qkb.3
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 06:52:38 -0700 (PDT)
Date: Mon, 3 Jul 2017 09:52:37 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170703135236.GD27097@destiny>
References: <1496949546-2223-1-git-send-email-jbacik@fb.com>
 <20170613052802.GA16061@bbox>
 <20170613120156.GA16003@destiny>
 <20170614064045.GA19843@bbox>
 <20170619151120.GA11245@destiny>
 <20170620024645.GA27702@bbox>
 <20170627135931.GA14097@destiny>
 <20170630021713.GB24520@bbox>
 <20170630150322.GB9743@destiny>
 <20170702015843.GA17762@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170702015843.GA17762@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Josef Bacik <josef@toxicpanda.com>, Minchan Kim <minchan@kernel.org>, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, mhocko@kernel.org, cl@linux.com

On Sun, Jul 02, 2017 at 11:58:43AM +1000, Dave Chinner wrote:
> [I don't have the full context, haven't seen the proposed patches,
> etc so I'm only commenting on small bits of what I was cc'd on]
> 
> On Fri, Jun 30, 2017 at 11:03:24AM -0400, Josef Bacik wrote:
> > On Fri, Jun 30, 2017 at 11:17:13AM +0900, Minchan Kim wrote:
> > 
> > <snip>
> > 
> > > > 
> > > > Because this static step down wastes cycles.  Why loop 10 times when you could
> > > > set the target at actual usage and try to get everything in one go?  Most
> > > > shrinkable slabs adhere to this default of in use first model, which means that
> > > > we have to hit an object in the lru twice before it is freed.  So in order to
> > > 
> > > I didn't know that.
> > > 
> > > > reclaim anything we have to scan a slab cache's entire lru at least once before
> > > > any reclaim starts happening.  If we're doing this static step down thing we
> > > 
> > > If it's really true, I think that shrinker should be fixed first.
> > > 
> > 
> > Easier said than done.  I've fixed this for the super shrinkers, but like I said
> > below, all it takes is some asshole doing find / -exec stat {} \; twice to put
> > us back in the same situation again.  There's no aging mechanism other than
> > memory reclaim, so we get into this shitty situation of aging+reclaiming at the
> > same time.
> 
> To me, this sounds like the problem that needs fixing. i.e.
> threshold detection to trigger demand-based aging of shrinkable
> caches at allocation time rather than waiting for memory pressure to
> trigger aging.
> 
> > > I guess at the first time, all of objects in shrinker could be INUSE state
> > > as you said, however, on steady state, they would work like real LRU
> > > to reflect recency, otherwise, I want to call it broken and we shouldn't
> > > design general slab aging model for those specific one.
> > 
> > Yeah that's totally a valid argument to make, but the idea of coming up with
> > something completely different hurts my head, and I'm trying to fix this problem
> > right now, not in 6 cycles when we all finally agree on the new mechanism.
> 
> Add a shrinker callback to the slab allocation code that checks the
> rate of growth of the cache. If the cache is growing fast and
> getting large, run the shrinker every so often to slow down the rate
> of growth. The larger the cache, the slower the allowed rate of
> growth. It's the feedback loop that we are missing between slab
> allocation and slab reclaim that prevents use from controlling slab
> cache growthi and aging cleanly.
> 
> This would also allow us to cap the size of caching slabs easily
> - something people have been asking us to do for years....
> 
> Note: we need to make a clear distinction between slabs used as
> "heap" memory and slabs used for allocating large numbers of objects
> that are cached for performance reasons. The problem here is cache
> management - the fact we are using slabs to allocate the memory for
> the objects is largely irrelevant...
> 
> > > > I expanded on this above, but I'll give a more concrete example.  Consider xfs
> > > > metadata, we allocate a slab object and read in our page, use it, and then free
> > > > the buffer which put's it on the lru list.  XFS marks this with a INUSE flag,
> > > > which must be cleared before it is free'd from the LRU.  We scan through the
> > > > LRU, clearing the INUSE flag and moving the object to the back of the LRU, but
> > > > not actually free'ing it.  This happens for all (well most) objects that end up
> > > > on the LRU, and this design pattern is used _everywhere_.  Until recently it was
> > > > used for the super shrinkers, but I changed that so thankfully the bulk of the
> > > > problem is gone.  However if you do a find / -exec stat {} \;, and then do it
> > > > again, you'll end up with the same scenario for the super shrinker.   There's no
> > > > aging except via pressure on the slabs, so worst case we always have to scan the
> > > > entire slab object lru once before we start reclaiming anything.  Being
> > > > agressive here I think is ok, we have things in place to make sure we don't over
> > > > reclaim.
> > > 
> > > Thanks for the detail example. Now I understood but the question is it is
> > > always true? I mean at the first stage(ie, first population of objects), it
> > > seems to be but at the steady stage, I guess some of objects have INUSE,
> > > others not by access pattern so it emulates LRU model. No?
> > > 
> > 
> > Sort of.  Lets take icache/dcache.  We open a file and close a file, this get's
> > added to the LRU.  We open the file and close the file again, it's already on
> > the LRU so it stays where it was and gets the INUSE flag set.  Once an object is
> > on the LRU it doesn't move unless we hit it via the shrinker.  Even if we open
> > and close the file, and then open and keep it open, the file stays on the LRU,
> > and is only removed once the shrinker hits it, sees it's refcount is > 1, and
> > removes it from the list.
> 
> Yes, but  the lazy LRU removal is a performance feature - the cost
> in terms of lock contention of removing dentries inodes from the LRU
> on first reference is prohibitive, especially for short term usage
> like 'find / -exec stat {} \;' workloads. Git does this sort of
> traverse/stat a lot, so making this path any slower would make lots
> of people unhappy...
>

Sure we want it when it's useful, but often times it ends up in latencies due to
reclaim.  I like your aging thing, it would definitely help in our worst case,
I'll give that a whirl after my vacation.  Thanks,

Josef 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
