Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5509A6B009C
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 11:49:56 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q58so1631272wes.24
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 08:49:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gt3si5928267wib.8.2014.02.20.08.49.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Feb 2014 08:49:54 -0800 (PST)
Message-ID: <5306322E.3030607@suse.cz>
Date: Thu, 20 Feb 2014 17:49:50 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/5] mm/compaction: do not call suitable_migration_target()
 on every page
References: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com> <1392360843-22261-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392360843-22261-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/14/2014 07:54 AM, Joonsoo Kim wrote:
> suitable_migration_target() checks that pageblock is suitable for
> migration target. In isolate_freepages_block(), it is called on every
> page and this is inefficient. So make it called once per pageblock.
>
> suitable_migration_target() also checks if page is highorder or not,
> but it's criteria for highorder is pageblock order. So calling it once
> within pageblock range has no problem.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> diff --git a/mm/compaction.c b/mm/compaction.c
> index bbe1260..0d821a2 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -245,6 +245,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>   	unsigned long nr_strict_required = end_pfn - blockpfn;
>   	unsigned long flags;
>   	bool locked = false;
> +	bool checked_pageblock = false;
>
>   	cursor = pfn_to_page(blockpfn);
>
> @@ -275,8 +276,16 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>   			break;
>
>   		/* Recheck this is a suitable migration target under lock */
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
>   		/* Recheck this is a buddy page under lock */
>   		if (!PageBuddy(page))
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
