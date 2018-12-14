Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Fri, 14 Dec 2018 23:05:45 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 13/14] mm, compaction: Capture a page under direct compaction
Message-ID: <20181214230545.GD29005@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181214230310.572-1-mgorman@techsingularity.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Compaction is inherently race-prone as a suitable page freed during compaction
can be allocated by any parallel task. This patch uses a capture_control
structure to isolate a page immediately when it is freed by a direct compactor
in the slow path of the page allocator.

                                    4.20.0-rc6             4.20.0-rc6
                                 findfree-v1r8           capture-v1r8
Amean     fault-both-3      2911.07 (   0.00%)     2898.64 (   0.43%)
Amean     fault-both-5      4692.96 (   0.00%)     4296.58 (   8.45%)
Amean     fault-both-7      6449.17 (   0.00%)     6203.55 (   3.81%)
Amean     fault-both-12     9778.40 (   0.00%)     9309.13 (   4.80%)
Amean     fault-both-18    11756.92 (   0.00%)     6245.27 *  46.88%*
Amean     fault-both-24    13675.93 (   0.00%)    15083.42 ( -10.29%)
Amean     fault-both-30    17195.41 (   0.00%)    11498.60 *  33.13%*
Amean     fault-both-32    18150.08 (   0.00%)     9684.82 *  46.64%*

As expected, the biggest reduction in latency is when there are multiple
compaction instances that would previously compete for the same blocks.
THP allocation rates are also slightly higher.

                               4.20.0-rc6             4.20.0-rc6
                            findfree-v1r8           capture-v1r8
Percentage huge-1         0.00 (   0.00%)        0.00 (   0.00%)
Percentage huge-3        97.63 (   0.00%)       98.12 (   0.49%)
Percentage huge-5        96.11 (   0.00%)       98.83 (   2.84%)
Percentage huge-7        95.44 (   0.00%)       97.99 (   2.68%)
Percentage huge-12       95.36 (   0.00%)       99.00 (   3.82%)
Percentage huge-18       95.32 (   0.00%)       98.92 (   3.78%)
Percentage huge-24       95.13 (   0.00%)       99.08 (   4.15%)
Percentage huge-30       95.53 (   0.00%)       99.22 (   3.86%)
Percentage huge-32       94.94 (   0.00%)       98.97 (   4.25%)

And scan rates are reduced

Compaction migrate scanned    27634284    19002941
Compaction free scanned       55279519    46395714

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/compaction.h |  3 ++-
 include/linux/sched.h      |  4 ++++
 kernel/sched/core.c        |  3 +++
 mm/compaction.c            | 31 +++++++++++++++++++------
 mm/internal.h              |  9 +++++++
 mm/page_alloc.c            | 58 ++++++++++++++++++++++++++++++++++++++++++----
 6 files changed, 96 insertions(+), 12 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 68250a57aace..b0d530cf46d1 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -95,7 +95,8 @@ extern int sysctl_compact_unevictable_allowed;
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern enum compact_result try_to_compact_pages(gfp_t gfp_mask,
 		unsigned int order, unsigned int alloc_flags,
-		const struct alloc_context *ac, enum compact_priority prio);
+		const struct alloc_context *ac, enum compact_priority prio,
+		struct page **page);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern enum compact_result compaction_suitable(struct zone *zone, int order,
 		unsigned int alloc_flags, int classzone_idx);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8681905589f0..f1758ef4d1e2 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -47,6 +47,7 @@ struct pid_namespace;
 struct pipe_inode_info;
 struct rcu_node;
 struct reclaim_state;
+struct capture_control;
 struct robust_list_head;
 struct sched_attr;
 struct sched_param;
@@ -964,6 +965,9 @@ struct task_struct {
 
 	struct io_context		*io_context;
 
+#ifdef CONFIG_COMPACTION
+	struct capture_control		*capture_control;
+#endif
 	/* Ptrace state: */
 	unsigned long			ptrace_message;
 	kernel_siginfo_t		*last_siginfo;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 5f41fd2e0b6b..cd6d816aa40b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2177,6 +2177,9 @@ static void __sched_fork(unsigned long clone_flags, struct task_struct *p)
 	INIT_HLIST_HEAD(&p->preempt_notifiers);
 #endif
 
+#ifdef CONFIG_COMPACTION
+	p->capture_control = NULL;
+#endif
 	init_numa_balancing(clone_flags, p);
 }
 
diff --git a/mm/compaction.c b/mm/compaction.c
index ba3035dcc548..39d33b6d1172 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1949,7 +1949,8 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 	return false;
 }
 
-static enum compact_result compact_zone(struct compact_control *cc)
+static enum compact_result
+compact_zone(struct compact_control *cc, struct capture_control *capc)
 {
 	enum compact_result ret;
 	unsigned long start_pfn = cc->zone->zone_start_pfn;
@@ -2086,6 +2087,11 @@ static enum compact_result compact_zone(struct compact_control *cc)
 			}
 		}
 
+		/* Stop if a page has been captured */
+		if (capc && capc->page) {
+			ret = COMPACT_SUCCESS;
+			break;
+		}
 	}
 
 out:
@@ -2119,7 +2125,8 @@ static enum compact_result compact_zone(struct compact_control *cc)
 
 static enum compact_result compact_zone_order(struct zone *zone, int order,
 		gfp_t gfp_mask, enum compact_priority prio,
-		unsigned int alloc_flags, int classzone_idx)
+		unsigned int alloc_flags, int classzone_idx,
+		struct page **capture)
 {
 	enum compact_result ret;
 	struct compact_control cc = {
@@ -2139,14 +2146,24 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 		.ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY),
 		.ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY)
 	};
+	struct capture_control capc = {
+		.cc = &cc,
+		.page = NULL,
+	};
+
+	if (capture)
+		current->capture_control = &capc;
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
-	ret = compact_zone(&cc);
+	ret = compact_zone(&cc, &capc);
 
 	VM_BUG_ON(!list_empty(&cc.freepages));
 	VM_BUG_ON(!list_empty(&cc.migratepages));
 
+	*capture = capc.page;
+	current->capture_control = NULL;
+
 	return ret;
 }
 
@@ -2164,7 +2181,7 @@ int sysctl_extfrag_threshold = 500;
  */
 enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum compact_priority prio)
+		enum compact_priority prio, struct page **capture)
 {
 	int may_perform_io = gfp_mask & __GFP_IO;
 	struct zoneref *z;
@@ -2192,7 +2209,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		}
 
 		status = compact_zone_order(zone, order, gfp_mask, prio,
-					alloc_flags, ac_classzone_idx(ac));
+				alloc_flags, ac_classzone_idx(ac), capture);
 		rc = max(status, rc);
 
 		/* The allocation should succeed, stop compacting */
@@ -2260,7 +2277,7 @@ static void compact_node(int nid)
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
 
-		compact_zone(&cc);
+		compact_zone(&cc, NULL);
 
 		VM_BUG_ON(!list_empty(&cc.freepages));
 		VM_BUG_ON(!list_empty(&cc.migratepages));
@@ -2402,7 +2419,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 
 		if (kthread_should_stop())
 			return;
-		status = compact_zone(&cc);
+		status = compact_zone(&cc, NULL);
 
 		if (status == COMPACT_SUCCESS) {
 			compaction_defer_reset(zone, cc.order, false);
diff --git a/mm/internal.h b/mm/internal.h
index 983cb975545f..08fbb9d157c0 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -207,6 +207,15 @@ struct compact_control {
 	bool contended;			/* Signal lock or sched contention */
 };
 
+/*
+ * Used in direct compaction when a page should be taken from the freelists
+ * immediately when one is created during the free path.
+ */
+struct capture_control {
+	struct compact_control *cc;
+	struct page *page;
+};
+
 unsigned long
 isolate_freepages_range(struct compact_control *cc,
 			unsigned long start_pfn, unsigned long end_pfn);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c7b80e62bfd9..4e0cf4dbda5b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -753,6 +753,41 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	return 0;
 }
 
+#ifdef CONFIG_COMPACTION
+static inline struct capture_control *task_capc(struct zone *zone)
+{
+	struct capture_control *capc = current->capture_control;
+
+	return capc &&
+		!(current->flags & PF_KTHREAD) &&
+		!capc->page &&
+		capc->cc->zone == zone &&
+		capc->cc->direct_compaction ? capc : NULL;
+}
+
+static inline bool
+compaction_capture(struct capture_control *capc, struct page *page, int order)
+{
+	if (!capc || order != capc->cc->order)
+		return false;
+
+	capc->page = page;
+	return true;
+}
+
+#else
+static inline struct capture_control *task_capc(struct zone *zone)
+{
+	return NULL;
+}
+
+static inline bool
+compaction_capture(struct capture_control *capc, struct page *page, int order)
+{
+	return false;
+}
+#endif /* CONFIG_COMPACTION */
+
 /*
  * Freeing function for a buddy system allocator.
  *
@@ -786,6 +821,7 @@ static inline void __free_one_page(struct page *page,
 	unsigned long uninitialized_var(buddy_pfn);
 	struct page *buddy;
 	unsigned int max_order;
+	struct capture_control *capc = task_capc(zone);
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
@@ -801,6 +837,12 @@ static inline void __free_one_page(struct page *page,
 
 continue_merging:
 	while (order < max_order - 1) {
+		if (compaction_capture(capc, page, order)) {
+			if (likely(!is_migrate_isolate(migratetype)))
+				__mod_zone_freepage_state(zone, -(1 << order),
+								migratetype);
+			return;
+		}
 		buddy_pfn = __find_buddy_pfn(pfn, order);
 		buddy = page + (buddy_pfn - pfn);
 
@@ -3779,7 +3821,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
 		enum compact_priority prio, enum compact_result *compact_result)
 {
-	struct page *page;
+	struct page *page = NULL;
 	unsigned long pflags;
 	unsigned int noreclaim_flag;
 
@@ -3790,13 +3832,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	noreclaim_flag = memalloc_noreclaim_save();
 
 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
-									prio);
+								prio, &page);
 
 	memalloc_noreclaim_restore(noreclaim_flag);
 	psi_memstall_leave(&pflags);
 
-	if (*compact_result <= COMPACT_INACTIVE)
+	if (*compact_result <= COMPACT_INACTIVE) {
+		WARN_ON_ONCE(page);
 		return NULL;
+	}
 
 	/*
 	 * At least in one zone compaction wasn't deferred or skipped, so let's
@@ -3804,7 +3848,13 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	 */
 	count_vm_event(COMPACTSTALL);
 
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	/* Prep a captured page if available */
+	if (page)
+		prep_new_page(page, order, gfp_mask, alloc_flags);
+
+	/* Try get a page from the freelist if available */
+	if (!page)
+		page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
 
 	if (page) {
 		struct zone *zone = page_zone(page);
-- 
2.16.4


-- 
Mel Gorman
SUSE Labs
