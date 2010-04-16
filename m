Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E7ADC6B021A
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 03:54:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3G7s5VH023910
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Apr 2010 16:54:05 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4223C45DE55
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 16:54:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DBB1845DE50
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 16:54:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A27D2E08011
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 16:54:04 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4108CE08008
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 16:54:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 09/10] vmscan: Setup pagevec as late as possible in shrink_page_list()
In-Reply-To: <1271352103-2280-10-git-send-email-mel@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-10-git-send-email-mel@csn.ul.ie>
Message-Id: <20100416115248.27A7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Apr 2010 16:54:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> shrink_page_list() sets up a pagevec to release pages as according as they
> are free. It uses significant amounts of stack on the pagevec. This
> patch adds pages to be freed via pagevec to a linked list which is then
> freed en-masse at the end. This avoids using stack in the main path that
> potentially calls writepage().
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |   34 ++++++++++++++++++++++++++--------
>  1 files changed, 26 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9bc1ede..2c22c83 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -619,6 +619,22 @@ static enum page_references page_check_references(struct page *page,
>  	return PAGEREF_RECLAIM;
>  }
>  
> +static void free_page_list(struct list_head *free_list)
> +{
> +	struct pagevec freed_pvec;
> +	struct page *page, *tmp;
> +
> +	pagevec_init(&freed_pvec, 1);
> +
> +	list_for_each_entry_safe(page, tmp, free_list, lru) {
> +		list_del(&page->lru);
> +		if (!pagevec_add(&freed_pvec, page)) {
> +			__pagevec_free(&freed_pvec);
> +			pagevec_reinit(&freed_pvec);
> +		}
> +	}

Need this two line at this? because we need consider number of
list element are not 14xN.

	if (pagevec_count(&freed_pvec))
		__pagevec_free(&freed_pvec);


> +}
> +
>  /*
>   * shrink_page_list() returns the number of reclaimed pages
>   */
> @@ -627,13 +643,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  					enum pageout_io sync_writeback)
>  {
>  	LIST_HEAD(ret_pages);
> -	struct pagevec freed_pvec;
> +	LIST_HEAD(free_list);
>  	int pgactivate = 0;
>  	unsigned long nr_reclaimed = 0;
>  
>  	cond_resched();
>  
> -	pagevec_init(&freed_pvec, 1);
>  	while (!list_empty(page_list)) {
>  		enum page_references references;
>  		struct address_space *mapping;
> @@ -808,10 +823,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		__clear_page_locked(page);
>  free_it:
>  		nr_reclaimed++;
> -		if (!pagevec_add(&freed_pvec, page)) {
> -			__pagevec_free(&freed_pvec);
> -			pagevec_reinit(&freed_pvec);
> -		}
> +
> +		/*
> +		 * Is there need to periodically free_page_list? It would
> +		 * appear not as the counts should be low
> +		 */
> +		list_add(&page->lru, &free_list);
>  		continue;
>  
>  cull_mlocked:
> @@ -834,9 +851,10 @@ keep:
>  		list_add(&page->lru, &ret_pages);
>  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
>  	}
> +
> +	free_page_list(&free_list);
> +
>  	list_splice(&ret_pages, page_list);
> -	if (pagevec_count(&freed_pvec))
> -		__pagevec_free(&freed_pvec);
>  	count_vm_events(PGACTIVATE, pgactivate);
>  	return nr_reclaimed;
>  }
> -- 
> 1.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
