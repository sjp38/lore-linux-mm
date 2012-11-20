Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id C0E546B0070
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 21:15:20 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id lz20so6907054obb.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 18:15:20 -0800 (PST)
Message-ID: <50AAE7B0.5000003@gmail.com>
Date: Tue, 20 Nov 2012 10:15:12 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFT PATCH v1 4/5] mm: provide more accurate estimation of pages
 occupied by memmap
References: <20121115112454.e582a033.akpm@linux-foundation.org> <1353254850-27336-1-git-send-email-jiang.liu@huawei.com> <1353254850-27336-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1353254850-27336-5-git-send-email-jiang.liu@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/19/2012 12:07 AM, Jiang Liu wrote:
> If SPARSEMEM is enabled, it won't build page structures for
> non-existing pages (holes) within a zone, so provide a more accurate
> estimation of pages occupied by memmap if there are big holes within
> the zone.
>
> And pages for highmem zones' memmap will be allocated from lowmem,
> so charge nr_kernel_pages for that.
>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> ---
>   mm/page_alloc.c |   22 ++++++++++++++++++++--
>   1 file changed, 20 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b327d7..eb25679 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4435,6 +4435,22 @@ void __init set_pageblock_order(void)
>   
>   #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
>   
> +static unsigned long calc_memmap_size(unsigned long spanned_pages,
> +				      unsigned long present_pages)
> +{
> +	unsigned long pages = spanned_pages;
> +
> +	/*
> +	 * Provide a more accurate estimation if there are big holes within
> +	 * the zone and SPARSEMEM is in use.
> +	 */
> +	if (spanned_pages > present_pages + (present_pages >> 4) &&
> +	    IS_ENABLED(CONFIG_SPARSEMEM))
> +		pages = present_pages;
> +
> +	return PAGE_ALIGN(pages * sizeof(struct page)) >> PAGE_SHIFT;
> +}
> +
>   /*
>    * Set up the zone data structures:
>    *   - mark all pages reserved
> @@ -4469,8 +4485,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>   		 * is used by this zone for memmap. This affects the watermark
>   		 * and per-cpu initialisations
>   		 */
> -		memmap_pages =
> -			PAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHIFT;
> +		memmap_pages = calc_memmap_size(size, realsize);
>   		if (freesize >= memmap_pages) {
>   			freesize -= memmap_pages;
>   			if (memmap_pages)
> @@ -4491,6 +4506,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>   
>   		if (!is_highmem_idx(j))
>   			nr_kernel_pages += freesize;
> +		/* Charge for highmem memmap if there are enough kernel pages */
> +		else if (nr_kernel_pages > memmap_pages * 2)
> +			nr_kernel_pages -= memmap_pages;

Since this is in else branch, if nr_kernel_pages is equal to 0 at 
initially time?

>   		nr_all_pages += freesize;
>   
>   		zone->spanned_pages = size;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
