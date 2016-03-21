Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 96D096B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 03:13:08 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id n5so254466568pfn.2
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 00:13:08 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id fk7si19991304pac.50.2016.03.21.00.13.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 00:13:07 -0700 (PDT)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8; format=flowed
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0O4D02P9GO1TORE0@mailout4.samsung.com> for linux-mm@kvack.org;
 Mon, 21 Mar 2016 16:13:05 +0900 (KST)
Content-transfer-encoding: 8BIT
Message-id: <56EF9F27.9060400@samsung.com>
Date: Mon, 21 Mar 2016 16:13:43 +0900
From: Chulmin Kim <cmlaika.kim@samsung.com>
Subject: Re: [PATCH v2 01/18] mm: use put_page to free page instead of
 putback_lru_page
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
 <1458541867-27380-2-git-send-email-minchan@kernel.org>
In-reply-to: <1458541867-27380-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org

On 2016e?? 03i?? 21i? 1/4  15:30, Minchan Kim wrote:
> Procedure of page migration is as follows:
>
> First of all, it should isolate a page from LRU and try to
> migrate the page. If it is successful, it releases the page
> for freeing. Otherwise, it should put the page back to LRU
> list.
>
> For LRU pages, we have used putback_lru_page for both freeing
> and putback to LRU list. It's okay because put_page is aware of
> LRU list so if it releases last refcount of the page, it removes
> the page from LRU list. However, It makes unnecessary operations
> (e.g., lru_cache_add, pagevec and flags operations. It would be
> not significant but no worth to do) and harder to support new
> non-lru page migration because put_page isn't aware of non-lru
> page's data structure.
>
> To solve the problem, we can add new hook in put_page with
> PageMovable flags check but it can increase overhead in
> hot path and needs new locking scheme to stabilize the flag check
> with put_page.
>
> So, this patch cleans it up to divide two semantic(ie, put and putback).
> If migration is successful, use put_page instead of putback_lru_page and
> use putback_lru_page only on failure. That makes code more readable
> and doesn't add overhead in put_page.
>
> Comment from Vlastimil
> "Yeah, and compaction (perhaps also other migration users) has to drain
> the lru pvec... Getting rid of this stuff is worth even by itself."
>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   mm/migrate.c | 50 +++++++++++++++++++++++++++++++-------------------
>   1 file changed, 31 insertions(+), 19 deletions(-)
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 6c822a7b27e0..b65c84267ce0 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -913,6 +913,14 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>   		put_anon_vma(anon_vma);
>   	unlock_page(page);
>   out:
> +	/* If migration is scucessful, move newpage to right list */

A minor comment fix :)
  +	/* If migration is successful, move newpage to right list */


> +	if (rc == MIGRATEPAGE_SUCCESS) {
> +		if (unlikely(__is_movable_balloon_page(newpage)))
> +			put_page(newpage);
> +		else
> +			putback_lru_page(newpage);
> +	}
> +
>   	return rc;
>   }
>
> @@ -946,6 +954,12 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>
>   	if (page_count(page) == 1) {
>   		/* page was freed from under us. So we are done. */
> +		ClearPageActive(page);
> +		ClearPageUnevictable(page);
> +		if (put_new_page)
> +			put_new_page(newpage, private);
> +		else
> +			put_page(newpage);
>   		goto out;
>   	}
>
> @@ -958,10 +972,8 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>   	}
>
>   	rc = __unmap_and_move(page, newpage, force, mode);
> -	if (rc == MIGRATEPAGE_SUCCESS) {
> -		put_new_page = NULL;
> +	if (rc == MIGRATEPAGE_SUCCESS)
>   		set_page_owner_migrate_reason(newpage, reason);
> -	}
>
>   out:
>   	if (rc != -EAGAIN) {
> @@ -974,28 +986,28 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>   		list_del(&page->lru);
>   		dec_zone_page_state(page, NR_ISOLATED_ANON +
>   				page_is_file_cache(page));
> -		/* Soft-offlined page shouldn't go through lru cache list */
> +	}
> +
> +	/*
> +	 * If migration is successful, drop the reference grabbed during
> +	 * isolation. Otherwise, restore the page to LRU list unless we
> +	 * want to retry.
> +	 */
> +	if (rc == MIGRATEPAGE_SUCCESS) {
> +		put_page(page);
>   		if (reason == MR_MEMORY_FAILURE) {
> -			put_page(page);
>   			if (!test_set_page_hwpoison(page))
>   				num_poisoned_pages_inc();
> -		} else
> +		}
> +	} else {
> +		if (rc != -EAGAIN)
>   			putback_lru_page(page);
> +		if (put_new_page)
> +			put_new_page(newpage, private);
> +		else
> +			put_page(newpage);
>   	}
>
> -	/*
> -	 * If migration was not successful and there's a freeing callback, use
> -	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
> -	 * during isolation.
> -	 */
> -	if (put_new_page)
> -		put_new_page(newpage, private);
> -	else if (unlikely(__is_movable_balloon_page(newpage))) {
> -		/* drop our reference, page already in the balloon */
> -		put_page(newpage);
> -	} else
> -		putback_lru_page(newpage);
> -
>   	if (result) {
>   		if (rc)
>   			*result = rc;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
