Date: Wed, 25 Apr 2007 12:22:38 +0100
Subject: Re: [RFC 06/16] Variable Page Cache: Add VM_BUG_ONs to check for correct page order
Message-ID: <20070425112237.GE19942@skynet.ie>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com> <20070423064916.5458.62790.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070423064916.5458.62790.sendpatchset@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Badari Pulavarty <pbadari@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Adam Litke <aglitke@gmail.com>, Dave Hansen <hansendc@us.ibm.com>, Avi Kivity <avi@argo.co.il>
List-ID: <linux-mm.kvack.org>

On (22/04/07 23:49), Christoph Lameter didst pronounce:
> Variable Page Cache: Add VM_BUG_ONs to check for correct page order
> 
> Before we start changing the page order we better get some debugging
> in there that trips us up whenever a wrong order page shows up in a
> mapping. This will be helpful for converting new filesystems to
> utilize higher orders.
> 

Oops, ignore earlier comments about flagging bugs related to compound
pages differently. This patch looks like it'll catch many of the
mistakes

> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/filemap.c |   19 ++++++++++++++++---
>  1 file changed, 16 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6.21-rc7/mm/filemap.c
> ===================================================================
> --- linux-2.6.21-rc7.orig/mm/filemap.c	2007-04-22 21:54:00.000000000 -0700
> +++ linux-2.6.21-rc7/mm/filemap.c	2007-04-22 21:59:15.000000000 -0700
> @@ -127,6 +127,7 @@ void remove_from_page_cache(struct page 
>  	struct address_space *mapping = page->mapping;
>  
>  	BUG_ON(!PageLocked(page));
> +	VM_BUG_ON(mapping->order != compound_order(page));
>  
>  	write_lock_irq(&mapping->tree_lock);
>  	__remove_from_page_cache(page);
> @@ -268,6 +269,7 @@ int wait_on_page_writeback_range(struct 
>  			if (page->index > end)
>  				continue;
>  
> +			VM_BUG_ON(mapping->order != compound_order(page));
>  			wait_on_page_writeback(page);
>  			if (PageError(page))
>  				ret = -EIO;
> @@ -439,6 +441,7 @@ int add_to_page_cache(struct page *page,
>  {
>  	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
>  
> +	VM_BUG_ON(mapping->order != compound_order(page));
>  	if (error == 0) {
>  		write_lock_irq(&mapping->tree_lock);
>  		error = radix_tree_insert(&mapping->page_tree, offset, page);
> @@ -598,8 +601,10 @@ struct page * find_get_page(struct addre
>  
>  	read_lock_irq(&mapping->tree_lock);
>  	page = radix_tree_lookup(&mapping->page_tree, offset);
> -	if (page)
> +	if (page) {
> +		VM_BUG_ON(mapping->order != compound_order(page));
>  		page_cache_get(page);
> +	}
>  	read_unlock_irq(&mapping->tree_lock);
>  	return page;
>  }
> @@ -624,6 +629,7 @@ struct page *find_lock_page(struct addre
>  repeat:
>  	page = radix_tree_lookup(&mapping->page_tree, offset);
>  	if (page) {
> +		VM_BUG_ON(mapping->order != compound_order(page));
>  		page_cache_get(page);
>  		if (TestSetPageLocked(page)) {
>  			read_unlock_irq(&mapping->tree_lock);
> @@ -683,6 +689,7 @@ repeat:
>  		} else if (err == -EEXIST)
>  			goto repeat;
>  	}
> +	VM_BUG_ON(mapping->order != compound_order(page));
>  	if (cached_page)
>  		page_cache_release(cached_page);
>  	return page;
> @@ -714,8 +721,10 @@ unsigned find_get_pages(struct address_s
>  	read_lock_irq(&mapping->tree_lock);
>  	ret = radix_tree_gang_lookup(&mapping->page_tree,
>  				(void **)pages, start, nr_pages);
> -	for (i = 0; i < ret; i++)
> +	for (i = 0; i < ret; i++) {
> +		VM_BUG_ON(mapping->order != compound_order(pages[i]));
>  		page_cache_get(pages[i]);
> +	}
>  	read_unlock_irq(&mapping->tree_lock);
>  	return ret;
>  }
> @@ -745,6 +754,7 @@ unsigned find_get_pages_contig(struct ad
>  		if (pages[i]->mapping == NULL || pages[i]->index != index)
>  			break;
>  
> +		VM_BUG_ON(mapping->order != compound_order(pages[i]));
>  		page_cache_get(pages[i]);
>  		index++;
>  	}
> @@ -772,8 +782,10 @@ unsigned find_get_pages_tag(struct addre
>  	read_lock_irq(&mapping->tree_lock);
>  	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
>  				(void **)pages, *index, nr_pages, tag);
> -	for (i = 0; i < ret; i++)
> +	for (i = 0; i < ret; i++) {
> +		VM_BUG_ON(mapping->order != compound_order(pages[i]));
>  		page_cache_get(pages[i]);
> +	}
>  	if (ret)
>  		*index = pages[ret - 1]->index + 1;
>  	read_unlock_irq(&mapping->tree_lock);
> @@ -2454,6 +2466,7 @@ int try_to_release_page(struct page *pag
>  	struct address_space * const mapping = page->mapping;
>  
>  	BUG_ON(!PageLocked(page));
> +	VM_BUG_ON(mapping->order != compound_order(page));
>  	if (PageWriteback(page))
>  		return 0;
>  

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
