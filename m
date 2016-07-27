Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E14246B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 10:22:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so1125287wmz.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 07:22:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df6si7361790wjb.2.2016.07.27.07.22.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jul 2016 07:22:30 -0700 (PDT)
Date: Wed, 27 Jul 2016 15:22:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: get_scan_count consider reclaimable lru pages
Message-ID: <20160727142226.GA2693@suse.de>
References: <1469604588-6051-1-git-send-email-minchan@kernel.org>
 <1469604588-6051-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1469604588-6051-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 27, 2016 at 04:29:48PM +0900, Minchan Kim wrote:
> With node-lru, if there are enough reclaimable pages in highmem
> but nothing in lowmem, VM try to shrink inactive list although
> the requested zone is lowmem.
> 
> The problem is that if the inactive list is full of highmem pages then a
> direct reclaimer searching for a lowmem page waste CPU scanning uselessly.
> It just burns out CPU.  Even, many direct reclaimers are stalled by
> too_many_isolated if lots of parallel reclaimer are going on although
> there are no reclaimable memory in inactive list.
> 

The too_many_isolated point is interesting because the fact we
congestion_wait in there is daft. Too many isolated LRU pages has nothing
to do with congestion or dirty pages. More on that later

> To solve the issue, get_scan_count should consider zone-reclaimable lru
> size in case of constrained-alloc rather than node-lru size so it should
> not scan lru list if there is no reclaimable pages in lowmem area.
> 
> Another optimization is to avoid too many stall in too_many_isolated loop
> if there isn't any reclaimable page any more.
> 

That should be split into a separate patch, particularly if
too_many_isolated is altered to avoid congestion_wait.

> This patch reduces hackbench elapsed time from 400sec to 50sec.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Incidentally, this does not apply to mmots (note mmots and not mmotm)
due to other patches that have been picked up in the meantime. It needs
to be rebased.

I had trouble replicating your exact results. I do not know if this is
because we used a different baseline (I had to revert patches and do
some fixups to apply yours) or whether we have different versions of
hackbench. The version I'm using uses 40 processes per group, how many
does yours use?

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d572b78..87d186f 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -805,7 +805,8 @@ static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
>  #endif
>  }
>  
> -extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru);
> +extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru,
> +					int classzone);
>  

Use reclaim_idx as it's sc->reclaim_idx that is passed in. Lets not
reintroduce any confusion between classzone_idx and reclaim_idx.

>  #ifdef CONFIG_HAVE_MEMORY_PRESENT
>  void memory_present(int nid, unsigned long start, unsigned long end);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f8ded2b..f553fd8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -234,12 +234,33 @@ bool pgdat_reclaimable(struct pglist_data *pgdat)
>  		pgdat_reclaimable_pages(pgdat) * 6;
>  }
>  
> -unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
> +/*
> + * Return size of lru list zones[0..classzone_idx] if memcg is disabled.
> + */
> +unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru,
> +				int classzone_idx)
>  {
> +	struct pglist_data *pgdat;
> +	unsigned long nr_pages, nr_zone_pages;
> +	int zid;
> +	struct zone *zone;
> +
>  	if (!mem_cgroup_disabled())
>  		return mem_cgroup_get_lru_size(lruvec, lru);
>  
> -	return node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
> +	pgdat = lruvec_pgdat(lruvec);
> +	nr_pages = node_page_state(pgdat, NR_LRU_BASE + lru);
> +
> +	for (zid = classzone_idx + 1; zid < MAX_NR_ZONES; zid++) {
> +		zone = &pgdat->node_zones[zid];
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		nr_zone_pages = zone_page_state(zone, NR_ZONE_LRU_BASE + lru);
> +		nr_pages -= min(nr_pages, nr_zone_pages);
> +	}
> +
> +	return nr_pages;
>  }
>  
>  /*

Ok.

> @@ -1481,13 +1502,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  			total_skipped += nr_skipped[zid];
>  		}
>  
> -		/*
> -		 * Account skipped pages as a partial scan as the pgdat may be
> -		 * close to unreclaimable. If the LRU list is empty, account
> -		 * skipped pages as a full scan.
> -		 */
> -		scan += list_empty(src) ? total_skipped : total_skipped >> 2;
> -
>  		list_splice(&pages_skipped, src);
>  	}
>  	*nr_scanned = scan;

It's not clear why this is removed. Minimally, there is a race between
when lruvec_lru_size is checked and when the pages are isolated that can
empty the LRU lists in the meantime. Furthermore, if the lists are small
then it still makes sense to account for skipped pages as partial scans
to ensure OOM detection happens. 

> @@ -1652,6 +1666,30 @@ static int current_may_throttle(void)
>  		bdi_write_congested(current->backing_dev_info);
>  }
>  
> +static bool inactive_reclaimable_pages(struct lruvec *lruvec,
> +				struct scan_control *sc, enum lru_list lru)
> +{
> +	int zid;
> +	struct zone *zone;
> +	int file = is_file_lru(lru);
> +	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> +
> +	if (!global_reclaim(sc))
> +		return true;
> +
> 

When you rebase, it should be clear that this check can disappear.

> +	for (zid = sc->reclaim_idx; zid >= 0; zid--) {
> +		zone = &pgdat->node_zones[zid];
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		if (zone_page_state_snapshot(zone, NR_ZONE_LRU_BASE +
> +				LRU_FILE * file) >= SWAP_CLUSTER_MAX)
> +			return true;
> +	}
> +
> +	return false;
> +}
> +
>  /*
>   * shrink_inactive_list() is a helper for shrink_node().  It returns the number
>   * of reclaimed pages
> @@ -1674,12 +1712,23 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>  
> +	/*
> +	 * Although get_scan_count tell us it's worth to scan, there
> +	 * would be no reclaimalble pages in the list if parallel
> +	 * reclaimers already isolated them.
> +	 */
> +	if (!inactive_reclaimable_pages(lruvec, sc, lru))
> +		return 0;
> +
>  	while (unlikely(too_many_isolated(pgdat, file, sc))) {
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/* We are about to die and free our memory. Return now. */
>  		if (fatal_signal_pending(current))
>  			return SWAP_CLUSTER_MAX;
> +
> +		if (!inactive_reclaimable_pages(lruvec, sc, lru))
> +			return 0;
>  	}
>  
>  	lru_add_drain();

I think it makes sense to fix this loop first before putting that check
in. I'll post a candidate patch below that arguably should be merged
before this one.

The rest looked ok but I haven't tested it in depth. I'm gathering a
baseline set of results based on mmots at the moment and so should be
ready when/if v2 of this patch arrives.

I'd also like you to consider the following for applying first.

---8<---
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, vmscan: Wait on a waitqueue when too many pages are
 isolated

When too many pages are isolated, direct reclaim waits on congestion to
clear for up to a tenth of a second. There is no reason to believe that too
many pages are isolated due to dirty pages, reclaim efficiency or congestion.
It may simply be because an extremely large number of processes have entered
direct reclaim at the same time.

This patch has processes wait on a waitqueue when too many pages are
isolated.  When parallel reclaimers finish shrink_page_list, they wake the
waiters to recheck whether too many pages are isolated. While it is difficult
to trigger this corner case, it's possible by lauching an extremely large
number of hackbench processes on a 32-bit system with limited memory. Without
the patch, a large number of processes wait uselessly and with the patch
applied, I was unable to stall the system.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 87d186fe60b4..510e074e2f7f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -653,6 +653,7 @@ typedef struct pglist_data {
 	int node_id;
 	wait_queue_head_t kswapd_wait;
 	wait_queue_head_t pfmemalloc_wait;
+	wait_queue_head_t isolated_wait;
 	struct task_struct *kswapd;	/* Protected by
 					   mem_hotplug_begin/end() */
 	int kswapd_order;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fbd329e61bf6..3800972f240e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5859,6 +5859,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 #endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
+	init_waitqueue_head(&pgdat->isolated_wait);
 #ifdef CONFIG_COMPACTION
 	init_waitqueue_head(&pgdat->kcompactd_wait);
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f553fd8597e9..60ba22a8bf1f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1568,16 +1568,16 @@ int isolate_lru_page(struct page *page)
  * the LRU list will go small and be scanned faster than necessary, leading to
  * unnecessary swapping, thrashing and OOM.
  */
-static int too_many_isolated(struct pglist_data *pgdat, int file,
+static bool safe_to_isolate(struct pglist_data *pgdat, int file,
 		struct scan_control *sc)
 {
 	unsigned long inactive, isolated;
 
 	if (current_is_kswapd())
-		return 0;
+		return true;
 
-	if (!sane_reclaim(sc))
-		return 0;
+	if (sane_reclaim(sc))
+		return true;
 
 	if (file) {
 		inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
@@ -1595,7 +1595,7 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
 	if ((sc->gfp_mask & (__GFP_IO | __GFP_FS)) == (__GFP_IO | __GFP_FS))
 		inactive >>= 3;
 
-	return isolated > inactive;
+	return isolated < inactive;
 }
 
 static noinline_for_stack void
@@ -1720,8 +1720,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (!inactive_reclaimable_pages(lruvec, sc, lru))
 		return 0;
 
-	while (unlikely(too_many_isolated(pgdat, file, sc))) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
+	if (!safe_to_isolate(pgdat, file, sc)) {
+		wait_event_killable(pgdat->isolated_wait,
+			safe_to_isolate(pgdat, file, sc));
 
 		/* We are about to die and free our memory. Return now. */
 		if (fatal_signal_pending(current))
@@ -1763,6 +1764,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 				&nr_writeback, &nr_immediate,
 				false);
 
+	wake_up_all(&pgdat->isolated_wait);
+
 	spin_lock_irq(&pgdat->lru_lock);
 
 	if (global_reclaim(sc)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
