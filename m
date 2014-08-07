Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7B36B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 09:49:21 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so5059271wib.17
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 06:49:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14si16164958wie.61.2014.08.07.06.49.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 06:49:20 -0700 (PDT)
Message-ID: <53E383DD.6090500@suse.cz>
Date: Thu, 07 Aug 2014 15:49:17 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/8] mm/isolation: remove unstable check for isolated
 page
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com> <1407309517-3270-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1407309517-3270-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/06/2014 09:18 AM, Joonsoo Kim wrote:
> The check '!PageBuddy(page) && page_count(page) == 0 &&
> migratetype == MIGRATE_ISOLATE' would mean the page on free processing.

What is "the page on free processing"? I thought this test means the 
page is on some CPU's pcplist?

> Although it could go into buddy allocator within a short time,
> futher operation such as isolate_freepages_range() in CMA, called after
> test_page_isolated_in_pageblock(), could be failed due to this unstability

By "unstability" you mean the page can be allocated again from the 
pcplist instead of being freed to buddy list?

> since it requires that the page is on buddy. I think that removing
> this unstability is good thing.
>
> And, following patch makes isolated freepage has new status matched with
> this condition and this check is the obstacle to that change. So remove
> it.

You could also say that pages from isolated pageblocks can no longer 
appear on pcplists after the later patches.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/page_isolation.c |    6 +-----
>   1 file changed, 1 insertion(+), 5 deletions(-)
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index d1473b2..3100f98 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -198,11 +198,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>   						MIGRATE_ISOLATE);
>   			}
>   			pfn += 1 << page_order(page);
> -		}
> -		else if (page_count(page) == 0 &&
> -			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
> -			pfn += 1;
> -		else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
> +		} else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
>   			/*
>   			 * The HWPoisoned page may be not in buddy
>   			 * system, and page_count() is not 0.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
