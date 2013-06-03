Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 2C32F6B003B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 04:35:42 -0400 (EDT)
Date: Mon, 3 Jun 2013 17:35:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [v4][PATCH 4/6] mm: vmscan: break out mapping "freepage" code
Message-ID: <20130603083540.GC2795@blaptop>
References: <20130531183855.44DDF928@viggo.jf.intel.com>
 <20130531183901.375FE758@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130531183901.375FE758@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On Fri, May 31, 2013 at 11:39:01AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> __remove_mapping() only deals with pages with mappings, meaning
> page cache and swap cache.
> 
> At this point, the page has been removed from the mapping's radix
> tree, and we need to ensure that any fs-specific (or swap-
> specific) resources are freed up.
> 
> We will be using this function from a second location in a
> following patch.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Acked-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Minchan Kim <minchan@kernel.org>

Again, a nitpick. Sorry.

> ---
> 
>  linux.git-davehans/mm/vmscan.c |   28 +++++++++++++++++++---------
>  1 file changed, 19 insertions(+), 9 deletions(-)
> 
> diff -puN mm/vmscan.c~free_mapping_page mm/vmscan.c
> --- linux.git/mm/vmscan.c~free_mapping_page	2013-05-30 16:07:51.461115968 -0700
> +++ linux.git-davehans/mm/vmscan.c	2013-05-30 16:07:51.465116144 -0700
> @@ -497,6 +497,24 @@ static int __remove_mapping(struct addre
>  	return 1;
>  }
>  
> +/*
> + * Release any resources the mapping had tied up in
> + * the page.

It could be a one line.


> + */
> +static void mapping_release_page(struct address_space *mapping,
> +				 struct page *page)
> +{
> +	if (PageSwapCache(page)) {
> +		swapcache_free_page_entry(page);
> +	} else {
> +		void (*freepage)(struct page *);
> +		freepage = mapping->a_ops->freepage;
> +		mem_cgroup_uncharge_cache_page(page);
> +		if (freepage != NULL)
> +			freepage(page);
> +	}
> +}
> +
>  static int lock_remove_mapping(struct address_space *mapping, struct page *page)
>  {
>  	int ret;
> @@ -510,15 +528,7 @@ static int lock_remove_mapping(struct ad
>  	if (!ret)
>  		return 0;
>  
> -	if (PageSwapCache(page)) {
> -		swapcache_free_page_entry(page);
> -	} else {
> -		void (*freepage)(struct page *);
> -		freepage = mapping->a_ops->freepage;
> -		mem_cgroup_uncharge_cache_page(page);
> -		if (freepage != NULL)
> -			freepage(page);
> -	}
> +	mapping_release_page(mapping, page);
>  	return ret;
>  }
>  
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
