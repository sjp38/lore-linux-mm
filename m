Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 327B06B0006
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 14:02:24 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c2-v6so1420198plo.21
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 11:02:24 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0108.outbound.protection.outlook.com. [104.47.1.108])
        by mx.google.com with ESMTPS id m137si7453827pga.382.2018.04.06.11.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 11:02:22 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v3 2/2] mm/vmscan: don't mess with pgdat->flags in memcg reclaim
Date: Fri,  6 Apr 2018 21:02:54 +0300
Message-Id: <20180406180254.8970-2-aryabinin@virtuozzo.com>
In-Reply-To: <20180406180254.8970-1-aryabinin@virtuozzo.com>
References: <20180323152029.11084-1-aryabinin@virtuozzo.com>
 <20180406180254.8970-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

memcg reclaim may alter pgdat->flags based on the state of LRU lists in
cgroup and its children.  PGDAT_WRITEBACK may force kswapd to sleep
congested_wait(), PGDAT_DIRTY may force kswapd to writeback filesystem
pages. But the worst here is PGDAT_CONGESTED, since it may force all
direct reclaims to stall in wait_iff_congested().  Note that only kswapd
have powers to clear any of these bits.  This might just never happen if
cgroup limits configured that way.  So all direct reclaims will stall as
long as we have some congested bdi in the system.

Leave all pgdat->flags manipulations to kswapd. kswapd scans the whole
pgdat, only kswapd can clear pgdat->flags once node is balanced, thus it's
reasonable to leave all decisions about node state to kswapd.

Why only kswapd? Why not allow to global direct reclaim change these flags?
It is because currently only kswapd can clear these flags. I'm less worried
about the case when PGDAT_CONGESTED falsely not set, and more worried about
the case when it falsely set. If direct reclaimer sets PGDAT_CONGESTED, do
we have guarantee that after the congestion problem is sorted out, kswapd
will be woken up and clear the flag? It seems like there is no such
guarantee. E.g. direct reclaimers may eventually balance pgdat and kswapd
simply won't wake up (see wakeup_kswapd()).

Moving pgdat->flags manipulation to kswapd, means that cgroup2 recalim now
loses its congestion throttling mechanism.  Add per-cgroup congestion
state and throttle cgroup2 reclaimers if memcg is in congestion state.

Currently there is no need in per-cgroup PGDAT_WRITEBACK and PGDAT_DIRTY
bits since they alter only kswapd behavior.

The problem could be easily demonstrated by creating heavy congestion
in one cgroup:

    echo "+memory" > /sys/fs/cgroup/cgroup.subtree_control
    mkdir -p /sys/fs/cgroup/congester
    echo 512M > /sys/fs/cgroup/congester/memory.max
    echo $$ > /sys/fs/cgroup/congester/cgroup.procs
    /* generate a lot of diry data on slow HDD */
    while true; do dd if=/dev/zero of=/mnt/sdb/zeroes bs=1M count=1024; done &
    ....
    while true; do dd if=/dev/zero of=/mnt/sdb/zeroes bs=1M count=1024; done &

and some job in another cgroup:

    mkdir /sys/fs/cgroup/victim
    echo 128M > /sys/fs/cgroup/victim/memory.max

    # time cat /dev/sda > /dev/null
    real    10m15.054s
    user    0m0.487s
    sys     1m8.505s

According to the tracepoint in wait_iff_congested(), the 'cat' spent 50%
of the time sleeping there.

With the patch, cat don't waste time anymore:

    # time cat /dev/sda > /dev/null
    real    5m32.911s
    user    0m0.411s
    sys     0m56.664s

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>
---

 Changes since v2:
 - Make congestion state per-cgroup-per-node instead of just per-cgroup. (Shakeel)
 - Changelog update. (Shakeel)
 - Add Acked-by/Reviewed-by

 include/linux/backing-dev.h |  2 +-
 include/linux/memcontrol.h  |  3 ++
 mm/backing-dev.c            | 19 +++------
 mm/vmscan.c                 | 96 +++++++++++++++++++++++++++++++++------------
 4 files changed, 82 insertions(+), 38 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 3e4ce54d84ab..e6cbb915ee56 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -175,7 +175,7 @@ static inline int wb_congested(struct bdi_writeback *wb, int cong_bits)
 }
 
 long congestion_wait(int sync, long timeout);
-long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout);
+long wait_iff_congested(int sync, long timeout);
 
 static inline bool bdi_cap_synchronous_io(struct backing_dev_info *bdi)
 {
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c46016bb25eb..f292efac378d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -120,6 +120,9 @@ struct mem_cgroup_per_node {
 	unsigned long		usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
 	bool			on_tree;
+	bool			congested;	/* memcg has many dirty pages */
+						/* backed by a congested BDI */
+
 	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
 						/* use container_of	   */
 };
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index fac66abd5a68..2b23ba08389a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -1022,23 +1022,18 @@ EXPORT_SYMBOL(congestion_wait);
 
 /**
  * wait_iff_congested - Conditionally wait for a backing_dev to become uncongested or a pgdat to complete writes
- * @pgdat: A pgdat to check if it is heavily congested
  * @sync: SYNC or ASYNC IO
  * @timeout: timeout in jiffies
  *
- * In the event of a congested backing_dev (any backing_dev) and the given
- * @pgdat has experienced recent congestion, this waits for up to @timeout
- * jiffies for either a BDI to exit congestion of the given @sync queue
- * or a write to complete.
- *
- * In the absence of pgdat congestion, cond_resched() is called to yield
- * the processor if necessary but otherwise does not sleep.
+ * In the event of a congested backing_dev (any backing_dev) this waits
+ * for up to @timeout jiffies for either a BDI to exit congestion of the
+ * given @sync queue or a write to complete.
  *
  * The return value is 0 if the sleep is for the full timeout. Otherwise,
  * it is the number of jiffies that were still remaining when the function
  * returned. return_value == timeout implies the function did not sleep.
  */
-long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout)
+long wait_iff_congested(int sync, long timeout)
 {
 	long ret;
 	unsigned long start = jiffies;
@@ -1046,12 +1041,10 @@ long wait_iff_congested(struct pglist_data *pgdat, int sync, long timeout)
 	wait_queue_head_t *wqh = &congestion_wqh[sync];
 
 	/*
-	 * If there is no congestion, or heavy congestion is not being
-	 * encountered in the current pgdat, yield if necessary instead
+	 * If there is no congestion, yield if necessary instead
 	 * of sleeping on the congestion queue
 	 */
-	if (atomic_read(&nr_wb_congested[sync]) == 0 ||
-	    !test_bit(PGDAT_CONGESTED, &pgdat->flags)) {
+	if (atomic_read(&nr_wb_congested[sync]) == 0) {
 		cond_resched();
 
 		/* In case we scheduled, work out time remaining */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1ecc648b6191..e411385b304a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -200,6 +200,29 @@ static bool sane_reclaim(struct scan_control *sc)
 #endif
 	return false;
 }
+
+static void set_memcg_congestion(pg_data_t *pgdat,
+				struct mem_cgroup *memcg,
+				bool congested)
+{
+	struct mem_cgroup_per_node *mn;
+
+	if (!memcg)
+		return;
+
+	mn = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
+	WRITE_ONCE(mn->congested, congested);
+}
+
+static bool memcg_congested(pg_data_t *pgdat,
+			struct mem_cgroup *memcg)
+{
+	struct mem_cgroup_per_node *mn;
+
+	mn = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
+	return READ_ONCE(mn->congested);
+
+}
 #else
 static bool global_reclaim(struct scan_control *sc)
 {
@@ -210,6 +233,18 @@ static bool sane_reclaim(struct scan_control *sc)
 {
 	return true;
 }
+
+static inline void set_memcg_congestion(struct pglist_data *pgdat,
+				struct mem_cgroup *memcg, bool congested)
+{
+}
+
+static inline bool memcg_congested(struct pglist_data *pgdat,
+			struct mem_cgroup *memcg)
+{
+	return false;
+
+}
 #endif
 
 /*
@@ -2474,6 +2509,12 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	return true;
 }
 
+static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
+{
+	return test_bit(PGDAT_CONGESTED, &pgdat->flags) ||
+		(memcg && memcg_congested(pgdat, memcg));
+}
+
 static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
@@ -2556,29 +2597,27 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		if (sc->nr_reclaimed - nr_reclaimed)
 			reclaimable = true;
 
-		/*
-		 * If reclaim is isolating dirty pages under writeback, it
-		 * implies that the long-lived page allocation rate is exceeding
-		 * the page laundering rate. Either the global limits are not
-		 * being effective at throttling processes due to the page
-		 * distribution throughout zones or there is heavy usage of a
-		 * slow backing device. The only option is to throttle from
-		 * reclaim context which is not ideal as there is no guarantee
-		 * the dirtying process is throttled in the same way
-		 * balance_dirty_pages() manages.
-		 *
-		 * Once a node is flagged PGDAT_WRITEBACK, kswapd will count the
-		 * number of pages under pages flagged for immediate reclaim and
-		 * stall if any are encountered in the nr_immediate check below.
-		 */
-		if (sc->nr.writeback && sc->nr.writeback == sc->nr.taken)
-			set_bit(PGDAT_WRITEBACK, &pgdat->flags);
+		if (current_is_kswapd()) {
+			/*
+			 * If reclaim is isolating dirty pages under writeback,
+			 * it implies that the long-lived page allocation rate
+			 * is exceeding the page laundering rate. Either the
+			 * global limits are not being effective at throttling
+			 * processes due to the page distribution throughout
+			 * zones or there is heavy usage of a slow backing
+			 * device. The only option is to throttle from reclaim
+			 * context which is not ideal as there is no guarantee
+			 * the dirtying process is throttled in the same way
+			 * balance_dirty_pages() manages.
+			 *
+			 * Once a node is flagged PGDAT_WRITEBACK, kswapd will
+			 * count the number of pages under pages flagged for
+			 * immediate reclaim and stall if any are encountered
+			 * in the nr_immediate check below.
+			 */
+			if (sc->nr.writeback && sc->nr.writeback == sc->nr.taken)
+				set_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
-		/*
-		 * Legacy memcg will stall in page writeback so avoid forcibly
-		 * stalling here.
-		 */
-		if (sane_reclaim(sc)) {
 			/*
 			 * Tag a node as congested if all the dirty pages
 			 * scanned were backed by a congested BDI and
@@ -2601,6 +2640,14 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 				congestion_wait(BLK_RW_ASYNC, HZ/10);
 		}
 
+		/*
+		 * Legacy memcg will stall in page writeback so avoid forcibly
+		 * stalling in wait_iff_congested().
+		 */
+		if (!global_reclaim(sc) && sane_reclaim(sc) &&
+		    sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
+			set_memcg_congestion(pgdat, root, true);
+
 		/*
 		 * Stall direct reclaim for IO completions if underlying BDIs
 		 * and node is congested. Allow kswapd to continue until it
@@ -2608,8 +2655,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		 * the LRU too quickly.
 		 */
 		if (!sc->hibernation_mode && !current_is_kswapd() &&
-		    current_may_throttle())
-			wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
+		   current_may_throttle() && pgdat_memcg_congested(pgdat, root))
+			wait_iff_congested(BLK_RW_ASYNC, HZ/10);
 
 	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
@@ -2826,6 +2873,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			continue;
 		last_pgdat = zone->zone_pgdat;
 		snapshot_refaults(sc->target_mem_cgroup, zone->zone_pgdat);
+		set_memcg_congestion(last_pgdat, sc->target_mem_cgroup, false);
 	}
 
 	delayacct_freepages_end();
-- 
2.16.1
