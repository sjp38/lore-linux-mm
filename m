Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id C618F6B0062
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 23:00:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 606153EE0C1
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:00:55 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4816645DE59
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:00:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D4AE45DE58
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:00:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 089DC1DB8056
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:00:55 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B29E61DB8049
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:00:54 +0900 (JST)
Message-ID: <4FDE9969.1090706@jp.fujitsu.com>
Date: Mon, 18 Jun 2012 11:58:49 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm: memcg discount pages under softlimit from per-zone
 reclaimable_pages
References: <1339007051-10672-1-git-send-email-yinghan@google.com>
In-Reply-To: <1339007051-10672-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

(2012/06/07 3:24), Ying Han wrote:
> The function zone_reclaimable() marks zone->all_unreclaimable based on
> per-zone pages_scanned and reclaimable_pages. If all_unreclaimable is true,
> alloc_pages could go to OOM instead of getting stuck in page reclaim.
> 
> In memcg kernel, cgroup under its softlimit is not targeted under global
> reclaim. So we need to remove those pages from reclaimable_pages, otherwise
> it will cause reclaim mechanism to get stuck trying to reclaim from
> all_unreclaimable zone.
> 
> Signed-off-by: Ying Han<yinghan@google.com>
> ---
>   mm/vmscan.c |   24 ++++++++++++++++++------
>   1 files changed, 18 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 65febc1..163b197 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3142,14 +3142,26 @@ unsigned long global_reclaimable_pages(void)
> 
>   unsigned long zone_reclaimable_pages(struct zone *zone)
>   {
> -	int nr;
> +	int nr = 0;
> +	struct mem_cgroup *memcg;
> 
> -	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> -	     zone_page_state(zone, NR_INACTIVE_FILE);
> +	memcg = mem_cgroup_iter(NULL, NULL, NULL);
> +	do {
> +		struct mem_cgroup_zone mz = {
> +			.mem_cgroup = memcg,
> +			.zone = zone,
> +		};
> 
> -	if (nr_swap_pages>  0)
> -		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> -		      zone_page_state(zone, NR_INACTIVE_ANON);
> +		if (should_reclaim_mem_cgroup(memcg)) {
> +			nr += zone_nr_lru_pages(&mz, LRU_INACTIVE_FILE) +
> +			      zone_nr_lru_pages(&mz, LRU_ACTIVE_FILE);
> +
> +			if (nr_swap_pages>  0)
> +				nr += zone_nr_lru_pages(&mz, LRU_ACTIVE_ANON) +
> +				      zone_nr_lru_pages(&mz, LRU_INACTIVE_ANON);
> +		}
> +		memcg = mem_cgroup_iter(NULL, memcg, NULL);
> +	} while (memcg);
> 

Shouldn't you handle 'ignore_softlimit' case ?
Anyway, Kosaki-san is now trying to modify zone->all_unreclaimable etc..
we need to check it with softlimit context.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
