Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3310B6B0089
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 10:44:03 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 4/7] mm: migration: Allow migration to operate asynchronously and avoid synchronous compaction in the faster path
Date: Mon, 22 Nov 2010 15:43:52 +0000
Message-Id: <1290440635-30071-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
References: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Migration synchronously waits for writeback if the initial passes fails.
Callers of memory compaction do not necessarily want this behaviour if the
caller is latency sensitive or expects that synchronous migration is not
going to have a significantly better success rate.

This patch adds a sync parameter to migrate_pages() allowing the caller to
indicate if wait_on_page_writeback() is allowed within migration or not. For
reclaim/compaction, try_to_compact_pages() is first called asynchronously,
direct reclaim runs and then try_to_compact_pages() is called synchronously
as there is a greater expectation that it'll succeed.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/compaction.h |   10 ++++++----
 include/linux/migrate.h    |   12 ++++++++----
 mm/compaction.c            |   14 ++++++++++----
 mm/memory-failure.c        |    3 ++-
 mm/memory_hotplug.c        |    3 ++-
 mm/mempolicy.c             |    4 ++--
 mm/migrate.c               |   22 +++++++++++++---------
 mm/page_alloc.c            |   21 +++++++++++++++------
 mm/vmscan.c                |    2 +-
 9 files changed, 59 insertions(+), 32 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index e082cf9..d0aeffd 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -21,10 +21,11 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
-			int order, gfp_t gfp_mask, nodemask_t *mask);
+			int order, gfp_t gfp_mask, nodemask_t *mask,
+			bool sync);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 extern unsigned long compact_zone_order(struct zone *zone, int order,
-						gfp_t gfp_mask);
+						gfp_t gfp_mask, bool sync);
 
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
@@ -57,7 +58,8 @@ static inline bool compaction_deferred(struct zone *zone)
 
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
-			int order, gfp_t gfp_mask, nodemask_t *nodemask)
+			int order, gfp_t gfp_mask, nodemask_t *nodemask,
+			bool sync)
 {
 	return COMPACT_CONTINUE;
 }
@@ -68,7 +70,7 @@ static inline unsigned long compaction_suitable(struct zone *zone, int order)
 }
 
 extern unsigned long compact_zone_order(struct zone *zone, int order,
-						gfp_t gfp_mask)
+						gfp_t gfp_mask, bool sync)
 {
 	return 0;
 }
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 085527f..fa31902 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -13,9 +13,11 @@ extern void putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x,
-			unsigned long private, int offlining);
+			unsigned long private, int offlining,
+			bool sync);
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
-			unsigned long private, int offlining);
+			unsigned long private, int offlining,
+			bool sync);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -33,9 +35,11 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
-		unsigned long private, int offlining) { return -ENOSYS; }
+		unsigned long private, int offlining,
+		bool sync) { return -ENOSYS; }
 static inline int migrate_huge_pages(struct list_head *l, new_page_t x,
-		unsigned long private, int offlining) { return -ENOSYS; }
+		unsigned long private, int offlining,
+		bool sync) { return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
diff --git a/mm/compaction.c b/mm/compaction.c
index 384fa71..03bd8f9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -33,6 +33,7 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	bool sync;			/* Synchronous migration */
 
 	/* Account for isolated anon and file pages */
 	unsigned long nr_anon;
@@ -456,7 +457,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 		nr_migrate = cc->nr_migratepages;
 		migrate_pages(&cc->migratepages, compaction_alloc,
-						(unsigned long)cc, 0);
+				(unsigned long)cc, 0,
+				cc->sync);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
@@ -483,7 +485,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 }
 
 unsigned long compact_zone_order(struct zone *zone,
-						int order, gfp_t gfp_mask)
+						int order, gfp_t gfp_mask,
+						bool sync)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -491,6 +494,7 @@ unsigned long compact_zone_order(struct zone *zone,
 		.order = order,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
+		.sync = sync,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -506,11 +510,13 @@ int sysctl_extfrag_threshold = 500;
  * @order: The order of the current allocation
  * @gfp_mask: The GFP mask of the current allocation
  * @nodemask: The allowed nodes to allocate from
+ * @sync: Whether migration is synchronous or not
  *
  * This is the main entry point for direct page compaction.
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
-			int order, gfp_t gfp_mask, nodemask_t *nodemask)
+			int order, gfp_t gfp_mask, nodemask_t *nodemask,
+			bool sync)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -534,7 +540,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 								nodemask) {
 		int status;
 
-		status = compact_zone_order(zone, order, gfp_mask);
+		status = compact_zone_order(zone, order, gfp_mask, sync);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1243241..188294e 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1413,7 +1413,8 @@ int soft_offline_page(struct page *page, int flags)
 		LIST_HEAD(pagelist);
 
 		list_add(&page->lru, &pagelist);
-		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0);
+		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
+								0, true);
 		if (ret) {
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
 				pfn, ret, page->flags);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9260314..221178b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -716,7 +716,8 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			goto out;
 		}
 		/* this function returns # of failed pages */
-		ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
+		ret = migrate_pages(&source, hotremove_migrate_alloc, 0,
+								1, true);
 		if (ret)
 			putback_lru_pages(&source);
 	}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4a57f13..8b1a490 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -935,7 +935,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 		return PTR_ERR(vma);
 
 	if (!list_empty(&pagelist)) {
-		err = migrate_pages(&pagelist, new_node_page, dest, 0);
+		err = migrate_pages(&pagelist, new_node_page, dest, 0, true);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
@@ -1155,7 +1155,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 
 		if (!list_empty(&pagelist)) {
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
-						(unsigned long)vma, 0);
+						(unsigned long)vma, 0, true);
 			if (nr_failed)
 				putback_lru_pages(&pagelist);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index fe5a3c6..678a84a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -612,7 +612,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force, int offlining)
+			struct page *page, int force, int offlining, bool sync)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -663,7 +663,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	BUG_ON(charge);
 
 	if (PageWriteback(page)) {
-		if (!force)
+		if (!force || !sync)
 			goto uncharge;
 		wait_on_page_writeback(page);
 	}
@@ -808,7 +808,7 @@ move_newpage:
  */
 static int unmap_and_move_huge_page(new_page_t get_new_page,
 				unsigned long private, struct page *hpage,
-				int force, int offlining)
+				int force, int offlining, bool sync)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -822,7 +822,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	rc = -EAGAIN;
 
 	if (!trylock_page(hpage)) {
-		if (!force)
+		if (!force || !sync)
 			goto out;
 		lock_page(hpage);
 	}
@@ -890,7 +890,8 @@ out:
  * Return: Number of pages not migrated or error code.
  */
 int migrate_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private, int offlining)
+		new_page_t get_new_page, unsigned long private, int offlining,
+		bool sync)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -910,7 +911,8 @@ int migrate_pages(struct list_head *from,
 			cond_resched();
 
 			rc = unmap_and_move(get_new_page, private,
-						page, pass > 2, offlining);
+						page, pass > 2, offlining,
+						sync);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -939,7 +941,8 @@ out:
 }
 
 int migrate_huge_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private, int offlining)
+		new_page_t get_new_page, unsigned long private, int offlining,
+		bool sync)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -955,7 +958,8 @@ int migrate_huge_pages(struct list_head *from,
 			cond_resched();
 
 			rc = unmap_and_move_huge_page(get_new_page,
-					private, page, pass > 2, offlining);
+					private, page, pass > 2, offlining,
+					sync);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -1088,7 +1092,7 @@ set_status:
 	err = 0;
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_page_node,
-				(unsigned long)pm, 0);
+				(unsigned long)pm, 0, true);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c88655..c9e0fbe 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1788,7 +1788,8 @@ static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, unsigned long *did_some_progress)
+	int migratetype, unsigned long *did_some_progress,
+	bool sync_migration)
 {
 	struct page *page;
 
@@ -1796,7 +1797,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
-								nodemask);
+						nodemask, sync_migration);
 	if (*did_some_progress != COMPACT_SKIPPED) {
 
 		/* Page migration frees to the PCP lists but we want merging */
@@ -1832,7 +1833,8 @@ static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, unsigned long *did_some_progress)
+	int migratetype, unsigned long *did_some_progress,
+	bool sync_migration)
 {
 	return NULL;
 }
@@ -1974,6 +1976,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
 	struct task_struct *p = current;
+	bool sync_migration = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -2036,14 +2039,19 @@ rebalance:
 	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
 		goto nopage;
 
-	/* Try direct compaction */
+	/*
+	 * Try direct compaction. The first pass is asynchronous. Subsequent
+	 * attempts after direct reclaim are synchronous
+	 */
 	page = __alloc_pages_direct_compact(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, &did_some_progress);
+					migratetype, &did_some_progress,
+					sync_migration);
 	if (page)
 		goto got_pg;
+	sync_migration = true;
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
@@ -2107,7 +2115,8 @@ rebalance:
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, &did_some_progress);
+					migratetype, &did_some_progress,
+					sync_migration);
 		if (page)
 			goto got_pg;
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3fb7a76..6a6aa7d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2371,7 +2371,7 @@ loop_again:
 			 */
 			if (sc.order > PAGE_ALLOC_COSTLY_ORDER)
 				compact_zone_order(zone, sc.order,
-						sc.gfp_mask);
+						sc.gfp_mask, false);
 
 			if (!zone_watermark_ok(zone, order,
 					high_wmark_pages(zone), end_zone, 0)) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
