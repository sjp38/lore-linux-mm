Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 69D9C9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 22:14:38 -0400 (EDT)
Received: by iaen33 with SMTP id n33so10354804iae.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 19:14:36 -0700 (PDT)
Date: Wed, 28 Sep 2011 11:14:24 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch] mm: disable user interface to manually rescue
 unevictable pages
Message-ID: <20110928021424.GA2715@barrios-desktop>
References: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com>
 <20110926112944.GC14333@redhat.com>
 <20110926161136.b4508ecb.akpm@google.com>
 <20110927072714.GA1997@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110927072714.GA1997@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@google.com>, Kautuk Consul <consul.kautuk@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 27, 2011 at 09:27:14AM +0200, Johannes Weiner wrote:
> At one point, anonymous pages were supposed to go on the unevictable
> list when no swap space was configured, and the idea was to manually
> rescue those pages after adding swap and making them evictable again.
> But nowadays, swap-backed pages on the anon LRU list are not scanned
> without available swap space anyway, so there is no point in moving
> them to a separate list anymore.
> 
> The manual rescue could also be used in case pages were stranded on
> the unevictable list due to race conditions.  But the code has been
> around for a while now and newly discovered bugs should be properly
> reported and dealt with instead of relying on such a manual fixup.
> 
> In addition to the lack of a usecase, the sysfs interface to rescue
> pages from a specific NUMA node has been broken since its
> introduction, so it's unlikely that anybody ever relied on that.
> 
> This patch removes the functionality behind the sysctl and the
> node-interface and emits a one-time warning when somebody tries to
> access either of them.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Reported-by: Kautuk Consul <consul.kautuk@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

There is a nitpick at below but I don't care of it.

> ---
>  mm/vmscan.c |   84 +++++-----------------------------------------------------
>  1 files changed, 8 insertions(+), 76 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7502726..71b5616 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3397,66 +3397,12 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
>  
>  }
>  
> -/**
> - * scan_zone_unevictable_pages - check unevictable list for evictable pages
> - * @zone - zone of which to scan the unevictable list
> - *
> - * Scan @zone's unevictable LRU lists to check for pages that have become
> - * evictable.  Move those that have to @zone's inactive list where they
> - * become candidates for reclaim, unless shrink_inactive_zone() decides
> - * to reactivate them.  Pages that are still unevictable are rotated
> - * back onto @zone's unevictable list.
> - */
> -#define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch size */
> -static void scan_zone_unevictable_pages(struct zone *zone)
> +static void warn_scan_unevictable_pages(void)
>  {
> -	struct list_head *l_unevictable = &zone->lru[LRU_UNEVICTABLE].list;
> -	unsigned long scan;
> -	unsigned long nr_to_scan = zone_page_state(zone, NR_UNEVICTABLE);
> -
> -	while (nr_to_scan > 0) {
> -		unsigned long batch_size = min(nr_to_scan,
> -						SCAN_UNEVICTABLE_BATCH_SIZE);
> -
> -		spin_lock_irq(&zone->lru_lock);
> -		for (scan = 0;  scan < batch_size; scan++) {
> -			struct page *page = lru_to_page(l_unevictable);
> -
> -			if (!trylock_page(page))
> -				continue;
> -
> -			prefetchw_prev_lru_page(page, l_unevictable, flags);
> -
> -			if (likely(PageLRU(page) && PageUnevictable(page)))
> -				check_move_unevictable_page(page, zone);
> -
> -			unlock_page(page);
> -		}
> -		spin_unlock_irq(&zone->lru_lock);
> -
> -		nr_to_scan -= batch_size;
> -	}
> -}
> -
> -
> -/**
> - * scan_all_zones_unevictable_pages - scan all unevictable lists for evictable pages
> - *
> - * A really big hammer:  scan all zones' unevictable LRU lists to check for
> - * pages that have become evictable.  Move those back to the zones'
> - * inactive list where they become candidates for reclaim.
> - * This occurs when, e.g., we have unswappable pages on the unevictable lists,
> - * and we add swap to the system.  As such, it runs in the context of a task
> - * that has possibly/probably made some previously unevictable pages
> - * evictable.
> - */
> -static void scan_all_zones_unevictable_pages(void)
> -{
> -	struct zone *zone;
> -
> -	for_each_zone(zone) {
> -		scan_zone_unevictable_pages(zone);
> -	}
> +	printk_once(KERN_WARNING
> +		    "The scan_unevictable_pages sysctl/node-interface has been "
> +		    "disabled for lack of a legitimate use case.  If you have "
> +		    "one, please send an email to linux-mm@kvack.org.\n");
>  }
>  
>  /*
> @@ -3469,11 +3415,8 @@ int scan_unevictable_handler(struct ctl_table *table, int write,
>  			   void __user *buffer,
>  			   size_t *length, loff_t *ppos)
>  {
> +	warn_scan_unevictable_pages();
>  	proc_doulongvec_minmax(table, write, buffer, length, ppos);
> -
> -	if (write && *(unsigned long *)table->data)
> -		scan_all_zones_unevictable_pages();
> -
>  	scan_unevictable_pages = 0;

Nitpick:
Could we remove this resetting with zero?
-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
