Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id D9D746B00FA
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:07 -0400 (EDT)
Message-Id: <20120316144240.307470041@chello.nl>
Date: Fri, 16 Mar 2012 15:40:31 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 03/26] mm, mpol: add MPOL_MF_LAZY ...
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=migrate-on-fault-06-mbind-lazy-migrate.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

This patch adds another mbind() flag to request "lazy migration".
The flag, MPOL_MF_LAZY, modifies MPOL_MF_MOVE* such that the selected
pages are simply unmapped from the calling task's page table ['_MOVE]
or from all referencing page tables [_MOVE_ALL].  Anon pages will first
be added to the swap [or migration?] cache, if necessary.  The pages
will be migrated in the fault path on "first touch", if the policy
dictates at that time.

"Lazy Migration" will allow testing of migrate-on-fault via mbind().
Also allows applications to specify that only subsequently touched
pages be migrated to obey new policy, instead of all pages in range.
This can be useful for multi-threaded applications working on a
large shared data area that is initialized by an initial thread
resulting in all pages on one [or a few, if overflowed] nodes.
After unmap, the pages in regions assigned to the worker threads
will be automatically migrated local to the threads on 1st touch.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mempolicy.h |   13 ++++--
 include/linux/migrate.h   |    2 
 include/linux/rmap.h      |    5 +-
 mm/mempolicy.c            |   20 +++++----
 mm/migrate.c              |   96 +++++++++++++++++++++++++++++++++++++++++++++-
 mm/rmap.c                 |    7 +--
 6 files changed, 125 insertions(+), 18 deletions(-)
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -47,9 +47,16 @@ enum mpol_rebind_step {
 
 /* Flags for mbind */
 #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
-#define MPOL_MF_MOVE	(1<<1)	/* Move pages owned by this process to conform to mapping */
-#define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to mapping */
-#define MPOL_MF_INTERNAL (1<<3)	/* Internal flags start here */
+#define MPOL_MF_MOVE	 (1<<1)	/* Move pages owned by this process to conform
+				   to policy */
+#define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
+#define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
+#define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
+
+#define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
+			 MPOL_MF_MOVE     | 	\
+			 MPOL_MF_MOVE_ALL |	\
+			 MPOL_MF_LAZY)
 
 /*
  * Internal flags that share the struct mempolicy flags word with
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -31,6 +31,8 @@ extern int migrate_vmas(struct mm_struct
 extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
+
+extern int migrate_pages_unmap_only(struct list_head *);
 #else
 #define PAGE_MIGRATION 0
 
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -164,8 +164,9 @@ int page_referenced_one(struct page *, s
 
 enum ttu_flags {
 	TTU_UNMAP = 0,			/* unmap mode */
-	TTU_MIGRATION = 1,		/* migration mode */
-	TTU_MUNLOCK = 2,		/* munlock mode */
+	TTU_MIGRATE_DIRECT = 1,		/* direct migration mode */
+	TTU_MIGRATE_DEFERRED = 2,	/* deferred [lazy] migration mode */
+	TTU_MUNLOCK = 4,		/* munlock mode */
 	TTU_ACTION_MASK = 0xff,
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1094,8 +1094,7 @@ static long do_mbind(unsigned long start
 	int err;
 	LIST_HEAD(pagelist);
 
-	if (flags & ~(unsigned long)(MPOL_MF_STRICT |
-				     MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+  	if (flags & ~(unsigned long)MPOL_MF_VALID)
 		return -EINVAL;
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
 		return -EPERM;
@@ -1154,21 +1153,26 @@ static long do_mbind(unsigned long start
 	vma = check_range(mm, start, end, nmask,
 			  flags | MPOL_MF_INVERT, &pagelist);
 
-	err = PTR_ERR(vma);
-	if (!IS_ERR(vma)) {
-		int nr_failed = 0;
-
+	err = PTR_ERR(vma);	/* maybe ... */
+	if (!IS_ERR(vma))
 		err = mbind_range(mm, start, end, new);
 
+	if (!err) {
+		int nr_failed = 0;
+
 		if (!list_empty(&pagelist)) {
-			nr_failed = migrate_pages(&pagelist, new_vma_page,
+			if (flags & MPOL_MF_LAZY)
+				nr_failed = migrate_pages_unmap_only(&pagelist);
+			else {
+				nr_failed = migrate_pages(&pagelist, new_vma_page,
 						(unsigned long)vma,
 						false, true);
+			}
 			if (nr_failed)
 				putback_lru_pages(&pagelist);
 		}
 
-		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
+		if (nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
 	} else
 		putback_lru_pages(&pagelist);
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -802,7 +802,7 @@ static int __unmap_and_move(struct page 
 	}
 
 	/* Establish migration ptes or remove ptes */
-	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(page, TTU_MIGRATE_DIRECT|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
 skip_unmap:
 	if (!page_mapped(page))
@@ -920,7 +920,7 @@ static int unmap_and_move_huge_page(new_
 	if (PageAnon(hpage))
 		anon_vma = page_get_anon_vma(hpage);
 
-	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(hpage, TTU_MIGRATE_DIRECT|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
 	if (!page_mapped(hpage))
 		rc = move_to_new_page(new_hpage, hpage, 1, mode);
@@ -950,6 +950,98 @@ static int unmap_and_move_huge_page(new_
 }
 
 /*
+ * Lazy migration:  just unmap pages, moving anon pages to swap cache, if
+ * necessary.  Migration will occur, if policy dictates, when a task faults
+ * an unmapped page back into its page table--i.e., on "first touch" after
+ * unmapping.  Note that migrate-on-fault only migrates pages whose mapping
+ * [e.g., file system] supplies a migratepage op, so we skip pages that
+ * wouldn't migrate on fault.
+ *
+ * Pages are placed back on the lru whether or not they were successfully
+ * unmapped.  Like migrate_pages().
+ *
+ * Unline migrate_pages(), this function is only called in the context of
+ * a task that is unmapping it's own pages while holding its map semaphore
+ * for write.
+ */
+int migrate_pages_unmap_only(struct list_head *pagelist)
+{
+	struct page *page;
+	struct page *page2;
+	int nr_failed = 0;
+	int nr_unmapped = 0;
+
+	list_for_each_entry_safe(page, page2, pagelist, lru) {
+		int ret;
+
+		cond_resched();
+
+		/*
+		 * Give up easily.  We ARE being lazy.
+		 */
+		if (page_count(page) == 1)
+			goto next;
+
+		if (unlikely(PageTransHuge(page)))
+			if (unlikely(split_huge_page(page)))
+				goto next;
+
+		if (!trylock_page(page))
+			goto next;
+
+		if (PageKsm(page) || PageWriteback(page))
+			goto unlock;
+
+		/*
+		 * see comments in unmap_and_move()
+		 */
+		if (!page->mapping)
+			goto unlock;
+
+		if (PageAnon(page)) {
+			if (!PageSwapCache(page) && !add_to_swap(page)) {
+				nr_failed++;
+				goto unlock;
+			}
+		} else {
+			struct address_space *mapping = page_mapping(page);
+			BUG_ON(!mapping);
+			if (!mapping->a_ops->migratepage)
+				goto unlock;
+		}
+
+		ret = try_to_unmap(page,
+	             TTU_MIGRATE_DEFERRED|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		if (ret != SWAP_SUCCESS || page_mapped(page))
+			nr_failed++;
+		else
+			nr_unmapped++;
+
+unlock:
+		unlock_page(page);
+next:
+		list_del(&page->lru);
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				page_is_file_cache(page));
+		putback_lru_page(page);
+
+	}
+
+	/*
+	 * Drain local per cpu pagevecs so fault path can find the the pages
+	 * on the lru.  If we got migrated during the loop above, we may
+	 * have left pages cached on other cpus.  But, we'll live with that
+	 * here to avoid lru_add_drain_all().
+	 * TODO:  mechanism to drain on only those cpus we've been
+	 *        scheduled on between two points--e.g., during the loop.
+	 */
+	if (nr_unmapped)
+		lru_add_drain();
+
+	return nr_failed;
+}
+
+/*
  * migrate_pages
  *
  * The function takes one list of pages to migrate and a function
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1288,12 +1288,13 @@ int try_to_unmap_one(struct page *page, 
 			 * pte. do_swap_page() will wait until the migration
 			 * pte is removed and then restart fault handling.
 			 */
-			BUG_ON(TTU_ACTION(flags) != TTU_MIGRATION);
+			BUG_ON(TTU_ACTION(flags) != TTU_MIGRATE_DIRECT);
 			entry = make_migration_entry(page, pte_write(pteval));
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
-	} else if (PAGE_MIGRATION && (TTU_ACTION(flags) == TTU_MIGRATION)) {
+	} else if (PAGE_MIGRATION &&
+		         (TTU_ACTION(flags) == TTU_MIGRATE_DIRECT)) {
 		/* Establish migration entry for a file page */
 		swp_entry_t entry;
 		entry = make_migration_entry(page, pte_write(pteval));
@@ -1499,7 +1500,7 @@ static int try_to_unmap_anon(struct page
 		 * locking requirements of exec(), migration skips
 		 * temporary VMAs until after exec() completes.
 		 */
-		if (PAGE_MIGRATION && (flags & TTU_MIGRATION) &&
+		if (PAGE_MIGRATION && (flags & TTU_MIGRATE_DIRECT) &&
 				is_vma_temporary_stack(vma))
 			continue;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
