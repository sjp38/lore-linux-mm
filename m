Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF656B007E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:08:43 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l15so68402835lfg.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 06:08:43 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id s3si7800419wmd.50.2016.04.15.06.08.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 06:08:41 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id F11471C1FC9
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 14:08:40 +0100 (IST)
Date: Fri, 15 Apr 2016 14:08:39 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/28] Optimise page alloc/free fast paths v3
Message-ID: <20160415130839.GF32073@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <20160415144402.5fbe7a1e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160415144402.5fbe7a1e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On Fri, Apr 15, 2016 at 02:44:02PM +0200, Jesper Dangaard Brouer wrote:
> On Fri, 15 Apr 2016 09:58:52 +0100
> Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > There were no further responses to the last series but I kept going and
> > added a few more small bits. Most are basic micro-optimisations.  The last
> > two patches weaken debugging checks to improve performance at the cost of
> > delayed detection of some use-after-free and memory corruption bugs. If
> > they make people uncomfortable, they can be dropped and the rest of the
> > series stands on its own.
> > 
> > Changelog since v2
> > o Add more micro-optimisations
> > o Weak debugging checks in favor of speed
> > 
> [...]
> > 
> > The overall impact on a page allocator microbenchmark for a range of orders
> 
> I also micro benchmarked this patchset.  Avail via Mel Gorman's kernel tree:
>  http://git.kernel.org/cgit/linux/kernel/git/mel/linux.git
> tested branch mm-vmscan-node-lru-v5r9 which also contain the node-lru series.
> 
> Tool:
>  https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench01.c
> Run as:
>  modprobe page_bench01; rmmod page_bench01 ; dmesg | tail -n40 | grep 'alloc_pages order'
> 

Thanks Jesper.

> Results kernel 4.6.0-rc1 :
> 
>  alloc_pages order:0(4096B/x1) 272 cycles per-4096B 272 cycles
>  alloc_pages order:1(8192B/x2) 395 cycles per-4096B 197 cycles
>  alloc_pages order:2(16384B/x4) 433 cycles per-4096B 108 cycles
>  alloc_pages order:3(32768B/x8) 503 cycles per-4096B 62 cycles
>  alloc_pages order:4(65536B/x16) 682 cycles per-4096B 42 cycles
>  alloc_pages order:5(131072B/x32) 910 cycles per-4096B 28 cycles
>  alloc_pages order:6(262144B/x64) 1384 cycles per-4096B 21 cycles
>  alloc_pages order:7(524288B/x128) 2335 cycles per-4096B 18 cycles
>  alloc_pages order:8(1048576B/x256) 4108 cycles per-4096B 16 cycles
>  alloc_pages order:9(2097152B/x512) 8398 cycles per-4096B 16 cycles
> 
> After Mel Gorman's optimizations, results from mm-vmscan-node-lru-v5r::
> 
>  alloc_pages order:0(4096B/x1) 231 cycles per-4096B 231 cycles
>  alloc_pages order:1(8192B/x2) 351 cycles per-4096B 175 cycles
>  alloc_pages order:2(16384B/x4) 357 cycles per-4096B 89 cycles
>  alloc_pages order:3(32768B/x8) 397 cycles per-4096B 49 cycles
>  alloc_pages order:4(65536B/x16) 481 cycles per-4096B 30 cycles
>  alloc_pages order:5(131072B/x32) 652 cycles per-4096B 20 cycles
>  alloc_pages order:6(262144B/x64) 1054 cycles per-4096B 16 cycles
>  alloc_pages order:7(524288B/x128) 1852 cycles per-4096B 14 cycles
>  alloc_pages order:8(1048576B/x256) 3156 cycles per-4096B 12 cycles
>  alloc_pages order:9(2097152B/x512) 6790 cycles per-4096B 13 cycles
> 

This is broadly in line with expectations. order-0 sees the biggest
boost because that's what the series focused on. High-order allocations
see some benefits but they're still going through the slower paths of
the allocator so it's less obvious.

I'm glad to see this independently verified.

> 
> I've also started doing some parallel concurrency testing workloads[1]
>  [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench03.c
> 
> Order-0 pages scale nicely:
> 
> Results kernel 4.6.0-rc1 :
>  Parallel-CPUs:1 page order:0(4096B/x1) ave 274 cycles per-4096B 274 cycles
>  Parallel-CPUs:2 page order:0(4096B/x1) ave 283 cycles per-4096B 283 cycles
>  Parallel-CPUs:3 page order:0(4096B/x1) ave 284 cycles per-4096B 284 cycles
>  Parallel-CPUs:4 page order:0(4096B/x1) ave 288 cycles per-4096B 288 cycles
>  Parallel-CPUs:5 page order:0(4096B/x1) ave 417 cycles per-4096B 417 cycles
>  Parallel-CPUs:6 page order:0(4096B/x1) ave 503 cycles per-4096B 503 cycles
>  Parallel-CPUs:7 page order:0(4096B/x1) ave 567 cycles per-4096B 567 cycles
>  Parallel-CPUs:8 page order:0(4096B/x1) ave 620 cycles per-4096B 620 cycles
> 
> And even better with you changes! :-))) This is great work!
> 
> Results from mm-vmscan-node-lru-v5r:
>  Parallel-CPUs:1 page order:0(4096B/x1) ave 246 cycles per-4096B 246 cycles
>  Parallel-CPUs:2 page order:0(4096B/x1) ave 251 cycles per-4096B 251 cycles
>  Parallel-CPUs:3 page order:0(4096B/x1) ave 254 cycles per-4096B 254 cycles
>  Parallel-CPUs:4 page order:0(4096B/x1) ave 258 cycles per-4096B 258 cycles
>  Parallel-CPUs:5 page order:0(4096B/x1) ave 313 cycles per-4096B 313 cycles
>  Parallel-CPUs:6 page order:0(4096B/x1) ave 369 cycles per-4096B 369 cycles
>  Parallel-CPUs:7 page order:0(4096B/x1) ave 379 cycles per-4096B 379 cycles
>  Parallel-CPUs:8 page order:0(4096B/x1) ave 399 cycles per-4096B 399 cycles
> 

Excellent, thanks!

> 
> It does not seem that higher order page scale... and your patches does
> not change this pattern.
> 
> Example order-3 pages, which is often used in the network stack:
> 

Unfortunately, this lack of scaling is expected. All the high-order
allocations bypass the per-cpu allocator so multiple parallel requests
will contend on the zone->lock. Technically, the per-cpu allocator could
handle high-order pages but failures would require IPIs to drain the
remote lists and the memory footprint would be high. Whatever about the
memory footprint, sending IPIs on every allocation failure is going to
cause undesirable latency spikes.

The original design of the per-cpu allocator assumed that high-order
allocations were rare. This expectation is partially violated by SLUB
using high-order pages, the network layer using compound pages and also
by the test case unfortunately.

I'll put some thought into how it could be improved on the flight over to
LSF/MM but right now, I'm not very optimistic that a solution will be simple.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
