Date: Mon, 30 Jul 2007 13:49:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] Wait for page writeback when directly reclaiming
 contiguous areas
Message-Id: <20070730134903.d7bd67b6.akpm@linux-foundation.org>
In-Reply-To: <ffcc80382e464d7a11a5194e1d327e96@pinky>
References: <exportbomb.1185662485@pinky>
	<ffcc80382e464d7a11a5194e1d327e96@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 28 Jul 2007 23:52:30 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> 
> From: Mel Gorman <mel@csn.ul.ie>
> 
> Lumpy reclaim works by selecting a lead page from the LRU list and then
> selecting pages for reclaim from the order-aligned area of pages. In the
> situation were all pages in that region are inactive and not referenced by
> any process over time, it works well.
> 
> In the situation where there is even light load on the system, the pages may
> not free quickly. Out of a area of 1024 pages, maybe only 950 of them are
> freed when the allocation attempt occurs because lumpy reclaim returned early.
> This patch alters the behaviour of direct reclaim for large contiguous blocks.
> 
> The first attempt to call shrink_page_list() is asynchronous but if it
> fails, the pages are submitted a second time and the calling process waits
> for the IO to complete. It'll retry up to 5 times for the pages to be
> fully freed. This may stall allocators waiting for contiguous memory but
> that should be expected behaviour for high-order users. It is preferable
> behaviour to potentially queueing unnecessary areas for IO. Note that kswapd
> will not stall in this fashion.

I agree with the intent.

> +/* Request for sync pageout. */
> +typedef enum {
> +	PAGEOUT_IO_ASYNC,
> +	PAGEOUT_IO_SYNC,
> +} pageout_io_t;

no typedefs.

(checkpatch.pl knew that ;))

>  /* possible outcome of pageout() */
>  typedef enum {
>  	/* failed to write page out, page is locked */
> @@ -287,7 +293,8 @@ typedef enum {
>   * pageout is called by shrink_page_list() for each dirty page.
>   * Calls ->writepage().
>   */
> -static pageout_t pageout(struct page *page, struct address_space *mapping)
> +static pageout_t pageout(struct page *page, struct address_space *mapping,
> +						pageout_io_t sync_writeback)
>  {
>  	/*
>  	 * If the page is dirty, only perform writeback if that write
> @@ -346,6 +353,15 @@ static pageout_t pageout(struct page *page, struct address_space *mapping)
>  			ClearPageReclaim(page);
>  			return PAGE_ACTIVATE;
>  		}
> +
> +		/*
> +		 * Wait on writeback if requested to. This happens when
> +		 * direct reclaiming a large contiguous area and the
> +		 * first attempt to free a ranage of pages fails

cnat tpye.

> +		 */
> +		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
> +			wait_on_page_writeback(page);
> +
>
>  		if (!PageWriteback(page)) {
>  			/* synchronous write or broken a_ops? */
>  			ClearPageReclaim(page);
> @@ -423,7 +439,8 @@ cannot_free:
>   * shrink_page_list() returns the number of reclaimed pages
>   */
>  static unsigned long shrink_page_list(struct list_head *page_list,
> -					struct scan_control *sc)
> +					struct scan_control *sc,
> +					pageout_io_t sync_writeback)
>  {
>  	LIST_HEAD(ret_pages);
>  	struct pagevec freed_pvec;
> @@ -458,8 +475,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (page_mapped(page) || PageSwapCache(page))
>  			sc->nr_scanned++;
>  
> -		if (PageWriteback(page))
> -			goto keep_locked;
> +		if (PageWriteback(page)) {
> +			if (sync_writeback == PAGEOUT_IO_SYNC)
> +				wait_on_page_writeback(page);
> +			else
> +				goto keep_locked;
> +		}

This is unneeded and conceivably deadlocky for !__GFP_FS allocations. 
Probably we avoid doing all this if the test which may_enter_fs uses is
false.

It's unlikely that any very-high-order allocators are using GFP_NOIO or
whatever, but still...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
