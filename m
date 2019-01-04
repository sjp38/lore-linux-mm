Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DEFB8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:54:29 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b3so35182266edi.0
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:54:29 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id r18-v6si5649388ejh.206.2019.01.04.04.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:54:27 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id D214C1C1CB6
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:54:26 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 24/25] mm, compaction: Capture a page under direct compaction
Date: Fri,  4 Jan 2019 12:50:10 +0000
Message-Id: <20190104125011.16071-25-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Compaction is inherently race-prone as a suitable page freed during
compaction can be allocated by any parallel task. This patch uses a
capture_control structure to isolate a page immediately when it is freed
by a direct compactor in the slow path of the page allocator. The intent
is to avoid redundant scanning.

                                        4.20.0                 4.20.0
                               selective-v2r15          capture-v2r15
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      2624.85 (   0.00%)     2594.49 (   1.16%)
Amean     fault-both-5      3842.66 (   0.00%)     4088.32 (  -6.39%)
Amean     fault-both-7      5459.47 (   0.00%)     5936.54 (  -8.74%)
Amean     fault-both-12     9276.60 (   0.00%)    10160.85 (  -9.53%)
Amean     fault-both-18    14030.73 (   0.00%)    13908.92 (   0.87%)
Amean     fault-both-24    13298.10 (   0.00%)    16819.86 * -26.48%*
Amean     fault-both-30    17648.62 (   0.00%)    17901.74 (  -1.43%)
Amean     fault-both-32    19161.67 (   0.00%)    18621.32 (   2.82%)

Latency is only moderately affected but the devil is in the details.
A closer examination indicates that base page fault latency is much
reduced but latency of huge pages is increased as it takes creater care
to succeed. Part of the "problem" is that allocation success rates
are close to 100% even when under pressure and compaction gets harder

                                   4.20.0                 4.20.0
                          selective-v2r15          capture-v2r15
Percentage huge-1         0.00 (   0.00%)        0.00 (   0.00%)
Percentage huge-3        99.95 (   0.00%)       99.98 (   0.03%)
Percentage huge-5        98.83 (   0.00%)       98.01 (  -0.84%)
Percentage huge-7        96.78 (   0.00%)       98.30 (   1.58%)
Percentage huge-12       98.85 (   0.00%)       97.76 (  -1.10%)
Percentage huge-18       97.52 (   0.00%)       99.05 (   1.57%)
Percentage huge-24       97.07 (   0.00%)       99.34 (   2.35%)
Percentage huge-30       96.59 (   0.00%)       99.08 (   2.58%)
Percentage huge-32       95.94 (   0.00%)       99.03 (   3.22%)

And scan rates are reduced as expected by 10% for the migration
scanner and 37% for the free scanner indicating that there is
less redundant work.

Compaction migrate scanned    20338945.00    18133661.00
Compaction free scanned       12590377.00     7986174.00

The impact on 2-socket is much larger albeit not presented. Under
a different workload that fragments heavily, the allocation latency
is reduced by 26% while the success rate goes from 63% to 80%

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
index 89541d248893..f5ac0cf9cc32 100644
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
index f66920173370..ef478b0daa45 100644
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
index 7f316e1a7275..ae70be023b21 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2051,7 +2051,8 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 	return false;
 }
 
-static enum compact_result compact_zone(struct compact_control *cc)
+static enum compact_result
+compact_zone(struct compact_control *cc, struct capture_control *capc)
 {
 	enum compact_result ret;
 	unsigned long start_pfn = cc->zone->zone_start_pfn;
@@ -2225,6 +2226,11 @@ static enum compact_result compact_zone(struct compact_control *cc)
 			}
 		}
 
+		/* Stop if a page has been captured */
+		if (capc && capc->page) {
+			ret = COMPACT_SUCCESS;
+			break;
+		}
 	}
 
 out:
@@ -2258,7 +2264,8 @@ static enum compact_result compact_zone(struct compact_control *cc)
 
 static enum compact_result compact_zone_order(struct zone *zone, int order,
 		gfp_t gfp_mask, enum compact_priority prio,
-		unsigned int alloc_flags, int classzone_idx)
+		unsigned int alloc_flags, int classzone_idx,
+		struct page **capture)
 {
 	enum compact_result ret;
 	struct compact_control cc = {
@@ -2279,14 +2286,24 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
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
 
@@ -2304,7 +2321,7 @@ int sysctl_extfrag_threshold = 500;
  */
 enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum compact_priority prio)
+		enum compact_priority prio, struct page **capture)
 {
 	int may_perform_io = gfp_mask & __GFP_IO;
 	struct zoneref *z;
@@ -2332,7 +2349,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		}
 
 		status = compact_zone_order(zone, order, gfp_mask, prio,
-					alloc_flags, ac_classzone_idx(ac));
+				alloc_flags, ac_classzone_idx(ac), capture);
 		rc = max(status, rc);
 
 		/* The allocation should succeed, stop compacting */
@@ -2400,7 +2417,7 @@ static void compact_node(int nid)
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
 
-		compact_zone(&cc);
+		compact_zone(&cc, NULL);
 
 		VM_BUG_ON(!list_empty(&cc.freepages));
 		VM_BUG_ON(!list_empty(&cc.migratepages));
@@ -2543,7 +2560,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 
 		if (kthread_should_stop())
 			return;
-		status = compact_zone(&cc);
+		status = compact_zone(&cc, NULL);
 
 		if (status == COMPACT_SUCCESS) {
 			compaction_defer_reset(zone, cc.order, false);
diff --git a/mm/internal.h b/mm/internal.h
index d028abd8a8f3..6b1e5e313855 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -208,6 +208,15 @@ struct compact_control {
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
index 05c9a81d54ed..83ea34d8dbe2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -789,6 +789,41 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
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
@@ -822,6 +857,7 @@ static inline void __free_one_page(struct page *page,
 	unsigned long uninitialized_var(buddy_pfn);
 	struct page *buddy;
 	unsigned int max_order;
+	struct capture_control *capc = task_capc(zone);
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
@@ -837,6 +873,12 @@ static inline void __free_one_page(struct page *page,
 
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
 
@@ -3700,7 +3742,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
 		enum compact_priority prio, enum compact_result *compact_result)
 {
-	struct page *page;
+	struct page *page = NULL;
 	unsigned long pflags;
 	unsigned int noreclaim_flag;
 
@@ -3711,13 +3753,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
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
@@ -3725,7 +3769,13 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
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
