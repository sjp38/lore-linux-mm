Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 375188E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 08:18:06 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i55so1105882ede.14
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 05:18:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x52si9407032edx.285.2019.01.15.05.18.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 05:18:04 -0800 (PST)
Subject: Re: [PATCH 10/25] mm, compaction: Ignore the fragmentation avoidance
 boost for isolation and compaction
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-11-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <99d75a89-ef07-683a-761d-f800c53cc910@suse.cz>
Date: Tue, 15 Jan 2019 14:18:03 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-11-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:49 PM, Mel Gorman wrote:
> When pageblocks get fragmented, watermarks are artifically boosted to
> reclaim pages to avoid further fragmentation events. However, compaction
> is often either fragmentation-neutral or moving movable pages away from
> unmovable/reclaimable pages. As the true watermarks are preserved, allow
> compaction to ignore the boost factor.
> 
> The expected impact is very slight as the main benefit is that compaction
> is slightly more likely to succeed when the system has been fragmented
> very recently. On both 1-socket and 2-socket machines for THP-intensive
> allocation during fragmentation the success rate was increased by less
> than 1% which is marginal. However, detailed tracing indicated that
> failure of migration due to a premature ENOMEM triggered by watermark
> checks were eliminated.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 57ba9d1da519..05c9a81d54ed 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2958,7 +2958,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  		 * watermark, because we already know our high-order page
>  		 * exists.
>  		 */
> -		watermark = min_wmark_pages(zone) + (1UL << order);
> +		watermark = zone->_watermark[WMARK_MIN] + (1UL << order);
>  		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
>  			return 0;
>  
> 
