Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C95206B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 04:05:24 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g8so180007297itb.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 01:05:24 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id b188si9596ite.101.2016.07.04.01.05.23
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 01:05:24 -0700 (PDT)
Date: Mon, 4 Jul 2016 17:04:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 00/31] Move LRU page reclaim from zones to nodes v8
Message-ID: <20160704080412.GA24605@bbox>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <20160704013703.GA19943@bbox>
 <20160704043405.GB11498@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <20160704043405.GB11498@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, daniel.vetter@intel.com, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>

On Mon, Jul 04, 2016 at 05:34:05AM +0100, Mel Gorman wrote:
> On Mon, Jul 04, 2016 at 10:37:03AM +0900, Minchan Kim wrote:
> > > The reason we have zone-based reclaim is that we used to have
> > > large highmem zones in common configurations and it was necessary
> > > to quickly find ZONE_NORMAL pages for reclaim. Today, this is much
> > > less of a concern as machines with lots of memory will (or should) use
> > > 64-bit kernels. Combinations of 32-bit hardware and 64-bit hardware are
> > > rare. Machines that do use highmem should have relatively low highmem:lowmem
> > > ratios than we worried about in the past.
> > 
> > Hello Mel,
> > 
> > I agree the direction absolutely. However, I have a concern on highmem
> > system as you already mentioned.
> > 
> > Embedded products still use 2 ~ 3 ratio (highmem:lowmem).
> > In such system, LRU churning by skipping other zone pages frequently
> > might be significant for the performance.
> > 
> > How big ratio between highmem:lowmem do you think a problem?
> > 
> 
> That's a "how long is a piece of string" type question.  The ratio does
> not matter as much as whether the workload is both under memory pressure
> and requires large amounts of lowmem pages. Even on systems with very high
> ratios, it may not be a problem if HIGHPTE is enabled.

As well page table, pgd/kernelstack/zbud/slab and so on, every kernel
allocations wanted to mask __GFP_HIGHMEM off would be a problem in
32bit system.

It also depends on that how many drivers needed lowmem only we have
in the system.

I don't know how many such driver in the world. When I simply do grep,
I found several cases which mask __GFP_HIGHMEM off and among them,
I guess DRM might be a popular for us. However, it might be really rare
usecase among various i915 usecases.

> 
> > > 
> > > Conceptually, moving to node LRUs should be easier to understand. The
> > > page allocator plays fewer tricks to game reclaim and reclaim behaves
> > > similarly on all nodes. 
> > > 
> > > The series has been tested on a 16 core UMA machine and a 2-socket 48
> > > core NUMA machine. The UMA results are presented in most cases as the NUMA
> > > machine behaved similarly.
> > 
> > I guess you would already test below with various highmem system(e.g.,
> > 2:1, 3:1, 4:1 and so on). If you have, could you mind sharing it?
> > 
> 
> I haven't that data, the baseline distribution used doesn't even have
> 32-bit support. Even if it was, the results may not be that interesting.
> The workloads used were not necessarily going to trigger lowmem pressure
> as HIGHPTE was set on the 32-bit configs.

That means we didn't test this on 32-bit with highmem.

I'm not sure it's really too rare case to spend a time for testing.
In fact, I really want to test all series to our production system
which is 32bit and highmem but as we know well, most of embedded
system kernel is rather old so backporting needs lots of time and
care. However, if we miss testing in those system at the moment,
we will be suprised after 1~2 years.

I don't know what kinds of benchmark can we can check it so I cannot
insist on it but you might know it.

Okay, do you have any idea to fix it if we see such regression report
in 32-bit system in future?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
