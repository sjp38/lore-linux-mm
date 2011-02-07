Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ABD688D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 04:37:10 -0500 (EST)
Subject: Re: [PATCH] mm: Add hook of freepage
From: Miklos Szeredi <mszeredi@suse.cz>
In-Reply-To: <1297004934-4605-1-git-send-email-minchan.kim@gmail.com>
References: <1297004934-4605-1-git-send-email-minchan.kim@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Feb 2011 10:37:01 +0100
Message-ID: <1297071421.25994.58.camel@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>

On Mon, 2011-02-07 at 00:08 +0900, Minchan Kim wrote:
> Recently, "Call the filesystem back whenever a page is removed from
> the page cache(6072d13c)" added new freepage hook in page cache
> drop function.
> 
> So, replace_page_cache_page should call freepage to support
> page cleanup to fs.

Thanks Minchan for fixing this.

Acked-by: Miklos Szeredi <mszeredi@suse.cz>

> 
> Cc: Miklos Szeredi <mszeredi@suse.cz>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/filemap.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 3c89c96..a25c898 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -436,7 +436,10 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
>  	if (!error) {
>  		struct address_space *mapping = old->mapping;
> +		void (*freepage)(struct page *);
> +
>  		pgoff_t offset = old->index;
> +		freepage = mapping->a_ops->freepage;
>  
>  		page_cache_get(new);
>  		new->mapping = mapping;
> @@ -452,6 +455,8 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  			__inc_zone_page_state(new, NR_SHMEM);
>  		spin_unlock_irq(&mapping->tree_lock);
>  		radix_tree_preload_end();
> +		if (freepage)
> +			freepage(old);
>  		page_cache_release(old);
>  		mem_cgroup_end_migration(memcg, old, new, true);
>  	} else {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
