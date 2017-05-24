Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 254576B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 13:46:20 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v42so1384468wrc.12
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:46:20 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d22si24422490ede.75.2017.05.24.10.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 10:46:18 -0700 (PDT)
Date: Wed, 24 May 2017 13:46:10 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: make kswapd try harder to keep active pages in cache
Message-ID: <20170524174610.GB22174@cmpxchg.org>
References: <1495549403-3719-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495549403-3719-1-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: akpm@linux-foundation.org, kernel-team@fb.com, riel@redhat.com, linux-mm@kvack.org

Hi Josef,

On Tue, May 23, 2017 at 10:23:23AM -0400, Josef Bacik wrote:
> @@ -308,7 +317,8 @@ EXPORT_SYMBOL(unregister_shrinker);
>  static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  				    struct shrinker *shrinker,
>  				    unsigned long nr_scanned,
> -				    unsigned long nr_eligible)
> +				    unsigned long nr_eligible,
> +				    unsigned long *slab_scanned)

Once you pass in pool size ratios here, nr_scanned and nr_eligible
become confusing. Can you update the names?

> @@ -2292,6 +2310,15 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  				scan = 0;
>  			}
>  			break;
> +		case SCAN_INACTIVE:
> +			if (file && !is_active_lru(lru)) {
> +				if (scan && size > sc->nr_to_reclaim)
> +					scan = sc->nr_to_reclaim;

Why is the scan target different than with regular cache reclaim? I'd
expect that we only need to zero the active list sizes here, not that
we'd also need any further updates to 'scan'.

> @@ -2509,8 +2536,62 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  {
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	unsigned long nr_reclaimed, nr_scanned;
> +	unsigned long nr_reclaim, nr_slab, total_high_wmark = 0, nr_inactive;
> +	int z;
>  	bool reclaimable = false;
> +	bool skip_slab = false;
> +
> +	nr_slab = sum_zone_node_page_state(pgdat->node_id,
> +					   NR_SLAB_RECLAIMABLE);
> +	nr_inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
> +	nr_reclaim = pgdat_reclaimable_pages(pgdat);
> +
> +	for (z = 0; z < MAX_NR_ZONES; z++) {
> +		struct zone *zone = &pgdat->node_zones[z];
> +		if (!managed_zone(zone))
> +			continue;
> +		total_high_wmark += high_wmark_pages(zone);
> +	}

This function is used for memcg target reclaim, in which case you're
only looking at a subset of the pgdats and zones. Any pgdat or zone
state read here would be scoped incorrectly; and the ratios on the
node level are independent from ratios on the cgroup level and can
diverge heavily from each other.

These size inquiries to drive the balancing will have to be made
inside the memcg iteration loop further down with per-cgroup numbers.

> +	/*
> +	 * If we don't have a lot of inactive or slab pages then there's no
> +	 * point in trying to free them exclusively, do the normal scan stuff.
> +	 */
> +	if (nr_inactive < total_high_wmark && nr_slab < total_high_wmark)
> +		sc->inactive_only = 0;

Yes, we need something like this, to know when to fall back to full
reclaim. Cgroups don't have high watermarks, but I guess some magic
number for "too few pages" could do the trick.

> +	/*
> +	 * We don't have historical information, we can't make good decisions
> +	 * about ratio's and where we should put pressure, so just apply
> +	 * pressure based on overall consumption ratios.
> +	 */
> +	if (!sc->slab_diff && !sc->inactive_diff)
> +		sc->inactive_only = 0;

This one I'm not sure about. If we have enough slabs and and inactive
pages why shouldn't we go for them first anyway - regardless of
whether they have grown since the last reclaim invocation?

> @@ -2543,10 +2626,27 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
>  			node_lru_pages += lru_pages;
>  
> -			if (memcg)
> -				shrink_slab(sc->gfp_mask, pgdat->node_id,
> -					    memcg, sc->nr_scanned - scanned,
> -					    lru_pages);
> +			/*
> +			 * We don't want to put a lot of pressure on all of the
> +			 * slabs if a memcg is mostly full, so use the ratio of
> +			 * the lru size to the total reclaimable space on the
> +			 * system.  If we have sc->inactive_only set then we
> +			 * want to use the ratio of the difference between the
> +			 * two since the last kswapd run so we apply pressure to
> +			 * the consumer appropriately.
> +			 */
> +			if (memcg && !skip_slab) {
> +				unsigned long numerator = lru_pages;
> +				unsigned long denominator = nr_reclaim;

I don't quite follow this.

It calculates the share of this memcg's pages on the node, which is
the ratio we should apply to the global slab pool to have equivalent
pressure. However, it's being applied to the *memcg's* share of slab
pages. This means that the smaller the memcg relative to the node, the
less of its tiny share of slab objects we reclaim.

We're not translating from fraction to total, we're translating from
fraction to fraction. Shouldn't the ratio be always 1:1?

For example, if there is only one cgroup on the node, the ratio would
be 1 share of LRU pages and 1 share of slab pages. But if there are
two cgroups, we still scan one share of each cgroup's LRU pages but
only half a share of each cgroup's slab pages. That doesn't add up.

Am I missing something?

> +				if (sc->inactive_only) {
> +					numerator = sc->slab_diff;
> +					denominator = sc->inactive_diff;
> +				}

Shouldn't these diffs already be reflected in the pool sizes? If we
scan pools proportional to their size, we also go more aggressively
for the one that grows faster relative to the other one, right?

I guess this *could* be more adaptive to fluctuations, but I wonder if
that's an optimization that could be split out into a separate patch,
to make it easier to review on its own merit. Start with a simple size
based balancing in the first patch, add improved adaptiveness after.

As mentioned above, this function is used not just by kswapd but also
by direct reclaim, which doesn't initialize these fields and so always
passes 0:0. We should be able to retain sensible balancing for them as
well, but it would require moving the diff sampling.

To make it work for cgroup reclaim, it would have to look at the
growths not on the node level, but on the lruvec level in
get_scan_count() or thereabouts.

Anyway, I think it might be less confusing to nail down the size-based
pressure balancing for slab caches first, and then do the recent diff
balancing on top of it as an optimization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
