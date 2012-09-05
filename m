Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 833776B0096
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:25:39 -0400 (EDT)
Date: Wed, 5 Sep 2012 10:25:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] mm: remain migratetype in freed page
Message-ID: <20120905092534.GE11266@suse.de>
References: <1346829962-31989-1-git-send-email-minchan@kernel.org>
 <1346829962-31989-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1346829962-31989-3-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 05, 2012 at 04:26:01PM +0900, Minchan Kim wrote:
> Page allocator doesn't keep migratetype information to page
> when the page is freed. This patch remains the information
> to freed page's index field which isn't used by free/alloc
> preparing so it shouldn't change any behavir except below one.
> 

This explanation could have been a *LOT* more helpful.

The page allocator caches the pageblock information in page->private while
it is in the PCP freelists but this is overwritten with the order of the
page when freed to the buddy allocator. This patch stores the migratetype
of the page in the page->index field so that it is available at all times.

> This patch adds a new call site in __free_pages_ok so it might be
> overhead a bit but it's for high order allocation.
> So I believe damage isn't hurt.
> 

The additional call to set_page_migratetype() is not heavy. If you were
adding a new call to get_pageblock_migratetype() or something equally
expensive I would be more concerned.

> Signed-off-by: Minchan Kim <minchan@kernel.org>

The information you store in the page->index becomes stale if the page
gets moved to another free list by move_freepages(). Not sure if that is
a problem for you or not but it is possible that
get_page_migratetype(page) != get_pageblock_migratetype(page)

> ---
>  include/linux/mm.h |    6 ++++--
>  mm/page_alloc.c    |    7 ++++---
>  2 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 86d61d6..8fd32da 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -251,12 +251,14 @@ struct inode;
>  
>  static inline void set_page_migratetype(struct page *page, int migratetype)
>  {
> -	set_page_private(page, migratetype);
> +	VM_BUG_ON((unsigned int)migratetype >= MIGRATE_TYPES);

This additional bug check is not mentioned in the changelog. Not clear
if it's necessary.

> +	page->index = migratetype;
>  }
>  
>  static inline int get_page_migratetype(struct page *page)
>  {
> -	return page_private(page);
> +	VM_BUG_ON((unsigned int)page->index >= MIGRATE_TYPES);
> +	return page->index;
>  }
>  
>  /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 103ba66..32985dd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -723,6 +723,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  {
>  	unsigned long flags;
>  	int wasMlocked = __TestClearPageMlocked(page);
> +	int migratetype;
>  
>  	if (!free_pages_prepare(page, order))
>  		return;
> @@ -731,9 +732,9 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  	if (unlikely(wasMlocked))
>  		free_page_mlock(page);
>  	__count_vm_events(PGFREE, 1 << order);
> -	free_one_page(page_zone(page), page, order,
> -					get_pageblock_migratetype(page));
> -
> +	migratetype = get_pageblock_migratetype(page);
> +	set_page_migratetype(page, migratetype);
> +	free_one_page(page_zone(page), page, order, migratetype);
>  	local_irq_restore(flags);
>  }
>  

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
