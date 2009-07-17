Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CFEAC6B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 08:18:46 -0400 (EDT)
Subject: Re: [PATCH 4/5] Use add_page_to_lru_list() helper function
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090716173921.9D54.A69D9226@jp.fujitsu.com>
References: <20090716173449.9D4B.A69D9226@jp.fujitsu.com>
	 <20090716173921.9D54.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Jul 2009 14:18:48 +0200
Message-Id: <1247833128.15751.41.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-07-16 at 17:40 +0900, KOSAKI Motohiro wrote:
> Subject: Use add_page_to_lru_list() helper function
> 
> add_page_to_lru_list() is equivalent to
>   - add lru list (global)
>   - add lru list (mem-cgroup)
>   - modify zone stat
> 
> We can use it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1225,12 +1225,12 @@ static void move_active_pages_to_lru(str
>  
>  	while (!list_empty(list)) {
>  		page = lru_to_page(list);
> +		list_del(&page->lru);
>  
>  		VM_BUG_ON(PageLRU(page));
>  		SetPageLRU(page);
>  
> -		list_move(&page->lru, &zone->lru[lru].list);
> -		mem_cgroup_add_lru_list(page, lru);
> +		add_page_to_lru_list(zone, page, lru);
>  		pgmoved++;
>  
>  		if (!pagevec_add(&pvec, page) || list_empty(list)) {
> @@ -1241,7 +1241,6 @@ static void move_active_pages_to_lru(str
>  			spin_lock_irq(&zone->lru_lock);
>  		}
>  	}
> -	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
>  	if (!is_active_lru(lru))
>  		__count_vm_events(PGDEACTIVATE, pgmoved);
>  }

This is a net loss, you introduce pgmoved calls to __inc_zone_state,
instead of the one __mod_zone_page_state() call.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
