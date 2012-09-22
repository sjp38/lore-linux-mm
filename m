Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 731956B0044
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 08:43:45 -0400 (EDT)
Date: Sat, 22 Sep 2012 20:43:37 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/5] mm/readahead: Check return value of read_pages
Message-ID: <20120922124337.GA17562@localhost>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <dcdfd8620ae632321a28112f5074cc3c78d05bde.1348309711.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dcdfd8620ae632321a28112f5074cc3c78d05bde.1348309711.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghu.prabhu13@gmail.com
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Sat, Sep 22, 2012 at 04:03:10PM +0530, raghu.prabhu13@gmail.com wrote:
> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> 
> Return value of a_ops->readpage will be propagated to return value of read_pages
> and __do_page_cache_readahead.

That does not explain the intention and benefit of this patch..

Thanks,
Fengguang

> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
> ---
>  mm/readahead.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index ea8f8fa..461fcc0 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -113,7 +113,7 @@ static int read_pages(struct address_space *mapping, struct file *filp,
>  {
>  	struct blk_plug plug;
>  	unsigned page_idx;
> -	int ret;
> +	int ret = 0;
>  
>  	blk_start_plug(&plug);
>  
> @@ -129,11 +129,12 @@ static int read_pages(struct address_space *mapping, struct file *filp,
>  		list_del(&page->lru);
>  		if (!add_to_page_cache_lru(page, mapping,
>  					page->index, GFP_KERNEL)) {
> -			mapping->a_ops->readpage(filp, page);
> +			ret = mapping->a_ops->readpage(filp, page);
> +			if (ret < 0)
> +				break;
>  		}
>  		page_cache_release(page);
>  	}
> -	ret = 0;
>  
>  out:
>  	blk_finish_plug(&plug);
> @@ -160,6 +161,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  	LIST_HEAD(page_pool);
>  	int page_idx;
>  	int ret = 0;
> +	int ret_read = 0;
>  	loff_t isize = i_size_read(inode);
>  
>  	if (isize == 0)
> @@ -198,10 +200,10 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  	 * will then handle the error.
>  	 */
>  	if (ret)
> -		read_pages(mapping, filp, &page_pool, ret);
> +		ret_read = read_pages(mapping, filp, &page_pool, ret);
>  	BUG_ON(!list_empty(&page_pool));
>  out:
> -	return ret;
> +	return (ret_read < 0 ? ret_read : ret);
>  }
>  
>  /*
> -- 
> 1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
