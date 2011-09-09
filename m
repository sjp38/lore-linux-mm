Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 79D2C6B0200
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 06:57:42 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/14] mm: Account for the number of times direct reclaimers get throttled
Date: Fri,  9 Sep 2011 11:57:25 +0100
Message-Id: <1315565845-16857-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1315565845-16857-1-git-send-email-mgorman@suse.de>
References: <1315565845-16857-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Under significant pressure when writing back to network-backed storage,
direct reclaimers may get throttled. This is expected to be a
short-lived event and the processes get woken up again but processes do
get stalled. This patch counts how many times such stalling occurs. It's
up to the administrator whether to reduce these stalls by increasing
min_free_kbytes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/vm_event_item.h |    1 +
 mm/vmscan.c                   |    1 +
 mm/vmstat.c                   |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 03b90cdc..652e5f3 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -29,6 +29,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGSTEAL),
 		FOR_ALL_ZONES(PGSCAN_KSWAPD),
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
+		PGSCAN_DIRECT_THROTTLE,
 #ifdef CONFIG_NUMA
 		PGSCAN_ZONE_RECLAIM_FAILED,
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ddf2be0..4ac5a28 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2271,6 +2271,7 @@ static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 		return;
 
 	/* Throttle */
+	count_vm_event(PGSCAN_DIRECT_THROTTLE);
 	wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
 		pfmemalloc_watermark_ok(zone->zone_pgdat, high_zoneidx));
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 20c18b7..0ab4a3d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -740,6 +740,7 @@ const char * const vmstat_text[] = {
 	TEXTS_FOR_ZONES("pgsteal")
 	TEXTS_FOR_ZONES("pgscan_kswapd")
 	TEXTS_FOR_ZONES("pgscan_direct")
+	"pgscan_direct_throttle",
 
 #ifdef CONFIG_NUMA
 	"zone_reclaim_failed",
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
