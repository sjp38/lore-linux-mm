Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1297A6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 05:46:44 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so116404524lfg.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 02:46:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r138si701575wmg.36.2016.06.27.02.46.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 02:46:42 -0700 (PDT)
Subject: Re: [PATCH v3 5/6] mm/cma: remove MIGRATE_CMA
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464243748-16367-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <087368b2-19d3-30e0-e420-456c291f16c9@suse.cz>
Date: Mon, 27 Jun 2016 11:46:39 +0200
MIME-Version: 1.0
In-Reply-To: <1464243748-16367-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/26/2016 08:22 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Now, all reserved pages for CMA region are belong to the ZONE_CMA
> and there is no other type of pages. Therefore, we don't need to
> use MIGRATE_CMA to distinguish and handle differently for CMA pages
> and ordinary pages. Remove MIGRATE_CMA.
>
> Unfortunately, this patch make free CMA counter incorrect because
> we count it when pages are on the MIGRATE_CMA. It will be fixed
> by next patch. I can squash next patch here but it makes changes
> complicated and hard to review so I separate that.

Doesn't sound like a big deal.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

[...]

> @@ -7442,14 +7401,14 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  	 * allocator removing them from the buddy system.  This way
>  	 * page allocator will never consider using them.
>  	 *
> -	 * This lets us mark the pageblocks back as
> -	 * MIGRATE_CMA/MIGRATE_MOVABLE so that free pages in the
> -	 * aligned range but not in the unaligned, original range are
> -	 * put back to page allocator so that buddy can use them.
> +	 * This lets us mark the pageblocks back as MIGRATE_MOVABLE
> +	 * so that free pages in the aligned range but not in the
> +	 * unaligned, original range are put back to page allocator
> +	 * so that buddy can use them.
>  	 */
>
>  	ret = start_isolate_page_range(pfn_max_align_down(start),
> -				       pfn_max_align_up(end), migratetype,
> +				       pfn_max_align_up(end), MIGRATE_MOVABLE,
>  				       false);
>  	if (ret)
>  		return ret;
> @@ -7528,7 +7487,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>
>  done:
>  	undo_isolate_page_range(pfn_max_align_down(start),
> -				pfn_max_align_up(end), migratetype);
> +				pfn_max_align_up(end), MIGRATE_MOVABLE);
>  	return ret;
>  }

Looks like all callers of {start,undo}_isolate_page_range() now use 
MIGRATE_MOVABLE, so it could be removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
