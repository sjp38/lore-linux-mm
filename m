Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B18BD6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 09:25:24 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id t84so111284583qke.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 06:25:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 52si14298919qtv.302.2017.01.16.06.25.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 06:25:23 -0800 (PST)
Date: Mon, 16 Jan 2017 15:25:18 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 4/4] mm, page_alloc: Add a bulk page allocator
Message-ID: <20170116152518.5519dc1e@redhat.com>
In-Reply-To: <20170109163518.6001-5-mgorman@techsingularity.net>
References: <20170109163518.6001-1-mgorman@techsingularity.net>
	<20170109163518.6001-5-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, brouer@redhat.com

On Mon,  9 Jan 2017 16:35:18 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> This patch adds a new page allocator interface via alloc_pages_bulk,
> __alloc_pages_bulk and __alloc_pages_bulk_nodemask. A caller requests a
> number of pages to be allocated and added to a list. They can be freed in
> bulk using free_pages_bulk(). Note that it would theoretically be possible
> to use free_hot_cold_page_list for faster frees if the symbol was exported,
> the refcounts were 0 and the caller guaranteed it was not in an interrupt.
> This would be significantly faster in the free path but also more unsafer
> and a harder API to use.
> 
> The API is not guaranteed to return the requested number of pages and
> may fail if the preferred allocation zone has limited free memory, the
> cpuset changes during the allocation or page debugging decides to fail
> an allocation. It's up to the caller to request more pages in batch if
> necessary.
> 
> The following compares the allocation cost per page for different batch
> sizes. The baseline is allocating them one at a time and it compares with
> the performance when using the new allocation interface.

I've also played with testing the bulking API here:
 [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench04_bulk.c

My baseline single (order-0 page) show: 158 cycles(tsc) 39.593 ns

Using bulking API:
 Bulk:   1 cycles: 128 nanosec: 32.134
 Bulk:   2 cycles: 107 nanosec: 26.783
 Bulk:   3 cycles: 100 nanosec: 25.047
 Bulk:   4 cycles:  95 nanosec: 23.988
 Bulk:   8 cycles:  91 nanosec: 22.823
 Bulk:  16 cycles:  88 nanosec: 22.093
 Bulk:  32 cycles:  85 nanosec: 21.338
 Bulk:  64 cycles:  85 nanosec: 21.315
 Bulk: 128 cycles:  84 nanosec: 21.214
 Bulk: 256 cycles: 115 nanosec: 28.979

This bulk API (and other improvements part of patchset) definitely
moves the speed of the page allocator closer to my (crazy) time budget
target of between 201 to 269 cycles per packet[1].  Remember I was
reporting[2] order-0 cost between 231 to 277 cycles, at MM-summit
2016, so this is a huge improvement since then.

The bulk numbers are great, but it still cannot compete with the
recycles tricks used by drivers.  Looking at the code (and as Mel also
mentions) there is room for improvements especially on the bulk free-side.


[1] http://people.netfilter.org/hawk/presentations/devconf2016/net_stack_challenges_100G_Feb2016.pdf
[2] http://people.netfilter.org/hawk/presentations/MM-summit2016/generic_page_pool_mm_summit2016.pdf

> pagealloc
>                                           4.10.0-rc2                 4.10.0-rc2
>                                        one-at-a-time                    bulk-v2
> Amean    alloc-odr0-1               259.54 (  0.00%)           106.62 ( 58.92%)
> Amean    alloc-odr0-2               193.38 (  0.00%)            76.38 ( 60.50%)
> Amean    alloc-odr0-4               162.38 (  0.00%)            57.23 ( 64.76%)
> Amean    alloc-odr0-8               144.31 (  0.00%)            48.77 ( 66.20%)
> Amean    alloc-odr0-16              134.08 (  0.00%)            45.38 ( 66.15%)
> Amean    alloc-odr0-32              128.62 (  0.00%)            42.77 ( 66.75%)
> Amean    alloc-odr0-64              126.00 (  0.00%)            41.00 ( 67.46%)
> Amean    alloc-odr0-128             125.00 (  0.00%)            40.08 ( 67.94%)
> Amean    alloc-odr0-256             136.62 (  0.00%)            56.00 ( 59.01%)
> Amean    alloc-odr0-512             152.00 (  0.00%)            69.00 ( 54.61%)
> Amean    alloc-odr0-1024            158.00 (  0.00%)            76.23 ( 51.75%)
> Amean    alloc-odr0-2048            163.00 (  0.00%)            81.15 ( 50.21%)
> Amean    alloc-odr0-4096            169.77 (  0.00%)            85.92 ( 49.39%)
> Amean    alloc-odr0-8192            170.00 (  0.00%)            88.00 ( 48.24%)
> Amean    alloc-odr0-16384           170.00 (  0.00%)            89.00 ( 47.65%)
> Amean    free-odr0-1                 88.69 (  0.00%)            55.69 ( 37.21%)
> Amean    free-odr0-2                 66.00 (  0.00%)            49.38 ( 25.17%)
> Amean    free-odr0-4                 54.23 (  0.00%)            45.38 ( 16.31%)
> Amean    free-odr0-8                 48.23 (  0.00%)            44.23 (  8.29%)
> Amean    free-odr0-16                47.00 (  0.00%)            45.00 (  4.26%)
> Amean    free-odr0-32                44.77 (  0.00%)            43.92 (  1.89%)
> Amean    free-odr0-64                44.00 (  0.00%)            43.00 (  2.27%)
> Amean    free-odr0-128               43.00 (  0.00%)            43.00 (  0.00%)
> Amean    free-odr0-256               60.69 (  0.00%)            60.46 (  0.38%)
> Amean    free-odr0-512               79.23 (  0.00%)            76.00 (  4.08%)
> Amean    free-odr0-1024              86.00 (  0.00%)            85.38 (  0.72%)
> Amean    free-odr0-2048              91.00 (  0.00%)            91.23 ( -0.25%)
> Amean    free-odr0-4096              94.85 (  0.00%)            95.62 ( -0.81%)
> Amean    free-odr0-8192              97.00 (  0.00%)            97.00 (  0.00%)
> Amean    free-odr0-16384             98.00 (  0.00%)            97.46 (  0.55%)
> Amean    total-odr0-1               348.23 (  0.00%)           162.31 ( 53.39%)
> Amean    total-odr0-2               259.38 (  0.00%)           125.77 ( 51.51%)
> Amean    total-odr0-4               216.62 (  0.00%)           102.62 ( 52.63%)
> Amean    total-odr0-8               192.54 (  0.00%)            93.00 ( 51.70%)
> Amean    total-odr0-16              181.08 (  0.00%)            90.38 ( 50.08%)
> Amean    total-odr0-32              173.38 (  0.00%)            86.69 ( 50.00%)
> Amean    total-odr0-64              170.00 (  0.00%)            84.00 ( 50.59%)
> Amean    total-odr0-128             168.00 (  0.00%)            83.08 ( 50.55%)
> Amean    total-odr0-256             197.31 (  0.00%)           116.46 ( 40.97%)
> Amean    total-odr0-512             231.23 (  0.00%)           145.00 ( 37.29%)
> Amean    total-odr0-1024            244.00 (  0.00%)           161.62 ( 33.76%)
> Amean    total-odr0-2048            254.00 (  0.00%)           172.38 ( 32.13%)
> Amean    total-odr0-4096            264.62 (  0.00%)           181.54 ( 31.40%)
> Amean    total-odr0-8192            267.00 (  0.00%)           185.00 ( 30.71%)
> Amean    total-odr0-16384           268.00 (  0.00%)           186.46 ( 30.42%)
> 
> It shows a roughly 50-60% reduction in the cost of allocating pages.
> The free paths are not improved as much but relatively little can be batched
> there. It's not quite as fast as it could be but taking further shortcuts
> would require making a lot of assumptions about the state of the page and
> the context of the caller.

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
