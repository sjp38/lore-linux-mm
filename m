Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id D3E169003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:00:24 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so19396603wic.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:00:24 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id df3si11992141wib.53.2015.07.20.01.00.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 01:00:21 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id AC00D98846
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:00:20 +0000 (UTC)
From: Mel Gorman <mgorman@suse.com>
Subject: [RFC PATCH 00/10] Remove zonelist cache and high-order watermark checking
Date: Mon, 20 Jul 2015 09:00:09 +0100
Message-Id: <1437379219-9160-1-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Mel Gorman <mgorman@suse.de>

This series started with the idea to move LRU lists to pgdat but this
part was more important to start with. It was written against 4.2-rc1 but
applies to 4.2-rc3.

The zonelist cache has been around for a long time but it is of dubious merit
with a lot of complexity. There are a few reasons why it needs help that
are explained in the first patch but the most important is that a failed
THP allocation can cause a zone to be treated as "full". This potentially
causes unnecessary stalls, reclaim activity or remote fallbacks. Maybe the
issues could be fixed but it's not worth it.  The series places a small
number of other micro-optimisations on top before examining watermarks.

High-order watermarks are something that can cause high-order allocations to
fail even though pages are free. This was originally to protect high-order
atomic allocations but there is a much better way that can be handled using
migrate types. This series uses page grouping by mobility to preserve some
pageblocks for high-order allocations with the size of the reservation
depending on demand. kswapd awareness is maintained by examining the free
lists. By patch 10 in this series, there are no high-order watermark checks
while preserving the properties that motivated the introduction of the
watermark checks.

An interesting side-effect of this series is that high-order atomic
allocations should be a lot more reliable as long as they start before heavy
fragmentation or memory pressure is encountered. This is due to the reserves
being dynamically sized instead of just depending on MIGRATE_RESERVE. The
traditional expected case here is atomic allocations for network buffers
using jumbo frames whose devices cannot handle scatter/gather. In aggressive
tests the failure rate of atomic order-3 allocations is reduced by 98%. I
would be very interested in hearing from someone who uses jumbo frames
with hardware that requires high-order atomic allocations to succeed that
can test this series.

A potential side-effect of this series may be of interest to developers
of embedded platforms. There have been a number of patches recently that
were aimed at making high-order allocations fast or reliable in various
different ways. Usually they came under the headings of compaction but
they are likely to have hit limited success without modifying how grouping
works. One patch attempting to introduce an interface that allowed userspace
to dump all of memory in an attempt to make high-order allocations faster
which is definitely a bad idea. Using this series they get two other
options as out-of-tree patches

  1. Alter patch 9 of this series to only call unreserve_highatomic_pageblock
     if the system is about to go OOM. This should drop the allocation
     failure for high-order atomic failures to 0 or near 0 in a lot of cases.
     Your milage will depend on the workload. Such a change would not suit
     mainline because it'll push a lot of workloads into reclaim in cases
     where the HighAtomic reserves are too large.

  2. Alter patch 9 of this series to reserve space for all high-order kernel
     allocations, not just atomic ones. This will make the high-order
     allocations more reliable and in many cases faster. However, the caveat
     may be excessive reclaim if those reserves become a large percentage of
     memory. I would recommend that you still try and avoid ever depending
     on high-order allocations for functional correctness.  Alternative keep
     them as short-lived as possible so they fit in a small reserve.

With or without the out-of-tree modifications, this series should work well
with compaction series that aim to make more pages migratable so high-order
allocations are more successful.

 include/linux/cpuset.h |   6 +
 include/linux/gfp.h    |  47 +++-
 include/linux/mmzone.h |  94 +-------
 init/main.c            |   2 +-
 mm/huge_memory.c       |   2 +-
 mm/internal.h          |   1 +
 mm/page_alloc.c        | 565 ++++++++++++++-----------------------------------
 mm/slab.c              |   4 +-
 mm/slob.c              |   4 +-
 mm/slub.c              |   6 +-
 mm/vmscan.c            |   4 +-
 mm/vmstat.c            |   2 +-
 12 files changed, 228 insertions(+), 509 deletions(-)

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
