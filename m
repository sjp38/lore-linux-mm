Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 554698E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 07:36:45 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so12427122edd.2
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:36:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si3143510ede.46.2018.12.18.04.36.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 04:36:43 -0800 (PST)
Subject: Re: [PATCH 09/14] mm, compaction: Ignore the fragmentation avoidance
 boost for isolation and compaction
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-10-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f8aeec16-65de-b873-3362-3c7cb30c4ac6@suse.cz>
Date: Tue, 18 Dec 2018 13:36:42 +0100
MIME-Version: 1.0
In-Reply-To: <20181214230310.572-10-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 12/15/18 12:03 AM, Mel Gorman wrote:
> When pageblocks get fragmented, watermarks are artifically boosted to pages
> are reclaimed to avoid further fragmentation events. However, compaction
> is often either fragmentation-neutral or moving movable pages away from
> unmovable/reclaimable pages. As the actual watermarks are preserved,
> allow compaction to ignore the boost factor.

Right, I should have realized that when reviewing the boost patch. I
think it would be useful to do the same change in
__compaction_suitable() as well. Compaction has its own "gap".

> 1-socket thpscale
>                                     4.20.0-rc6             4.20.0-rc6
>                                finishscan-v1r4           noboost-v1r4
> Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
> Amean     fault-both-3      3849.90 (   0.00%)     3753.53 (   2.50%)
> Amean     fault-both-5      5054.13 (   0.00%)     5396.32 (  -6.77%)
> Amean     fault-both-7      7061.77 (   0.00%)     7393.46 (  -4.70%)
> Amean     fault-both-12    11560.59 (   0.00%)    12155.50 (  -5.15%)
> Amean     fault-both-18    16120.15 (   0.00%)    16445.96 (  -2.02%)
> Amean     fault-both-24    19804.31 (   0.00%)    20465.03 (  -3.34%)
> Amean     fault-both-30    25018.73 (   0.00%)    20813.54 *  16.81%*
> Amean     fault-both-32    24380.19 (   0.00%)    22384.02 (   8.19%)
> 
> The impact on the scan rates is a mixed bag because this patch is very
> sensitive to timing and whether the boost was active or not. However,
> detailed tracing indicated that failure of migration due to a premature
> ENOMEM triggered by watermark checks were eliminated.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 80535cd55a92..c7b80e62bfd9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3043,7 +3043,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  		 * watermark, because we already know our high-order page
>  		 * exists.
>  		 */
> -		watermark = min_wmark_pages(zone) + (1UL << order);
> +		watermark = zone->_watermark[WMARK_MIN] + (1UL << order);
>  		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
>  			return 0;
>  
> 
