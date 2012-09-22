Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 423A66B0044
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 09:15:15 -0400 (EDT)
Date: Sat, 22 Sep 2012 21:15:07 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] mm/readahead: Use find_get_pages instead of
 radix_tree_lookup.
Message-ID: <20120922131507.GC15962@localhost>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <aae0fd43fc74dff95489de3c2b543ae8a4c7ed7d.1348309711.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aae0fd43fc74dff95489de3c2b543ae8a4c7ed7d.1348309711.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghu.prabhu13@gmail.com
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Sat, Sep 22, 2012 at 04:03:14PM +0530, raghu.prabhu13@gmail.com wrote:
> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> 
> Instead of running radix_tree_lookup in a loop and lock/unlocking in the
> process, find_get_pages is called once, which returns a page_list, some of which
> are not NULL and are in core.
> 
> Also, since find_get_pages returns number of pages, if all pages are already
> cached, it can return early.
> 
> This will be mostly helpful when a higher proportion of nr_to_read pages are
> already in the cache, which will mean less locking for page cache hits.

Do you mean the rcu_read_lock()? But it's a no-op for most archs.  So
the benefit of this patch is questionable. Will need real performance
numbers to support it.

> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
> ---
>  mm/readahead.c | 31 +++++++++++++++++++++++--------
>  1 file changed, 23 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 3977455..3a1798d 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -157,35 +157,42 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  {
>  	struct inode *inode = mapping->host;
>  	struct page *page;
> +	struct page **page_list = NULL;
>  	unsigned long end_index;	/* The last page we want to read */
>  	LIST_HEAD(page_pool);
>  	int page_idx;
>  	int ret = 0;
>  	int ret_read = 0;
> +	unsigned long num;
> +	pgoff_t page_offset;
>  	loff_t isize = i_size_read(inode);
>  
>  	if (isize == 0)
>  		goto out;
>  
> +	page_list = kzalloc(nr_to_read * sizeof(struct page *), GFP_KERNEL);
> +	if (!page_list)
> +		goto out;

That cost one more memory allocation and added code to maintain the
page list. The original code also don't have the cost of grabbing the
page count, which eliminate the trouble of page release.

>  	end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
> +	num = find_get_pages(mapping, offset, nr_to_read, page_list);

Assume we want to readahead pages for indexes [0, 100] and the cached
pages are in [1000, 1100]. find_get_pages() will return the latter.
Which is probably not the your expected results.

>  	/*
>  	 * Preallocate as many pages as we will need.
>  	 */
>  	for (page_idx = 0; page_idx < nr_to_read; page_idx++) {
> -		pgoff_t page_offset = offset + page_idx;
> +		if (page_list[page_idx]) {
> +			page_cache_release(page_list[page_idx]);
> +			continue;
> +		}
> +
> +		page_offset = offset + page_idx;
>  
>  		if (page_offset > end_index)
>  			break;
>  
> -		rcu_read_lock();
> -		page = radix_tree_lookup(&mapping->page_tree, page_offset);
> -		rcu_read_unlock();
> -		if (page)
> -			continue;
> -
>  		page = page_cache_alloc_readahead(mapping);
> -		if (!page)
> +		if (unlikely(!page))
>  			break;

That break will leave the remaining pages' page_count lifted and lead
to memory leak.

>  		page->index = page_offset;
>  		list_add(&page->lru, &page_pool);
> @@ -194,6 +201,13 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  			lookahead_size = 0;
>  		}
>  		ret++;
> +
> +		/*
> +		 * Since num pages are already returned, bail out after
> +		 * nr_to_read - num pages are allocated and added.
> +		 */
> +		if (ret == nr_to_read - num)
> +			break;

Confused. That break seems unnecessary?

Thanks,
Fengguang

>  	}
>  
>  	/*
> @@ -205,6 +219,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  		ret_read = read_pages(mapping, filp, &page_pool, ret);
>  	BUG_ON(!list_empty(&page_pool));
>  out:
> +	kfree(page_list);
>  	return (ret_read < 0 ? ret_read : ret);
>  }
>  
> -- 
> 1.7.12.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
