Date: Wed, 3 Aug 2005 09:39:09 -0400
From: Martin Hicks <mort@bork.org>
Subject: [PATCH] VM: zone reclaim atomic ops cleanup
Message-ID: <20050803133909.GN26803@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: marcelo.tosatti@cyclades.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Hi,

This is a cleanup that was requested by Marcelo and Christoph Lameter.
It is against a recent git tree, but should apply to anything recent.

thanks
mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com



Christoph Lameter and Marcelo Tosatti asked to get rid of the
atomic_inc_and_test() to cleanup the atomic ops in the zone
reclaim code.

Signed-off-by:  Martin Hicks <mort@sgi.com>
Signed-off-by:  Christoph Lameter <clameter@sgi.com>

---
commit 414acb15f0f237cbf560bfa56c74ca9d19c5cd5a
tree 2092de012fbfb1bc93293b90a584220672713c87
parent d7ed538a02c219119adb20f1dccbf0f8015e53f3
author Martin Hicks,,,,,,,engr <mort@tomahawk.engr.sgi.com> Wed, 03 Aug 2005 06:31:13 -0700
committer Martin Hicks,,,,,,,engr <mort@tomahawk.engr.sgi.com> Wed, 03 Aug 2005 06:31:13 -0700

 mm/page_alloc.c |    2 +-
 mm/vmscan.c     |    9 +++++----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1909,7 +1909,7 @@ static void __init free_area_init_core(s
 		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
 		zone->nr_inactive = 0;
-		atomic_set(&zone->reclaim_in_progress, -1);
+		atomic_set(&zone->reclaim_in_progress, 0);
 		if (!size)
 			continue;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -822,6 +822,8 @@ shrink_zone(struct zone *zone, struct sc
 	unsigned long nr_active;
 	unsigned long nr_inactive;
 
+	atomic_inc(&zone->reclaim_in_progress);
+
 	/*
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
 	 * slowly sift through the active list.
@@ -861,6 +863,8 @@ shrink_zone(struct zone *zone, struct sc
 	}
 
 	throttle_vm_writeout();
+
+	atomic_dec(&zone->reclaim_in_progress);
 }
 
 /*
@@ -900,9 +904,7 @@ shrink_caches(struct zone **zones, struc
 		if (zone->all_unreclaimable && sc->priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
 
-		atomic_inc(&zone->reclaim_in_progress);
 		shrink_zone(zone, sc);
-		atomic_dec(&zone->reclaim_in_progress);
 	}
 }
  
@@ -1358,14 +1360,13 @@ int zone_reclaim(struct zone *zone, unsi
 		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
 
 	/* Don't reclaim the zone if there are other reclaimers active */
-	if (!atomic_inc_and_test(&zone->reclaim_in_progress))
+	if (atomic_read(&zone->reclaim_in_progress) > 0)
 		goto out;
 
 	shrink_zone(zone, &sc);
 	total_reclaimed = sc.nr_reclaimed;
 
  out:
-	atomic_dec(&zone->reclaim_in_progress);
 	return total_reclaimed;
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
