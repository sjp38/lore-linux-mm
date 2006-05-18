Date: Thu, 18 May 2006 11:21:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060518182116.20734.48633.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
References: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 1/5] page migration: simplify migrate_pages()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, bls@sgi.com, jes@sgi.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

page migration: Simplify migrate_pages()

Currently migrate_pages() is mess with lots of goto.
Extract two functions from migrate_pages() and get rid of the gotos.

Plus we can just unconditionally set the locked bit on the new page
since we are the only one holding a reference. Locking is to
stop others from accessing the page once we establish references
to the new page.

Remove the list_del from move_to_lru in order to have finer control
over list processing.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/mm/migrate.c	2006-05-15 15:40:13.214835974 -0700
+++ linux-2.6.17-rc4-mm1/mm/migrate.c	2006-05-18 09:41:59.814842493 -0700
@@ -84,7 +84,6 @@ int migrate_prep(void)
 
 static inline void move_to_lru(struct page *page)
 {
-	list_del(&page->lru);
 	if (PageActive(page)) {
 		/*
 		 * lru_cache_add_active checks that
@@ -110,6 +109,7 @@ int putback_lru_pages(struct list_head *
 	int count = 0;
 
 	list_for_each_entry_safe(page, page2, l, lru) {
+		list_del(&page->lru);
 		move_to_lru(page);
 		count++;
 	}
@@ -534,11 +534,108 @@ static int fallback_migrate_page(struct 
 }
 
 /*
+ * Move a page to a newly allocated page
+ * The page is locked and all ptes have been successfully removed.
+ *
+ * The new page will have replaced the old page if this function
+ * is successful.
+ */
+static int move_to_new_page(struct page *newpage, struct page *page)
+{
+	struct address_space *mapping;
+	int rc;
+
+	/*
+	 * Block others from accessing the page when we get around to
+	 * establishing additional references. We are the only one
+	 * holding a reference to the new page at this point.
+	 */
+	SetPageLocked(newpage);
+
+	/* Prepare mapping for the new page.*/
+	newpage->index = page->index;
+	newpage->mapping = page->mapping;
+
+	mapping = page_mapping(page);
+	if (!mapping)
+		rc = migrate_page(mapping, newpage, page);
+
+	else if (mapping->a_ops->migratepage)
+		/*
+		 * Most pages have a mapping and most filesystems
+		 * should provide a migration function. Anonymous
+		 * pages are part of swap space which also has its
+		 * own migration function. This is the most common
+		 * path for page migration.
+		 */
+		rc = mapping->a_ops->migratepage(mapping,
+						newpage, page);
+	else
+		rc = fallback_migrate_page(mapping, newpage, page);
+
+	if (!rc)
+		remove_migration_ptes(page, newpage);
+	else
+		newpage->mapping = NULL;
+
+	unlock_page(newpage);
+
+	return rc;
+}
+
+/*
+ * Obtain the lock on page, remove all ptes and migrate the page
+ * to the newly allocated page in newpage.
+ */
+static int unmap_and_move(struct page *newpage, struct page *page, int force)
+{
+	int rc = 0;
+
+	if (page_count(page) == 1)
+		/* page was freed from under us. So we are done. */
+		goto ret;
+
+	rc = -EAGAIN;
+	if (TestSetPageLocked(page)) {
+		if (!force)
+			goto ret;
+		lock_page(page);
+	}
+
+	if (PageWriteback(page)) {
+		if (!force)
+			goto unlock;
+		wait_on_page_writeback(page);
+	}
+
+	/*
+	 * Establish migration ptes or remove ptes
+	 */
+	if (try_to_unmap(page, 1) != SWAP_FAIL) {
+		if (!page_mapped(page))
+			rc = move_to_new_page(newpage, page);
+	} else
+		/* A vma has VM_LOCKED set -> permanent failure */
+		rc = -EPERM;
+
+	if (rc)
+		remove_migration_ptes(page, page);
+unlock:
+	unlock_page(page);
+ret:
+	if (rc != -EAGAIN) {
+		list_del(&newpage->lru);
+		move_to_lru(newpage);
+	}
+	return rc;
+}
+
+/*
  * migrate_pages
  *
  * Two lists are passed to this function. The first list
  * contains the pages isolated from the LRU to be migrated.
- * The second list contains new pages that the pages isolated
+ * The second list contains new pages that the isolated pages
  * can be moved to.
  *
  * The function returns after 10 attempts or if no pages
@@ -550,7 +647,7 @@ static int fallback_migrate_page(struct 
 int migrate_pages(struct list_head *from, struct list_head *to,
 		  struct list_head *moved, struct list_head *failed)
 {
-	int retry;
+	int retry = 1;
 	int nr_failed = 0;
 	int pass = 0;
 	struct page *page;
@@ -561,118 +658,33 @@ int migrate_pages(struct list_head *from
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
 
-redo:
-	retry = 0;
-
-	list_for_each_entry_safe(page, page2, from, lru) {
-		struct page *newpage = NULL;
-		struct address_space *mapping;
-
-		cond_resched();
-
-		rc = 0;
-		if (page_count(page) == 1)
-			/* page was freed from under us. So we are done. */
-			goto next;
-
-		if (to && list_empty(to))
-			break;
-
-		/*
-		 * Skip locked pages during the first two passes to give the
-		 * functions holding the lock time to release the page. Later we
-		 * use lock_page() to have a higher chance of acquiring the
-		 * lock.
-		 */
-		rc = -EAGAIN;
-		if (pass > 2)
-			lock_page(page);
-		else
-			if (TestSetPageLocked(page))
-				goto next;
-
-		/*
-		 * Only wait on writeback if we have already done a pass where
-		 * we we may have triggered writeouts for lots of pages.
-		 */
-		if (pass > 0)
-			wait_on_page_writeback(page);
-		else
-			if (PageWriteback(page))
-				goto unlock_page;
+	for(pass = 0; pass < 10 && retry; pass++) {
+		retry = 0;
 
-		/*
-		 * Establish migration ptes or remove ptes
-		 */
-		rc = -EPERM;
-		if (try_to_unmap(page, 1) == SWAP_FAIL)
-			/* A vma has VM_LOCKED set -> permanent failure */
-			goto unlock_page;
-
-		rc = -EAGAIN;
-		if (page_mapped(page))
-			goto unlock_page;
-
-		newpage = lru_to_page(to);
-		lock_page(newpage);
-		/* Prepare mapping for the new page.*/
-		newpage->index = page->index;
-		newpage->mapping = page->mapping;
+		list_for_each_entry_safe(page, page2, from, lru) {
 
-		/*
-		 * Pages are properly locked and writeback is complete.
-		 * Try to migrate the page.
-		 */
-		mapping = page_mapping(page);
-		if (!mapping)
-			rc = migrate_page(mapping, newpage, page);
+			if (list_empty(to))
+				break;
 
-		else if (mapping->a_ops->migratepage)
-			/*
-			 * Most pages have a mapping and most filesystems
-			 * should provide a migration function. Anonymous
-			 * pages are part of swap space which also has its
-			 * own migration function. This is the most common
-			 * path for page migration.
-			 */
-			rc = mapping->a_ops->migratepage(mapping,
-							newpage, page);
-		else
-			rc = fallback_migrate_page(mapping, newpage, page);
-
-		if (!rc)
-			remove_migration_ptes(page, newpage);
-
-		unlock_page(newpage);
+			cond_resched();
 
-unlock_page:
-		if (rc)
-			remove_migration_ptes(page, page);
+			rc = unmap_and_move(lru_to_page(to), page, pass > 2);
 
-		unlock_page(page);
-
-next:
-		if (rc) {
-			if (newpage)
-				newpage->mapping = NULL;
-
-			if (rc == -EAGAIN)
+			switch(rc) {
+			case -EAGAIN:
 				retry++;
-			else {
+				break;
+			case 0:
+				list_move(&page->lru, moved);
+				break;
+			default:
 				/* Permanent failure */
 				list_move(&page->lru, failed);
 				nr_failed++;
+				break;
 			}
-		} else {
-			if (newpage) {
-				/* Successful migration. Return page to LRU */
-				move_to_lru(newpage);
-			}
-			list_move(&page->lru, moved);
 		}
 	}
-	if (retry && pass++ < 10)
-		goto redo;
 
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
