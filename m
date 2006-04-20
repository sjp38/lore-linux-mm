Subject: [PATCH/RFC] Page Cache Policy V0.0 1/5 add offset arg to
	migrate_pages_to()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 20 Apr 2006 16:41:07 -0400
Message-Id: <1145565667.5214.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Page Cache Policy V0.0 1/5 add offset arg to migrate_pages_to()

This patch adds a page offset arg to migrate_pages_to() for
use in selecting nodes from which to allocate for regions with
interleave policy.   This is needed to calculate the correct
node for shmem and generic mmap()ed files using the shared
policy infrastructure [subsequent patches]

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm2/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/migrate.h	2006-04-20 12:04:21.000000000 -0400
+++ linux-2.6.17-rc1-mm2/include/linux/migrate.h	2006-04-20 12:04:51.000000000 -0400
@@ -12,8 +12,8 @@ extern void migrate_page_copy(struct pag
 extern int migrate_page_remove_references(struct page *, struct page *, int);
 extern int migrate_pages(struct list_head *l, struct list_head *t,
 		struct list_head *moved, struct list_head *failed);
-extern int migrate_pages_to(struct list_head *pagelist,
-			struct vm_area_struct *vma, int dest);
+extern int migrate_pages_to(struct list_head *, struct vm_area_struct *,
+		int, unsigned long);
 extern int fail_migrate_page(struct page *, struct page *);
 
 extern int migrate_prep(void);
Index: linux-2.6.17-rc1-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/mempolicy.c	2006-04-20 12:04:21.000000000 -0400
+++ linux-2.6.17-rc1-mm2/mm/mempolicy.c	2006-04-20 12:05:35.000000000 -0400
@@ -604,7 +604,7 @@ int migrate_to_node(struct mm_struct *mm
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist)) {
-		err = migrate_pages_to(&pagelist, NULL, dest);
+		err = migrate_pages_to(&pagelist, NULL, dest, 0L);
 		if (!list_empty(&pagelist))
 			putback_lru_pages(&pagelist);
 	}
@@ -767,7 +767,8 @@ long do_mbind(unsigned long start, unsig
 		err = mbind_range(vma, start, end, new);
 
 		if (!list_empty(&pagelist))
-			nr_failed = migrate_pages_to(&pagelist, vma, -1);
+			nr_failed = migrate_pages_to(&pagelist, vma, -1,
+					start - vma->vm_start);
 
 		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
Index: linux-2.6.17-rc1-mm2/mm/migrate.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/migrate.c	2006-04-20 12:04:21.000000000 -0400
+++ linux-2.6.17-rc1-mm2/mm/migrate.c	2006-04-20 12:04:51.000000000 -0400
@@ -584,14 +584,13 @@ EXPORT_SYMBOL(buffer_migrate_page);
  * Specify destination with either non-NULL vma or dest_node >= 0
  * Return the number of pages not migrated or error code
  */
-int migrate_pages_to(struct list_head *pagelist,
-			struct vm_area_struct *vma, int dest)
+int migrate_pages_to(struct list_head *pagelist, struct vm_area_struct *vma,
+			int dest, unsigned long offset)
 {
 	LIST_HEAD(newlist);
 	LIST_HEAD(moved);
 	LIST_HEAD(failed);
 	int err = 0;
-	unsigned long offset = 0;
 	int nr_pages;
 	struct page *page;
 	struct list_head *p;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
