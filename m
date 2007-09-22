Date: Sat, 22 Sep 2007 10:47:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 4/5] mm: test and set zone reclaim lock before starting
 reclaim
In-Reply-To: <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Introduces new zone flag interface for testing and setting flags:

	int zone_test_and_set_flag(struct zone *zone, zone_flags_t flag)

Instead of setting and clearing ZONE_RECLAIM_LOCKED each time
shrink_zone() is called, this flag is test and set before starting zone
reclaim.  Zone reclaim starts in __alloc_pages() when a zone's watermark
fails and the system is in zone_reclaim_mode.  If it's already in
reclaim, there's no need to start again so it is simply considered full
for that allocation attempt.

There is a change of behavior with regard to concurrent zone shrinking.
It is now possible for try_to_free_pages() or kswapd to already be
shrinking a particular zone when __alloc_pages() starts zone reclaim.  In
this case, it is possible for two concurrent threads to invoke
shrink_zone() for a single zone.

This change forbids a zone to be in zone reclaim twice, which was always
the behavior, but allows for concurrent try_to_free_pages() or kswapd
shrinking when starting zone reclaim.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mmzone.h |    4 ++++
 mm/vmscan.c            |   23 +++++++++++++----------
 2 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -320,6 +320,10 @@ static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
 {
 	set_bit(flag, &zone->flags);
 }
+static inline int zone_test_and_set_flag(struct zone *zone, zone_flags_t flag)
+{
+	return test_and_set_bit(flag, &zone->flags);
+}
 static inline void zone_clear_flag(struct zone *zone, zone_flags_t flag)
 {
 	clear_bit(flag, &zone->flags);
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1067,8 +1067,6 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
 
-	zone_set_flag(zone, ZONE_RECLAIM_LOCKED);
-
 	/*
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
 	 * slowly sift through the active list.
@@ -1107,8 +1105,6 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
 	}
 
 	throttle_vm_writeout(sc->gfp_mask);
-
-	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
 	return nr_reclaimed;
 }
 
@@ -1852,6 +1848,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 {
 	cpumask_t mask;
 	int node_id;
+	int ret;
 
 	/*
 	 * Zone reclaim reclaims unmapped file backed pages and
@@ -1869,13 +1866,13 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 			<= zone->min_slab_pages)
 		return 0;
 
+	if (zone_is_all_unreclaimable(zone))
+		return 0;
+
 	/*
-	 * Avoid concurrent zone reclaims, do not reclaim in a zone that does
-	 * not have reclaimable pages and if we should not delay the allocation
-	 * then do not scan.
+	 * Do not scan if the allocation should not be delayed.
 	 */
-	if (!(gfp_mask & __GFP_WAIT) || zone_is_all_unreclaimable(zone) ||
-		zone_is_reclaim_locked(zone) || (current->flags & PF_MEMALLOC))
+	if (!(gfp_mask & __GFP_WAIT) || (current->flags & PF_MEMALLOC))
 			return 0;
 
 	/*
@@ -1888,6 +1885,12 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	mask = node_to_cpumask(node_id);
 	if (!cpus_empty(mask) && node_id != numa_node_id())
 		return 0;
-	return __zone_reclaim(zone, gfp_mask, order);
+
+	if (zone_test_and_set_flag(zone, ZONE_RECLAIM_LOCKED))
+		return 0;
+	ret = __zone_reclaim(zone, gfp_mask, order);
+	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
+
+	return ret;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
