Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 818326B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:58:33 -0400 (EDT)
Received: by wgez8 with SMTP id z8so31607999wge.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:58:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hn1si16869161wjc.69.2015.06.10.02.58.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 02:58:32 -0700 (PDT)
Date: Wed, 10 Jun 2015 10:58:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/4] mm: Send one IPI per CPU to TLB flush all entries
 after unmapping pages
Message-ID: <20150610095826.GD26425@suse.de>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-3-git-send-email-mgorman@suse.de>
 <20150610082640.GA24483@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150610082640.GA24483@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 10, 2015 at 10:26:40AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > On a 4-socket machine the results were
> > 
> >                                         4.1.0-rc6          4.1.0-rc6
> >                                     batchdirty-v6      batchunmap-v6
> > Ops lru-file-mmap-read-elapsed   121.27 (  0.00%)   118.79 (  2.05%)
> > 
> >            4.1.0-rc6      4.1.0-rc6
> >         batchdirty-v6 batchunmap-v6
> > User          620.84         608.48
> > System       4245.35        4152.89
> > Elapsed       122.65         120.15
> > 
> > In this case the workload completed faster and there was less CPU overhead
> > but as it's a NUMA machine there are a lot of factors at play. It's easier
> > to quantify on a single socket machine;
> > 
> >                                         4.1.0-rc6          4.1.0-rc6
> >                                     batchdirty-v6      batchunmap-v6
> > Ops lru-file-mmap-read-elapsed    20.35 (  0.00%)    21.52 ( -5.75%)
> > 
> >            4.1.0-rc6   4.1.0-rc6
> >         batchdirty-v6r5batchunmap-v6r5
> > User           58.02       60.70
> > System         77.57       81.92
> > Elapsed        22.14       23.16
> > 
> > That shows the workload takes 5.75% longer to complete with a similar
> > increase in the system CPU usage.
> 
> Btw., do you have any stddev noise numbers?
> 

                                           4.1.0-rc6          4.1.0-rc6          4.1.0-rc6          4.1.0-rc6
                                             vanilla     flushfull-v6r5    batchdirty-v6r5    batchunmap-v6r5
Ops lru-file-mmap-read-elapsed       25.43 (  0.00%)    20.59 ( 19.03%)    20.35 ( 19.98%)    21.52 ( 15.38%)
Ops lru-file-mmap-read-time_stddv     0.32 (  0.00%)     0.32 ( -1.30%)     0.39 (-23.00%)     0.45 (-40.91%)


flushfull  -- patch 2
batchdirty -- patch 3
batchunmap -- patch 4

So the impact of tracking the PFNs is outside the noise and there is
definite direct cost to it. This was expected for both the PFN tracking
and the individual flushes.

> The batching speedup is brutal enough to not need any noise estimations, it's a 
> clear winner.
> 

Agreed.

> But this PFN tracking patch is more difficult to judge as the numbers are pretty 
> close to each other.
> 

It's definitely measurable, no doubt about it and there never was. The
concerns were always the refill costs due to flushing potentially active
TLB entries unnecessarily. From https://lkml.org/lkml/2014/7/31/825, this
is potentially high where it says that a 512 DTLB refill takes 22,000
cycles which is higher than the individual flushes. However, this is an
estimate and it'll always be a case of "it depends". It's been asserted
that the refill costs are really low so lets just go with that, drop
patch 4 and wait and see who complains.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
