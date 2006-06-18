Subject: Re: [patch] rfc: fix splice mapping race?
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060618094157.GD14452@wotan.suse.de>
References: <20060618094157.GD14452@wotan.suse.de>
Content-Type: text/plain
Date: Sun, 18 Jun 2006 12:02:45 +0200
Message-Id: <1150624965.28517.55.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@engr.sgi.com>, Jens Axboe <axboe@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2006-06-18 at 11:41 +0200, Nick Piggin wrote:
> Hi, I would be interested in confirmation/comments for this patch.
> 
> I believe splice is unsafe to access the page mapping obtained
> when the page was unlocked: the page could subsequently be truncated
> and the mapping reclaimed (see set_page_dirty_lock comments).
> 
> Modify the remove_mapping precondition to ensure the caller has
> locked the page and obtained the correct mapping. Modify callers to
> ensure the mapping is the correct one.
> 
> In page migration, detect the missing mapping early and bail out if
> that is the case: the page is not going to get un-truncated, so
> retrying is just a waste of time.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Looks sane, except the change in migrate (comment there). I like the
remove_mapping() pre-conditions.

> 
> Index: linux-2.6/fs/splice.c
> ===================================================================
> --- linux-2.6.orig/fs/splice.c
> +++ linux-2.6/fs/splice.c
> @@ -55,9 +55,12 @@ static int page_cache_pipe_buf_steal(str
>  				     struct pipe_buffer *buf)
>  {
>  	struct page *page = buf->page;
> -	struct address_space *mapping = page_mapping(page);
> +	struct address_space *mapping;
>  
>  	lock_page(page);
> +	mapping = page_mapping(page);
> +	if (!mapping)
> +		goto out_failed;
>  
>  	WARN_ON(!PageUptodate(page));
>  
> @@ -74,6 +77,7 @@ static int page_cache_pipe_buf_steal(str
>  		try_to_release_page(page, mapping_gfp_mask(mapping));
>  
>  	if (!remove_mapping(mapping, page)) {
> +out_failed:
>  		unlock_page(page);
>  		return 1;
>  	}
> Index: linux-2.6/mm/migrate.c
> ===================================================================
> --- linux-2.6.orig/mm/migrate.c
> +++ linux-2.6/mm/migrate.c
> @@ -136,9 +136,13 @@ static int swap_page(struct page *page)
>  {
>  	struct address_space *mapping = page_mapping(page);
>  
> -	if (page_mapped(page) && mapping)
> +	if (!mapping)
> +		return -EINVAL; /* page truncated. signal permanent failure */

Here, I think you need to unlock the page too.

> +
> +	if (page_mapped(page)) {
>  		if (try_to_unmap(page, 1) != SWAP_SUCCESS)
>  			goto unlock_retry;
> +	}
>  
>  	if (PageDirty(page)) {
>  		/* Page is dirty, try to write it out here */
> Index: linux-2.6/mm/vmscan.c
> ===================================================================
> --- linux-2.6.orig/mm/vmscan.c
> +++ linux-2.6/mm/vmscan.c
> @@ -362,8 +362,8 @@ pageout_t pageout(struct page *page, str
>  
>  int remove_mapping(struct address_space *mapping, struct page *page)
>  {
> -	if (!mapping)
> -		return 0;		/* truncate got there first */
> +	BUG_ON(!PageLocked(page));
> +	BUG_ON(mapping != page->mapping);
>  
>  	write_lock_irq(&mapping->tree_lock);
>  
> @@ -532,7 +532,7 @@ static unsigned long shrink_page_list(st
>  				goto free_it;
>  		}
>  
> -		if (!remove_mapping(mapping, page))
> +		if (!mapping || !remove_mapping(mapping, page))
>  			goto keep_locked;
>  
>  free_it:
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
