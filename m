Date: Fri, 28 Apr 2006 20:23:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032338.4999.4264.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/3] Swapless PM: Modify core logic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Use the migration entries for page migration

This modifies the migration code to use the new migration entries.  It now
becomes possible to migrate anonymous pages without having to add a swap
entry.

We add a couple of new functions to replace migration entries with the proper
ptes.

We cannot take the tree_lock for migrating anonymous pages anymore.  However,
we know that we hold the only remaining reference to the page when the page
count reaches 1.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-rc3/mm/Kconfig
===================================================================
--- linux-2.6.17-rc3.orig/mm/Kconfig	2006-04-26 19:19:25.000000000 -0700
+++ linux-2.6.17-rc3/mm/Kconfig	2006-04-28 20:11:44.644703353 -0700
@@ -138,8 +138,8 @@
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
Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-28 20:11:39.065947928 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-04-28 20:12:15.213119206 -0700
@@ -258,6 +258,13 @@
 {
 	struct page **radix_pointer;
 
+	if (!mapping) {
+		/* Anonymous page */
+		if (page_count(page) != 1 || !page->mapping)
+			return -EAGAIN;
+		return 0;
+	}
+
 	write_lock_irq(&mapping->tree_lock);
 
 	radix_pointer = (struct page **)radix_tree_lookup_slot(
@@ -275,10 +282,12 @@
 	 * Now we know that no one else is looking at the page.
 	 */
 	get_page(newpage);
+#ifdef CONFIG_SWAP
 	if (PageSwapCache(page)) {
 		SetPageSwapCache(newpage);
 		set_page_private(newpage, page_private(page));
 	}
+#endif
 
 	*radix_pointer = newpage;
 	__put_page(page);
@@ -312,7 +321,9 @@
 		set_page_dirty(newpage);
  	}
 
+#ifdef CONFIG_SWAP
 	ClearPageSwapCache(page);
+#endif
 	ClearPageActive(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
@@ -357,16 +368,6 @@
 		return rc;
 
 	migrate_page_copy(newpage, page);
-
-	/*
-	 * Remove auxiliary swap entries and replace
-	 * them with real ptes.
-	 *
-	 * Note that a real pte entry will allow processes that are not
-	 * waiting on the page lock to use the new page via the page tables
-	 * before the new page is unlocked.
-	 */
-	remove_from_swap(newpage);
 	return 0;
 }
 EXPORT_SYMBOL(migrate_page);
@@ -534,23 +535,7 @@
 				goto unlock_page;
 
 		/*
-		 * Establish swap ptes for anonymous pages or destroy pte
-		 * maps for files.
-		 *
-		 * In order to reestablish file backed mappings the fault handlers
-		 * will take the radix tree_lock which may then be used to stop
-	  	 * processses from accessing this page until the new page is ready.
-		 *
-		 * A process accessing via a swap pte (an anonymous page) will take a
-		 * page_lock on the old page which will block the process until the
-		 * migration attempt is complete. At that time the PageSwapCache bit
-		 * will be examined. If the page was migrated then the PageSwapCache
-		 * bit will be clear and the operation to retrieve the page will be
-		 * retried which will find the new page in the radix tree. Then a new
-		 * direct mapping may be generated based on the radix tree contents.
-		 *
-		 * If the page was not migrated then the PageSwapCache bit
-		 * is still set and the operation may continue.
+		 * Establish migration ptes or remove ptes
 		 */
 		rc = -EPERM;
 		if (try_to_unmap(page, 1) == SWAP_FAIL)
@@ -573,9 +558,9 @@
 		 */
 		mapping = page_mapping(page);
 		if (!mapping)
-			goto unlock_both;
+			rc = migrate_page(mapping, newpage, page);
 
-		if (mapping->a_ops->migratepage)
+		else if (mapping->a_ops->migratepage)
 			/*
 			 * Most pages have a mapping and most filesystems
 			 * should provide a migration function. Anonymous
@@ -588,10 +573,15 @@
 		else
 			rc = fallback_migrate_page(mapping, newpage, page);
 
-unlock_both:
+		if (!rc)
+			remove_migration_ptes(page, newpage);
+
 		unlock_page(newpage);
 
 unlock_page:
+		if (rc)
+			remove_migration_ptes(page, page);
+
 		unlock_page(page);
 
 next:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
