Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D017D6B0031
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 04:14:44 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id m15so4825255wgh.9
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 01:14:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx6si13141320wjb.172.2014.06.27.01.14.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 01:14:43 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/5] Improve sequential read throughput v3
Date: Fri, 27 Jun 2014 09:14:35 +0100
Message-Id: <1403856880-12597-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

Changelog since V2
o Simply fair zone policy cost reduction
o Drop CFQ patch

Changelog since v1
o Rebase to v3.16-rc2
o Move CFQ patch to end of series where it can be rejected easier if necessary
o Introduce page-reclaim related patch related to kswapd/fairzone interactions
o Rework fast zone policy patch

IO performance since 3.0 has been a mixed bag. In many respects we are
better and in some we are worse and one of those places is sequential
read throughput. This is visible in a number of benchmarks but I looked
at tiobench the closest. This is using ext3 on a mid-range desktop and
the series applied.

                                      3.16.0-rc2            3.16.0-rc2
                                         vanilla             lessdirty
Min    SeqRead-MB/sec-1         120.92 (  0.00%)      140.73 ( 16.38%)
Min    SeqRead-MB/sec-2         100.25 (  0.00%)      117.43 ( 17.14%)
Min    SeqRead-MB/sec-4          96.27 (  0.00%)      109.01 ( 13.23%)
Min    SeqRead-MB/sec-8          83.55 (  0.00%)       90.86 (  8.75%)
Min    SeqRead-MB/sec-16         66.77 (  0.00%)       74.12 ( 11.01%)

Overall system CPU usage is reduced

          3.16.0-rc2  3.16.0-rc2
             vanilla lessdirty-v3
User          390.13      390.20
System        404.41      379.08
Elapsed      5412.45     5123.74

This series does not fully restore throughput performance to 3.0 levels
but it brings it close for lower thread counts. Higher thread counts are
known to be worse than 3.0 due to CFQ changes but there is no appetite
for changing the defaults there.

 include/linux/mmzone.h         | 210 ++++++++++++++++++++++-------------------
 include/linux/writeback.h      |   1 +
 include/trace/events/pagemap.h |  16 ++--
 mm/internal.h                  |   1 +
 mm/mm_init.c                   |   4 +-
 mm/page-writeback.c            |  23 +++--
 mm/page_alloc.c                | 173 ++++++++++++++++++++-------------
 mm/swap.c                      |   4 +-
 mm/vmscan.c                    |  16 ++--
 mm/vmstat.c                    |   4 +-
 10 files changed, 258 insertions(+), 194 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
