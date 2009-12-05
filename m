Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2295B6B0044
	for <linux-mm@kvack.org>; Sat,  5 Dec 2009 08:09:46 -0500 (EST)
Date: Sat, 5 Dec 2009 13:09:36 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] mm:  remove unevictable_migrate_page function
In-Reply-To: <1259778941.4088.176.camel@useless.americas.hpqcorp.net>
Message-ID: <Pine.LNX.4.64.0912051308300.32005@sister.anvils>
References: <1259778941.4088.176.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 2009, Lee Schermerhorn wrote:
> 
> unevictable_migrate_page() in mm/internal.h is a relic of the
> since removed UNEVICTABLE_LRU Kconfig option.  This patch removes
> the function and open codes the test in migrate_page_copy().
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

(and Andrew has already put this in mmotm, thanks)

More obfuscation gone: good, thanks.

> 
>  mm/internal.h |   12 ------------
>  mm/migrate.c  |    4 ++--
>  2 files changed, 2 insertions(+), 14 deletions(-)
> 
> Index: linux-2.6.32-rc8/mm/internal.h
> ===================================================================
> --- linux-2.6.32-rc8.orig/mm/internal.h	2009-11-24 13:19:58.000000000 -0500
> +++ linux-2.6.32-rc8/mm/internal.h	2009-12-01 13:33:11.000000000 -0500
> @@ -74,18 +74,6 @@ static inline void munlock_vma_pages_all
>  }
>  #endif
>  
> -/*
> - * unevictable_migrate_page() called only from migrate_page_copy() to
> - * migrate unevictable flag to new page.
> - * Note that the old page has been isolated from the LRU lists at this
> - * point so we don't need to worry about LRU statistics.
> - */
> -static inline void unevictable_migrate_page(struct page *new, struct page *old)
> -{
> -	if (TestClearPageUnevictable(old))
> -		SetPageUnevictable(new);
> -}
> -
>  #ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
>  /*
>   * Called only in fault path via page_evictable() for a new page
> Index: linux-2.6.32-rc8/mm/migrate.c
> ===================================================================
> --- linux-2.6.32-rc8.orig/mm/migrate.c	2009-11-24 13:19:58.000000000 -0500
> +++ linux-2.6.32-rc8/mm/migrate.c	2009-12-01 13:32:48.000000000 -0500
> @@ -341,8 +341,8 @@ static void migrate_page_copy(struct pag
>  	if (TestClearPageActive(page)) {
>  		VM_BUG_ON(PageUnevictable(page));
>  		SetPageActive(newpage);
> -	} else
> -		unevictable_migrate_page(newpage, page);
> +	} else if (TestClearPageUnevictable(page))
> +		SetPageUnevictable(newpage);
>  	if (PageChecked(page))
>  		SetPageChecked(newpage);
>  	if (PageMappedToDisk(page))
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
