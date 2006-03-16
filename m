Date: Wed, 15 Mar 2006 17:42:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: page migration reorg patch
Message-ID: <Pine.LNX.4.64.0603151736380.30472@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

This patch centralizes the page migration functions in anticipation of 
additional tinkering. Creates a new file mm/migrate.c

1. Extract buffer_migrate_page() from fs/buffer.c

2. Extract central migration code from vmscan.c

3. Extract some components from mempolicy.c

4. Export pageout() and remove_from_swap() from vmscan.c

5. Make it possible to configure NUMA systems without page migration
   and non-NUMA systems with page migration.

I had to so some #ifdeffing in mempolicy.c that may need a cleanup.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc6/mm/Makefile
===================================================================
--- linux-2.6.16-rc6.orig/mm/Makefile	2006-03-11 14:12:55.000000000 -0800
+++ linux-2.6.16-rc6/mm/Makefile	2006-03-15 17:23:42.000000000 -0800
@@ -22,3 +22,5 @@ obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
+obj-$(CONFIG_MIGRATION) += migrate.o
+
Index: linux-2.6.16-rc6/mm/migrate.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.16-rc6/mm/migrate.c	2006-03-15 17:35:49.000000000 -0800
@@ -0,0 +1,620 @@
+/*
+ * Memory Migration functionality - linux/mm/migration.c
+ *
+ * Copyright (C) 2006 Silicon Graphics, Inc., Christoph Lameter
+ *
+ * Page migration was first developed in the context of the memory hotplug
+ * project. The main authors of the migration code are:
+ *
+ * IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
+ * Hirokazu Takahashi <taka@valinux.co.jp>
+ * Dave Hansen <haveblue@us.ibm.com>
+ * Christoph Lameter <clameter@sgi.com>
+ */
+
+#include <linux/migrate.h>
+#include <linux/module.h>
+#include <linux/swap.h>
+#include <linux/pagemap.h>
+#include <linux/buffer_head.h>	/* for try_to_release_page(),
+					buffer_heads_over_limit */
+#include <linux/mm_inline.h>
+#include <linux/pagevec.h>
+#include <linux/rmap.h>
+#include <linux/topology.h>
+#include <linux/cpu.h>
+#include <linux/cpuset.h>
+#include <linux/swapops.h>
+
+/* The maximum number of pages to take off the LRU for migration */
+#define MIGRATE_CHUNK_SIZE 256
+
+#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
+
+static inline void move_to_lru(struct page *page)
+{
+	list_del(&page->lru);
+	if (PageActive(page)) {
+		/*
+		 * lru_cache_add_active checks that
+		 * the PG_active bit is off.
+		 */
+		ClearPageActive(page);
+		lru_cache_add_active(page);
+	} else {
+		lru_cache_add(page);
+	}
+	put_page(page);
+}
+
+/*
+ * Add isolated pages on the list back to the LRU.
+ *
+ * returns the number of pages put back.
+ */
+int putback_lru_pages(struct list_head *l)
+{
+	struct page *page;
+	struct page *page2;
+	int count = 0;
+
+	list_for_each_entry_safe(page, page2, l, lru) {
+		move_to_lru(page);
+		count++;
+	}
+	return count;
+}
+
+/*
+ * Non migratable page
+ */
+int fail_migrate_page(struct page *newpage, struct page *page)
+{
+	return -EIO;
+}
+EXPORT_SYMBOL(fail_migrate_page);
+
+/*
+ * swapout a single page
+ * page is locked upon entry, unlocked on exit
+ */
+static int swap_page(struct page *page)
+{
+	struct address_space *mapping = page_mapping(page);
+
+	if (page_mapped(page) && mapping)
+		if (try_to_unmap(page, 1) != SWAP_SUCCESS)
+			goto unlock_retry;
+
+	if (PageDirty(page)) {
+		/* Page is dirty, try to write it out here */
+		switch(pageout(page, mapping)) {
+		case PAGE_KEEP:
+		case PAGE_ACTIVATE:
+			goto unlock_retry;
+
+		case PAGE_SUCCESS:
+			goto retry;
+
+		case PAGE_CLEAN:
+			; /* try to free the page below */
+		}
+	}
+
+	if (PagePrivate(page)) {
+		if (!try_to_release_page(page, GFP_KERNEL) ||
+		    (!mapping && page_count(page) == 1))
+			goto unlock_retry;
+	}
+
+	if (remove_mapping(mapping, page)) {
+		/* Success */
+		unlock_page(page);
+		return 0;
+	}
+
+unlock_retry:
+	unlock_page(page);
+
+retry:
+	return -EAGAIN;
+}
+EXPORT_SYMBOL(swap_page);
+
+/*
+ * Remove references for a page and establish the new page with the correct
+ * basic settings to be able to stop accesses to the page.
+ */
+int migrate_page_remove_references(struct page *newpage,
+				struct page *page, int nr_refs)
+{
+	struct address_space *mapping = page_mapping(page);
+	struct page **radix_pointer;
+
+	/*
+	 * Avoid doing any of the following work if the page count
+	 * indicates that the page is in use or truncate has removed
+	 * the page.
+	 */
+	if (!mapping || page_mapcount(page) + nr_refs != page_count(page))
+		return 1;
+
+	/*
+	 * Establish swap ptes for anonymous pages or destroy pte
+	 * maps for files.
+	 *
+	 * In order to reestablish file backed mappings the fault handlers
+	 * will take the radix tree_lock which may then be used to stop
+  	 * processses from accessing this page until the new page is ready.
+	 *
+	 * A process accessing via a swap pte (an anonymous page) will take a
+	 * page_lock on the old page which will block the process until the
+	 * migration attempt is complete. At that time the PageSwapCache bit
+	 * will be examined. If the page was migrated then the PageSwapCache
+	 * bit will be clear and the operation to retrieve the page will be
+	 * retried which will find the new page in the radix tree. Then a new
+	 * direct mapping may be generated based on the radix tree contents.
+	 *
+	 * If the page was not migrated then the PageSwapCache bit
+	 * is still set and the operation may continue.
+	 */
+	try_to_unmap(page, 1);
+
+	/*
+	 * Give up if we were unable to remove all mappings.
+	 */
+	if (page_mapcount(page))
+		return 1;
+
+	write_lock_irq(&mapping->tree_lock);
+
+	radix_pointer = (struct page **)radix_tree_lookup_slot(
+						&mapping->page_tree,
+						page_index(page));
+
+	if (!page_mapping(page) || page_count(page) != nr_refs ||
+			*radix_pointer != page) {
+		write_unlock_irq(&mapping->tree_lock);
+		return 1;
+	}
+
+	/*
+	 * Now we know that no one else is looking at the page.
+	 *
+	 * Certain minimal information about a page must be available
+	 * in order for other subsystems to properly handle the page if they
+	 * find it through the radix tree update before we are finished
+	 * copying the page.
+	 */
+	get_page(newpage);
+	newpage->index = page->index;
+	newpage->mapping = page->mapping;
+	if (PageSwapCache(page)) {
+		SetPageSwapCache(newpage);
+		set_page_private(newpage, page_private(page));
+	}
+
+	*radix_pointer = newpage;
+	__put_page(page);
+	write_unlock_irq(&mapping->tree_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(migrate_page_remove_references);
+
+/*
+ * Copy the page to its new location
+ */
+void migrate_page_copy(struct page *newpage, struct page *page)
+{
+	copy_highpage(newpage, page);
+
+	if (PageError(page))
+		SetPageError(newpage);
+	if (PageReferenced(page))
+		SetPageReferenced(newpage);
+	if (PageUptodate(page))
+		SetPageUptodate(newpage);
+	if (PageActive(page))
+		SetPageActive(newpage);
+	if (PageChecked(page))
+		SetPageChecked(newpage);
+	if (PageMappedToDisk(page))
+		SetPageMappedToDisk(newpage);
+
+	if (PageDirty(page)) {
+		clear_page_dirty_for_io(page);
+		set_page_dirty(newpage);
+ 	}
+
+	ClearPageSwapCache(page);
+	ClearPageActive(page);
+	ClearPagePrivate(page);
+	set_page_private(page, 0);
+	page->mapping = NULL;
+
+	/*
+	 * If any waiters have accumulated on the new page then
+	 * wake them up.
+	 */
+	if (PageWriteback(newpage))
+		end_page_writeback(newpage);
+}
+EXPORT_SYMBOL(migrate_page_copy);
+
+/*
+ * Common logic to directly migrate a single page suitable for
+ * pages that do not use PagePrivate.
+ *
+ * Pages are locked upon entry and exit.
+ */
+int migrate_page(struct page *newpage, struct page *page)
+{
+	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
+
+	if (migrate_page_remove_references(newpage, page, 2))
+		return -EAGAIN;
+
+	migrate_page_copy(newpage, page);
+
+	/*
+	 * Remove auxiliary swap entries and replace
+	 * them with real ptes.
+	 *
+	 * Note that a real pte entry will allow processes that are not
+	 * waiting on the page lock to use the new page via the page tables
+	 * before the new page is unlocked.
+	 */
+	remove_from_swap(newpage);
+	return 0;
+}
+EXPORT_SYMBOL(migrate_page);
+
+/*
+ * migrate_pages
+ *
+ * Two lists are passed to this function. The first list
+ * contains the pages isolated from the LRU to be migrated.
+ * The second list contains new pages that the pages isolated
+ * can be moved to. If the second list is NULL then all
+ * pages are swapped out.
+ *
+ * The function returns after 10 attempts or if no pages
+ * are movable anymore because to has become empty
+ * or no retryable pages exist anymore.
+ *
+ * Return: Number of pages not migrated when "to" ran empty.
+ */
+int migrate_pages(struct list_head *from, struct list_head *to,
+		  struct list_head *moved, struct list_head *failed)
+{
+	int retry;
+	int nr_failed = 0;
+	int pass = 0;
+	struct page *page;
+	struct page *page2;
+	int swapwrite = current->flags & PF_SWAPWRITE;
+	int rc;
+
+	if (!swapwrite)
+		current->flags |= PF_SWAPWRITE;
+
+redo:
+	retry = 0;
+
+	list_for_each_entry_safe(page, page2, from, lru) {
+		struct page *newpage = NULL;
+		struct address_space *mapping;
+
+		cond_resched();
+
+		rc = 0;
+		if (page_count(page) == 1)
+			/* page was freed from under us. So we are done. */
+			goto next;
+
+		if (to && list_empty(to))
+			break;
+
+		/*
+		 * Skip locked pages during the first two passes to give the
+		 * functions holding the lock time to release the page. Later we
+		 * use lock_page() to have a higher chance of acquiring the
+		 * lock.
+		 */
+		rc = -EAGAIN;
+		if (pass > 2)
+			lock_page(page);
+		else
+			if (TestSetPageLocked(page))
+				goto next;
+
+		/*
+		 * Only wait on writeback if we have already done a pass where
+		 * we we may have triggered writeouts for lots of pages.
+		 */
+		if (pass > 0) {
+			wait_on_page_writeback(page);
+		} else {
+			if (PageWriteback(page))
+				goto unlock_page;
+		}
+
+		/*
+		 * Anonymous pages must have swap cache references otherwise
+		 * the information contained in the page maps cannot be
+		 * preserved.
+		 */
+		if (PageAnon(page) && !PageSwapCache(page)) {
+			if (!add_to_swap(page, GFP_KERNEL)) {
+				rc = -ENOMEM;
+				goto unlock_page;
+			}
+		}
+
+		if (!to) {
+			rc = swap_page(page);
+			goto next;
+		}
+
+		newpage = lru_to_page(to);
+		lock_page(newpage);
+
+		/*
+		 * Pages are properly locked and writeback is complete.
+		 * Try to migrate the page.
+		 */
+		mapping = page_mapping(page);
+		if (!mapping)
+			goto unlock_both;
+
+		if (mapping->a_ops->migratepage) {
+			/*
+			 * Most pages have a mapping and most filesystems
+			 * should provide a migration function. Anonymous
+			 * pages are part of swap space which also has its
+			 * own migration function. This is the most common
+			 * path for page migration.
+			 */
+			rc = mapping->a_ops->migratepage(newpage, page);
+			goto unlock_both;
+                }
+
+		/*
+		 * Default handling if a filesystem does not provide
+		 * a migration function. We can only migrate clean
+		 * pages so try to write out any dirty pages first.
+		 */
+		if (PageDirty(page)) {
+			switch (pageout(page, mapping)) {
+			case PAGE_KEEP:
+			case PAGE_ACTIVATE:
+				goto unlock_both;
+
+			case PAGE_SUCCESS:
+				unlock_page(newpage);
+				goto next;
+
+			case PAGE_CLEAN:
+				; /* try to migrate the page below */
+			}
+                }
+
+		/*
+		 * Buffers are managed in a filesystem specific way.
+		 * We must have no buffers or drop them.
+		 */
+		if (!page_has_buffers(page) ||
+		    try_to_release_page(page, GFP_KERNEL)) {
+			rc = migrate_page(newpage, page);
+			goto unlock_both;
+		}
+
+		/*
+		 * On early passes with mapped pages simply
+		 * retry. There may be a lock held for some
+		 * buffers that may go away. Later
+		 * swap them out.
+		 */
+		if (pass > 4) {
+			/*
+			 * Persistently unable to drop buffers..... As a
+			 * measure of last resort we fall back to
+			 * swap_page().
+			 */
+			unlock_page(newpage);
+			newpage = NULL;
+			rc = swap_page(page);
+			goto next;
+		}
+
+unlock_both:
+		unlock_page(newpage);
+
+unlock_page:
+		unlock_page(page);
+
+next:
+		if (rc == -EAGAIN) {
+			retry++;
+		} else if (rc) {
+			/* Permanent failure */
+			list_move(&page->lru, failed);
+			nr_failed++;
+		} else {
+			if (newpage) {
+				/* Successful migration. Return page to LRU */
+				move_to_lru(newpage);
+			}
+			list_move(&page->lru, moved);
+		}
+	}
+	if (retry && pass++ < 10)
+		goto redo;
+
+	if (!swapwrite)
+		current->flags &= ~PF_SWAPWRITE;
+
+	return nr_failed + retry;
+}
+
+/*
+ * Isolate one page from the LRU lists and put it on the
+ * indicated list with elevated refcount.
+ *
+ * Result:
+ *  0 = page not on LRU list
+ *  1 = page removed from LRU list and added to the specified list.
+ */
+int isolate_lru_page(struct page *page)
+{
+	int ret = 0;
+
+	if (PageLRU(page)) {
+		struct zone *zone = page_zone(page);
+		spin_lock_irq(&zone->lru_lock);
+		if (TestClearPageLRU(page)) {
+			ret = 1;
+			get_page(page);
+			if (PageActive(page))
+				del_page_from_active_list(zone, page);
+			else
+				del_page_from_inactive_list(zone, page);
+		}
+		spin_unlock_irq(&zone->lru_lock);
+	}
+
+	return ret;
+}
+
+/*
+ * Migration function for pages with buffers. This function can only be used
+ * if the underlying filesystem guarantees that no other references to "page"
+ * exist.
+ */
+int buffer_migrate_page(struct page *newpage, struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	struct buffer_head *bh, *head;
+
+	if (!mapping)
+		return -EAGAIN;
+
+	if (!page_has_buffers(page))
+		return migrate_page(newpage, page);
+
+	head = page_buffers(page);
+
+	if (migrate_page_remove_references(newpage, page, 3))
+		return -EAGAIN;
+
+	bh = head;
+	do {
+		get_bh(bh);
+		lock_buffer(bh);
+		bh = bh->b_this_page;
+
+	} while (bh != head);
+
+	ClearPagePrivate(page);
+	set_page_private(newpage, page_private(page));
+	set_page_private(page, 0);
+	put_page(page);
+	get_page(newpage);
+
+	bh = head;
+	do {
+		set_bh_page(bh, newpage, bh_offset(bh));
+		bh = bh->b_this_page;
+
+	} while (bh != head);
+
+	SetPagePrivate(newpage);
+
+	migrate_page_copy(newpage, page);
+
+	bh = head;
+	do {
+		unlock_buffer(bh);
+ 		put_bh(bh);
+		bh = bh->b_this_page;
+
+	} while (bh != head);
+
+	return 0;
+}
+EXPORT_SYMBOL(buffer_migrate_page);
+
+#ifdef CONFIG_NUMA
+/*
+ * Migrate the list 'pagelist' of pages to a certain destination.
+ *
+ * Specify destination with either non-NULL vma or dest_node >= 0
+ * Return the number of pages not migrated or error code
+ */
+int migrate_pages_to(struct list_head *pagelist,
+			struct vm_area_struct *vma, int dest)
+{
+	LIST_HEAD(newlist);
+	LIST_HEAD(moved);
+	LIST_HEAD(failed);
+	int err = 0;
+	unsigned long offset = 0;
+	int nr_pages;
+	struct page *page;
+	struct list_head *p;
+
+redo:
+	nr_pages = 0;
+	list_for_each(p, pagelist) {
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
+			page = alloc_page_vma(GFP_HIGHUSER, vma,
+					offset + vma->vm_start);
+			offset += PAGE_SIZE;
+		}
+		else
+			page = alloc_pages_node(dest, GFP_HIGHUSER, 0);
+
+		if (!page) {
+			err = -ENOMEM;
+			goto out;
+		}
+		list_add_tail(&page->lru, &newlist);
+		nr_pages++;
+		if (nr_pages > MIGRATE_CHUNK_SIZE)
+			break;
+	}
+	err = migrate_pages(pagelist, &newlist, &moved, &failed);
+
+	putback_lru_pages(&moved);	/* Call release pages instead ?? */
+
+	if (err >= 0 && list_empty(&newlist) && !list_empty(pagelist))
+		goto redo;
+out:
+	/* Return leftover allocated pages */
+	while (!list_empty(&newlist)) {
+		page = list_entry(newlist.next, struct page, lru);
+		list_del(&page->lru);
+		__free_page(page);
+	}
+	list_splice(&failed, pagelist);
+	if (err < 0)
+		return err;
+
+	/* Calculate number of leftover pages */
+	nr_pages = 0;
+	list_for_each(p, pagelist)
+		nr_pages++;
+	return nr_pages;
+}
+#endif
Index: linux-2.6.16-rc6/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc6.orig/mm/vmscan.c	2006-03-11 14:12:55.000000000 -0800
+++ linux-2.6.16-rc6/mm/vmscan.c	2006-03-15 16:43:32.000000000 -0800
@@ -39,18 +39,6 @@
 
 #include <linux/swapops.h>
 
-/* possible outcome of pageout() */
-typedef enum {
-	/* failed to write page out, page is locked */
-	PAGE_KEEP,
-	/* move page to the active list, page is locked */
-	PAGE_ACTIVATE,
-	/* page has been sent to the disk successfully, page is unlocked */
-	PAGE_SUCCESS,
-	/* page is clean and locked */
-	PAGE_CLEAN,
-} pageout_t;
-
 struct scan_control {
 	/* Ask refill_inactive_zone, or shrink_cache to scan this many pages */
 	unsigned long nr_to_scan;
@@ -308,7 +296,7 @@ static void handle_write_error(struct ad
 /*
  * pageout is called by shrink_list() for each dirty page. Calls ->writepage().
  */
-static pageout_t pageout(struct page *page, struct address_space *mapping)
+pageout_t pageout(struct page *page, struct address_space *mapping)
 {
 	/*
 	 * If the page is dirty, only perform writeback if that write
@@ -376,7 +364,7 @@ static pageout_t pageout(struct page *pa
 	return PAGE_CLEAN;
 }
 
-static int remove_mapping(struct address_space *mapping, struct page *page)
+int remove_mapping(struct address_space *mapping, struct page *page)
 {
 	if (!mapping)
 		return 0;		/* truncate got there first */
@@ -583,474 +571,6 @@ keep:
 	return reclaimed;
 }
 
-#ifdef CONFIG_MIGRATION
-static inline void move_to_lru(struct page *page)
-{
-	list_del(&page->lru);
-	if (PageActive(page)) {
-		/*
-		 * lru_cache_add_active checks that
-		 * the PG_active bit is off.
-		 */
-		ClearPageActive(page);
-		lru_cache_add_active(page);
-	} else {
-		lru_cache_add(page);
-	}
-	put_page(page);
-}
-
-/*
- * Add isolated pages on the list back to the LRU.
- *
- * returns the number of pages put back.
- */
-int putback_lru_pages(struct list_head *l)
-{
-	struct page *page;
-	struct page *page2;
-	int count = 0;
-
-	list_for_each_entry_safe(page, page2, l, lru) {
-		move_to_lru(page);
-		count++;
-	}
-	return count;
-}
-
-/*
- * Non migratable page
- */
-int fail_migrate_page(struct page *newpage, struct page *page)
-{
-	return -EIO;
-}
-EXPORT_SYMBOL(fail_migrate_page);
-
-/*
- * swapout a single page
- * page is locked upon entry, unlocked on exit
- */
-static int swap_page(struct page *page)
-{
-	struct address_space *mapping = page_mapping(page);
-
-	if (page_mapped(page) && mapping)
-		if (try_to_unmap(page, 1) != SWAP_SUCCESS)
-			goto unlock_retry;
-
-	if (PageDirty(page)) {
-		/* Page is dirty, try to write it out here */
-		switch(pageout(page, mapping)) {
-		case PAGE_KEEP:
-		case PAGE_ACTIVATE:
-			goto unlock_retry;
-
-		case PAGE_SUCCESS:
-			goto retry;
-
-		case PAGE_CLEAN:
-			; /* try to free the page below */
-		}
-	}
-
-	if (PagePrivate(page)) {
-		if (!try_to_release_page(page, GFP_KERNEL) ||
-		    (!mapping && page_count(page) == 1))
-			goto unlock_retry;
-	}
-
-	if (remove_mapping(mapping, page)) {
-		/* Success */
-		unlock_page(page);
-		return 0;
-	}
-
-unlock_retry:
-	unlock_page(page);
-
-retry:
-	return -EAGAIN;
-}
-EXPORT_SYMBOL(swap_page);
-
-/*
- * Page migration was first developed in the context of the memory hotplug
- * project. The main authors of the migration code are:
- *
- * IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
- * Hirokazu Takahashi <taka@valinux.co.jp>
- * Dave Hansen <haveblue@us.ibm.com>
- * Christoph Lameter <clameter@sgi.com>
- */
-
-/*
- * Remove references for a page and establish the new page with the correct
- * basic settings to be able to stop accesses to the page.
- */
-int migrate_page_remove_references(struct page *newpage,
-				struct page *page, int nr_refs)
-{
-	struct address_space *mapping = page_mapping(page);
-	struct page **radix_pointer;
-
-	/*
-	 * Avoid doing any of the following work if the page count
-	 * indicates that the page is in use or truncate has removed
-	 * the page.
-	 */
-	if (!mapping || page_mapcount(page) + nr_refs != page_count(page))
-		return 1;
-
-	/*
-	 * Establish swap ptes for anonymous pages or destroy pte
-	 * maps for files.
-	 *
-	 * In order to reestablish file backed mappings the fault handlers
-	 * will take the radix tree_lock which may then be used to stop
-  	 * processses from accessing this page until the new page is ready.
-	 *
-	 * A process accessing via a swap pte (an anonymous page) will take a
-	 * page_lock on the old page which will block the process until the
-	 * migration attempt is complete. At that time the PageSwapCache bit
-	 * will be examined. If the page was migrated then the PageSwapCache
-	 * bit will be clear and the operation to retrieve the page will be
-	 * retried which will find the new page in the radix tree. Then a new
-	 * direct mapping may be generated based on the radix tree contents.
-	 *
-	 * If the page was not migrated then the PageSwapCache bit
-	 * is still set and the operation may continue.
-	 */
-	try_to_unmap(page, 1);
-
-	/*
-	 * Give up if we were unable to remove all mappings.
-	 */
-	if (page_mapcount(page))
-		return 1;
-
-	write_lock_irq(&mapping->tree_lock);
-
-	radix_pointer = (struct page **)radix_tree_lookup_slot(
-						&mapping->page_tree,
-						page_index(page));
-
-	if (!page_mapping(page) || page_count(page) != nr_refs ||
-			*radix_pointer != page) {
-		write_unlock_irq(&mapping->tree_lock);
-		return 1;
-	}
-
-	/*
-	 * Now we know that no one else is looking at the page.
-	 *
-	 * Certain minimal information about a page must be available
-	 * in order for other subsystems to properly handle the page if they
-	 * find it through the radix tree update before we are finished
-	 * copying the page.
-	 */
-	get_page(newpage);
-	newpage->index = page->index;
-	newpage->mapping = page->mapping;
-	if (PageSwapCache(page)) {
-		SetPageSwapCache(newpage);
-		set_page_private(newpage, page_private(page));
-	}
-
-	*radix_pointer = newpage;
-	__put_page(page);
-	write_unlock_irq(&mapping->tree_lock);
-
-	return 0;
-}
-EXPORT_SYMBOL(migrate_page_remove_references);
-
-/*
- * Copy the page to its new location
- */
-void migrate_page_copy(struct page *newpage, struct page *page)
-{
-	copy_highpage(newpage, page);
-
-	if (PageError(page))
-		SetPageError(newpage);
-	if (PageReferenced(page))
-		SetPageReferenced(newpage);
-	if (PageUptodate(page))
-		SetPageUptodate(newpage);
-	if (PageActive(page))
-		SetPageActive(newpage);
-	if (PageChecked(page))
-		SetPageChecked(newpage);
-	if (PageMappedToDisk(page))
-		SetPageMappedToDisk(newpage);
-
-	if (PageDirty(page)) {
-		clear_page_dirty_for_io(page);
-		set_page_dirty(newpage);
- 	}
-
-	ClearPageSwapCache(page);
-	ClearPageActive(page);
-	ClearPagePrivate(page);
-	set_page_private(page, 0);
-	page->mapping = NULL;
-
-	/*
-	 * If any waiters have accumulated on the new page then
-	 * wake them up.
-	 */
-	if (PageWriteback(newpage))
-		end_page_writeback(newpage);
-}
-EXPORT_SYMBOL(migrate_page_copy);
-
-/*
- * Common logic to directly migrate a single page suitable for
- * pages that do not use PagePrivate.
- *
- * Pages are locked upon entry and exit.
- */
-int migrate_page(struct page *newpage, struct page *page)
-{
-	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
-
-	if (migrate_page_remove_references(newpage, page, 2))
-		return -EAGAIN;
-
-	migrate_page_copy(newpage, page);
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
-	return 0;
-}
-EXPORT_SYMBOL(migrate_page);
-
-/*
- * migrate_pages
- *
- * Two lists are passed to this function. The first list
- * contains the pages isolated from the LRU to be migrated.
- * The second list contains new pages that the pages isolated
- * can be moved to. If the second list is NULL then all
- * pages are swapped out.
- *
- * The function returns after 10 attempts or if no pages
- * are movable anymore because to has become empty
- * or no retryable pages exist anymore.
- *
- * Return: Number of pages not migrated when "to" ran empty.
- */
-int migrate_pages(struct list_head *from, struct list_head *to,
-		  struct list_head *moved, struct list_head *failed)
-{
-	int retry;
-	int nr_failed = 0;
-	int pass = 0;
-	struct page *page;
-	struct page *page2;
-	int swapwrite = current->flags & PF_SWAPWRITE;
-	int rc;
-
-	if (!swapwrite)
-		current->flags |= PF_SWAPWRITE;
-
-redo:
-	retry = 0;
-
-	list_for_each_entry_safe(page, page2, from, lru) {
-		struct page *newpage = NULL;
-		struct address_space *mapping;
-
-		cond_resched();
-
-		rc = 0;
-		if (page_count(page) == 1)
-			/* page was freed from under us. So we are done. */
-			goto next;
-
-		if (to && list_empty(to))
-			break;
-
-		/*
-		 * Skip locked pages during the first two passes to give the
-		 * functions holding the lock time to release the page. Later we
-		 * use lock_page() to have a higher chance of acquiring the
-		 * lock.
-		 */
-		rc = -EAGAIN;
-		if (pass > 2)
-			lock_page(page);
-		else
-			if (TestSetPageLocked(page))
-				goto next;
-
-		/*
-		 * Only wait on writeback if we have already done a pass where
-		 * we we may have triggered writeouts for lots of pages.
-		 */
-		if (pass > 0) {
-			wait_on_page_writeback(page);
-		} else {
-			if (PageWriteback(page))
-				goto unlock_page;
-		}
-
-		/*
-		 * Anonymous pages must have swap cache references otherwise
-		 * the information contained in the page maps cannot be
-		 * preserved.
-		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
-			if (!add_to_swap(page, GFP_KERNEL)) {
-				rc = -ENOMEM;
-				goto unlock_page;
-			}
-		}
-
-		if (!to) {
-			rc = swap_page(page);
-			goto next;
-		}
-
-		newpage = lru_to_page(to);
-		lock_page(newpage);
-
-		/*
-		 * Pages are properly locked and writeback is complete.
-		 * Try to migrate the page.
-		 */
-		mapping = page_mapping(page);
-		if (!mapping)
-			goto unlock_both;
-
-		if (mapping->a_ops->migratepage) {
-			/*
-			 * Most pages have a mapping and most filesystems
-			 * should provide a migration function. Anonymous
-			 * pages are part of swap space which also has its
-			 * own migration function. This is the most common
-			 * path for page migration.
-			 */
-			rc = mapping->a_ops->migratepage(newpage, page);
-			goto unlock_both;
-                }
-
-		/*
-		 * Default handling if a filesystem does not provide
-		 * a migration function. We can only migrate clean
-		 * pages so try to write out any dirty pages first.
-		 */
-		if (PageDirty(page)) {
-			switch (pageout(page, mapping)) {
-			case PAGE_KEEP:
-			case PAGE_ACTIVATE:
-				goto unlock_both;
-
-			case PAGE_SUCCESS:
-				unlock_page(newpage);
-				goto next;
-
-			case PAGE_CLEAN:
-				; /* try to migrate the page below */
-			}
-                }
-
-		/*
-		 * Buffers are managed in a filesystem specific way.
-		 * We must have no buffers or drop them.
-		 */
-		if (!page_has_buffers(page) ||
-		    try_to_release_page(page, GFP_KERNEL)) {
-			rc = migrate_page(newpage, page);
-			goto unlock_both;
-		}
-
-		/*
-		 * On early passes with mapped pages simply
-		 * retry. There may be a lock held for some
-		 * buffers that may go away. Later
-		 * swap them out.
-		 */
-		if (pass > 4) {
-			/*
-			 * Persistently unable to drop buffers..... As a
-			 * measure of last resort we fall back to
-			 * swap_page().
-			 */
-			unlock_page(newpage);
-			newpage = NULL;
-			rc = swap_page(page);
-			goto next;
-		}
-
-unlock_both:
-		unlock_page(newpage);
-
-unlock_page:
-		unlock_page(page);
-
-next:
-		if (rc == -EAGAIN) {
-			retry++;
-		} else if (rc) {
-			/* Permanent failure */
-			list_move(&page->lru, failed);
-			nr_failed++;
-		} else {
-			if (newpage) {
-				/* Successful migration. Return page to LRU */
-				move_to_lru(newpage);
-			}
-			list_move(&page->lru, moved);
-		}
-	}
-	if (retry && pass++ < 10)
-		goto redo;
-
-	if (!swapwrite)
-		current->flags &= ~PF_SWAPWRITE;
-
-	return nr_failed + retry;
-}
-
-/*
- * Isolate one page from the LRU lists and put it on the
- * indicated list with elevated refcount.
- *
- * Result:
- *  0 = page not on LRU list
- *  1 = page removed from LRU list and added to the specified list.
- */
-int isolate_lru_page(struct page *page)
-{
-	int ret = 0;
-
-	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
-		spin_lock_irq(&zone->lru_lock);
-		if (TestClearPageLRU(page)) {
-			ret = 1;
-			get_page(page);
-			if (PageActive(page))
-				del_page_from_active_list(zone, page);
-			else
-				del_page_from_inactive_list(zone, page);
-		}
-		spin_unlock_irq(&zone->lru_lock);
-	}
-
-	return ret;
-}
-#endif
-
 /*
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
Index: linux-2.6.16-rc6/include/linux/swap.h
===================================================================
--- linux-2.6.16-rc6.orig/include/linux/swap.h	2006-03-11 14:12:55.000000000 -0800
+++ linux-2.6.16-rc6/include/linux/swap.h	2006-03-15 16:48:53.000000000 -0800
@@ -175,6 +175,21 @@ extern void swap_setup(void);
 extern int try_to_free_pages(struct zone **, gfp_t);
 extern int shrink_all_memory(int);
 extern int vm_swappiness;
+extern int remove_mapping(struct address_space *mapping, struct page *page);
+
+/* possible outcome of pageout() */
+typedef enum {
+	/* failed to write page out, page is locked */
+	PAGE_KEEP,
+	/* move page to the active list, page is locked */
+	PAGE_ACTIVATE,
+	/* page has been sent to the disk successfully, page is unlocked */
+	PAGE_SUCCESS,
+	/* page is clean and locked */
+	PAGE_CLEAN,
+} pageout_t;
+
+extern pageout_t pageout(struct page *page, struct address_space *mapping);
 
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
@@ -188,25 +203,6 @@ static inline int zone_reclaim(struct zo
 }
 #endif
 
-#ifdef CONFIG_MIGRATION
-extern int isolate_lru_page(struct page *p);
-extern int putback_lru_pages(struct list_head *l);
-extern int migrate_page(struct page *, struct page *);
-extern void migrate_page_copy(struct page *, struct page *);
-extern int migrate_page_remove_references(struct page *, struct page *, int);
-extern int migrate_pages(struct list_head *l, struct list_head *t,
-		struct list_head *moved, struct list_head *failed);
-extern int fail_migrate_page(struct page *, struct page *);
-#else
-static inline int isolate_lru_page(struct page *p) { return -ENOSYS; }
-static inline int putback_lru_pages(struct list_head *l) { return 0; }
-static inline int migrate_pages(struct list_head *l, struct list_head *t,
-	struct list_head *moved, struct list_head *failed) { return -ENOSYS; }
-/* Possible settings for the migrate_page() method in address_operations */
-#define migrate_page NULL
-#define fail_migrate_page NULL
-#endif
-
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
Index: linux-2.6.16-rc6/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc6.orig/mm/mempolicy.c	2006-03-14 19:52:25.000000000 -0800
+++ linux-2.6.16-rc6/mm/mempolicy.c	2006-03-15 17:33:31.000000000 -0800
@@ -86,6 +86,7 @@
 #include <linux/swap.h>
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
+#include <linux/migrate.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -95,9 +96,6 @@
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
 #define MPOL_MF_STATS (MPOL_MF_INTERNAL << 2)		/* Gather statistics */
 
-/* The number of pages to migrate per call to migrate_pages() */
-#define MIGRATE_CHUNK_SIZE 256
-
 static kmem_cache_t *policy_cache;
 static kmem_cache_t *sn_cache;
 
@@ -331,6 +329,7 @@ check_range(struct mm_struct *mm, unsign
 	struct vm_area_struct *first, *vma, *prev;
 
 	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
+#ifdef CONFIG_MIGRATION
 		/* Must have swap device for migration */
 		if (nr_swap_pages <= 0)
 			return ERR_PTR(-ENODEV);
@@ -342,6 +341,9 @@ check_range(struct mm_struct *mm, unsign
 		 * pages that may be busy.
 		 */
 		lru_add_drain_all();
+#else
+		return -ENOSYS;
+#endif
 	}
 
 	first = find_vma(mm, start);
@@ -553,10 +555,10 @@ long do_get_mempolicy(int *policy, nodem
 /*
  * page migration
  */
-
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags)
 {
+#ifdef CONFIG_MIGRATION
 	/*
 	 * Avoid migrating a page that is shared with others.
 	 */
@@ -564,80 +566,10 @@ static void migrate_page_add(struct page
 		if (isolate_lru_page(page))
 			list_add_tail(&page->lru, pagelist);
 	}
+#endif
 }
 
-/*
- * Migrate the list 'pagelist' of pages to a certain destination.
- *
- * Specify destination with either non-NULL vma or dest_node >= 0
- * Return the number of pages not migrated or error code
- */
-static int migrate_pages_to(struct list_head *pagelist,
-			struct vm_area_struct *vma, int dest)
-{
-	LIST_HEAD(newlist);
-	LIST_HEAD(moved);
-	LIST_HEAD(failed);
-	int err = 0;
-	unsigned long offset = 0;
-	int nr_pages;
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
-	err = migrate_pages(pagelist, &newlist, &moved, &failed);
-
-	putback_lru_pages(&moved);	/* Call release pages instead ?? */
-
-	if (err >= 0 && list_empty(&newlist) && !list_empty(pagelist))
-		goto redo;
-out:
-	/* Return leftover allocated pages */
-	while (!list_empty(&newlist)) {
-		page = list_entry(newlist.next, struct page, lru);
-		list_del(&page->lru);
-		__free_page(page);
-	}
-	list_splice(&failed, pagelist);
-	if (err < 0)
-		return err;
-
-	/* Calculate number of leftover pages */
-	nr_pages = 0;
-	list_for_each(p, pagelist)
-		nr_pages++;
-	return nr_pages;
-}
-
+#ifdef CONFIG_MIGRATION
 /*
  * Migrate pages from one node to a target node.
  * Returns error or the number of pages not migrated.
@@ -661,6 +593,7 @@ int migrate_to_node(struct mm_struct *mm
 	}
 	return err;
 }
+#endif
 
 /*
  * Move pages between the two nodesets so as to preserve the physical
@@ -671,6 +604,7 @@ int migrate_to_node(struct mm_struct *mm
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags)
 {
+#ifdef CONFIG_MIGRATION
 	LIST_HEAD(pagelist);
 	int busy = 0;
 	int err = 0;
@@ -742,6 +676,9 @@ int do_migrate_pages(struct mm_struct *m
 	if (err < 0)
 		return err;
 	return busy;
+#else
+	return -ENOSYS;
+#endif
 }
 
 long do_mbind(unsigned long start, unsigned long len,
@@ -802,12 +739,15 @@ long do_mbind(unsigned long start, unsig
 
 		err = mbind_range(vma, start, end, new);
 
+#ifdef CONFIG_MIGRATION
 		if (!list_empty(&pagelist))
 			nr_failed = migrate_pages_to(&pagelist, vma, -1);
+#endif
 
 		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
 	}
+
 	if (!list_empty(&pagelist))
 		putback_lru_pages(&pagelist);
 
Index: linux-2.6.16-rc6/fs/xfs/linux-2.6/xfs_buf.c
===================================================================
--- linux-2.6.16-rc6.orig/fs/xfs/linux-2.6/xfs_buf.c	2006-03-11 14:12:55.000000000 -0800
+++ linux-2.6.16-rc6/fs/xfs/linux-2.6/xfs_buf.c	2006-03-15 17:03:01.000000000 -0800
@@ -29,6 +29,7 @@
 #include <linux/blkdev.h>
 #include <linux/hash.h>
 #include <linux/kthread.h>
+#include <linux/migrate.h>
 #include "xfs_linux.h"
 
 STATIC kmem_zone_t *xfs_buf_zone;
Index: linux-2.6.16-rc6/fs/buffer.c
===================================================================
--- linux-2.6.16-rc6.orig/fs/buffer.c	2006-03-11 14:12:55.000000000 -0800
+++ linux-2.6.16-rc6/fs/buffer.c	2006-03-15 17:09:57.000000000 -0800
@@ -3051,66 +3051,6 @@ asmlinkage long sys_bdflush(int func, lo
 }
 
 /*
- * Migration function for pages with buffers. This function can only be used
- * if the underlying filesystem guarantees that no other references to "page"
- * exist.
- */
-#ifdef CONFIG_MIGRATION
-int buffer_migrate_page(struct page *newpage, struct page *page)
-{
-	struct address_space *mapping = page->mapping;
-	struct buffer_head *bh, *head;
-
-	if (!mapping)
-		return -EAGAIN;
-
-	if (!page_has_buffers(page))
-		return migrate_page(newpage, page);
-
-	head = page_buffers(page);
-
-	if (migrate_page_remove_references(newpage, page, 3))
-		return -EAGAIN;
-
-	bh = head;
-	do {
-		get_bh(bh);
-		lock_buffer(bh);
-		bh = bh->b_this_page;
-
-	} while (bh != head);
-
-	ClearPagePrivate(page);
-	set_page_private(newpage, page_private(page));
-	set_page_private(page, 0);
-	put_page(page);
-	get_page(newpage);
-
-	bh = head;
-	do {
-		set_bh_page(bh, newpage, bh_offset(bh));
-		bh = bh->b_this_page;
-
-	} while (bh != head);
-
-	SetPagePrivate(newpage);
-
-	migrate_page_copy(newpage, page);
-
-	bh = head;
-	do {
-		unlock_buffer(bh);
- 		put_bh(bh);
-		bh = bh->b_this_page;
-
-	} while (bh != head);
-
-	return 0;
-}
-EXPORT_SYMBOL(buffer_migrate_page);
-#endif
-
-/*
  * Buffer-head allocation
  */
 static kmem_cache_t *bh_cachep;
Index: linux-2.6.16-rc6/mm/Kconfig
===================================================================
--- linux-2.6.16-rc6.orig/mm/Kconfig	2006-03-11 14:12:55.000000000 -0800
+++ linux-2.6.16-rc6/mm/Kconfig	2006-03-15 17:31:53.000000000 -0800
@@ -137,5 +137,11 @@ config SPLIT_PTLOCK_CPUS
 # support for page migration
 #
 config MIGRATION
+	bool "Page migration"
 	def_bool y if NUMA || SPARSEMEM || DISCONTIGMEM
 	depends on SWAP
+	help
+	  Allows the migration of the physical location of pages of processes
+	  while the virtual addresses are not changed. This is useful for
+	  example on NUMA systems to put pages nearer to the processors accessing
+	  the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
