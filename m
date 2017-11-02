Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6457B6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:32:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 5so2720546wmk.13
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:32:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g20si103762edc.164.2017.11.02.06.32.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 06:32:35 -0700 (PDT)
Date: Thu, 2 Nov 2017 14:32:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 1/1] mm: buddy page accessed before initialized
Message-ID: <20171102133235.2vfmmut6w4of2y3j@dhcp22.suse.cz>
References: <20171031155002.21691-1-pasha.tatashin@oracle.com>
 <20171031155002.21691-2-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031155002.21691-2-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 31-10-17 11:50:02, Pavel Tatashin wrote:
[...]
> The problem happens in this path:
> 
> page_alloc_init_late
>   deferred_init_memmap
>     deferred_init_range
>       __def_free
>         deferred_free_range
>           __free_pages_boot_core(page, order)
>             __free_pages()
>               __free_pages_ok()
>                 free_one_page()
>                   __free_one_page(page, pfn, zone, order, migratetype);
> 
> deferred_init_range() initializes one page at a time by calling
> __init_single_page(), once it initializes pageblock_nr_pages pages, it
> calls deferred_free_range() to free the initialized pages to the buddy
> allocator. Eventually, we reach __free_one_page(), where we compute buddy
> page:
> 	buddy_pfn = __find_buddy_pfn(pfn, order);
> 	buddy = page + (buddy_pfn - pfn);
> 
> buddy_pfn is computed as pfn ^ (1 << order), or pfn + pageblock_nr_pages.
> Thefore, buddy page becomes a page one after the range that currently was
> initialized, and we access this page in this function. Also, later when we
> return back to deferred_init_range(), the buddy page is initialized again.
> 
> So, in order to avoid this issue, we must initialize the buddy page prior
> to calling deferred_free_range().

How come we didn't have this problem previously? I am really confused.

> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  mm/page_alloc.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 97687b38da05..f3ea06db3eed 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1500,9 +1500,17 @@ static unsigned long deferred_init_range(int nid, int zid, unsigned long pfn,
>  			__init_single_page(page, pfn, zid, nid);
>  			nr_free++;
>  		} else {
> -			nr_pages += __def_free(&nr_free, &free_base_pfn, &page);
>  			page = pfn_to_page(pfn);
>  			__init_single_page(page, pfn, zid, nid);
> +			/*
> +			 * We must free previous range after initializing the
> +			 * first page of the next range. This is because first
> +			 * page may be accessed in __free_one_page(), when buddy
> +			 * page is computed:
> +			 *   buddy_pfn = pfn + pageblock_nr_pages
> +			 */
> +			deferred_free_range(free_base_pfn, nr_free);
> +			nr_pages += nr_free;
>  			free_base_pfn = pfn;
>  			nr_free = 1;
>  			cond_resched();
> -- 
> 2.14.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
