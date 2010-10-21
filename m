Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 472615F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 10:25:46 -0400 (EDT)
Date: Thu, 21 Oct 2010 22:25:34 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] do_migrate_range: exit loop if not_managed is true.
Message-ID: <20101021142534.GB9709@localhost>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
 <1287667701-8081-2-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1287667701-8081-2-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 09:28:20PM +0800, Bob Liu wrote:
> If not_managed is true all pages will be putback to lru, so
> break the loop earlier to skip other pages isolate.

It's good fix in itself. However it's normal for isolate_lru_page() to
fail at times (when there are active reclaimers). The failures are
typically temporal and may well go away when offline_pages() retries
the call. So it seems more reasonable to migrate as much as possible
to increase the chance of complete success in next retry.

> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/memory_hotplug.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d4e940a..4f72184 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -709,15 +709,17 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  					    page_is_file_cache(page));
>  
>  		} else {
> -			/* Becasue we don't have big zone->lock. we should
> -			   check this again here. */
> -			if (page_count(page))
> -				not_managed++;
>  #ifdef CONFIG_DEBUG_VM
>  			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
>  			       pfn);
>  			dump_page(page);
>  #endif
> +			/* Becasue we don't have big zone->lock. we should
> +			   check this again here. */
> +			if (page_count(page)) {
> +				not_managed++;
> +				break;
> +			}
>  		}
>  	}
>  	ret = -EBUSY;
> -- 
> 1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
