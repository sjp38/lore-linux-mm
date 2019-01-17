Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8729B8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:16:57 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id 39so3862806edq.13
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 07:16:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m26si1535450eds.250.2019.01.17.07.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 07:16:55 -0800 (PST)
Subject: Re: [PATCH 14/25] mm, compaction: Avoid rescanning the same pageblock
 multiple times
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-15-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <67b95fef-6f9a-a91f-c1b2-1c3fbc9330ca@suse.cz>
Date: Thu, 17 Jan 2019 16:16:54 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-15-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:50 PM, Mel Gorman wrote:
> Pageblocks are marked for skip when no pages are isolated after a scan.
> However, it's possible to hit corner cases where the migration scanner
> gets stuck near the boundary between the source and target scanner. Due
> to pages being migrated in blocks of COMPACT_CLUSTER_MAX, pages that
> are migrated can be reallocated before the pageblock is complete. The
> pageblock is not necessarily skipped so it can be rescanned multiple
> times. Similarly, a pageblock with some dirty/writeback pages may fail
> to isolate and be rescanned until writeback completes which is wasteful.

     ^ migrate? If we failed to isolate, then it wouldn't bump nr_isolated.
Wonder if we could do better checks and not isolate pages that cannot be at the
moment migrated anyway.

> 
> This patch tracks if a pageblock is being rescanned. If so, then the entire
> pageblock will be migrated as one operation. This narrows the race window
> during which pages can be reallocated during migration. Secondly, if there
> are pages that cannot be isolated then the pageblock will still be fully
> scanned and marked for skipping. On the second rescan, the pageblock skip
> is set and the migration scanner makes progress.
> 
>                                         4.20.0                 4.20.0
>                               finishscan-v2r15         norescan-v2r15
> Amean     fault-both-3      3729.80 (   0.00%)     2872.13 *  23.00%*
> Amean     fault-both-5      5148.49 (   0.00%)     4330.56 *  15.89%*
> Amean     fault-both-7      7393.24 (   0.00%)     6496.63 (  12.13%)
> Amean     fault-both-12    11709.32 (   0.00%)    10280.59 (  12.20%)
> Amean     fault-both-18    16626.82 (   0.00%)    11079.19 *  33.37%*
> Amean     fault-both-24    19944.34 (   0.00%)    17207.80 *  13.72%*
> Amean     fault-both-30    23435.53 (   0.00%)    17736.13 *  24.32%*
> Amean     fault-both-32    23948.70 (   0.00%)    18509.41 *  22.71%*
> 
>                                    4.20.0                 4.20.0
>                          finishscan-v2r15         norescan-v2r15
> Percentage huge-1         0.00 (   0.00%)        0.00 (   0.00%)
> Percentage huge-3        88.39 (   0.00%)       96.87 (   9.60%)
> Percentage huge-5        92.07 (   0.00%)       94.63 (   2.77%)
> Percentage huge-7        91.96 (   0.00%)       93.83 (   2.03%)
> Percentage huge-12       93.38 (   0.00%)       92.65 (  -0.78%)
> Percentage huge-18       91.89 (   0.00%)       93.66 (   1.94%)
> Percentage huge-24       91.37 (   0.00%)       93.15 (   1.95%)
> Percentage huge-30       92.77 (   0.00%)       93.16 (   0.42%)
> Percentage huge-32       87.97 (   0.00%)       92.58 (   5.24%)
> 
> The fault latency reduction is large and while the THP allocation
> success rate is only slightly higher, it's already high at this
> point of the series.
> 
> Compaction migrate scanned    60718343.00    31772603.00
> Compaction free scanned      933061894.00    63267928.00

Hm I thought the order of magnitude difference between migrate and free scanned
was already gone at this point as reported in the previous 2 patches. Or is this
from different system/configuration? Anyway, encouraging result. I would expect
that after "Keep migration source private to a single compaction instance" sets
the skip bits much more early and aggressively, the rescans would not happen
anymore thanks to those, even if cached pfns were not updated.

> Migration scan rates are reduced by 48% and free scan rates are
> also reduced as the same migration source block is not being selected
> multiple times. The corner case where migration scan rates go through the
> roof due to a dirty/writeback pageblock located at the boundary of the
> migration/free scanner did not happen in this case. When it does happen,
> the scan rates multiple by factors measured in the hundreds and would be
> misleading to present.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
