Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D01036B0088
	for <linux-mm@kvack.org>; Sat,  8 Jan 2011 17:16:46 -0500 (EST)
Date: Sat, 8 Jan 2011 23:16:35 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 1/7] Introduce delete_from_page_cache
Message-ID: <20110108221635.GB23189@cmpxchg.org>
References: <cover.1293982522.git.minchan.kim@gmail.com>
 <39f5e90f69d523d7f69f8ba283e318def6538307.1293982522.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39f5e90f69d523d7f69f8ba283e318def6538307.1293982522.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 03, 2011 at 12:44:30AM +0900, Minchan Kim wrote:
> This function works as just wrapper remove_from_page_cache.
> The difference is that it decreases page references in itself.
> So caller have to make sure it has a page reference before calling.
> 
> This patch is ready for removing remove_from_page_cache.
> 
> Cc: Christoph Hellwig <hch@infradead.org>
> Acked-by: Hugh Dickins <hughd@google.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  include/linux/pagemap.h |    1 +
>  mm/filemap.c            |   17 +++++++++++++++++
>  2 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 9c66e99..7a1cb49 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -457,6 +457,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
>  				pgoff_t index, gfp_t gfp_mask);
>  extern void remove_from_page_cache(struct page *page);
>  extern void __remove_from_page_cache(struct page *page);
> +extern void delete_from_page_cache(struct page *page);
>  
>  /*
>   * Like add_to_page_cache_locked, but used to add newly allocated pages:
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 095c393..1ca7475 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -166,6 +166,23 @@ void remove_from_page_cache(struct page *page)
>  }
>  EXPORT_SYMBOL(remove_from_page_cache);
>  
> +/**
> + * delete_from_page_cache - delete page from page cache
> + *

This empty line is invalid kerneldoc, the argument descriptions must
follow the short function description line immediately.

Otherwise,
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

> + * @page: the page which the kernel is trying to remove from page cache
> + *
> + * This must be called only on pages that have
> + * been verified to be in the page cache and locked.
> + * It will never put the page into the free list,
> + * the caller has a reference on the page.
> + */
> +void delete_from_page_cache(struct page *page)
> +{
> +	remove_from_page_cache(page);
> +	page_cache_release(page);
> +}
> +EXPORT_SYMBOL(delete_from_page_cache);
> +
>  static int sync_page(void *word)
>  {
>  	struct address_space *mapping;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
