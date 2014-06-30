Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 95AED6B0036
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 12:48:08 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so8428699wgh.12
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 09:48:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bm8si9795326wjb.103.2014.06.30.09.48.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 09:48:07 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/5] Improve sequential read throughput v4r8
Date: Mon, 30 Jun 2014 17:47:59 +0100
Message-Id: <1404146883-21414-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

Changelog since V3
o Push down kwapd changes to cover the balance gap
o Drop drop page distribution patch

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

                                      3.16.0-rc2                 3.0.0            3.16.0-rc2
                                         vanilla               vanilla         fairzone-v4r5
Min    SeqRead-MB/sec-1         120.92 (  0.00%)      133.65 ( 10.53%)      140.68 ( 16.34%)
Min    SeqRead-MB/sec-2         100.25 (  0.00%)      121.74 ( 21.44%)      118.13 ( 17.84%)
Min    SeqRead-MB/sec-4          96.27 (  0.00%)      113.48 ( 17.88%)      109.84 ( 14.10%)
Min    SeqRead-MB/sec-8          83.55 (  0.00%)       97.87 ( 17.14%)       89.62 (  7.27%)
Min    SeqRead-MB/sec-16         66.77 (  0.00%)       82.59 ( 23.69%)       70.49 (  5.57%)

Overall system CPU usage is reduced

          3.16.0-rc2       3.0.0  3.16.0-rc2
             vanilla     vanilla fairzone-v4
User          390.13      251.45      396.13
System        404.41      295.13      389.61
Elapsed      5412.45     5072.42     5163.49

This series does not fully restore throughput performance to 3.0 levels
but it brings it close for lower thread counts. Higher thread counts are
known to be worse than 3.0 due to CFQ changes but there is no appetite
for changing the defaults there.

 include/linux/mmzone.h         | 207 ++++++++++++++++++++++-------------------
 include/linux/swap.h           |   9 --
 include/trace/events/pagemap.h |  16 ++--
 mm/page_alloc.c                | 126 ++++++++++++++-----------
 mm/swap.c                      |   4 +-
 mm/vmscan.c                    |  46 ++++-----
 mm/vmstat.c                    |   4 +-
 7 files changed, 208 insertions(+), 204 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
