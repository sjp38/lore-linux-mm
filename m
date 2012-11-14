Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 751346B00AF
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 16:50:57 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so401310dad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:50:56 -0800 (PST)
Date: Wed, 14 Nov 2012 13:50:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [3.6 regression?] THP + migration/compaction livelock (I
 think)
In-Reply-To: <20121114132940.GA13196@offline.be>
Message-ID: <alpine.DEB.2.00.1211141342460.13515@chino.kir.corp.google.com>
References: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com> <alpine.DEB.2.00.1211131507370.17623@chino.kir.corp.google.com> <CALCETrU=7+pk_rMKKuzgW1gafWfv6v7eQtVw3p8JryaTkyVQYQ@mail.gmail.com> <alpine.DEB.2.00.1211131530020.17623@chino.kir.corp.google.com>
 <20121114100154.GI8218@suse.de> <20121114132940.GA13196@offline.be>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Duponcheel <marc@offline.be>
Cc: Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 14 Nov 2012, Marc Duponcheel wrote:

>  Hi all
> 
>  If someone can provide the patches (or learn me how to get them with
> git (I apologise to not be git savy)) then, this weekend, I can apply
> them to 3.6.6 and compare before/after to check if they fix #49361.
> 

I've backported all the commits that Mel quoted to 3.6.6 and appended them 
to this email as one big patch.  It should apply cleanly to your kernel.

Now we are only missing these commits that weren't quoted:

 - 1fb3f8ca0e92 ("mm: compaction: capture a suitable high-order page 
                  immediately when it is made available"), and

 - 83fde0f22872 ("mm: vmscan: scale number of pages reclaimed by 
                  reclaim/compaction based on failures").

Since your regression is easily reproducible, would it be possible to try 
to reproduce the issue FIRST with 3.6.6 and, if still present as it was in 
3.6.2, then try reproducing it with the appended patch?

You earlier reported that khugepaged was taking the second-most cpu time 
when this was happening, which initially pointed you to thp, so presumably 
this isn't a kswapd issue running at 100%.  If both 3.6.6 kernels fail 
(the one with and without the following patch), would it be possible to 
try Mel's suggestion of patching with

 - https://lkml.org/lkml/2012/11/5/308 +
   https://lkml.org/lkml/2012/11/12/113

to see if it helps and, if not, reverting the latter and trying

 - https://lkml.org/lkml/2012/11/5/308 +
   https://lkml.org/lkml/2012/11/12/151

as the final test?  This will certainly help us to find out what needs to 
be backported to 3.6 stable to prevent this issue for other users.

Thanks!
---
 include/linux/compaction.h      |   15 ++
 include/linux/mmzone.h          |    6 +-
 include/linux/pageblock-flags.h |   19 +-
 mm/compaction.c                 |  450 +++++++++++++++++++++++++--------------
 mm/internal.h                   |   16 +-
 mm/page_alloc.c                 |   42 ++--
 mm/vmscan.c                     |    8 +
 7 files changed, 366 insertions(+), 190 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -24,6 +24,7 @@ extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
 			bool sync, bool *contended);
 extern int compact_pgdat(pg_data_t *pgdat, int order);
+extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 
 /* Do not skip compaction more than 64 times */
@@ -61,6 +62,16 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return zone->compact_considered < defer_limit;
 }
 
+/* Returns true if restarting compaction after many failures */
+static inline bool compaction_restarting(struct zone *zone, int order)
+{
+	if (order < zone->compact_order_failed)
+		return false;
+
+	return zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT &&
+		zone->compact_considered >= 1UL << zone->compact_defer_shift;
+}
+
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
@@ -74,6 +85,10 @@ static inline int compact_pgdat(pg_data_t *pgdat, int order)
 	return COMPACT_CONTINUE;
 }
 
+static inline void reset_isolation_suitable(pg_data_t *pgdat)
+{
+}
+
 static inline unsigned long compaction_suitable(struct zone *zone, int order)
 {
 	return COMPACT_SKIPPED;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -369,8 +369,12 @@ struct zone {
 	spinlock_t		lock;
 	int                     all_unreclaimable; /* All pages pinned */
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
-	/* pfn where the last incremental compaction isolated free pages */
+	/* Set to true when the PG_migrate_skip bits should be cleared */
+	bool			compact_blockskip_flush;
+
+	/* pfns where compaction scanners should start */
 	unsigned long		compact_cached_free_pfn;
+	unsigned long		compact_cached_migrate_pfn;
 #endif
 #ifdef CONFIG_MEMORY_HOTPLUG
 	/* see spanned/present_pages for more description */
diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -30,6 +30,9 @@ enum pageblock_bits {
 	PB_migrate,
 	PB_migrate_end = PB_migrate + 3 - 1,
 			/* 3 bits required for migrate types */
+#ifdef CONFIG_COMPACTION
+	PB_migrate_skip,/* If set the block is skipped by compaction */
+#endif /* CONFIG_COMPACTION */
 	NR_PAGEBLOCK_BITS
 };
 
@@ -65,10 +68,22 @@ unsigned long get_pageblock_flags_group(struct page *page,
 void set_pageblock_flags_group(struct page *page, unsigned long flags,
 					int start_bitidx, int end_bitidx);
 
+#ifdef CONFIG_COMPACTION
+#define get_pageblock_skip(page) \
+			get_pageblock_flags_group(page, PB_migrate_skip,     \
+							PB_migrate_skip + 1)
+#define clear_pageblock_skip(page) \
+			set_pageblock_flags_group(page, 0, PB_migrate_skip,  \
+							PB_migrate_skip + 1)
+#define set_pageblock_skip(page) \
+			set_pageblock_flags_group(page, 1, PB_migrate_skip,  \
+							PB_migrate_skip + 1)
+#endif /* CONFIG_COMPACTION */
+
 #define get_pageblock_flags(page) \
-			get_pageblock_flags_group(page, 0, NR_PAGEBLOCK_BITS-1)
+			get_pageblock_flags_group(page, 0, PB_migrate_end)
 #define set_pageblock_flags(page, flags) \
 			set_pageblock_flags_group(page, flags,	\
-						  0, NR_PAGEBLOCK_BITS-1)
+						  0, PB_migrate_end)
 
 #endif	/* PAGEBLOCK_FLAGS_H */
diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -50,6 +50,111 @@ static inline bool migrate_async_suitable(int migratetype)
 	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
 }
 
+#ifdef CONFIG_COMPACTION
+/* Returns true if the pageblock should be scanned for pages to isolate. */
+static inline bool isolation_suitable(struct compact_control *cc,
+					struct page *page)
+{
+	if (cc->ignore_skip_hint)
+		return true;
+
+	return !get_pageblock_skip(page);
+}
+
+/*
+ * This function is called to clear all cached information on pageblocks that
+ * should be skipped for page isolation when the migrate and free page scanner
+ * meet.
+ */
+static void __reset_isolation_suitable(struct zone *zone)
+{
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	unsigned long pfn;
+
+	zone->compact_cached_migrate_pfn = start_pfn;
+	zone->compact_cached_free_pfn = end_pfn;
+	zone->compact_blockskip_flush = false;
+
+	/* Walk the zone and mark every pageblock as suitable for isolation */
+	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		struct page *page;
+
+		cond_resched();
+
+		if (!pfn_valid(pfn))
+			continue;
+
+		page = pfn_to_page(pfn);
+		if (zone != page_zone(page))
+			continue;
+
+		clear_pageblock_skip(page);
+	}
+}
+
+void reset_isolation_suitable(pg_data_t *pgdat)
+{
+	int zoneid;
+
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+		struct zone *zone = &pgdat->node_zones[zoneid];
+		if (!populated_zone(zone))
+			continue;
+
+		/* Only flush if a full compaction finished recently */
+		if (zone->compact_blockskip_flush)
+			__reset_isolation_suitable(zone);
+	}
+}
+
+/*
+ * If no pages were isolated then mark this pageblock to be skipped in the
+ * future. The information is later cleared by __reset_isolation_suitable().
+ */
+static void update_pageblock_skip(struct compact_control *cc,
+			struct page *page, unsigned long nr_isolated,
+			bool migrate_scanner)
+{
+	struct zone *zone = cc->zone;
+	if (!page)
+		return;
+
+	if (!nr_isolated) {
+		unsigned long pfn = page_to_pfn(page);
+		set_pageblock_skip(page);
+
+		/* Update where compaction should restart */
+		if (migrate_scanner) {
+			if (!cc->finished_update_migrate &&
+			    pfn > zone->compact_cached_migrate_pfn)
+				zone->compact_cached_migrate_pfn = pfn;
+		} else {
+			if (!cc->finished_update_free &&
+			    pfn < zone->compact_cached_free_pfn)
+				zone->compact_cached_free_pfn = pfn;
+		}
+	}
+}
+#else
+static inline bool isolation_suitable(struct compact_control *cc,
+					struct page *page)
+{
+	return true;
+}
+
+static void update_pageblock_skip(struct compact_control *cc,
+			struct page *page, unsigned long nr_isolated,
+			bool migrate_scanner)
+{
+}
+#endif /* CONFIG_COMPACTION */
+
+static inline bool should_release_lock(spinlock_t *lock)
+{
+	return need_resched() || spin_is_contended(lock);
+}
+
 /*
  * Compaction requires the taking of some coarse locks that are potentially
  * very heavily contended. Check if the process needs to be scheduled or
@@ -62,7 +167,7 @@ static inline bool migrate_async_suitable(int migratetype)
 static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 				      bool locked, struct compact_control *cc)
 {
-	if (need_resched() || spin_is_contended(lock)) {
+	if (should_release_lock(lock)) {
 		if (locked) {
 			spin_unlock_irqrestore(lock, *flags);
 			locked = false;
@@ -70,14 +175,11 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 
 		/* async aborts if taking too long or contended */
 		if (!cc->sync) {
-			if (cc->contended)
-				*cc->contended = true;
+			cc->contended = true;
 			return false;
 		}
 
 		cond_resched();
-		if (fatal_signal_pending(current))
-			return false;
 	}
 
 	if (!locked)
@@ -91,44 +193,85 @@ static inline bool compact_trylock_irqsave(spinlock_t *lock,
 	return compact_checklock_irqsave(lock, flags, false, cc);
 }
 
+/* Returns true if the page is within a block suitable for migration to */
+static bool suitable_migration_target(struct page *page)
+{
+	int migratetype = get_pageblock_migratetype(page);
+
+	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
+	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
+		return false;
+
+	/* If the page is a large free page, then allow migration */
+	if (PageBuddy(page) && page_order(page) >= pageblock_order)
+		return true;
+
+	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
+	if (migrate_async_suitable(migratetype))
+		return true;
+
+	/* Otherwise skip the block */
+	return false;
+}
+
 /*
  * Isolate free pages onto a private freelist. Caller must hold zone->lock.
  * If @strict is true, will abort returning 0 on any invalid PFNs or non-free
  * pages inside of the pageblock (even though it may still end up isolating
  * some pages).
  */
-static unsigned long isolate_freepages_block(unsigned long blockpfn,
+static unsigned long isolate_freepages_block(struct compact_control *cc,
+				unsigned long blockpfn,
 				unsigned long end_pfn,
 				struct list_head *freelist,
 				bool strict)
 {
 	int nr_scanned = 0, total_isolated = 0;
-	struct page *cursor;
+	struct page *cursor, *valid_page = NULL;
+	unsigned long nr_strict_required = end_pfn - blockpfn;
+	unsigned long flags;
+	bool locked = false;
 
 	cursor = pfn_to_page(blockpfn);
 
-	/* Isolate free pages. This assumes the block is valid */
+	/* Isolate free pages. */
 	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
 		int isolated, i;
 		struct page *page = cursor;
 
-		if (!pfn_valid_within(blockpfn)) {
-			if (strict)
-				return 0;
-			continue;
-		}
 		nr_scanned++;
+		if (!pfn_valid_within(blockpfn))
+			continue;
+		if (!valid_page)
+			valid_page = page;
+		if (!PageBuddy(page))
+			continue;
+
+		/*
+		 * The zone lock must be held to isolate freepages.
+		 * Unfortunately this is a very coarse lock and can be
+		 * heavily contended if there are parallel allocations
+		 * or parallel compactions. For async compaction do not
+		 * spin on the lock and we acquire the lock as late as
+		 * possible.
+		 */
+		locked = compact_checklock_irqsave(&cc->zone->lock, &flags,
+								locked, cc);
+		if (!locked)
+			break;
+
+		/* Recheck this is a suitable migration target under lock */
+		if (!strict && !suitable_migration_target(page))
+			break;
 
-		if (!PageBuddy(page)) {
-			if (strict)
-				return 0;
+		/* Recheck this is a buddy page under lock */
+		if (!PageBuddy(page))
 			continue;
-		}
 
 		/* Found a free page, break it into order-0 pages */
 		isolated = split_free_page(page);
 		if (!isolated && strict)
-			return 0;
+			break;
 		total_isolated += isolated;
 		for (i = 0; i < isolated; i++) {
 			list_add(&page->lru, freelist);
@@ -143,6 +286,22 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
 	}
 
 	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
+
+	/*
+	 * If strict isolation is requested by CMA then check that all the
+	 * pages requested were isolated. If there were any failures, 0 is
+	 * returned and CMA will fail.
+	 */
+	if (strict && nr_strict_required > total_isolated)
+		total_isolated = 0;
+
+	if (locked)
+		spin_unlock_irqrestore(&cc->zone->lock, flags);
+
+	/* Update the pageblock-skip if the whole pageblock was scanned */
+	if (blockpfn == end_pfn)
+		update_pageblock_skip(cc, valid_page, total_isolated, false);
+
 	return total_isolated;
 }
 
@@ -160,17 +319,14 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
  * a free page).
  */
 unsigned long
-isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
+isolate_freepages_range(struct compact_control *cc,
+			unsigned long start_pfn, unsigned long end_pfn)
 {
-	unsigned long isolated, pfn, block_end_pfn, flags;
-	struct zone *zone = NULL;
+	unsigned long isolated, pfn, block_end_pfn;
 	LIST_HEAD(freelist);
 
-	if (pfn_valid(start_pfn))
-		zone = page_zone(pfn_to_page(start_pfn));
-
 	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
-		if (!pfn_valid(pfn) || zone != page_zone(pfn_to_page(pfn)))
+		if (!pfn_valid(pfn) || cc->zone != page_zone(pfn_to_page(pfn)))
 			break;
 
 		/*
@@ -180,10 +336,8 @@ isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
 		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		spin_lock_irqsave(&zone->lock, flags);
-		isolated = isolate_freepages_block(pfn, block_end_pfn,
+		isolated = isolate_freepages_block(cc, pfn, block_end_pfn,
 						   &freelist, true);
-		spin_unlock_irqrestore(&zone->lock, flags);
 
 		/*
 		 * In strict mode, isolate_freepages_block() returns 0 if
@@ -276,7 +430,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	isolate_mode_t mode = 0;
 	struct lruvec *lruvec;
 	unsigned long flags;
-	bool locked;
+	bool locked = false;
+	struct page *page = NULL, *valid_page = NULL;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -296,23 +451,15 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 	/* Time to isolate some pages for migration */
 	cond_resched();
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	locked = true;
 	for (; low_pfn < end_pfn; low_pfn++) {
-		struct page *page;
-
 		/* give a chance to irqs before checking need_resched() */
-		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
-			locked = false;
+		if (locked && !((low_pfn+1) % SWAP_CLUSTER_MAX)) {
+			if (should_release_lock(&zone->lru_lock)) {
+				spin_unlock_irqrestore(&zone->lru_lock, flags);
+				locked = false;
+			}
 		}
 
-		/* Check if it is ok to still hold the lock */
-		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
-								locked, cc);
-		if (!locked)
-			break;
-
 		/*
 		 * migrate_pfn does not necessarily start aligned to a
 		 * pageblock. Ensure that pfn_valid is called when moving
@@ -340,6 +487,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		if (page_zone(page) != zone)
 			continue;
 
+		if (!valid_page)
+			valid_page = page;
+
+		/* If isolation recently failed, do not retry */
+		pageblock_nr = low_pfn >> pageblock_order;
+		if (!isolation_suitable(cc, page))
+			goto next_pageblock;
+
 		/* Skip if free */
 		if (PageBuddy(page))
 			continue;
@@ -349,24 +504,43 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		 * migration is optimistic to see if the minimum amount of work
 		 * satisfies the allocation
 		 */
-		pageblock_nr = low_pfn >> pageblock_order;
 		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
-			low_pfn += pageblock_nr_pages;
-			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
-			last_pageblock_nr = pageblock_nr;
-			continue;
+			cc->finished_update_migrate = true;
+			goto next_pageblock;
 		}
 
+		/* Check may be lockless but that's ok as we recheck later */
 		if (!PageLRU(page))
 			continue;
 
 		/*
-		 * PageLRU is set, and lru_lock excludes isolation,
-		 * splitting and collapsing (collapsing has already
-		 * happened if PageLRU is set).
+		 * PageLRU is set. lru_lock normally excludes isolation
+		 * splitting and collapsing (collapsing has already happened
+		 * if PageLRU is set) but the lock is not necessarily taken
+		 * here and it is wasteful to take it just to check transhuge.
+		 * Check TransHuge without lock and skip the whole pageblock if
+		 * it's either a transhuge or hugetlbfs page, as calling
+		 * compound_order() without preventing THP from splitting the
+		 * page underneath us may return surprising results.
 		 */
 		if (PageTransHuge(page)) {
+			if (!locked)
+				goto next_pageblock;
+			low_pfn += (1 << compound_order(page)) - 1;
+			continue;
+		}
+
+		/* Check if it is ok to still hold the lock */
+		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
+								locked, cc);
+		if (!locked || fatal_signal_pending(current))
+			break;
+
+		/* Recheck PageLRU and PageTransHuge under lock */
+		if (!PageLRU(page))
+			continue;
+		if (PageTransHuge(page)) {
 			low_pfn += (1 << compound_order(page)) - 1;
 			continue;
 		}
@@ -383,6 +557,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		VM_BUG_ON(PageTransCompound(page));
 
 		/* Successfully isolated */
+		cc->finished_update_migrate = true;
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
@@ -393,6 +568,13 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			++low_pfn;
 			break;
 		}
+
+		continue;
+
+next_pageblock:
+		low_pfn += pageblock_nr_pages;
+		low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
+		last_pageblock_nr = pageblock_nr;
 	}
 
 	acct_isolated(zone, locked, cc);
@@ -400,6 +582,10 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	if (locked)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
+	/* Update the pageblock-skip if the whole pageblock was scanned */
+	if (low_pfn == end_pfn)
+		update_pageblock_skip(cc, valid_page, nr_isolated, true);
+
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
 	return low_pfn;
@@ -407,43 +593,6 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
-
-/* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
-{
-
-	int migratetype = get_pageblock_migratetype(page);
-
-	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
-	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
-		return false;
-
-	/* If the page is a large free page, then allow migration */
-	if (PageBuddy(page) && page_order(page) >= pageblock_order)
-		return true;
-
-	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(migratetype))
-		return true;
-
-	/* Otherwise skip the block */
-	return false;
-}
-
-/*
- * Returns the start pfn of the last page block in a zone.  This is the starting
- * point for full compaction of a zone.  Compaction searches for free pages from
- * the end of each zone, while isolate_freepages_block scans forward inside each
- * page block.
- */
-static unsigned long start_free_pfn(struct zone *zone)
-{
-	unsigned long free_pfn;
-	free_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	free_pfn &= ~(pageblock_nr_pages-1);
-	return free_pfn;
-}
-
 /*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
@@ -453,7 +602,6 @@ static void isolate_freepages(struct zone *zone,
 {
 	struct page *page;
 	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
-	unsigned long flags;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
@@ -501,30 +649,16 @@ static void isolate_freepages(struct zone *zone,
 		if (!suitable_migration_target(page))
 			continue;
 
-		/*
-		 * Found a block suitable for isolating free pages from. Now
-		 * we disabled interrupts, double check things are ok and
-		 * isolate the pages. This is to minimise the time IRQs
-		 * are disabled
-		 */
-		isolated = 0;
+		/* If isolation recently failed, do not retry */
+		if (!isolation_suitable(cc, page))
+			continue;
 
-		/*
-		 * The zone lock must be held to isolate freepages. This
-		 * unfortunately this is a very coarse lock and can be
-		 * heavily contended if there are parallel allocations
-		 * or parallel compactions. For async compaction do not
-		 * spin on the lock
-		 */
-		if (!compact_trylock_irqsave(&zone->lock, &flags, cc))
-			break;
-		if (suitable_migration_target(page)) {
-			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
-			isolated = isolate_freepages_block(pfn, end_pfn,
-							   freelist, false);
-			nr_freepages += isolated;
-		}
-		spin_unlock_irqrestore(&zone->lock, flags);
+		/* Found a block suitable for isolating free pages from */
+		isolated = 0;
+		end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
+		isolated = isolate_freepages_block(cc, pfn, end_pfn,
+						   freelist, false);
+		nr_freepages += isolated;
 
 		/*
 		 * Record the highest PFN we isolated pages from. When next
@@ -532,17 +666,8 @@ static void isolate_freepages(struct zone *zone,
 		 * page migration may have returned some pages to the allocator
 		 */
 		if (isolated) {
+			cc->finished_update_free = true;
 			high_pfn = max(high_pfn, pfn);
-
-			/*
-			 * If the free scanner has wrapped, update
-			 * compact_cached_free_pfn to point to the highest
-			 * pageblock with free pages. This reduces excessive
-			 * scanning of full pageblocks near the end of the
-			 * zone
-			 */
-			if (cc->order > 0 && cc->wrapped)
-				zone->compact_cached_free_pfn = high_pfn;
 		}
 	}
 
@@ -551,11 +676,6 @@ static void isolate_freepages(struct zone *zone,
 
 	cc->free_pfn = high_pfn;
 	cc->nr_freepages = nr_freepages;
-
-	/* If compact_cached_free_pfn is reset then set it now */
-	if (cc->order > 0 && !cc->wrapped &&
-			zone->compact_cached_free_pfn == start_free_pfn(zone))
-		zone->compact_cached_free_pfn = high_pfn;
 }
 
 /*
@@ -634,7 +754,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
 	/* Perform the isolation */
 	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
-	if (!low_pfn)
+	if (!low_pfn || cc->contended)
 		return ISOLATE_ABORT;
 
 	cc->migrate_pfn = low_pfn;
@@ -651,27 +771,19 @@ static int compact_finished(struct zone *zone,
 	if (fatal_signal_pending(current))
 		return COMPACT_PARTIAL;
 
-	/*
-	 * A full (order == -1) compaction run starts at the beginning and
-	 * end of a zone; it completes when the migrate and free scanner meet.
-	 * A partial (order > 0) compaction can start with the free scanner
-	 * at a random point in the zone, and may have to restart.
-	 */
+	/* Compaction run completes if the migrate and free scanner meet */
 	if (cc->free_pfn <= cc->migrate_pfn) {
-		if (cc->order > 0 && !cc->wrapped) {
-			/* We started partway through; restart at the end. */
-			unsigned long free_pfn = start_free_pfn(zone);
-			zone->compact_cached_free_pfn = free_pfn;
-			cc->free_pfn = free_pfn;
-			cc->wrapped = 1;
-			return COMPACT_CONTINUE;
-		}
-		return COMPACT_COMPLETE;
-	}
+		/*
+		 * Mark that the PG_migrate_skip information should be cleared
+		 * by kswapd when it goes to sleep. kswapd does not set the
+		 * flag itself as the decision to be clear should be directly
+		 * based on an allocation request.
+		 */
+		if (!current_is_kswapd())
+			zone->compact_blockskip_flush = true;
 
-	/* We wrapped around and ended up where we started. */
-	if (cc->wrapped && cc->free_pfn <= cc->start_free_pfn)
 		return COMPACT_COMPLETE;
+	}
 
 	/*
 	 * order == -1 is expected when compacting via
@@ -754,6 +866,8 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 static int compact_zone(struct zone *zone, struct compact_control *cc)
 {
 	int ret;
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
 
 	ret = compaction_suitable(zone, cc->order);
 	switch (ret) {
@@ -766,17 +880,29 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		;
 	}
 
-	/* Setup to move all movable pages to the end of the zone */
-	cc->migrate_pfn = zone->zone_start_pfn;
-
-	if (cc->order > 0) {
-		/* Incremental compaction. Start where the last one stopped. */
-		cc->free_pfn = zone->compact_cached_free_pfn;
-		cc->start_free_pfn = cc->free_pfn;
-	} else {
-		/* Order == -1 starts at the end of the zone. */
-		cc->free_pfn = start_free_pfn(zone);
+	/*
+	 * Setup to move all movable pages to the end of the zone. Used cached
+	 * information on where the scanners should start but check that it
+	 * is initialised by ensuring the values are within zone boundaries.
+	 */
+	cc->migrate_pfn = zone->compact_cached_migrate_pfn;
+	cc->free_pfn = zone->compact_cached_free_pfn;
+	if (cc->free_pfn < start_pfn || cc->free_pfn > end_pfn) {
+		cc->free_pfn = end_pfn & ~(pageblock_nr_pages-1);
+		zone->compact_cached_free_pfn = cc->free_pfn;
 	}
+	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn > end_pfn) {
+		cc->migrate_pfn = start_pfn;
+		zone->compact_cached_migrate_pfn = cc->migrate_pfn;
+	}
+
+	/*
+	 * Clear pageblock skip if there were failures recently and compaction
+	 * is about to be retried after being deferred. kswapd does not do
+	 * this reset as it'll reset the cached information when going to sleep.
+	 */
+	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
+		__reset_isolation_suitable(zone);
 
 	migrate_prep_local();
 
@@ -787,6 +913,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
 			ret = COMPACT_PARTIAL;
+			putback_lru_pages(&cc->migratepages);
+			cc->nr_migratepages = 0;
 			goto out;
 		case ISOLATE_NONE:
 			continue;
@@ -831,6 +959,7 @@ static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
 				 bool sync, bool *contended)
 {
+	unsigned long ret;
 	struct compact_control cc = {
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
@@ -838,12 +967,17 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.sync = sync,
-		.contended = contended,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
-	return compact_zone(zone, &cc);
+	ret = compact_zone(zone, &cc);
+
+	VM_BUG_ON(!list_empty(&cc.freepages));
+	VM_BUG_ON(!list_empty(&cc.migratepages));
+
+	*contended = cc.contended;
+	return ret;
 }
 
 int sysctl_extfrag_threshold = 500;
@@ -855,6 +989,8 @@ int sysctl_extfrag_threshold = 500;
  * @gfp_mask: The GFP mask of the current allocation
  * @nodemask: The allowed nodes to allocate from
  * @sync: Whether migration is synchronous or not
+ * @contended: Return value that is true if compaction was aborted due to lock contention
+ * @page: Optionally capture a free page of the requested order during compaction
  *
  * This is the main entry point for direct page compaction.
  */
diff --git a/mm/internal.h b/mm/internal.h
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -118,23 +118,23 @@ struct compact_control {
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
-	unsigned long start_free_pfn;	/* where we started the search */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	bool sync;			/* Synchronous migration */
-	bool wrapped;			/* Order > 0 compactions are
-					   incremental, once free_pfn
-					   and migrate_pfn meet, we restart
-					   from the top of the zone;
-					   remember we wrapped around. */
+	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
+	bool finished_update_free;	/* True when the zone cached pfns are
+					 * no longer being updated
+					 */
+	bool finished_update_migrate;
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
-	bool *contended;		/* True if a lock was contended */
+	bool contended;			/* True if a lock was contended */
 };
 
 unsigned long
-isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn);
+isolate_freepages_range(struct compact_control *cc,
+			unsigned long start_pfn, unsigned long end_pfn);
 unsigned long
 isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			   unsigned long low_pfn, unsigned long end_pfn);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2131,6 +2131,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
 				preferred_zone, migratetype);
 		if (page) {
+			preferred_zone->compact_blockskip_flush = false;
 			preferred_zone->compact_considered = 0;
 			preferred_zone->compact_defer_shift = 0;
 			if (order >= preferred_zone->compact_order_failed)
@@ -4438,11 +4439,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
-#if defined CONFIG_COMPACTION || defined CONFIG_CMA
-		zone->compact_cached_free_pfn = zone->zone_start_pfn +
-						zone->spanned_pages;
-		zone->compact_cached_free_pfn &= ~(pageblock_nr_pages-1);
-#endif
 #ifdef CONFIG_NUMA
 		zone->node = nid;
 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
@@ -5632,7 +5628,8 @@ __alloc_contig_migrate_alloc(struct page *page, unsigned long private,
 }
 
 /* [start, end) must belong to a single zone. */
-static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
+static int __alloc_contig_migrate_range(struct compact_control *cc,
+					unsigned long start, unsigned long end)
 {
 	/* This function is based on compact_zone() from compaction.c. */
 
@@ -5640,25 +5637,17 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 	unsigned int tries = 0;
 	int ret = 0;
 
-	struct compact_control cc = {
-		.nr_migratepages = 0,
-		.order = -1,
-		.zone = page_zone(pfn_to_page(start)),
-		.sync = true,
-	};
-	INIT_LIST_HEAD(&cc.migratepages);
-
 	migrate_prep_local();
 
-	while (pfn < end || !list_empty(&cc.migratepages)) {
+	while (pfn < end || !list_empty(&cc->migratepages)) {
 		if (fatal_signal_pending(current)) {
 			ret = -EINTR;
 			break;
 		}
 
-		if (list_empty(&cc.migratepages)) {
-			cc.nr_migratepages = 0;
-			pfn = isolate_migratepages_range(cc.zone, &cc,
+		if (list_empty(&cc->migratepages)) {
+			cc->nr_migratepages = 0;
+			pfn = isolate_migratepages_range(cc->zone, cc,
 							 pfn, end);
 			if (!pfn) {
 				ret = -EINTR;
@@ -5670,12 +5659,12 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 			break;
 		}
 
-		ret = migrate_pages(&cc.migratepages,
+		ret = migrate_pages(&cc->migratepages,
 				    __alloc_contig_migrate_alloc,
 				    0, false, MIGRATE_SYNC);
 	}
 
-	putback_lru_pages(&cc.migratepages);
+	putback_lru_pages(&cc->migratepages);
 	return ret > 0 ? 0 : ret;
 }
 
@@ -5754,6 +5743,15 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	unsigned long outer_start, outer_end;
 	int ret = 0, order;
 
+	struct compact_control cc = {
+		.nr_migratepages = 0,
+		.order = -1,
+		.zone = page_zone(pfn_to_page(start)),
+		.sync = true,
+		.ignore_skip_hint = true,
+	};
+	INIT_LIST_HEAD(&cc.migratepages);
+
 	/*
 	 * What we do here is we mark all pageblocks in range as
 	 * MIGRATE_ISOLATE.  Because pageblock and max order pages may
@@ -5783,7 +5781,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	if (ret)
 		goto done;
 
-	ret = __alloc_contig_migrate_range(start, end);
+	ret = __alloc_contig_migrate_range(&cc, start, end);
 	if (ret)
 		goto done;
 
@@ -5832,7 +5830,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	__reclaim_pages(zone, GFP_HIGHUSER_MOVABLE, end-start);
 
 	/* Grab isolated pages from freelists. */
-	outer_end = isolate_freepages_range(outer_start, end);
+	outer_end = isolate_freepages_range(&cc, outer_start, end);
 	if (!outer_end) {
 		ret = -EBUSY;
 		goto done;
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2839,6 +2839,14 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		 */
 		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
 
+		/*
+		 * Compaction records what page blocks it recently failed to
+		 * isolate pages from and skips them in the future scanning.
+		 * When kswapd is going to sleep, it is reasonable to assume
+		 * that pages and compaction may succeed so reset the cache.
+		 */
+		reset_isolation_suitable(pgdat);
+
 		if (!kthread_should_stop())
 			schedule();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
