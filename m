Date: Thu, 16 Feb 2006 12:42:29 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: page migration: Fix MPOL_INTERLEAVE behavior for migration via
 mbind()
Message-ID: <Pine.LNX.4.64.0602161238270.16786@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: ak@suse.de, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

migrate_pages_to() allocates a list of new pages on the intended target 
node or with the intended policy and then uses the list of new pages as 
targets for the migration of a list of pages out of place.

When the pages are allocated it is not clear which of the out of place pages
will be moved to the new pages. So we cannot specify an address as needed by
alloc_page_vma(). This causes problem for MPOL_INTERLEAVE which will currently
allocate the pages on the first node of the set. If mbind is used with
vma that has the policy of MPOL_INTERLEAVE then the interleaving of pages
may be destroyed.

This patch fixes that by generating a fake address for each alloc_page_vma which
will result is a distribution of pages as prescribed by MPOL_INTERLEAVE.

Lee also noted that the sequence of nodes for the new pages seems to be inverted.
So we also invert the way the lists of pages for migration are build.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc3/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc3.orig/mm/mempolicy.c	2006-02-16 12:34:09.000000000 -0800
+++ linux-2.6.16-rc3/mm/mempolicy.c	2006-02-16 12:34:25.000000000 -0800
@@ -542,7 +542,7 @@ static void migrate_page_add(struct page
 	 */
 	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
 		if (isolate_lru_page(page))
-			list_add(&page->lru, pagelist);
+			list_add_tail(&page->lru, pagelist);
 	}
 }
 
@@ -559,6 +559,7 @@ static int migrate_pages_to(struct list_
 	LIST_HEAD(moved);
 	LIST_HEAD(failed);
 	int err = 0;
+	unsigned long offset = vma->vm_start;
 	int nr_pages;
 	struct page *page;
 	struct list_head *p;
@@ -566,8 +567,20 @@ static int migrate_pages_to(struct list_
 redo:
 	nr_pages = 0;
 	list_for_each(p, pagelist) {
-		if (vma)
-			page = alloc_page_vma(GFP_HIGHUSER, vma, vma->vm_start);
+		if (vma) {
+			/*
+			 * The address passed to alloc_page_vma is used to
+			 * generate the proper interleave behavior. We fake
+			 * the address here by an increasing offset in order
+			 * to get the proper distribution of pages.
+			 *
+			 * No decision has been made as to which page
+			 * a certain old page is moved to so we cannot
+			 * specify the correct address.
+			 */
+			page = alloc_page_vma(GFP_HIGHUSER, vma, offset);
+			offset += PAGE_SIZE;
+		}
 		else
 			page = alloc_pages_node(dest, GFP_HIGHUSER, 0);
 
@@ -575,7 +588,7 @@ redo:
 			err = -ENOMEM;
 			goto out;
 		}
-		list_add(&page->lru, &newlist);
+		list_add_tail(&page->lru, &newlist);
 		nr_pages++;
 		if (nr_pages > MIGRATE_CHUNK_SIZE);
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
