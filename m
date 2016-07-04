Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 571FC6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 05:55:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so63087629wma.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 02:55:13 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id k66si558625wmb.105.2016.07.04.02.55.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jul 2016 02:55:12 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id A8E5199012
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 09:55:11 +0000 (UTC)
Date: Mon, 4 Jul 2016 10:55:09 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/31] Move LRU page reclaim from zones to nodes v8
Message-ID: <20160704095509.GC11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <20160704013703.GA19943@bbox>
 <20160704043405.GB11498@techsingularity.net>
 <20160704080412.GA24605@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160704080412.GA24605@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, daniel.vetter@intel.com, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>

On Mon, Jul 04, 2016 at 05:04:12PM +0900, Minchan Kim wrote:
> > > How big ratio between highmem:lowmem do you think a problem?
> > > 
> > 
> > That's a "how long is a piece of string" type question.  The ratio does
> > not matter as much as whether the workload is both under memory pressure
> > and requires large amounts of lowmem pages. Even on systems with very high
> > ratios, it may not be a problem if HIGHPTE is enabled.
> 
> As well page table, pgd/kernelstack/zbud/slab and so on, every kernel
> allocations wanted to mask __GFP_HIGHMEM off would be a problem in
> 32bit system.
> 

The same point applies -- it depends on the rate of these allocations,
not the ratio of highmem:lowmem per se.

> It also depends on that how many drivers needed lowmem only we have
> in the system.
> 
> I don't know how many such driver in the world. When I simply do grep,
> I found several cases which mask __GFP_HIGHMEM off and among them,
> I guess DRM might be a popular for us. However, it might be really rare
> usecase among various i915 usecases.
> 

It's also perfectly possible that such allocations are long-lived in which
case they are not going to cause many skips. Hence why I cannot make a
general prediction.

> > > > Conceptually, moving to node LRUs should be easier to understand. The
> > > > page allocator plays fewer tricks to game reclaim and reclaim behaves
> > > > similarly on all nodes. 
> > > > 
> > > > The series has been tested on a 16 core UMA machine and a 2-socket 48
> > > > core NUMA machine. The UMA results are presented in most cases as the NUMA
> > > > machine behaved similarly.
> > > 
> > > I guess you would already test below with various highmem system(e.g.,
> > > 2:1, 3:1, 4:1 and so on). If you have, could you mind sharing it?
> > > 
> > 
> > I haven't that data, the baseline distribution used doesn't even have
> > 32-bit support. Even if it was, the results may not be that interesting.
> > The workloads used were not necessarily going to trigger lowmem pressure
> > as HIGHPTE was set on the 32-bit configs.
> 
> That means we didn't test this on 32-bit with highmem.
> 

No. I tested the skip logic and noticed that when forced on purpose that
system CPU usage was higher but it functionally worked.

> I'm not sure it's really too rare case to spend a time for testing.
> In fact, I really want to test all series to our production system
> which is 32bit and highmem but as we know well, most of embedded
> system kernel is rather old so backporting needs lots of time and
> care. However, if we miss testing in those system at the moment,
> we will be suprised after 1~2 years.
> 

It would be appreciated if it could be tested on such platforms if at all
possible. Even if I did set up a 32-bit x86 system, it won't have the same
allocation/reclaim profile as the platforms you are considering.

> I don't know what kinds of benchmark can we can check it so I cannot
> insist on it but you might know it.
> 

One method would be to use fsmark with very large numbers of small files
to force slab to require low memory. It's not representative of many real
workloads unfortunately. Usually such a configuration is for checking the
slab shrinker is working as expected.

> Okay, do you have any idea to fix it if we see such regression report
> in 32-bit system in future?

Two options, neither whose complexity is justified without a "real"
workload to use as a reference.

1. Long-term isolation of highmem pages when reclaim is lowmem

   When pages are skipped, they are immediately added back onto the LRU
   list. If lowmem reclaim persisted for long periods of time, the same
   highmem pages get continually scanned. The idea would be that lowmem
   keeps those pages on a separate list until a reclaim for highmem pages
   arrives that splices the highmem pages back onto the LRU.

   That would reduce the skip rate, the potential corner case is that
   highmem pages have to be scanned and reclaimed to free lowmem slab pages.

2. Linear scan lowmem pages if the initial LRU shrink fails

   This will break LRU ordering but may be preferable and faster during
   memory pressure than skipping LRU pages.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
