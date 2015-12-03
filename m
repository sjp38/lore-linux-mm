Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EFB566B0255
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 02:11:35 -0500 (EST)
Received: by padhx2 with SMTP id hx2so63235147pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:35 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id r73si10146767pfa.169.2015.12.02.23.11.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 23:11:35 -0800 (PST)
Received: by pfnn128 with SMTP id n128so5525272pfn.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:35 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v3 0/7] mm/compaction: redesign compaction: part1
Date: Thu,  3 Dec 2015 16:11:14 +0900
Message-Id: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Major changes from v2:
o Split patchset into two parts, one is for replacing compaction
deferring with compaction limit and the other is for changing
scanner activity
o Add some fixes and cleanup for current defer logic
o Fix opposite direction problem in "skip useless pfn when..." patch
o Reuse current defer logic for compaction limit
o Provide proper argument when calling __reset_isolation_suitable()
o Prevent async compaction while compaction limit is activated

Previous cover-letter isn't appropriate for this part1 patchset so
I just append link about it.

https://lkml.org/lkml/2015/8/23/182

New description:
Compaction deferring effectively reduces compaction overhead if
compaction success isn't expected. But, it is implemented that
skipping a number of compaction requests until compaction is re-enabled.
Due to this implementation, unfortunate compaction requestor will get
whole compaction overhead unlike others have zero overhead. And, after
deferring start to work, even if compaction success possibility is
restored, we should skip to compaction in some number of times.

This patch try to solve above problem by using compaction limit.
Instead of imposing compaction overhead to one unfortunate requestor,
compaction limit distributes overhead to all compaction requestors.
All requestors have a chance to migrate some amount of pages and
after limit is exhausted compaction will be stopped. This will fairly
distributes overhead to all compaction requestors. And, because we don't
defer compaction request, someone will succeed to compact as soon as
possible if compaction success possiblility is restored.

I tested this patch on my compaction benchmark and found that high-order
allocation latency is evenly distributed and there is no latency spike
in the situation where compaction success isn't possible.

Following is the result of each high-order allocation latency (ns).
Base vs Limit

9807 failure 825        9807 failure 10839
9808 failure 820        9808 failure 9762
9809 failure 827        9809 failure 8585
9810 failure 3751       9810 failure 14052
9811 failure 881        9811 failure 10781
9812 failure 827        9812 failure 9906
9813 failure 2447430    9813 failure 8925
9814 failure 8632       9814 failure 9185
9815 failure 1172       9815 failure 9076
9816 failure 1045       9816 failure 10860
9817 failure 1044       9817 failure 10571
9818 failure 1043       9818 failure 8789
9819 failure 979        9819 failure 9086
9820 failure 4338       9820 failure 43681
9821 failure 1001       9821 failure 9361
9822 failure 875        9822 failure 15175
9823 failure 822        9823 failure 9394
9824 failure 827        9824 failure 334341
9825 failure 829        9825 failure 15404
9826 failure 823        9826 failure 10419
9827 failure 824        9827 failure 11375
9828 failure 827        9828 failure 9416
9829 failure 822        9829 failure 9303
9830 failure 3646       9830 failure 18514
9831 failure 869        9831 failure 11064
9832 failure 820        9832 failure 9626
9833 failure 832        9833 failure 8794
9834 failure 820        9834 failure 10576
9835 failure 2450955    9835 failure 12260
9836 failure 9428       9836 failure 9049
9837 failure 1067       9837 failure 10346
9838 failure 968        9838 failure 8793
9839 failure 984        9839 failure 8932
9840 failure 4262       9840 failure 18436
9841 failure 964        9841 failure 11429
9842 failure 937        9842 failure 9433
9843 failure 828        9843 failure 8838
9844 failure 827        9844 failure 8948
9845 failure 822        9845 failure 13017
9846 failure 827        9846 failure 10795

As you can see, Base has a latency spike periodically, but,
in Limit, latency is distributed evenly.

This patchset is based on linux-next-20151106 +
"restore COMPACT_CLUSTER_MAX to 32" + "__compact_pgdat() code cleanuup"
which are sent by me today.

Thanks.

Joonsoo Kim (7):
  mm/compaction: skip useless pfn when updating cached pfn
  mm/compaction: remove unused defer_compaction() in compaction.h
  mm/compaction: initialize compact_order_failed to MAX_ORDER
  mm/compaction: update defer counter when allocation is expected to
    succeed
  mm/compaction: respect compaction order when updating defer counter
  mm/compaction: introduce migration scan limit
  mm/compaction: replace compaction deferring with compaction limit

 include/linux/compaction.h        |   3 -
 include/linux/mmzone.h            |   6 +-
 include/trace/events/compaction.h |   7 +-
 mm/compaction.c                   | 188 ++++++++++++++++++++++++--------------
 mm/internal.h                     |   1 +
 mm/page_alloc.c                   |   4 +-
 6 files changed, 125 insertions(+), 84 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
