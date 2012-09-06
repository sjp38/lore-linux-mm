Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 5DF376B006C
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 12:34:53 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M9X00KSBSQ3N030@mailout4.samsung.com> for
 linux-mm@kvack.org; Fri, 07 Sep 2012 01:34:51 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M9X001LCSQ1H730@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 07 Sep 2012 01:34:51 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [RFC v2] memory-hotplug: remove MIGRATE_ISOLATE from
 free_area->free_list
Date: Thu, 06 Sep 2012 18:34:35 +0200
References: <1346900018-14759-1-git-send-email-minchan@kernel.org>
In-reply-to: <1346900018-14759-1-git-send-email-minchan@kernel.org>
MIME-version: 1.0
Message-id: <201209061834.35473.b.zolnierkie@samsung.com>
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mel@csn.ul.ie>, Wen Congyang <wency@cn.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>


Hi,

On Thursday 06 September 2012 04:53:38 Minchan Kim wrote:
> Normally, MIGRATE_ISOLATE type is used for memory-hotplug.
> But it's irony type because the pages isolated would exist
> as free page in free_area->free_list[MIGRATE_ISOLATE] so people
> can think of it as allocatable pages but it is *never* allocatable.
> It ends up confusing NR_FREE_PAGES vmstat so it would be
> totally not accurate so some of place which depend on such vmstat
> could reach wrong decision by the context.
> 
> There were already report about it.[1]
> [1] 702d1a6e, memory-hotplug: fix kswapd looping forever problem
> 
> Then, there was other report which is other problem.[2]
> [2] http://www.spinics.net/lists/linux-mm/msg41251.html
> 
> I believe it can make problems in future, too.
> So I hope removing such irony type by another design.
> 
> I hope this patch solves it and let's revert [1] and doesn't need [2].
> 
> * Changelog v1
>  * Fix from Michal's many suggestion
> 
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Wen Congyang <wency@cn.fujitsu.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> It's very early version which show the concept so I still marked it with RFC.
> I just tested it with simple test and works.
> This patch is needed indepth review from memory-hotplug guys from fujitsu
> because I saw there are lots of patches recenlty they sent to about
> memory-hotplug change. Please take a look at this patch.

[...]

> @@ -948,8 +954,13 @@ static int move_freepages(struct zone *zone,
>  		}
>  
>  		order = page_order(page);
> -		list_move(&page->lru,
> -			  &zone->free_area[order].free_list[migratetype]);
> +		if (migratetype != MIGRATE_ISOLATE) {
> +			list_move(&page->lru,
> +				&zone->free_area[order].free_list[migratetype]);
> +		} else {
> +			list_del(&page->lru);
> +			isolate_free_page(page, order);
> +		}
>  		page += 1 << order;
>  		pages_moved += 1 << order;
>  	}

Shouldn't NR_FREE_PAGES counter be decreased somewhere above?

[ I can see that it is not modified in __free_pages_ok() and
  free_hot_cold_page() because page is still counted as non-free one but
  here situation is different AFAICS. ]

I tested the patch locally here with CONFIG_CMA=y and it causes some
major problems for CMA (multiple errors from dma_alloc_from_contiguous()
about memory ranges being busy and allocation failures).

[ I'm sorry that I don't know more details yet but the issue should be
  easily reproducible. ]

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
