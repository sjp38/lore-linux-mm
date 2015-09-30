Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 35D836B026B
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 10:17:47 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so199136298wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 07:17:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yv9si1025585wjc.67.2015.09.30.07.17.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 07:17:46 -0700 (PDT)
Subject: Re: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for order-0
 allocations
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <20150921120317.GC3068@techsingularity.net>
 <20150929140507.82b5e02f300038e4bb5b2493@linux-foundation.org>
 <20150930084650.GM3068@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <560BEF08.60704@suse.cz>
Date: Wed, 30 Sep 2015 16:17:44 +0200
MIME-Version: 1.0
In-Reply-To: <20150930084650.GM3068@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/30/2015 10:46 AM, Mel Gorman wrote:
> On Tue, Sep 29, 2015 at 02:05:07PM -0700, Andrew Morton wrote:
>
> The wizard of oz because because!
>
> This should fix it up better than clicking my shoes three times.
>
> ---8<---
> From: Mel Gorman <mgorman@techsingularity.net>
> Subject: [PATCH] mm, page_alloc: only enforce watermarks for order-0
>   allocations -fix
>
> This patch is updating comments for clarity and converts a bool to an
> int. The code as-is is ok as the compiler is meant to cast it correctly
> but it looks odd to people who know the value would be truncated and
> lost for other types.
>
> This is a fix to the mmotm patch
> mm-page_alloc-only-enforce-watermarks-for-order-0-allocations.patch
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Ack (with nitpick below)

> ---
>   mm/page_alloc.c | 11 ++++++++---
>   1 file changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 25731624d734..fedec98aafca 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2332,7 +2332,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>   {
>   	long min = mark;
>   	int o;
> -	const bool alloc_harder = (alloc_flags & ALLOC_HARDER);
> +	const int alloc_harder = (alloc_flags & ALLOC_HARDER);

How bout the !!(alloc_flags & ALLOC_HARDER) conversion to bool? Unless 
it forces to make the compiler some extra work...

>
>   	/* free_pages may go negative - that's OK */
>   	free_pages -= (1 << order) - 1;
> @@ -2356,14 +2356,19 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>   		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
>   #endif
>
> +	/*
> +	 * Check watermarks for an order-0 allocation request. If these
> +	 * are not met, then a high-order request also cannot go ahead
> +	 * even if a suitable page happened to be free.
> +	 */
>   	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
>   		return false;
>
> -	/* order-0 watermarks are ok */
> +	/* If this is an order-0 request then the watermark is fine */
>   	if (!order)
>   		return true;
>
> -	/* Check at least one high-order page is free */
> +	/* For a high-order request, check at least one suitable page is free */
>   	for (o = order; o < MAX_ORDER; o++) {
>   		struct free_area *area = &z->free_area[o];
>   		int mt;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
