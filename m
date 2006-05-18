Date: Thu, 18 May 2006 11:21:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060518182126.20734.57740.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
References: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 3/5] page migration: use allocator function for migrate_pages()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, bls@sgi.com, jes@sgi.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Pass a function that allocates the target page to migrate_pages()

Instead of passing a list of new pages, pass a function to allocate
a new page. This allows the correct placement of MPOL_INTERLEAVE pages
during page migration. It also further simplifies the callers
of migrate pages. migrate_pages() becomes similar to migrate_pages_to()
so drop migrate_pages_to(). The batching of new page allocations
becomes unnecessary.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/mm/migrate.c	2006-05-18 09:44:09.438655508 -0700
+++ linux-2.6.17-rc4-mm1/mm/migrate.c	2006-05-18 09:56:43.766958108 -0700
@@ -28,9 +28,6 @@
 
 #include "internal.h"
 
-/* The maximum number of pages to take off the LRU for migration */
-#define MIGRATE_CHUNK_SIZE 256
-
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 /*
@@ -587,18 +584,23 @@ static int move_to_new_page(struct page 
  * Obtain the lock on page, remove all ptes and migrate the page
  * to the newly allocated page in newpage.
  */
-static int unmap_and_move(struct page *newpage, struct page *page, int force)
+static int unmap_and_move(new_page_t get_new_page, unsigned long private,
+			struct page *page, int force)
 {
 	int rc = 0;
+	struct page *newpage = get_new_page(page, private);
+
+	if (!newpage)
+		return -ENOMEM;
 
 	if (page_count(page) == 1)
 		/* page was freed from under us. So we are done. */
-		goto ret;
+		goto move_newpage;
 
 	rc = -EAGAIN;
 	if (TestSetPageLocked(page)) {
 		if (!force)
-			goto ret;
+			goto move_newpage;
 		lock_page(page);
 	}
 
@@ -622,7 +624,7 @@ static int unmap_and_move(struct page *n
 		remove_migration_ptes(page, page);
 unlock:
 	unlock_page(page);
-ret:
+
 	if (rc != -EAGAIN) {
  		/*
  		 * A page that has been migrated has all references
@@ -632,29 +634,33 @@ ret:
  		 */
  		list_del(&page->lru);
  		move_to_lru(page);
-
-		list_del(&newpage->lru);
-		move_to_lru(newpage);
 	}
+
+move_newpage:
+	/*
+	 * Move the new page to the LRU. If migration was not successful
+	 * then this will free the page.
+	 */
+	move_to_lru(newpage);
 	return rc;
 }
 
 /*
  * migrate_pages
  *
- * Two lists are passed to this function. The first list
- * contains the pages isolated from the LRU to be migrated.
- * The second list contains new pages that the isolated pages
- * can be moved to.
+ * The function takes one list of pages to migrate and a function
+ * that determines from the page to be migrated and the private data
+ * the target of the move and allocates the page.
  *
  * The function returns after 10 attempts or if no pages
  * are movable anymore because to has become empty
  * or no retryable pages exist anymore. All pages will be
  * retruned to the LRU or freed.
  *
- * Return: Number of pages not migrated.
+ * Return: Number of pages not migrated or error code.
  */
-int migrate_pages(struct list_head *from, struct list_head *to)
+int migrate_pages(struct list_head *from,
+		new_page_t get_new_page, unsigned long private)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -671,15 +677,14 @@ int migrate_pages(struct list_head *from
 		retry = 0;
 
 		list_for_each_entry_safe(page, page2, from, lru) {
-
-			if (list_empty(to))
-				break;
-
 			cond_resched();
 
-			rc = unmap_and_move(lru_to_page(to), page, pass > 2);
+			rc = unmap_and_move(get_new_page, private,
+						page, pass > 2);
 
 			switch(rc) {
+			case -ENOMEM:
+				goto out;
 			case -EAGAIN:
 				retry++;
 				break;
@@ -692,72 +697,16 @@ int migrate_pages(struct list_head *from
 			}
 		}
 	}
-
+	rc = 0;
+out:
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 
 	putback_lru_pages(from);
-	return nr_failed + retry;
-}
-
-/*
- * Migrate the list 'pagelist' of pages to a certain destination.
- *
- * Specify destination with either non-NULL vma or dest_node >= 0
- * Return the number of pages not migrated or error code
- */
-int migrate_pages_to(struct list_head *pagelist,
-			struct vm_area_struct *vma, int dest)
-{
-	LIST_HEAD(newlist);
-	int err = 0;
-	unsigned long offset = 0;
-	int nr_pages;
-	int nr_failed = 0;
-	struct page *page;
-	struct list_head *p;
-
-redo:
-	nr_pages = 0;
-	list_for_each(p, pagelist) {
-		if (vma) {
-			/*
-			 * The address passed to alloc_page_vma is used to
-			 * generate the proper interleave behavior. We fake
-			 * the address here by an increasing offset in order
-			 * to get the proper distribution of pages.
-			 *
-			 * No decision has been made as to which page
-			 * a certain old page is moved to so we cannot
-			 * specify the correct address.
-			 */
-			page = alloc_page_vma(GFP_HIGHUSER, vma,
-					offset + vma->vm_start);
-			offset += PAGE_SIZE;
-		}
-		else
-			page = alloc_pages_node(dest, GFP_HIGHUSER, 0);
-
-		if (!page) {
-			err = -ENOMEM;
-			goto out;
-		}
-		list_add_tail(&page->lru, &newlist);
-		nr_pages++;
-		if (nr_pages > MIGRATE_CHUNK_SIZE)
-			break;
-	}
-	err = migrate_pages(pagelist, &newlist);
 
-	if (err >= 0) {
-		nr_failed += err;
-		if (list_empty(&newlist) && !list_empty(pagelist))
-			goto redo;
-	}
-out:
+	if (rc)
+		return rc;
 
-	/* Calculate number of leftover pages */
-	list_for_each(p, pagelist)
-		nr_failed++;
-	return nr_failed;
+	return nr_failed + retry;
 }
+
Index: linux-2.6.17-rc4-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/mm/mempolicy.c	2006-05-18 09:42:45.071807043 -0700
+++ linux-2.6.17-rc4-mm1/mm/mempolicy.c	2006-05-18 09:48:12.491970088 -0700
@@ -87,6 +87,7 @@
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/migrate.h>
+#include <linux/rmap.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -587,6 +588,11 @@ static void migrate_page_add(struct page
 		isolate_lru_page(page, pagelist);
 }
 
+static struct page *new_node_page(struct page *page, unsigned long node)
+{
+	return alloc_pages_node(node, GFP_HIGHUSER, 0);
+}
+
 /*
  * Migrate pages from one node to a target node.
  * Returns error or the number of pages not migrated.
@@ -604,7 +610,8 @@ int migrate_to_node(struct mm_struct *mm
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist))
-		err = migrate_pages_to(&pagelist, NULL, dest);
+		err = migrate_pages(&pagelist, new_node_page, dest);
+
 	return err;
 }
 
@@ -691,6 +698,12 @@ int do_migrate_pages(struct mm_struct *m
 
 }
 
+static struct page *new_vma_page(struct page *page, unsigned long private)
+{
+	struct vm_area_struct *vma = (struct vm_area_struct *)private;
+
+	return alloc_page_vma(GFP_HIGHUSER, vma, page_address_in_vma(page, vma));
+}
 #else
 
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
@@ -703,6 +716,11 @@ int do_migrate_pages(struct mm_struct *m
 {
 	return -ENOSYS;
 }
+
+static struct page *new_vma_page(struct page *page, unsigned long private)
+{
+	return NULL;
+}
 #endif
 
 long do_mbind(unsigned long start, unsigned long len,
@@ -764,7 +782,8 @@ long do_mbind(unsigned long start, unsig
 		err = mbind_range(vma, start, end, new);
 
 		if (!list_empty(&pagelist))
-			nr_failed = migrate_pages_to(&pagelist, vma, -1);
+			nr_failed = migrate_pages(&pagelist, new_vma_page,
+						(unsigned long)vma);
 
 		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
Index: linux-2.6.17-rc4-mm1/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc4-mm1.orig/include/linux/migrate.h	2006-05-18 09:42:45.070830541 -0700
+++ linux-2.6.17-rc4-mm1/include/linux/migrate.h	2006-05-18 09:48:12.493923092 -0700
@@ -3,14 +3,15 @@
 
 #include <linux/mm.h>
 
+typedef struct page *new_page_t(struct page *, unsigned long private);
+
 #ifdef CONFIG_MIGRATION
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
-extern int migrate_pages(struct list_head *l, struct list_head *t);
-extern int migrate_pages_to(struct list_head *pagelist,
-			struct vm_area_struct *vma, int dest);
+extern int migrate_pages(struct list_head *l, new_page_t x, unsigned long);
+
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
 
@@ -21,8 +22,8 @@ extern int migrate_prep(void);
 static inline int isolate_lru_page(struct page *p, struct list_head *list)
 					{ return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
-static inline int migrate_pages(struct list_head *l, struct list_head *t)
-					{ return -ENOSYS; }
+static inline int migrate_pages(struct list_head *l, new_page_t x,
+		unsigned long private) { return -ENOSYS; }
 
 static inline int migrate_pages_to(struct list_head *pagelist,
 			struct vm_area_struct *vma, int dest) { return 0; }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
