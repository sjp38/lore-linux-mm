Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 22A2C6B0036
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 12:06:45 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/9] mm: zone_reclaim: remove ZONE_RECLAIM_LOCKED
Date: Fri,  2 Aug 2013 18:06:28 +0200
Message-Id: <1375459596-30061-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
thread allocates memory at the same time, it forces a premature
allocation into remote NUMA nodes even when there's plenty of clean
cache to reclaim in the local nodes.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mmzone.h | 6 ------
 mm/vmscan.c            | 4 ----
 2 files changed, 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index dcad2ab..1badcc9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -497,7 +497,6 @@ struct zone {
 } ____cacheline_internodealigned_in_smp;
 
 typedef enum {
-	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
 	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
 	ZONE_CONGESTED,			/* zone has many dirty pages backed by
 					 * a congested BDI
@@ -541,11 +540,6 @@ static inline int zone_is_reclaim_writeback(const struct zone *zone)
 	return test_bit(ZONE_WRITEBACK, &zone->flags);
 }
 
-static inline int zone_is_reclaim_locked(const struct zone *zone)
-{
-	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
-}
-
 static inline int zone_is_oom_locked(const struct zone *zone)
 {
 	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 758540d..4b2da9e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3595,11 +3595,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
 		return ZONE_RECLAIM_NOSCAN;
 
-	if (zone_test_and_set_flag(zone, ZONE_RECLAIM_LOCKED))
-		return ZONE_RECLAIM_NOSCAN;
-
 	ret = __zone_reclaim(zone, gfp_mask, order);
-	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
 
 	if (!ret)
 		count_vm_event(PGSCAN_ZONE_RECLAIM_FAILED);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
