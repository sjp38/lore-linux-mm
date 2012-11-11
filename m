Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 8D4306B005A
	for <linux-mm@kvack.org>; Sun, 11 Nov 2012 14:02:00 -0500 (EST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v12 3/7] mm: introduce a common interface for balloon pages mobility
Date: Sun, 11 Nov 2012 17:01:16 -0200
Message-Id: <16764824450ccaebca7f22aa754507d60c383201.1352656285.git.aquini@redhat.com>
In-Reply-To: <cover.1352656285.git.aquini@redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
In-Reply-To: <cover.1352656285.git.aquini@redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, aquini@redhat.com

Memory fragmentation introduced by ballooning might reduce significantly
the number of 2MB contiguous memory blocks that can be used within a guest,
thus imposing performance penalties associated with the reduced number of
transparent huge pages that could be used by the guest workload.

This patch introduces a common interface to help a balloon driver on
making its page set movable to compaction, and thus allowing the system
to better leverage the compation efforts on memory defragmentation.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/balloon_compaction.h | 256 +++++++++++++++++++++++++++++++
 include/linux/migrate.h            |  10 ++
 include/linux/pagemap.h            |  16 ++
 mm/Kconfig                         |  15 ++
 mm/Makefile                        |   3 +-
 mm/balloon_compaction.c            | 302 +++++++++++++++++++++++++++++++++++++
 6 files changed, 601 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/balloon_compaction.h
 create mode 100644 mm/balloon_compaction.c

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
new file mode 100644
index 0000000..2e63d94
--- /dev/null
+++ b/include/linux/balloon_compaction.h
@@ -0,0 +1,256 @@
+/*
+ * include/linux/balloon_compaction.h
+ *
+ * Common interface definitions for making balloon pages movable by compaction.
+ *
+ * Despite being perfectly possible to perform ballooned pages migration, they
+ * make a special corner case to compaction scans because balloon pages are not
+ * enlisted at any LRU list like the other pages we do compact / migrate.
+ *
+ * As the page isolation scanning step a compaction thread does is a lockless
+ * procedure (from a page standpoint), it might bring some racy situations while
+ * performing balloon page compaction. In order to sort out these racy scenarios
+ * and safely perform balloon's page compaction and migration we must, always,
+ * ensure following these three simple rules:
+ *
+ *   i. when updating a balloon's page ->mapping element, strictly do it under
+ *      the following lock order, independently of the far superior
+ *      locking scheme (lru_lock, balloon_lock):
+ *	    +-page_lock(page);
+ *	      +--spin_lock_irq(&b_dev_info->pages_lock);
+ *	            ... page->mapping updates here ...
+ *
+ *  ii. before isolating or dequeueing a balloon page from the balloon device
+ *      pages list, the page reference counter must be raised by one and the
+ *      extra refcount must be dropped when the page is enqueued back into
+ *      the balloon device page list, thus a balloon page keeps its reference
+ *      counter raised only while it is under our special handling;
+ *
+ * iii. after the lockless scan step have selected a potential balloon page for
+ *      isolation, re-test the page->mapping flags and the page ref counter
+ *      under the proper page lock, to ensure isolating a valid balloon page
+ *      (not yet isolated, nor under release procedure)
+ *
+ * The functions provided by this interface are placed to help on coping with
+ * the aforementioned balloon page corner case, as well as to ensure the simple
+ * set of exposed rules are satisfied while we are dealing with balloon pages
+ * compaction / migration.
+ *
+ * Copyright (C) 2012, Red Hat, Inc.  Rafael Aquini <aquini@redhat.com>
+ */
+#ifndef _LINUX_BALLOON_COMPACTION_H
+#define _LINUX_BALLOON_COMPACTION_H
+#include <linux/pagemap.h>
+#include <linux/migrate.h>
+#include <linux/gfp.h>
+#include <linux/err.h>
+
+/*
+ * Balloon device information descriptor.
+ * This struct is used to allow the common balloon compaction interface
+ * procedures to find the proper balloon device holding memory pages they'll
+ * have to cope for page compaction / migration, as well as it serves the
+ * balloon driver as a page book-keeper for its registered balloon devices.
+ */
+struct balloon_dev_info {
+	void *balloon_device;		/* balloon device descriptor */
+	struct address_space *mapping;	/* balloon special page->mapping */
+	unsigned long isolated_pages;	/* # of isolated pages for migration */
+	spinlock_t pages_lock;		/* Protection to pages list */
+	struct list_head pages;		/* Pages enqueued & handled to Host */
+};
+
+extern struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info);
+extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
+extern struct balloon_dev_info *balloon_devinfo_alloc(
+						void *balloon_dev_descriptor);
+
+static inline void balloon_devinfo_free(struct balloon_dev_info *b_dev_info)
+{
+	kfree(b_dev_info);
+}
+
+/*
+ * balloon_page_free - release a balloon page back to the page free lists
+ * @page: ballooned page to be set free
+ *
+ * This function must be used to properly set free an isolated/dequeued balloon
+ * page at the end of a sucessful page migration, or at the balloon driver's
+ * page release procedure.
+ */
+static inline void balloon_page_free(struct page *page)
+{
+	/*
+	 * Balloon pages always get an extra refcount before being isolated
+	 * and before being dequeued to help on sorting out fortuite colisions
+	 * between a thread attempting to isolate and another thread attempting
+	 * to release the very same balloon page.
+	 *
+	 * Before we handle the page back to Buddy, lets drop its extra refcnt.
+	 */
+	put_page(page);
+	__free_page(page);
+}
+
+#ifdef CONFIG_BALLOON_COMPACTION
+extern bool balloon_page_isolate(struct page *page);
+extern void balloon_page_putback(struct page *page);
+extern int balloon_page_migrate(struct page *newpage,
+				struct page *page, enum migrate_mode mode);
+extern struct address_space
+*balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
+			const struct address_space_operations *a_ops);
+
+static inline void balloon_mapping_free(struct address_space *balloon_mapping)
+{
+	kfree(balloon_mapping);
+}
+
+/*
+ * __is_movable_balloon_page - helper to perform @page mapping->flags tests
+ */
+static inline bool __is_movable_balloon_page(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	return mapping_balloon(mapping);
+}
+
+/*
+ * balloon_page_movable - test page->mapping->flags to identify balloon pages
+ *			  that can be moved by compaction/migration.
+ *
+ * This function is used at core compaction's page isolation scheme, therefore
+ * most pages exposed to it are not enlisted as balloon pages and so, to avoid
+ * undesired side effects like racing against __free_pages(), we cannot afford
+ * holding the page locked while testing page->mapping->flags here.
+ *
+ * As we might return false positives in the case of a balloon page being just
+ * released under us, the page->mapping->flags need to be re-tested later,
+ * under the proper page lock, at the functions that will be coping with the
+ * balloon page case.
+ */
+static inline bool balloon_page_movable(struct page *page)
+{
+	/*
+	 * Before dereferencing and testing mapping->flags, lets make sure
+	 * this is not a page that uses ->mapping in a different way
+	 */
+	if (!PageSlab(page) && !PageSwapCache(page) && !PageAnon(page) &&
+	    !page_mapped(page))
+		return __is_movable_balloon_page(page);
+
+	return false;
+}
+
+/*
+ * balloon_page_insert - insert a page into the balloon's page list and make
+ *		         the page->mapping assignment accordingly.
+ * @page    : page to be assigned as a 'balloon page'
+ * @mapping : allocated special 'balloon_mapping'
+ * @head    : balloon's device page list head
+ *
+ * Caller must ensure the page is locked and the spin_lock protecting balloon
+ * pages list is held before inserting a page into the balloon device.
+ */
+static inline void balloon_page_insert(struct page *page,
+				       struct address_space *mapping,
+				       struct list_head *head)
+{
+	page->mapping = mapping;
+	list_add(&page->lru, head);
+}
+
+/*
+ * balloon_page_delete - delete a page from balloon's page list and clear
+ *			 the page->mapping assignement accordingly.
+ * @page    : page to be released from balloon's page list
+ *
+ * Caller must ensure the page is locked and the spin_lock protecting balloon
+ * pages list is held before deleting a page from the balloon device.
+ */
+static inline void balloon_page_delete(struct page *page)
+{
+	page->mapping = NULL;
+	list_del(&page->lru);
+}
+
+/*
+ * balloon_page_device - get the b_dev_info descriptor for the balloon device
+ *			 that enqueues the given page.
+ */
+static inline struct balloon_dev_info *balloon_page_device(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	if (likely(mapping))
+		return mapping->private_data;
+
+	return NULL;
+}
+
+static inline gfp_t balloon_mapping_gfp_mask(void)
+{
+	return GFP_HIGHUSER_MOVABLE;
+}
+
+static inline bool balloon_compaction_check(void)
+{
+	return true;
+}
+
+#else /* !CONFIG_BALLOON_COMPACTION */
+
+static inline void *balloon_mapping_alloc(void *balloon_device,
+				const struct address_space_operations *a_ops)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static inline void balloon_mapping_free(struct address_space *balloon_mapping)
+{
+	return;
+}
+
+static inline void balloon_page_insert(struct page *page,
+				       struct address_space *mapping,
+				       struct list_head *head)
+{
+	list_add(&page->lru, head);
+}
+
+static inline void balloon_page_delete(struct page *page)
+{
+	list_del(&page->lru);
+}
+
+static inline bool balloon_page_movable(struct page *page)
+{
+	return false;
+}
+
+static inline bool balloon_page_isolate(struct page *page)
+{
+	return false;
+}
+
+static inline void balloon_page_putback(struct page *page)
+{
+	return;
+}
+
+static inline int balloon_page_migrate(struct page *newpage,
+				struct page *page, enum migrate_mode mode)
+{
+	return 0;
+}
+
+static inline gfp_t balloon_mapping_gfp_mask(void)
+{
+	return GFP_HIGHUSER;
+}
+
+static inline bool balloon_compaction_check(void)
+{
+	return false;
+}
+#endif /* CONFIG_BALLOON_COMPACTION */
+#endif /* _LINUX_BALLOON_COMPACTION_H */
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index fab15ae..4ce2ee9 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -11,8 +11,18 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
  * Return values from addresss_space_operations.migratepage():
  * - negative errno on page migration failure;
  * - zero on page migration success;
+ *
+ * The balloon page migration introduces this special case where a 'distinct'
+ * return code is used to flag a successful page migration to unmap_and_move().
+ * This approach is necessary because page migration can race against balloon
+ * deflation procedure, and for such case we could introduce a nasty page leak
+ * if a successfully migrated balloon page gets released concurrently with
+ * migration's unmap_and_move() wrap-up steps.
  */
 #define MIGRATEPAGE_SUCCESS		0
+#define MIGRATEPAGE_BALLOON_SUCCESS	1 /* special ret code for balloon page
+					   * sucessful migration case.
+					   */
 
 #ifdef CONFIG_MIGRATION
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e42c762..6da609d 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -24,6 +24,7 @@ enum mapping_flags {
 	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
+	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -53,6 +54,21 @@ static inline int mapping_unevictable(struct address_space *mapping)
 	return !!mapping;
 }
 
+static inline void mapping_set_balloon(struct address_space *mapping)
+{
+	set_bit(AS_BALLOON_MAP, &mapping->flags);
+}
+
+static inline void mapping_clear_balloon(struct address_space *mapping)
+{
+	clear_bit(AS_BALLOON_MAP, &mapping->flags);
+}
+
+static inline int mapping_balloon(struct address_space *mapping)
+{
+	return mapping && test_bit(AS_BALLOON_MAP, &mapping->flags);
+}
+
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
 	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
diff --git a/mm/Kconfig b/mm/Kconfig
index a3f8ddd..ae92dd5 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -188,6 +188,21 @@ config SPLIT_PTLOCK_CPUS
 	default "4"
 
 #
+# support for memory balloon compaction
+config BALLOON_COMPACTION
+	bool "Allow for balloon memory compaction/migration"
+	def_bool y
+	depends on TRANSPARENT_HUGEPAGE && VIRTIO_BALLOON
+	help
+	  Memory fragmentation introduced by ballooning might reduce
+	  significantly the number of 2MB contiguous memory blocks that can be
+	  used within a guest, thus imposing performance penalties associated
+	  with the reduced number of transparent huge pages that could be used
+	  by the guest workload. Allowing the compaction & migration for memory
+	  pages enlisted as being part of memory balloon devices avoids the
+	  scenario aforementioned and helps improving memory defragmentation.
+
+#
 # support for memory compaction
 config COMPACTION
 	bool "Allow for memory compaction"
diff --git a/mm/Makefile b/mm/Makefile
index 6b025f8..3a46287 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -16,7 +16,8 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
-			   compaction.o interval_tree.o $(mmu-y)
+			   compaction.o balloon_compaction.o \
+			   interval_tree.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
new file mode 100644
index 0000000..07dbc8e
--- /dev/null
+++ b/mm/balloon_compaction.c
@@ -0,0 +1,302 @@
+/*
+ * mm/balloon_compaction.c
+ *
+ * Common interface for making balloon pages movable by compaction.
+ *
+ * Copyright (C) 2012, Red Hat, Inc.  Rafael Aquini <aquini@redhat.com>
+ */
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/export.h>
+#include <linux/balloon_compaction.h>
+
+/*
+ * balloon_devinfo_alloc - allocates a balloon device information descriptor.
+ * @balloon_dev_descriptor: pointer to reference the balloon device which
+ *                          this struct balloon_dev_info will be servicing.
+ *
+ * Driver must call it to properly allocate and initialize an instance of
+ * struct balloon_dev_info which will be used to reference a balloon device
+ * as well as to keep track of the balloon device page list.
+ */
+struct balloon_dev_info *balloon_devinfo_alloc(void *balloon_dev_descriptor)
+{
+	struct balloon_dev_info *b_dev_info;
+	b_dev_info = kmalloc(sizeof(*b_dev_info), GFP_KERNEL);
+	if (!b_dev_info)
+		return ERR_PTR(-ENOMEM);
+
+	b_dev_info->balloon_device = balloon_dev_descriptor;
+	b_dev_info->mapping = NULL;
+	b_dev_info->isolated_pages = 0;
+	spin_lock_init(&b_dev_info->pages_lock);
+	INIT_LIST_HEAD(&b_dev_info->pages);
+
+	return b_dev_info;
+}
+EXPORT_SYMBOL_GPL(balloon_devinfo_alloc);
+
+/*
+ * balloon_page_enqueue - allocates a new page and inserts it into the balloon
+ *			  page list.
+ * @b_dev_info: balloon device decriptor where we will insert a new page to
+ *
+ * Driver must call it to properly allocate a new enlisted balloon page
+ * before definetively removing it from the guest system.
+ * This function returns the page address for the recently enqueued page or
+ * NULL in the case we fail to allocate a new page this turn.
+ */
+struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
+{
+	unsigned long flags;
+	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
+					__GFP_NOMEMALLOC | __GFP_NORETRY);
+	if (!page)
+		return NULL;
+
+	/*
+	 * Block others from accessing the 'page' when we get around to
+	 * establishing additional references. We should be the only one
+	 * holding a reference to the 'page' at this point.
+	 */
+	BUG_ON(!trylock_page(page));
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	balloon_page_insert(page, b_dev_info->mapping, &b_dev_info->pages);
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+	unlock_page(page);
+	return page;
+}
+EXPORT_SYMBOL_GPL(balloon_page_enqueue);
+
+/*
+ * balloon_page_dequeue - removes a page from balloon's page list and returns
+ *			  the its address to allow the driver release the page.
+ * @b_dev_info: balloon device decriptor where we will grab a page from.
+ *
+ * Driver must call it to properly de-allocate a previous enlisted balloon page
+ * before definetively releasing it back to the guest system.
+ * This function returns the page address for the recently dequeued page or
+ * NULL in the case we find balloon's page list temporarily empty due to
+ * compaction isolated pages.
+ */
+struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
+{
+	struct page *page, *tmp;
+	unsigned long flags;
+	bool dequeued_page;
+
+	dequeued_page = false;
+	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
+		/*
+		 * Block others from accessing the 'page' while we get around
+		 * establishing additional references and preparing the 'page'
+		 * to be released by the balloon driver.
+		 */
+		if (trylock_page(page)) {
+			spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+			/*
+			 * Raise the page refcount here to prevent any wrong
+			 * attempt to isolate this page, in case of coliding
+			 * with balloon_page_isolate() just after we release
+			 * the page lock.
+			 *
+			 * balloon_page_free() will take care of dropping
+			 * this extra refcount later.
+			 */
+			get_page(page);
+			balloon_page_delete(page);
+			spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+			unlock_page(page);
+			dequeued_page = true;
+			break;
+		}
+	}
+
+	if (!dequeued_page) {
+		/*
+		 * If we are unable to dequeue a balloon page because the page
+		 * list is empty and there is no isolated pages, then something
+		 * went out of track and some balloon pages are lost.
+		 * BUG() here, otherwise the balloon driver may get stuck into
+		 * an infinite loop while attempting to release all its pages.
+		 */
+		spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+		if (unlikely(list_empty(&b_dev_info->pages) &&
+			     !b_dev_info->isolated_pages))
+			BUG();
+		spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+		page = NULL;
+	}
+	return page;
+}
+EXPORT_SYMBOL_GPL(balloon_page_dequeue);
+
+#ifdef CONFIG_BALLOON_COMPACTION
+/*
+ * balloon_mapping_alloc - allocates a special ->mapping for ballooned pages.
+ * @b_dev_info: holds the balloon device information descriptor.
+ * @a_ops: balloon_mapping address_space_operations descriptor.
+ *
+ * Driver must call it to properly allocate and initialize an instance of
+ * struct address_space which will be used as the special page->mapping for
+ * balloon device enlisted page instances.
+ */
+struct address_space *balloon_mapping_alloc(struct balloon_dev_info *b_dev_info,
+				const struct address_space_operations *a_ops)
+{
+	struct address_space *mapping;
+
+	mapping = kmalloc(sizeof(*mapping), GFP_KERNEL);
+	if (!mapping)
+		return ERR_PTR(-ENOMEM);
+
+	/*
+	 * Give a clean 'zeroed' status to all elements of this special
+	 * balloon page->mapping struct address_space instance.
+	 */
+	address_space_init_once(mapping);
+
+	/*
+	 * Set mapping->flags appropriately, to allow balloon pages
+	 * ->mapping identification.
+	 */
+	mapping_set_balloon(mapping);
+	mapping_set_gfp_mask(mapping, balloon_mapping_gfp_mask());
+
+	/* balloon's page->mapping->a_ops callback descriptor */
+	mapping->a_ops = a_ops;
+
+	/*
+	 * Establish a pointer reference back to the balloon device descriptor
+	 * this particular page->mapping will be servicing.
+	 * This is used by compaction / migration procedures to identify and
+	 * access the balloon device pageset while isolating / migrating pages.
+	 *
+	 * As some balloon drivers can register multiple balloon devices
+	 * for a single guest, this also helps compaction / migration to
+	 * properly deal with multiple balloon pagesets, when required.
+	 */
+	mapping->private_data = b_dev_info;
+	b_dev_info->mapping = mapping;
+
+	return mapping;
+}
+EXPORT_SYMBOL_GPL(balloon_mapping_alloc);
+
+static inline void __isolate_balloon_page(struct page *page)
+{
+	struct balloon_dev_info *b_dev_info = page->mapping->private_data;
+	unsigned long flags;
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	list_del(&page->lru);
+	b_dev_info->isolated_pages++;
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+}
+
+static inline void __putback_balloon_page(struct page *page)
+{
+	struct balloon_dev_info *b_dev_info = page->mapping->private_data;
+	unsigned long flags;
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	list_add(&page->lru, &b_dev_info->pages);
+	b_dev_info->isolated_pages--;
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+}
+
+static inline int __migrate_balloon_page(struct address_space *mapping,
+		struct page *newpage, struct page *page, enum migrate_mode mode)
+{
+	return page->mapping->a_ops->migratepage(mapping, newpage, page, mode);
+}
+
+/* __isolate_lru_page() counterpart for a ballooned page */
+bool balloon_page_isolate(struct page *page)
+{
+	/*
+	 * Avoid burning cycles with pages that are yet under __free_pages(),
+	 * or just got freed under us.
+	 *
+	 * In case we 'win' a race for a balloon page being freed under us and
+	 * raise its refcount preventing __free_pages() from doing its job
+	 * the put_page() at the end of this block will take care of
+	 * release this page, thus avoiding a nasty leakage.
+	 */
+	if (likely(get_page_unless_zero(page))) {
+		/*
+		 * As balloon pages are not isolated from LRU lists, concurrent
+		 * compaction threads can race against page migration functions
+		 * as well as race against the balloon driver releasing a page.
+		 *
+		 * In order to avoid having an already isolated balloon page
+		 * being (wrongly) re-isolated while it is under migration,
+		 * or to avoid attempting to isolate pages being released by
+		 * the balloon driver, lets be sure we have the page lock
+		 * before proceeding with the balloon page isolation steps.
+		 */
+		if (likely(trylock_page(page))) {
+			/*
+			 * A ballooned page, by default, has just one refcount.
+			 * Prevent concurrent compaction threads from isolating
+			 * an already isolated balloon page by refcount check.
+			 */
+			if (__is_movable_balloon_page(page) &&
+			    page_count(page) == 2) {
+				__isolate_balloon_page(page);
+				unlock_page(page);
+				return true;
+			}
+			unlock_page(page);
+		}
+		put_page(page);
+	}
+	return false;
+}
+
+/* putback_lru_page() counterpart for a ballooned page */
+void balloon_page_putback(struct page *page)
+{
+	/*
+	 * 'lock_page()' stabilizes the page and prevents races against
+	 * concurrent isolation threads attempting to re-isolate it.
+	 */
+	lock_page(page);
+
+	if (__is_movable_balloon_page(page)) {
+		__putback_balloon_page(page);
+		/* drop the extra ref count taken for page isolation */
+		put_page(page);
+	} else {
+		WARN_ON(1);
+		dump_page(page);
+	}
+	unlock_page(page);
+}
+
+/* move_to_new_page() counterpart for a ballooned page */
+int balloon_page_migrate(struct page *newpage,
+			 struct page *page, enum migrate_mode mode)
+{
+	struct address_space *mapping;
+	int rc = -EAGAIN;
+
+	/*
+	 * Block others from accessing the 'newpage' when we get around to
+	 * establishing additional references. We should be the only one
+	 * holding a reference to the 'newpage' at this point.
+	 */
+	BUG_ON(!trylock_page(newpage));
+
+	if (WARN_ON(!__is_movable_balloon_page(page))) {
+		dump_page(page);
+		unlock_page(newpage);
+		return rc;
+	}
+
+	mapping = page->mapping;
+	if (mapping)
+		rc = __migrate_balloon_page(mapping, newpage, page, mode);
+
+	unlock_page(newpage);
+	return rc;
+}
+#endif /* CONFIG_BALLOON_COMPACTION */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
