Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 625786B0044
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 01:25:28 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v9 1/5] mm: introduce a common interface for balloon pages mobility
Date: Sat, 25 Aug 2012 02:24:56 -0300
Message-Id: <aa4af6e819584cb05fc0dba44594ae23ab761d03.1345869378.git.aquini@redhat.com>
In-Reply-To: <cover.1345869378.git.aquini@redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
In-Reply-To: <cover.1345869378.git.aquini@redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rafael Aquini <aquini@redhat.com>

Memory fragmentation introduced by ballooning might reduce significantly
the number of 2MB contiguous memory blocks that can be used within a guest,
thus imposing performance penalties associated with the reduced number of
transparent huge pages that could be used by the guest workload.

This patch introduces a common interface to help a balloon driver on
making its page set movable to compaction, and thus allowing the system
to better leverage the compation efforts on memory defragmentation.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 include/linux/balloon_compaction.h | 137 +++++++++++++++++++++++++++++
 include/linux/pagemap.h            |  18 ++++
 mm/Kconfig                         |  15 ++++
 mm/Makefile                        |   2 +-
 mm/balloon_compaction.c            | 172 +++++++++++++++++++++++++++++++++++++
 5 files changed, 343 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/balloon_compaction.h
 create mode 100644 mm/balloon_compaction.c

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
new file mode 100644
index 0000000..7afb0ae
--- /dev/null
+++ b/include/linux/balloon_compaction.h
@@ -0,0 +1,137 @@
+/*
+ * include/linux/balloon_compaction.h
+ *
+ * Common interface definitions for making balloon pages movable to compaction.
+ *
+ * Copyright (C) 2012, Red Hat, Inc.  Rafael Aquini <aquini@redhat.com>
+ */
+#ifndef _LINUX_BALLOON_COMPACTION_H
+#define _LINUX_BALLOON_COMPACTION_H
+#ifdef __KERNEL__
+
+#include <linux/rcupdate.h>
+#include <linux/pagemap.h>
+#include <linux/gfp.h>
+
+#ifdef CONFIG_BALLOON_COMPACTION
+#define count_balloon_event(e)	count_vm_event(e)
+extern bool isolate_balloon_page(struct page *);
+extern void putback_balloon_page(struct page *);
+extern int migrate_balloon_page(struct page *newpage,
+				struct page *page, enum migrate_mode mode);
+
+static inline gfp_t balloon_mapping_gfp_mask(void)
+{
+	return GFP_HIGHUSER_MOVABLE;
+}
+
+/*
+ * movable_balloon_page - test page->mapping->flags to identify balloon pages
+ *			  that can be moved by compaction/migration.
+ *
+ * This function is used at core compaction's page isolation scheme and so it's
+ * exposed to several system pages which may, or may not, be part of a memory
+ * balloon, and thus we cannot afford to hold a page locked to perform tests.
+ *
+ * Therefore, as we might return false positives in the case a balloon page
+ * is just released under us, the page->mapping->flags need to be retested
+ * with the proper page lock held, on the functions that will cope with the
+ * balloon page later.
+ */
+static inline bool movable_balloon_page(struct page *page)
+{
+	/*
+	 * Before dereferencing and testing mapping->flags, lets make sure
+	 * this is not a page that uses ->mapping in a different way
+	 */
+	if (!PageSlab(page) && !PageSwapCache(page) &&
+	    !PageAnon(page) && !page_mapped(page)) {
+		/*
+		 * While doing compaction core work, we cannot afford to hold
+		 * page lock as it might cause very undesirable side effects.
+		 */
+		struct address_space *mapping;
+		mapping = rcu_dereference_raw(page->mapping);
+		if (mapping)
+			return mapping_balloon(mapping);
+	}
+	return false;
+}
+
+/*
+ * __page_balloon_device - return the balloon device owing the page.
+ *
+ * This shall only be used at driver callbacks under proper page lock,
+ * to get access to the balloon device structure that owns @page.
+ */
+static inline void *__page_balloon_device(struct page *page)
+{
+	struct address_space *mapping;
+	mapping = rcu_dereference_protected(page->mapping, PageLocked(page));
+	if (mapping)
+		mapping = mapping->assoc_mapping;
+	return (void *)mapping;
+}
+
+/*
+ * DEFINE_BALLOON_MAPPING_AOPS - declare and instantiate a callback descriptor
+ *				 to be used as balloon page->mapping->a_ops.
+ *
+ * @label     : declaration identifier (var name)
+ * @isolatepg : callback symbol name for performing the page isolation step
+ * @migratepg : callback symbol name for performing the page migration step
+ * @putbackpg : callback symbol name for performing the page putback step
+ *
+ * address_space_operations utilized methods for ballooned pages:
+ *   .migratepage    - used to perform balloon's page migration (as is)
+ *   .invalidatepage - used to isolate a page from balloon's page list
+ *   .freepage       - used to reinsert an isolated page to balloon's page list
+ */
+#define DEFINE_BALLOON_MAPPING_AOPS(label, isolatepg, migratepg, putbackpg) \
+	const struct address_space_operations (label) = {		    \
+		.migratepage    = (migratepg),				    \
+		.invalidatepage = (isolatepg),				    \
+		.freepage       = (putbackpg),				    \
+	}
+
+#else
+#define count_balloon_event(e)	do { } while (0)
+static inline bool movable_balloon_page(struct page *page) { return false; }
+static inline bool isolate_balloon_page(struct page *page) { return false; }
+static inline void putback_balloon_page(struct page *page) { return; }
+
+static inline int migrate_balloon_page(struct page *newpage,
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
+#define DEFINE_BALLOON_MAPPING_AOPS(label, migratepg, isolatepg, putbackpg) \
+	const struct address_space_operations *(label) = NULL
+
+#endif /* CONFIG_BALLOON_COMPACTION */
+
+/* return code to identify when a ballooned page has been migrated */
+#define BALLOON_MIGRATION_RETURN	0xba1100
+
+extern struct address_space *alloc_balloon_mapping(void *balloon_device,
+				const struct address_space_operations *a_ops);
+
+static inline void assign_balloon_mapping(struct page *page,
+					  struct address_space *mapping)
+{
+	rcu_assign_pointer(page->mapping, mapping);
+}
+
+static inline void clear_balloon_mapping(struct page *page)
+{
+	rcu_assign_pointer(page->mapping, NULL);
+}
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_BALLOON_COMPACTION_H */
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e42c762..6df0664 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -24,6 +24,7 @@ enum mapping_flags {
 	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
+	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -53,6 +54,23 @@ static inline int mapping_unevictable(struct address_space *mapping)
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
+	if (mapping)
+		return test_bit(AS_BALLOON_MAP, &mapping->flags);
+	return !!mapping;
+}
+
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
 	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
diff --git a/mm/Kconfig b/mm/Kconfig
index d5c8019..0bd783b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -188,6 +188,21 @@ config SPLIT_PTLOCK_CPUS
 	default "4"
 
 #
+# support for memory balloon compaction
+config BALLOON_COMPACTION
+	bool "Allow for balloon memory compaction/migration"
+	select COMPACTION
+	depends on VIRTIO_BALLOON
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
index 92753e2..78d8caa 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -16,7 +16,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
-			   compaction.o $(mmu-y)
+			   compaction.o balloon_compaction.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
new file mode 100644
index 0000000..86a3692
--- /dev/null
+++ b/mm/balloon_compaction.c
@@ -0,0 +1,172 @@
+/*
+ * mm/balloon_compaction.c
+ *
+ * Common interface for making balloon pages movable to compaction.
+ *
+ * Copyright (C) 2012, Red Hat, Inc.  Rafael Aquini <aquini@redhat.com>
+ */
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/export.h>
+#include <linux/balloon_compaction.h>
+
+/*
+ * alloc_balloon_mapping - allocates a special ->mapping for ballooned pages.
+ * @balloon_device: pointer address that references the balloon device which
+ *                 owns pages bearing this ->mapping.
+ * @a_ops: balloon_mapping address_space_operations descriptor.
+ *
+ * Users must call it to properly allocate and initialize an instance of
+ * struct address_space which will be used as the special page->mapping for
+ * balloon devices enlisted page instances.
+ */
+struct address_space *alloc_balloon_mapping(void *balloon_device,
+				const struct address_space_operations *a_ops)
+{
+	struct address_space *mapping;
+
+	mapping = kmalloc(sizeof(*mapping), GFP_KERNEL);
+	if (!mapping)
+		return NULL;
+
+	/*
+	 * Give a clean 'zeroed' status to all elements of this special
+	 * balloon page->mapping struct address_space instance.
+	 */
+	address_space_init_once(mapping);
+
+	/*
+	 * Set mapping->flags appropriately, to allow balloon ->mapping
+	 * identification, as well as give a proper hint to the balloon
+	 * driver on what GFP allocation mask shall be used.
+	 */
+	mapping_set_balloon(mapping);
+	mapping_set_gfp_mask(mapping, balloon_mapping_gfp_mask());
+
+	/* balloon's page->mapping->a_ops callback descriptor */
+	mapping->a_ops = a_ops;
+
+	/*
+	 * balloon special page->mapping overloads ->assoc_mapping
+	 * to held a reference back to the balloon device wich 'owns'
+	 * a given page. This is the way we can cope with multiple
+	 * balloon devices without losing reference of several
+	 * ballooned pagesets.
+	 */
+	mapping->assoc_mapping = balloon_device;
+
+	return mapping;
+}
+EXPORT_SYMBOL_GPL(alloc_balloon_mapping);
+
+#ifdef CONFIG_BALLOON_COMPACTION
+
+static inline bool __is_movable_balloon_page(struct page *page)
+{
+	struct address_space *mapping;
+
+	mapping = rcu_dereference_protected(page->mapping, PageLocked(page));
+	if (mapping)
+		return mapping_balloon(mapping);
+
+	return false;
+}
+
+static inline void __isolate_balloon_page(struct page *page)
+{
+	page->mapping->a_ops->invalidatepage(page, 0);
+}
+
+static inline void __putback_balloon_page(struct page *page)
+{
+	page->mapping->a_ops->freepage(page);
+}
+
+static inline int __migrate_balloon_page(struct address_space *mapping,
+		struct page *newpage, struct page *page, enum migrate_mode mode)
+{
+	return page->mapping->a_ops->migratepage(mapping, newpage, page, mode);
+}
+
+/* __isolate_lru_page() counterpart for a ballooned page */
+bool isolate_balloon_page(struct page *page)
+{
+	if (likely(get_page_unless_zero(page))) {
+		/*
+		 * As balloon pages are not isolated from LRU lists, concurrent
+		 * compaction threads can race against page migration functions
+		 * move_to_new_page() & __unmap_and_move().
+		 * In order to avoid having an already isolated balloon page
+		 * being (wrongly) re-isolated while it is under migration,
+		 * lets be sure we have the page lock before proceeding with
+		 * the balloon page isolation steps.
+		 */
+		if (likely(trylock_page(page))) {
+			/*
+			 * A ballooned page, by default, has just one refcount.
+			 * Prevent concurrent compaction threads from isolating
+			 * an already isolated balloon page by refcount check.
+			 */
+			if (__is_movable_balloon_page(page) &&
+			    (page_count(page) == 2)) {
+				__isolate_balloon_page(page);
+				unlock_page(page);
+				return true;
+			} else if (unlikely(!__is_movable_balloon_page(page))) {
+				dump_page(page);
+				__WARN();
+			}
+			unlock_page(page);
+		}
+		/*
+		 * The page is either under migration, or it's isolated already
+		 * Drop the refcount taken for it.
+		 */
+		put_page(page);
+	}
+	return false;
+}
+
+/* putback_lru_page() counterpart for a ballooned page */
+void putback_balloon_page(struct page *page)
+{
+	/*
+	 * 'lock_page()' stabilizes the page and prevents races against
+	 * concurrent isolation threads attempting to re-isolate it.
+	 */
+	lock_page(page);
+
+	if (__is_movable_balloon_page(page)) {
+		__putback_balloon_page(page);
+		put_page(page);
+	} else {
+		dump_page(page);
+		__WARN();
+	}
+	unlock_page(page);
+}
+
+/* move_to_new_page() counterpart for a ballooned page */
+int migrate_balloon_page(struct page *newpage,
+			 struct page *page, enum migrate_mode mode)
+{
+	struct address_space *mapping;
+	int rc = -EAGAIN;
+
+	BUG_ON(!trylock_page(newpage));
+
+	if (WARN_ON(!__is_movable_balloon_page(page))) {
+		dump_page(page);
+		unlock_page(newpage);
+		return rc;
+	}
+
+	mapping = rcu_dereference_protected(page->mapping, PageLocked(page));
+	if (mapping)
+		rc = __migrate_balloon_page(mapping, newpage, page, mode);
+
+	unlock_page(newpage);
+	return rc;
+}
+
+#endif /* CONFIG_BALLOON_COMPACTION */
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
