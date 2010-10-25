Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4A7A68D0006
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 22:45:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P2jiGt012413
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 25 Oct 2010 11:45:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 26C6345DE50
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 11:45:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 04A7445DE4D
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 11:45:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E5063E18001
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 11:45:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F117E08003
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 11:45:43 +0900 (JST)
Date: Mon, 25 Oct 2010 11:40:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] do_migrate_range: avoid failure as much as possible
Message-Id: <20101025114017.86ee5e54.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
References: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, fengguang.wu@intel.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010 10:47:31 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> It's normal for isolate_lru_page() to fail at times. The failures are
> typically temporal and may well go away when offline_pages() retries
> the call. So it seems more reasonable to migrate as much as possible
> to increase the chance of complete success in next retry.
> 
> This patch remove page_count() check and remove putback_lru_pages() and
> call migrate_pages() regardless of not_managed to reduce failure as much
> as possible.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

-EBUSY should be returned.

-Kame


> ---
>  mm/memory_hotplug.c |   12 ------------
>  1 files changed, 0 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index a4cfcdc..b64cc9b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -687,7 +687,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  	unsigned long pfn;
>  	struct page *page;
>  	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
> -	int not_managed = 0;
>  	int ret = 0;
>  	LIST_HEAD(source);
>  
> @@ -709,10 +708,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
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
> @@ -720,13 +715,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  #endif
>  		}
>  	}
> -	ret = -EBUSY;
> -	if (not_managed) {
> -		if (!list_empty(&source))
> -			putback_lru_pages(&source);
> -		goto out;
> -	}
> -	ret = 0;
>  	if (list_empty(&source))
>  		goto out;
>  	/* this function returns # of failed pages */
> -- 
> 1.6.3.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
