Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 151506B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 07:02:32 -0400 (EDT)
Date: Fri, 10 Aug 2012 12:02:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/5] Improve hugepage allocation success rates under
 load V3
Message-ID: <20120810110225.GO12690@suse.de>
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
 <5023FE83.4090200@sandia.gov>
 <20120809204630.GJ12690@suse.de>
 <50243BE0.9060007@sandia.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50243BE0.9060007@sandia.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Schutt <jaschut@sandia.gov>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 09, 2012 at 04:38:24PM -0600, Jim Schutt wrote:
> >><SNIP>
> >
> >My conclusion looking at the vmstat data is that everything is looking ok
> >until system CPU usage goes through the roof. I'm assuming that's what we
> >are all still looking at.
> 
> I'm concerned about both the high CPU usage as well as the
> reduction in write-out rate, but I've been assuming the latter
> is caused by the former.
> 

Almost certainly.

> <snip>
> 
> >
> >Ok, this is an untested hack and I expect it would drop allocation success
> >rates again under load (but not as much). Can you test again and see what
> >effect, if any, it has please?
> >
> >---8<---
> >mm: compaction: back out if contended
> >
> >---
> 
> <snip>
> 
> Initial testing with this patch looks very good from
> my perspective; CPU utilization stays reasonable,
> write-out rate stays high, no signs of stress.
> Here's an example after ~10 minutes under my test load:
> 

Excellent, so it is contention that is the problem.

> <SNIP>
> I'll continue testing tomorrow to be sure nothing
> shows up after continued testing.
> 
> If this passes your allocation success rate testing,
> I'm happy with this performance for 3.6 - if not, I'll
> be happy to test any further patches.
> 

It does impair allocation success rates as I expected (they're still ok
but not as high as I'd like) so I implemented the following instead. It
attempts to backoff when contention is detected or compaction is taking
too long. It does not backoff as quickly as the first prototype did so
I'd like to see if it addresses your problem or not.

> I really appreciate getting the chance to test out
> your patchset.
> 

I appreciate that you have a workload that demonstrates the problem and
will test patches. I will not abuse this and hope the keep the revisions
to a minimum.

Thanks.

---8<---
mm: compaction: Abort async compaction if locks are contended or taking too long

Jim Schutt reported a problem that pointed at compaction contending
heavily on locks. The workload is straight-forward and in his own words;

	The systems in question have 24 SAS drives spread across 3 HBAs,
	running 24 Ceph OSD instances, one per drive.  FWIW these servers
	are dual-socket Intel 5675 Xeons w/48 GB memory.  I've got ~160
	Ceph Linux clients doing dd simultaneously to a Ceph file system
	backed by 12 of these servers.

Early in the test everything looks fine

procs -------------------memory------------------ ---swap-- -----io---- --system-- -----cpu-------
 r  b       swpd       free       buff      cache   si   so    bi    bo   in   cs  us sy  id wa st
31 15          0     287216        576   38606628    0    0     2  1158    2   14   1  3  95  0  0
27 15          0     225288        576   38583384    0    0    18 2222016 203357 134876  11 56  17 15  0
28 17          0     219256        576   38544736    0    0    11 2305932 203141 146296  11 49  23 17  0
 6 18          0     215596        576   38552872    0    0     7 2363207 215264 166502  12 45  22 20  0
22 18          0     226984        576   38596404    0    0     3 2445741 223114 179527  12 43  23 22  0

and then it goes to pot

procs -------------------memory------------------ ---swap-- -----io---- --system-- -----cpu-------
 r  b       swpd       free       buff      cache   si   so    bi    bo   in   cs  us sy  id wa st
163  8          0     464308        576   36791368    0    0    11 22210  866  536   3 13  79  4  0
207 14          0     917752        576   36181928    0    0   712 1345376 134598 47367   7 90   1  2  0
123 12          0     685516        576   36296148    0    0   429 1386615 158494 60077   8 84   5  3  0
123 12          0     598572        576   36333728    0    0  1107 1233281 147542 62351   7 84   5  4  0
622  7          0     660768        576   36118264    0    0   557 1345548 151394 59353   7 85   4  3  0
223 11          0     283960        576   36463868    0    0    46 1107160 121846 33006   6 93   1  1  0

Note that system CPU usage is very high blocks being written out has
dropped by 42%. He analysed this with perf and found

  perf record -g -a sleep 10
  perf report --sort symbol --call-graph fractal,5
    34.63%  [k] _raw_spin_lock_irqsave
            |
            |--97.30%-- isolate_freepages
            |          compaction_alloc
            |          unmap_and_move
            |          migrate_pages
            |          compact_zone
            |          compact_zone_order
            |          try_to_compact_pages
            |          __alloc_pages_direct_compact
            |          __alloc_pages_slowpath
            |          __alloc_pages_nodemask
            |          alloc_pages_vma
            |          do_huge_pmd_anonymous_page
            |          handle_mm_fault
            |          do_page_fault
            |          page_fault
            |          |
            |          |--87.39%-- skb_copy_datagram_iovec
            |          |          tcp_recvmsg
            |          |          inet_recvmsg
            |          |          sock_recvmsg
            |          |          sys_recvfrom
            |          |          system_call
            |          |          __recv
            |          |          |
            |          |           --100.00%-- (nil)
            |          |
            |           --12.61%-- memcpy
             --2.70%-- [...]

There was other data but primarily it is all showing that compaction is
contended heavily on the zone->lock and zone->lru_lock.

commit [b2eef8c0: mm: compaction: minimise the time IRQs are disabled
while isolating pages for migration] noted that it was possible for
migration to hold the lru_lock for an excessive amount of time. Very
broadly speaking this patch expands the concept.

This patch introduces compact_checklock_irqsave() to check if a lock
is contended or the process needs to be scheduled. If either condition
is true then async compaction is aborted and the caller is informed.
The page allocator will fail a THP allocation if compaction failed due
to contention. This patch also introduces compact_trylock_irqsave()
which will acquire the lock only if it is not contended and the process
does not need to schedule.

Reported-by: Jim Schutt <jaschut@sandia.gov>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/compaction.h |    4 +-
 mm/compaction.c            |   91 +++++++++++++++++++++++++++++++++++---------
 mm/internal.h              |    1 +
 mm/page_alloc.c            |   13 +++++--
 4 files changed, 84 insertions(+), 25 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 5673459..9c94cba 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -22,7 +22,7 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
-			bool sync, struct page **page);
+			bool sync, bool *contended, struct page **page);
 extern int compact_pgdat(pg_data_t *pgdat, int order);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 
@@ -64,7 +64,7 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync, struct page **page)
+			bool sync, bool *contended, struct page **page)
 {
 	return COMPACT_CONTINUE;
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index c2d0958..1827d9a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -50,6 +50,47 @@ static inline bool migrate_async_suitable(int migratetype)
 	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
 }
 
+/*
+ * Compaction requires the taking of some coarse locks that are potentially
+ * very heavily contended. Check if the process needs to be scheduled or
+ * if the lock is contended. For async compaction, back out in the event
+ * if contention is severe. For sync compaction, schedule.
+ *
+ * Returns true if the lock is held.
+ * Returns false if the lock is released and compaction should abort
+ */
+static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
+				      bool locked, struct compact_control *cc)
+{
+	if (need_resched() || spin_is_contended(lock)) {
+		if (locked) {
+			spin_unlock_irq(lock);
+			locked = false;
+		}
+
+		/* async aborts if taking too long or contended */
+		if (!cc->sync) {
+			if (cc->contended)
+				*cc->contended = true;
+			return false;
+		}
+
+		cond_resched();
+		if (fatal_signal_pending(current))
+			return false;
+	}
+
+	if (!locked)
+		spin_lock_irqsave(lock, *flags);
+	return true;
+}
+
+static inline bool compact_trylock_irqsave(spinlock_t *lock, unsigned long *flags,
+					   struct compact_control *cc)
+{
+	return compact_checklock_irqsave(lock, flags, false, cc);
+}
+
 static void compact_capture_page(struct compact_control *cc)
 {
 	unsigned long flags;
@@ -87,7 +128,8 @@ static void compact_capture_page(struct compact_control *cc)
 				continue;
 
 			/* Take the lock and attempt capture of the page */
-			spin_lock_irqsave(&cc->zone->lock, flags);
+			if (!compact_trylock_irqsave(&cc->zone->lock, &flags, cc))
+				return;
 			if (!list_empty(&area->free_list[mtype])) {
 				page = list_entry(area->free_list[mtype].next,
 							struct page, lru);
@@ -281,6 +323,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	struct list_head *migratelist = &cc->migratepages;
 	isolate_mode_t mode = 0;
 	struct lruvec *lruvec;
+	unsigned long flags;
+	bool locked;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -300,25 +344,22 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 	/* Time to isolate some pages for migration */
 	cond_resched();
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	locked = true;
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
-		bool locked = true;
 
 		/* give a chance to irqs before checking need_resched() */
 		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
-			spin_unlock_irq(&zone->lru_lock);
+			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			locked = false;
 		}
-		if (need_resched() || spin_is_contended(&zone->lru_lock)) {
-			if (locked)
-				spin_unlock_irq(&zone->lru_lock);
-			cond_resched();
-			spin_lock_irq(&zone->lru_lock);
-			if (fatal_signal_pending(current))
-				break;
-		} else if (!locked)
-			spin_lock_irq(&zone->lru_lock);
+
+		/* Check if it is ok to still hold the lock */
+		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
+								locked, cc);
+		if (!locked)
+			break;
 
 		/*
 		 * migrate_pfn does not necessarily start aligned to a
@@ -404,7 +445,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 	acct_isolated(zone, cc);
 
-	spin_unlock_irq(&zone->lru_lock);
+	if (locked)
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
@@ -514,7 +556,16 @@ static void isolate_freepages(struct zone *zone,
 		 * are disabled
 		 */
 		isolated = 0;
-		spin_lock_irqsave(&zone->lock, flags);
+
+		/*
+		 * The zone lock must be held to isolate freepages. This
+		 * unfortunately this is a very coarse lock and can be
+		 * heavily contended if there are parallel allocations
+		 * or parallel compactions. For async compaction do not
+		 * spin on the lock
+		 */
+		if (!compact_trylock_irqsave(&zone->lock, &flags, cc))
+			break;
 		if (suitable_migration_target(page)) {
 			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
 			trace_mm_compaction_freepage_scanpfn(pfn);
@@ -837,8 +888,8 @@ out:
 }
 
 static unsigned long compact_zone_order(struct zone *zone,
-				 int order, gfp_t gfp_mask,
-				 bool sync, struct page **page)
+				 int order, gfp_t gfp_mask, bool sync,
+				 bool *contended, struct page **page)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -848,6 +899,7 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.zone = zone,
 		.sync = sync,
 		.page = page,
+		.contended = contended,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -869,7 +921,7 @@ int sysctl_extfrag_threshold = 500;
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync, struct page **page)
+			bool sync, bool *contended, struct page **page)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -889,7 +941,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 								nodemask) {
 		int status;
 
-		status = compact_zone_order(zone, order, gfp_mask, sync, page);
+		status = compact_zone_order(zone, order, gfp_mask, sync,
+						contended, page);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
diff --git a/mm/internal.h b/mm/internal.h
index 064f6ef..344b555 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -130,6 +130,7 @@ struct compact_control {
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
+	bool *contended;		/* True if a lock was contended */
 	struct page **page;		/* Page captured of requested size */
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 781d6e4..75b30ea 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2086,7 +2086,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
 	int migratetype, bool sync_migration,
-	bool *deferred_compaction,
+	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
@@ -2101,7 +2101,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 	current->flags |= PF_MEMALLOC;
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
-					nodemask, sync_migration, &page);
+					nodemask, sync_migration,
+					contended_compaction, &page);
 	current->flags &= ~PF_MEMALLOC;
 
 	/* If compaction captured a page, prep and use it */
@@ -2154,7 +2155,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
 	int migratetype, bool sync_migration,
-	bool *deferred_compaction,
+	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
 	return NULL;
@@ -2318,6 +2319,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned long did_some_progress;
 	bool sync_migration = false;
 	bool deferred_compaction = false;
+	bool contended_compaction = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -2399,6 +2401,7 @@ rebalance:
 					nodemask,
 					alloc_flags, preferred_zone,
 					migratetype, sync_migration,
+					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
 	if (page)
@@ -2411,7 +2414,8 @@ rebalance:
 	 * has requested the system not be heavily disrupted, fail the
 	 * allocation now instead of entering direct reclaim
 	 */
-	if (deferred_compaction && (gfp_mask & __GFP_NO_KSWAPD))
+	if ((deferred_compaction || contended_compaction) &&
+						(gfp_mask & __GFP_NO_KSWAPD))
 		goto nopage;
 
 	/* Try direct reclaim and then allocating */
@@ -2482,6 +2486,7 @@ rebalance:
 					nodemask,
 					alloc_flags, preferred_zone,
 					migratetype, sync_migration,
+					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
 		if (page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
