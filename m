Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id A35466B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 08:05:50 -0400 (EDT)
Date: Tue, 19 Jun 2012 14:05:23 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V5 5/5] mm: memcg discount pages under softlimit from
 per-zone reclaimable_pages
Message-ID: <20120619120523.GD27816@cmpxchg.org>
References: <1340038051-29502-1-git-send-email-yinghan@google.com>
 <1340038051-29502-5-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340038051-29502-5-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Jun 18, 2012 at 09:47:31AM -0700, Ying Han wrote:
> The function zone_reclaimable() marks zone->all_unreclaimable based on
> per-zone pages_scanned and reclaimable_pages. If all_unreclaimable is true,
> alloc_pages could go to OOM instead of getting stuck in page reclaim.

There is no zone->all_unreclaimable at this point, you removed it in
the previous patch.

> In memcg kernel, cgroup under its softlimit is not targeted under global
> reclaim. So we need to remove those pages from reclaimable_pages, otherwise
> it will cause reclaim mechanism to get stuck trying to reclaim from
> all_unreclaimable zone.

Can't you check if zone->pages_scanned changed in between reclaim
runs?

Or sum up the scanned and reclaimable pages encountered while
iterating the hierarchy during regular reclaim and then use those
numbers in the equation instead of the per-zone counters?

Walking the full global hierarchy in all the places where we check if
a zone is reclaimable is a scalability nightmare.

> @@ -100,18 +100,36 @@ static __always_inline enum lru_list page_lru(struct page *page)
>  	return lru;
>  }
>  
> +static inline unsigned long get_lru_size(struct lruvec *lruvec,
> +					 enum lru_list lru)
> +{
> +	if (!mem_cgroup_disabled())
> +		return mem_cgroup_get_lru_size(lruvec, lru);
> +
> +	return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru);
> +}
> +
>  static inline unsigned long zone_reclaimable_pages(struct zone *zone)
>  {
> -	int nr;
> +	int nr = 0;
> +	struct mem_cgroup *memcg;
> +
> +	memcg = mem_cgroup_iter(NULL, NULL, NULL);
> +	do {
> +		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  
> -	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> -	     zone_page_state(zone, NR_INACTIVE_FILE);
> +		if (should_reclaim_mem_cgroup(memcg)) {
> +			nr += get_lru_size(lruvec, LRU_INACTIVE_FILE) +
> +			      get_lru_size(lruvec, LRU_ACTIVE_FILE);

Sometimes, the number of reclaimable pages DO include those of groups
for which should_reclaim_mem_cgroup() is false: when the priority
level is <= DEF_PRIORITY - 2, as you defined in 1/5!  This means that
you consider pages you just scanned unreclaimable, which can result in
the zone being unreclaimable after the DEF_PRIORITY - 2 cycle, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
