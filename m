Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0F3C6B0038
	for <linux-mm@kvack.org>; Tue,  2 May 2017 17:27:27 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id e53so36921472qte.17
        for <linux-mm@kvack.org>; Tue, 02 May 2017 14:27:27 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id e78si17767268qkj.324.2017.05.02.14.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 14:27:26 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id t52so22188042qtb.3
        for <linux-mm@kvack.org>; Tue, 02 May 2017 14:27:26 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH][RFC] mm: make kswapd try harder to keep active pages in cache
Date: Tue,  2 May 2017 17:27:24 -0400
Message-Id: <1493760444-18250-1-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, hannes@cmpxchg.org, kernel-team@fb.com, riel@redhat.com

When testing a slab heavy workload I noticed that we often would barely
reclaim anything at all from slab when kswapd started doing reclaim.
This is because we use the ratio of nr_scanned / nr_lru to determine how
much of slab we should reclaim.  But in a slab only/mostly workload we
will not have much page cache to reclaim, and thus our ratio will be
really low and not at all related to where the memory on the system is.
Instead we want to use a ratio of the reclaimable slab to the actual
reclaimable space on the system.  That way if we are slab heavy we work
harder to reclaim slab.

The other part of this that hurts is when we are running close to full
memory with our working set.  If we start putting a lot of reclaimable
slab pressure on the system (think find /, or some other silliness), we
will happily evict the active pages over the slab cache.  This is kind
of backwards as we want to do all that we can to keep the active working
set in memory, and instead evict these short lived objects.  The same
thing occurs when say you do a yum update of a few packages while your
working set takes up most of RAM, you end up with inactive lists being
relatively small and so we reclaim active pages even though we could
reclaim these short lived inactive pages.

Enter this patch.  I wanted to break it up into two parts but they are
so interlinked that it wasn't really practical.  Instead of scanning
active/inactive LRU's together and slab as an afterthought, instead
take a look at the node state from the beginning and purposefully only
considering the inactive LRU's and slab.  Then if for example inactive
isn't reclaiming anything but slab is, increase the pressure on the slab
cache until we reclaim what we want, or stop being effective and then
start processing all the LRU's like we normally would.

I have two tests I was using to watch either side of this problem.  The
first test kept 2 files that took up 3/4 of the memory, and then started
creating a bunch of empty files.  Without this patch we would have to
re-read both files in their entirety at least 3 times during the run.
With this patch the active pages are never evicted.

The second test was a test that would read and stat all the files in a
directory, which again would take up about 3/4 of the memory with slab
cache.  Then I cat'ed a 100gib file into /dev/null and checked to see if
any of the files were evicted and verified that none of the files were
evicted.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/vmscan.c | 126 ++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 105 insertions(+), 21 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bc8031e..457583d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -105,6 +105,9 @@ struct scan_control {
 	/* One of the zones is ready for compaction */
 	unsigned int compaction_ready:1;
 
+	/* Only reclaim inactive page cache or slab. */
+	unsigned int inactive_only:1;
+
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
 
@@ -309,7 +312,8 @@ EXPORT_SYMBOL(unregister_shrinker);
 static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 				    struct shrinker *shrinker,
 				    unsigned long nr_scanned,
-				    unsigned long nr_eligible)
+				    unsigned long nr_eligible,
+				    unsigned long *slab_scanned)
 {
 	unsigned long freed = 0;
 	unsigned long long delta;
@@ -410,6 +414,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		next_deferred -= scanned;
 	else
 		next_deferred = 0;
+	if (slab_scanned)
+		(*slab_scanned) += scanned;
+
 	/*
 	 * move the unused scan count back into the shrinker in a
 	 * manner that handles concurrent updates. If we exhausted the
@@ -456,7 +463,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 				 struct mem_cgroup *memcg,
 				 unsigned long nr_scanned,
-				 unsigned long nr_eligible)
+				 unsigned long nr_eligible,
+				 unsigned long *slab_scanned)
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
@@ -464,9 +472,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
 		return 0;
 
-	if (nr_scanned == 0)
-		nr_scanned = SWAP_CLUSTER_MAX;
-
 	if (!down_read_trylock(&shrinker_rwsem)) {
 		/*
 		 * If we would return 0, our callers would understand that we
@@ -497,7 +502,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
-		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
+		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible,
+					slab_scanned);
 	}
 
 	up_read(&shrinker_rwsem);
@@ -516,7 +522,7 @@ void drop_slab_node(int nid)
 		freed = 0;
 		do {
 			freed += shrink_slab(GFP_KERNEL, nid, memcg,
-					     1000, 1000);
+					     1000, 1000, NULL);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
 	} while (freed > 10);
 }
@@ -2100,6 +2106,7 @@ enum scan_balance {
 	SCAN_FRACT,
 	SCAN_ANON,
 	SCAN_FILE,
+	SCAN_INACTIVE,
 };
 
 /*
@@ -2148,6 +2155,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	if (!global_reclaim(sc))
 		force_scan = true;
 
+	if (sc->inactive_only) {
+		scan_balance = SCAN_INACTIVE;
+		goto out;
+	}
+
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
 		scan_balance = SCAN_FILE;
@@ -2312,6 +2324,15 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 					scan = 0;
 				}
 				break;
+			case SCAN_INACTIVE:
+				if (file && !is_active_lru(lru)) {
+					if (scan && size > sc->nr_to_reclaim)
+						scan = sc->nr_to_reclaim;
+				} else {
+					size = 0;
+					scan = 0;
+				}
+				break;
 			default:
 				/* Look ma, no brain */
 				BUG();
@@ -2536,7 +2557,40 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
+	unsigned long nr_reclaim, nr_slab, total_high_wmark = 0, nr_inactive;
+	int z;
 	bool reclaimable = false;
+	bool skip_slab = false;
+
+	nr_slab = sum_zone_node_page_state(pgdat->node_id,
+					   NR_SLAB_RECLAIMABLE);
+	nr_inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
+	nr_reclaim = pgdat_reclaimable_pages(pgdat);
+
+	for (z = 0; z < MAX_NR_ZONES; z++) {
+		struct zone *zone = &pgdat->node_zones[z];
+		if (!managed_zone(zone))
+			continue;
+		total_high_wmark += high_wmark_pages(zone);
+	}
+
+	/*
+	 * If we don't have a lot of inactive or slab pages then there's no
+	 * point in trying to free them exclusively, do the normal scan stuff.
+	 */
+	if (nr_inactive < total_high_wmark && nr_slab < total_high_wmark)
+		sc->inactive_only = 0;
+	if (!global_reclaim(sc))
+		sc->inactive_only = 0;
+
+	/*
+	 * We still want to slightly prefer slab over inactive, so if inactive
+	 * is large enough just skip slab shrinking for now.  If we aren't able
+	 * to reclaim enough exclusively from the inactive lists then we'll
+	 * reset this on the first loop and dip into slab.
+	 */
+	if (nr_inactive > total_high_wmark && nr_inactive > nr_slab)
+		skip_slab = true;
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2545,6 +2599,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			.priority = sc->priority,
 		};
 		unsigned long node_lru_pages = 0;
+		unsigned long slab_reclaimed = 0;
+		unsigned long slab_scanned = 0;
 		struct mem_cgroup *memcg;
 
 		nr_reclaimed = sc->nr_reclaimed;
@@ -2568,10 +2624,23 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
-			if (memcg)
-				shrink_slab(sc->gfp_mask, pgdat->node_id,
-					    memcg, sc->nr_scanned - scanned,
-					    lru_pages);
+			/*
+			 * We don't want to put a lot of pressure on all of the
+			 * slabs if a memcg is mostly full, so use the ratio of
+			 * the lru size to the total reclaimable space on the
+			 * system.  If we have sc->inactive_only set only use
+			 * this node's inactive space to get a more realistic
+			 * ratio.
+			 */
+			if (memcg && !skip_slab) {
+				unsigned long denominator = nr_reclaim;
+				if (sc->inactive_only)
+					denominator = nr_inactive;
+				slab_reclaimed +=
+					shrink_slab(sc->gfp_mask, pgdat->node_id,
+						    memcg, lru_pages, denominator,
+						    &slab_scanned);
+			}
 
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
@@ -2595,15 +2664,11 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			}
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
-		/*
-		 * Shrink the slab caches in the same proportion that
-		 * the eligible LRU pages were scanned.
-		 */
-		if (global_reclaim(sc))
-			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
-				    sc->nr_scanned - nr_scanned,
-				    node_lru_pages);
-
+		if (!skip_slab && global_reclaim(sc))
+			slab_reclaimed += shrink_slab(sc->gfp_mask,
+						      pgdat->node_id, NULL,
+						      nr_slab, nr_reclaim,
+						      &slab_scanned);
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
@@ -2614,9 +2679,27 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			   sc->nr_scanned - nr_scanned,
 			   sc->nr_reclaimed - nr_reclaimed);
 
-		if (sc->nr_reclaimed - nr_reclaimed)
+		if (sc->nr_reclaimed - nr_reclaimed) {
 			reclaimable = true;
+		} else if (sc->inactive_only && !skip_slab) {
+			unsigned long percent;
 
+			/*
+			 * We didn't reclaim anything this go around, so the
+			 * inactive list is likely spent.  If we're reclaiming
+			 * less than half of the objects in slab that we're
+			 * scanning then just stop doing the inactive only scan.
+			 * Otherwise ramp up the pressure on the slab caches
+			 * hoping that eventually we'll start freeing enough
+			 * objects to reclaim space.
+			 */
+			percent = (slab_reclaimed * 100 / slab_scanned);
+			if (percent < 50)
+				sc->inactive_only = 0;
+			else
+				nr_slab <<= 1;
+		}
+		skip_slab = false;
 	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 
@@ -3210,6 +3293,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = 1,
+		.inactive_only = 1,
 	};
 	count_vm_event(PAGEOUTRUN);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
