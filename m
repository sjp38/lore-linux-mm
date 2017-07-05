Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F49B6B0292
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 00:27:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p10so57248289pgr.6
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 21:27:07 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id z15si15084038pgo.33.2017.07.04.21.27.05
        for <linux-mm@kvack.org>;
        Tue, 04 Jul 2017 21:27:06 -0700 (PDT)
Date: Wed, 5 Jul 2017 13:27:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/4][v2] vmscan: bailout of slab reclaim once we reach
 our target
Message-ID: <20170705042704.GA20079@bbox>
References: <1499171620-6746-1-git-send-email-jbacik@fb.com>
 <1499171620-6746-2-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499171620-6746-2-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josef@toxicpanda.com
Cc: akpm@linux-foundation.org, kernel-team@fb.com, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, Josef Bacik <jbacik@fb.com>

On Tue, Jul 04, 2017 at 08:33:38AM -0400, josef@toxicpanda.com wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Following patches will greatly increase our aggressiveness in slab
> reclaim, so we need checks in place to make sure we stop trying to
> reclaim slab once we've hit our reclaim target.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
> v1->v2:
> - Don't bail out in shrink_slab() so that we always scan at least batch_size
>   objects of every slab regardless of wether we've hit our target or not.

It's no different with v1 for aging fairness POV.

Imagine you have 3 shrinkers in shrinker_list and A has a lots of objects.

        HEAD-> A -> B -> C

shrink_slab does scan/reclaims from A srhinker a lot until it meets
sc->nr_to_reclaim. Then, VM does aging B and C with batch_size which is
rather small. It breaks fairness.

In next memory pressure, it shrinks A a lot again but B and C
a little bit.

> 
>  mm/vmscan.c | 33 ++++++++++++++++++++++-----------
>  1 file changed, 22 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index cf23de9..78860a6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -305,11 +305,13 @@ EXPORT_SYMBOL(unregister_shrinker);
>  
>  #define SHRINK_BATCH 128
>  
> -static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> +static unsigned long do_shrink_slab(struct scan_control *sc,
> +				    struct shrink_control *shrinkctl,
>  				    struct shrinker *shrinker,
>  				    unsigned long nr_scanned,
>  				    unsigned long nr_eligible)
>  {
> +	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	unsigned long freed = 0;
>  	unsigned long long delta;
>  	long total_scan;
> @@ -394,14 +396,18 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  
>  		shrinkctl->nr_to_scan = nr_to_scan;
>  		ret = shrinker->scan_objects(shrinker, shrinkctl);
> +		if (reclaim_state) {
> +			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> +			reclaim_state->reclaimed_slab = 0;
> +		}
>  		if (ret == SHRINK_STOP)
>  			break;
>  		freed += ret;
> -
>  		count_vm_events(SLABS_SCANNED, nr_to_scan);
>  		total_scan -= nr_to_scan;
>  		scanned += nr_to_scan;
> -
> +		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
> +			break;
>  		cond_resched();
>  	}
>  
> @@ -452,7 +458,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>   *
>   * Returns the number of reclaimed slab objects.
>   */
> -static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
> +static unsigned long shrink_slab(struct scan_control *sc, int nid,
>  				 struct mem_cgroup *memcg,
>  				 unsigned long nr_scanned,
>  				 unsigned long nr_eligible)
> @@ -478,8 +484,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	}
>  
>  	list_for_each_entry(shrinker, &shrinker_list, list) {
> -		struct shrink_control sc = {
> -			.gfp_mask = gfp_mask,
> +		struct shrink_control shrinkctl = {
> +			.gfp_mask = sc->gfp_mask,
>  			.nid = nid,
>  			.memcg = memcg,
>  		};
> @@ -494,9 +500,10 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  			continue;
>  
>  		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
> -			sc.nid = 0;
> +			shrinkctl.nid = 0;
>  
> -		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
> +		freed += do_shrink_slab(sc, &shrinkctl, shrinker, nr_scanned,
> +					nr_eligible);
>  	}
>  
>  	up_read(&shrinker_rwsem);
> @@ -510,11 +517,15 @@ void drop_slab_node(int nid)
>  	unsigned long freed;
>  
>  	do {
> +		struct scan_control sc = {
> +			.nr_to_reclaim = -1UL,
> +			.gfp_mask = GFP_KERNEL,
> +		};
>  		struct mem_cgroup *memcg = NULL;
>  
>  		freed = 0;
>  		do {
> -			freed += shrink_slab(GFP_KERNEL, nid, memcg,
> +			freed += shrink_slab(&sc, nid, memcg,
>  					     1000, 1000);
>  		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
>  	} while (freed > 10);
> @@ -2600,7 +2611,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  			node_lru_pages += lru_pages;
>  
>  			if (memcg)
> -				shrink_slab(sc->gfp_mask, pgdat->node_id,
> +				shrink_slab(sc, pgdat->node_id,
>  					    memcg, sc->nr_scanned - scanned,
>  					    lru_pages);
>  
> @@ -2631,7 +2642,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  		 * the eligible LRU pages were scanned.
>  		 */
>  		if (global_reclaim(sc))
> -			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
> +			shrink_slab(sc, pgdat->node_id, NULL,
>  				    sc->nr_scanned - nr_scanned,
>  				    node_lru_pages);
>  
> -- 
> 2.7.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
