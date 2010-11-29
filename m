Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 132AB6B004A
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 19:33:41 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAT0XdHp009050
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 29 Nov 2010 09:33:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 983C945DE7E
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 09:33:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6945245DE70
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 09:33:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 473C8E38004
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 09:33:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EAA6F1DB803B
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 09:33:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 1/3] deactivate invalidated pages
In-Reply-To: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
Message-Id: <20101129090514.829C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 29 Nov 2010 09:33:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> ---
>  mm/swap.c |   84 +++++++++++++++++++++++++++++++++++++++++++++---------------
>  1 files changed, 63 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 31f5ec4..345eca1 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -268,10 +268,65 @@ void add_page_to_unevictable_list(struct page *page)
>  	spin_unlock_irq(&zone->lru_lock);
>  }
>  
> -static void __pagevec_lru_deactive(struct pagevec *pvec)
> +/*
> + * This function is used by invalidate_mapping_pages.
> + * If the page can't be invalidated, this function moves the page
> + * into inative list's head or tail to reclaim ASAP and evict
> + * working set page.
> + *
> + * PG_reclaim means when the page's writeback completes, the page
> + * will move into tail of inactive for reclaiming ASAP.
> + *
> + * 1. active, mapped page -> inactive, head
> + * 2. active, dirty/writeback page -> inactive, head, PG_reclaim
> + * 3. inactive, mapped page -> none
> + * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
> + * 5. others -> none
> + *
> + * In 4, why it moves inactive's head, the VM expects the page would
> + * be writeout by flusher. The flusher's writeout is much effective than
> + * reclaimer's random writeout.
> + */
> +static void __lru_deactivate(struct page *page, struct zone *zone)
>  {
> -	int i, lru, file;
> +	int lru, file;
> +	int active = 0;
> +
> +	if (!PageLRU(page))
> +		return;
> +
> +	if (PageActive(page))
> +		active = 1;
> +	/* Some processes are using the page */
> +	if (page_mapped(page) && !active)
> +		return;
> +
> +	else if (PageWriteback(page)) {
> +		SetPageReclaim(page);
> +		/* Check race with end_page_writeback */
> +		if (!PageWriteback(page))
> +			ClearPageReclaim(page);
> +	} else if (PageDirty(page))
> +		SetPageReclaim(page);
> +
> +	file = page_is_file_cache(page);
> +	lru = page_lru_base_type(page);
> +	del_page_from_lru_list(zone, page, lru + active);
> +	ClearPageActive(page);
> +	ClearPageReferenced(page);
> +	add_page_to_lru_list(zone, page, lru);
> +	if (active)
> +		__count_vm_event(PGDEACTIVATE);
> +
> +	update_page_reclaim_stat(zone, page, file, 0);
> +}

I don't like this change because fadvise(DONT_NEED) is rarely used
function and this PG_reclaim trick doesn't improve so much. In the
other hand, It increase VM state mess.

However, I haven't found any fault and unworked reason in this patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
