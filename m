Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9FB286B007D
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:56:53 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C2uoUV020338
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Jan 2010 11:56:51 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8D6245DE55
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:56:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 76C9D45DE4E
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:56:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EC0E1DB803B
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:56:50 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CB998F8006
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:56:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] mm/page_alloc : modify the return type of __free_one_page
In-Reply-To: <1263184634-15447-3-git-send-email-shijie8@gmail.com>
References: <1263184634-15447-2-git-send-email-shijie8@gmail.com> <1263184634-15447-3-git-send-email-shijie8@gmail.com>
Message-Id: <20100112115615.B39B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Jan 2010 11:56:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>   Modify the return type for __free_one_page.
> It will return 1 on success, and return 0 when
> the check of the compound page is failed.

This patch should be merged [4/4]. but I really dislike 4/4...



> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/page_alloc.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 00aa83a..290dfc3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -445,17 +445,18 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>   * triggers coalescing into a block of larger size.            
>   *
>   * -- wli
> + *
> + *  Returns 1 on success, else return 0;
>   */
>  
> -static inline void __free_one_page(struct page *page,
> -		struct zone *zone, unsigned int order,
> -		int migratetype)
> +static inline int __free_one_page(struct page *page, struct zone *zone,
> +		       unsigned int order, int migratetype)
>  {
>  	unsigned long page_idx;
>  
>  	if (unlikely(PageCompound(page)))
>  		if (unlikely(destroy_compound_page(page, order)))
> -			return;
> +			return 0;
>  
>  	VM_BUG_ON(migratetype == -1);
>  
> @@ -485,6 +486,7 @@ static inline void __free_one_page(struct page *page,
>  	list_add(&page->lru,
>  		&zone->free_area[order].free_list[migratetype]);
>  	zone->free_area[order].nr_free++;
> +	return 1;
>  }
>  
>  /*
> -- 
> 1.6.5.2
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
