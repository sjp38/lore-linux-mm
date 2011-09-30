Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ACE459000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 10:41:27 -0400 (EDT)
Date: Fri, 30 Sep 2011 16:41:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 4/5] mm: filemap: pass __GFP_WRITE from
 grab_cache_page_write_begin()
Message-ID: <20110930144122.GD869@tiehlicka.suse.cz>
References: <1317367044-475-1-git-send-email-jweiner@redhat.com>
 <1317367044-475-5-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317367044-475-5-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Shaohua Li <shaohua.li@intel.com>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 30-09-11 09:17:23, Johannes Weiner wrote:
> Tell the page allocator that pages allocated through
> grab_cache_page_write_begin() are expected to become dirty soon.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/filemap.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 645a080..cf0352d 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2349,8 +2349,11 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
>  					pgoff_t index, unsigned flags)
>  {
>  	int status;
> +	gfp_t gfp_mask;
>  	struct page *page;
>  	gfp_t gfp_notmask = 0;
> +
> +	gfp_mask = mapping_gfp_mask(mapping) | __GFP_WRITE;
>  	if (flags & AOP_FLAG_NOFS)
>  		gfp_notmask = __GFP_FS;
>  repeat:
> @@ -2358,7 +2361,7 @@ repeat:
>  	if (page)
>  		goto found;
>  
> -	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~gfp_notmask);
> +	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
>  	if (!page)
>  		return NULL;
>  	status = add_to_page_cache_lru(page, mapping, index,
> -- 
> 1.7.6.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
