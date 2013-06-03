Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id C6E696B0031
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 15:33:10 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v10 12/35] shrinker: add node awareness
Date: Mon,  3 Jun 2013 23:29:41 +0400
Message-Id: <1370287804-3481-13-git-send-email-glommer@openvz.org>
In-Reply-To: <1370287804-3481-1-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>

From: Dave Chinner <dchinner@redhat.com>

Pass the node of the current zone being reclaimed to shrink_slab(),
allowing the shrinker control nodemask to be set appropriately for
node aware shrinkers.

[ v3: update ashmem ]
Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 drivers/staging/android/ashmem.c |  3 +++
 fs/drop_caches.c                 |  1 +
 include/linux/shrinker.h         |  3 +++
 mm/memory-failure.c              |  2 ++
 mm/vmscan.c                      | 11 ++++++++---
 5 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 21a3f72..65f36d7 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -692,6 +692,9 @@ static long ashmem_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 				.gfp_mask = GFP_KERNEL,
 				.nr_to_scan = 0,
 			};
+
+			nodes_setall(sc.nodes_to_scan);
+
 			ret = ashmem_shrink(&ashmem_shrinker, &sc);
 			sc.nr_to_scan = ret;
 			ashmem_shrink(&ashmem_shrinker, &sc);
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index f23d2a7..c3f44e7 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -44,6 +44,7 @@ static void drop_slab(void)
 		.gfp_mask = GFP_KERNEL,
 	};
 
+	nodes_setall(shrink.nodes_to_scan);
 	do {
 		nr_objects = shrink_slab(&shrink, 1000, 1000);
 	} while (nr_objects > 10);
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index c277b4e..98be3ab 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -16,6 +16,9 @@ struct shrink_control {
 
 	/* How many slab objects shrinker() should scan and try to reclaim */
 	long nr_to_scan;
+
+	/* shrink from these nodes */
+	nodemask_t nodes_to_scan;
 };
 
 /*
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ceb0c7f..86788ff 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -248,10 +248,12 @@ void shake_page(struct page *p, int access)
 	 */
 	if (access) {
 		int nr;
+		int nid = page_to_nid(p);
 		do {
 			struct shrink_control shrink = {
 				.gfp_mask = GFP_KERNEL,
 			};
+			node_set(nid, shrink.nodes_to_scan);
 
 			nr = shrink_slab(&shrink, 1000, 1000);
 			if (page_count(p) == 1)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6ac3ec2..53e647f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2296,12 +2296,16 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 */
 		if (global_reclaim(sc)) {
 			unsigned long lru_pages = 0;
+
+			nodes_clear(shrink->nodes_to_scan);
 			for_each_zone_zonelist(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask)) {
 				if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 					continue;
 
 				lru_pages += zone_reclaimable_pages(zone);
+				node_set(zone_to_nid(zone),
+					 shrink->nodes_to_scan);
 			}
 
 			shrink_slab(shrink, sc->nr_scanned, lru_pages);
@@ -2769,6 +2773,8 @@ static bool kswapd_shrink_zone(struct zone *zone,
 		return true;
 
 	shrink_zone(zone, sc);
+	nodes_clear(shrink.nodes_to_scan);
+	node_set(zone_to_nid(zone), shrink.nodes_to_scan);
 
 	reclaim_state->reclaimed_slab = 0;
 	nr_slab = shrink_slab(&shrink, sc->nr_scanned, lru_pages);
@@ -3477,10 +3483,9 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * number of slab pages and shake the slab until it is reduced
 		 * by the same nr_pages that we used for reclaiming unmapped
 		 * pages.
-		 *
-		 * Note that shrink_slab will free memory on all zones and may
-		 * take a long time.
 		 */
+		nodes_clear(shrink.nodes_to_scan);
+		node_set(zone_to_nid(zone), shrink.nodes_to_scan);
 		for (;;) {
 			unsigned long lru_pages = zone_reclaimable_pages(zone);
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
