Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 159C66B0083
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:03 -0400 (EDT)
Message-Id: <20120316144240.492318994@chello.nl>
Date: Fri, 16 Mar 2012 15:40:34 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 06/26] mm: Migrate misplaced page
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=migrate-on-fault-04-migrate_misplaced_page.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

This patch adds a new function migrate_misplaced_page() to mm/migrate.c
[where most of the other page migration functions live] to migrate a
misplaced page to a specified destination node.  This function will be
called from the fault path.  Because we already know the destination
node for the migration, we allocate pages directly rather than rerunning
the policy node computation in alloc_page_vma().

Since the fault path holds an extra reference from other migration
paths, introduce a new migration_mode (MIGRATE_FAULT) to communicate
this.

The patch adds the function check_migrate_misplaced_page() to migrate.c
to check whether a page is "misplaced" -- i.e. on a node different
from what the policy for (vma, address) dictates.  This check
involves accessing the vma policy, so we only do this if:
   * page has zero mapcount [no pte references]
   * page is not in writeback
   * page is up to date
   * page's mapping has a migratepage a_op [no fallback!]
If these checks are satisfied, the page will be migrated to the
"correct" node, if possible.  If migration fails for any reason,
we just use the original page.

Subsequent patches will hook the fault handlers [anon, and possibly
file and/or shmem] to check_migrate_misplaced_page().

XXX: hnaz, dansmith saw some bad_page() reports when using memcg, I
could not reproduce -- is there something funny with the mem_cgroup
calls in the below patch?

Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
[ removed the weird ignore page count on migrate stuff with the
  new migrate_mode and strict accounting ]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mempolicy.h    |   18 ------
 include/linux/migrate.h      |    9 +++
 include/linux/migrate_mode.h |    3 +
 mm/mempolicy.c               |   19 ++++++
 mm/migrate.c                 |  128 ++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 160 insertions(+), 17 deletions(-)
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -77,6 +77,7 @@ enum mpol_rebind_step {
 #include <linux/spinlock.h>
 #include <linux/nodemask.h>
 #include <linux/pagemap.h>
+#include <linux/migrate.h>
 
 struct mm_struct;
 
@@ -245,22 +246,7 @@ extern int mpol_parse_str(char *str, str
 extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol,
 			int no_context);
 
-/* Check if a vma is migratable */
-static inline int vma_migratable(struct vm_area_struct *vma)
-{
-	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
-		return 0;
-	/*
-	 * Migration allocates pages in the highest zone. If we cannot
-	 * do so then migration (at least from node to node) is not
-	 * possible.
-	 */
-	if (vma->vm_file &&
-		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
-								< policy_zone)
-			return 0;
-	return 1;
-}
+extern int vma_migratable(struct vm_area_struct *);
 
 extern int mpol_misplaced(struct page *, struct vm_area_struct *, unsigned long);
 
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -33,6 +33,10 @@ extern int migrate_huge_page_move_mappin
 				  struct page *newpage, struct page *page);
 
 extern int migrate_pages_unmap_only(struct list_head *);
+extern struct page *check_migrate_misplaced_page(struct page *,
+			struct vm_area_struct *, unsigned long);
+extern struct page *migrate_misplaced_page(struct page *,
+			struct mm_struct *, int);
 #else
 #define PAGE_MIGRATION 0
 
@@ -67,5 +71,10 @@ static inline int migrate_huge_page_move
 #define migrate_page NULL
 #define fail_migrate_page NULL
 
+static inline struct page *check_migrate_misplaced_page(struct page *page,
+			struct vm_area_struct *vma, unsigned long addr)
+{
+	return page;
+}
 #endif /* CONFIG_MIGRATION */
 #endif /* _LINUX_MIGRATE_H */
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -6,11 +6,14 @@
  *	on most operations but not ->writepage as the potential stall time
  *	is too significant
  * MIGRATE_SYNC will block when migrating pages
+ * MIGRATE_FAULT called from the fault path to migrate-on-fault for mempolicy
+ * 	this path has an extra reference count
  */
 enum migrate_mode {
 	MIGRATE_ASYNC,
 	MIGRATE_SYNC_LIGHT,
 	MIGRATE_SYNC,
+	MIGRATE_FAULT,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -460,6 +460,25 @@ static const struct mempolicy_operations
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags);
 
+/*
+ * Check whether a vma is migratable
+ */
+int vma_migratable(struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
+		return 0;
+	/*
+	 * Migration allocates pages in the highest zone. If we cannot
+	 * do so then migration (at least from node to node) is not
+	 * possible.
+	 */
+	if (vma->vm_file &&
+		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
+								< policy_zone)
+			return 0;
+	return 1;
+}
+
 struct mempol_walk_data {
 	struct vm_area_struct *vma;
 	const nodemask_t *nodes;
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -294,6 +294,10 @@ static int migrate_page_move_mapping(str
  					page_index(page));
 
 	expected_count = 2 + page_has_private(page);
+	if (mode == MIGRATE_FAULT) {
+		expected_count++;
+		mode = MIGRATE_ASYNC; /* don't bother blocking for MoF */
+	}
 	if (page_count(page) != expected_count ||
 		radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
 		spin_unlock_irq(&mapping->tree_lock);
@@ -1517,4 +1521,126 @@ int migrate_vmas(struct mm_struct *mm, c
  	}
  	return err;
 }
-#endif
+
+/*
+ * Attempt to migrate a misplaced page to the specified destination
+ * node.  Page is already unmapped, up to date and locked by caller.
+ * Anon pages are in the swap cache.  Page's mapping has a migratepage aop.
+ *
+ * page refs on entry/exit:  cache + fault path [+ bufs]
+ */
+struct page *
+migrate_misplaced_page(struct page *page, struct mm_struct *mm, int node)
+{
+	struct page *oldpage = page, *newpage;
+	struct address_space *mapping = page_mapping(page);
+	struct mem_cgroup *mcg;
+	unsigned int gfp;
+	int rc = 0;
+	int charge = -ENOMEM;
+
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(page_mapcount(page));
+	VM_BUG_ON(PageAnon(page) && !PageSwapCache(page));
+	VM_BUG_ON(!mapping || !mapping->a_ops->migratepage);
+
+	/*
+	 * remove old page from LRU so it can't be found while migrating
+	 * except thru' the cache by other faulting tasks who will
+	 * block behind my lock.
+	 */
+	if (isolate_lru_page(page))	/* incrs page count on success */
+		goto out_nolru;	/* we lost */
+
+	/*
+	 * Never wait for allocations just to migrate on fault,
+	 * but don't dip into reserves.
+	 * And, only accept pages from specified node.
+	 * No sense migrating to a different "misplaced" page!
+	 */
+	gfp = (unsigned int)mapping_gfp_mask(mapping) & ~__GFP_WAIT;
+	gfp |= __GFP_NOMEMALLOC | GFP_THISNODE ;
+
+	newpage = alloc_pages_node(node, gfp, 0);
+	if (!newpage)
+		goto out;	/* give up */
+
+	/*
+	 * can't just lock_page() -- "might sleep" in atomic context
+	 */
+	if (!trylock_page(newpage))
+		BUG();		/* new page should be unlocked!!! */
+
+	// XXX hnaz, is this right?
+	charge = mem_cgroup_prepare_migration(page, newpage, &mcg, gfp);
+	if (charge == -ENOMEM) {
+		rc = charge;
+		goto out;
+	}
+
+	newpage->index = page->index;
+	newpage->mapping = page->mapping;
+	if (PageSwapBacked(page))		/* like move_to_new_page() */
+		SetPageSwapBacked(newpage);
+
+	/*
+	 * migrate a_op transfers cache [+ buf] refs
+	 */
+	rc = mapping->a_ops->migratepage(mapping, newpage, page, MIGRATE_FAULT);
+	if (!rc) {
+		get_page(newpage);	/* add isolate_lru_page ref */
+		put_page(page);		/* drop       "          "  */
+
+		unlock_page(page);
+		put_page(page);		/* drop fault path ref & free */
+
+		page = newpage;
+	}
+
+out:
+	if (!charge)
+		mem_cgroup_end_migration(mcg, oldpage, newpage, !rc);
+
+	if (rc) {
+		unlock_page(newpage);
+		__free_page(newpage);
+	}
+
+	putback_lru_page(page);		/* ultimately, drops a page ref */
+
+out_nolru:
+	return page;			/* locked, to complete fault */
+}
+
+/*
+ * Called in fault path, if migrate_on_fault_enabled(current) for a page
+ * found in the cache, page is locked, and page_mapping(page) != NULL;
+ * We check for page uptodate here because we want to be able to do any
+ * needed migration before grabbing the page table lock.  In the anon fault
+ * path, PageUptodate() isn't checked until after locking the page table.
+ *
+ * For migrate on fault, we only migrate pages whose mapping has a
+ * migratepage op.  The fallback path requires writing out the page and
+ * reading it back in.  That sort of defeats the purpose of
+ * migrate-on-fault [performance].  So, we don't even bother to check
+ * for misplacment unless the op is present.  Of course, this is an extra
+ * check in the fault path for pages we care about :-(
+ */
+struct page *check_migrate_misplaced_page(struct page *page,
+		struct vm_area_struct *vma, unsigned long address)
+{
+	int node;
+
+	if (page_mapcount(page) || PageWriteback(page) ||
+			unlikely(!PageUptodate(page))  ||
+			!page_mapping(page)->a_ops->migratepage)
+		return page;
+
+	node = mpol_misplaced(page, vma, address);
+	if (node == -1)
+		return page;
+
+	return migrate_misplaced_page(page, vma->vm_mm, node);
+}
+
+#endif /* CONFIG_NUMA */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
