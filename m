Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9F08E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 01:36:33 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 33-v6so11055983plf.19
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 22:36:33 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c19-v6si20646945pfc.18.2018.09.10.22.36.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 22:36:31 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH 4/9] mm: convert zone lock from spinlock to rwlock
Date: Tue, 11 Sep 2018 13:36:11 +0800
Message-Id: <20180911053616.6894-5-aaron.lu@intel.com>
In-Reply-To: <20180911053616.6894-1-aaron.lu@intel.com>
References: <20180911053616.6894-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Yosef Lev <levyossi@icloud.com>, Jesper Dangaard Brouer <brouer@redhat.com>

This patch converts zone lock from spinlock to rwlock and always
take the lock in write mode so there is no functionality change.

This is a preparation for free path to take the lock in read mode
to make free path work concurrently.

compact_trylock and compact_unlock_should_abort are taken from
Daniel Jordan's patch.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 include/linux/mmzone.h |  2 +-
 mm/compaction.c        | 90 +++++++++++++++++++++---------------------
 mm/hugetlb.c           |  8 ++--
 mm/page_alloc.c        | 52 ++++++++++++------------
 mm/page_isolation.c    | 12 +++---
 mm/vmstat.c            |  4 +-
 6 files changed, 85 insertions(+), 83 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1e22d96734e0..84cfa56e2d19 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -465,7 +465,7 @@ struct zone {
 	unsigned long		flags;
 
 	/* Primarily protects free_area */
-	spinlock_t		lock;
+	rwlock_t		lock;
 
 	/* Write-intensive fields used by compaction and vmstats. */
 	ZONE_PADDING(_pad2_)
diff --git a/mm/compaction.c b/mm/compaction.c
index faca45ebe62d..6ecf74d8e287 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -347,20 +347,20 @@ static inline void update_pageblock_skip(struct compact_control *cc,
  * Returns true if the lock is held
  * Returns false if the lock is not held and compaction should abort
  */
-static bool compact_trylock_irqsave(spinlock_t *lock, unsigned long *flags,
-						struct compact_control *cc)
-{
-	if (cc->mode == MIGRATE_ASYNC) {
-		if (!spin_trylock_irqsave(lock, *flags)) {
-			cc->contended = true;
-			return false;
-		}
-	} else {
-		spin_lock_irqsave(lock, *flags);
-	}
-
-	return true;
-}
+#define compact_trylock(lock, flags, cc, lockf, trylockf)		       \
+({									       \
+	bool __ret = true;						       \
+	if ((cc)->mode == MIGRATE_ASYNC) {				       \
+		if (!trylockf((lock), *(flags))) {			       \
+			(cc)->contended = true;				       \
+			__ret = false;					       \
+		}							       \
+	} else {							       \
+		lockf((lock), *(flags));				       \
+	}								       \
+									       \
+	__ret;								       \
+})
 
 /*
  * Compaction requires the taking of some coarse locks that are potentially
@@ -377,29 +377,29 @@ static bool compact_trylock_irqsave(spinlock_t *lock, unsigned long *flags,
  * Returns false when compaction can continue (sync compaction might have
  *		scheduled)
  */
-static bool compact_unlock_should_abort(spinlock_t *lock,
-		unsigned long flags, bool *locked, struct compact_control *cc)
-{
-	if (*locked) {
-		spin_unlock_irqrestore(lock, flags);
-		*locked = false;
-	}
-
-	if (fatal_signal_pending(current)) {
-		cc->contended = true;
-		return true;
-	}
-
-	if (need_resched()) {
-		if (cc->mode == MIGRATE_ASYNC) {
-			cc->contended = true;
-			return true;
-		}
-		cond_resched();
-	}
-
-	return false;
-}
+#define compact_unlock_should_abort(lock, flags, locked, cc, unlockf)	       \
+({									       \
+	bool __ret = false;						       \
+									       \
+	if (*(locked)) {						       \
+		unlockf((lock), (flags));				       \
+		*(locked) = false;					       \
+	}								       \
+									       \
+	if (fatal_signal_pending(current)) {				       \
+		(cc)->contended = true;					       \
+		__ret = true;						       \
+	} else if (need_resched()) {					       \
+		if ((cc)->mode == MIGRATE_ASYNC) {			       \
+			(cc)->contended = true;				       \
+			__ret = true;					       \
+		} else {						       \
+			cond_resched();					       \
+		}							       \
+	}								       \
+									       \
+	__ret;								       \
+})
 
 /*
  * Aside from avoiding lock contention, compaction also periodically checks
@@ -457,7 +457,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		 */
 		if (!(blockpfn % SWAP_CLUSTER_MAX)
 		    && compact_unlock_should_abort(&cc->zone->lock, flags,
-								&locked, cc))
+					&locked, cc, write_unlock_irqrestore))
 			break;
 
 		nr_scanned++;
@@ -502,8 +502,9 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 			 * spin on the lock and we acquire the lock as late as
 			 * possible.
 			 */
-			locked = compact_trylock_irqsave(&cc->zone->lock,
-								&flags, cc);
+			locked = compact_trylock(&cc->zone->lock, &flags, cc,
+						 write_lock_irqsave,
+						 write_trylock_irqsave);
 			if (!locked)
 				break;
 
@@ -541,7 +542,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	}
 
 	if (locked)
-		spin_unlock_irqrestore(&cc->zone->lock, flags);
+		write_unlock_irqrestore(&cc->zone->lock, flags);
 
 	/*
 	 * There is a tiny chance that we have read bogus compound_order(),
@@ -758,7 +759,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		if (!(low_pfn % SWAP_CLUSTER_MAX)
 		    && compact_unlock_should_abort(zone_lru_lock(zone), flags,
-								&locked, cc))
+					&locked, cc, spin_unlock_irqrestore))
 			break;
 
 		if (!pfn_valid_within(low_pfn))
@@ -847,8 +848,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
-			locked = compact_trylock_irqsave(zone_lru_lock(zone),
-								&flags, cc);
+			locked = compact_trylock(zone_lru_lock(zone), &flags, cc,
+						 spin_lock_irqsave,
+						 spin_trylock_irqsave);
 			if (!locked)
 				break;
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3c21775f196b..18fde0139f4a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1113,7 +1113,7 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 
 	zonelist = node_zonelist(nid, gfp_mask);
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), nodemask) {
-		spin_lock_irqsave(&zone->lock, flags);
+		write_lock_irqsave(&zone->lock, flags);
 
 		pfn = ALIGN(zone->zone_start_pfn, nr_pages);
 		while (zone_spans_last_pfn(zone, pfn, nr_pages)) {
@@ -1125,16 +1125,16 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 				 * spinning on this lock, it may win the race
 				 * and cause alloc_contig_range() to fail...
 				 */
-				spin_unlock_irqrestore(&zone->lock, flags);
+				write_unlock_irqrestore(&zone->lock, flags);
 				ret = __alloc_gigantic_page(pfn, nr_pages, gfp_mask);
 				if (!ret)
 					return pfn_to_page(pfn);
-				spin_lock_irqsave(&zone->lock, flags);
+				write_lock_irqsave(&zone->lock, flags);
 			}
 			pfn += nr_pages;
 		}
 
-		spin_unlock_irqrestore(&zone->lock, flags);
+		write_unlock_irqrestore(&zone->lock, flags);
 	}
 
 	return NULL;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 05e983f42316..38e39ccdd6d9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1133,7 +1133,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		} while (--count && --batch_free && !list_empty(list));
 	}
 
-	spin_lock(&zone->lock);
+	write_lock(&zone->lock);
 	isolated_pageblocks = has_isolate_pageblock(zone);
 
 	/*
@@ -1151,7 +1151,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		__free_one_page(page, page_to_pfn(page), zone, 0, mt);
 		trace_mm_page_pcpu_drain(page, 0, mt);
 	}
-	spin_unlock(&zone->lock);
+	write_unlock(&zone->lock);
 }
 
 static void free_one_page(struct zone *zone,
@@ -1159,13 +1159,13 @@ static void free_one_page(struct zone *zone,
 				unsigned int order,
 				int migratetype)
 {
-	spin_lock(&zone->lock);
+	write_lock(&zone->lock);
 	if (unlikely(has_isolate_pageblock(zone) ||
 		is_migrate_isolate(migratetype))) {
 		migratetype = get_pfnblock_migratetype(page, pfn);
 	}
 	__free_one_page(page, pfn, zone, order, migratetype);
-	spin_unlock(&zone->lock);
+	write_unlock(&zone->lock);
 }
 
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
@@ -2251,7 +2251,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 	if (zone->nr_reserved_highatomic >= max_managed)
 		return;
 
-	spin_lock_irqsave(&zone->lock, flags);
+	write_lock_irqsave(&zone->lock, flags);
 
 	/* Recheck the nr_reserved_highatomic limit under the lock */
 	if (zone->nr_reserved_highatomic >= max_managed)
@@ -2267,7 +2267,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 	}
 
 out_unlock:
-	spin_unlock_irqrestore(&zone->lock, flags);
+	write_unlock_irqrestore(&zone->lock, flags);
 }
 
 /*
@@ -2300,7 +2300,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 					pageblock_nr_pages)
 			continue;
 
-		spin_lock_irqsave(&zone->lock, flags);
+		write_lock_irqsave(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
 			struct free_area *area = &(zone->free_area[order]);
 
@@ -2343,11 +2343,11 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 			ret = move_freepages_block(zone, page, ac->migratetype,
 									NULL);
 			if (ret) {
-				spin_unlock_irqrestore(&zone->lock, flags);
+				write_unlock_irqrestore(&zone->lock, flags);
 				return ret;
 			}
 		}
-		spin_unlock_irqrestore(&zone->lock, flags);
+		write_unlock_irqrestore(&zone->lock, flags);
 	}
 
 	return false;
@@ -2465,7 +2465,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 {
 	int i, alloced = 0;
 
-	spin_lock(&zone->lock);
+	write_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
 		struct page *page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
@@ -2498,7 +2498,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 	 * pages added to the pcp list.
 	 */
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
-	spin_unlock(&zone->lock);
+	write_unlock(&zone->lock);
 	return alloced;
 }
 
@@ -2687,7 +2687,7 @@ void mark_free_pages(struct zone *zone)
 	if (zone_is_empty(zone))
 		return;
 
-	spin_lock_irqsave(&zone->lock, flags);
+	write_lock_irqsave(&zone->lock, flags);
 
 	max_zone_pfn = zone_end_pfn(zone);
 	for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
@@ -2721,7 +2721,7 @@ void mark_free_pages(struct zone *zone)
 			}
 		}
 	}
-	spin_unlock_irqrestore(&zone->lock, flags);
+	write_unlock_irqrestore(&zone->lock, flags);
 }
 #endif /* CONFIG_PM */
 
@@ -2990,7 +2990,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 	 * allocate greater than order-1 page units with __GFP_NOFAIL.
 	 */
 	WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));
-	spin_lock_irqsave(&zone->lock, flags);
+	write_lock_irqsave(&zone->lock, flags);
 
 	do {
 		page = NULL;
@@ -3002,7 +3002,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 		if (!page)
 			page = __rmqueue(zone, order, migratetype);
 	} while (page && check_new_pages(page, order));
-	spin_unlock(&zone->lock);
+	write_unlock(&zone->lock);
 	if (!page)
 		goto failed;
 	__mod_zone_freepage_state(zone, -(1 << order),
@@ -5009,7 +5009,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		show_node(zone);
 		printk(KERN_CONT "%s: ", zone->name);
 
-		spin_lock_irqsave(&zone->lock, flags);
+		write_lock_irqsave(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
 			struct free_area *area = &zone->free_area[order];
 			int type;
@@ -5023,7 +5023,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 					types[order] |= 1 << type;
 			}
 		}
-		spin_unlock_irqrestore(&zone->lock, flags);
+		write_unlock_irqrestore(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
 			printk(KERN_CONT "%lu*%lukB ",
 			       nr[order], K(1UL) << order);
@@ -6247,7 +6247,7 @@ static void __meminit zone_init_internals(struct zone *zone, enum zone_type idx,
 	zone_set_nid(zone, nid);
 	zone->name = zone_names[idx];
 	zone->zone_pgdat = NODE_DATA(nid);
-	spin_lock_init(&zone->lock);
+	rwlock_init(&zone->lock);
 	zone_seqlock_init(zone);
 	zone_pcp_init(zone);
 }
@@ -7239,7 +7239,7 @@ static void __setup_per_zone_wmarks(void)
 	for_each_zone(zone) {
 		u64 tmp;
 
-		spin_lock_irqsave(&zone->lock, flags);
+		write_lock_irqsave(&zone->lock, flags);
 		tmp = (u64)pages_min * zone->managed_pages;
 		do_div(tmp, lowmem_pages);
 		if (is_highmem(zone)) {
@@ -7277,7 +7277,7 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
 
-		spin_unlock_irqrestore(&zone->lock, flags);
+		write_unlock_irqrestore(&zone->lock, flags);
 	}
 
 	/* update totalreserve_pages */
@@ -8041,7 +8041,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		return;
 	offline_mem_sections(pfn, end_pfn);
 	zone = page_zone(pfn_to_page(pfn));
-	spin_lock_irqsave(&zone->lock, flags);
+	write_lock_irqsave(&zone->lock, flags);
 	pfn = start_pfn;
 	while (pfn < end_pfn) {
 		if (!pfn_valid(pfn)) {
@@ -8073,7 +8073,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
 	}
-	spin_unlock_irqrestore(&zone->lock, flags);
+	write_unlock_irqrestore(&zone->lock, flags);
 }
 #endif
 
@@ -8084,14 +8084,14 @@ bool is_free_buddy_page(struct page *page)
 	unsigned long flags;
 	unsigned int order;
 
-	spin_lock_irqsave(&zone->lock, flags);
+	write_lock_irqsave(&zone->lock, flags);
 	for (order = 0; order < MAX_ORDER; order++) {
 		struct page *page_head = page - (pfn & ((1 << order) - 1));
 
 		if (PageBuddy(page_head) && page_order(page_head) >= order)
 			break;
 	}
-	spin_unlock_irqrestore(&zone->lock, flags);
+	write_unlock_irqrestore(&zone->lock, flags);
 
 	return order < MAX_ORDER;
 }
@@ -8110,7 +8110,7 @@ bool set_hwpoison_free_buddy_page(struct page *page)
 	unsigned int order;
 	bool hwpoisoned = false;
 
-	spin_lock_irqsave(&zone->lock, flags);
+	write_lock_irqsave(&zone->lock, flags);
 	for (order = 0; order < MAX_ORDER; order++) {
 		struct page *page_head = page - (pfn & ((1 << order) - 1));
 
@@ -8120,7 +8120,7 @@ bool set_hwpoison_free_buddy_page(struct page *page)
 			break;
 		}
 	}
-	spin_unlock_irqrestore(&zone->lock, flags);
+	write_unlock_irqrestore(&zone->lock, flags);
 
 	return hwpoisoned;
 }
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 43e085608846..5c99fc2a1616 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -26,7 +26,7 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
 
 	zone = page_zone(page);
 
-	spin_lock_irqsave(&zone->lock, flags);
+	write_lock_irqsave(&zone->lock, flags);
 
 	/*
 	 * We assume the caller intended to SET migrate type to isolate.
@@ -82,7 +82,7 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
 		__mod_zone_freepage_state(zone, -nr_pages, mt);
 	}
 
-	spin_unlock_irqrestore(&zone->lock, flags);
+	write_unlock_irqrestore(&zone->lock, flags);
 	if (!ret)
 		drain_all_pages(zone);
 	return ret;
@@ -98,7 +98,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	struct page *buddy;
 
 	zone = page_zone(page);
-	spin_lock_irqsave(&zone->lock, flags);
+	write_lock_irqsave(&zone->lock, flags);
 	if (!is_migrate_isolate_page(page))
 		goto out;
 
@@ -137,7 +137,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	set_pageblock_migratetype(page, migratetype);
 	zone->nr_isolate_pageblock--;
 out:
-	spin_unlock_irqrestore(&zone->lock, flags);
+	write_unlock_irqrestore(&zone->lock, flags);
 	if (isolated_page) {
 		post_alloc_hook(page, order, __GFP_MOVABLE);
 		__free_pages(page, order);
@@ -299,10 +299,10 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 		return -EBUSY;
 	/* Check all pages are free or marked as ISOLATED */
 	zone = page_zone(page);
-	spin_lock_irqsave(&zone->lock, flags);
+	write_lock_irqsave(&zone->lock, flags);
 	pfn = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
 						skip_hwpoisoned_pages);
-	spin_unlock_irqrestore(&zone->lock, flags);
+	write_unlock_irqrestore(&zone->lock, flags);
 
 	trace_test_pages_isolated(start_pfn, end_pfn, pfn);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 8ba0870ecddd..06d79271a8ae 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1337,10 +1337,10 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 			continue;
 
 		if (!nolock)
-			spin_lock_irqsave(&zone->lock, flags);
+			write_lock_irqsave(&zone->lock, flags);
 		print(m, pgdat, zone);
 		if (!nolock)
-			spin_unlock_irqrestore(&zone->lock, flags);
+			write_unlock_irqrestore(&zone->lock, flags);
 	}
 }
 #endif
-- 
2.17.1
