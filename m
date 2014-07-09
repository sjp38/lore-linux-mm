Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 23BF96B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 04:13:12 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t60so7122318wes.0
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 01:13:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si29942215wjr.7.2014.07.09.01.13.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 01:13:11 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/5] Reduce sequential read overhead
Date: Wed,  9 Jul 2014 09:13:02 +0100
Message-Id: <1404893588-21371-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

This was formerly the series "Improve sequential read throughput" which
noted some major differences in performance of tiobench since 3.0. While
there are a number of factors, two that dominated were the introduction
of the fair zone allocation policy and changes to CFQ.

The behaviour of fair zone allocation policy makes more sense than tiobench
as a benchmark and CFQ defaults were not changed due to insufficient
benchmarking.

This series is what's left. It's one functional fix to the fair zone
allocation policy when used on NUMA machines and a reduction of overhead
in general. tiobench was used for the comparison despite its flaws as an
IO benchmark as in this case we are primarily interested in the overhead
of page allocator and page reclaim activity.

On UMA, it makes little difference to overhead

          3.16.0-rc3   3.16.0-rc3
             vanilla lowercost-v5
User          383.61      386.77
System        403.83      401.74
Elapsed      5411.50     5413.11

On a 4-socket NUMA machine it's a bit more noticable

          3.16.0-rc3   3.16.0-rc3
             vanilla lowercost-v5
User          746.94      802.00
System      65336.22    40852.33
Elapsed     27553.52    27368.46

 include/linux/mmzone.h         | 217 ++++++++++++++++++++++-------------------
 include/trace/events/pagemap.h |  16 ++-
 mm/page_alloc.c                | 122 ++++++++++++-----------
 mm/swap.c                      |   4 +-
 mm/vmscan.c                    |   7 +-
 mm/vmstat.c                    |   9 +-
 6 files changed, 198 insertions(+), 177 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
