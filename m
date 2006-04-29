Date: Fri, 28 Apr 2006 20:23:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032301.4999.80540.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/7] PM cleanup: Remove useless definitions
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

Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-28 17:24:03.935627108 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-04-28 17:26:13.866044400 -0700
@@ -169,7 +169,7 @@
  * Remove references for a page and establish the new page with the correct
  * basic settings to be able to stop accesses to the page.
  */
-int migrate_page_remove_references(struct page *newpage,
+static int migrate_page_remove_references(struct page *newpage,
 				struct page *page, int nr_refs)
 {
 	struct address_space *mapping = page_mapping(page);
@@ -246,12 +246,11 @@
 
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
 
@@ -286,7 +285,6 @@
 	if (PageWriteback(newpage))
 		end_page_writeback(newpage);
 }
-EXPORT_SYMBOL(migrate_page_copy);
 
 /************************************************************
  *                    Migration functions
Index: linux-2.6.17-rc3/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc3.orig/include/linux/migrate.h	2006-04-26 19:19:25.000000000 -0700
+++ linux-2.6.17-rc3/include/linux/migrate.h	2006-04-28 17:26:13.867020902 -0700
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
