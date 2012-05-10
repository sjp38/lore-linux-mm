Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 5702B6B00E9
	for <linux-mm@kvack.org>; Thu, 10 May 2012 09:45:36 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/17] mm: Account for the number of times direct reclaimers get throttled
Date: Thu, 10 May 2012 14:45:10 +0100
Message-Id: <1336657510-24378-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1336657510-24378-1-git-send-email-mgorman@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

Under significant pressure when writing back to network-backed storage,
direct reclaimers may get throttled. This is expected to be a
short-lived event and the processes get woken up again but processes do
get stalled. This patch counts how many times such stalling occurs. It's
up to the administrator whether to reduce these stalls by increasing
min_free_kbytes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/vm_event_item.h |    1 +
 mm/vmscan.c                   |    3 +++
 mm/vmstat.c                   |    1 +
 3 files changed, 5 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 06f8e38..57f7b10 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -30,6 +30,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGSTEAL_DIRECT),
 		FOR_ALL_ZONES(PGSCAN_KSWAPD),
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
+		PGSCAN_DIRECT_THROTTLE,
 #ifdef CONFIG_NUMA
 		PGSCAN_ZONE_RECLAIM_FAILED,
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 97c766f..141ab5c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2486,6 +2486,9 @@ static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 	if (pfmemalloc_watermark_ok(pgdat))
 		return;
 
+	/* Account for the throttling */
+	count_vm_event(PGSCAN_DIRECT_THROTTLE);
+
 	/*
 	 * If the caller cannot enter the filesystem, it's possible that it
 	 * is due to the caller holding an FS lock or performing a journal
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7db1b9b..7861cbe 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -742,6 +742,7 @@ const char * const vmstat_text[] = {
 	TEXTS_FOR_ZONES("pgsteal_direct")
 	TEXTS_FOR_ZONES("pgscan_kswapd")
 	TEXTS_FOR_ZONES("pgscan_direct")
+	"pgscan_direct_throttle",
 
 #ifdef CONFIG_NUMA
 	"zone_reclaim_failed",
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
