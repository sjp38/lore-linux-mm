Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C60016B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:21:08 -0400 (EDT)
Date: Fri, 12 Jun 2009 07:21:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH for mmotm 1/5] cleanp page_remove_rmap()
Message-ID: <20090611232131.GA5960@localhost>
References: <20090611192114.6D4A.A69D9226@jp.fujitsu.com> <20090611192514.6D4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090611192514.6D4D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 06:26:04PM +0800, KOSAKI Motohiro wrote:
> Subject: [PATCH] cleanp page_remove_rmap()
> 
> page_remove_rmap() has multiple PageAnon() test and it has
> a bit deeply nesting.
> 
> cleanup here.
> 
> note: this patch doesn't have behavior change.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Wu Fengguang <fengguang.wu@intel.com> 

> ---
>  mm/rmap.c |   59 ++++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 32 insertions(+), 27 deletions(-)
> 
> Index: b/mm/rmap.c
> ===================================================================
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -862,34 +862,39 @@ void page_dup_rmap(struct page *page, st
>   */
>  void page_remove_rmap(struct page *page)
>  {
> -	if (atomic_add_negative(-1, &page->_mapcount)) {
> -		/*
> -		 * Now that the last pte has gone, s390 must transfer dirty
> -		 * flag from storage key to struct page.  We can usually skip
> -		 * this if the page is anon, so about to be freed; but perhaps
> -		 * not if it's in swapcache - there might be another pte slot
> -		 * containing the swap entry, but page not yet written to swap.
> -		 */
> -		if ((!PageAnon(page) || PageSwapCache(page)) &&
> -		    page_test_dirty(page)) {
> -			page_clear_dirty(page);
> -			set_page_dirty(page);
> -		}
> -		if (PageAnon(page))
> -			mem_cgroup_uncharge_page(page);
> -		__dec_zone_page_state(page,
> -			PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
> -		mem_cgroup_update_mapped_file_stat(page, -1);
> -		/*
> -		 * It would be tidy to reset the PageAnon mapping here,
> -		 * but that might overwrite a racing page_add_anon_rmap
> -		 * which increments mapcount after us but sets mapping
> -		 * before us: so leave the reset to free_hot_cold_page,
> -		 * and remember that it's only reliable while mapped.
> -		 * Leaving it set also helps swapoff to reinstate ptes
> -		 * faster for those pages still in swapcache.
> -		 */
> +	if (!atomic_add_negative(-1, &page->_mapcount)) {
> +		/* the page is still mapped another one */
> +		return;
>  	}

Coding style nitpick.
I'd prefer to remove the brackets and move the comment above the line:

        /* page still mapped by someone else? */
	if (!atomic_add_negative(-1, &page->_mapcount))
                return;

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
