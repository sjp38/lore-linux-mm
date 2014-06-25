Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id EB7476B0037
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 03:58:55 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so1956552wiv.4
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 00:58:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pg3si3973723wjb.99.2014.06.25.00.58.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 00:58:52 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/6] Improve sequential read throughput v2
Date: Wed, 25 Jun 2014 08:58:43 +0100
Message-Id: <1403683129-10814-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Jeff Moyer <jmoyer@redhat.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>

Changelog since v1
o Rebase to v3.16-rc2
o Move CFQ patch to end of series where it can be rejected easier if necessary
o Introduce page-reclaim related patch related to kswapd/fairzone interactions
o Rework fast zone policy patch

IO performance since 3.0 has been a mixed bag. In many respects we are
better and in some we are worse and one of those places is sequential
read throughput. This is visible in a number of benchmarks but I looked
at tiobench the closest. This is using ext3 on a mid-range desktop and
comparing against 3.0.

                                      3.16.0-rc2            3.16.0-rc2                 3.0.0
                                         vanilla                cfq600               vanilla
Min    SeqRead-MB/sec-1         120.96 (  0.00%)      140.43 ( 16.10%)      134.04 ( 10.81%)
Min    SeqRead-MB/sec-2         100.73 (  0.00%)      118.18 ( 17.32%)      120.76 ( 19.88%)
Min    SeqRead-MB/sec-4          96.05 (  0.00%)      110.84 ( 15.40%)      114.49 ( 19.20%)
Min    SeqRead-MB/sec-8          82.46 (  0.00%)       92.40 ( 12.05%)       98.04 ( 18.89%)
Min    SeqRead-MB/sec-16         66.37 (  0.00%)       76.68 ( 15.53%)       79.49 ( 19.77%)

This series does not fully restore throughput performance to 3.0 levels
but it brings it acceptably close. While throughput for higher numbers
of threads is lower, it is known that it can be tuned by increasing
target_latency or disabling low_latency giving higher overall throughput
at the cost of latency and IO fairness.

This series in ordered in ascending-likelihood-to-cause-controversary so
that a partial series can still potentially be merged even if parts of it
are naked (e.g. CGQ). For reference, here is the series without the CFQ
patch at the end.

                                      3.16.0-rc2            3.16.0-rc2                 3.0.0
                                         vanilla             lessdirty               vanilla
Min    SeqRead-MB/sec-1         120.96 (  0.00%)      141.04 ( 16.60%)      134.04 ( 10.81%)
Min    SeqRead-MB/sec-2         100.73 (  0.00%)      116.26 ( 15.42%)      120.76 ( 19.88%)
Min    SeqRead-MB/sec-4          96.05 (  0.00%)      109.52 ( 14.02%)      114.49 ( 19.20%)
Min    SeqRead-MB/sec-8          82.46 (  0.00%)       88.60 (  7.45%)       98.04 ( 18.89%)
Min    SeqRead-MB/sec-16         66.37 (  0.00%)       69.87 (  5.27%)       79.49 ( 19.77%)


 block/cfq-iosched.c            |   2 +-
 include/linux/mmzone.h         | 210 ++++++++++++++++++++++-------------------
 include/linux/writeback.h      |   1 +
 include/trace/events/pagemap.h |  16 ++--
 mm/internal.h                  |   1 +
 mm/mm_init.c                   |   5 +-
 mm/page-writeback.c            |  15 +--
 mm/page_alloc.c                | 206 ++++++++++++++++++++++++++--------------
 mm/swap.c                      |   4 +-
 mm/vmscan.c                    |  16 ++--
 mm/vmstat.c                    |   4 +-
 11 files changed, 285 insertions(+), 195 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
