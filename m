Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46F2D6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:43:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c206so2767478wme.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 02:43:02 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id x81si1512535wmb.43.2017.01.12.02.43.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 02:43:00 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 87B4A9914D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:43:00 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/3] Use per-cpu allocator for !irq requests and prepare for a bulk allocator
Date: Thu, 12 Jan 2017 10:42:57 +0000
Message-Id: <20170112104300.24345-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

Changelog since v2
o Add ack's and benchmark data
o Rebase to 4.10-rc3

Changelog since v1
o Remove a scheduler point from the allocation path
o Finalise the bulk allocator and test it

This series is motivated by a conversation led by Jesper Dangaard Brouer at
the last LSF/MM proposing a generic page pool for DMA-coherent pages. Part
of his motivation was due to the overhead of allocating multiple order-0
that led some drivers to use high-order allocations and splitting them. This
is very slow in some cases.

The first two patches in this series restructure the page allocator such
that it is relatively easy to introduce an order-0 bulk page allocator.
A patch exists to do that and has been handed over to Jesper until an
in-kernel users is created.  The third patch alters the per-cpu alloctor
to make it exclusive to !irq requests. This cuts allocation/free overhead
by roughly 30%.

Performance tests from both Jesper and I are included in the patch.

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
