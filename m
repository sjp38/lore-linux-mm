Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id CC7416B006E
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 04:24:29 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id z12so269632wgg.1
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 01:24:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si1850630wiy.17.2014.12.09.01.24.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 01:24:28 -0800 (PST)
Message-ID: <5486BFCB.4040305@suse.cz>
Date: Tue, 09 Dec 2014 10:24:27 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: page_isolation: remove unnecessary freepage_migratetype
 check for unused page
References: <000201d01385$25a6c950$70f45bf0$%yang@samsung.com>
In-Reply-To: <000201d01385$25a6c950$70f45bf0$%yang@samsung.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>, iamjoonsoo.kim@lge.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Minchan Kim' <minchan@kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/09/2014 08:51 AM, Weijie Yang wrote:
> when we test the pages in a range is free or not, there is a little
> chance we encounter some page which is not in buddy but page_count is 0.
> That means that page could be in the page-freeing path but not in the
> buddy freelist, such as in pcplist

This shouldn't happen anymore IMHO. The pageblock is marked as 
MIGRATE_ISOLATE and then a lru+pcplist drain is performed. Nothing 
should be left on pcplist - anything newly freed goes directly to free 
lists. Hm, maybe it could be on lru cache, but that holds a page 
reference IIRC, so this test won't pass.

> or wait for the zone->lock which the
> tester is holding.

That could maybe happen, but is it worth testing? If yes, please add it 
in a comment to the code.

> Back to the freepage_migratetype, we use it for a cached value for decide
> which free-list the page go when freeing page. If the pageblock is isolated
> the page will go to free-list[MIGRATE_ISOLATE] even if the cached type is
> not MIGRATE_ISOLATE, the commit ad53f92e(fix incorrect isolation behavior
> by rechecking migratetype) patch series have ensure this.
>
> So the freepage_migratetype check for page_count==0 page in
> __test_page_isolated_in_pageblock() is meaningless.
> This patch removes the unnecessary freepage_migratetype check.
>
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> ---
>   mm/page_isolation.c |    3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 6e5174d..f7c9183 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -223,8 +223,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>   		page = pfn_to_page(pfn);
>   		if (PageBuddy(page))
>   			pfn += 1 << page_order(page);
> -		else if (page_count(page) == 0 &&
> -			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
> +		else if (page_count(page) == 0)
>   			pfn += 1;
>   		else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
>   			/*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
