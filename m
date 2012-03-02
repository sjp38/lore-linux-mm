Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 357EF6B004D
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 00:29:54 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A28C53EE0C7
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:29:52 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 84EF745DE55
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:29:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A5CD45DE4F
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:29:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D4C01DB803B
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:29:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F40491DB803F
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:29:51 +0900 (JST)
Date: Fri, 2 Mar 2012 14:28:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] mm: rework reclaim_stat counters
Message-Id: <20120302142825.cd583b59.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120229091556.29236.96896.stgit@zurg>
References: <20120229090748.29236.35489.stgit@zurg>
	<20120229091556.29236.96896.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 29 Feb 2012 13:15:56 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Currently there is two types of reclaim-stat counters:
> recent_scanned (pages picked from from lru),
> recent_rotated (pages putted back to active lru).
> Reclaimer uses ratio recent_rotated / recent_scanned
> for balancing pressure between file and anon pages.
> 
> But if we pick page from lru we can either reclaim it or put it back to lru, thus:
> recent_scanned == recent_rotated[inactive] + recent_rotated[active] + reclaimed
> This can be called "The Law of Conservation of Memory" =)
> 
I'm sorry....where is the count for active->incative ?



> Thus recent_rotated counters for each lru list is enough, reclaimed pages can be
> counted as rotatation into inactive lru. After that reclaimer can use this ratio:
> recent_rotated[active] / (recent_rotated[active] + recent_rotated[inactive])
> 
> After this patch struct zone_reclaimer_stat has only one array: recent_rotated,
> which is directly indexed by lru list index.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

I'm sorry if I misunderstand..
Recent_scanned can be update by some logics other than vmscan..

For example, how lru_deactivate_fn() is handled ?

Thanks,
-Kame




> ---
>  include/linux/mmzone.h |   11 +++++------
>  mm/memcontrol.c        |   29 +++++++++++++++++------------
>  mm/page_alloc.c        |    6 ++----
>  mm/swap.c              |   26 ++++++++------------------
>  mm/vmscan.c            |   42 ++++++++++++++++++++++--------------------
>  5 files changed, 54 insertions(+), 60 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2fed935..fdcd683 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -137,12 +137,14 @@ enum lru_list {
>  	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
>  	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
>  	LRU_UNEVICTABLE,
> -	NR_LRU_LISTS
> +	NR_LRU_LISTS,
> +	NR_EVICTABLE_LRU_LISTS = LRU_UNEVICTABLE,
>  };
>  
>  #define for_each_lru(lru) for (lru = 0; lru < NR_LRU_LISTS; lru++)
>  
> -#define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
> +#define for_each_evictable_lru(lru) \
> +	for (lru = 0; lru < NR_EVICTABLE_LRU_LISTS; lru++)
>  
>  static inline int is_file_lru(enum lru_list lru)
>  {
> @@ -165,11 +167,8 @@ struct zone_reclaim_stat {
>  	 * mem/swap backed and file backed pages are refeferenced.
>  	 * The higher the rotated/scanned ratio, the more valuable
>  	 * that cache is.
> -	 *
> -	 * The anon LRU stats live in [0], file LRU stats in [1]
>  	 */
> -	unsigned long		recent_rotated[2];
> -	unsigned long		recent_scanned[2];
> +	unsigned long		recent_rotated[NR_EVICTABLE_LRU_LISTS];
>  };
>  
>  struct lruvec {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index aeebb9e..2809531 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4189,26 +4189,31 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
>  
>  #ifdef CONFIG_DEBUG_VM
>  	{
> -		int nid, zid;
> +		int nid, zid, lru;
>  		struct mem_cgroup_per_zone *mz;
>  		struct zone_reclaim_stat *rstat;
> -		unsigned long recent_rotated[2] = {0, 0};
> -		unsigned long recent_scanned[2] = {0, 0};
> +		unsigned long recent_rotated[NR_EVICTABLE_LRU_LISTS];
>  
> +		memset(recent_rotated, 0, sizeof(recent_rotated));
>  		for_each_online_node(nid)
>  			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
>  				mz = mem_cgroup_zoneinfo(memcg, nid, zid);
>  				rstat = &mz->lruvec.reclaim_stat;
> -
> -				recent_rotated[0] += rstat->recent_rotated[0];
> -				recent_rotated[1] += rstat->recent_rotated[1];
> -				recent_scanned[0] += rstat->recent_scanned[0];
> -				recent_scanned[1] += rstat->recent_scanned[1];
> +				for_each_evictable_lru(lru)
> +					recent_rotated[lru] +=
> +						rstat->recent_rotated[lru];
>  			}
> -		cb->fill(cb, "recent_rotated_anon", recent_rotated[0]);
> -		cb->fill(cb, "recent_rotated_file", recent_rotated[1]);
> -		cb->fill(cb, "recent_scanned_anon", recent_scanned[0]);
> -		cb->fill(cb, "recent_scanned_file", recent_scanned[1]);
> +
> +		cb->fill(cb, "recent_rotated_anon",
> +				recent_rotated[LRU_ACTIVE_ANON]);
> +		cb->fill(cb, "recent_rotated_file",
> +				recent_rotated[LRU_ACTIVE_FILE]);
> +		cb->fill(cb, "recent_scanned_anon",
> +				recent_rotated[LRU_ACTIVE_ANON] +
> +				recent_rotated[LRU_INACTIVE_ANON]);
> +		cb->fill(cb, "recent_scanned_file",
> +				recent_rotated[LRU_ACTIVE_FILE] +
> +				recent_rotated[LRU_INACTIVE_FILE]);
>  	}
>  #endif
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ab2d210..ea40034 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4365,10 +4365,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>  		zone_pcp_init(zone);
>  		for_each_lru(lru)
>  			INIT_LIST_HEAD(&zone->lruvec.lists[lru]);
> -		zone->lruvec.reclaim_stat.recent_rotated[0] = 0;
> -		zone->lruvec.reclaim_stat.recent_rotated[1] = 0;
> -		zone->lruvec.reclaim_stat.recent_scanned[0] = 0;
> -		zone->lruvec.reclaim_stat.recent_scanned[1] = 0;
> +		memset(&zone->lruvec.reclaim_stat, 0,
> +				sizeof(struct zone_reclaim_stat));
>  		zap_zone_vm_stats(zone);
>  		zone->flags = 0;
>  		if (!size)
> diff --git a/mm/swap.c b/mm/swap.c
> index 9a6850b..c7bcde7 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -277,7 +277,7 @@ void rotate_reclaimable_page(struct page *page)
>  }
>  
>  static void update_page_reclaim_stat(struct zone *zone, struct page *page,
> -				     int file, int rotated)
> +				     enum lru_list lru)
>  {
>  	struct zone_reclaim_stat *reclaim_stat;
>  
> @@ -285,9 +285,7 @@ static void update_page_reclaim_stat(struct zone *zone, struct page *page,
>  	if (!reclaim_stat)
>  		reclaim_stat = &zone->lruvec.reclaim_stat;
>  
> -	reclaim_stat->recent_scanned[file]++;
> -	if (rotated)
> -		reclaim_stat->recent_rotated[file]++;
> +	reclaim_stat->recent_rotated[lru]++;
>  }
>  
>  static void __activate_page(struct page *page, void *arg)
> @@ -295,7 +293,6 @@ static void __activate_page(struct page *page, void *arg)
>  	struct zone *zone = page_zone(page);
>  
>  	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> -		int file = page_is_file_cache(page);
>  		int lru = page_lru_base_type(page);
>  		del_page_from_lru_list(zone, page, lru);
>  
> @@ -304,7 +301,7 @@ static void __activate_page(struct page *page, void *arg)
>  		add_page_to_lru_list(zone, page, lru);
>  		__count_vm_event(PGACTIVATE);
>  
> -		update_page_reclaim_stat(zone, page, file, 1);
> +		update_page_reclaim_stat(zone, page, lru);
>  	}
>  }
>  
> @@ -482,7 +479,7 @@ static void lru_deactivate_fn(struct page *page, void *arg)
>  
>  	if (active)
>  		__count_vm_event(PGDEACTIVATE);
> -	update_page_reclaim_stat(zone, page, file, 0);
> +	update_page_reclaim_stat(zone, page, lru);
>  }
>  
>  /*
> @@ -646,9 +643,7 @@ EXPORT_SYMBOL(__pagevec_release);
>  void lru_add_page_tail(struct zone* zone,
>  		       struct page *page, struct page *page_tail)
>  {
> -	int active;
>  	enum lru_list lru;
> -	const int file = 0;
>  
>  	VM_BUG_ON(!PageHead(page));
>  	VM_BUG_ON(PageCompound(page_tail));
> @@ -660,13 +655,10 @@ void lru_add_page_tail(struct zone* zone,
>  	if (page_evictable(page_tail, NULL)) {
>  		if (PageActive(page)) {
>  			SetPageActive(page_tail);
> -			active = 1;
>  			lru = LRU_ACTIVE_ANON;
> -		} else {
> -			active = 0;
> +		} else
>  			lru = LRU_INACTIVE_ANON;
> -		}
> -		update_page_reclaim_stat(zone, page_tail, file, active);
> +		update_page_reclaim_stat(zone, page_tail, lru);
>  	} else {
>  		SetPageUnevictable(page_tail);
>  		lru = LRU_UNEVICTABLE;
> @@ -694,17 +686,15 @@ static void __pagevec_lru_add_fn(struct page *page, void *arg)
>  {
>  	enum lru_list lru = (enum lru_list)arg;
>  	struct zone *zone = page_zone(page);
> -	int file = is_file_lru(lru);
> -	int active = is_active_lru(lru);
>  
>  	VM_BUG_ON(PageActive(page));
>  	VM_BUG_ON(PageUnevictable(page));
>  	VM_BUG_ON(PageLRU(page));
>  
>  	SetPageLRU(page);
> -	if (active)
> +	if (is_active_lru(lru))
>  		SetPageActive(page);
> -	update_page_reclaim_stat(zone, page, file, active);
> +	update_page_reclaim_stat(zone, page, lru);
>  	add_page_to_lru_list(zone, page, lru);
>  }
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 483b98e..fe00a22 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1355,11 +1355,7 @@ putback_inactive_pages(struct mem_cgroup_zone *mz,
>  		SetPageLRU(page);
>  		lru = page_lru(page);
>  		add_page_to_lru_list(zone, page, lru);
> -		if (is_active_lru(lru)) {
> -			int file = is_file_lru(lru);
> -			int numpages = hpage_nr_pages(page);
> -			reclaim_stat->recent_rotated[file] += numpages;
> -		}
> +		reclaim_stat->recent_rotated[lru] += hpage_nr_pages(page);
>  		if (put_page_testzero(page)) {
>  			__ClearPageLRU(page);
>  			__ClearPageActive(page);
> @@ -1543,8 +1539,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
>  
>  	spin_lock_irq(&zone->lru_lock);
>  
> -	reclaim_stat->recent_scanned[0] += nr_anon;
> -	reclaim_stat->recent_scanned[1] += nr_file;
> +	/*
> +	 * Count reclaimed pages as rotated, this helps balance scan pressure
> +	 * between file and anonymous pages in get_scan_ratio.
> +	 */
> +	reclaim_stat->recent_rotated[lru] += nr_reclaimed;
>  
>  	if (current_is_kswapd())
>  		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
> @@ -1685,8 +1684,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	if (global_reclaim(sc))
>  		zone->pages_scanned += nr_scanned;
>  
> -	reclaim_stat->recent_scanned[file] += nr_taken;
> -
>  	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
>  	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
>  	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
> @@ -1742,7 +1739,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	 * helps balance scan pressure between file and anonymous pages in
>  	 * get_scan_ratio.
>  	 */
> -	reclaim_stat->recent_rotated[file] += nr_rotated;
> +	reclaim_stat->recent_rotated[lru] += nr_rotated;
>  
>  	move_active_pages_to_lru(zone, &l_active, &l_hold, lru);
>  	move_active_pages_to_lru(zone, &l_inactive, &l_hold, lru - LRU_ACTIVE);
> @@ -1875,6 +1872,7 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
>  	unsigned long anon_prio, file_prio;
>  	unsigned long ap, fp;
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
> +	unsigned long *recent_rotated = reclaim_stat->recent_rotated;
>  	u64 fraction[2], denominator;
>  	enum lru_list lru;
>  	int noswap = 0;
> @@ -1940,14 +1938,16 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
>  	 * anon in [0], file in [1]
>  	 */
>  	spin_lock_irq(&mz->zone->lru_lock);
> -	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
> -		reclaim_stat->recent_scanned[0] /= 2;
> -		reclaim_stat->recent_rotated[0] /= 2;
> +	if (unlikely(recent_rotated[LRU_INACTIVE_ANON] +
> +		     recent_rotated[LRU_ACTIVE_ANON] > anon / 4)) {
> +		recent_rotated[LRU_INACTIVE_ANON] /= 2;
> +		recent_rotated[LRU_ACTIVE_ANON] /= 2;
>  	}
>  
> -	if (unlikely(reclaim_stat->recent_scanned[1] > file / 4)) {
> -		reclaim_stat->recent_scanned[1] /= 2;
> -		reclaim_stat->recent_rotated[1] /= 2;
> +	if (unlikely(recent_rotated[LRU_INACTIVE_FILE] +
> +		     recent_rotated[LRU_ACTIVE_FILE] > file / 4)) {
> +		recent_rotated[LRU_INACTIVE_FILE] /= 2;
> +		recent_rotated[LRU_ACTIVE_FILE] /= 2;
>  	}
>  
>  	/*
> @@ -1955,11 +1955,13 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
>  	 * proportional to the fraction of recently scanned pages on
>  	 * each list that were recently referenced and in active use.
>  	 */
> -	ap = (anon_prio + 1) * (reclaim_stat->recent_scanned[0] + 1);
> -	ap /= reclaim_stat->recent_rotated[0] + 1;
> +	ap = (anon_prio + 1) * (recent_rotated[LRU_INACTIVE_ANON] +
> +				recent_rotated[LRU_ACTIVE_ANON] + 1);
> +	ap /= recent_rotated[LRU_ACTIVE_ANON] + 1;
>  
> -	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
> -	fp /= reclaim_stat->recent_rotated[1] + 1;
> +	fp = (file_prio + 1) * (recent_rotated[LRU_INACTIVE_FILE] +
> +				recent_rotated[LRU_ACTIVE_FILE] + 1);
> +	fp /= recent_rotated[LRU_ACTIVE_FILE] + 1;
>  	spin_unlock_irq(&mz->zone->lru_lock);
>  
>  	fraction[0] = ap;
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
