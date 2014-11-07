Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 22A16800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 04:18:23 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so2966342pdj.40
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 01:18:22 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id s4si8477849pdj.117.2014.11.07.01.18.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Nov 2014 01:18:21 -0800 (PST)
Date: Fri, 7 Nov 2014 12:18:11 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [rfc patch] mm: vmscan: invoke slab shrinkers for each lruvec
Message-ID: <20141107091811.GH4839@esperanza>
References: <1415317828-19390-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1415317828-19390-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Johannes,

The general idea sounds sane to me. A few comments inline.

On Thu, Nov 06, 2014 at 06:50:28PM -0500, Johannes Weiner wrote:
[...]
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a384339bf718..6a9ab5adf118 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
[...]
> @@ -1876,7 +1872,8 @@ enum scan_balance {
>   * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
>   */
>  static void get_scan_count(struct lruvec *lruvec, int swappiness,
> -			   struct scan_control *sc, unsigned long *nr)
> +			   struct scan_control *sc, unsigned long *nr,
> +			   unsigned long *lru_pages)
>  {
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>  	u64 fraction[2];
> @@ -2022,39 +2019,34 @@ out:
>  	some_scanned = false;
>  	/* Only use force_scan on second pass. */
>  	for (pass = 0; !some_scanned && pass < 2; pass++) {
> +		*lru_pages = 0;
>  		for_each_evictable_lru(lru) {
>  			int file = is_file_lru(lru);
>  			unsigned long size;
>  			unsigned long scan;
>  
> +			/* Scan one type exclusively */
> +			if ((scan_balance == SCAN_FILE) != file) {
> +				nr[lru] = 0;
> +				continue;
> +			}
> +

Why do you move this piece of code? AFAIU, we only want to accumulate
the total number of evictable pages on the lruvec, so the patch for
shrink_lruvec should look much simpler. Is it a kind of cleanup? If so,
I guess it'd be better to submit it separately.

Anyways, this hunk doesn't look right to me. With it applied, if
scan_balance equals SCAN_EQUAL or SCAN_FRACT we won't scan file lists at
all.

>  			size = get_lru_size(lruvec, lru);
> -			scan = size >> sc->priority;
> +			*lru_pages += size;
>  
> +			scan = size >> sc->priority;
>  			if (!scan && pass && force_scan)
>  				scan = min(size, SWAP_CLUSTER_MAX);
>  
> -			switch (scan_balance) {
> -			case SCAN_EQUAL:
> -				/* Scan lists relative to size */
> -				break;
> -			case SCAN_FRACT:
> +			if (scan_balance == SCAN_FRACT) {
>  				/*
>  				 * Scan types proportional to swappiness and
>  				 * their relative recent reclaim efficiency.
>  				 */
>  				scan = div64_u64(scan * fraction[file],
> -							denominator);
> -				break;
> -			case SCAN_FILE:
> -			case SCAN_ANON:
> -				/* Scan one type exclusively */
> -				if ((scan_balance == SCAN_FILE) != file)
> -					scan = 0;
> -				break;
> -			default:
> -				/* Look ma, no brain */
> -				BUG();
> +						 denominator);
>  			}
> +
>  			nr[lru] = scan;
>  			/*
>  			 * Skip the second pass and don't force_scan,
> @@ -2077,10 +2069,17 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
>  	enum lru_list lru;
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> +	unsigned long nr_scanned = sc->nr_scanned;
> +	unsigned long lru_pages;
>  	struct blk_plug plug;
>  	bool scan_adjusted;
> +	struct shrink_control shrink = {
> +		.gfp_mask = sc->gfp_mask,
> +		.nid = zone_to_nid(lruvec_zone(lruvec)),
> +	};
> +	struct reclaim_state *reclaim_state = current->reclaim_state;
>  
> -	get_scan_count(lruvec, swappiness, sc, nr);
> +	get_scan_count(lruvec, swappiness, sc, nr, &lru_pages);
>  
>  	/* Record the original scan target for proportional adjustments later */
>  	memcpy(targets, nr, sizeof(nr));
> @@ -2173,6 +2172,23 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
>  	sc->nr_reclaimed += nr_reclaimed;
>  
>  	/*
> +	 * Shrink slab caches in the same proportion that the eligible
> +	 * LRU pages were scanned.
> +	 *
> +	 * XXX: Skip memcg limit reclaim, as the slab shrinkers are
> +	 * not cgroup-aware yet and we can't know if the objects in
> +	 * the global lists contribute to the memcg limit.
> +	 */
> +	if (global_reclaim(sc) && lru_pages) {
> +		nr_scanned = sc->nr_scanned - nr_scanned;
> +		shrink_slab(&shrink, nr_scanned, lru_pages);

I've a few concerns about slab-vs-pagecache reclaim proportion:

If a node has > 1 zones, then we will scan slabs more aggressively than
lru pages. Not sure, if it really matters, because on x86_64 most nodes
have 1 zone.

If there are > 1 nodes, NUMA-unaware shrinkers will get more pressure
than NUMA-aware ones. However, we have the same behavior in kswapd at
present. This might be an issue if there are many nodes.

If there are > 1 memory cgroups, slab shrinkers will get significantly
more pressure on global reclaim than they should. The introduction of
memcg-aware shrinkers will help, but only for memcg-aware shrinkers.
Other shrinkers (if there are any) will be treated unfairly. I think for
memcg-unaware shrinkers (i.e. for all shrinkers right now) we should
pass lru_pages=zone_reclaimable_pages.

BTW, may be we'd better pass the scan priority for shrink_slab to
calculate the pressure instead of messing with nr_scanned/lru_pages?

> +		if (reclaim_state) {
> +			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> +			reclaim_state->reclaimed_slab = 0;
> +		}

OFF TOPIC: I wonder why we need the reclaim_state. The main shrink
candidates, dentries and inodes, are mostly freed by RCU, so they won't
count there.

> +	}
> +
> +	/*
>  	 * Even if we did not try to evict anon pages at all, we want to
>  	 * rebalance the anon lru active/inactive ratio.
>  	 */
[...]

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
