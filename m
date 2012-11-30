Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id F00D36B00E2
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 14:58:57 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so657952eek.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:58:57 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 03/10] numa, mempolicy: Improve CONFIG_NUMA_BALANCING=y OOM behavior
Date: Fri, 30 Nov 2012 20:58:34 +0100
Message-Id: <1354305521-11583-4-git-send-email-mingo@kernel.org>
In-Reply-To: <1354305521-11583-1-git-send-email-mingo@kernel.org>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Zhouping Liu reported worse out-of-memory behavior with
CONFIG_NUMA_BALANCING=y, compared to the mainline kernel.

One reason for that change in behavior is that with typical
applications the mainline kernel allocates memory essentially
randomly, and leaves it where it was.

"Random" placement is not the worst possible placement - in fact
it's a pretty good placement strategy. It's definitely possible
for a NUMA-aware kernel to do worse than that, and
CONFIG_NUMA_BALANCING=y regressed because it's very opinionated
about which node tasks should execute and on which node they
should allocate memory on.

One such problematic case is when a node has already used up
most of its memory - in that case it's pointless trying to
allocate even more memory from there. Doing so would trigger
OOMs even though the system has more memory on other nodes.

The migration code is already trying to be nice when allocating
memory for NUMA purposes - extend this concept to mempolicy
driven allocations as well.

Expose migrate_balanced_pgdat() and use it. If all fails try just
as hard as the old code would.

Hopefully this improves behavior in memory allocation corner
cases.

[ migrate_balanced_pgdat() should probably be moved to
  mm/page_alloc.c and be renamed to balanced_pgdat() or
  so - but this patch tries to be minimalistic. ]

Reported-by: Zhouping Liu <zliu@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/migrate.h        |  6 +++
 include/uapi/linux/mempolicy.h |  1 +
 kernel/sched/core.c            |  2 +-
 mm/huge_memory.c               |  9 +++++
 mm/mempolicy.c                 | 86 +++++++++++++++++++++++++++++++++++-------
 mm/migrate.c                   |  3 +-
 6 files changed, 90 insertions(+), 17 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 72665c9..e5c900f 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -31,6 +31,7 @@ extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
 extern int migrate_misplaced_page(struct page *page, int node);
+extern bool migrate_balanced_pgdat(struct pglist_data *pgdat, int nr_migrate_pages);
 #else
 
 static inline void putback_lru_pages(struct list_head *l) {}
@@ -60,6 +61,11 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 	return -ENOSYS;
 }
 
+static inline bool migrate_balanced_pgdat(struct pglist_data *pgdat, int nr_migrate_pages)
+{
+	return true;
+}
+
 /* Possible settings for the migrate_page() method in address_operations */
 #define migrate_page NULL
 #define fail_migrate_page NULL
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 23e62e0..5accdc3 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -44,6 +44,7 @@ enum mpol_rebind_step {
 #define MPOL_F_NODE	(1<<0)	/* return next IL mode instead of node mask */
 #define MPOL_F_ADDR	(1<<1)	/* look up vma using address */
 #define MPOL_F_MEMS_ALLOWED (1<<2) /* return allowed memories */
+#define MPOL_F_MOF	(1<<3)	/* Migrate On Fault */
 
 /* Flags for mbind */
 #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 0324d5e..129924a 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1566,7 +1566,7 @@ static void __sched_fork(struct task_struct *p)
 	p->ideal_cpu_curr = -1;
 	atomic_set(&p->numa_policy.refcnt, 1);
 	p->numa_policy.mode = MPOL_INTERLEAVE;
-	p->numa_policy.flags = 0;
+	p->numa_policy.flags = MPOL_F_MOF;
 	p->numa_policy.v.preferred_node = 0;
 	p->numa_policy.v.nodes = node_online_map;
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 92e101f..977834c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -788,6 +788,15 @@ unlock:
 migrate:
 	spin_unlock(&mm->page_table_lock);
 
+	/*
+	 * If this node is getting full then don't migrate even
+ 	 * more pages here:
+ 	 */
+	if (!migrate_balanced_pgdat(NODE_DATA(node), HPAGE_PMD_NR)) {
+		put_page(page);
+		return;
+	}
+
 	lock_page(page);
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, entry))) {
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d71a93d..081a505 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -115,7 +115,7 @@ enum zone_type policy_zone = 0;
 static struct mempolicy default_policy_local = {
 	.refcnt		= ATOMIC_INIT(1), /* never free it */
 	.mode		= MPOL_PREFERRED,
-	.flags		= MPOL_F_LOCAL,
+	.flags		= MPOL_F_LOCAL | MPOL_F_MOF,
 };
 
 static struct mempolicy *default_policy(void)
@@ -1675,11 +1675,14 @@ unsigned slab_node(void)
 		struct zonelist *zonelist;
 		struct zone *zone;
 		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
+		int node;
+
 		zonelist = &NODE_DATA(numa_node_id())->node_zonelists[0];
 		(void)first_zones_zonelist(zonelist, highest_zoneidx,
 							&policy->v.nodes,
 							&zone);
-		return zone ? zone->node : numa_node_id();
+		node = zone ? zone->node : numa_node_id();
+		return node;
 	}
 
 	default:
@@ -1889,6 +1892,62 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 	return page;
 }
 
+static struct page *
+alloc_pages_nice(gfp_t gfp, int order, struct mempolicy *pol, int best_nid)
+{
+	struct zonelist *zl = policy_zonelist(gfp, pol, best_nid);
+#ifdef CONFIG_NUMA_BALANCING
+	unsigned int pages = 1 << order;
+	gfp_t gfp_nice = gfp | GFP_THISNODE;
+#endif
+	struct page *page = NULL;
+	nodemask_t *nodemask;
+
+	nodemask = policy_nodemask(gfp, pol);
+
+#ifdef CONFIG_NUMA_BALANCING
+	if (migrate_balanced_pgdat(NODE_DATA(best_nid), pages)) {
+		page = alloc_pages_node(best_nid, gfp_nice, order);
+		if (page)
+			return page;
+	}
+
+	/*
+	 * For non-hard-bound tasks, see whether there's another node
+	 * before trying harder:
+	 */
+	if (current->nr_cpus_allowed > 1) {
+		int nid;
+
+		if (nodemask) {
+			int first_nid = find_first_bit(nodemask->bits, MAX_NUMNODES);
+
+			page = alloc_pages_node(first_nid, gfp_nice, order);
+			if (page)
+				return page;
+		}
+
+		/*
+		 * Pick a less loaded node, if possible:
+		 */
+		for_each_node(nid) {
+			if (!migrate_balanced_pgdat(NODE_DATA(nid), pages))
+				continue;
+
+			page = alloc_pages_node(nid, gfp_nice, order);
+			if (page)
+				return page;
+		}
+	}
+#endif
+
+	/* If all failed then try the original plan: */
+	if (!page)
+		page = __alloc_pages_nodemask(gfp, order, zl, nodemask);
+
+	return page;
+}
+
 /**
  * 	alloc_pages_vma	- Allocate a page for a VMA.
  *
@@ -1917,8 +1976,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		unsigned long addr, int node)
 {
 	struct mempolicy *pol;
-	struct zonelist *zl;
-	struct page *page;
+	struct page *page = NULL;
 	unsigned int cpuset_mems_cookie;
 
 retry_cpuset:
@@ -1936,13 +1994,12 @@ retry_cpuset:
 
 		return page;
 	}
-	zl = policy_zonelist(gfp, pol, node);
 	if (unlikely(mpol_needs_cond_ref(pol))) {
 		/*
 		 * slow path: ref counted shared policy
 		 */
-		struct page *page =  __alloc_pages_nodemask(gfp, order,
-						zl, policy_nodemask(gfp, pol));
+		page = alloc_pages_nice(gfp, order, pol, node);
+
 		__mpol_put(pol);
 		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 			goto retry_cpuset;
@@ -1951,10 +2008,10 @@ retry_cpuset:
 	/*
 	 * fast path:  default or task policy
 	 */
-	page = __alloc_pages_nodemask(gfp, order, zl,
-				      policy_nodemask(gfp, pol));
+	page = alloc_pages_nice(gfp, order, pol, node);
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
+
 	return page;
 }
 
@@ -1980,8 +2037,8 @@ retry_cpuset:
 struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 {
 	struct mempolicy *pol = current->mempolicy;
-	struct page *page;
 	unsigned int cpuset_mems_cookie;
+	struct page *page;
 
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
 		pol = default_policy();
@@ -1996,9 +2053,7 @@ retry_cpuset:
 	if (pol->mode == MPOL_INTERLEAVE)
 		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
 	else
-		page = __alloc_pages_nodemask(gfp, order,
-				policy_zonelist(gfp, pol, numa_node_id()),
-				policy_nodemask(gfp, pol));
+		page = alloc_pages_nice(gfp, order, pol, numa_node_id());
 
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
@@ -2275,7 +2330,10 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	cpu_last_access = page_xchg_last_cpu(page, this_cpu);
 
 	pol = get_vma_policy(current, vma, addr);
-	if (!(task_numa_shared(current) >= 0))
+
+	if (task_numa_shared(current) < 0)
+		goto out_keep_page;
+	if (!(pol->flags & MPOL_F_MOF))
 		goto out_keep_page;
 
 	switch (pol->mode) {
diff --git a/mm/migrate.c b/mm/migrate.c
index 16a4709..3db0543 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1408,8 +1408,7 @@ int migrate_vmas(struct mm_struct *mm, const nodemask_t *to,
  * Returns true if this is a safe migration target node for misplaced NUMA
  * pages. Currently it only checks the watermarks which is a bit crude.
  */
-static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
-				   int nr_migrate_pages)
+bool migrate_balanced_pgdat(struct pglist_data *pgdat, int nr_migrate_pages)
 {
 	int z;
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
