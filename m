Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 56CC26B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:35:11 -0400 (EDT)
Date: Thu, 16 Jul 2009 21:34:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] mm: count only reclaimable lru pages
Message-ID: <20090716133454.GA20550@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

global_lru_pages() / zone_lru_pages() can be used in two ways:
- to estimate max reclaimable pages in determine_dirtyable_memory()  
- to calculate the slab scan ratio

When swap is full or not present, the anon lru lists are not reclaimable
and thus won't be scanned. So the anon pages shall not be counted. Also
rename the function names to reflect the new meaning.

It can greatly (and correctly) increase the slab scan rate under high memory
pressure (when most file pages have been reclaimed and swap is full/absent),
thus avoid possible false OOM kills.

Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/vmstat.h |   11 +--------
 mm/page-writeback.c    |    5 ++--
 mm/vmscan.c            |   44 +++++++++++++++++++++++++++++----------
 3 files changed, 38 insertions(+), 22 deletions(-)

--- linux.orig/include/linux/vmstat.h
+++ linux/include/linux/vmstat.h
@@ -166,15 +166,8 @@ static inline unsigned long zone_page_st
 	return x;
 }
 
-extern unsigned long global_lru_pages(void);
-
-static inline unsigned long zone_lru_pages(struct zone *zone)
-{
-	return (zone_page_state(zone, NR_ACTIVE_ANON)
-		+ zone_page_state(zone, NR_ACTIVE_FILE)
-		+ zone_page_state(zone, NR_INACTIVE_ANON)
-		+ zone_page_state(zone, NR_INACTIVE_FILE));
-}
+extern unsigned long global_reclaimable_pages(void);
+extern unsigned long zone_reclaimable_pages(struct zone *zone);
 
 #ifdef CONFIG_NUMA
 /*
--- linux.orig/mm/page-writeback.c
+++ linux/mm/page-writeback.c
@@ -380,7 +380,8 @@ static unsigned long highmem_dirtyable_m
 		struct zone *z =
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
-		x += zone_page_state(z, NR_FREE_PAGES) + zone_lru_pages(z);
+		x += zone_page_state(z, NR_FREE_PAGES) +
+		     zone_reclaimable_pages(z);
 	}
 	/*
 	 * Make sure that the number of highmem pages is never larger
@@ -404,7 +405,7 @@ unsigned long determine_dirtyable_memory
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES) + global_lru_pages();
+	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -1735,7 +1735,7 @@ static unsigned long do_try_to_free_page
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
 
-			lru_pages += zone_lru_pages(zone);
+			lru_pages += zone_reclaimable_pages(zone);
 		}
 	}
 
@@ -1952,7 +1952,7 @@ loop_again:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 
-			lru_pages += zone_lru_pages(zone);
+			lru_pages += zone_reclaimable_pages(zone);
 		}
 
 		/*
@@ -1996,7 +1996,7 @@ loop_again:
 			if (zone_is_all_unreclaimable(zone))
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
-						(zone_lru_pages(zone) * 6))
+					(zone_reclaimable_pages(zone) * 6))
 					zone_set_flag(zone,
 						      ZONE_ALL_UNRECLAIMABLE);
 			/*
@@ -2163,12 +2163,33 @@ void wakeup_kswapd(struct zone *zone, in
 	wake_up_interruptible(&pgdat->kswapd_wait);
 }
 
-unsigned long global_lru_pages(void)
+unsigned long global_reclaimable_pages(void)
 {
-	return global_page_state(NR_ACTIVE_ANON)
-		+ global_page_state(NR_ACTIVE_FILE)
-		+ global_page_state(NR_INACTIVE_ANON)
-		+ global_page_state(NR_INACTIVE_FILE);
+	int nr;
+
+	nr = global_page_state(NR_ACTIVE_FILE) +
+	     global_page_state(NR_INACTIVE_FILE);
+
+	if (nr_swap_pages > 0)
+		nr += global_page_state(NR_ACTIVE_ANON) +
+		      global_page_state(NR_INACTIVE_ANON);
+
+	return nr;
+}
+
+
+unsigned long zone_reclaimable_pages(struct zone *zone)
+{
+	int nr;
+
+	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
+	     zone_page_state(zone, NR_INACTIVE_FILE);
+
+	if (nr_swap_pages > 0)
+		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
+		      zone_page_state(zone, NR_INACTIVE_ANON);
+
+	return nr;
 }
 
 #ifdef CONFIG_HIBERNATION
@@ -2240,7 +2261,7 @@ unsigned long shrink_all_memory(unsigned
 
 	current->reclaim_state = &reclaim_state;
 
-	lru_pages = global_lru_pages();
+	lru_pages = global_reclaimable_pages();
 	nr_slab = global_page_state(NR_SLAB_RECLAIMABLE);
 	/* If slab caches are huge, it's better to hit them first */
 	while (nr_slab >= lru_pages) {
@@ -2282,7 +2303,7 @@ unsigned long shrink_all_memory(unsigned
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
-					global_lru_pages());
+				    global_reclaimable_pages());
 			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
 			if (sc.nr_reclaimed >= nr_pages)
 				goto out;
@@ -2299,7 +2320,8 @@ unsigned long shrink_all_memory(unsigned
 	if (!sc.nr_reclaimed) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
-			shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
+			shrink_slab(nr_pages, sc.gfp_mask,
+				    global_reclaimable_pages());
 			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
 		} while (sc.nr_reclaimed < nr_pages &&
 				reclaim_state.reclaimed_slab > 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
