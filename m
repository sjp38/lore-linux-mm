Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id E185C6B0093
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 06:18:16 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so17349367wgb.2
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 03:18:15 -0800 (PST)
Message-ID: <4EFC4C74.9010705@openvz.org>
Date: Thu, 29 Dec 2011 15:18:12 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hugh Dickins wrote:
> Replace pagevecs in putback_lru_pages() and move_active_pages_to_lru()
> by lists of pages_to_free: then apply Konstantin Khlebnikov's
> free_hot_cold_page_list() to them instead of pagevec_release().
>
> Which simplifies the flow (no need to drop and retake lock whenever
> pagevec fills up) and reduces stale addresses in stack backtraces
> (which often showed through the pagevecs); but more importantly,
> removes another 120 bytes from the deepest stacks in page reclaim.
> Although I've not recently seen an actual stack overflow here with
> a vanilla kernel, move_active_pages_to_lru() has often featured in
> deep backtraces.
>
> However, free_hot_cold_page_list() does not handle compound pages
> (nor need it: a Transparent HugePage would have been split by the
> time it reaches the call in shrink_page_list()), but it is possible
> for putback_lru_pages() or move_active_pages_to_lru() to be left
> holding the last reference on a THP, so must exclude the unlikely
> compound case before putting on pages_to_free.
>
> Remove pagevec_strip(), its work now done in move_active_pages_to_lru().
> The pagevec in scan_mapping_unevictable_pages() remains in mm/vmscan.c,
> but that is never on the reclaim path, and cannot be replaced by a list.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

Nice patch

Reviewed-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

> @@ -1398,12 +1398,10 @@ putback_lru_pages(struct mem_cgroup_zone
>   		  struct list_head *page_list)
>   {
>   	struct page *page;
> -	struct pagevec pvec;
> +	LIST_HEAD(pages_to_free);
>   	struct zone *zone = mz->zone;

As I see, this patch is on top "memcg naturalization" patchset,
it does not apply clearly against Linus tree.

 > +		if (put_page_testzero(page)) {
 > +			__ClearPageLRU(page);
 > +			__ClearPageActive(page);
 > +			del_page_from_lru_list(zone, page, lru);
 > +
 > +			if (unlikely(PageCompound(page))) {
 > +				spin_unlock_irq(&zone->lru_lock);

There is good place for VM_BUG_ON(!PageHead(page));

 > +				(*get_compound_page_dtor(page))(page);
 > +				spin_lock_irq(&zone->lru_lock);
 > +			} else
 > +				list_add(&page->lru,&pages_to_free);
 >   		}
 >   	}
 >   	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 >   	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 >
 >   	spin_unlock_irq(&zone->lru_lock);
 > -	pagevec_release(&pvec);
 > +	free_hot_cold_page_list(&pages_to_free, 1);
 >   }
 >
 >   static noinline_for_stack void

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
