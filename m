Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5756B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 08:44:59 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so43485082wic.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 05:44:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u3si9648665wiy.65.2015.08.26.05.44.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 05:44:57 -0700 (PDT)
Subject: Re: [PATCH 11/12] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824122957.GI12432@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DDB4C7.6030300@suse.cz>
Date: Wed, 26 Aug 2015 14:44:55 +0200
MIME-Version: 1.0
In-Reply-To: <20150824122957.GI12432@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/24/2015 02:29 PM, Mel Gorman wrote:
> High-order watermark checking exists for two reasons --  kswapd high-order
> awareness and protection for high-order atomic requests. Historically the
> kernel depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order
> free pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
> that reserves pageblocks for high-order atomic allocations on demand and
> avoids using those blocks for order-0 allocations. This is more flexible
> and reliable than MIGRATE_RESERVE was.
>
> A MIGRATE_HIGHORDER pageblock is created when a high-order allocation

                                                  ^ atomic ...

> request steals a pageblock but limits the total number to 1% of the zone.
> Callers that speculatively abuse atomic allocations for long-lived
> high-order allocations to access the reserve will quickly fail. Note that
> SLUB is currently not such an abuser as it reclaims at least once.  It is
> possible that the pageblock stolen has few suitable high-order pages and
> will need to steal again in the near future but there would need to be
> strong justification to search all pageblocks for an ideal candidate.
>
> The pageblocks are unreserved if an allocation fails after a direct
> reclaim attempt.
>
> The watermark checks account for the reserved pageblocks when the allocation
> request is not a high-order atomic allocation.
>
> The reserved pageblocks can not be used for order-0 allocations. This may
> allow temporary wastage until a failed reclaim reassigns the pageblock. This
> is deliberate as the intent of the reservation is to satisfy a limited
> number of atomic high-order short-lived requests if the system requires them.
>
> The stutter benchmark was used to evaluate this but while it was running
> there was a systemtap script that randomly allocated between 1 high-order
> page and 12.5% of memory's worth of order-3 pages using GFP_ATOMIC. This
> is much larger than the potential reserve and it does not attempt to be
> realistic.  It is intended to stress random high-order allocations from
> an unknown source, show that there is a reduction in failures without
> introducing an anomaly where atomic allocations are more reliable than
> regular allocations.  The amount of memory reserved varied throughout the
> workload as reserves were created and reclaimed under memory pressure. The
> allocation failures once the workload warmed up were as follows;
>
> 4.2-rc5-vanilla		70%
> 4.2-rc5-atomic-reserve	56%
>
> The failure rate was also measured while building multiple kernels. The
> failure rate was 14% but is 6% with this patch applied.
>
> Overall, this is a small reduction but the reserves are small relative to the
> number of allocation requests. In early versions of the patch, the failure
> rate reduced by a much larger amount but that required much larger reserves
> and perversely made atomic allocations seem more reliable than regular allocations.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
