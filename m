Date: Fri, 28 Apr 2006 20:23:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032322.4999.77950.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 7/7] PM cleanup: Move fallback handling into special function
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

page migration: Add new fallback function

Move the fallback code into a new fallback function and make the
function behave like any other migration function. This requires
retaking the lock if pageout() drops it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-28 18:12:58.595320357 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-04-28 18:25:47.893218995 -0700
@@ -349,6 +349,42 @@
 }
 EXPORT_SYMBOL(buffer_migrate_page);
 
+static int fallback_migrate_page(struct address_space *mapping,
+	struct page *newpage, struct page *page)
+{
+	/*
+	 * Default handling if a filesystem does not provide
+	 * a migration function. We can only migrate clean
+	 * pages so try to write out any dirty pages first.
+	 */
+	if (PageDirty(page)) {
+		switch (pageout(page, mapping)) {
+		case PAGE_KEEP:
+		case PAGE_ACTIVATE:
+			return -EAGAIN;
+
+		case PAGE_SUCCESS:
+			/* Relock since we lost the lock */
+			lock_page(page);
+			/* Must retry since page state may have changed */
+			return -EAGAIN;
+
+		case PAGE_CLEAN:
+			; /* try to migrate the page below */
+		}
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
+	return migrate_page(mapping, newpage, page);
+}
+
 /*
  * migrate_pages
  *
@@ -478,7 +514,7 @@
 		if (!mapping)
 			goto unlock_both;
 
-		if (mapping->a_ops->migratepage) {
+		if (mapping->a_ops->migratepage)
 			/*
 			 * Most pages have a mapping and most filesystems
 			 * should provide a migration function. Anonymous
@@ -488,56 +524,8 @@
 			 */
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
-
-		/*
-		 * On early passes with mapped pages simply
-		 * retry. There may be a lock held for some
-		 * buffers that may go away. Later
-		 * swap them out.
-		 */
-		if (pass > 4) {
-			/*
-			 * Persistently unable to drop buffers..... As a
-			 * measure of last resort we fall back to
-			 * swap_page().
-			 */
-			unlock_page(newpage);
-			newpage = NULL;
-			rc = swap_page(page);
-			goto next;
-		}
+		else
+			rc = fallback_migrate_page(mapping, newpage, page);
 
 unlock_both:
 		unlock_page(newpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
