Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 86C3C6B0075
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:44:23 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1082361eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:44:23 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 12/52] mm/migrate: Introduce migrate_misplaced_page()
Date: Sun,  2 Dec 2012 19:43:04 +0100
Message-Id: <1354473824-19229-13-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Note: This was originally based on Peter's patch "mm/migrate:
Introduce 	migrate_misplaced_page()" but borrows extremely heavily from Andrea's
	"autonuma: memory follows CPU algorithm and task/mm_autonuma stats
	collection". The end result is barely recognisable so signed-offs
	had to be dropped. If original authors are ok with it, I'll
	re-add the signed-off-bys.

Add migrate_misplaced_page() which deals with migrating pages
from faults.

Based-on-work-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Based-on-work-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Based-on-work-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Paul Turner <pjt@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Alex Shi <lkml.alex@gmail.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/migrate.h |  16 +++++++
 mm/migrate.c            | 108 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 122 insertions(+), 2 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 9d1c159..f7404b6 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -13,6 +13,7 @@ enum migrate_reason {
 	MR_MEMORY_HOTPLUG,
 	MR_SYSCALL,		/* also applies to cpusets */
 	MR_MEMPOLICY_MBIND,
+	MR_NUMA_MISPLACED,
 	MR_CMA
 };
 
@@ -39,6 +40,15 @@ extern int migrate_vmas(struct mm_struct *mm,
 extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
+#ifdef CONFIG_NUMA_BALANCING
+extern int migrate_misplaced_page(struct page *page, int node);
+#else
+static inline
+int migrate_misplaced_page(struct page *page, int node)
+{
+	return -EAGAIN; /* can't migrate now */
+}
+#endif
 #else
 
 static inline void putback_lru_pages(struct list_head *l) {}
@@ -72,5 +82,11 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #define migrate_page NULL
 #define fail_migrate_page NULL
 
+static inline
+int migrate_misplaced_page(struct page *page, int node)
+{
+	return -EAGAIN; /* can't migrate now */
+}
 #endif /* CONFIG_MIGRATION */
+
 #endif /* _LINUX_MIGRATE_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index 27be9c9..d168aec 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -282,7 +282,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
 		struct buffer_head *head, enum migrate_mode mode)
 {
-	int expected_count;
+	int expected_count = 0;
 	void **pslot;
 
 	if (!mapping) {
@@ -1415,4 +1415,108 @@ int migrate_vmas(struct mm_struct *mm, const nodemask_t *to,
  	}
  	return err;
 }
-#endif
+
+#ifdef CONFIG_NUMA_BALANCING
+/*
+ * Returns true if this is a safe migration target node for misplaced NUMA
+ * pages. Currently it only checks the watermarks which crude
+ */
+static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
+				   int nr_migrate_pages)
+{
+	int z;
+	for (z = pgdat->nr_zones - 1; z >= 0; z--) {
+		struct zone *zone = pgdat->node_zones + z;
+
+		if (!populated_zone(zone))
+			continue;
+
+		if (zone->all_unreclaimable)
+			continue;
+
+		/* Avoid waking kswapd by allocating pages_to_migrate pages. */
+		if (!zone_watermark_ok(zone, 0,
+				       high_wmark_pages(zone) +
+				       nr_migrate_pages,
+				       0, 0))
+			continue;
+		return true;
+	}
+	return false;
+}
+
+static struct page *alloc_misplaced_dst_page(struct page *page,
+					   unsigned long data,
+					   int **result)
+{
+	int nid = (int) data;
+	struct page *newpage;
+
+	newpage = alloc_pages_exact_node(nid,
+					 (GFP_HIGHUSER_MOVABLE | GFP_THISNODE |
+					  __GFP_NOMEMALLOC | __GFP_NORETRY |
+					  __GFP_NOWARN) &
+					 ~GFP_IOFS, 0);
+	return newpage;
+}
+
+/*
+ * Attempt to migrate a misplaced page to the specified destination
+ * node. Caller is expected to have an elevated reference count on
+ * the page that will be dropped by this function before returning.
+ */
+int migrate_misplaced_page(struct page *page, int node)
+{
+	int isolated = 0;
+	LIST_HEAD(migratepages);
+
+	/*
+	 * Don't migrate pages that are mapped in multiple processes.
+	 * TODO: Handle false sharing detection instead of this hammer
+	 */
+	if (page_mapcount(page) != 1) {
+		put_page(page);
+		goto out;
+	}
+
+	/* Avoid migrating to a node that is nearly full */
+	if (migrate_balanced_pgdat(NODE_DATA(node), 1)) {
+		int page_lru;
+
+		if (isolate_lru_page(page)) {
+			put_page(page);
+			goto out;
+		}
+		isolated = 1;
+
+		/*
+		 * Page is isolated which takes a reference count so now the
+		 * callers reference can be safely dropped without the page
+		 * disappearing underneath us during migration
+		 */
+		put_page(page);
+
+		page_lru = page_is_file_cache(page);
+		inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
+		list_add(&page->lru, &migratepages);
+	}
+
+	if (isolated) {
+		int nr_remaining;
+
+		nr_remaining = migrate_pages(&migratepages,
+				alloc_misplaced_dst_page,
+				node, false, MIGRATE_ASYNC,
+				MR_NUMA_MISPLACED);
+		if (nr_remaining) {
+			putback_lru_pages(&migratepages);
+			isolated = 0;
+		}
+	}
+	BUG_ON(!list_empty(&migratepages));
+out:
+	return isolated;
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
+#endif /* CONFIG_NUMA */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
