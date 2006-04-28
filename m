Date: Thu, 27 Apr 2006 23:03:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060428060307.30257.8191.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/7] page migration: Remove unnecessarily exported functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

page migration: Remove unnecessarily exported functions

Remove the export for migrate_page_remove_references() and
migrate_page_copy() that are unlikely to be used directly by
filesystems implementing migration. The export was useful
when buffer_migrate_page() lived in fs/buffer.c but it has now
been moved to migrate.c in the migration reorg.

Signed-off-by: Christoph Lameter <clameter@sgi.com>


Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-27 19:28:57.347549552 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-27 19:34:41.194349304 -0700
@@ -250,7 +250,7 @@
  * the page can be blocked. Establish the new page
  * with the basic settings to be able to stop accesses to the page.
  */
-int migrate_page_remove_references(struct page *newpage,
+static int migrate_page_remove_references(struct page *newpage,
 				struct page *page, int nr_refs)
 {
 	struct address_space *mapping = page_mapping(page);
@@ -343,12 +343,11 @@
 
 	return 0;
 }
-EXPORT_SYMBOL(migrate_page_remove_references);
 
 /*
  * Copy the page to its new location
  */
-void migrate_page_copy(struct page *newpage, struct page *page)
+static void migrate_page_copy(struct page *newpage, struct page *page)
 {
 	copy_highpage(newpage, page);
 
@@ -385,7 +384,6 @@
 	if (PageWriteback(newpage))
 		end_page_writeback(newpage);
 }
-EXPORT_SYMBOL(migrate_page_copy);
 
 /************************************************************
  *                    Migration functions
Index: linux-2.6.17-rc2-mm1/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc2-mm1.orig/include/linux/migrate.h	2006-04-18 20:00:49.000000000 -0700
+++ linux-2.6.17-rc2-mm1/include/linux/migrate.h	2006-04-27 19:35:10.943477554 -0700
@@ -8,8 +8,6 @@
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct page *, struct page *);
-extern void migrate_page_copy(struct page *, struct page *);
-extern int migrate_page_remove_references(struct page *, struct page *, int);
 extern int migrate_pages(struct list_head *l, struct list_head *t,
 		struct list_head *moved, struct list_head *failed);
 extern int migrate_pages_to(struct list_head *pagelist,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
