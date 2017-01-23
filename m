Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF69C6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 10:39:08 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so18711485wmi.6
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 07:39:08 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id g18si18098779wrc.171.2017.01.23.07.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 07:39:07 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 17F8C1C1069
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:39:07 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/4] Use per-cpu allocator for !irq requests and prepare for a bulk allocator v5
Date: Mon, 23 Jan 2017 15:39:02 +0000
Message-Id: <20170123153906.3122-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

This is rebased on top of mmotm to handle collisions with Vlastimil's
series on cpusets and premature OOMs.

Changelog since v4
o Protect drain with get_online_cpus
o Micro-optimisation of stat updates
o Avoid double preparing a page free

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

 mm/page_alloc.c | 282 ++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 181 insertions(+), 101 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
