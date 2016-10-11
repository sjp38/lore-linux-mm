Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D57136B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 05:40:38 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id d186so10536522lfg.7
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 02:40:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cv8si3846090wjc.92.2016.10.11.02.40.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 02:40:37 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm: adjust reserved highatomic count
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-2-git-send-email-minchan@kernel.org>
 <7ac7c0d8-4b7b-e362-08e7-6d62ee20f4c3@suse.cz> <20161007142919.GA3060@bbox>
 <c0920ac2-fe63-567e-e24c-eb6d638143b0@suse.cz> <20161011041916.GA30973@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c177a63f-d243-b291-44a8-51217a602b5e@suse.cz>
Date: Tue, 11 Oct 2016 11:40:33 +0200
MIME-Version: 1.0
In-Reply-To: <20161011041916.GA30973@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On 10/11/2016 06:19 AM, Minchan Kim wrote:
> Hi Vlasimil,
>
> On Mon, Oct 10, 2016 at 08:57:40AM +0200, Vlastimil Babka wrote:
>> On 10/07/2016 04:29 PM, Minchan Kim wrote:
>> >>>In that case, we should adjust nr_reserved_highatomic.
>> >>>Otherwise, VM cannot reserve highorderatomic pageblocks any more
>> >>>although it doesn't reach 1% limit. It means highorder atomic
>> >>>allocation failure would be higher.
>> >>>
>> >>>So, this patch decreases the account as well as migratetype
>> >>>if it was MIGRATE_HIGHATOMIC.
>> >>>
>> >>>Signed-off-by: Minchan Kim <minchan@kernel.org>
>> >>
>> >>Hm wouldn't it be simpler just to prevent the pageblock's migratetype to be
>> >>changed if it's highatomic? Possibly also not do move_freepages_block() in
>> >
>> >It could be. Actually, I did it with modifying can_steal_fallback which returns
>> >false it found the pageblock is highorderatomic but changed to this way again
>> >because I don't have any justification to prevent changing pageblock.
>> >If you give concrete justification so others isn't against on it, I am happy to
>> >do what you suggested.
>>
>> Well, MIGRATE_HIGHATOMIC is not listed in the fallbacks array at all, so we
>> are not supposed to steal from it in the first place. Stealing will only
>> happen due to races, which would be too costly to close, so we allow them
>> and expect to be rare. But we shouldn't allow them to break the accounting.
>>
>
> Fair enough.
> How about this?

Look sgood.

> From 4a0b6a74ebf1af7f90720b0028da49e2e2a2b679 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Thu, 6 Oct 2016 13:38:35 +0900
> Subject: [PATCH] mm: don't steal highatomic pageblock
>
> In page freeing path, migratetype is racy so that a highorderatomic
> page could free into non-highorderatomic free list. If that page
> is allocated, VM can change the pageblock from higorderatomic to
> something. In that case, highatomic pageblock accounting is broken
> so it doesn't work(e.g., VM cannot reserve highorderatomic pageblocks
> any more although it doesn't reach 1% limit).
>
> So, this patch prohibits the changing from highatomic to other type.
> It's no problem because MIGRATE_HIGHATOMIC is not listed in fallback
> array so stealing will only happen due to unexpected races which is
> really rare. Also, such prohibiting keeps highatomic pageblock more
> longer so it would be better for highorderatomic page allocation.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 55ad0229ebf3..79853b258211 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2154,7 +2154,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>
>  		page = list_first_entry(&area->free_list[fallback_mt],
>  						struct page, lru);
> -		if (can_steal)
> +		if (can_steal &&
> +			get_pageblock_migratetype(page) != MIGRATE_HIGHATOMIC)
>  			steal_suitable_fallback(zone, page, start_migratetype);
>
>  		/* Remove the page from the freelists */
> @@ -2555,7 +2556,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  		struct page *endpage = page + (1 << order) - 1;
>  		for (; page < endpage; page += pageblock_nr_pages) {
>  			int mt = get_pageblock_migratetype(page);
> -			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
> +			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)
> +				&& mt != MIGRATE_HIGHATOMIC)
>  				set_pageblock_migratetype(page,
>  							  MIGRATE_MOVABLE);
>  		}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
