Message-ID: <41DEBF90.4030400@sgi.com>
Date: Fri, 07 Jan 2005 10:57:52 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: migration cache, updated
References: <41D99743.5000601@sgi.com>	<1104781061.25994.19.camel@localhost>	 <41D9A7DB.2020306@sgi.com> <20050104.234207.74734492.taka@valinux.co.jp>	 <41DAD2AF.80604@sgi.com> <1104860456.7581.21.camel@localhost> <41DADFB9.2090607@sgi.com>
In-Reply-To: <41DADFB9.2090607@sgi.com>
Content-Type: multipart/mixed;
 boundary="------------010502000007070108010506"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010502000007070108010506
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Marcello,

Attached is a patch which fixes some compiler warnings in mmigrate.c
that I was getting with the migration cache code.  The only substantive
change was to change:

         /* Wait for all operations against the page to finish. */
         ret = migrate_fn(page, newpage, &vlist);
         switch (ret) {
         default:
                 /* The page is busy. Try it later. */
                 goto out_busy;
         case -ENOENT:
                 /* The file the page belongs to has been truncated. */
                 page_cache_get(page);
                 page_cache_release(newpage);
                 newpage->mapping = NULL;
                 /* fall thru */
         case 0:
                 /* fall thru */
         }

in generic_migrate_page(), to:

         /* Wait for all operations against the page to finish. */
         ret = migrate_fn(page, newpage, &vlist);
         switch (ret) {
         case -ENOENT:
                 /* The file the page belongs to has been truncated. */
                 page_cache_get(page);
                 page_cache_release(newpage);
                 newpage->mapping = NULL;
                 /* fall thru */
         case 0:
                 break;
         default:
                 /* The page is busy. Try it later. */
                 goto out_busy;
         }

This change was made to get rid of the warning:

mm/mmigrate.c:500: warning: deprecated use of label at end of compound statement

I suppose you used the previous order to eliminate an extra branch or
some such.  Do you have any other suggestion on how to eliminate that
warning?
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

--------------010502000007070108010506
Content-Type: text/plain;
 name="fix-migration-cache-warnings.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-migration-cache-warnings.patch"

Index: linux-2.6.10-rc2-mm4-page-migration-only/include/linux/swap.h
===================================================================
--- linux-2.6.10-rc2-mm4-page-migration-only.orig/include/linux/swap.h	2005-01-04 07:55:22.000000000 -0800
+++ linux-2.6.10-rc2-mm4-page-migration-only/include/linux/swap.h	2005-01-04 08:13:16.000000000 -0800
@@ -258,7 +258,7 @@ static inline int remove_exclusive_swap_
 {
 	return __remove_exclusive_swap_page(p, 0);
 }
-extern int migration_remove_entry(swp_entry_t);
+extern void migration_remove_entry(swp_entry_t);
 struct backing_dev_info;
 
 extern struct swap_list_t swap_list;
Index: linux-2.6.10-rc2-mm4-page-migration-only/mm/mmigrate.c
===================================================================
--- linux-2.6.10-rc2-mm4-page-migration-only.orig/mm/mmigrate.c	2005-01-04 07:55:22.000000000 -0800
+++ linux-2.6.10-rc2-mm4-page-migration-only/mm/mmigrate.c	2005-01-04 08:11:51.000000000 -0800
@@ -79,7 +79,6 @@ struct page *lookup_migration_cache(int 
 
 void migration_duplicate(swp_entry_t entry)
 {
-	int offset;
 	struct counter *cnt;
 
 	read_lock_irq(&migration_space.tree_lock);
@@ -96,32 +95,11 @@ void remove_from_migration_cache(struct 
         idr_remove(&migration_idr, id);
 	radix_tree_delete(&migration_space.page_tree, id);
 	ClearPageSwapCache(page);
-	page->private = NULL;
+	page->private = 0;
 	write_unlock_irq(&migration_space.tree_lock);
 }
 
-// FIXME: if the page is locked will it be correctly removed from migr cache?
-// check races
-
-int migration_remove_entry(swp_entry_t entry)
-{
-	struct page *page;
-	
-	page = find_get_page(&migration_space, entry.val);
-
-	if (!page)
-		BUG();
-
-	lock_page(page);	
-
-	migration_remove_reference(page, 1);
-
-	unlock_page(page);
-
-	page_cache_release(page);
-}
-
-int migration_remove_reference(struct page *page, int dec)
+void migration_remove_reference(struct page *page, int dec)
 {
 	struct counter *c;
 	swp_entry_t entry;
@@ -145,6 +123,28 @@ int migration_remove_reference(struct pa
 	}
 }
 
+
+// FIXME: if the page is locked will it be correctly removed from migr cache?
+// check races
+
+void migration_remove_entry(swp_entry_t entry)
+{
+	struct page *page;
+	
+	page = find_get_page(&migration_space, entry.val);
+
+	if (!page)
+		BUG();
+
+	lock_page(page);	
+
+	migration_remove_reference(page, 1);
+
+	unlock_page(page);
+
+	page_cache_release(page);
+}
+
 int detach_from_migration_cache(struct page *page)
 {
 	lock_page(page);	
@@ -486,9 +486,6 @@ generic_migrate_page(struct page *page, 
 	/* Wait for all operations against the page to finish. */
 	ret = migrate_fn(page, newpage, &vlist);
 	switch (ret) {
-	default:
-		/* The page is busy. Try it later. */
-		goto out_busy;
 	case -ENOENT:
 		/* The file the page belongs to has been truncated. */
 		page_cache_get(page);
@@ -496,7 +493,10 @@ generic_migrate_page(struct page *page, 
 		newpage->mapping = NULL;
 		/* fall thru */
 	case 0:
-		/* fall thru */
+		break;
+	default:
+		/* The page is busy. Try it later. */
+		goto out_busy;
 	}
 
 	arch_migrate_page(page, newpage);

--------------010502000007070108010506--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
