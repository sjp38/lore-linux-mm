Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC2D6B006E
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 04:14:48 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x13so232353wgg.19
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 01:14:47 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lq1si1098572wjb.25.2014.12.09.01.14.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 01:14:47 -0800 (PST)
Message-ID: <5486BD85.1010903@suse.cz>
Date: Tue, 09 Dec 2014 10:14:45 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: page_isolation: remove redundant moving for isolated
 buddy pages
References: <000101d01384$fac61240$f05236c0$%yang@samsung.com>
In-Reply-To: <000101d01384$fac61240$f05236c0$%yang@samsung.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>, iamjoonsoo.kim@lge.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Minchan Kim' <minchan@kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/09/2014 08:50 AM, Weijie Yang wrote:
> The commit ad53f92e(fix incorrect isolation behavior by rechecking migratetype)
> patch series describe the race between page isolation and alloc/free path, and
> fix the race.
>
> Now, after the pageblock has been isolated, free buddy pages are already in
> the free_list[MIGRATE_ISOLATE] and will not be allocated for usage. So the
> current freepage_migratetype check is unnecessary and it will cause redundant
> page move. That is to say, even if the buddy page's migratetype is not
> MIGRATE_ISOLATE, the page is in free_list[MIGRATE_ISOLATE], we just move it
> from free_list[MIGRATE_ISOLATE] to free_list[MIGRATE_ISOLATE].
>
> This patch removes the unnecessary freepage_migratetype check and the
> redundant page moving.
>
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

With great hope that Joonsoo won't find another corner case J

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/page_isolation.c |   17 +----------------
>   1 file changed, 1 insertion(+), 16 deletions(-)
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index c8778f7..6e5174d 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -221,23 +221,8 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>   			continue;
>   		}
>   		page = pfn_to_page(pfn);
> -		if (PageBuddy(page)) {
> -			/*
> -			 * If race between isolatation and allocation happens,
> -			 * some free pages could be in MIGRATE_MOVABLE list
> -			 * although pageblock's migratation type of the page
> -			 * is MIGRATE_ISOLATE. Catch it and move the page into
> -			 * MIGRATE_ISOLATE list.
> -			 */
> -			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
> -				struct page *end_page;
> -
> -				end_page = page + (1 << page_order(page)) - 1;
> -				move_freepages(page_zone(page), page, end_page,
> -						MIGRATE_ISOLATE);
> -			}
> +		if (PageBuddy(page))
>   			pfn += 1 << page_order(page);
> -		}
>   		else if (page_count(page) == 0 &&
>   			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
>   			pfn += 1;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
