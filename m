Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4A3A8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:43:09 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id x15-v6so44613551ite.8
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:43:09 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y13-v6si11859069itb.31.2018.09.10.17.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 17:43:07 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 3/8] mm: convert lru_lock from a spinlock_t to a rwlock_t
Date: Mon, 10 Sep 2018 20:42:35 -0400
Message-Id: <20180911004240.4758-4-daniel.m.jordan@oracle.com>
In-Reply-To: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
References: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, dave.dice@oracle.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, levyossi@icloud.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, steven.sistare@oracle.com, tim.c.chen@intel.com, vdavydov.dev@gmail.com, ying.huang@intel.com

lru_lock is currently a spinlock, which allows only one task at a time
to add or remove pages from any of a node's LRU lists, even if the
pages are in different parts of the same LRU or on different LRUs
altogether.  This bottleneck shows up in memory-intensive database
workloads such as decision support and data warehousing.  In the
artificial benchmark will-it-scale/page_fault1, the lock contributes to
system anti-scaling, so that adding more processes causes less work to
be done.

To prepare for better lru_lock scalability, change lru_lock into a
rwlock_t.  For now, just make all users take the lock as writers.
Later, to allow concurrent operations, change some users to acquire as
readers, which will synchronize amongst themselves in a fine-grained,
per-page way.  This is explained more later.

RW locks are slower than spinlocks.  However, our results show that low
task counts do not significantly regress, even in the stress test
page_fault1, and high task counts enjoy much better scalability.

zone->lock is often taken around the same times as lru_lock and
contributes to this bottleneck.  For the full performance benefits of
this work to be realized, both locks must be fixed, but changing
lru_lock in isolation still allows modest performance improvements and
is one step toward fixing the larger problem.

Remove the spin_is_locked check in lru_add_page_tail.  Unfortunately,
rwlock_t lacks an equivalent and adding one would require 17 new
arch_write_is_locked functions, a heavy price for a single debugging
check.

Yosef Lev had the idea to use a reader-writer lock to split up the code
that lru_lock protects, a form of room synchronization.

Suggested-by: Yosef Lev <levyossi@icloud.com>
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/mmzone.h |  4 +-
 mm/compaction.c        | 99 ++++++++++++++++++++++--------------------
 mm/huge_memory.c       |  6 +--
 mm/memcontrol.c        |  4 +-
 mm/mlock.c             | 10 ++---
 mm/page_alloc.c        |  2 +-
 mm/page_idle.c         |  4 +-
 mm/swap.c              | 44 +++++++++++--------
 mm/vmscan.c            | 42 +++++++++---------
 9 files changed, 112 insertions(+), 103 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6d4c23a3069d..c140aa9290a8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -742,7 +742,7 @@ typedef struct pglist_data {
 
 	/* Write-intensive fields used by page reclaim */
 	ZONE_PADDING(_pad1_)
-	spinlock_t		lru_lock;
+	rwlock_t		lru_lock;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 	/*
@@ -783,7 +783,7 @@ typedef struct pglist_data {
 
 #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
 #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
-static inline spinlock_t *zone_lru_lock(struct zone *zone)
+static inline rwlock_t *zone_lru_lock(struct zone *zone)
 {
 	return &zone->zone_pgdat->lru_lock;
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index 29bd1df18b98..1d3c3f872a19 100644
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
+					   &locked, cc, spin_unlock_irqrestore))
 			break;
 
 		nr_scanned++;
@@ -502,8 +502,9 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 			 * spin on the lock and we acquire the lock as late as
 			 * possible.
 			 */
-			locked = compact_trylock_irqsave(&cc->zone->lock,
-								&flags, cc);
+			locked = compact_trylock(&cc->zone->lock, &flags, cc,
+						 spin_lock_irqsave,
+						 spin_trylock_irqsave);
 			if (!locked)
 				break;
 
@@ -757,8 +758,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * if contended.
 		 */
 		if (!(low_pfn % SWAP_CLUSTER_MAX)
-		    && compact_unlock_should_abort(zone_lru_lock(zone), flags,
-								&locked, cc))
+		    && compact_unlock_should_abort(zone_lru_lock(zone),
+				   flags, &locked, cc, write_unlock_irqrestore))
 			break;
 
 		if (!pfn_valid_within(low_pfn))
@@ -817,8 +818,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			if (unlikely(__PageMovable(page)) &&
 					!PageIsolated(page)) {
 				if (locked) {
-					spin_unlock_irqrestore(zone_lru_lock(zone),
-									flags);
+					write_unlock_irqrestore(
+						    zone_lru_lock(zone), flags);
 					locked = false;
 				}
 
@@ -847,8 +848,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
-			locked = compact_trylock_irqsave(zone_lru_lock(zone),
-								&flags, cc);
+			locked = compact_trylock(zone_lru_lock(zone), &flags,
+						 cc, write_lock_irqsave,
+						 write_trylock_irqsave);
 			if (!locked)
 				break;
 
@@ -912,7 +914,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		if (nr_isolated) {
 			if (locked) {
-				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
+				write_unlock_irqrestore(zone_lru_lock(zone),
+							flags);
 				locked = false;
 			}
 			putback_movable_pages(&cc->migratepages);
@@ -939,7 +942,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		low_pfn = end_pfn;
 
 	if (locked)
-		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
+		write_unlock_irqrestore(zone_lru_lock(zone), flags);
 
 	/*
 	 * Update the pageblock-skip information and cached scanner pfn,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b9f3dbd885bd..6ad045df967d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2453,7 +2453,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 		xa_unlock(&head->mapping->i_pages);
 	}
 
-	spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
+	write_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
 
 	unfreeze_page(head);
 
@@ -2653,7 +2653,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		lru_add_drain();
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irqsave(zone_lru_lock(page_zone(head)), flags);
+	write_lock_irqsave(zone_lru_lock(page_zone(head)), flags);
 
 	if (mapping) {
 		void **pslot;
@@ -2701,7 +2701,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		spin_unlock(&pgdata->split_queue_lock);
 fail:		if (mapping)
 			xa_unlock(&mapping->i_pages);
-		spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
+		write_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
 		unfreeze_page(head);
 		ret = -EBUSY;
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f7f9682482cd..0580aff3bd98 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2043,7 +2043,7 @@ static void lock_page_lru(struct page *page, int *isolated)
 {
 	struct zone *zone = page_zone(page);
 
-	spin_lock_irq(zone_lru_lock(zone));
+	write_lock_irq(zone_lru_lock(zone));
 	if (PageLRU(page)) {
 		struct lruvec *lruvec;
 
@@ -2067,7 +2067,7 @@ static void unlock_page_lru(struct page *page, int isolated)
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 	}
-	spin_unlock_irq(zone_lru_lock(zone));
+	write_unlock_irq(zone_lru_lock(zone));
 }
 
 static void commit_charge(struct page *page, struct mem_cgroup *memcg,
diff --git a/mm/mlock.c b/mm/mlock.c
index 74e5a6547c3d..f3c628e0eeb0 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -194,7 +194,7 @@ unsigned int munlock_vma_page(struct page *page)
 	 * might otherwise copy PageMlocked to part of the tail pages before
 	 * we clear it in the head page. It also stabilizes hpage_nr_pages().
 	 */
-	spin_lock_irq(zone_lru_lock(zone));
+	write_lock_irq(zone_lru_lock(zone));
 
 	if (!TestClearPageMlocked(page)) {
 		/* Potentially, PTE-mapped THP: do not skip the rest PTEs */
@@ -206,14 +206,14 @@ unsigned int munlock_vma_page(struct page *page)
 	__mod_zone_page_state(zone, NR_MLOCK, -nr_pages);
 
 	if (__munlock_isolate_lru_page(page, true)) {
-		spin_unlock_irq(zone_lru_lock(zone));
+		write_unlock_irq(zone_lru_lock(zone));
 		__munlock_isolated_page(page);
 		goto out;
 	}
 	__munlock_isolation_failed(page);
 
 unlock_out:
-	spin_unlock_irq(zone_lru_lock(zone));
+	write_unlock_irq(zone_lru_lock(zone));
 
 out:
 	return nr_pages - 1;
@@ -298,7 +298,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 	pagevec_init(&pvec_putback);
 
 	/* Phase 1: page isolation */
-	spin_lock_irq(zone_lru_lock(zone));
+	write_lock_irq(zone_lru_lock(zone));
 	for (i = 0; i < nr; i++) {
 		struct page *page = pvec->pages[i];
 
@@ -325,7 +325,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 		pvec->pages[i] = NULL;
 	}
 	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
-	spin_unlock_irq(zone_lru_lock(zone));
+	write_unlock_irq(zone_lru_lock(zone));
 
 	/* Now we can release pins of pages that we are not munlocking */
 	pagevec_release(&pvec_putback);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 22320ea27489..ca6620042431 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6222,7 +6222,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	init_waitqueue_head(&pgdat->kcompactd_wait);
 #endif
 	pgdat_page_ext_init(pgdat);
-	spin_lock_init(&pgdat->lru_lock);
+	rwlock_init(&pgdat->lru_lock);
 	lruvec_init(node_lruvec(pgdat));
 
 	pgdat->per_cpu_nodestats = &boot_nodestats;
diff --git a/mm/page_idle.c b/mm/page_idle.c
index e412a63b2b74..60118aa1b1ef 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -42,12 +42,12 @@ static struct page *page_idle_get_page(unsigned long pfn)
 		return NULL;
 
 	zone = page_zone(page);
-	spin_lock_irq(zone_lru_lock(zone));
+	write_lock_irq(zone_lru_lock(zone));
 	if (unlikely(!PageLRU(page))) {
 		put_page(page);
 		page = NULL;
 	}
-	spin_unlock_irq(zone_lru_lock(zone));
+	write_unlock_irq(zone_lru_lock(zone));
 	return page;
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index 219c234d632f..a16ba5194e1c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -63,12 +63,12 @@ static void __page_cache_release(struct page *page)
 		struct lruvec *lruvec;
 		unsigned long flags;
 
-		spin_lock_irqsave(zone_lru_lock(zone), flags);
+		write_lock_irqsave(zone_lru_lock(zone), flags);
 		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 		__ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
-		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
+		write_unlock_irqrestore(zone_lru_lock(zone), flags);
 	}
 	__ClearPageWaiters(page);
 	mem_cgroup_uncharge(page);
@@ -200,17 +200,19 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 		struct pglist_data *pagepgdat = page_pgdat(page);
 
 		if (pagepgdat != pgdat) {
-			if (pgdat)
-				spin_unlock_irqrestore(&pgdat->lru_lock, flags);
+			if (pgdat) {
+				write_unlock_irqrestore(&pgdat->lru_lock,
+							flags);
+			}
 			pgdat = pagepgdat;
-			spin_lock_irqsave(&pgdat->lru_lock, flags);
+			write_lock_irqsave(&pgdat->lru_lock, flags);
 		}
 
 		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 		(*move_fn)(page, lruvec, arg);
 	}
 	if (pgdat)
-		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
+		write_unlock_irqrestore(&pgdat->lru_lock, flags);
 	release_pages(pvec->pages, pvec->nr);
 	pagevec_reinit(pvec);
 }
@@ -336,9 +338,9 @@ void activate_page(struct page *page)
 	struct zone *zone = page_zone(page);
 
 	page = compound_head(page);
-	spin_lock_irq(zone_lru_lock(zone));
+	write_lock_irq(zone_lru_lock(zone));
 	__activate_page(page, mem_cgroup_page_lruvec(page, zone->zone_pgdat), NULL);
-	spin_unlock_irq(zone_lru_lock(zone));
+	write_unlock_irq(zone_lru_lock(zone));
 }
 #endif
 
@@ -735,7 +737,8 @@ void release_pages(struct page **pages, int nr)
 		 * same pgdat. The lock is held only if pgdat != NULL.
 		 */
 		if (locked_pgdat && ++lock_batch == SWAP_CLUSTER_MAX) {
-			spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
+			write_unlock_irqrestore(&locked_pgdat->lru_lock,
+						flags);
 			locked_pgdat = NULL;
 		}
 
@@ -745,8 +748,9 @@ void release_pages(struct page **pages, int nr)
 		/* Device public page can not be huge page */
 		if (is_device_public_page(page)) {
 			if (locked_pgdat) {
-				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
-						       flags);
+				write_unlock_irqrestore(
+						      &locked_pgdat->lru_lock,
+						      flags);
 				locked_pgdat = NULL;
 			}
 			put_zone_device_private_or_public_page(page);
@@ -759,7 +763,9 @@ void release_pages(struct page **pages, int nr)
 
 		if (PageCompound(page)) {
 			if (locked_pgdat) {
-				spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
+				write_unlock_irqrestore(
+						      &locked_pgdat->lru_lock,
+						      flags);
 				locked_pgdat = NULL;
 			}
 			__put_compound_page(page);
@@ -770,12 +776,14 @@ void release_pages(struct page **pages, int nr)
 			struct pglist_data *pgdat = page_pgdat(page);
 
 			if (pgdat != locked_pgdat) {
-				if (locked_pgdat)
-					spin_unlock_irqrestore(&locked_pgdat->lru_lock,
-									flags);
+				if (locked_pgdat) {
+					write_unlock_irqrestore(
+					      &locked_pgdat->lru_lock, flags);
+				}
 				lock_batch = 0;
 				locked_pgdat = pgdat;
-				spin_lock_irqsave(&locked_pgdat->lru_lock, flags);
+				write_lock_irqsave(&locked_pgdat->lru_lock,
+						   flags);
 			}
 
 			lruvec = mem_cgroup_page_lruvec(page, locked_pgdat);
@@ -791,7 +799,7 @@ void release_pages(struct page **pages, int nr)
 		list_add(&page->lru, &pages_to_free);
 	}
 	if (locked_pgdat)
-		spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
+		write_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
 
 	mem_cgroup_uncharge_list(&pages_to_free);
 	free_unref_page_list(&pages_to_free);
@@ -829,8 +837,6 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
 	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
-	VM_BUG_ON(NR_CPUS != 1 &&
-		  !spin_is_locked(&lruvec_pgdat(lruvec)->lru_lock));
 
 	if (!list)
 		SetPageLRU(page_tail);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 730b6d0c6c61..e6f8f05d1bc6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1601,7 +1601,7 @@ int isolate_lru_page(struct page *page)
 		struct zone *zone = page_zone(page);
 		struct lruvec *lruvec;
 
-		spin_lock_irq(zone_lru_lock(zone));
+		write_lock_irq(zone_lru_lock(zone));
 		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
@@ -1610,7 +1610,7 @@ int isolate_lru_page(struct page *page)
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
 		}
-		spin_unlock_irq(zone_lru_lock(zone));
+		write_unlock_irq(zone_lru_lock(zone));
 	}
 	return ret;
 }
@@ -1668,9 +1668,9 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page))) {
-			spin_unlock_irq(&pgdat->lru_lock);
+			write_unlock_irq(&pgdat->lru_lock);
 			putback_lru_page(page);
-			spin_lock_irq(&pgdat->lru_lock);
+			write_lock_irq(&pgdat->lru_lock);
 			continue;
 		}
 
@@ -1691,10 +1691,10 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&pgdat->lru_lock);
+				write_unlock_irq(&pgdat->lru_lock);
 				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&pgdat->lru_lock);
+				write_lock_irq(&pgdat->lru_lock);
 			} else
 				list_add(&page->lru, &pages_to_free);
 		}
@@ -1755,7 +1755,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
 
-	spin_lock_irq(&pgdat->lru_lock);
+	write_lock_irq(&pgdat->lru_lock);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
@@ -1774,7 +1774,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
 				   nr_scanned);
 	}
-	spin_unlock_irq(&pgdat->lru_lock);
+	write_unlock_irq(&pgdat->lru_lock);
 
 	if (nr_taken == 0)
 		return 0;
@@ -1782,7 +1782,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, 0,
 				&stat, false);
 
-	spin_lock_irq(&pgdat->lru_lock);
+	write_lock_irq(&pgdat->lru_lock);
 
 	if (current_is_kswapd()) {
 		if (global_reclaim(sc))
@@ -1800,7 +1800,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 
-	spin_unlock_irq(&pgdat->lru_lock);
+	write_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&page_list);
 	free_unref_page_list(&page_list);
@@ -1880,10 +1880,10 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
-				spin_unlock_irq(&pgdat->lru_lock);
+				write_unlock_irq(&pgdat->lru_lock);
 				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
-				spin_lock_irq(&pgdat->lru_lock);
+				write_lock_irq(&pgdat->lru_lock);
 			} else
 				list_add(&page->lru, pages_to_free);
 		} else {
@@ -1923,7 +1923,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
 
-	spin_lock_irq(&pgdat->lru_lock);
+	write_lock_irq(&pgdat->lru_lock);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
@@ -1934,7 +1934,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__count_vm_events(PGREFILL, nr_scanned);
 	count_memcg_events(lruvec_memcg(lruvec), PGREFILL, nr_scanned);
 
-	spin_unlock_irq(&pgdat->lru_lock);
+	write_unlock_irq(&pgdat->lru_lock);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1979,7 +1979,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&pgdat->lru_lock);
+	write_lock_irq(&pgdat->lru_lock);
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1991,7 +1991,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
 	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&pgdat->lru_lock);
+	write_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_hold);
 	free_unref_page_list(&l_hold);
@@ -2235,7 +2235,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, MAX_NR_ZONES) +
 		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, MAX_NR_ZONES);
 
-	spin_lock_irq(&pgdat->lru_lock);
+	write_lock_irq(&pgdat->lru_lock);
 	recent_scanned[0] = atomic_long_read(&rstat->recent_scanned[0]);
 	recent_rotated[0] = atomic_long_read(&rstat->recent_rotated[0]);
 	if (unlikely(recent_scanned[0] > anon / 4)) {
@@ -2264,7 +2264,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 
 	fp = file_prio * (recent_scanned[1] + 1);
 	fp /= recent_rotated[1] + 1;
-	spin_unlock_irq(&pgdat->lru_lock);
+	write_unlock_irq(&pgdat->lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3998,9 +3998,9 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 		pgscanned++;
 		if (pagepgdat != pgdat) {
 			if (pgdat)
-				spin_unlock_irq(&pgdat->lru_lock);
+				write_unlock_irq(&pgdat->lru_lock);
 			pgdat = pagepgdat;
-			spin_lock_irq(&pgdat->lru_lock);
+			write_lock_irq(&pgdat->lru_lock);
 		}
 		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
@@ -4021,7 +4021,7 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 	if (pgdat) {
 		__count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
 		__count_vm_events(UNEVICTABLE_PGSCANNED, pgscanned);
-		spin_unlock_irq(&pgdat->lru_lock);
+		write_unlock_irq(&pgdat->lru_lock);
 	}
 }
 #endif /* CONFIG_SHMEM */
-- 
2.18.0
