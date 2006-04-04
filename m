Date: Mon, 3 Apr 2006 23:58:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060404065810.24532.30027.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 6/6] Swapless V1: Revise main migration logic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

New migration scheme

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc1.orig/mm/migrate.c	2006-04-03 23:44:31.000000000 -0700
+++ linux-2.6.17-rc1/mm/migrate.c	2006-04-03 23:48:02.000000000 -0700
@@ -151,27 +151,21 @@ int migrate_page_remove_references(struc
 	 * indicates that the page is in use or truncate has removed
 	 * the page.
 	 */
-	if (!mapping || page_mapcount(page) + nr_refs != page_count(page))
-		return -EAGAIN;
+	if (!page->mapping ||
+		page_mapcount(page) + nr_refs + !!mapping != page_count(page))
+			return -EAGAIN;
 
 	/*
-	 * Establish swap ptes for anonymous pages or destroy pte
+	 * Establish migration ptes for anonymous pages or destroy pte
 	 * maps for files.
 	 *
 	 * In order to reestablish file backed mappings the fault handlers
 	 * will take the radix tree_lock which may then be used to stop
   	 * processses from accessing this page until the new page is ready.
 	 *
-	 * A process accessing via a swap pte (an anonymous page) will take a
-	 * page_lock on the old page which will block the process until the
-	 * migration attempt is complete. At that time the PageSwapCache bit
-	 * will be examined. If the page was migrated then the PageSwapCache
-	 * bit will be clear and the operation to retrieve the page will be
-	 * retried which will find the new page in the radix tree. Then a new
-	 * direct mapping may be generated based on the radix tree contents.
-	 *
-	 * If the page was not migrated then the PageSwapCache bit
-	 * is still set and the operation may continue.
+	 * A process accessing via a migration pte (an anonymous page) will
+	 * take a  page_lock on the old page which will block the process
+	 * until the migration attempt is complete.
 	 */
 	if (try_to_unmap(page, 1) == SWAP_FAIL)
 		/* A vma has VM_LOCKED set -> permanent failure */
@@ -183,13 +177,19 @@ int migrate_page_remove_references(struc
 	if (page_mapcount(page))
 		return -EAGAIN;
 
+	if (!mapping)
+		return 0;	/* Anonymous page without swap */
+
+	/*
+	 * Page has a mapping that we need to change
+	 */
 	write_lock_irq(&mapping->tree_lock);
 
 	radix_pointer = (struct page **)radix_tree_lookup_slot(
 						&mapping->page_tree,
 						page_index(page));
 
-	if (!page_mapping(page) || page_count(page) != nr_refs ||
+	if (!page_mapping(page) || page_count(page) != nr_refs + 1 ||
 			*radix_pointer != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
@@ -206,11 +206,12 @@ int migrate_page_remove_references(struc
 	get_page(newpage);
 	newpage->index = page->index;
 	newpage->mapping = page->mapping;
+#ifdef CONFIG_SWAP
 	if (PageSwapCache(page)) {
 		SetPageSwapCache(newpage);
 		set_page_private(newpage, page_private(page));
 	}
-
+#endif
 	*radix_pointer = newpage;
 	__put_page(page);
 	write_unlock_irq(&mapping->tree_lock);
@@ -244,7 +245,9 @@ void migrate_page_copy(struct page *newp
 		set_page_dirty(newpage);
  	}
 
+#ifdef CONFIG_SWAP
 	ClearPageSwapCache(page);
+#endif
 	ClearPageActive(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
@@ -271,10 +274,12 @@ int migrate_page(struct page *newpage, s
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_remove_references(newpage, page, 2);
+	rc = migrate_page_remove_references(newpage, page, 1);
 
-	if (rc)
+	if (rc) {
+		remove_migration_ptes(page, page);
 		return rc;
+	}
 
 	migrate_page_copy(newpage, page);
 
@@ -286,7 +291,7 @@ int migrate_page(struct page *newpage, s
 	 * waiting on the page lock to use the new page via the page tables
 	 * before the new page is unlocked.
 	 */
-	remove_from_swap(newpage);
+	remove_migration_ptes(page, newpage);
 	return 0;
 }
 EXPORT_SYMBOL(migrate_page);
@@ -368,9 +373,12 @@ redo:
 		 * Try to migrate the page.
 		 */
 		mapping = page_mapping(page);
-		if (!mapping)
+		if (!mapping) {
+
+			rc = migrate_page(newpage, page);
 			goto unlock_both;
 
+		} else
 		if (mapping->a_ops->migratepage) {
 			/*
 			 * Most pages have a mapping and most filesystems
@@ -462,7 +470,7 @@ int buffer_migrate_page(struct page *new
 
 	head = page_buffers(page);
 
-	rc = migrate_page_remove_references(newpage, page, 3);
+	rc = migrate_page_remove_references(newpage, page, 2);
 
 	if (rc)
 		return rc;
Index: linux-2.6.17-rc1/mm/Kconfig
===================================================================
--- linux-2.6.17-rc1.orig/mm/Kconfig	2006-04-02 20:22:10.000000000 -0700
+++ linux-2.6.17-rc1/mm/Kconfig	2006-04-03 23:44:31.000000000 -0700
@@ -138,8 +138,8 @@ config SPLIT_PTLOCK_CPUS
 #
 config MIGRATION
 	bool "Page migration"
-	def_bool y if NUMA
-	depends on SWAP && NUMA
+	def_bool y
+	depends on NUMA
 	help
 	  Allows the migration of the physical location of pages of processes
 	  while the virtual addresses are not changed. This is useful for

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
