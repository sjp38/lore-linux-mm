Date: Mon, 8 May 2006 23:52:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060509065207.24194.23387.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060509065146.24194.47401.sendpatchset@schroedinger.engr.sgi.com>
References: <20060509065146.24194.47401.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 5/5] page migration: Replace call to pageout() with writepage()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

page migration: Do not use pageout() but writepage() for fallback.

Migration cannot use pageout for fallback since the migration entries have
to be removed before calling writepage. writepage (and therefore pageout)
may drop the lock and expose migration entries. Removing migration
entries in turn increases the mapcount which results in pageout()
not writing out the page. sigh.

This problem was re-introduced with the use of migration entries for file
backed pages.

Implement our own writeout() function (this approach was posted already last
week but not included in the patch reorg) and undo the export of pageout()
since page migration was the only user of pageout().

Also remove a definition for remove_vma_swap() that was somehow left over
from earlier changes.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3-mm1.orig/mm/migrate.c	2006-05-08 23:11:42.859814459 -0700
+++ linux-2.6.17-rc3-mm1/mm/migrate.c	2006-05-08 23:13:15.904821312 -0700
@@ -24,6 +24,7 @@
 #include <linux/topology.h>
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
+#include <linux/writeback.h>
 
 #include "internal.h"
 
@@ -468,28 +469,58 @@ int buffer_migrate_page(struct address_s
 EXPORT_SYMBOL(buffer_migrate_page);
 
 /*
- * Default handling if a filesystem does not provide a migration function.
+ * Writeback a page to clean the dirty state
  */
-static int fallback_migrate_page(struct address_space *mapping,
-	struct page *newpage, struct page *page)
+static int writeout(struct address_space *mapping, struct page *page)
 {
-	if (PageDirty(page)) {
-		/*
-		 * A dirty page may imply that the underlying filesystem has
-		 * the page on some queue. So the page must be clean for
-		 * migration. Writeout may mean we loose the lock and the
-		 * page state is no longer what we checked for earlier.
-		 * At this point we know that the migration attempt cannot
-		 * be successful.
-		 */
-		remove_migration_ptes(page, page);
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+		.nr_to_write = 1,
+		.range_start = 0,
+		.range_end = LLONG_MAX,
+		.nonblocking = 1,
+		.for_reclaim = 1
+	};
+	int rc;
 
-		if (pageout(page, mapping) == PAGE_SUCCESS)
-			/* unlocked. Relock */
-			lock_page(page);
+	if (!mapping->a_ops->writepage)
+		/* No write method for the address space */
+		return -EINVAL;
 
+	if (!clear_page_dirty_for_io(page))
+		/* Someone else already triggered a write */
 		return -EAGAIN;
-	}
+
+	/*
+	 * A dirty page may imply that the underlying filesystem has
+	 * the page on some queue. So the page must be clean for
+	 * migration. Writeout may mean we loose the lock and the
+	 * page state is no longer what we checked for earlier.
+	 * At this point we know that the migration attempt cannot
+	 * be successful.
+	 */
+	remove_migration_ptes(page, page);
+
+	rc = mapping->a_ops->writepage(page, &wbc);
+	if (rc < 0)
+		/* I/O Error writing */
+		return -EIO;
+
+	if (rc != AOP_WRITEPAGE_ACTIVATE)
+		/* unlocked. Relock */
+		lock_page(page);
+
+	return -EAGAIN;
+}
+
+/*
+ * Default handling if a filesystem does not provide a migration function.
+ */
+static int fallback_migrate_page(struct address_space *mapping,
+	struct page *newpage, struct page *page)
+{
+	if (PageDirty(page))
+		return writeout(mapping, page);
 
 	/*
 	 * Buffers may be managed in a filesystem specific way.
Index: linux-2.6.17-rc3-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.17-rc3-mm1.orig/include/linux/swap.h	2006-05-08 01:44:39.629546798 -0700
+++ linux-2.6.17-rc3-mm1/include/linux/swap.h	2006-05-08 23:13:15.960481920 -0700
@@ -188,20 +188,6 @@ extern unsigned long shrink_all_memory(u
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 
-/* possible outcome of pageout() */
-typedef enum {
-	/* failed to write page out, page is locked */
-	PAGE_KEEP,
-	/* move page to the active list, page is locked */
-	PAGE_ACTIVATE,
-	/* page has been sent to the disk successfully, page is unlocked */
-	PAGE_SUCCESS,
-	/* page is clean and locked */
-	PAGE_CLEAN,
-} pageout_t;
-
-extern pageout_t pageout(struct page *page, struct address_space *mapping);
-
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
 extern int zone_reclaim_interval;
@@ -264,7 +250,6 @@ extern int remove_exclusive_swap_page(st
 struct backing_dev_info;
 
 extern spinlock_t swap_lock;
-extern int remove_vma_swap(struct vm_area_struct *vma, struct page *page);
 
 /* linux/mm/thrash.c */
 extern struct mm_struct * swap_token_mm;
Index: linux-2.6.17-rc3-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.17-rc3-mm1.orig/mm/vmscan.c	2006-05-08 00:48:20.410392574 -0700
+++ linux-2.6.17-rc3-mm1/mm/vmscan.c	2006-05-08 23:13:15.975129449 -0700
@@ -291,11 +291,23 @@ static void handle_write_error(struct ad
 	unlock_page(page);
 }
 
+/* possible outcome of pageout() */
+typedef enum {
+	/* failed to write page out, page is locked */
+	PAGE_KEEP,
+	/* move page to the active list, page is locked */
+	PAGE_ACTIVATE,
+	/* page has been sent to the disk successfully, page is unlocked */
+	PAGE_SUCCESS,
+	/* page is clean and locked */
+	PAGE_CLEAN,
+} pageout_t;
+
 /*
  * pageout is called by shrink_page_list() for each dirty page.
  * Calls ->writepage().
  */
-pageout_t pageout(struct page *page, struct address_space *mapping)
+static pageout_t pageout(struct page *page, struct address_space *mapping)
 {
 	/*
 	 * If the page is dirty, only perform writeback if that write

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
