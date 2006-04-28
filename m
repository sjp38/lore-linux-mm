Date: Thu, 27 Apr 2006 23:03:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060428060333.30257.43096.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 7/7] page migration: Add new fallback function
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

page migration: Add new fallback function that checks properly for dirty pages

Add a new migration function that checks for PageDirty after unmapping
the ptes. It then directly writes out the page without relying on pageout().

Add some logic to deal with writepage() potentially unlocking the page.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-27 21:34:12.171976982 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-27 22:52:35.363141399 -0700
@@ -24,6 +24,7 @@
 #include <linux/topology.h>
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
+#include <linux/writeback.h>
 
 #include "internal.h"
 
@@ -445,6 +446,66 @@
 }
 EXPORT_SYMBOL(buffer_migrate_page);
 
+static int fallback_migrate_page(struct address_space *mapping,
+		struct page *newpage, struct page *page)
+{
+	int rc;
+
+	if (try_to_unmap(page, 1) == SWAP_FAIL)
+		/* A vma has VM_LOCKED set -> permanent failure */
+		return -EPERM;
+
+	/*
+	 * Removing the ptes may have dirtied the page
+	 */
+	if (PageDirty(page)) {
+		struct writeback_control wbc = {
+			.sync_mode = WB_SYNC_NONE,
+			.nr_to_write = 1,
+			.range_start = 0,
+			.range_end = LLONG_MAX,
+			.nonblocking = 1,
+			.for_reclaim = 1
+		};
+
+		if (!mapping->a_ops->writepage)
+			/* No write method for the address space */
+			return -EINVAL;
+
+		if (!clear_page_dirty_for_io(page))
+			/* Someone else already triggered a write */
+			return -EAGAIN;
+
+		if (mapping->a_ops->writepage(page, &wbc) < 0)
+			/* I/O Error writing */
+			return -EIO;
+
+		/*
+		 * Retry if writepage() removed the lock or the page
+		 * is still dirty or undergoing writeback.
+		 */
+		if (!PageLocked(page) ||
+			PageWriteback(page) || PageDirty(page))
+				return -EAGAIN;
+	}
+
+	/*
+	 * Buffers are managed in a filesystem specific way.
+	 * We must have no buffers or drop them.
+	 */
+	if (page_has_buffers(page) &&
+	    !try_to_release_page(page, GFP_KERNEL))
+		return -EAGAIN;
+
+	rc = migrate_page_move_mapping(mapping, newpage, page);
+
+	if (rc)
+		return rc;
+
+	migrate_page_copy(newpage, page);
+	return 0;
+}
+
 /*
  * migrate_pages
  *
@@ -527,59 +588,19 @@
 		 * Try to migrate the page.
 		 */
 		mapping = page_mapping(page);
-		if (!mapping) {
+		if (!mapping)
 			rc = migrate_page(mapping, newpage, page);
-			goto unlock_both;
 
-		} else
-		if (mapping->a_ops->migratepage) {
-			/*
-			 * Most pages have a mapping and most filesystems
-			 * should provide a migration function. Anonymous
-			 * pages are part of swap space which also has its
-			 * own migration function. This is the most common
-			 * path for page migration.
-			 */
+		else if (mapping->a_ops->migratepage)
 			rc = mapping->a_ops->migratepage(mapping,
 							newpage, page);
-			goto unlock_both;
-                }
-
-		/*
-		 * Default handling if a filesystem does not provide
-		 * a migration function. We can only migrate clean
-		 * pages so try to write out any dirty pages first.
-		 */
-		if (PageDirty(page)) {
-			switch (pageout(page, mapping)) {
-			case PAGE_KEEP:
-			case PAGE_ACTIVATE:
-				goto unlock_both;
-
-			case PAGE_SUCCESS:
-				unlock_page(newpage);
-				goto next;
-
-			case PAGE_CLEAN:
-				; /* try to migrate the page below */
-			}
-                }
-
-		/*
-		 * Buffers are managed in a filesystem specific way.
-		 * We must have no buffers or drop them.
-		 */
-		if (!page_has_buffers(page) ||
-		    try_to_release_page(page, GFP_KERNEL)) {
-			rc = migrate_page(mapping, newpage, page);
-			goto unlock_both;
-		}
+		else
+			rc = fallback_migrate_page(mapping, newpage, page);
 
-unlock_both:
 		unlock_page(newpage);
-
 unlock_page:
-		unlock_page(page);
+		if (PageLocked(page))	/* writepage() may unlock */
+			unlock_page(page);
 
 next:
 		if (rc) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
