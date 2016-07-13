Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 938156B0260
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 22:23:01 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u142so50414778oia.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 19:23:01 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a199si14480206ita.105.2016.07.12.19.23.00
        for <linux-mm@kvack.org>;
        Tue, 12 Jul 2016 19:23:01 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: fix pgalloc_stall on unpopulated zone
Date: Wed, 13 Jul 2016 11:24:13 +0900
Message-Id: <1468376653-26561-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

If we use sc->reclaim_idx for accounting pgstall, it can increase
the count on unpopulated zone, for example, movable zone(but
my system doesn't have movable zone) if allocation request were
GFP_HIGHUSER_MOVABLE. It doesn't make no sense.

This patch fixes it so that it can account it on first populated
zone at or below highest_zoneidx of the request.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/buffer.c          | 2 +-
 include/linux/swap.h | 3 ++-
 mm/page_alloc.c      | 3 ++-
 mm/vmscan.c          | 5 +++--
 4 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 46b3568..69841f4 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -268,7 +268,7 @@ static void free_more_memory(void)
 						gfp_zone(GFP_NOFS), NULL);
 		if (z->zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
-						GFP_NOFS, NULL);
+					GFP_NOFS, NULL, gfp_zone(GFP_NOFS));
 	}
 }
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index cc753c6..935f7e1 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -309,7 +309,8 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 /* linux/mm/vmscan.c */
 extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-					gfp_t gfp_mask, nodemask_t *mask);
+					gfp_t gfp_mask, nodemask_t *mask,
+					enum zone_type classzone_idx);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 						  unsigned long nr_pages,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 80c9b9a..5f20d4b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3305,7 +3305,8 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 	current->reclaim_state = &reclaim_state;
 
 	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
-								ac->nodemask);
+				ac->nodemask,
+				zonelist_zone_idx(ac->preferred_zoneref));
 
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c538a8c..1f91e2e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2855,13 +2855,14 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 }
 
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-				gfp_t gfp_mask, nodemask_t *nodemask)
+				gfp_t gfp_mask, nodemask_t *nodemask,
+				enum zone_type classzone_idx)
 {
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
-		.reclaim_idx = gfp_zone(gfp_mask),
+		.reclaim_idx = classzone_idx,
 		.order = order,
 		.nodemask = nodemask,
 		.priority = DEF_PRIORITY,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
