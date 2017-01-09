Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D5C1C6B025E
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 11:35:20 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id iq1so75261634wjb.1
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 08:35:20 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id eq7si12294436wjc.293.2017.01.09.08.35.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 08:35:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id EA9F81DC02B
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 16:35:18 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [RFC PATCH 0/4] Fast noirq bulk page allocator v2r7
Date: Mon,  9 Jan 2017 16:35:14 +0000
Message-Id: <20170109163518.6001-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mel Gorman <mgorman@techsingularity.net>

The biggest changes are in the final patch. In v1, it was a rough untested
prototype. This version corrected a number of issues, tested it and includes
a comparison between bulk allocating pages and allocating them one at a time.
While there are still no in-kernel users, it is hoped that the bulk API
would convince network drivers to avoid using high-order allocations. One
slight caveat is that there still may be an advantage to doing the coherent
setup on a high-order page instead of a list of order-0 pages. If that is the
case, it would need to be covered by Jesper's generic page pool allocator.

Changelog since v1
o Remove a scheduler point from the allocation path
o Finalise the bulk allocator and test it

This series is motivated by a conversation led by Jesper Dangaard Brouer at
the last LSF/MM proposing a generic page pool for DMA-coherent pages. Part of
his motivation was due to the overhead of allocating multiple order-0 that
led some drivers to use high-order allocations and splitting them which
can be very slow if high-order pages are unavailable. This long-overdue
series aims to show that raw bulk page allocation can be achieved relatively
easily without introducing a completely new allocator. A new generic page
pool allocator would then ideally focus on just the DMA-coherent part.

The first two patches in the series restructure the allocator such that
it's relatively easy to build a bulk page allocator. The third patch
alters the per-cpu alloctor to make it exclusive to !irq requests. This
cuts allocation/free overhead by roughly 30% but it may not be noticable
to anyone other than users of high-speed networks (I'm not one). The
fourth patch introduces a bulk page allocator with no in-kernel users as
an example for Jesper and others who want to build a page allocator for
DMA-coherent pages.  It hopefully is relatively easy to modify this API
and the one core function to get the semantics they require.  Note that
Patch 3 is not required for patch 4 but it may be desirable if the bulk
allocations happen from !IRQ context.

A comparison of costs of allocating one page at a time on the vanilla
kernel vs the bulk allocator that forces the per-cpu allocator to be
used from a !irq context is as follows

pagealloc
                                          4.10.0-rc2                 4.10.0-rc2
                                             vanilla                  bulk-v2r7
Amean    alloc-odr0-1               302.85 (  0.00%)           106.62 ( 64.80%)
Amean    alloc-odr0-2               227.85 (  0.00%)            76.38 ( 66.48%)
Amean    alloc-odr0-4               191.23 (  0.00%)            57.23 ( 70.07%)
Amean    alloc-odr0-8               167.54 (  0.00%)            48.77 ( 70.89%)
Amean    alloc-odr0-16              158.54 (  0.00%)            45.38 ( 71.37%)
Amean    alloc-odr0-32              150.46 (  0.00%)            42.77 ( 71.57%)
Amean    alloc-odr0-64              148.23 (  0.00%)            41.00 ( 72.34%)
Amean    alloc-odr0-128             145.00 (  0.00%)            40.08 ( 72.36%)
Amean    alloc-odr0-256             157.00 (  0.00%)            56.00 ( 64.33%)
Amean    alloc-odr0-512             170.00 (  0.00%)            69.00 ( 59.41%)
Amean    alloc-odr0-1024            181.00 (  0.00%)            76.23 ( 57.88%)
Amean    alloc-odr0-2048            186.00 (  0.00%)            81.15 ( 56.37%)
Amean    alloc-odr0-4096            192.92 (  0.00%)            85.92 ( 55.46%)
Amean    alloc-odr0-8192            194.00 (  0.00%)            88.00 ( 54.64%)
Amean    alloc-odr0-16384           202.15 (  0.00%)            89.00 ( 55.97%)
Amean    free-odr0-1                154.92 (  0.00%)            55.69 ( 64.05%)
Amean    free-odr0-2                115.31 (  0.00%)            49.38 ( 57.17%)
Amean    free-odr0-4                 93.31 (  0.00%)            45.38 ( 51.36%)
Amean    free-odr0-8                 82.62 (  0.00%)            44.23 ( 46.46%)
Amean    free-odr0-16                79.00 (  0.00%)            45.00 ( 43.04%)
Amean    free-odr0-32                75.15 (  0.00%)            43.92 ( 41.56%)
Amean    free-odr0-64                74.00 (  0.00%)            43.00 ( 41.89%)
Amean    free-odr0-128               73.00 (  0.00%)            43.00 ( 41.10%)
Amean    free-odr0-256               91.00 (  0.00%)            60.46 ( 33.56%)
Amean    free-odr0-512              108.00 (  0.00%)            76.00 ( 29.63%)
Amean    free-odr0-1024             119.00 (  0.00%)            85.38 ( 28.25%)
Amean    free-odr0-2048             125.08 (  0.00%)            91.23 ( 27.06%)
Amean    free-odr0-4096             130.00 (  0.00%)            95.62 ( 26.45%)
Amean    free-odr0-8192             130.00 (  0.00%)            97.00 ( 25.38%)
Amean    free-odr0-16384            134.46 (  0.00%)            97.46 ( 27.52%)
Amean    total-odr0-1               457.77 (  0.00%)           162.31 ( 64.54%)
Amean    total-odr0-2               343.15 (  0.00%)           125.77 ( 63.35%)
Amean    total-odr0-4               284.54 (  0.00%)           102.62 ( 63.94%)
Amean    total-odr0-8               250.15 (  0.00%)            93.00 ( 62.82%)
Amean    total-odr0-16              237.54 (  0.00%)            90.38 ( 61.95%)
Amean    total-odr0-32              225.62 (  0.00%)            86.69 ( 61.58%)
Amean    total-odr0-64              222.23 (  0.00%)            84.00 ( 62.20%)
Amean    total-odr0-128             218.00 (  0.00%)            83.08 ( 61.89%)
Amean    total-odr0-256             248.00 (  0.00%)           116.46 ( 53.04%)
Amean    total-odr0-512             278.00 (  0.00%)           145.00 ( 47.84%)
Amean    total-odr0-1024            300.00 (  0.00%)           161.62 ( 46.13%)
Amean    total-odr0-2048            311.08 (  0.00%)           172.38 ( 44.58%)
Amean    total-odr0-4096            322.92 (  0.00%)           181.54 ( 43.78%)
Amean    total-odr0-8192            324.00 (  0.00%)           185.00 ( 42.90%)
Amean    total-odr0-16384           336.62 (  0.00%)           186.46 ( 44.61%)

It's roughly a 50-70% reduction of allocation costs and roughly a halving of the
overall cost of allocating/freeing batches of pages.

 include/linux/gfp.h |  24 ++++
 mm/page_alloc.c     | 353 +++++++++++++++++++++++++++++++++++++---------------
 2 files changed, 278 insertions(+), 99 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
