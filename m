Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id B81AA6B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 20:23:21 -0500 (EST)
Date: Wed, 25 Jan 2012 17:23:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 -mm] make swapin readahead skip over holes
Message-Id: <20120125172319.edbbde73.akpm@linux-foundation.org>
In-Reply-To: <20120124141400.6d33b7c4@annuminas.surriel.com>
References: <20120124131351.05309a2a@annuminas.surriel.com>
	<20120124141400.6d33b7c4@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Adrian Drzewieki <z@drze.net>

On Tue, 24 Jan 2012 14:14:00 -0500
Rik van Riel <riel@redhat.com> wrote:

> Ever since abandoning the virtual scan of processes, for scalability
> reasons, swap space has been a little more fragmented than before.
> This can lead to the situation where a large memory user is killed,
> swap space ends up full of "holes" and swapin readahead is totally
> ineffective.
> 
> On my home system, after killing a leaky firefox it took over an
> hour to page just under 2GB of memory back in, slowing the virtual
> machines down to a crawl.
> 
> This patch makes swapin readahead simply skip over holes, instead
> of stopping at them.  This allows the system to swap things back in
> at rates of several MB/second, instead of a few hundred kB/second.
> 
> The checks done in valid_swaphandles are already done in 
> read_swap_cache_async as well, allowing us to remove a fair amount
> of code.

Just to show that I'm paying attention...

> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -382,25 +382,23 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  			struct vm_area_struct *vma, unsigned long addr)
>  {
> -	int nr_pages;
>  	struct page *page;
> -	unsigned long offset;
> -	unsigned long end_offset;
> +	unsigned long offset = swp_offset(entry);
> +	unsigned long start_offset, end_offset;
> +	unsigned long mask = (1 << page_cluster) - 1;

This is broken for page_cluster > 31.  Fix:

--- a/mm/swap_state.c~make-swapin-readahead-skip-over-holes-fix
+++ a/mm/swap_state.c
@@ -385,7 +385,7 @@ struct page *swapin_readahead(swp_entry_
 	struct page *page;
 	unsigned long offset = swp_offset(entry);
 	unsigned long start_offset, end_offset;
-	unsigned long mask = (1 << page_cluster) - 1;
+	unsigned long mask = (1UL << page_cluster) - 1;
 
 	/* Read a page_cluster sized and aligned cluster around offset. */
 	start_offset = offset & ~mask;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
