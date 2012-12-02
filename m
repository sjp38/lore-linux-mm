Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id BF6776B00C5
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:45:27 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1476612eek.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:45:27 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 42/52] numa, mempolicy: Improve CONFIG_NUMA_BALANCING=y OOM behavior
Date: Sun,  2 Dec 2012 19:43:34 +0100
Message-Id: <1354473824-19229-43-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
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
 include/linux/migrate.h | 12 +++++++
 kernel/sched/core.c     |  2 +-
 mm/huge_memory.c        |  9 +++++
 mm/mempolicy.c          | 89 ++++++++++++++++++++++++++++++++++++++++---------
 mm/migrate.c            |  3 +-
 5 files changed, 96 insertions(+), 19 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index c92d455..9b0a4d0 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -41,6 +41,7 @@ extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
 # ifdef CONFIG_NUMA_BALANCING
+extern bool migrate_balanced_pgdat(struct pglist_data *pgdat, int nr_migrate_pages);
 extern int migrate_misplaced_page_put(struct page *page, int node);
 extern int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
 			struct vm_area_struct *vma,
@@ -48,6 +49,12 @@ extern int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
 			unsigned long address,
 			struct page *page, int node);
 # else /* !CONFIG_NUMA_BALANCING: */
+
+static inline bool migrate_balanced_pgdat(struct pglist_data *pgdat, int nr_migrate_pages)
+{
+	return true;
+}
+
 static inline
 int migrate_misplaced_page_put(struct page *page, int node)
 {
@@ -93,6 +100,11 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
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
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 05d4e1d..26ab5ff 100644
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
index 5607d91..03c3b4b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1078,6 +1078,15 @@ unlock:
 migrate:
 	spin_unlock(&mm->page_table_lock);
 
+	/*
+	 * If this node is getting full then don't migrate even
+ 	 * more pages here:
+ 	 */
+	if (!migrate_balanced_pgdat(NODE_DATA(node), HPAGE_PMD_NR)) {
+		put_page(page);
+		return 0;
+	}
+
 	lock_page(page);
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, entry))) {
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0649679..da5a189 100644
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
@@ -1746,11 +1746,14 @@ unsigned slab_node(void)
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
@@ -1960,6 +1963,62 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
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
@@ -1988,8 +2047,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		unsigned long addr, int node)
 {
 	struct mempolicy *pol;
-	struct zonelist *zl;
-	struct page *page;
+	struct page *page = NULL;
 	unsigned int cpuset_mems_cookie;
 
 retry_cpuset:
@@ -2007,13 +2065,12 @@ retry_cpuset:
 
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
@@ -2022,10 +2079,10 @@ retry_cpuset:
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
 
@@ -2067,9 +2124,7 @@ retry_cpuset:
 	if (pol->mode == MPOL_INTERLEAVE)
 		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
 	else
-		page = __alloc_pages_nodemask(gfp, order,
-				policy_zonelist(gfp, pol, numa_node_id()),
-				policy_nodemask(gfp, pol));
+		page = alloc_pages_nice(gfp, order, pol, numa_node_id());
 
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
@@ -2284,8 +2339,10 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 
 	pol = get_vma_policy(current, vma, addr);
 	if (!(pol->flags & MPOL_F_MOF))
-		goto out;
-
+		goto out_keep_page;
+	if (task_numa_shared(current) < 0)
+		goto out_keep_page;
+	
 	switch (pol->mode) {
 	case MPOL_INTERLEAVE:
 	{
@@ -2321,7 +2378,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 * If no allowed nodes, use current [!misplaced].
 		 */
 		if (node_isset(page_nid, pol->v.nodes))
-			goto out;
+			goto out_keep_page;
 		(void)first_zones_zonelist(
 				node_zonelist(numa_node_id(), GFP_HIGHUSER),
 				gfp_zone(GFP_HIGHUSER),
@@ -2369,7 +2426,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		if (cpu_last_access == this_cpu)
 			target_node = this_node;
 	}
-out:
+out_keep_page:
 	mpol_cond_put(pol);
 
 	/* Page already at its ideal target node: */
diff --git a/mm/migrate.c b/mm/migrate.c
index 5e50c094..94f5f28 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1421,8 +1421,7 @@ int migrate_vmas(struct mm_struct *mm, const nodemask_t *to,
  * Returns true if this is a safe migration target node for misplaced NUMA
  * pages. Currently it only checks the watermarks which crude
  */
-static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
-				   int nr_migrate_pages)
+bool migrate_balanced_pgdat(struct pglist_data *pgdat, int nr_migrate_pages)
 {
 	int z;
 	for (z = pgdat->nr_zones - 1; z >= 0; z--) {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
