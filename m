Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 74A826B003D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 11:43:37 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id k14so1937109wgh.0
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 08:43:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bs20si41763560wib.80.2014.07.07.08.43.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 08:43:36 -0700 (PDT)
Message-ID: <53BAC023.1070504@suse.cz>
Date: Mon, 07 Jul 2014 17:43:31 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 04/10] mm/page_alloc: carefully free the page on isolate
 pageblock
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <1404460675-24456-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
> We got migratetype without holding the lock so it could be
> racy. If some pages go on the isolate migratetype buddy list
> by this race, we can't allocate this page anymore until next
> isolation attempt on this pageblock. Below is possible
> scenario of this race.
>
> pageblock 1 is isolate migratetype.
>
> CPU1					CPU2
> - get_pfnblock_migratetype(pageblock 1),
> so MIGRATE_ISOLATE is returned
> - call free_one_page() with MIGRATE_ISOLATE
> 					- grab the zone lock
> 					- unisolate pageblock 1
> 					- release the zone lock
> - grab the zone lock
> - call __free_one_page() with MIGRATE_ISOLATE
> - free page go into isolate buddy list
> and we can't use it anymore
>
> To prevent this possibility, re-check migratetype with holding the lock.

This could be also solved similarly to the other races, if during 
unisolation, CPU2 sent a drain_all_pages() IPI and only then used 
move_freepages_block(). Again, get_pfnblock_migratetype() on CPU1 would 
need to be moved under disabled irq's.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/page_alloc.c |   11 +++++++++++
>   1 file changed, 11 insertions(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 99c05f7..d8feedc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -743,6 +743,17 @@ static void free_one_page(struct zone *zone,
>   	spin_lock(&zone->lock);
>   	zone->pages_scanned = 0;
>
> +	if (unlikely(is_migrate_isolate(migratetype))) {
> +		/*
> +		 * We got migratetype without holding the lock so it could be
> +		 * racy. If some pages go on the isolate migratetype buddy list
> +		 * by this race, we can't allocate this page anymore until next
> +		 * isolation attempt on this pageblock. To prevent this
> +		 * possibility, re-check migratetype with holding the lock.
> +		 */
> +		migratetype = get_pfnblock_migratetype(page, pfn);
> +	}
> +
>   	__free_one_page(page, pfn, zone, order, migratetype);
>   	if (!is_migrate_isolate(migratetype))
>   		__mod_zone_freepage_state(zone, 1 << order, migratetype);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
