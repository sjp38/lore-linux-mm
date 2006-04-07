Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by atlrel8.hp.com (Postfix) with ESMTP id 2329C36F6F
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:20:53 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id 00A9F1097F
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:20:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 951B1134225
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:20:52 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 21216-01 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:20:50 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 5F9AB134250
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:20:48 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 1/6] Migrate-on-fault - separate unmap
	from radix tree replace
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441108.5198.36.camel@localhost.localdomain>
References: <1144441108.5198.36.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:22:12 -0400
Message-Id: <1144441333.5198.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Migrate-on-fault prototype 1/6 V0.2 - separate unmap from radix tree replace

V0.2 - rework against 2.6.17-rc1, with Christoph migration code
       reorg.  No change for 2.6.17-rc1-mm1

The migrate_page_remove_references() function performs two distinct
operations:  actually attempting to remove pte references from the
page via try_to_unmap() and replacing the page with a new page in
the page's mapping's radix tree.  This patch separates these 
operations into two functions so that they can be called separately.

Then, migrate_page_remove_references() is replaced with a function
named migrate_page_unmap_and_replace() to indicate the two operations,
and existing calls in mm/migrate.c:migrate_page() and
mm/migrate.c:buffer_migrate_page() are updated.

Note:  this results in each of the functions having to load the
mapping when called for direct migration.  Perhaps passing mapping as
an argument would be preferable?

Subsequent patches in the series will make use of the separate
operations. 

Eventually, we can remove migrate_page_unmap_and_replace()

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc1.orig/include/linux/migrate.h	2006-04-03 08:51:08.000000000 -0400
+++ linux-2.6.17-rc1/include/linux/migrate.h	2006-04-03 12:09:57.000000000 -0400
@@ -9,7 +9,9 @@ extern int isolate_lru_page(struct page 
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct page *, struct page *);
 extern void migrate_page_copy(struct page *, struct page *);
-extern int migrate_page_remove_references(struct page *, struct page *, int);
+extern int migrate_page_try_to_unmap(struct page *, int);
+extern int migrate_page_replace_in_mapping(struct page *, struct page *, int);
+extern int migrate_page_unmap_and_replace(struct page *, struct page *, int);
 extern int migrate_pages(struct list_head *l, struct list_head *t,
 		struct list_head *moved, struct list_head *failed);
 extern int migrate_pages_to(struct list_head *pagelist,
Index: linux-2.6.17-rc1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc1.orig/mm/migrate.c	2006-04-03 08:51:08.000000000 -0400
+++ linux-2.6.17-rc1/mm/migrate.c	2006-04-03 12:09:57.000000000 -0400
@@ -179,14 +179,12 @@ retry:
 EXPORT_SYMBOL(swap_page);
 
 /*
- * Remove references for a page and establish the new page with the correct
- * basic settings to be able to stop accesses to the page.
+ * Try to remove pte references from page in preparation to migrate to
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
@@ -225,6 +223,19 @@ int migrate_page_remove_references(struc
 	if (page_mapcount(page))
 		return -EAGAIN;
 
+	return 0;
+}
+EXPORT_SYMBOL(migrate_page_try_to_unmap);
+
+/*
+ * replace page in it's mapping's radix tree with newpage
+ */
+int migrate_page_replace_in_mapping(struct page *newpage,
+		struct page *page, int nr_refs)
+{
+	struct address_space *mapping = page_mapping(page);
+        struct page **radix_pointer;
+
 	write_lock_irq(&mapping->tree_lock);
 
 	radix_pointer = (struct page **)radix_tree_lookup_slot(
@@ -254,12 +265,29 @@ int migrate_page_remove_references(struc
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
@@ -310,10 +338,11 @@ EXPORT_SYMBOL(migrate_page_copy);
 int migrate_page(struct page *newpage, struct page *page)
 {
 	int rc;
+	int nr_refs = 2;	/* cache + current */
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_remove_references(newpage, page, 2);
+	rc = migrate_page_unmap_and_replace(newpage, page, nr_refs);
 
 	if (rc)
 		return rc;
@@ -530,6 +559,7 @@ int buffer_migrate_page(struct page *new
 {
 	struct address_space *mapping = page->mapping;
 	struct buffer_head *bh, *head;
+	int nr_refs = 3;	/* cache + bufs + current */
 	int rc;
 
 	if (!mapping)
@@ -540,7 +570,7 @@ int buffer_migrate_page(struct page *new
 
 	head = page_buffers(page);
 
-	rc = migrate_page_remove_references(newpage, page, 3);
+ 	rc = migrate_page_unmap_and_replace(newpage, page, nr_refs);
 
 	if (rc)
 		return rc;
@@ -556,7 +586,7 @@ int buffer_migrate_page(struct page *new
 	ClearPagePrivate(page);
 	set_page_private(newpage, page_private(page));
 	set_page_private(page, 0);
-	put_page(page);
+	put_page(page);		/* transfer buf ref to newpage */
 	get_page(newpage);
 
 	bh = head;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
