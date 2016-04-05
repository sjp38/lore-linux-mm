Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5156B0005
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 08:03:11 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id u206so1060016wme.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 05:03:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i69si18758042wmc.104.2016.04.05.05.03.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Apr 2016 05:03:10 -0700 (PDT)
Subject: Re: [PATCH v3 04/16] mm/balloon: use general movable page feature
 into balloon
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-5-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5703A979.402@suse.cz>
Date: Tue, 5 Apr 2016 14:03:05 +0200
MIME-Version: 1.0
In-Reply-To: <1459321935-3655-5-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Gioh Kim <gurugio@hanmail.net>

On 03/30/2016 09:12 AM, Minchan Kim wrote:
> Now, VM has a feature to migrate non-lru movable pages so
> balloon doesn't need custom migration hooks in migrate.c
> and compact.c. Instead, this patch implements page->mapping
> ->{isolate|migrate|putback} functions.
>
> With that, we could remove hooks for ballooning in general
> migration functions and make balloon compaction simple.
>
> Cc: virtualization@lists.linux-foundation.org
> Cc: Rafael Aquini <aquini@redhat.com>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Signed-off-by: Gioh Kim <gurugio@hanmail.net>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

I'm not familiar with the inode and pseudofs stuff, so just some things 
I noticed:

> -#define PAGE_MOVABLE_MAPCOUNT_VALUE (-255)
> +#define PAGE_MOVABLE_MAPCOUNT_VALUE (-256)
> +#define PAGE_BALLOON_MAPCOUNT_VALUE PAGE_MOVABLE_MAPCOUNT_VALUE
>
>   static inline int PageMovable(struct page *page)
>   {
> -	return ((test_bit(PG_movable, &(page)->flags) &&
> -		atomic_read(&page->_mapcount) == PAGE_MOVABLE_MAPCOUNT_VALUE)
> -		|| PageBalloon(page));
> +	return (test_bit(PG_movable, &(page)->flags) &&
> +		atomic_read(&page->_mapcount) == PAGE_MOVABLE_MAPCOUNT_VALUE);
>   }
>
>   /* Caller should hold a PG_lock */
> @@ -645,6 +626,35 @@ static inline void __ClearPageMovable(struct page *page)
>
>   PAGEFLAG(Isolated, isolated, PF_ANY);
>
> +static inline int PageBalloon(struct page *page)
> +{
> +	return atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE
> +		&& PagePrivate2(page);
> +}

Hmm so you are now using PG_private_2 flag here, but it's not 
documented. Also the only caller of PageBalloon() seems to be 
stable_page_flags(). Which will now report all movable pages with 
PG_private_2 as KPF_BALOON. Seems like an overkill and also not 
reliable. Could it test e.g. page->mapping instead?

Or maybe if we manage to get rid of PAGE_MOVABLE_MAPCOUNT_VALUE, we can 
keep PAGE_BALLOON_MAPCOUNT_VALUE to simply distinguish balloon pages for 
stable_page_flags().

> @@ -1033,7 +1019,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>   out:
>   	/* If migration is successful, move newpage to right list */
>   	if (rc == MIGRATEPAGE_SUCCESS) {
> -		if (unlikely(__is_movable_balloon_page(newpage)))
> +		if (unlikely(PageMovable(newpage)))
>   			put_page(newpage);
>   		else
>   			putback_lru_page(newpage);

Hmm shouldn't the condition have been changed to

if (unlikely(__is_movable_balloon_page(newpage)) || PageMovable(newpage)

by patch 02/16? And this patch should be just removing the 
balloon-specific check? Otherwise it seems like between patches 02 and 
04, other kinds of PageMovable pages were unnecessarily/wrongly routed 
through putback_lru_page()?

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d82196244340..c7696a2e11c7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1254,7 +1254,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>
>   	list_for_each_entry_safe(page, next, page_list, lru) {
>   		if (page_is_file_cache(page) && !PageDirty(page) &&
> -		    !isolated_balloon_page(page)) {
> +		    !PageIsolated(page)) {
>   			ClearPageActive(page);
>   			list_move(&page->lru, &clean_pages);
>   		}

This looks like the same comment as above at first glance. But looking 
closer, it's even weirder. isolated_balloon_page() was simply 
PageBalloon() after d6d86c0a7f8dd... weird already. You replace it with 
check for !PageIsolated() which looks like a more correct check, so ok. 
Except the potential false positive with PG_owner_priv_1.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
