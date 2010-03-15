Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4B6636B01F8
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 19:57:45 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2FNvgFr002052
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Mar 2010 08:57:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B90AE45DE52
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 08:57:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ECEB45DE51
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 08:57:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 75CD91DB8040
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 08:57:42 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 284561DB803F
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 08:57:39 +0900 (JST)
Date: Tue, 16 Mar 2010 08:54:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove return value of putback_lru_pages
Message-Id: <20100316085405.f2720f56.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1268658994.1889.8.camel@barrios-desktop>
References: <1268658994.1889.8.camel@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Mar 2010 22:16:34 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> 
> Now putback_lru_page never can fail.
> So it doesn't matter count of "the number of pages put back".
> 
> In addition, users of this functions don't use return value.
> 
> Let's remove unnecessary code.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  include/linux/migrate.h |    4 ++--
>  mm/migrate.c            |    7 +------
>  2 files changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 7f085c9..7a07b17 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -9,7 +9,7 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
>  #ifdef CONFIG_MIGRATION
>  #define PAGE_MIGRATION 1
>  
> -extern int putback_lru_pages(struct list_head *l);
> +extern void putback_lru_pages(struct list_head *l);
>  extern int migrate_page(struct address_space *,
>  			struct page *, struct page *);
>  extern int migrate_pages(struct list_head *l, new_page_t x,
> @@ -25,7 +25,7 @@ extern int migrate_vmas(struct mm_struct *mm,
>  #else
>  #define PAGE_MIGRATION 0
>  
> -static inline int putback_lru_pages(struct list_head *l) { return 0; }
> +static inline void putback_lru_pages(struct list_head *l) {}
>  static inline int migrate_pages(struct list_head *l, new_page_t x,
>  		unsigned long private, int offlining) { return -ENOSYS; }
>  
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 88000b8..6903abf 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -57,23 +57,18 @@ int migrate_prep(void)
>  /*
>   * Add isolated pages on the list back to the LRU under page lock
>   * to avoid leaking evictable pages back onto unevictable list.
> - *
> - * returns the number of pages put back.
>   */
> -int putback_lru_pages(struct list_head *l)
> +void putback_lru_pages(struct list_head *l)
>  {
>  	struct page *page;
>  	struct page *page2;
> -	int count = 0;
>  
>  	list_for_each_entry_safe(page, page2, l, lru) {
>  		list_del(&page->lru);
>  		dec_zone_page_state(page, NR_ISOLATED_ANON +
>  				page_is_file_cache(page));
>  		putback_lru_page(page);
> -		count++;
>  	}
> -	return count;
>  }
>  
>  /*
> -- 
> 1.6.5
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
