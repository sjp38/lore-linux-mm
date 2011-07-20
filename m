Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 01D246B004A
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 22:53:37 -0400 (EDT)
Subject: [PATCH]vmscan: add block plug for page reclaim
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jul 2011 10:53:33 +0800
Message-ID: <1311130413.15392.326.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <jaxboe@fusionio.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

per-task block plug can reduce block queue lock contention and increase request
merge. Currently page reclaim doesn't support it. I originally thought page
reclaim doesn't need it, because kswapd thread count is limited and file cache
write is done at flusher mostly.
When I test a workload with heavy swap in a 4-node machine, each CPU is doing
direct page reclaim and swap. This causes block queue lock contention. In my
test, without below patch, the CPU utilization is about 2% ~ 7%. With the
patch, the CPU utilization is about 1% ~ 3%. Disk throughput isn't changed.
This should improve normal kswapd write and file cache write too (increase
request merge for example), but might not be so obvious as I explain above.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5ed24b9..8ec04b2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1933,12 +1933,14 @@ static void shrink_zone(int priority, struct zone *zone,
 	enum lru_list l;
 	unsigned long nr_reclaimed, nr_scanned;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
+	struct blk_plug plug;
 
 restart:
 	nr_reclaimed = 0;
 	nr_scanned = sc->nr_scanned;
 	get_scan_count(zone, sc, nr, priority);
 
+	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {
@@ -1962,6 +1964,7 @@ restart:
 		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
 			break;
 	}
+	blk_finish_plug(&plug);
 	sc->nr_reclaimed += nr_reclaimed;
 
 	/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
