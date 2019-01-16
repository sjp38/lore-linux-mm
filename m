Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E83658E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:46:01 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so2587800eda.3
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:46:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r53si1189324eda.218.2019.01.16.07.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 07:46:00 -0800 (PST)
Subject: Re: [PATCH 12/25] mm, compaction: Keep migration source private to a
 single compaction instance
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-13-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0d02b611-85a7-b161-1310-883c4b1594f8@suse.cz>
Date: Wed, 16 Jan 2019 16:45:59 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-13-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:49 PM, Mel Gorman wrote:
> Due to either a fast search of the free list or a linear scan, it is
> possible for multiple compaction instances to pick the same pageblock
> for migration.  This is lucky for one scanner and increased scanning for
> all the others. It also allows a race between requests on which first
> allocates the resulting free block.
> 
> This patch tests and updates the pageblock skip for the migration scanner
> carefully. When isolating a block, it will check and skip if the block is
> already in use. Once the zone lock is acquired, it will be rechecked so
> that only one scanner can set the pageblock skip for exclusive use. Any
> scanner contending will continue with a linear scan. The skip bit is
> still set if no pages can be isolated in a range.

Also the skip bit will remain set even if pages *could* be isolated,
AFAICS there's no clearing after a block was finished with
nr_isolated>0. Is it intended? Note even previously it wasn't ideal,
because when pageblock was visited multiple times due to
COMPACT_CLUSTER_MAX, it would be marked with skip bit if the last visit
failed to isolate, even if the previous visits didn't.

> While this may result
> in redundant scanning, it avoids unnecessarily acquiring the zone lock
> when there are no suitable migration sources.



> 1-socket thpscale
>                                         4.20.0                 4.20.0
>                                  findmig-v2r15          isolmig-v2r15
> Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
> Amean     fault-both-3      3505.69 (   0.00%)     3066.68 *  12.52%*
> Amean     fault-both-5      5794.13 (   0.00%)     4298.49 *  25.81%*
> Amean     fault-both-7      7663.09 (   0.00%)     5986.99 *  21.87%*
> Amean     fault-both-12    10983.36 (   0.00%)     9324.85 (  15.10%)
> Amean     fault-both-18    13602.71 (   0.00%)    13350.05 (   1.86%)
> Amean     fault-both-24    16145.77 (   0.00%)    13491.77 *  16.44%*
> Amean     fault-both-30    19753.82 (   0.00%)    15630.86 *  20.87%*
> Amean     fault-both-32    20616.16 (   0.00%)    17428.50 *  15.46%*
> 
> This is the first patch that shows a significant reduction in latency as
> multiple compaction scanners do not operate on the same blocks. There is
> a small increase in the success rate
> 
>                                4.20.0-rc6             4.20.0-rc6
>                              findmig-v1r4           isolmig-v1r4
> Percentage huge-3        90.58 (   0.00%)       95.84 (   5.81%)
> Percentage huge-5        91.34 (   0.00%)       94.19 (   3.12%)
> Percentage huge-7        92.21 (   0.00%)       93.78 (   1.71%)
> Percentage huge-12       92.48 (   0.00%)       94.33 (   2.00%)
> Percentage huge-18       91.65 (   0.00%)       94.15 (   2.72%)
> Percentage huge-24       90.23 (   0.00%)       94.23 (   4.43%)
> Percentage huge-30       90.17 (   0.00%)       95.17 (   5.54%)
> Percentage huge-32       89.72 (   0.00%)       93.59 (   4.32%)
> 
> Compaction migrate scanned    54168306    25516488
> Compaction free scanned      800530954    87603321
> 
> Migration scan rates are reduced by 52%.

Wonder how much of that is due to not clearing as pointed out above.
Also interesting how free scanned was reduced so disproportionally.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
