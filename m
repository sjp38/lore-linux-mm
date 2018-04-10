Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1266B0010
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:46:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p10so6908792pfl.22
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 06:46:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c16si1854378pgv.220.2018.04.10.06.46.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 06:46:49 -0700 (PDT)
Date: Tue, 10 Apr 2018 15:46:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] page cache: Mask off unwanted GFP flags
Message-ID: <20180410134646.p5wuhl6fwtg6megr@quack2.suse.cz>
References: <20180410125351.15837-1-willy@infradead.org>
 <20180410125351.15837-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410125351.15837-2-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue 10-04-18 05:53:51, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The page cache has used the mapping's GFP flags for allocating
> radix tree nodes for a long time.  It took care to always mask off the
> __GFP_HIGHMEM flag, and masked off other flags in other paths, but the
> __GFP_ZERO flag was still able to sneak through.  The __GFP_DMA and
> __GFP_DMA32 flags would also have been able to sneak through if they
> were ever used.  Fix them all by using GFP_RECLAIM_MASK at the innermost
> location, and remove it from earlier in the callchain.
> 
> Fixes: 19f99cee206c ("f2fs: add core inode operations")
> Reported-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: stable@vger.kernel.org

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/filemap.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index c2147682f4c3..1a4bfc5ed3dc 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -785,7 +785,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  	VM_BUG_ON_PAGE(!PageLocked(new), new);
>  	VM_BUG_ON_PAGE(new->mapping, new);
>  
> -	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> +	error = radix_tree_preload(gfp_mask & GFP_RECLAIM_MASK);
>  	if (!error) {
>  		struct address_space *mapping = old->mapping;
>  		void (*freepage)(struct page *);
> @@ -841,7 +841,7 @@ static int __add_to_page_cache_locked(struct page *page,
>  			return error;
>  	}
>  
> -	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
> +	error = radix_tree_maybe_preload(gfp_mask & GFP_RECLAIM_MASK);
>  	if (error) {
>  		if (!huge)
>  			mem_cgroup_cancel_charge(page, memcg, false);
> @@ -1574,8 +1574,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
>  		if (fgp_flags & FGP_ACCESSED)
>  			__SetPageReferenced(page);
>  
> -		err = add_to_page_cache_lru(page, mapping, offset,
> -				gfp_mask & GFP_RECLAIM_MASK);
> +		err = add_to_page_cache_lru(page, mapping, offset, gfp_mask);
>  		if (unlikely(err)) {
>  			put_page(page);
>  			page = NULL;
> @@ -2378,7 +2377,7 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
>  		if (!page)
>  			return -ENOMEM;
>  
> -		ret = add_to_page_cache_lru(page, mapping, offset, gfp_mask & GFP_KERNEL);
> +		ret = add_to_page_cache_lru(page, mapping, offset, gfp_mask);
>  		if (ret == 0)
>  			ret = mapping->a_ops->readpage(file, page);
>  		else if (ret == -EEXIST)
> -- 
> 2.16.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
