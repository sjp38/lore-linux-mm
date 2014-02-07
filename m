Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0866B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 04:36:18 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id a1so2120435wgh.16
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 01:36:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si1973470wjz.136.2014.02.07.01.36.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 01:36:16 -0800 (PST)
Message-ID: <52F4A90D.20804@suse.cz>
Date: Fri, 07 Feb 2014 10:36:13 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm/compaction: do not call suitable_migration_target()
 on every page
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com> <1391749726-28910-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1391749726-28910-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/07/2014 06:08 AM, Joonsoo Kim wrote:
> suitable_migration_target() checks that pageblock is suitable for
> migration target. In isolate_freepages_block(), it is called on every
> page and this is inefficient. So make it called once per pageblock.

Hmm but in sync compaction, compact_checklock_irqsave() may drop the zone->lock,
reschedule and reacquire it and thus possibly invalidate your previous check. Async
compaction is ok as that will quit immediately. So you could probably communicate that
this happened and invalidate checked_pageblock in such case. Or maybe this would not
happen too enough to worry about rare suboptimal migrations?

Vlastimil

> suitable_migration_target() also checks if page is highorder or not,
> but it's criteria for highorder is pageblock order. So calling it once
> within pageblock range has no problem.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index bbe1260..0d821a2 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -245,6 +245,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  	unsigned long nr_strict_required = end_pfn - blockpfn;
>  	unsigned long flags;
>  	bool locked = false;
> +	bool checked_pageblock = false;
>  
>  	cursor = pfn_to_page(blockpfn);
>  
> @@ -275,8 +276,16 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  			break;
>  
>  		/* Recheck this is a suitable migration target under lock */
> -		if (!strict && !suitable_migration_target(page))
> -			break;
> +		if (!strict && !checked_pageblock) {
> +			/*
> +			 * We need to check suitability of pageblock only once
> +			 * and this isolate_freepages_block() is called with
> +			 * pageblock range, so just check once is sufficient.
> +			 */
> +			checked_pageblock = true;
> +			if (!suitable_migration_target(page))
> +				break;
> +		}
>  
>  		/* Recheck this is a buddy page under lock */
>  		if (!PageBuddy(page))
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
