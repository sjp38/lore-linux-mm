Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AB2BA6B0095
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 17:37:16 -0400 (EDT)
Date: Mon, 25 Oct 2010 14:36:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] do_migrate_range: reduce list_empty() check.
Message-Id: <20101025143641.5be6cb5b.akpm@linux-foundation.org>
In-Reply-To: <1287667701-8081-3-git-send-email-lliubbo@gmail.com>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
	<1287667701-8081-2-git-send-email-lliubbo@gmail.com>
	<1287667701-8081-3-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, fengguang.wu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


It's not completely clear to me that these three patches are finalised.
If updates are needed, lease send them ASAP.

On Thu, 21 Oct 2010 21:28:21 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> simple code for reducing list_empty(&source) check.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/memory_hotplug.c |   17 +++++++----------
>  1 files changed, 7 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 4f72184..b6ffcfe 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -718,22 +718,19 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  			   check this again here. */
>  			if (page_count(page)) {
>  				not_managed++;
> +				ret = -EBUSY;
>  				break;
>  			}
>  		}
>  	}
> -	ret = -EBUSY;
> -	if (not_managed) {
> -		if (!list_empty(&source))
> +	if (!list_empty(&source)) {
> +		if (not_managed) {
>  			putback_lru_pages(&source);
> -		goto out;
> +			goto out;
> +		}
> +		/* this function returns # of failed pages */
> +		ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
>  	}
> -	ret = 0;
> -	if (list_empty(&source))
> -		goto out;
> -	/* this function returns # of failed pages */
> -	ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
> -
>  out:
>  	return ret;

The code you're patching has changed a bit in -mm.  Here's what I ended
up with:

	static int
	do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
	{
		unsigned long pfn;
		struct page *page;
		int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
		int not_managed = 0;
		int ret = 0;
		LIST_HEAD(source);
	
		for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
			if (!pfn_valid(pfn))
				continue;
			page = pfn_to_page(pfn);
			if (!page_count(page))
				continue;
			/*
			 * We can skip free pages. And we can only deal with pages on
			 * LRU.
			 */
			ret = isolate_lru_page(page);
			if (!ret) { /* Success */
				list_add_tail(&page->lru, &source);
				move_pages--;
				inc_zone_page_state(page, NR_ISOLATED_ANON +
						    page_is_file_cache(page));
	
			} else {
	#ifdef CONFIG_DEBUG_VM
				printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
				       pfn);
				dump_page(page);
	#endif
				/* Becasue we don't have big zone->lock. we should
				   check this again here. */
				if (page_count(page)) {
					not_managed++;
					ret = -EBUSY;
					break;
				}
			}
		}
		if (!list_empty(&source)) {
			if (not_managed) {
				putback_lru_pages(&source);
				goto out;
			}
			/* this function returns # of failed pages */
			ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
-->>			if (ret)
-->>				putback_lru_pages(&source);
		}
	out:
		return ret;
	}
	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
