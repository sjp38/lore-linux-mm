Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA936B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 06:10:51 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id s63so82928967wms.7
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 03:10:51 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id l123si77312661wmb.151.2017.01.04.03.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 03:10:50 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 8DB831C191C
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 11:10:49 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [RFC PATCH 0/4] Fast noirq bulk page allocator
Date: Wed,  4 Jan 2017 11:10:45 +0000
Message-Id: <20170104111049.15501-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

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

 include/linux/gfp.h |  23 ++++
 mm/page_alloc.c     | 329 ++++++++++++++++++++++++++++++++++++----------------
 2 files changed, 254 insertions(+), 98 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
