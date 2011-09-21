Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 16B0A9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 08:34:02 -0400 (EDT)
Date: Wed, 21 Sep 2011 14:33:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 07/11] mm: vmscan: convert unevictable page rescue
 scanner to per-memcg LRU lists
Message-ID: <20110921123354.GC8501@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-8-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315825048-3437-8-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 12-09-11 12:57:24, Johannes Weiner wrote:
> The global per-zone LRU lists are about to go away on memcg-enabled
> kernels, the unevictable page rescue scanner must be able to find its
> pages on the per-memcg LRU lists.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

The patch is correct but I guess the original implementation of
scan_zone_unevictable_pages is buggy (see bellow). This should be
addressed separatelly, though.

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/memcontrol.h |    3 ++
>  mm/memcontrol.c            |   11 ++++++++
>  mm/vmscan.c                |   61 ++++++++++++++++++++++++++++---------------
>  3 files changed, 54 insertions(+), 21 deletions(-)
> 
[...]
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -3490,32 +3501,40 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
>  #define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch size */
>  static void scan_zone_unevictable_pages(struct zone *zone)
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
> +	struct mem_cgroup *mem;
>  
> -			if (!trylock_page(page))
> -				continue;
> +	mem = mem_cgroup_iter(NULL, NULL, NULL);
> +	do {
> +		struct mem_cgroup_zone mz = {
> +			.mem_cgroup = mem,
> +			.zone = zone,
> +		};
> +		unsigned long nr_to_scan;
>  
> -			prefetchw_prev_lru_page(page, l_unevictable, flags);
> +		nr_to_scan = zone_nr_lru_pages(&mz, LRU_UNEVICTABLE);
> +		while (nr_to_scan > 0) {
> +			unsigned long batch_size;
> +			unsigned long scan;
>  
> -			if (likely(PageLRU(page) && PageUnevictable(page)))
> -				check_move_unevictable_page(page, zone);
> +			batch_size = min(nr_to_scan,
> +					 SCAN_UNEVICTABLE_BATCH_SIZE);
> +			spin_lock_irq(&zone->lru_lock);
> +			for (scan = 0; scan < batch_size; scan++) {
> +				struct page *page;
>  
> -			unlock_page(page);
> +				page = lru_tailpage(&mz, LRU_UNEVICTABLE);
> +				if (!trylock_page(page))
> +					continue;

We are not moving to the next page so we will try it again in the next
round while we already increased the scan count. In the end we will
missed some pages.

> +				if (likely(PageLRU(page) &&
> +					   PageUnevictable(page)))
> +					check_move_unevictable_page(page, zone);
> +				unlock_page(page);
> +			}
> +			spin_unlock_irq(&zone->lru_lock);
> +			nr_to_scan -= batch_size;
>  		}
> -		spin_unlock_irq(&zone->lru_lock);
> -
> -		nr_to_scan -= batch_size;
> -	}
> +		mem = mem_cgroup_iter(NULL, mem, NULL);
> +	} while (mem);
>  }
>  
>  
> -- 
> 1.7.6
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
