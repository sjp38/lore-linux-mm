Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2344E6B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 04:29:57 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so32066676wmi.6
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:29:57 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id i47si24389656wra.8.2017.01.17.01.29.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 01:29:55 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 5AD7798E49
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 09:29:55 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/4] Use per-cpu allocator for !irq requests and prepare for a bulk allocator v4
Date: Tue, 17 Jan 2017 09:29:50 +0000
Message-Id: <20170117092954.15413-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

For Vlastimil, this version passed a few tests with full debugging on
without triggering the additional !in_interrupt() checks. The biggest change
is patch 3 which avoids draining the per-cpu lists from IPI context.

Changelog since v3
o Debugging check in allocation path
o Make it harder to use the free path incorrectly
o Use preempt-safe stats counter
o Do not use IPIs to drain the per-cpu allocator

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
in-kernel users is created. The third patch prevents the per-cpu allocator
being drained from IPI context as that can potentially corrupt the list
after patch four is merged. The final patch alters the per-cpu alloctor
to make it exclusive to !irq requests. This cuts allocation/free overhead
by roughly 30%.

Performance tests from both Jesper and I are included in the patch.

 mm/page_alloc.c | 284 ++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 181 insertions(+), 103 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
