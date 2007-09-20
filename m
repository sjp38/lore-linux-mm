Date: Thu, 20 Sep 2007 13:23:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/9] oom: change all_unreclaimable zone member to flags
In-Reply-To: <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Convert the int all_unreclaimable member of struct zone to
unsigned long flags.  This can now be used to specify several different
zone flags such as all_unreclaimable and reclaim_in_progress, which can
now be removed and converted to a per-zone flag.

Flags are set and cleared as follows:

	zone_set_flag(struct zone *zone, zone_flags_t flag)
	zone_clear_flag(struct zone *zone, zone_flags_t flag)

Defines the first zone flags, ZONE_ALL_UNRECLAIMABLE and
ZONE_RECLAIM_LOCKED, which have the same semantics as the old
zone->all_unreclaimable and zone->reclaim_in_progress, respectively.  Also
converts all current users that set or clear either flag to use the new
interface.

Helper functions are defined to test the flags:

	int zone_is_all_unreclaimable(const struct zone *zone)
	int zone_is_reclaim_locked(const struct zone *zone)

All flag operators are of the atomic variety because there are currently
readers that are implemented that do not take zone->lock.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mmzone.h |   28 ++++++++++++++++++++++++----
 mm/page_alloc.c        |    8 ++++----
 mm/vmscan.c            |   25 +++++++++++++------------
 mm/vmstat.c            |    2 +-
 4 files changed, 42 insertions(+), 21 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -232,10 +232,7 @@ struct zone {
 	unsigned long		nr_scan_active;
 	unsigned long		nr_scan_inactive;
 	unsigned long		pages_scanned;	   /* since last reclaim */
-	int			all_unreclaimable; /* All pages pinned */
-
-	/* A count of how many reclaimers are scanning this zone */
-	atomic_t		reclaim_in_progress;
+	unsigned long		flags;		   /* zone flags, see below */
 
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
@@ -313,6 +310,29 @@ struct zone {
 	const char		*name;
 } ____cacheline_internodealigned_in_smp;
 
+typedef enum {
+	ZONE_ALL_UNRECLAIMABLE,		/* all pages pinned */
+	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
+} zone_flags_t;
+
+static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
+{
+	set_bit(flag, &zone->flags);
+}
+static inline void zone_clear_flag(struct zone *zone, zone_flags_t flag)
+{
+	clear_bit(flag, &zone->flags);
+}
+
+static inline int zone_is_all_unreclaimable(const struct zone *zone)
+{
+	return test_bit(ZONE_ALL_UNRECLAIMABLE, &zone->flags);
+}
+static inline int zone_is_reclaim_locked(const struct zone *zone)
+{
+	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
+}
+
 /*
  * The "priority" of VM scanning is how much of the queues we will scan in one
  * go. A value of 12 for DEF_PRIORITY implies that we will scan 1/4096th of the
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -479,7 +479,7 @@ static void free_pages_bulk(struct zone *zone, int count,
 					struct list_head *list, int order)
 {
 	spin_lock(&zone->lock);
-	zone->all_unreclaimable = 0;
+	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
 	while (count--) {
 		struct page *page;
@@ -496,7 +496,7 @@ static void free_pages_bulk(struct zone *zone, int count,
 static void free_one_page(struct zone *zone, struct page *page, int order)
 {
 	spin_lock(&zone->lock);
-	zone->all_unreclaimable = 0;
+	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
 	__free_one_page(page, zone, order);
 	spin_unlock(&zone->lock);
@@ -1617,7 +1617,7 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_INACTIVE)),
 			K(zone->present_pages),
 			zone->pages_scanned,
-			(zone->all_unreclaimable ? "yes" : "no")
+			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
 			);
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
@@ -2978,7 +2978,7 @@ static void __meminit free_area_init_core(struct pglist_data *pgdat,
 		zone->nr_scan_active = 0;
 		zone->nr_scan_inactive = 0;
 		zap_zone_vm_stats(zone);
-		atomic_set(&zone->reclaim_in_progress, 0);
+		zone->flags = 0;
 		if (!size)
 			continue;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1067,7 +1067,7 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
 
-	atomic_inc(&zone->reclaim_in_progress);
+	zone_set_flag(zone, ZONE_RECLAIM_LOCKED);
 
 	/*
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
@@ -1108,7 +1108,7 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
 
 	throttle_vm_writeout(sc->gfp_mask);
 
-	atomic_dec(&zone->reclaim_in_progress);
+	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
 	return nr_reclaimed;
 }
 
@@ -1146,7 +1146,7 @@ static unsigned long shrink_zones(int priority, struct zone **zones,
 
 		note_zone_scanning_priority(zone, priority);
 
-		if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+		if (zone_is_all_unreclaimable(zone) && priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
 
 		sc->all_unreclaimable = 0;
@@ -1327,7 +1327,8 @@ loop_again:
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			if (zone_is_all_unreclaimable(zone) &&
+			    priority != DEF_PRIORITY)
 				continue;
 
 			if (!zone_watermark_ok(zone, order, zone->pages_high,
@@ -1362,7 +1363,8 @@ loop_again:
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			if (zone_is_all_unreclaimable(zone) &&
+			    priority != DEF_PRIORITY)
 				continue;
 
 			if (!zone_watermark_ok(zone, order, zone->pages_high,
@@ -1377,12 +1379,13 @@ loop_again:
 						lru_pages);
 			nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
-			if (zone->all_unreclaimable)
+			if (zone_is_all_unreclaimable(zone))
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
 				(zone_page_state(zone, NR_ACTIVE)
 				+ zone_page_state(zone, NR_INACTIVE)) * 6)
-					zone->all_unreclaimable = 1;
+					zone_set_flag(zone,
+						      ZONE_ALL_UNRECLAIMABLE);
 			/*
 			 * If we've done a decent amount of scanning and
 			 * the reclaim ratio is low, start doing writepage
@@ -1548,7 +1551,7 @@ static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
 		if (!populated_zone(zone))
 			continue;
 
-		if (zone->all_unreclaimable && prio != DEF_PRIORITY)
+		if (zone_is_all_unreclaimable(zone) && prio != DEF_PRIORITY)
 			continue;
 
 		/* For pass = 0 we don't shrink the active list */
@@ -1871,10 +1874,8 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 * not have reclaimable pages and if we should not delay the allocation
 	 * then do not scan.
 	 */
-	if (!(gfp_mask & __GFP_WAIT) ||
-		zone->all_unreclaimable ||
-		atomic_read(&zone->reclaim_in_progress) > 0 ||
-		(current->flags & PF_MEMALLOC))
+	if (!(gfp_mask & __GFP_WAIT) || zone_is_all_unreclaimable(zone) ||
+		zone_is_reclaim_locked(zone) || (current->flags & PF_MEMALLOC))
 			return 0;
 
 	/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -604,7 +604,7 @@ static int zoneinfo_show(struct seq_file *m, void *arg)
 			   "\n  all_unreclaimable: %u"
 			   "\n  prev_priority:     %i"
 			   "\n  start_pfn:         %lu",
-			   zone->all_unreclaimable,
+			   zone_is_all_unreclaimable(zone),
 			   zone->prev_priority,
 			   zone->zone_start_pfn);
 		spin_unlock_irqrestore(&zone->lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
