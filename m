Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 653586B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 04:43:09 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id yr2so38482630wjc.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 01:43:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15si2360677wmc.25.2017.01.26.01.43.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 01:43:08 -0800 (PST)
Date: Thu, 26 Jan 2017 10:43:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v2 PATCH] mm/hotplug: enable memory hotplug for non-lru
 movable pages
Message-ID: <20170126094303.GE6590@dhcp22.suse.cz>
References: <1485327585-62872-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485327585-62872-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, arbab@linux.vnet.ibm.com, vkuznets@redhat.com, ak@linux.intel.com, n-horiguchi@ah.jp.nec.com, minchan@kernel.org, qiuxishi@huawei.com, guohanjun@huawei.com

On Wed 25-01-17 14:59:45, Yisheng Xie wrote:
> We had considered all of the non-lru pages as unmovable before
> commit bda807d44454 ("mm: migrate: support non-lru movable page
> migration"). But now some of non-lru pages like zsmalloc,
> virtio-balloon pages also become movable. So we can offline such
> blocks by using non-lru page migration.
> 
> This patch straightforwardly add non-lru migration code, which
> means adding non-lru related code to the functions which scan
> over pfn and collect pages to be migrated and isolate them before
> migration.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
> v2
>  make a minor change about lock_page logic in function scan_movable_pages.
> 
>  mm/memory_hotplug.c | 36 +++++++++++++++++++++++++-----------
>  mm/page_alloc.c     |  8 ++++++--
>  2 files changed, 31 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e43142c1..5559175 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1510,10 +1510,10 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
>  }
>  
>  /*
> - * Scan pfn range [start,end) to find movable/migratable pages (LRU pages
> - * and hugepages). We scan pfn because it's much easier than scanning over
> - * linked list. This function returns the pfn of the first found movable
> - * page if it's found, otherwise 0.
> + * Scan pfn range [start,end) to find movable/migratable pages (LRU pages,
> + * non-lru movable pages and hugepages). We scan pfn because it's much
> + * easier than scanning over linked list. This function returns the pfn
> + * of the first found movable page if it's found, otherwise 0.
>   */
>  static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  {
> @@ -1531,6 +1531,16 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  					pfn = round_up(pfn + 1,
>  						1 << compound_order(page)) - 1;
>  			}
> +			/*
> +			 * check __PageMovable in lock_page to avoid miss some
> +			 * non-lru movable pages at race condition.
> +			 */
> +			lock_page(page);
> +			if (__PageMovable(page)) {
> +				unlock_page(page);
> +				return pfn;
> +			}
> +			unlock_page(page);

This doesn't make any sense to me. __PageMovable can change right after
you drop the lock so why the race matters? If we cannot tolerate races
then the above doesn't work and if we can then taking the lock is
pointless.

>  		}
>  	}
>  	return 0;
> @@ -1600,21 +1610,25 @@ static struct page *new_node_page(struct page *page, unsigned long private,
>  		if (!get_page_unless_zero(page))
>  			continue;
>  		/*
> -		 * We can skip free pages. And we can only deal with pages on
> -		 * LRU.
> +		 * We can skip free pages. And we can deal with pages on
> +		 * LRU and non-lru movable pages.
>  		 */
> -		ret = isolate_lru_page(page);
> +		if (PageLRU(page))
> +			ret = isolate_lru_page(page);
> +		else
> +			ret = !isolate_movable_page(page, ISOLATE_UNEVICTABLE);

we really want to propagate the proper error code to the caller.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
