Date: Thu, 10 May 2007 17:42:54 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] memory hotremove patch take 2 [04/10] (isolate all free
 pages)
In-Reply-To: <20070509120434.B90E.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705101737500.6987@skynet.skynet.ie>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
 <20070509120434.B90E.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Yasunori Goto wrote:

> Isolate all freed pages (means in buddy_list) in the range.
> See page_buddy() and free_one_page() function if unsure.
>
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
>
> include/linux/page_isolation.h |    1
> mm/page_alloc.c                |   45 +++++++++++++++++++++++++++++++++++++++++
> 2 files changed, 46 insertions(+)
>
> Index: current_test/mm/page_alloc.c
> ===================================================================
> --- current_test.orig/mm/page_alloc.c	2007-05-08 15:08:04.000000000 +0900
> +++ current_test/mm/page_alloc.c	2007-05-08 15:08:26.000000000 +0900
> @@ -4411,6 +4411,51 @@ free_all_isolated_pages(struct isolation
> 	}
> }
>
> +/*
> + * Isolate already freed pages.
> + */
> +int
> +capture_isolate_freed_pages(struct isolation_info *info)
> +{
> +	struct zone *zone;
> +	unsigned long pfn;
> +	struct page *page;
> +	int order, order_size;
> +	int nr_pages = 0;
> +	unsigned long last_pfn = info->end_pfn - 1;
> +	pfn = info->start_pfn;
> +	if (!pfn_valid(pfn))
> +		return -EINVAL;

This may lead to boundary cases where pages cannot be captured at the 
start and end of non-aligned zones due to memory holes.

> +	zone = info->zone;
> +	if ((zone != page_zone(pfn_to_page(pfn))) ||
> +	    (zone != page_zone(pfn_to_page(last_pfn))))
> +		return -EINVAL;

Is this check really necessary? Surely a caller to 
capture_isolate_freed_pages() will have already made all the necessary 
checks when adding the struct insolation_info ?

> +	drain_all_pages();
> +	spin_lock(&zone->lock);
> +	while (pfn < info->end_pfn) {
> +		if (!pfn_valid(pfn)) {
> +			pfn++;
> +			continue;
> +		}
> +		page = pfn_to_page(pfn);
> +		/* See page_is_buddy()  */
> +		if (page_count(page) == 0 && PageBuddy(page)) {

If PageBuddy is set it's free, you shouldn't have to check the page_count.

> +			order = page_order(page);
> +			order_size = 1 << order;
> +			zone->free_area[order].nr_free--;
> +			__mod_zone_page_state(zone, NR_FREE_PAGES, -order_size);
> +			list_del(&page->lru);
> +			rmv_page_order(page);
> +			isolate_page_nolock(info, page, order);
> +			nr_pages += order_size;
> +			pfn += order_size;
> +		} else {
> +			pfn++;
> +		}
> +	}
> +	spin_unlock(&zone->lock);
> +	return nr_pages;
> +}
> #endif /* CONFIG_PAGE_ISOLATION */
>

This is all similar to move_freepages() other than the locking part. It 
would be worth checking if there is code that could be shared or at least 
have similar styles.

>
> Index: current_test/include/linux/page_isolation.h
> ===================================================================
> --- current_test.orig/include/linux/page_isolation.h	2007-05-08 15:08:04.000000000 +0900
> +++ current_test/include/linux/page_isolation.h	2007-05-08 15:08:27.000000000 +0900
> @@ -40,6 +40,7 @@ extern void free_isolation_info(struct i
> extern void unuse_all_isolated_pages(struct isolation_info *info);
> extern void free_all_isolated_pages(struct isolation_info *info);
> extern void drain_all_pages(void);
> +extern int capture_isolate_freed_pages(struct isolation_info *info);
>
> #else
>
>
> -- 
> Yasunori Goto
>
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
