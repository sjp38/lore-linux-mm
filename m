Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 8CD4A6B00ED
	for <linux-mm@kvack.org>; Mon, 14 May 2012 06:44:19 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so5004816lbj.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 03:44:17 -0700 (PDT)
Message-ID: <4FB0E1FD.7030505@openvz.org>
Date: Mon, 14 May 2012 14:44:13 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/memcg: get_lru_size not get_lruvec_size
References: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils> <alpine.LSU.2.00.1205132158470.6148@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1205132158470.6148@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hugh Dickins wrote:
> Konstantin just introduced mem_cgroup_get_lruvec_size() and
> get_lruvec_size(), I'm about to add mem_cgroup_update_lru_size():
> but we're dealing with the same thing, lru_size[lru].  We ought to
> agree on the naming, and I do think lru_size is the more correct:
> so rename his ones to get_lru_size().

Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

BTW I plan to move lru_size[] and recent_rotated[] directly to
struct lruvec and update them both right in add_page_to_lru_list()

>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> ---
> But I'd prefer this patch to vanish and you just edit Konstantin's.
>
>   include/linux/memcontrol.h |    4 ++--
>   mm/memcontrol.c            |   10 +++++-----
>   mm/vmscan.c                |   19 +++++++++----------
>   3 files changed, 16 insertions(+), 17 deletions(-)
>
> --- 3046N.orig/include/linux/memcontrol.h	2012-05-13 20:41:20.506117289 -0700
> +++ 3046N/include/linux/memcontrol.h	2012-05-13 20:41:24.330117381 -0700
> @@ -121,7 +121,7 @@ void mem_cgroup_iter_break(struct mem_cg
>   int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec);
>   int mem_cgroup_inactive_file_is_low(struct lruvec *lruvec);
>   int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
> -unsigned long mem_cgroup_get_lruvec_size(struct lruvec *lruvec, enum lru_list);
> +unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list);
>   struct zone_reclaim_stat*
>   mem_cgroup_get_reclaim_stat_from_page(struct page *page);
>   extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> @@ -340,7 +340,7 @@ mem_cgroup_inactive_file_is_low(struct l
>   }
>
>   static inline unsigned long
> -mem_cgroup_get_lruvec_size(struct lruvec *lruvec, enum lru_list lru)
> +mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
>   {
>   	return 0;
>   }
> --- 3046N.orig/mm/memcontrol.c	2012-05-13 20:41:20.510117289 -0700
> +++ 3046N/mm/memcontrol.c	2012-05-13 20:41:24.334117380 -0700
> @@ -742,7 +742,7 @@ static void mem_cgroup_charge_statistics
>   }
>
>   unsigned long
> -mem_cgroup_get_lruvec_size(struct lruvec *lruvec, enum lru_list lru)
> +mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
>   {
>   	struct mem_cgroup_per_zone *mz;
>
> @@ -1234,8 +1234,8 @@ int mem_cgroup_inactive_anon_is_low(stru
>   	unsigned long active;
>   	unsigned long gb;
>
> -	inactive = mem_cgroup_get_lruvec_size(lruvec, LRU_INACTIVE_ANON);
> -	active = mem_cgroup_get_lruvec_size(lruvec, LRU_ACTIVE_ANON);
> +	inactive = mem_cgroup_get_lru_size(lruvec, LRU_INACTIVE_ANON);
> +	active = mem_cgroup_get_lru_size(lruvec, LRU_ACTIVE_ANON);
>
>   	gb = (inactive + active)>>  (30 - PAGE_SHIFT);
>   	if (gb)
> @@ -1251,8 +1251,8 @@ int mem_cgroup_inactive_file_is_low(stru
>   	unsigned long active;
>   	unsigned long inactive;
>
> -	inactive = mem_cgroup_get_lruvec_size(lruvec, LRU_INACTIVE_FILE);
> -	active = mem_cgroup_get_lruvec_size(lruvec, LRU_ACTIVE_FILE);
> +	inactive = mem_cgroup_get_lru_size(lruvec, LRU_INACTIVE_FILE);
> +	active = mem_cgroup_get_lru_size(lruvec, LRU_ACTIVE_FILE);
>
>   	return (active>  inactive);
>   }
> --- 3046N.orig/mm/vmscan.c	2012-05-13 20:41:20.510117289 -0700
> +++ 3046N/mm/vmscan.c	2012-05-13 20:41:24.334117380 -0700
> @@ -145,10 +145,10 @@ static bool global_reclaim(struct scan_c
>   }
>   #endif
>
> -static unsigned long get_lruvec_size(struct lruvec *lruvec, enum lru_list lru)
> +static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
>   {
>   	if (!mem_cgroup_disabled())
> -		return mem_cgroup_get_lruvec_size(lruvec, lru);
> +		return mem_cgroup_get_lru_size(lruvec, lru);
>
>   	return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru);
>   }
> @@ -1608,10 +1608,10 @@ static void get_scan_count(struct lruvec
>   		goto out;
>   	}
>
> -	anon  = get_lruvec_size(lruvec, LRU_ACTIVE_ANON) +
> -		get_lruvec_size(lruvec, LRU_INACTIVE_ANON);
> -	file  = get_lruvec_size(lruvec, LRU_ACTIVE_FILE) +
> -		get_lruvec_size(lruvec, LRU_INACTIVE_FILE);
> +	anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
> +		get_lru_size(lruvec, LRU_INACTIVE_ANON);
> +	file  = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
> +		get_lru_size(lruvec, LRU_INACTIVE_FILE);
>
>   	if (global_reclaim(sc)) {
>   		free  = zone_page_state(zone, NR_FREE_PAGES);
> @@ -1674,7 +1674,7 @@ out:
>   		int file = is_file_lru(lru);
>   		unsigned long scan;
>
> -		scan = get_lruvec_size(lruvec, lru);
> +		scan = get_lru_size(lruvec, lru);
>   		if (sc->priority || noswap) {
>   			scan>>= sc->priority;
>   			if (!scan&&  force_scan)
> @@ -1743,10 +1743,9 @@ static inline bool should_continue_recla
>   	 * inactive lists are large enough, continue reclaiming
>   	 */
>   	pages_for_compaction = (2UL<<  sc->order);
> -	inactive_lru_pages = get_lruvec_size(lruvec, LRU_INACTIVE_FILE);
> +	inactive_lru_pages = get_lru_size(lruvec, LRU_INACTIVE_FILE);
>   	if (nr_swap_pages>  0)
> -		inactive_lru_pages += get_lruvec_size(lruvec,
> -						      LRU_INACTIVE_ANON);
> +		inactive_lru_pages += get_lru_size(lruvec, LRU_INACTIVE_ANON);
>   	if (sc->nr_reclaimed<  pages_for_compaction&&
>   			inactive_lru_pages>  pages_for_compaction)
>   		return true;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
