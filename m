Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE0816B028D
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 05:08:02 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id ez4so7435421wjd.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 02:08:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d22si3865038wrb.2.2017.01.19.02.08.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 02:08:01 -0800 (PST)
Date: Thu, 19 Jan 2017 10:07:55 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170119100755.rs6erdiz5u5by2pu@suse.de>
References: <20170118134453.11725-1-mhocko@kernel.org>
 <20170118134453.11725-2-mhocko@kernel.org>
 <20170118144655.3lra7xgdcl2awgjd@suse.de>
 <20170118151530.GR7015@dhcp22.suse.cz>
 <20170118155430.kimzqkur5c3te2at@suse.de>
 <20170118161731.GT7015@dhcp22.suse.cz>
 <20170118170010.agpd4njpv5log3xe@suse.de>
 <20170118172944.GA17135@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170118172944.GA17135@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 18, 2017 at 06:29:46PM +0100, Michal Hocko wrote:
> On Wed 18-01-17 17:00:10, Mel Gorman wrote:
> > > > You don't appear to directly use that information in patch 2.
> > > 
> > > It is used via zone_reclaimable_pages in should_reclaim_retry
> > > 
> > 
> > Which is still not directly required to avoid the infinite loop. There
> > even is a small inherent risk if the too_isolated_condition no longer
> > applies at the time should_reclaim_retry is attempted.
> 
> Not really because, if those pages are no longer isolated then they
> either have been reclaimed - and NR_FREE_PAGES will increase - or they
> have been put back to LRU in which case we will see them in regular LRU
> counters. I need to catch the case where there are still too many pages
> isolated which would skew should_reclaim_retry watermark check.
>  

We can also rely on the no_progress_loops counter to trigger OOM. It'll
take longer but has a lower risk of premature OOM.

> > > > The primary
> > > > breakout is returning after stalling at least once. You could also avoid
> > > > an infinite loop by using a waitqueue that sleeps on too many isolated.
> > > 
> > > That would be tricky on its own. Just consider the report form Tetsuo.
> > > Basically all the direct reclamers are looping on too_many_isolated
> > > while the kswapd is not making any progres because it is blocked on FS
> > > locks which are held by flushers which are making dead slow progress.
> > > Some of those direct reclaimers could have gone oom instead and release
> > > some memory if we decide so, which we cannot because we are deep down in
> > > the reclaim path. Waiting for on the reclaimer to increase the ISOLATED
> > > counter wouldn't help in this situation.
> > > 
> > 
> > If it's a waitqueue waking one process at a time, the progress may be
> > slow but it'll still exit the loop, attempt the reclaim and then
> > potentially OOM if no progress is made. The key is using the waitqueue
> > to have a fair queue of processes making progress instead of a
> > potentially infinite loop that never meets the exit conditions.
> 
> It is not clear to me who would wake waiters on the queue. You cannot
> rely on kswapd to do that as already mentioned.
> 

We can use timeouts to guard against an infinite wait. Besides, updating
every single place where pages are put back on the LRU would be fragile
and too easy to break.

> > > > That would both avoid the clunky congestion_wait() and guarantee forward
> > > > progress. If the primary motivation is to avoid an infinite loop with
> > > > too_many_isolated then there are ways of handling that without reintroducing
> > > > zone-based counters.
> > > > 
> > > > > > Heavy memory pressure on highmem should be spread across the whole node as
> > > > > > we no longer are applying the fair zone allocation policy. The processes
> > > > > > with highmem requirements will be reclaiming from all zones and when it
> > > > > > finishes, it's possible that a lowmem-specific request will be clear to make
> > > > > > progress. It's all the same LRU so if there are too many pages isolated,
> > > > > > it makes sense to wait regardless of the allocation request.
> > > > > 
> > > > > This is true but I am not sure how it is realated to the patch.
> > > > 
> > > > Because heavy pressure that is enough to trigger too many isolated pages
> > > > is unlikely to be specifically targetting a lower zone.
> > > 
> > > Why? Basically any GFP_KERNEL allocation will make lowmem pressure and
> > > going OOM on lowmem is not all that unrealistic scenario on 32b systems.
> > > 
> > 
> > If the sole source of pressure is from GFP_KERNEL allocations then the
> > isolated counter will also be specific to the lower zones and there is no
> > benefit from the patch.
> 
> I believe you are wrong here. Just consider that you have isolated
> basically all lowmem pages. too_many_isolated will still happily tell
> you to not throttle or back off because NR_INACTIVE_* are way too bigger
> than all low mem pages altogether. Or am I still missing your point?
> 

This is a potential risk. It could be accounted for by including the node
isolated counters in the calculation but it'll be inherently fuzzy and
may stall a lowmem direct reclaimer unnecessarily in the presence of
highmem reclaim.

> > If there is a combination of highmem and lowmem pressure then the highmem
> > reclaimers will also reclaim lowmem memory.
> > 
> > > > There is general
> > > > pressure with multiple direct reclaimers being applied. If the system is
> > > > under enough pressure with parallel reclaimers to trigger too_many_isolated
> > > > checks then the system is grinding already and making little progress. Adding
> > > > multiple counters to allow a lowmem reclaimer to potentially make faster
> > > > progress is going to be marginal at best.
> > > 
> > > OK, I agree that the situation where highmem blocks lowmem from making
> > > progress is much less likely than the other situation described in the
> > > changelog when lowmem doesn't get throttled ever. Which is the one I am
> > > interested more about.
> > > 
> > 
> > That is of some concern but could be handled by having too_may_isolated
> > take into account if it's a zone-restricted allocation and if so, then
> > decrement the LRU counts from the higher zones. Counters already exist
> > there. It would not be as strict but it should be sufficient.
> 
> Well, this is what this patch tries to do. Which other counters I can
> use to consider only eligible zones when evaluating the number of
> isolated pages?
> 

The LRU anon/file counters. It'll reduce the number of eligible pages
for reclaim.

> > > > > Also consider that lowmem throttling in too_many_isolated has only small
> > > > > chance to ever work with the node counters because highmem >> lowmem in
> > > > > many/most configurations.
> > > > > 
> > > > 
> > > > While true, it's also not that important.
> > > > 
> > > > > > More importantly, this patch may make things worse and delay reclaim. If
> > > > > > this patch allowed a lowmem request to make progress that would have
> > > > > > previously stalled, it's going to spend time skipping pages in the LRU
> > > > > > instead of letting kswapd and the highmem pressured processes make progress.
> > > > > 
> > > > > I am not sure I understand this part. Say that we have highmem pressure
> > > > > which would isolated too many pages from the LRU.
> > > > 
> > > > Which requires multiple direct reclaimers or tiny inactive lists. In the
> > > > event there is such highmem pressure, it also means the lower zones are
> > > > depleted.
> > > 
> > > But consider a lowmem without highmem pressure. E.g. a heavy parallel
> > > fork or any other GFP_KERNEL intensive workload.
> > >  
> > 
> > Lowmem without highmem pressure means all isolated pages are in the lowmem
> > nodes and the per-zone counters are unnecessary.
> 
> But most configurations will have highmem and lowmem zones in the same
> node...

True but if it's only lowmem pressure it doesn't matter.

>  
> > > OK, I guess we are talking past each other. What I meant to say is that
> > > it doesn't really make any difference who is chewing through the LRU to
> > > find last few lowmem pages to reclaim. So I do not see much of a
> > > difference sleeping and postponing that to the kswapd.
> > > 
> > > That being said, I _believe_ I will need per zone ISOLATED counters in
> > > order to make the other patch work reliably and do not declare oom
> > > prematurely. Maybe there is some other way around that (hence this RFC).
> > > Would you be strongly opposed to the patch which would make counters per
> > > zone without touching too_many_isolated?
> > 
> > I'm resistent to the per-zone counters in general but it's unfortunate to
> > add them just to avoid a potentially infinite loop from isolated pages.
> 
> I am really open to any alternative solutions, of course. This is
> the best I could come up with. I will keep thinking but removing
> too_many_isolated without considering isolated pages during the oom
> detection is just too risky. We can isolate many pages to ignore them.

If it's definitely required and is proven to fix the
infinite-loop-without-oom workload then I'll back off and withdraw my
objections. However, I'd at least like the following untested patch to
be considered as an alternative. It has some weaknesses and would be
slower to OOM than your patch but it avoids reintroducing zone counters

---8<---
mm, vmscan: Wait on a waitqueue when too many pages are isolated

When too many pages are isolated, direct reclaim waits on congestion to clear
for up to a tenth of a second. There is no reason to believe that too many
pages are isolated due to dirty pages, reclaim efficiency or congestion.
It may simply be because an extremely large number of processes have entered
direct reclaim at the same time. However, it is possible for the situation
to persist forever and never reach OOM.

This patch queues processes a waitqueue when too many pages are isolated.
When parallel reclaimers finish shrink_page_list, they wake the waiters
to recheck whether too many pages are isolated.

The wait on the queue has a timeout as not all sites that isolate pages
will do the wakeup. Depending on every isolation of LRU pages to be perfect
forever is potentially fragile. The specific wakeups occur for page reclaim
and compaction. If too many pages are isolated due to memory failure,
hotplug or directly calling migration from a syscall then the waiting
processes may wait the full timeout.

Note that the timeout allows the use of waitqueue_active() on the basis
that a race will cause the full timeout to be reached due to a missed
wakeup. This is relatively harmless and still a massive improvement over
unconditionally calling congestion_wait.

Direct reclaimers that cannot isolate pages within the timeout will consider
return to the caller. This is somewhat clunky as it won't return immediately
and make go through the other priorities and slab shrinking. Eventually,
it'll go through a few iterations of should_reclaim_retry and reach the
MAX_RECLAIM_RETRIES limit and consider going OOM.

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 91f69aa0d581..3dd617d0c8c4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -628,6 +628,7 @@ typedef struct pglist_data {
 	int node_id;
 	wait_queue_head_t kswapd_wait;
 	wait_queue_head_t pfmemalloc_wait;
+	wait_queue_head_t isolated_wait;
 	struct task_struct *kswapd;	/* Protected by
 					   mem_hotplug_begin/end() */
 	int kswapd_order;
diff --git a/mm/compaction.c b/mm/compaction.c
index 43a6cf1dc202..1b1ff6da7401 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1634,6 +1634,10 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	count_compact_events(COMPACTMIGRATE_SCANNED, cc->total_migrate_scanned);
 	count_compact_events(COMPACTFREE_SCANNED, cc->total_free_scanned);
 
+	/* Page reclaim could have stalled due to isolated pages */
+	if (waitqueue_active(&zone->zone_pgdat->isolated_wait))
+		wake_up(&zone->zone_pgdat->isolated_wait);
+
 	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync, ret);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8ff25883c172..d848c9f31bff 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5823,6 +5823,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 #endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
+	init_waitqueue_head(&pgdat->isolated_wait);
 #ifdef CONFIG_COMPACTION
 	init_waitqueue_head(&pgdat->kcompactd_wait);
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2281ad310d06..c93f299fbad7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1603,16 +1603,16 @@ int isolate_lru_page(struct page *page)
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
@@ -1630,7 +1630,7 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
 	if ((sc->gfp_mask & (__GFP_IO | __GFP_FS)) == (__GFP_IO | __GFP_FS))
 		inactive >>= 3;
 
-	return isolated > inactive;
+	return isolated < inactive;
 }
 
 static noinline_for_stack void
@@ -1719,12 +1719,28 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	while (unlikely(too_many_isolated(pgdat, file, sc))) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
+	while (!safe_to_isolate(pgdat, file, sc)) {
+		long ret;
+
+		ret = wait_event_interruptible_timeout(pgdat->isolated_wait,
+			safe_to_isolate(pgdat, file, sc), HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
-		if (fatal_signal_pending(current))
-			return SWAP_CLUSTER_MAX;
+		if (fatal_signal_pending(current)) {
+			nr_reclaimed = SWAP_CLUSTER_MAX;
+			goto out;
+		}
+
+		/*
+		 * If we reached the timeout, this is direct reclaim, and
+		 * pages cannot be isolated then return. If the situation
+		 * persists for a long time then it'll eventually reach
+		 * the no_progress limit in should_reclaim_retry and consider
+		 * going OOM. In this case, do not wake the isolated_wait
+		 * queue as the wakee will still not be able to make progress.
+		 */
+		if (!ret && !current_is_kswapd() && !safe_to_isolate(pgdat, file, sc))
+			return 0;
 	}
 
 	lru_add_drain();
@@ -1839,6 +1855,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 			stat.nr_activate, stat.nr_ref_keep,
 			stat.nr_unmap_fail,
 			sc->priority, file);
+
+out:
+	if (waitqueue_active(&pgdat->isolated_wait))
+		wake_up(&pgdat->isolated_wait);
 	return nr_reclaimed;
 }
 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
