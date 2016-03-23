Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC496B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 10:47:50 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id p65so237127072wmp.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 07:47:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d81si4150970wmc.85.2016.03.23.07.47.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 07:47:49 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm/vmstat: add zone range overlapping check
References: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1457940697-2278-5-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56F2AC92.9070600@suse.cz>
Date: Wed, 23 Mar 2016 15:47:46 +0100
MIME-Version: 1.0
In-Reply-To: <1457940697-2278-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/14/2016 08:31 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> There is a system that node's pfn are overlapped like as following.
>
> -----pfn-------->
> N0 N1 N2 N0 N1 N2
>
> Therefore, we need to care this overlapping when iterating pfn range.
>
> There are two places in vmstat.c that iterates pfn range and
> they don't consider this overlapping. Add it.
>
> Without this patch, above system could over count pageblock number
> on a zone.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/vmstat.c | 7 +++++++
>   1 file changed, 7 insertions(+)
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 5e43004..0a726e3 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1010,6 +1010,9 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
>   		if (!memmap_valid_within(pfn, page, zone))
>   			continue;

The above already does this for each page within the block, but it's 
guarded by CONFIG_ARCH_HAS_HOLES_MEMORYMODEL. I guess that's not the 
case of your system, right?

I guess your added check should go above this, though. Also what about 
employing pageblock_pfn_to_page() here and in all other applicable 
places, so it's unified and optimized by zone->contiguous?

>
> +		if (page_zone(page) != zone)
> +			continue;
> +
>   		mtype = get_pageblock_migratetype(page);
>
>   		if (mtype < MIGRATE_TYPES)
> @@ -1076,6 +1079,10 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
>   				continue;
>
>   			page = pfn_to_page(pfn);
> +
> +			if (page_zone(page) != zone)
> +				continue;
> +
>   			if (PageBuddy(page)) {
>   				pfn += (1UL << page_order(page)) - 1;
>   				continue;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
