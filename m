Date: Wed, 12 Sep 2007 05:17:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 06 of 24] reduce the probability of an OOM livelock
Message-Id: <20070912051730.c9efd406.akpm@linux-foundation.org>
In-Reply-To: <49e2d90eb0d7b1021b1e.1187786933@v2.random>
References: <patchbomb.1187786927@v2.random>
	<49e2d90eb0d7b1021b1e.1187786933@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:48:53 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1187778125 -7200
> # Node ID 49e2d90eb0d7b1021b1e1e841bef22fdc647766e
> # Parent  de62eb332b1dfee7e493043b20e560283ef42f67
> reduce the probability of an OOM livelock
> 
> There's no need to loop way too many times over the lrus in order to
> declare defeat and decide to kill a task. The more loops we do the more
> likely there we'll run in a livelock with a page bouncing back and
> forth between tasks. The maximum number of entries to check in a loop
> that returns less than swap-cluster-max pages freed, should be the size
> of the list (or at most twice the size of the list if you want to be
> really paranoid about the PG_referenced bit).
> 
> Our objective there is to know reliably when it's time that we kill a
> task, tring to free a few more pages at that already ciritical point is
> worthless.
> 
> This seems to have the effect of reducing the "hang" time during oom
> killing.
> 
> Signed-off-by: Andrea Arcangeli <andrea@suse.de>
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1112,7 +1112,7 @@ unsigned long try_to_free_pages(struct z
>  	int priority;
>  	int ret = 0;
>  	unsigned long total_scanned = 0;
> -	unsigned long nr_reclaimed = 0;
> +	unsigned long nr_reclaimed;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	unsigned long lru_pages = 0;
>  	int i;
> @@ -1141,12 +1141,12 @@ unsigned long try_to_free_pages(struct z
>  		sc.nr_scanned = 0;
>  		if (!priority)
>  			disable_swap_token();
> -		nr_reclaimed += shrink_zones(priority, zones, &sc);
> +		nr_reclaimed = shrink_zones(priority, zones, &sc);
> +		if (reclaim_state)
> +			reclaim_state->reclaimed_slab = 0;
>  		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
> -		if (reclaim_state) {
> +		if (reclaim_state)
>  			nr_reclaimed += reclaim_state->reclaimed_slab;
> -			reclaim_state->reclaimed_slab = 0;
> -		}
>  		total_scanned += sc.nr_scanned;
>  		if (nr_reclaimed >= sc.swap_cluster_max) {
>  			ret = 1;

I don't get it.  This code changes try_to_free_pages() so that it will only
bale out when a single scan of the zone at a particular priority reclaimed
more than swap_cluster_max pages.  Previously we'd include the results of all the
lower-priority scanning in that comparison too.

So this patch will make try_to_free_pages() do _more_ scanning than it used
to, in some situations.  Which seems opposite to what you're trying to do
here.

> @@ -1238,7 +1238,6 @@ static unsigned long balance_pgdat(pg_da
>  
>  loop_again:
>  	total_scanned = 0;
> -	nr_reclaimed = 0;
>  	sc.may_writepage = !laptop_mode;
>  	count_vm_event(PAGEOUTRUN);
>  
> @@ -1293,6 +1292,7 @@ loop_again:
>  		 * pages behind kswapd's direction of progress, which would
>  		 * cause too much scanning of the lower zones.
>  		 */
> +		nr_reclaimed = 0;
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
>  			int nr_slab;
> 

A similar situation exists with this change.

Your changelog made no mention of the change to balance_pgdat() and I'm
struggling a bit to see what it's doing in there.


In both places, the definition of local variable nr_reclaimed can be moved
into a more inner scope.  This makes the code easier to follow.  Please
watch out for cleanup opportunities like that.

I'll skip this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
