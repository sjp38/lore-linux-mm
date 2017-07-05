Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3AA8680FED
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 19:30:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 1so4020589pfi.14
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 16:30:11 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id x2si226794pfa.400.2017.07.05.16.30.09
        for <linux-mm@kvack.org>;
        Wed, 05 Jul 2017 16:30:10 -0700 (PDT)
Date: Thu, 6 Jul 2017 09:30:06 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170705233006.GU17542@dastard>
References: <20170620024645.GA27702@bbox>
 <20170627135931.GA14097@destiny>
 <20170630021713.GB24520@bbox>
 <20170630150322.GB9743@destiny>
 <20170703013303.GA2567@bbox>
 <20170703135006.GC27097@destiny>
 <20170704030100.GA16432@bbox>
 <20170704132136.GB6807@destiny>
 <20170704225758.GT17542@dastard>
 <20170705133344.GB16179@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170705133344.GB16179@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Minchan Kim <minchan@kernel.org>, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, mhocko@kernel.org, cl@linux.com

On Wed, Jul 05, 2017 at 09:33:45AM -0400, Josef Bacik wrote:
> On Wed, Jul 05, 2017 at 08:57:58AM +1000, Dave Chinner wrote:
> > My suggestion of allocation based aging callbacks is something for
> > specific caches to be able to run based on their own or the users
> > size/growth/performance constraints. It's independent of memory
> > reclaim behaviour and so can be a strongly biased as the user wants.
> > Memory reclaim will just maintain whatever balance that exists
> > between the different caches as a result of the subsystem specific
> > aging callbacks.
> > 
> 
> Ok so how does a scheme like this look?  The shrinking stuff can be relatively
> heavy because generally speaking it's always run asynchronously by kswapd, so
> the only latency it induces to normal workloads is the CPU time it takes away
> from processes we care about.
> 
> With an aging callback at allocation time we're inducing latency for the user at
> allocation time.  So we want to do as little as possible here, but what do we
> need to determine if there's something to do?  Do we just have a static "I'm
> over limit X objects, start a worker thread to check if we need to reclaim"?  Or
> do we have it be actually smart, checking the overall count and checking it
> against some configurable growth rate?  That's going to be expensive on a per
> allocation basis.
> 
> I'm having a hard time envisioning how this works that doesn't induce a bunch of
> latency.

I was thinking the aging would also be async, like kswapd, and the
only thing the allocation does is accounting. THe actual aging scans
don't need to be done in the foreground and get the in way of the
current allocation because aging doesn't need precise control or
behaviour...

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
