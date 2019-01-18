Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06A058E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:55:33 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so5288296edd.2
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:55:32 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id hh8-v6si1326332ejb.41.2019.01.18.09.55.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:55:31 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id BC19198C63
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:55:30 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 22/22] mm, compaction: Capture a page under direct compaction
Date: Fri, 18 Jan 2019 17:51:36 +0000
Message-Id: <20190118175136.31341-23-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Compaction is inherently race-prone as a suitable page freed during
compaction can be allocated by any parallel task. This patch uses a
capture_control structure to isolate a page immediately when it is freed
by a direct compactor in the slow path of the page allocator. The intent
is to avoid redundant scanning.

                                     5.0.0-rc1              5.0.0-rc1
                               selective-v3r17          capture-v3r19
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      2582.11 (   0.00%)     2563.68 (   0.71%)
Amean     fault-both-5      4500.26 (   0.00%)     4233.52 (   5.93%)
Amean     fault-both-7      5819.53 (   0.00%)     6333.65 (  -8.83%)
Amean     fault-both-12     9321.18 (   0.00%)     9759.38 (  -4.70%)
Amean     fault-both-18     9782.76 (   0.00%)    10338.76 (  -5.68%)
Amean     fault-both-24    15272.81 (   0.00%)    13379.55 *  12.40%*
Amean     fault-both-30    15121.34 (   0.00%)    16158.25 (  -6.86%)
Amean     fault-both-32    18466.67 (   0.00%)    18971.21 (  -2.73%)

Latency is only moderately affected but the devil is in the details.
A closer examination indicates that base page fault latency is reduced
but latency of huge pages is increased as it takes creater care to
succeed. Part of the "problem" is that allocation success rates are close
to 100% even when under pressure and compaction gets harder

                                5.0.0-rc1              5.0.0-rc1
                          selective-v3r17          capture-v3r19
Percentage huge-3        96.70 (   0.00%)       98.23 (   1.58%)
Percentage huge-5        96.99 (   0.00%)       95.30 (  -1.75%)
Percentage huge-7        94.19 (   0.00%)       97.24 (   3.24%)
Percentage huge-12       94.95 (   0.00%)       97.35 (   2.53%)
Percentage huge-18       96.74 (   0.00%)       97.30 (   0.58%)
Percentage huge-24       97.07 (   0.00%)       97.55 (   0.50%)
Percentage huge-30       95.69 (   0.00%)       98.50 (   2.95%)
Percentage huge-32       96.70 (   0.00%)       99.27 (   2.65%)

And scan rates are reduced as expected by 6% for the migration scanner
and 29% for the free scanner indicating that there is less redundant work.

Compaction migrate scanned    20815362    19573286
Compaction free scanned       16352612    11510663

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/compaction.h |  3 +-
 include/linux/sched.h      |  4 +++
 kernel/sched/core.c        |  3 ++
 mm/compaction.c            | 31 ++++++++++++++-----
 mm/internal.h              |  9 ++++++
 mm/page_alloc.c            | 74 +++++++++++++++++++++++++++++++++++++++++++---
 6 files changed, 112 insertions(+), 12 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 70d0256edd31..c960923d9ec2 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -93,7 +93,8 @@ extern int sysctl_compact_unevictable_allowed;
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
index 9a46243e6585..5e6690042497 100644
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
index a674c7db2f29..ae5beb3ed09e 100644
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
index de558f110319..2a6240d940e9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2055,7 +2055,8 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 	return false;
 }
 
-static enum compact_result compact_zone(struct compact_control *cc)
+static enum compact_result
+compact_zone(struct compact_control *cc, struct capture_control *capc)
 {
 	enum compact_result ret;
 	unsigned long start_pfn = cc->zone->zone_start_pfn;
@@ -2224,6 +2225,11 @@ static enum compact_result compact_zone(struct compact_control *cc)
 			}
 		}
 
+		/* Stop if a page has been captured */
+		if (capc && capc->page) {
+			ret = COMPACT_SUCCESS;
+			break;
+		}
 	}
 
 out:
@@ -2257,7 +2263,8 @@ static enum compact_result compact_zone(struct compact_control *cc)
 
 static enum compact_result compact_zone_order(struct zone *zone, int order,
 		gfp_t gfp_mask, enum compact_priority prio,
-		unsigned int alloc_flags, int classzone_idx)
+		unsigned int alloc_flags, int classzone_idx,
+		struct page **capture)
 {
 	enum compact_result ret;
 	struct compact_control cc = {
@@ -2278,14 +2285,24 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
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
 
@@ -2303,7 +2320,7 @@ int sysctl_extfrag_threshold = 500;
  */
 enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum compact_priority prio)
+		enum compact_priority prio, struct page **capture)
 {
 	int may_perform_io = gfp_mask & __GFP_IO;
 	struct zoneref *z;
@@ -2331,7 +2348,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		}
 
 		status = compact_zone_order(zone, order, gfp_mask, prio,
-					alloc_flags, ac_classzone_idx(ac));
+				alloc_flags, ac_classzone_idx(ac), capture);
 		rc = max(status, rc);
 
 		/* The allocation should succeed, stop compacting */
@@ -2399,7 +2416,7 @@ static void compact_node(int nid)
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
 
-		compact_zone(&cc);
+		compact_zone(&cc, NULL);
 
 		VM_BUG_ON(!list_empty(&cc.freepages));
 		VM_BUG_ON(!list_empty(&cc.migratepages));
@@ -2534,7 +2551,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 
 		if (kthread_should_stop())
 			return;
-		status = compact_zone(&cc);
+		status = compact_zone(&cc, NULL);
 
 		if (status == COMPACT_SUCCESS) {
 			compaction_defer_reset(zone, cc.order, false);
diff --git a/mm/internal.h b/mm/internal.h
index 31bb0be6fd52..9eeaf2b95166 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -209,6 +209,15 @@ struct compact_control {
 	bool rescan;			/* Rescanning the same pageblock */
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
index 6607cb7131b0..d61174bb0333 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -786,6 +786,57 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
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
+compaction_capture(struct capture_control *capc, struct page *page,
+		   int order, int migratetype)
+{
+	if (!capc || order != capc->cc->order)
+		return false;
+
+	/* Do not accidentally pollute CMA or isolated regions*/
+	if (is_migrate_cma(migratetype) ||
+	    is_migrate_isolate(migratetype))
+		return false;
+
+	/*
+	 * Do not let lower order allocations polluate a movable pageblock.
+	 * This might let an unmovable request use a reclaimable pageblock
+	 * and vice-versa but no more than normal fallback logic which can
+	 * have trouble finding a high-order free page.
+	 */
+	if (order < pageblock_order && migratetype == MIGRATE_MOVABLE)
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
+compaction_capture(struct capture_control *capc, struct page *page,
+		   int order, int migratetype)
+{
+	return false;
+}
+#endif /* CONFIG_COMPACTION */
+
 /*
  * Freeing function for a buddy system allocator.
  *
@@ -819,6 +870,7 @@ static inline void __free_one_page(struct page *page,
 	unsigned long uninitialized_var(buddy_pfn);
 	struct page *buddy;
 	unsigned int max_order;
+	struct capture_control *capc = task_capc(zone);
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
@@ -834,6 +886,12 @@ static inline void __free_one_page(struct page *page,
 
 continue_merging:
 	while (order < max_order - 1) {
+		if (compaction_capture(capc, page, order, migratetype)) {
+			if (likely(!is_migrate_isolate(migratetype)))
+				__mod_zone_freepage_state(zone, -(1 << order),
+								migratetype);
+			return;
+		}
 		buddy_pfn = __find_buddy_pfn(pfn, order);
 		buddy = page + (buddy_pfn - pfn);
 
@@ -3819,7 +3877,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
 		enum compact_priority prio, enum compact_result *compact_result)
 {
-	struct page *page;
+	struct page *page = NULL;
 	unsigned long pflags;
 	unsigned int noreclaim_flag;
 
@@ -3830,13 +3888,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
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
@@ -3844,7 +3904,13 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
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
