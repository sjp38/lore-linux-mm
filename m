Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD1F66B025E
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 09:20:29 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id t184so315984147qkd.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 06:20:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f9si35334988qki.259.2017.01.04.06.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 06:20:29 -0800 (PST)
Date: Wed, 4 Jan 2017 15:20:24 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 3/4] mm, page_allocator: Only use per-cpu allocator for
 irq-safe requests
Message-ID: <20170104152024.7e050b84@redhat.com>
In-Reply-To: <20170104111049.15501-4-mgorman@techsingularity.net>
References: <20170104111049.15501-1-mgorman@techsingularity.net>
	<20170104111049.15501-4-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, brouer@redhat.com

On Wed,  4 Jan 2017 11:10:48 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> Many workloads that allocate pages are not handling an interrupt at a
> time. As allocation requests may be from IRQ context, it's necessary to
> disable/enable IRQs for every page allocation. This cost is the bulk
> of the free path but also a significant percentage of the allocation
> path.
> 
> This patch alters the locking and checks such that only irq-safe allocation
> requests use the per-cpu allocator. All others acquire the irq-safe
> zone->lock and allocate from the buddy allocator. It relies on disabling
> preemption to safely access the per-cpu structures. 

I love this idea and patch :-)

> It could be slightly
> modified to avoid soft IRQs using it but it's not clear it's worthwhile.

NICs usually refill their RX-ring from SoftIRQ context (NAPI).
Thus, we do want this optimization to work in softirq.

 
> This modification may slow allocations from IRQ context slightly but the main
> gain from the per-cpu allocator is that it scales better for allocations
> from multiple contexts. There is an implicit assumption that intensive
> allocations from IRQ contexts on multiple CPUs from a single NUMA node are
> rare and that the fast majority of scaling issues are encountered in !IRQ
> contexts such as page faulting. 

IHMO, I agree with this implicit assumption.


> It's worth noting that this patch is not
> required for a bulk page allocator but it significantly reduces the overhead.
> 
> The following is results from a page allocator micro-benchmark. Only
> order-0 is interesting as higher orders do not use the per-cpu allocator

I'm seeing approx 34% reduction in a order-0 micro-benchmark! amazing! :-)
[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/

>                                           4.10.0-rc2                 4.10.0-rc2
>                                              vanilla               irqsafe-v1r5
> Amean    alloc-odr0-1               287.15 (  0.00%)           219.00 ( 23.73%)
> Amean    alloc-odr0-2               221.23 (  0.00%)           183.23 ( 17.18%)
> Amean    alloc-odr0-4               187.00 (  0.00%)           151.38 ( 19.05%)
> Amean    alloc-odr0-8               167.54 (  0.00%)           132.77 ( 20.75%)
> Amean    alloc-odr0-16              156.00 (  0.00%)           123.00 ( 21.15%)
> Amean    alloc-odr0-32              149.00 (  0.00%)           118.31 ( 20.60%)
> Amean    alloc-odr0-64              138.77 (  0.00%)           116.00 ( 16.41%)
> Amean    alloc-odr0-128             145.00 (  0.00%)           118.00 ( 18.62%)
> Amean    alloc-odr0-256             136.15 (  0.00%)           125.00 (  8.19%)
> Amean    alloc-odr0-512             147.92 (  0.00%)           121.77 ( 17.68%)
> Amean    alloc-odr0-1024            147.23 (  0.00%)           126.15 ( 14.32%)
> Amean    alloc-odr0-2048            155.15 (  0.00%)           129.92 ( 16.26%)
> Amean    alloc-odr0-4096            164.00 (  0.00%)           136.77 ( 16.60%)
> Amean    alloc-odr0-8192            166.92 (  0.00%)           138.08 ( 17.28%)
> Amean    alloc-odr0-16384           159.00 (  0.00%)           138.00 ( 13.21%)
> Amean    free-odr0-1                165.00 (  0.00%)            89.00 ( 46.06%)
> Amean    free-odr0-2                113.00 (  0.00%)            63.00 ( 44.25%)
> Amean    free-odr0-4                 99.00 (  0.00%)            54.00 ( 45.45%)
> Amean    free-odr0-8                 88.00 (  0.00%)            47.38 ( 46.15%)
> Amean    free-odr0-16                83.00 (  0.00%)            46.00 ( 44.58%)
> Amean    free-odr0-32                80.00 (  0.00%)            44.38 ( 44.52%)
> Amean    free-odr0-64                72.62 (  0.00%)            43.00 ( 40.78%)
> Amean    free-odr0-128               78.00 (  0.00%)            42.00 ( 46.15%)
> Amean    free-odr0-256               80.46 (  0.00%)            57.00 ( 29.16%)
> Amean    free-odr0-512               96.38 (  0.00%)            64.69 ( 32.88%)
> Amean    free-odr0-1024             107.31 (  0.00%)            72.54 ( 32.40%)
> Amean    free-odr0-2048             108.92 (  0.00%)            78.08 ( 28.32%)
> Amean    free-odr0-4096             113.38 (  0.00%)            82.23 ( 27.48%)
> Amean    free-odr0-8192             112.08 (  0.00%)            82.85 ( 26.08%)
> Amean    free-odr0-16384            110.38 (  0.00%)            81.92 ( 25.78%)
> Amean    total-odr0-1               452.15 (  0.00%)           308.00 ( 31.88%)
> Amean    total-odr0-2               334.23 (  0.00%)           246.23 ( 26.33%)
> Amean    total-odr0-4               286.00 (  0.00%)           205.38 ( 28.19%)
> Amean    total-odr0-8               255.54 (  0.00%)           180.15 ( 29.50%)
> Amean    total-odr0-16              239.00 (  0.00%)           169.00 ( 29.29%)
> Amean    total-odr0-32              229.00 (  0.00%)           162.69 ( 28.96%)
> Amean    total-odr0-64              211.38 (  0.00%)           159.00 ( 24.78%)
> Amean    total-odr0-128             223.00 (  0.00%)           160.00 ( 28.25%)
> Amean    total-odr0-256             216.62 (  0.00%)           182.00 ( 15.98%)
> Amean    total-odr0-512             244.31 (  0.00%)           186.46 ( 23.68%)
> Amean    total-odr0-1024            254.54 (  0.00%)           198.69 ( 21.94%)
> Amean    total-odr0-2048            264.08 (  0.00%)           208.00 ( 21.24%)
> Amean    total-odr0-4096            277.38 (  0.00%)           219.00 ( 21.05%)
> Amean    total-odr0-8192            279.00 (  0.00%)           220.92 ( 20.82%)
> Amean    total-odr0-16384           269.38 (  0.00%)           219.92 ( 18.36%)
> 
> This is the alloc, free and total overhead of allocating order-0 pages in
> batches of 1 page up to 16384 pages. Avoiding disabling/enabling overhead
> massively reduces overhead. Alloc overhead is roughly reduced by 14-20% in
> most cases. The free path is reduced by 26-46% and the total reduction
> is significant.
> 
[...]
> 
> Similarly, little benefit was seen on networking benchmarks both localhost
> and between physical server/clients where other costs dominate. It's
> possible that this will only be noticable on very high speed networks.

The networking results highly depend on NIC drivers.  As you mention in
the cover-letter, (1) some drivers (e.g mlx4) alloc high-order pages to
work-around order-0 pages and DMA-map being too slow (for their HW
use-case), (2) drivers that do use order-0 pages have driver specific
page-recycling tricks (e.g. mlx5 and ixgbe).  The page_pool target
making a more generic recycle mechanism for drivers to use.

I'm very excited to see improvements in this area! :-)))
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
