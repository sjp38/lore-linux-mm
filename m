Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEC19003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 08:04:49 -0400 (EDT)
Received: by labow3 with SMTP id ow3so14973292lab.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 05:04:49 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id o2si11759521lah.162.2015.08.03.05.04.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 05:04:47 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 2/3] mm: make workingset detection logic memcg aware
Date: Mon, 3 Aug 2015 15:04:22 +0300
Message-ID: <9662034e14549b9e1445684f674063ce8b092cb0.1438599199.git.vdavydov@parallels.com>
In-Reply-To: <cover.1438599199.git.vdavydov@parallels.com>
References: <cover.1438599199.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, inactive_age is maintained per zone, which makes file page
activations pretty random in case memory cgroups are used. This patch
moves inactive_age to lruvec and makes all workingset detection related
functions use mem_cgroup_page_lruvec() to get the actual inactive_age.

Note, we do not make pack_shadow() store info about the memory cgroup
the evicted page belonged to in a shadow entry. Instead, on refault, we
simply use the memory cgroup the refaulted page belongs to. Since page
migration between different memory cgroups is a rather rare event, this
should be acceptable.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/mmzone.h |  7 ++++---
 include/linux/swap.h   |  2 +-
 mm/filemap.c           |  2 +-
 mm/internal.h          |  1 +
 mm/vmscan.c            |  2 +-
 mm/workingset.c        | 25 ++++++++++++++++---------
 6 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ac00e2050943..cc7ec7546371 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -216,6 +216,10 @@ struct zone_reclaim_stat {
 struct lruvec {
 	struct list_head lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat reclaim_stat;
+
+	/* Evictions & activations on the inactive file list */
+	atomic_long_t		inactive_age;
+
 #ifdef CONFIG_MEMCG
 	struct zone *zone;
 #endif
@@ -491,9 +495,6 @@ struct zone {
 	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
-	/* Evictions & activations on the inactive file list */
-	atomic_long_t		inactive_age;
-
 	/*
 	 * When free pages are below this point, additional steps are taken
 	 * when reading the number of free pages to avoid per-cpu counter
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 9c7c4b418498..b7070f49aff2 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -250,7 +250,7 @@ struct swap_info_struct {
 
 /* linux/mm/workingset.c */
 void *workingset_eviction(struct address_space *mapping, struct page *page);
-bool workingset_refault(void *shadow);
+bool workingset_refault(void *shadow, struct page *page);
 void workingset_activation(struct page *page);
 extern struct list_lru workingset_shadow_nodes;
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 204fd1c7c813..f72ee2e4ec0d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -652,7 +652,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 		 * recently, in which case it should be activated like
 		 * any other repeatedly accessed page.
 		 */
-		if (shadow && workingset_refault(shadow)) {
+		if (shadow && workingset_refault(shadow, page)) {
 			SetPageActive(page);
 			workingset_activation(page);
 		} else
diff --git a/mm/internal.h b/mm/internal.h
index 1195dd2d6a2b..ec3863d1c62a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -99,6 +99,7 @@ extern unsigned long highest_memmap_pfn;
 extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
 extern bool zone_reclaimable(struct zone *zone);
+extern unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru);
 
 /*
  * in mm/rmap.c:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8b405277d2fc..5221e19e98f4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -213,7 +213,7 @@ bool zone_reclaimable(struct zone *zone)
 		zone_reclaimable_pages(zone) * 6;
 }
 
-static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
+unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 {
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_get_lru_size(lruvec, lru);
diff --git a/mm/workingset.c b/mm/workingset.c
index aa017133744b..76bf9b6ee88c 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -12,6 +12,7 @@
 #include <linux/swap.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include "internal.h"
 
 /*
  *		Double CLOCK lists
@@ -142,7 +143,7 @@
  *		Implementation
  *
  * For each zone's file LRU lists, a counter for inactive evictions
- * and activations is maintained (zone->inactive_age).
+ * and activations is maintained (lruvec->inactive_age).
  *
  * On eviction, a snapshot of this counter (along with some bits to
  * identify the zone) is stored in the now empty page cache radix tree
@@ -161,8 +162,8 @@ static void *pack_shadow(unsigned long eviction, struct zone *zone)
 	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
 }
 
-static void unpack_shadow(void *shadow,
-			  struct zone **zone,
+static void unpack_shadow(void *shadow, struct page *page,
+			  struct zone **zone, struct lruvec **lruvec,
 			  unsigned long *distance)
 {
 	unsigned long entry = (unsigned long)shadow;
@@ -179,8 +180,9 @@ static void unpack_shadow(void *shadow,
 	eviction = entry;
 
 	*zone = NODE_DATA(nid)->node_zones + zid;
+	*lruvec = mem_cgroup_page_lruvec(page, *zone);
 
-	refault = atomic_long_read(&(*zone)->inactive_age);
+	refault = atomic_long_read(&(*lruvec)->inactive_age);
 	mask = ~0UL >> (NODES_SHIFT + ZONES_SHIFT +
 			RADIX_TREE_EXCEPTIONAL_SHIFT);
 	/*
@@ -213,30 +215,33 @@ static void unpack_shadow(void *shadow,
 void *workingset_eviction(struct address_space *mapping, struct page *page)
 {
 	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec = mem_cgroup_page_lruvec(page, zone);
 	unsigned long eviction;
 
-	eviction = atomic_long_inc_return(&zone->inactive_age);
+	eviction = atomic_long_inc_return(&lruvec->inactive_age);
 	return pack_shadow(eviction, zone);
 }
 
 /**
  * workingset_refault - evaluate the refault of a previously evicted page
  * @shadow: shadow entry of the evicted page
+ * @page: the refaulted page
  *
  * Calculates and evaluates the refault distance of the previously
  * evicted page in the context of the zone it was allocated in.
  *
  * Returns %true if the page should be activated, %false otherwise.
  */
-bool workingset_refault(void *shadow)
+bool workingset_refault(void *shadow, struct page *page)
 {
 	unsigned long refault_distance;
 	struct zone *zone;
+	struct lruvec *lruvec;
 
-	unpack_shadow(shadow, &zone, &refault_distance);
+	unpack_shadow(shadow, page, &zone, &lruvec, &refault_distance);
 	inc_zone_state(zone, WORKINGSET_REFAULT);
 
-	if (refault_distance <= zone_page_state(zone, NR_ACTIVE_FILE)) {
+	if (refault_distance <= get_lru_size(lruvec, LRU_ACTIVE_FILE)) {
 		inc_zone_state(zone, WORKINGSET_ACTIVATE);
 		return true;
 	}
@@ -249,7 +254,9 @@ bool workingset_refault(void *shadow)
  */
 void workingset_activation(struct page *page)
 {
-	atomic_long_inc(&page_zone(page)->inactive_age);
+	struct lruvec *lruvec = mem_cgroup_page_lruvec(page, page_zone(page));
+
+	atomic_long_inc(&lruvec->inactive_age);
 }
 
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
