Message-ID: <41DB3010.7000600@sgi.com>
Date: Tue, 04 Jan 2005 18:08:48 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration
References: <20050103171344.GD14886@logos.cnet>	<41D9AC2D.90409@sgi.com>	<20050103183811.GE14886@logos.cnet> <20050105.004221.41649018.taka@valinux.co.jp> <41DAD393.1030009@sgi.com>
In-Reply-To: <41DAD393.1030009@sgi.com>
Content-Type: multipart/mixed;
 boundary="------------080600050509010601090809"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, marcelo.tosatti@cyclades.com, haveblue@us.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080600050509010601090809
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The attached patch changes "migrate_onepage(page)" to
"migrate_onepage(page, nodeid)".  For the case where
the caller doesn't care which target node is used,
then the call: "migrate_onepage(page, MIGRATE_NODE_ANY)"
causes migrate_onepage() to revert to its previous
behavior.

Since migrate_onepage() is only called in mmigrate.c
at the present time, this is a localized change.

This patch applies at the end of the migration
patches.

Unless there are objections, I'd like Dave to add this
patch to the hotplug patch as part of the page migration
patchset.

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

--------------080600050509010601090809
Content-Type: text/plain;
 name="add-node-arg-to-migrate_onepage.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="add-node-arg-to-migrate_onepage.patch"

Index: linux-2.6.10-rc2-mm4-page-migration-only/include/linux/mmigrate.h
===================================================================
--- linux-2.6.10-rc2-mm4-page-migration-only.orig/include/linux/mmigrate.h	2004-12-23 17:04:41.000000000 -0800
+++ linux-2.6.10-rc2-mm4-page-migration-only/include/linux/mmigrate.h	2005-01-04 07:23:36.000000000 -0800
@@ -4,6 +4,7 @@
 #include <linux/config.h>
 #include <linux/mm.h>
 
+#define MIGRATE_NODE_ANY -1
 
 #ifdef CONFIG_MEMORY_MIGRATE
 extern int generic_migrate_page(struct page *, struct page *,
@@ -14,7 +15,7 @@ extern int migrate_page_buffer(struct pa
 					struct list_head *);
 extern int page_migratable(struct page *, struct page *, int,
 					struct list_head *);
-extern struct page * migrate_onepage(struct page *);
+extern struct page * migrate_onepage(struct page *, int nodeid);
 extern int try_to_migrate_pages(struct list_head *);
 
 #else
Index: linux-2.6.10-rc2-mm4-page-migration-only/mm/mmigrate.c
===================================================================
--- linux-2.6.10-rc2-mm4-page-migration-only.orig/mm/mmigrate.c	2005-01-04 07:09:24.000000000 -0800
+++ linux-2.6.10-rc2-mm4-page-migration-only/mm/mmigrate.c	2005-01-04 07:30:57.000000000 -0800
@@ -404,7 +404,7 @@ out_removing:
  * swapcache or anonymous memory.
  */
 struct page *
-migrate_onepage(struct page *page)
+migrate_onepage(struct page *page, int nodeid)
 {
 	struct page *newpage;
 	struct address_space *mapping;
@@ -434,7 +434,10 @@ migrate_onepage(struct page *page)
 	 * Allocate a new page with the same gfp_mask
 	 * as the target page has.
 	 */
-	newpage = page_cache_alloc(mapping, page->index);
+	if (nodeid == MIGRATE_NODE_ANY)
+		newpage = page_cache_alloc(mapping, page->index);
+	else
+		newpage = alloc_pages_node(nodeid, mapping->flags, 0);
 	if (newpage == NULL) {
 		unlock_page(page);
 		return ERR_PTR(-ENOMEM);
@@ -538,7 +541,7 @@ int try_to_migrate_pages(struct list_hea
 	list_for_each_entry_safe(page, page2, &pass1_list, lru) {
 		list_del(&page->lru);
 		if (PageLocked(page) || PageWriteback(page) ||
-		    IS_ERR(newpage = migrate_onepage(page))) {
+		    IS_ERR(newpage = migrate_onepage(page, MIGRATE_NODE_ANY))) {
 			if (page_count(page) == 1) {
 				/* the page is already unused */
 				putback_page_to_lru(page_zone(page), page);
@@ -556,7 +559,7 @@ int try_to_migrate_pages(struct list_hea
 	 */
 	list_for_each_entry_safe(page, page2, &pass2_list, lru) {
 		list_del(&page->lru);
-		if (IS_ERR(newpage = migrate_onepage(page))) {
+		if (IS_ERR(newpage = migrate_onepage(page, MIGRATE_NODE_ANY))) {
 			if (page_count(page) == 1) {
 				/* the page is already unused */
 				putback_page_to_lru(page_zone(page), page);
@@ -586,4 +589,4 @@ EXPORT_SYMBOL(generic_migrate_page);
 EXPORT_SYMBOL(migrate_page_common);
 EXPORT_SYMBOL(migrate_page_buffer);
 EXPORT_SYMBOL(page_migratable);
-
+EXPORT_SYMBOL(migrate_onepage);

--------------080600050509010601090809--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
