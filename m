Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 846036B0071
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 03:15:02 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 5/5] vmscan: accelerate to reclaim mapped-pages stream
Date: Wed, 22 Aug 2012 16:15:17 +0900
Message-Id: <1345619717-5322-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1345619717-5322-1-git-send-email-minchan@kernel.org>
References: <1345619717-5322-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

Normally, mmapped data pages has a chance to stay around in LRU
one more rather than others because they were bon with referecend
pte so we can keep workingset mapped page in memory.

But it can have a problem when there are a ton of mmaped page stream.
VM should burn out CPU for rotating them in LRU so that kswapd's
efficiency would drop so that processes start to enter direct reclaim
path. It's not desirable.

This patch try to detect mmaped pages stream.
If VM see above 80%'s mmaped pages in a reclaim chunk(32),
he consider it as mmaped-pages stream's symptom and monitor
consecutive reclaim chunk. If VM find 1M mmapped pages during
consecutive reclaim, he concludes it as mmaped pages stream and
start to reclaim them without rotation.
If VM see below 80%'s mmaped pages in a reclaim chunck during
consecutive reclaim, it back off instantly

==DRIVER                      mapped-file-stream            mapped-file-stream(0.00,    -nan%)
Name                          mapped-file-stream            mapped-file-stream(0.00,    -nan%)
Elapsed                       665                           615       (-50.00,  -7.52%)
nr_vmscan_write               849                           62        (-787.00, -92.70%)
nr_vmscan_immediate_reclaim   8                             5         (-3.00,   -37.50%)
pgpgin                        30280                         27096     (-3184.00,-10.52%)
pgpgout                       6396                          2680      (-3716.00,-58.10%)
pswpin                        8                             0         (-8.00,   -100.00%)
pswpout                       849                           18        (-831.00, -97.88%)
pgactivate                    15959                         15585     (-374.00, -2.34%)
pgdeactivate                  15303                         13896     (-1407.00,-9.19%)
pgfault                       204524410                     204524092 (-318.00, -0.00%)
pgmajfault                    204472602                     204472572 (-30.00,  -0.00%)
pgsteal_kswapd_dma            475265                        892600    (417335.00,87.81%)
pgsteal_kswapd_normal         51289479                      44560409  (-6729070.00,-13.12%)
pgsteal_kswapd_high           135817904                     142316673 (6498769.00,4.78%)
pgsteal_kswapd_movable        4380123                       4793399   (413276.00,9.44%)
pgsteal_direct_dma            11910                         0         (-11910.00,-100.00%)
pgsteal_direct_normal         165012                        1322      (-163690.00,-99.20%)
pgsteal_direct_high           309271                        40        (-309231.00,-99.99%)
pgsteal_direct_movable        45638                         0         (-45638.00,-100.00%)
pgscan_kswapd_dma             972089                        893162    (-78927.00,-8.12%)
pgscan_kswapd_normal          100850050                     44609130  (-56240920.00,-55.77%)
pgscan_kswapd_high            269039236                     142394025 (-126645211.00,-47.07%)
pgscan_kswapd_movable         8774392                       4798082   (-3976310.00,-45.32%)
pgscan_direct_dma             26410                         0         (-26410.00,-100.00%)
pgscan_direct_normal          4186439                       1322      (-4185117.00,-99.97%)
pgscan_direct_high            5132110                       1161      (-5130949.00,-99.98%)
pgscan_direct_movable         122790                        0         (-122790.00,-100.00%)
pgscan_direct_throttle        0                             0         (0.00,    0.00%)
pginodesteal                  6836                          0         (-6836.00,-100.00%)
slabs_scanned                 56320                         52224     (-4096.00,-7.27%)
kswapd_inodesteal             35904                         41679     (5775.00, 16.08%)
kswapd_low_wmark_hit_quickly  5193                          7587      (2394.00, 46.10%)
kswapd_high_wmark_hit_quickly 421                           463       (42.00,   9.98%)
kswapd_skip_congestion_wait   12375                         23        (-12352.00,-99.81%)
pageoutrun                    3071912                       3202200   (130288.00,4.24%)
allocstall                    9727                          32        (-9695.00,-99.67%)
pgrotated                     850                           18        (-832.00, -97.88%)
kswapd_totalscan              379635767                     192694399 (-186941368.00,-49.24%)
kswapd_totalsteal             191962771                     192563081 (600310.00,0.31%)
Kswapd_efficiency             50.00                         99.00     (49.00,   98.00%)
direct_totalscan              9467749                       2483      (-9465266.00,-99.97%)
direct_totalsteal             531831                        1362      (-530469.00,-99.74%)
direct_efficiency             5.00                          54.00     (49.00,   980.00%)
reclaim_velocity              585118.06                     313328.26 (-271789.80,-46.45%)

Elapsed time of test program is 50 second. Of course,
the number of scanning is decreased hugely so efficiency of
kswapd/direct reclaim is super enhanced.
I think this patch can help very much on mmapped-file stream
while it doesn't have a problem on other workload due to instant
backoff.

Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mmzone.h |   23 +++++++++++++++++++++++
 mm/vmscan.c            |   24 ++++++++++++++++++++++--
 2 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2daa54f..190376e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -325,6 +325,28 @@ enum zone_type {
 #error ZONES_SHIFT -- too many zones configured adjust calculation
 #endif
 
+/*
+ * VM try to detect mp(mapped-pages) stream so it could be reclaimed
+ * without rotation. It reduces CPU burning and enhances kswapd
+ * efficiency.
+ */
+struct mp_detector {
+	bool force_reclaim;
+	int stream_detect_shift;
+};
+
+/*
+ * If we detect SWAP_CLUSTER_MAX * MP_DETECT_MAX_SHIFT(ie, 1M)
+ * mapped-pages during consecutive reclaim, we consider it as
+ * mapped-pages stream.
+ */
+#define MP_DETECT_MAX_SHIFT	8	/* 1 is SWAP_CLUSTER_MAX pages */
+/*
+ * If above 80% is mapped pages in a reclaim chunk, we consider it as
+ * mapped-pages stream's symptom.
+ */
+#define MP_STREAM_RATIO		(4 / 5)
+
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 
@@ -422,6 +444,7 @@ struct zone {
 	 */
 	unsigned int inactive_ratio;
 
+	struct mp_detector mp;
 
 	ZONE_PADDING(_pad2_)
 	/* Rarely used or read-mostly fields */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1a66680..e215e98 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -674,12 +674,14 @@ static enum page_references page_check_references(struct page *page,
 static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
 				      struct scan_control *sc,
+				      unsigned long *ret_nr_referenced_ptes,
 				      unsigned long *ret_nr_writeback)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
 	unsigned long nr_dirty = 0;
+	unsigned long nr_referenced_ptes = 0;
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
@@ -762,12 +764,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
 		case PAGEREF_KEEP:
+			nr_referenced_ptes++;
+			if (zone->mp.force_reclaim)
+				goto free_mapped_page;
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
 			; /* try to reclaim the page below */
 		}
-
+free_mapped_page:
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
@@ -954,6 +959,7 @@ keep:
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
 	mem_cgroup_uncharge_end();
+	*ret_nr_referenced_ptes = nr_referenced_ptes;
 	*ret_nr_writeback += nr_writeback;
 	return nr_reclaimed;
 }
@@ -1234,6 +1240,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
+	unsigned long nr_referenced_ptes = 0;
 	unsigned long nr_writeback = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
@@ -1275,7 +1282,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (nr_taken == 0)
 		return 0;
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, &nr_writeback);
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
+				&nr_referenced_ptes, &nr_writeback);
 
 	spin_lock_irq(&zone->lru_lock);
 
@@ -1325,6 +1333,18 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 			(nr_taken >> (DEF_PRIORITY - sc->priority)))
 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
 
+
+	if (nr_referenced_ptes >= (nr_taken * MP_STREAM_RATIO)) {
+		int shift = zone->mp.stream_detect_shift;
+		shift = min(++shift, MP_DETECT_MAX_SHIFT);
+		if (shift == MP_DETECT_MAX_SHIFT)
+			zone->mp.force_reclaim = true;
+		zone->mp.stream_detect_shift = shift;
+	} else {
+		zone->mp.stream_detect_shift = 0;
+		zone->mp.force_reclaim = false;
+	}
+
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
 		nr_scanned, nr_reclaimed,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
