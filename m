Date: Mon, 8 May 2006 23:51:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060509065151.24194.83295.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060509065146.24194.47401.sendpatchset@schroedinger.engr.sgi.com>
References: <20060509065146.24194.47401.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/5] page migration: Update comments
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Fix comments

Edit comments to be nicer better and reflect the current state
of page migration.

Remove useless BUG_ON() in migrate_entry_wait() since
migration_entry_to_page() already does a BUG_ON().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.17-rc3-mm1.orig/include/linux/swap.h	2006-05-01 09:48:43.178275544 -0700
+++ linux-2.6.17-rc3-mm1/include/linux/swap.h	2006-05-04 22:55:37.540218299 -0700
@@ -32,7 +32,7 @@ static inline int current_is_kswapd(void
 #ifndef CONFIG_MIGRATION
 #define MAX_SWAPFILES		(1 << MAX_SWAPFILES_SHIFT)
 #else
-/* Use last entry for page migration swap entries */
+/* Use last two entries for page migration swap entries */
 #define MAX_SWAPFILES		((1 << MAX_SWAPFILES_SHIFT)-2)
 #define SWP_MIGRATION_READ	MAX_SWAPFILES
 #define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + 1)
Index: linux-2.6.17-rc3-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3-mm1.orig/mm/migrate.c	2006-05-01 09:48:43.581570781 -0700
+++ linux-2.6.17-rc3-mm1/mm/migrate.c	2006-05-04 22:55:37.541194801 -0700
@@ -121,8 +121,7 @@ static inline int is_swap_pte(pte_t pte)
 }
 
 /*
- * Restore a potential migration pte to a working pte entry for
- * anonymous pages.
+ * Restore a potential migration pte to a working pte entry
  */
 static void remove_migration_pte(struct vm_area_struct *vma, unsigned long addr,
 		struct page *old, struct page *new)
@@ -181,9 +180,8 @@ out:
 }
 
 /*
- * Note that remove_file_migration_ptes will only work on regular mappings
- * specialized other mappings will simply be unmapped and do not use
- * migration entries.
+ * Note that remove_file_migration_ptes will only work on regular mappings,
+ * Nonlinear mappings do not use migration entries.
  */
 static void remove_file_migration_ptes(struct page *old, struct page *new)
 {
@@ -269,9 +267,6 @@ void migration_entry_wait(struct mm_stru
 
 	page = migration_entry_to_page(entry);
 
-	/* Pages with migration entries are always locked */
-	BUG_ON(!PageLocked(page));
-
 	get_page(page);
 	pte_unmap_unlock(ptep, ptl);
 	wait_on_page_locked(page);
@@ -282,7 +277,7 @@ out:
 }
 
 /*
- * Remove or replace the page in the mapping.
+ * Replace the page in the mapping.
  *
  * The number of remaining references must be:
  * 1 for anonymous pages without a mapping
@@ -466,19 +461,20 @@ int buffer_migrate_page(struct address_s
 }
 EXPORT_SYMBOL(buffer_migrate_page);
 
+/*
+ * Default handling if a filesystem does not provide a migration function.
+ */
 static int fallback_migrate_page(struct address_space *mapping,
 	struct page *newpage, struct page *page)
 {
-	/*
-	 * Default handling if a filesystem does not provide
-	 * a migration function. We can only migrate clean
-	 * pages so try to write out any dirty pages first.
-	 */
 	if (PageDirty(page)) {
 		/*
-		 * Remove the migration entries because pageout() may
-		 * unlock which may result in migration entries pointing
-		 * to unlocked pages.
+		 * A dirty page may imply that the underlying filesystem has
+		 * the page on some queue. So the page must be clean for
+		 * migration. Writeout may mean we loose the lock and the
+		 * page state is no longer what we checked for earlier.
+		 * At this point we know that the migration attempt cannot
+		 * be successful.
 		 */
 		remove_migration_ptes(page, page);
 
@@ -490,7 +486,7 @@ static int fallback_migrate_page(struct 
 	}
 
 	/*
-	 * Buffers are managed in a filesystem specific way.
+	 * Buffers may be managed in a filesystem specific way.
 	 * We must have no buffers or drop them.
 	 */
 	if (page_has_buffers(page) &&
Index: linux-2.6.17-rc3-mm1/Documentation/vm/page_migration
===================================================================
--- linux-2.6.17-rc3-mm1.orig/Documentation/vm/page_migration	2006-04-26 19:19:25.000000000 -0700
+++ linux-2.6.17-rc3-mm1/Documentation/vm/page_migration	2006-05-07 22:34:33.385854538 -0700
@@ -62,15 +62,15 @@ A. In kernel use of migrate_pages()
    It also prevents the swapper or other scans to encounter
    the page.
 
-2. Generate a list of newly allocates page. These pages will contain the
+2. Generate a list of newly allocates pages. These pages will contain the
    contents of the pages from the first list after page migration is
    complete.
 
 3. The migrate_pages() function is called which attempts
    to do the migration. It returns the moved pages in the
    list specified as the third parameter and the failed
-   migrations in the fourth parameter. The first parameter
-   will contain the pages that could still be retried.
+   migrations in the fourth parameter. When the function
+   returns the first list will contain the pages that could still be retried.
 
 4. The leftover pages of various types are returned
    to the LRU using putback_to_lru_pages() or otherwise
@@ -93,83 +93,58 @@ Steps:
 
 2. Insure that writeback is complete.
 
-3. Make sure that the page has assigned swap cache entry if
-   it is an anonyous page. The swap cache reference is necessary
-   to preserve the information contain in the page table maps while
-   page migration occurs.
-
-4. Prep the new page that we want to move to. It is locked
+3. Prep the new page that we want to move to. It is locked
    and set to not being uptodate so that all accesses to the new
    page immediately lock while the move is in progress.
 
-5. All the page table references to the page are either dropped (file
-   backed pages) or converted to swap references (anonymous pages).
-   This should decrease the reference count.
+4. The new page is prepped with some settings from the old page so that
+   accesses to the new page will discover a page with the correct settings.
+
+5. All the page table references to the page are converted
+   to migration entries or dropped (nonlinear vmas).
+   This decrease the mapcount of a page. If the resulting
+   mapcount is not zero then we do not migrate the page.
+   All user space processes that attempt to access the page
+   will now wait on the page lock.
 
 6. The radix tree lock is taken. This will cause all processes trying
-   to reestablish a pte to block on the radix tree spinlock.
+   to access the page via the mapping to block on the radix tree spinlock.
 
 7. The refcount of the page is examined and we back out if references remain
    otherwise we know that we are the only one referencing this page.
 
 8. The radix tree is checked and if it does not contain the pointer to this
-   page then we back out because someone else modified the mapping first.
-
-9. The mapping is checked. If the mapping is gone then a truncate action may
-   be in progress and we back out.
+   page then we back out because someone else modified the radix tree.
 
-10. The new page is prepped with some settings from the old page so that
-   accesses to the new page will be discovered to have the correct settings.
+9. The radix tree is changed to point to the new page.
 
-11. The radix tree is changed to point to the new page.
+10. The reference count of the old page is dropped because the radix tree
+    reference is gone. A reference to the new page is established because
+    the new page is referenced to by the radix tree.
 
-12. The reference count of the old page is dropped because the radix tree
-    reference is gone.
+11. The radix tree lock is dropped. With that lookups in the mapping
+    become possible again. Processes will move from spinning on the tree_lock
+    to sleeping on the locked new page.
 
-13. The radix tree lock is dropped. With that lookups become possible again
-    and other processes will move from spinning on the tree lock to sleeping on
-    the locked new page.
+12. The page contents are copied to the new page.
 
-14. The page contents are copied to the new page.
+13. The remaining page flags are copied to the new page.
 
-15. The remaining page flags are copied to the new page.
+14. The old page flags are cleared to indicate that the page does
+    not provide any information anymore.
 
-16. The old page flags are cleared to indicate that the page does
-    not use any information anymore.
+15. Queued up writeback on the new page is triggered.
 
-17. Queued up writeback on the new page is triggered.
-
-18. If swap pte's were generated for the page then replace them with real
-    ptes. This will reenable access for processes not blocked by the page lock.
+16. If migration entries were page then replace them with real ptes. Doing
+    so will enable access for user space processes not already waiting for
+    the page lock.
 
 19. The page locks are dropped from the old and new page.
-    Processes waiting on the page lock can continue.
+    Processes waiting on the page lock will redo their page faults
+    and will reach the new page.
 
 20. The new page is moved to the LRU and can be scanned by the swapper
     etc again.
 
-TODO list
----------
-
-- Page migration requires the use of swap handles to preserve the
-  information of the anonymous page table entries. This means that swap
-  space is reserved but never used. The maximum number of swap handles used
-  is determined by CHUNK_SIZE (see mm/mempolicy.c) per ongoing migration.
-  Reservation of pages could be avoided by having a special type of swap
-  handle that does not require swap space and that would only track the page
-  references. Something like that was proposed by Marcelo Tosatti in the
-  past (search for migration cache on lkml or linux-mm@kvack.org).
-
-- Page migration unmaps ptes for file backed pages and requires page
-  faults to reestablish these ptes. This could be optimized by somehow
-  recording the references before migration and then reestablish them later.
-  However, there are several locking challenges that have to be overcome
-  before this is possible.
-
-- Page migration generates read ptes for anonymous pages. Dirty page
-  faults are required to make the pages writable again. It may be possible
-  to generate a pte marked dirty if it is known that the page is dirty and
-  that this process has the only reference to that page.
-
-Christoph Lameter, March 8, 2006.
+Christoph Lameter, May 8, 2006.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
