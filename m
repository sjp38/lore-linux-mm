Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C3AE06B012E
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 11:22:56 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 4/8] mm: migration: Allow migration to operate asynchronously and avoid synchronous compaction in the faster path
Date: Wed, 17 Nov 2010 16:22:45 +0000
Message-Id: <1290010969-26721-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Migration synchronously waits for writeback if the initial passes fails.
try_to_compact_pages() does not want this behaviour. It's in a faster
allocation path where no pages have been freed yet. If compaction does not
succeed quickly, synchronous migration is not going to help and unnecessarily
delays a process.

This patch adds a sync parameter to migrate_pages() allowing the caller
to indicate if wait_on_page_writeback() is allowed within migration or
not. Only try_to_compact_pages() uses asynchronous migration with direct
compaction using the synchronous version within the direct reclaim path.
All other callers use synchronous migration to preserve existing
behaviour.

In tests, this reduces latency when allocating huge pages as the faster
path is avoiding stalls and postponing synchronous migration until pages
had been freed.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/migrate.h |   12 ++++++++----
 mm/compaction.c         |    6 +++++-
 mm/memory-failure.c     |    3 ++-
 mm/memory_hotplug.c     |    3 ++-
 mm/mempolicy.c          |    4 ++--
 mm/migrate.c            |   24 ++++++++++++++----------
 6 files changed, 33 insertions(+), 19 deletions(-)

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
index 3c37c52..b8e27cc 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -33,6 +33,7 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	bool sync;			/* Synchronous migration */
 
 	/* Account for isolated anon and file pages */
 	unsigned long nr_anon;
@@ -449,7 +450,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 		nr_migrate = cc->nr_migratepages;
 		migrate_pages(&cc->migratepages, compaction_alloc,
-						(unsigned long)cc, 0);
+				(unsigned long)cc, 0,
+				cc->sync);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
@@ -484,6 +486,7 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.order = order,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
+		.sync = false,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -500,6 +503,7 @@ unsigned long reclaimcompact_zone_order(struct zone *zone,
 		.order = order,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
+		.sync = true,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1243241..ebc2a1b 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1413,7 +1413,8 @@ int soft_offline_page(struct page *page, int flags)
 		LIST_HEAD(pagelist);
 
 		list_add(&page->lru, &pagelist);
-		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0);
+		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
+									0, true);
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
index fe5a3c6..ea684ab 100644
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
@@ -635,7 +635,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	rc = -EAGAIN;
 
 	if (!trylock_page(page)) {
-		if (!force)
+		if (!force || !sync)
 			goto move_newpage;
 		lock_page(page);
 	}
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
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
