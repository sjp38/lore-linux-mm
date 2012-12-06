Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id A3BB38D0011
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 16:09:44 -0500 (EST)
Message-ID: <50C10997.8090801@codeaurora.org>
Date: Thu, 06 Dec 2012 13:09:43 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: Use aligned zone start for pfn_to_bitidx calculation
References: <1354824324-21993-1-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1354824324-21993-1-git-send-email-lauraa@codeaurora.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

On 12/6/2012 12:05 PM, Laura Abbott wrote:
> The current calculation in pfn_to_bitidx assumes that
> (pfn - zone->zone_start_pfn) >> pageblock_order will return the
> same bit for all pfn in a pageblock. If zone_start_pfn is not
> aligned to pageblock_nr_pages, this may not always be correct.
>
> Consider the following with pageblock order = 10, zone start 2MB:
>
> pfn     | pfn - zone start | (pfn - zone start) >> page block order
> ----------------------------------------------------------------
> 0x26000 | 0x25e00	   |  0x97
> 0x26100 | 0x25f00	   |  0x97
> 0x26200 | 0x26000	   |  0x98
> 0x26300 | 0x26100	   |  0x98
>
> This means that calling {get,set}_pageblock_migratetype on a single
> page will not set the migratetype for the full block. Fix this by
> rounding down zone_start_pfn when doing the bitidx calculation.
>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> ---
>   mm/page_alloc.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 92dd060..2e06abd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5422,7 +5422,7 @@ static inline int pfn_to_bitidx(struct zone *zone, unsigned long pfn)
>   	pfn &= (PAGES_PER_SECTION-1);
>   	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
>   #else
> -	pfn = pfn - zone->zone_start_pfn;
> +	pfn = pfn - round_down(zone->start_pfn, pageblock_nr_pages);
>   	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
>   #endif /* CONFIG_SPARSEMEM */
>   }
>

Sorry for the spam, please ignore this one. This has a typo. Third times 
the charm.

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
