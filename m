Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0233D6B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 00:02:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s4so226685086pgr.3
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 21:02:06 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w33si14453232plb.501.2017.07.03.21.02.05
        for <linux-mm@kvack.org>;
        Mon, 03 Jul 2017 21:02:05 -0700 (PDT)
Date: Tue, 4 Jul 2017 13:02:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/4] vmscan: bailout of slab reclaim once we reach our
 target
Message-ID: <20170704040204.GB16432@bbox>
References: <1499095984-1942-1-git-send-email-jbacik@fb.com>
 <1499095984-1942-2-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499095984-1942-2-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josef@toxicpanda.com
Cc: linux-mm@kvack.org, riel@redhat.com, hannes@cmpxchg.org, kernel-team@fb.com, akpm@linux-foundation.org, Josef Bacik <jbacik@fb.com>

On Mon, Jul 03, 2017 at 11:33:02AM -0400, josef@toxicpanda.com wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Following patches will greatly increase our aggressiveness in slab
> reclaim, so we need checks in place to make sure we stop trying to
> reclaim slab once we've hit our reclaim target.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
>  mm/vmscan.c | 35 ++++++++++++++++++++++++-----------
>  1 file changed, 24 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index cf23de9..77a887a 100644
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
> @@ -494,9 +500,12 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  			continue;
>  
>  		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
> -			sc.nid = 0;
> +			shrinkctl.nid = 0;
>  
> -		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
> +		freed += do_shrink_slab(sc, &shrinkctl, shrinker, nr_scanned,
> +					nr_eligible);
> +		if (sc->nr_to_reclaim <= sc->nr_reclaimed)
> +			break;
>  	}
>  

Such bailout ruins fair aging so that a specific shrinker in head of the list
will be exhausted. Also, without fair aging, it's hard to reclaim a slab page
mixed several type objects. I don't think it's a good idea to bail out after
passing huge aggressive scan number.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
