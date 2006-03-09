Subject: Re: [PATCH/RFC] Migrate-on-fault prototype 1/5 V0.1 - separate
	unmap from radix tree replace
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <1141928931.6393.11.camel@localhost.localdomain>
References: <1141928931.6393.11.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 09 Mar 2006 16:38:10 -0500
Message-Id: <1141940290.8326.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-03-09 at 13:28 -0500, Lee Schermerhorn wrote:
> Migrate-on-fault prototype 1/5 V0.1 - separate unmap from radix tree
> replace

Previous send mangled by mailer.  Try this:

Migrate-on-fault prototype 1/5 V0.1 - separate unmap from radix tree replace

The migrate_page_remove_references() function performs two distinct
operations:  actually attempting to remove pte references from the
page via try_to_unmap() and replacing the page with a new page in
the page's mapping's radix tree.  This patch separates these 
operations into two functions so that they can be called separately.

Then, migrate_page_remove_references() is replaced with a function
named migrate_page_unmap_and_replace() to indicate the two operations,
and existing calls in mm/vmscan.c:migrate_page() and
fs/buffer.c:buffer_migrate_page() are updated.

Note:  this results in each of the functions having to load the
mapping when called for direct migration.  Perhaps passing mapping as
an argument would be preferable?

Subsequent patches in the series will make use of the separate
operations. 

Eventually, we can remove migrate_page_unmap_and_replace()

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git8/fs/buffer.c
===================================================================
--- linux-2.6.16-rc5-git8.orig/fs/buffer.c	2006-03-06 13:40:46.000000000 -0500
+++ linux-2.6.16-rc5-git8/fs/buffer.c	2006-03-08 10:46:33.000000000 -0500
@@ -3060,6 +3060,7 @@ int buffer_migrate_page(struct page *new
 {
 	struct address_space *mapping = page->mapping;
 	struct buffer_head *bh, *head;
+	static const int nr_refs = 3;	/* cache + bufs + current */
 
 	if (!mapping)
 		return -EAGAIN;
@@ -3069,7 +3070,7 @@ int buffer_migrate_page(struct page *new
 
 	head = page_buffers(page);
 
-	if (migrate_page_remove_references(newpage, page, 3))
+	if (migrate_page_unmap_and_replace(newpage, page, nr_refs))
 		return -EAGAIN;
 
 	bh = head;
@@ -3083,7 +3084,7 @@ int buffer_migrate_page(struct page *new
 	ClearPagePrivate(page);
 	set_page_private(newpage, page_private(page));
 	set_page_private(page, 0);
-	put_page(page);
+	put_page(page);		/* transfer buf ref to newpage */
 	get_page(newpage);
 
 	bh = head;
Index: linux-2.6.16-rc5-git8/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc5-git8.orig/mm/vmscan.c	2006-03-06 13:40:48.000000000 -0500
+++ linux-2.6.16-rc5-git8/mm/vmscan.c	2006-03-08 10:44:39.000000000 -0500
@@ -685,14 +685,12 @@ EXPORT_SYMBOL(swap_page);
  */
 
 /*
- * Remove references for a page and establish the new page with the correct
- * basic settings to be able to stop accesses to the page.
+ * try to remove pte references from page in preparation to migrate to
+ * a new page.
  */
-int migrate_page_remove_references(struct page *newpage,
-				struct page *page, int nr_refs)
+int migrate_page_try_to_unmap(struct page *page, int nr_refs)
 {
 	struct address_space *mapping = page_mapping(page);
-	struct page **radix_pointer;
 
 	/*
 	 * Avoid doing any of the following work if the page count
@@ -721,14 +719,27 @@ int migrate_page_remove_references(struc
 	 * If the page was not migrated then the PageSwapCache bit
 	 * is still set and the operation may continue.
 	 */
-	try_to_unmap(page, 1);
+	try_to_unmap(page, 1);	/* ignore_refs */
 
 	/*
-	 * Give up if we were unable to remove all mappings.
+	 * Fail if we were unable to remove all mappings.
 	 */
 	if (page_mapcount(page))
 		return 1;
 
+	return 0;
+}
+EXPORT_SYMBOL(migrate_page_try_to_unmap);
+
+/*
+ * replace page in it's mapping's radix tree with newpage
+ */
+int migrate_page_replace_in_mapping(struct page *newpage,
+			struct page *page, int nr_refs)
+{
+	struct address_space *mapping = page_mapping(page);
+	struct page **radix_pointer;
+
 	write_lock_irq(&mapping->tree_lock);
 
 	radix_pointer = (struct page **)radix_tree_lookup_slot(
@@ -749,7 +760,7 @@ int migrate_page_remove_references(struc
 	 * find it through the radix tree update before we are finished
 	 * copying the page.
 	 */
-	get_page(newpage);
+	get_page(newpage);		/* add cache ref */
 	newpage->index = page->index;
 	newpage->mapping = page->mapping;
 	if (PageSwapCache(page)) {
@@ -758,12 +769,30 @@ int migrate_page_remove_references(struc
 	}
 
 	*radix_pointer = newpage;
-	__put_page(page);
+	__put_page(page);		/* drop cache ref */
 	write_unlock_irq(&mapping->tree_lock);
 
 	return 0;
 }
-EXPORT_SYMBOL(migrate_page_remove_references);
+EXPORT_SYMBOL(migrate_page_replace_in_mapping);
+
+
+/*
+ * Remove references for a page and establish the new page with the correct
+ * basic settings to be able to stop accesses to the page.
+ */
+int migrate_page_unmap_and_replace(struct page *newpage,
+				struct page *page, int nr_refs)
+{
+	/*
+	 * Give up if we were unable to remove all mappings.
+	 */
+	if (migrate_page_try_to_unmap(page, nr_refs))
+		return 1;
+
+	return migrate_page_replace_in_mapping(page, newpage, nr_refs);
+}
+EXPORT_SYMBOL(migrate_page_unmap_and_replace);
 
 /*
  * Copy the page to its new location
@@ -813,9 +842,11 @@ EXPORT_SYMBOL(migrate_page_copy);
  */
 int migrate_page(struct page *newpage, struct page *page)
 {
+	static const int nr_refs = 2;	/* cache + current */
+
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	if (migrate_page_remove_references(newpage, page, 2))
+	if (migrate_page_unmap_and_replace(newpage, page, nr_refs))
 		return -EAGAIN;
 
 	migrate_page_copy(newpage, page);
Index: linux-2.6.16-rc5-git8/include/linux/swap.h
===================================================================
--- linux-2.6.16-rc5-git8.orig/include/linux/swap.h	2006-03-06 13:40:47.000000000 -0500
+++ linux-2.6.16-rc5-git8/include/linux/swap.h	2006-03-08 10:44:14.000000000 -0500
@@ -193,7 +193,9 @@ extern int isolate_lru_page(struct page 
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct page *, struct page *);
 extern void migrate_page_copy(struct page *, struct page *);
-extern int migrate_page_remove_references(struct page *, struct page *, int);
+extern int migrate_page_try_to_unmap(struct page *, int);
+extern int migrate_page_replace_in_mapping(struct page *, struct page *, int);
+extern int migrate_page_unmap_and_replace(struct page *, struct page *, int);
 extern int migrate_pages(struct list_head *l, struct list_head *t,
 		struct list_head *moved, struct list_head *failed);
 extern int fail_migrate_page(struct page *, struct page *);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
