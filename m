Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 47D3F6B0072
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 03:51:16 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so48123662lbb.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:15 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id uo6si9859800lbc.21.2015.06.15.00.51.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 00:51:14 -0700 (PDT)
Received: by labbc20 with SMTP id bc20so16039807lab.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:13 -0700 (PDT)
Subject: [PATCH RFC v0 5/6] mm/compaction: use migration without isolation
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Mon, 15 Jun 2015 10:51:09 +0300
Message-ID: <20150615075109.18112.74504.stgit@zurg>
In-Reply-To: <20150615073926.18112.59207.stgit@zurg>
References: <20150615073926.18112.59207.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

TODO
* fix interaction with too_many_isolated (account pages as pinned?)
* rename the rest of isolated_* stuff, pages are not isolated
* fix racy check page->mapping->a_ops->migratepage

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/trace/events/compaction.h |   12 +-
 mm/compaction.c                   |  205 +++++++++++++++++++++----------------
 mm/internal.h                     |    9 +-
 mm/migrate.c                      |    2 
 mm/page_alloc.c                   |   24 ++--
 5 files changed, 142 insertions(+), 110 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 9a6a3fe..c5b3260 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -66,7 +66,7 @@ TRACE_EVENT(mm_compaction_migratepages,
 
 	TP_PROTO(unsigned long nr_all,
 		int migrate_rc,
-		struct list_head *migratepages),
+		struct pagevec *migratepages),
 
 	TP_ARGS(nr_all, migrate_rc, migratepages),
 
@@ -77,7 +77,9 @@ TRACE_EVENT(mm_compaction_migratepages,
 
 	TP_fast_assign(
 		unsigned long nr_failed = 0;
-		struct list_head *page_lru;
+		struct pagevec *pvec;
+		struct page *page;
+		int i;
 
 		/*
 		 * migrate_pages() returns either a non-negative number
@@ -88,8 +90,10 @@ TRACE_EVENT(mm_compaction_migratepages,
 		if (migrate_rc >= 0)
 			nr_failed = migrate_rc;
 		else
-			list_for_each(page_lru, migratepages)
-				nr_failed++;
+			pagevec_for_each_vec_and_page(migratepages,
+						      pvec, i, page)
+				if (page_count(page) != 1)
+					nr_failed++;
 
 		__entry->nr_migrated = nr_all - nr_failed;
 		__entry->nr_failed = nr_failed;
diff --git a/mm/compaction.c b/mm/compaction.c
index 018f08d..9f3fe19 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -378,6 +378,11 @@ static bool compact_unlock_should_abort(spinlock_t *lock,
  */
 static inline bool compact_should_abort(struct compact_control *cc)
 {
+	if (fatal_signal_pending(current)) {
+		cc->contended = COMPACT_CONTENDED_SCHED;
+		return true;
+	}
+
 	/* async compaction aborts if contended */
 	if (need_resched()) {
 		if (cc->mode == MIGRATE_ASYNC) {
@@ -591,22 +596,6 @@ isolate_freepages_range(struct compact_control *cc,
 	return pfn;
 }
 
-/* Update the number of anon and file isolated pages in the zone */
-static void acct_isolated(struct zone *zone, struct compact_control *cc)
-{
-	struct page *page;
-	unsigned int count[2] = { 0, };
-
-	if (list_empty(&cc->migratepages))
-		return;
-
-	list_for_each_entry(page, &cc->migratepages, lru)
-		count[!!page_is_file_cache(page)]++;
-
-	mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
-	mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
-}
-
 /* Similar to reclaim, but different enough that they don't share logic */
 static bool too_many_isolated(struct zone *zone)
 {
@@ -623,7 +612,7 @@ static bool too_many_isolated(struct zone *zone)
 }
 
 /**
- * isolate_migratepages_block() - isolate all migrate-able pages within
+ * collect_migratepages_block() - collect all migrate-able pages within
  *				  a single pageblock
  * @cc:		Compaction control structure.
  * @low_pfn:	The first PFN to isolate
@@ -641,15 +630,11 @@ static bool too_many_isolated(struct zone *zone)
  * is neither read nor updated.
  */
 static unsigned long
-isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
+collect_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			unsigned long end_pfn, isolate_mode_t isolate_mode)
 {
 	struct zone *zone = cc->zone;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
-	struct list_head *migratelist = &cc->migratepages;
-	struct lruvec *lruvec;
-	unsigned long flags = 0;
-	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
 	unsigned long start_pfn = low_pfn;
 
@@ -672,6 +657,10 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	if (compact_should_abort(cc))
 		return 0;
 
+	/* pagevec_extend() has failed */
+	if (!cc->migratepages_tail)
+		return 0;
+
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
 		/*
@@ -679,9 +668,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * contention, to give chance to IRQs. Abort async compaction
 		 * if contended.
 		 */
-		if (!(low_pfn % SWAP_CLUSTER_MAX)
-		    && compact_unlock_should_abort(&zone->lru_lock, flags,
-								&locked, cc))
+		if (!(low_pfn % SWAP_CLUSTER_MAX) &&
+				compact_should_abort(cc))
 			break;
 
 		if (!pfn_valid_within(low_pfn))
@@ -728,22 +716,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		}
 
 		/*
-		 * PageLRU is set. lru_lock normally excludes isolation
-		 * splitting and collapsing (collapsing has already happened
-		 * if PageLRU is set) but the lock is not necessarily taken
-		 * here and it is wasteful to take it just to check transhuge.
-		 * Check TransHuge without lock and skip the whole pageblock if
-		 * it's either a transhuge or hugetlbfs page, as calling
-		 * compound_order() without preventing THP from splitting the
-		 * page underneath us may return surprising results.
+		 * Check PageTransCompound without lock and skip the whole
+		 * pageblock if it's either a transhuge or hugetlbfs page,
+		 * as calling compound_order() without preventing THP from
+		 * splitting the page may return surprising results.
 		 */
-		if (PageTransHuge(page)) {
-			if (!locked)
-				low_pfn = ALIGN(low_pfn + 1,
-						pageblock_nr_pages) - 1;
-			else
-				low_pfn += (1 << compound_order(page)) - 1;
-
+		if (PageTransCompound(page)) {
+			low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
 			continue;
 		}
 
@@ -756,37 +735,60 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		    page_count(page) > page_mapcount(page))
 			continue;
 
-		/* If we already hold the lock, we can skip some rechecking */
-		if (!locked) {
-			locked = compact_trylock_irqsave(&zone->lru_lock,
-								&flags, cc);
-			if (!locked)
-				break;
+		/* Compaction should not handle unevictable pages but CMA can do so */
+		if (PageUnevictable(page) &&
+				!(isolate_mode & ISOLATE_UNEVICTABLE))
+			continue;
 
-			/* Recheck PageLRU and PageTransHuge under lock */
-			if (!PageLRU(page))
-				continue;
-			if (PageTransHuge(page)) {
-				low_pfn += (1 << compound_order(page)) - 1;
+		/*
+		 * ISOLATE_ASYNC_MIGRATE is used to indicate that it only wants to pages
+		 * that it is possible to migrate without blocking
+		 */
+		if (isolate_mode & ISOLATE_ASYNC_MIGRATE) {
+			/* All the caller can do on PageWriteback is block */
+			if (PageWriteback(page))
 				continue;
+
+			if (PageDirty(page)) {
+				struct address_space *mapping;
+
+				/*
+				 * Only pages without mappings or that have
+				 * a ->migratepage callback are possible to
+				 * migrate without blocking.
+				 *
+				 * FIXME this is unsafe without page_lock
+				 * present __isolate_lru_page does this too
+				 */
+				mapping = page_mapping(page);
+				if (mapping && !mapping->a_ops->migratepage)
+					continue;
 			}
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
-
-		/* Try isolate the page */
-		if (__isolate_lru_page(page, isolate_mode) != 0)
+		if (!get_page_unless_zero(page))
 			continue;
 
-		VM_BUG_ON_PAGE(PageTransCompound(page), page);
-
-		/* Successfully isolated */
-		del_page_from_lru_list(page, lruvec, page_lru(page));
+		/*
+		 * Without PageLRU that might any type of kernel page
+		 * we could also check page->mapping but without PageLRU
+		 * migraion likely fails because elevated page refcount.
+		 */
+		if (!PageLRU(page) || PageTransCompound(page)) {
+			VM_BUG_ON_PAGE(PageTail(page), page);
+			put_page(page);
+			continue;
+		}
 
 isolate_success:
-		list_add(&page->lru, migratelist);
-		cc->nr_migratepages++;
 		nr_isolated++;
+		cc->nr_migratepages++;
+		if (!pagevec_add(cc->migratepages_tail, page)) {
+			cc->migratepages_tail = pagevec_extend(
+					cc->migratepages_tail, GFP_ATOMIC);
+			if (!cc->migratepages_tail)
+				return 0;
+		}
 
 		/* Avoid isolating too much */
 		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
@@ -802,9 +804,6 @@ isolate_success:
 	if (unlikely(low_pfn > end_pfn))
 		low_pfn = end_pfn;
 
-	if (locked)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
-
 	/*
 	 * Update the pageblock-skip information and cached scanner pfn,
 	 * if the whole pageblock was scanned without isolating any page.
@@ -823,7 +822,7 @@ isolate_success:
 }
 
 /**
- * isolate_migratepages_range() - isolate migrate-able pages in a PFN range
+ * collect_migratepages_range() - collect migrate-able pages in a PFN range
  * @cc:        Compaction control structure.
  * @start_pfn: The first PFN to start isolating.
  * @end_pfn:   The one-past-last PFN.
@@ -833,7 +832,7 @@ isolate_success:
  * (which may be greater than end_pfn if end fell in a middle of a THP page).
  */
 unsigned long
-isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
+collect_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 							unsigned long end_pfn)
 {
 	unsigned long pfn, block_end_pfn;
@@ -850,8 +849,8 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
 			continue;
 
-		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
-							ISOLATE_UNEVICTABLE);
+		pfn = collect_migratepages_block(cc, pfn, block_end_pfn,
+						 ISOLATE_UNEVICTABLE);
 
 		/*
 		 * In case of fatal failure, release everything that might
@@ -859,19 +858,28 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 		 * the failure back to caller.
 		 */
 		if (!pfn) {
-			putback_movable_pages(&cc->migratepages);
-			cc->nr_migratepages = 0;
+			release_migratepages(cc);
 			break;
 		}
 
 		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
 			break;
 	}
-	acct_isolated(cc->zone, cc);
 
 	return pfn;
 }
 
+void release_migratepages(struct compact_control *cc)
+{
+	struct pagevec *pvec;
+
+	pagevec_for_each_vec(&cc->migratepages, pvec)
+		pagevec_release(pvec);
+	pagevec_shrink(&cc->migratepages);
+	cc->migratepages_tail = &cc->migratepages;
+	cc->nr_migratepages = 0;
+}
+
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
 
@@ -1040,7 +1048,7 @@ static void compaction_free(struct page *page, unsigned long data)
 	cc->nr_freepages++;
 }
 
-/* possible outcome of isolate_migratepages */
+/* possible outcome of collect_migratepages */
 typedef enum {
 	ISOLATE_ABORT,		/* Abort compaction now */
 	ISOLATE_NONE,		/* No pages isolated, continue scanning */
@@ -1058,7 +1066,7 @@ int sysctl_compact_unevictable_allowed __read_mostly = 1;
  * starting at the block pointed to by the migrate scanner pfn within
  * compact_control.
  */
-static isolate_migrate_t isolate_migratepages(struct zone *zone,
+static isolate_migrate_t collect_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
@@ -1109,14 +1117,11 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		    !migrate_async_suitable(get_pageblock_migratetype(page)))
 			continue;
 
-		/* Perform the isolation */
-		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
+		low_pfn = collect_migratepages_block(cc, low_pfn, end_pfn,
 								isolate_mode);
 
-		if (!low_pfn || cc->contended) {
-			acct_isolated(zone, cc);
+		if (!low_pfn || cc->contended)
 			return ISOLATE_ABORT;
-		}
 
 		/*
 		 * Either we isolated something and proceed with migration. Or
@@ -1126,7 +1131,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		break;
 	}
 
-	acct_isolated(zone, cc);
 	/*
 	 * Record where migration scanner will be restarted. If we end up in
 	 * the same pageblock as the free scanner, make the scanners fully
@@ -1344,11 +1348,14 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		int err;
 		unsigned long isolate_start_pfn = cc->migrate_pfn;
 
-		switch (isolate_migratepages(zone, cc)) {
+		VM_BUG_ON(cc->nr_migratepages);
+		VM_BUG_ON(pagevec_count(&cc->migratepages));
+		VM_BUG_ON(pagevec_next(&cc->migratepages));
+
+		switch (collect_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
 			ret = COMPACT_PARTIAL;
-			putback_movable_pages(&cc->migratepages);
-			cc->nr_migratepages = 0;
+			release_migratepages(cc);
 			goto out;
 		case ISOLATE_NONE:
 			/*
@@ -1361,7 +1368,22 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 			;
 		}
 
-		err = migrate_pages(&cc->migratepages, compaction_alloc,
+		{
+			struct pagevec *pvec;
+			int index;
+			struct page *page;
+			int count = 0;
+
+			pagevec_for_each_vec_and_page(&cc->migratepages, pvec, index, page) {
+				VM_BUG_ON_PAGE(page_count(page) < 1, page);
+				VM_BUG_ON_PAGE(PageTransCompound(page), page);
+				count++;
+			}
+
+			VM_BUG_ON(count != cc->nr_migratepages);
+		}
+
+		err = migrate_pagevec(&cc->migratepages, compaction_alloc,
 				compaction_free, (unsigned long)cc, cc->mode,
 				MR_COMPACTION);
 
@@ -1369,11 +1391,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 							&cc->migratepages);
 
 		/* All pages were either migrated or will be released */
-		cc->nr_migratepages = 0;
+		release_migratepages(cc);
 		if (err) {
-			putback_movable_pages(&cc->migratepages);
 			/*
-			 * migrate_pages() may return -ENOMEM when scanners meet
+			 * migrate_pagevec() may return -ENOMEM when scanners meet
 			 * and we want compact_finished() to detect it
 			 */
 			if (err == -ENOMEM && cc->free_pfn > cc->migrate_pfn) {
@@ -1385,7 +1406,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		/*
 		 * Record where we could have freed pages by migration and not
 		 * yet flushed them to buddy allocator. We use the pfn that
-		 * isolate_migratepages() started from in this loop iteration
+		 * collect_migratepages() started from in this loop iteration
 		 * - this is the lowest page that could have been isolated and
 		 * then freed by migration.
 		 */
@@ -1459,12 +1480,13 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 		.classzone_idx = classzone_idx,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
-	INIT_LIST_HEAD(&cc.migratepages);
+	pagevec_init(&cc.migratepages, 0);
+	cc.migratepages_tail = &cc.migratepages;
 
 	ret = compact_zone(zone, &cc);
 
 	VM_BUG_ON(!list_empty(&cc.freepages));
-	VM_BUG_ON(!list_empty(&cc.migratepages));
+	VM_BUG_ON(pagevec_count(&cc.migratepages));
 
 	*contended = cc.contended;
 	return ret;
@@ -1604,7 +1626,8 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		cc->nr_migratepages = 0;
 		cc->zone = zone;
 		INIT_LIST_HEAD(&cc->freepages);
-		INIT_LIST_HEAD(&cc->migratepages);
+		pagevec_init(&cc->migratepages, 0);
+		cc->migratepages_tail = &cc->migratepages;
 
 		/*
 		 * When called via /proc/sys/vm/compact_memory
@@ -1624,7 +1647,7 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		}
 
 		VM_BUG_ON(!list_empty(&cc->freepages));
-		VM_BUG_ON(!list_empty(&cc->migratepages));
+		VM_BUG_ON(pagevec_count(&cc->migratepages));
 	}
 }
 
diff --git a/mm/internal.h b/mm/internal.h
index 1cf2eb9..19081ba 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -13,6 +13,7 @@
 
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/pagevec.h>
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
@@ -176,11 +177,12 @@ extern int user_min_free_kbytes;
  */
 struct compact_control {
 	struct list_head freepages;	/* List of free pages to migrate to */
-	struct list_head migratepages;	/* List of pages being migrated */
+	struct pagevec migratepages;	/* Vector of pages being migrated */
+	struct pagevec *migratepages_tail;
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
-	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	unsigned long migrate_pfn;	/* collect_migratepages search base */
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
 	int order;			/* order a direct compactor needs */
@@ -198,8 +200,9 @@ unsigned long
 isolate_freepages_range(struct compact_control *cc,
 			unsigned long start_pfn, unsigned long end_pfn);
 unsigned long
-isolate_migratepages_range(struct compact_control *cc,
+collect_migratepages_range(struct compact_control *cc,
 			   unsigned long low_pfn, unsigned long end_pfn);
+void release_migratepages(struct compact_control *cc);
 int find_suitable_fallback(struct free_area *area, unsigned int order,
 			int migratetype, bool only_stealable, bool *can_steal);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 775cc9d..c060991 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -76,7 +76,7 @@ int migrate_prep_local(void)
  * from where they were once taken off for compaction/migration.
  *
  * This function shall be used whenever the isolated pageset has been
- * built from lru, balloon, hugetlbfs page. See isolate_migratepages_range()
+ * built from lru, balloon, hugetlbfs page. See collect_migratepages_range()
  * and isolate_huge_page().
  */
 void putback_movable_pages(struct list_head *l)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9adf4d07..ca37e71 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6343,20 +6343,21 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 	/* This function is based on compact_zone() from compaction.c. */
 	unsigned long pfn = start;
 	unsigned int tries = 0;
+	struct pagevec *pvec;
 	struct page *page;
-	int ret = 0;
+	int index, ret = 0;
 
 	migrate_prep();
 
-	while (pfn < end || !list_empty(&cc->migratepages)) {
+	while (pfn < end || pagevec_count(&cc->migratepages)) {
 		if (fatal_signal_pending(current)) {
 			ret = -EINTR;
 			break;
 		}
 
-		if (list_empty(&cc->migratepages)) {
+		if (!pagevec_count(&cc->migratepages)) {
 			cc->nr_migratepages = 0;
-			pfn = isolate_migratepages_range(cc, pfn, end);
+			pfn = collect_migratepages_range(cc, pfn, end);
 			if (!pfn) {
 				ret = -EINTR;
 				break;
@@ -6371,18 +6372,18 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 		 * Try to reclaim clean page cache pages.
 		 * Migration simply skips pages where page_count == 1.
 		 */
-		list_for_each_entry(page, &cc->migratepages, lru) {
+		pagevec_for_each_vec_and_page(&cc->migratepages,
+					      pvec, index, page) {
 			if (!PageAnon(page))
 				try_to_reclaim_page(page);
 		}
 
-		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
-				    NULL, 0, cc->mode, MR_CMA);
+		ret = migrate_pagevec(&cc->migratepages, alloc_migrate_target,
+				      NULL, 0, cc->mode, MR_CMA);
 	}
-	if (ret < 0) {
-		putback_movable_pages(&cc->migratepages);
+	release_migratepages(cc);
+	if (ret < 0)
 		return ret;
-	}
 	return 0;
 }
 
@@ -6419,7 +6420,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
 	};
-	INIT_LIST_HEAD(&cc.migratepages);
+	pagevec_init(&cc.migratepages, 0);
+	cc.migratepages_tail = &cc.migratepages;
 
 	/*
 	 * What we do here is we mark all pageblocks in range as

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
