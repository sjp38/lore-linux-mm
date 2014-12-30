Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCA46B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 08:42:34 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so23941587wiv.12
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 05:42:33 -0800 (PST)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id w7si65032082wiy.26.2014.12.30.05.42.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 05:42:33 -0800 (PST)
Received: by mail-wi0-f174.google.com with SMTP id h11so23983414wiw.1
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 05:42:33 -0800 (PST)
Date: Tue, 30 Dec 2014 14:42:30 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: get rid of radix tree gfp mask for
 pagecache_get_page (was: Re: How to handle TIF_MEMDIE stalls?)
Message-ID: <20141230134230.GB15546@dhcp22.suse.cz>
References: <20141217130807.GB24704@dhcp22.suse.cz>
 <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
 <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
 <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
 <20141220223504.GI15665@dastard>
 <20141229174030.GD32618@dhcp22.suse.cz>
 <CA+55aFw5uQpHkSWnKy-CKGgg1QQ6-kix+kfqEcQWKXx2bU1q4A@mail.gmail.com>
 <20141229193312.GA31288@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141229193312.GA31288@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dave Chinner <dchinner@redhat.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

Andrew,
I've noticed you have taken the patch to mm tree already. I have
realized I haven't marked it for stable which is worth it IMO because
debugging nasty reclaim recursion bugs is definitely a pain and might
fix one and even if it doesn't it is rather straightforward and
shouldn't break anything. So if nobody has anything against I would mark
this for stable 3.16+ AFAICS.

On Mon 29-12-14 20:33:12, Michal Hocko wrote:
> From 3242f56ae8886a3c605d93960e77176dfe1dff43 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 29 Dec 2014 20:30:35 +0100
> Subject: [PATCH] mm: get rid of radix tree gfp mask for pagecache_get_page
> 
> 2457aec63745 (mm: non-atomically mark page accessed during page cache
> allocation where possible) has added a separate parameter for specifying
> gfp mask for radix tree allocations.
> 
> Not only this is less than optimal from the API point of view
> because it is error prone, it is also buggy currently because
> grab_cache_page_write_begin is using GFP_KERNEL for radix tree and
> if fgp_flags doesn't contain FGP_NOFS (mostly controlled by fs by
> AOP_FLAG_NOFS flag) but the mapping_gfp_mask has __GFP_FS cleared then
> the radix tree allocation wouldn't obey the restriction and might
> recurse into filesystem and cause deadlocks. This is the case for
> most filesystems unfortunately because only ext4 and gfs2 are using
> AOP_FLAG_NOFS.
> 
> Let's simply remove radix_gfp_mask parameter because the allocation
> context is same for both page cache and for the radix tree. Just make
> sure that the radix tree gets only the sane subset of the mask (e.g. do
> not pass __GFP_WRITE).
> 
> Long term it is more preferable to convert remaining users of
> AOP_FLAG_NOFS to use mapping_gfp_mask instead and simplify this
> interface even further.
> 
> Reported-by: Dave Chinner <david@fromorbit.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  include/linux/pagemap.h | 13 ++++++-------
>  mm/filemap.c            | 29 ++++++++++++-----------------
>  2 files changed, 18 insertions(+), 24 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 7ea069cd3257..4b3736f7065c 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -251,7 +251,7 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
>  #define FGP_NOWAIT		0x00000020
>  
>  struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
> -		int fgp_flags, gfp_t cache_gfp_mask, gfp_t radix_gfp_mask);
> +		int fgp_flags, gfp_t cache_gfp_mask);
>  
>  /**
>   * find_get_page - find and get a page reference
> @@ -266,13 +266,13 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
>  static inline struct page *find_get_page(struct address_space *mapping,
>  					pgoff_t offset)
>  {
> -	return pagecache_get_page(mapping, offset, 0, 0, 0);
> +	return pagecache_get_page(mapping, offset, 0, 0);
>  }
>  
>  static inline struct page *find_get_page_flags(struct address_space *mapping,
>  					pgoff_t offset, int fgp_flags)
>  {
> -	return pagecache_get_page(mapping, offset, fgp_flags, 0, 0);
> +	return pagecache_get_page(mapping, offset, fgp_flags, 0);
>  }
>  
>  /**
> @@ -292,7 +292,7 @@ static inline struct page *find_get_page_flags(struct address_space *mapping,
>  static inline struct page *find_lock_page(struct address_space *mapping,
>  					pgoff_t offset)
>  {
> -	return pagecache_get_page(mapping, offset, FGP_LOCK, 0, 0);
> +	return pagecache_get_page(mapping, offset, FGP_LOCK, 0);
>  }
>  
>  /**
> @@ -319,7 +319,7 @@ static inline struct page *find_or_create_page(struct address_space *mapping,
>  {
>  	return pagecache_get_page(mapping, offset,
>  					FGP_LOCK|FGP_ACCESSED|FGP_CREAT,
> -					gfp_mask, gfp_mask & GFP_RECLAIM_MASK);
> +					gfp_mask);
>  }
>  
>  /**
> @@ -340,8 +340,7 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
>  {
>  	return pagecache_get_page(mapping, index,
>  			FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
> -			mapping_gfp_mask(mapping),
> -			GFP_NOFS);
> +			mapping_gfp_mask(mapping));
>  }
>  
>  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index e8905bc3cbd7..11477d3b7838 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1046,8 +1046,7 @@ EXPORT_SYMBOL(find_lock_entry);
>   * @mapping: the address_space to search
>   * @offset: the page index
>   * @fgp_flags: PCG flags
> - * @cache_gfp_mask: gfp mask to use for the page cache data page allocation
> - * @radix_gfp_mask: gfp mask to use for radix tree node allocation
> + * @gfp_mask: gfp mask to use for the page cache data page allocation
>   *
>   * Looks up the page cache slot at @mapping & @offset.
>   *
> @@ -1056,11 +1055,9 @@ EXPORT_SYMBOL(find_lock_entry);
>   * FGP_ACCESSED: the page will be marked accessed
>   * FGP_LOCK: Page is return locked
>   * FGP_CREAT: If page is not present then a new page is allocated using
> - *		@cache_gfp_mask and added to the page cache and the VM's LRU
> - *		list. If radix tree nodes are allocated during page cache
> - *		insertion then @radix_gfp_mask is used. The page is returned
> - *		locked and with an increased refcount. Otherwise, %NULL is
> - *		returned.
> + *		@gfp_mask and added to the page cache and the VM's LRU
> + *		list. The page is returned locked and with an increased
> + *		refcount. Otherwise, %NULL is returned.
>   *
>   * If FGP_LOCK or FGP_CREAT are specified then the function may sleep even
>   * if the GFP flags specified for FGP_CREAT are atomic.
> @@ -1068,7 +1065,7 @@ EXPORT_SYMBOL(find_lock_entry);
>   * If there is a page cache page, it is returned with an increased refcount.
>   */
>  struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
> -	int fgp_flags, gfp_t cache_gfp_mask, gfp_t radix_gfp_mask)
> +	int fgp_flags, gfp_t gfp_mask)
>  {
>  	struct page *page;
>  
> @@ -1105,13 +1102,11 @@ no_page:
>  	if (!page && (fgp_flags & FGP_CREAT)) {
>  		int err;
>  		if ((fgp_flags & FGP_WRITE) && mapping_cap_account_dirty(mapping))
> -			cache_gfp_mask |= __GFP_WRITE;
> -		if (fgp_flags & FGP_NOFS) {
> -			cache_gfp_mask &= ~__GFP_FS;
> -			radix_gfp_mask &= ~__GFP_FS;
> -		}
> +			gfp_mask |= __GFP_WRITE;
> +		if (fgp_flags & FGP_NOFS)
> +			gfp_mask &= ~__GFP_FS;
>  
> -		page = __page_cache_alloc(cache_gfp_mask);
> +		page = __page_cache_alloc(gfp_mask);
>  		if (!page)
>  			return NULL;
>  
> @@ -1122,7 +1117,8 @@ no_page:
>  		if (fgp_flags & FGP_ACCESSED)
>  			__SetPageReferenced(page);
>  
> -		err = add_to_page_cache_lru(page, mapping, offset, radix_gfp_mask);
> +		err = add_to_page_cache_lru(page, mapping, offset,
> +				gfp_mask & GFP_RECLAIM_MASK);
>  		if (unlikely(err)) {
>  			page_cache_release(page);
>  			page = NULL;
> @@ -2443,8 +2439,7 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
>  		fgp_flags |= FGP_NOFS;
>  
>  	page = pagecache_get_page(mapping, index, fgp_flags,
> -			mapping_gfp_mask(mapping),
> -			GFP_KERNEL);
> +			mapping_gfp_mask(mapping));
>  	if (page)
>  		wait_for_stable_page(page);
>  
> -- 
> 2.1.4
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
