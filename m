Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 494776B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:59:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so273781293pfa.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:59:08 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id h184si23520889pfc.168.2017.01.16.19.59.06
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 19:59:07 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170116160123.GB30300@cmpxchg.org> <20170116193317.20390-1-mhocko@kernel.org> <20170116193317.20390-3-mhocko@kernel.org>
In-Reply-To: <20170116193317.20390-3-mhocko@kernel.org>
Subject: Re: [PATCH 3/3] Reverted "mm: bail out in shrink_inactive_list()"
Date: Tue, 17 Jan 2017 11:58:51 +0800
Message-ID: <033d01d27076$03c798f0$0b56cad0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Johannes Weiner' <hannes@cmpxchg.org>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>


On Tuesday, January 17, 2017 3:33 AM Michal Hocko wrote: 
> 
> From: Michal Hocko <mhocko@suse.com>
> 
> This reverts 91dcade47a3d0e7c31464ef05f56c08e92a0e9c2.
> inactive_reclaimable_pages shouldn't be needed anymore since that
> get_scan_count is aware of the eligble zones ("mm, vmscan: consider
> eligible zones in get_scan_count").
> 
Looks radical ;)

> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 

>  mm/vmscan.c | 27 ---------------------------
>  1 file changed, 27 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a88e222784ea..486ba6d7dc4c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1700,30 +1700,6 @@ static int current_may_throttle(void)
>  		bdi_write_congested(current->backing_dev_info);
>  }
> 
> -static bool inactive_reclaimable_pages(struct lruvec *lruvec,
> -				struct scan_control *sc, enum lru_list lru)
> -{
> -	int zid;
> -	struct zone *zone;
> -	int file = is_file_lru(lru);
> -	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> -
> -	if (!global_reclaim(sc))
> -		return true;
> -
> -	for (zid = sc->reclaim_idx; zid >= 0; zid--) {
> -		zone = &pgdat->node_zones[zid];
> -		if (!managed_zone(zone))
> -			continue;
> -
> -		if (zone_page_state_snapshot(zone, NR_ZONE_LRU_BASE +
> -				LRU_FILE * file) >= SWAP_CLUSTER_MAX)
> -			return true;
> -	}
> -
> -	return false;
> -}
> -
>  /*
>   * shrink_inactive_list() is a helper for shrink_node().  It returns the number
>   * of reclaimed pages
> @@ -1742,9 +1718,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> 
> -	if (!inactive_reclaimable_pages(lruvec, sc, lru))
> -		return 0;
> -
>  	while (unlikely(too_many_isolated(pgdat, file, sc))) {
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> 
> --
> 2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
