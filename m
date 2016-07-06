Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C268828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 21:52:23 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id he1so426713162pac.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 18:52:23 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 2si1237096pfu.115.2016.07.05.18.52.21
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 18:52:22 -0700 (PDT)
Date: Wed, 6 Jul 2016 10:51:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 00/31] Move LRU page reclaim from zones to nodes v8
Message-ID: <20160706015143.GE12570@bbox>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <20160704013703.GA19943@bbox>
 <20160704043405.GB11498@techsingularity.net>
 <20160704080412.GA24605@bbox>
 <20160704095509.GC11498@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <20160704095509.GC11498@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, daniel.vetter@intel.com, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>

On Mon, Jul 04, 2016 at 10:55:09AM +0100, Mel Gorman wrote:
> On Mon, Jul 04, 2016 at 05:04:12PM +0900, Minchan Kim wrote:
> > > > How big ratio between highmem:lowmem do you think a problem?
> > > > 
> > > 
> > > That's a "how long is a piece of string" type question.  The ratio does
> > > not matter as much as whether the workload is both under memory pressure
> > > and requires large amounts of lowmem pages. Even on systems with very high
> > > ratios, it may not be a problem if HIGHPTE is enabled.
> > 
> > As well page table, pgd/kernelstack/zbud/slab and so on, every kernel
> > allocations wanted to mask __GFP_HIGHMEM off would be a problem in
> > 32bit system.
> > 
> 
> The same point applies -- it depends on the rate of these allocations,
> not the ratio of highmem:lowmem per se.
> 
> > It also depends on that how many drivers needed lowmem only we have
> > in the system.
> > 
> > I don't know how many such driver in the world. When I simply do grep,
> > I found several cases which mask __GFP_HIGHMEM off and among them,
> > I guess DRM might be a popular for us. However, it might be really rare
> > usecase among various i915 usecases.
> > 
> 
> It's also perfectly possible that such allocations are long-lived in which
> case they are not going to cause many skips. Hence why I cannot make a
> general prediction.
> 
> > > > > Conceptually, moving to node LRUs should be easier to understand. The
> > > > > page allocator plays fewer tricks to game reclaim and reclaim behaves
> > > > > similarly on all nodes. 
> > > > > 
> > > > > The series has been tested on a 16 core UMA machine and a 2-socket 48
> > > > > core NUMA machine. The UMA results are presented in most cases as the NUMA
> > > > > machine behaved similarly.
> > > > 
> > > > I guess you would already test below with various highmem system(e.g.,
> > > > 2:1, 3:1, 4:1 and so on). If you have, could you mind sharing it?
> > > > 
> > > 
> > > I haven't that data, the baseline distribution used doesn't even have
> > > 32-bit support. Even if it was, the results may not be that interesting.
> > > The workloads used were not necessarily going to trigger lowmem pressure
> > > as HIGHPTE was set on the 32-bit configs.
> > 
> > That means we didn't test this on 32-bit with highmem.
> > 
> 
> No. I tested the skip logic and noticed that when forced on purpose that
> system CPU usage was higher but it functionally worked.

Yeb, it would work well functionally. I meant not functionally but
performance point of view, system cpu usage and majfault rate
and so on.

> 
> > I'm not sure it's really too rare case to spend a time for testing.
> > In fact, I really want to test all series to our production system
> > which is 32bit and highmem but as we know well, most of embedded
> > system kernel is rather old so backporting needs lots of time and
> > care. However, if we miss testing in those system at the moment,
> > we will be suprised after 1~2 years.
> > 
> 
> It would be appreciated if it could be tested on such platforms if at all
> possible. Even if I did set up a 32-bit x86 system, it won't have the same
> allocation/reclaim profile as the platforms you are considering.

Yeb. I just finished reviewing of all patches and found no *big* problem
with my brain so my remanining homework is just testing which would find
what my brain have missed.

I will give the backporing to old 32-bit production kernel a shot and
report if something strange happens.

Thanks for great work, Mel!


> 
> > I don't know what kinds of benchmark can we can check it so I cannot
> > insist on it but you might know it.
> > 
> 
> One method would be to use fsmark with very large numbers of small files
> to force slab to require low memory. It's not representative of many real
> workloads unfortunately. Usually such a configuration is for checking the
> slab shrinker is working as expected.

Thanks for the suggestion.

> 
> > Okay, do you have any idea to fix it if we see such regression report
> > in 32-bit system in future?
> 
> Two options, neither whose complexity is justified without a "real"
> workload to use as a reference.
> 
> 1. Long-term isolation of highmem pages when reclaim is lowmem
> 
>    When pages are skipped, they are immediately added back onto the LRU
>    list. If lowmem reclaim persisted for long periods of time, the same
>    highmem pages get continually scanned. The idea would be that lowmem
>    keeps those pages on a separate list until a reclaim for highmem pages
>    arrives that splices the highmem pages back onto the LRU.
> 
>    That would reduce the skip rate, the potential corner case is that
>    highmem pages have to be scanned and reclaimed to free lowmem slab pages.
> 
> 2. Linear scan lowmem pages if the initial LRU shrink fails
> 
>    This will break LRU ordering but may be preferable and faster during
>    memory pressure than skipping LRU pages.

Okay. I guess it would be better to include this in descripion of [4/31].

> 
> -- 
> Mel Gorman
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
