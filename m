Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id CC7596B002B
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 16:46:35 -0400 (EDT)
Date: Thu, 9 Aug 2012 21:46:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/5] Improve hugepage allocation success rates under
 load V3
Message-ID: <20120809204630.GJ12690@suse.de>
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
 <5023FE83.4090200@sandia.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5023FE83.4090200@sandia.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Schutt <jaschut@sandia.gov>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 09, 2012 at 12:16:35PM -0600, Jim Schutt wrote:
> On 08/09/2012 07:49 AM, Mel Gorman wrote:
> >Changelog since V2
> >o Capture !MIGRATE_MOVABLE pages where possible
> >o Document the treatment of MIGRATE_MOVABLE pages while capturing
> >o Expand changelogs
> >
> >Changelog since V1
> >o Dropped kswapd related patch, basically a no-op and regresses if fixed (minchan)
> >o Expanded changelogs a little
> >
> >Allocation success rates have been far lower since 3.4 due to commit
> >[fe2c2a10: vmscan: reclaim at order 0 when compaction is enabled]. This
> >commit was introduced for good reasons and it was known in advance that
> >the success rates would suffer but it was justified on the grounds that
> >the high allocation success rates were achieved by aggressive reclaim.
> >Success rates are expected to suffer even more in 3.6 due to commit
> >[7db8889a: mm: have order>  0 compaction start off where it left] which
> >testing has shown to severely reduce allocation success rates under load -
> >to 0% in one case.  There is a proposed change to that patch in this series
> >and it would be ideal if Jim Schutt could retest the workload that led to
> >commit [7db8889a: mm: have order>  0 compaction start off where it left].
> 
> On my first test of this patch series on top of 3.5, I ran into an
> instance of what I think is the sort of thing that patch 4/5 was
> fixing.  Here's what vmstat had to say during that period:
> 
> <SNIP>

My conclusion looking at the vmstat data is that everything is looking ok
until system CPU usage goes through the roof. I'm assuming that's what we
are all still looking at.

I am still concerned that what patch 4/5 was actually doing was bypassing
compaction almost entirely in the contended case which "works" but not
exactly expected

> And here's a perf report, captured/displayed with
>   perf record -g -a sleep 10
>   perf report --sort symbol --call-graph fractal,5
> sometime during that period just after 12:00:09, when
> the run queueu was > 100.
> 
> ----------
> 
> Processed 0 events and LOST 1175296!
> 
> <SNIP>
> #
>     34.63%  [k] _raw_spin_lock_irqsave
>             |
>             |--97.30%-- isolate_freepages
>             |          compaction_alloc
>             |          unmap_and_move
>             |          migrate_pages
>             |          compact_zone
>             |          compact_zone_order
>             |          try_to_compact_pages
>             |          __alloc_pages_direct_compact
>             |          __alloc_pages_slowpath
>             |          __alloc_pages_nodemask
>             |          alloc_pages_vma
>             |          do_huge_pmd_anonymous_page
>             |          handle_mm_fault
>             |          do_page_fault
>             |          page_fault
>             |          |
>             |          |--87.39%-- skb_copy_datagram_iovec
>             |          |          tcp_recvmsg
>             |          |          inet_recvmsg
>             |          |          sock_recvmsg
>             |          |          sys_recvfrom
>             |          |          system_call
>             |          |          __recv
>             |          |          |
>             |          |           --100.00%-- (nil)
>             |          |
>             |           --12.61%-- memcpy
>              --2.70%-- [...]

So lets just consider this. My interpretation of that is that we are
receiving data from the network and copying it into a buffer that is
faulted for the first time and backed by THP.

All good so far *BUT* we are contending like crazy on the zone lock and
probably blocking normal page allocations in the meantime.

> 
>     14.31%  [k] _raw_spin_lock_irq
>             |
>             |--98.08%-- isolate_migratepages_range

This is a variation of the same problem but on the LRU lock this time.

> <SNIP>
> 
> ----------
> 
> If I understand what this is telling me, skb_copy_datagram_iovec
> is responsible for triggering the calls to isolate_freepages_block,
> isolate_migratepages_range, and isolate_freepages?
> 

Sortof. I do not think it's the jumbo frames that are doing it, it's the
faulting of the buffer it copies to.

> FWIW, I'm using a Chelsio T4 NIC in these hosts, with jumbo frames
> and the Linux TCP stack (i.e., no stateful TCP offload).
> 

Ok, this is an untested hack and I expect it would drop allocation success
rates again under load (but not as much). Can you test again and see what
effect, if any, it has please?

---8<---
mm: compaction: back out if contended

---
 include/linux/compaction.h |    4 ++--
 mm/compaction.c            |   45 ++++++++++++++++++++++++++++++++++++++------
 mm/internal.h              |    1 +
 mm/page_alloc.c            |   13 +++++++++----
 4 files changed, 51 insertions(+), 12 deletions(-)

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
index c2d0958..8e290d2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -50,6 +50,27 @@ static inline bool migrate_async_suitable(int migratetype)
 	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
 }
 
+/*
+ * Compaction requires the taking of some coarse locks that are potentially
+ * very heavily contended. For async compaction, back out in the event there
+ * is contention.
+ */
+static bool compact_trylock_irqsave(spinlock_t *lock, unsigned long *flags,
+				    struct compact_control *cc)
+{
+	if (cc->sync) {
+		spin_lock_irqsave(lock, *flags);
+	} else {
+		if (!spin_trylock_irqsave(lock, *flags)) {
+			if (cc->contended)
+				*cc->contended = true;
+			return false;
+		}
+	}
+
+	return true;
+}
+
 static void compact_capture_page(struct compact_control *cc)
 {
 	unsigned long flags;
@@ -87,7 +108,8 @@ static void compact_capture_page(struct compact_control *cc)
 				continue;
 
 			/* Take the lock and attempt capture of the page */
-			spin_lock_irqsave(&cc->zone->lock, flags);
+			if (!compact_trylock_irqsave(&cc->zone->lock, &flags, cc))
+				return;
 			if (!list_empty(&area->free_list[mtype])) {
 				page = list_entry(area->free_list[mtype].next,
 							struct page, lru);
@@ -514,7 +536,16 @@ static void isolate_freepages(struct zone *zone,
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
@@ -837,8 +868,8 @@ out:
 }
 
 static unsigned long compact_zone_order(struct zone *zone,
-				 int order, gfp_t gfp_mask,
-				 bool sync, struct page **page)
+				 int order, gfp_t gfp_mask, bool sync,
+				 bool *contended, struct page **page)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -848,6 +879,7 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.zone = zone,
 		.sync = sync,
 		.page = page,
+		.contended = contended,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -869,7 +901,7 @@ int sysctl_extfrag_threshold = 500;
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync, struct page **page)
+			bool sync, bool *contended, struct page **page)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -889,7 +921,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
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
