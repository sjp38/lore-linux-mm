Date: Fri, 16 Feb 2007 14:37:48 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: NUMA replicated pagecache (rewrite) for 2.6.20
Message-ID: <20070216133748.GC3036@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Page-based NUMA pagecache replication.

This is a scheme for page replication replicates read-only pagecache pages
opportunistically, at pagecache lookup time (at points where we know the
page is being looked up for read only).

The page will be replicated if it resides on a different node to what the
requesting CPU is on. Also, the original page must meet some conditions:
it must be clean, uptodate, not under writeback, and not have an elevated
refcount or filesystem private data. However it is allowed to be mapped
into pagetables.

Replication is done at the pagecache level, where a replicated pagecache
(inode,offset) key will have its radix-tree entry specially tagged, and its
radix-tree page will be replaced with a descriptor. Most importantly, this
descriptor has another radix-tree which is keyed by node.

Writes into pagetables are caught by having a filemap_mkwrite function,
which collapses the replication before proceeding. After collapsing the
replication, all process page tables are unmapped, so that any processes
mapping discarded pages will refault in the correct one.

/proc/vmstat has nr_repl_pages, which is the number of _additional_ pages
replicated, beyond the first.

Status:
Completely reworked and optimised. This is actually a reasonable design
and implementation.

- Data structures and conceptual state machine remain basically identical,
  however implementation is changed so much that I don't think it will be
  worth posting the incremental diff.

- Fastpath (ie. look up a page, without replicating or collapsing it)
  performance is basically unchanged now.
- Slowpath (replicating, unreplicating) still has some small locking
  inefficiencies (eg. we could use a rwlock downgrade). However I don't
  want to get fancy there, because with the lockless pagecache it should
  naturally become ideal.
- This is achieved by using a bit in the radix-tree entry pointer to
  tell us whether a given offset is a page or a pcache_desc. One good
  point about this is that it can give us completely lockless lookups
  for both replicated and unreplicated case with lockless pagecache.
- Also, gang lookup functions no longer perform a wild sweep looking
  for replicated pages to collapse, but precisely collapse those that
  are needed.
- Proper error handling implemented. We never get into a situation where
  setting up a replication could result in a failure where we're unable
  to restore the unreplicated state.
- Use __GFP_THISNODE | __GFP_NORETRY to allocate slave pages (thanks Lee)
- Made CONFIG_urable.
- Moved into its own file, with 6 hooks used by the core mm. Still not quite
  as nice as I would like (eg. get_unreplicated_page & variants), but it's
  getting closer. It might be cleaner to simply completely reimplement those
  few changed lookup functions if CONFIG_REPLICATION.
- Locking is generally much nicer, but again not perfect.
- Some commenting.
- Fixes several races (thanks Lee).
- No longer uses ->page_mkwrite, but hooks into mm/memory.c. This means
  all filesystems should now work.
- Unconditionally wrprotects ptes when cleaning a file page, and the page
  fault unreplicating hook locks then dirties the page, which should actually
  be a real attempt at getting the locking right this time. I still need to
  think more about this.

Todo:
- A PG_replicated bit will optimise reclaim and remove the last requirement
  for PAGECACHE_TAG_REPLICATED and radix_tree_tag_get! I didn't think this
  could be done so optimally without any changes to the radix tree! Sweet.
  This is implemented and will be included in the next version (I want to give
  it further testing).
- Again, no NUMA testing. However my per-CPU test patch is much closer to the
  NUMA code this time, so it's more likely to work.
- Would like to be able to control replication via userspace, and maybe
  even internally to the kernel.
- Ideally, reclaim might reclaim replicated pages preferentially, however
  I aim to be _minimally_ intrusive, and this conflicts with that.
- Would like to replicate PagePrivate, but filesystem may dirty page via
  buffers. Could replicate regular file pagecache, I think.
- Would be nice to promote a slave to master when reclaiming the master. This
  This should be quite easy: must transfer relevant flags, and only promote if
  !PagePrivate (which reclaim itself takes care of).
- More correctness testing.
- Eventually, have to look at playing nicely with migration.

 include/linux/fs.h         |    1 
 include/linux/mm.h         |    6 
 include/linux/mm_types.h   |    8 
 include/linux/mmzone.h     |    1 
 include/linux/radix-tree.h |    4 
 init/main.c                |    1 
 lib/radix-tree.c           |    2 
 mm/Kconfig                 |   11 +
 mm/Makefile                |    1 
 mm/filemap.c               |  132 ++++++-------
 mm/internal.h              |   59 ++++++
 mm/replication.c           |  435 +++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |    8 
 mm/vmstat.c                |    1 
 14 files changed, 594 insertions(+), 76 deletions(-)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -5,6 +5,8 @@
 #include <linux/threads.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
+#include <linux/radix-tree.h>
+#include <linux/nodemask.h>
 
 struct address_space;
 
@@ -64,4 +66,10 @@ struct page {
 #endif /* WANT_PAGE_VIRTUAL */
 };
 
+struct pcache_desc {
+	struct page *master;
+	nodemask_t nodes_present;
+	struct radix_tree_root page_tree;
+};
+
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -490,6 +490,7 @@ struct block_device {
  */
 #define PAGECACHE_TAG_DIRTY	0
 #define PAGECACHE_TAG_WRITEBACK	1
+#define PAGECACHE_TAG_REPLICATED 2
 
 int mapping_tagged(struct address_space *mapping, int tag);
 
Index: linux-2.6/include/linux/radix-tree.h
===================================================================
--- linux-2.6.orig/include/linux/radix-tree.h
+++ linux-2.6/include/linux/radix-tree.h
@@ -52,7 +52,11 @@ static inline int radix_tree_is_direct_p
 
 /*** radix-tree API starts here ***/
 
+#ifdef CONFIG_REPLICATION
+#define RADIX_TREE_MAX_TAGS 3
+#else
 #define RADIX_TREE_MAX_TAGS 2
+#endif
 
 /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
 struct radix_tree_root {
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -592,16 +592,13 @@ void fastcall __lock_page_nosync(struct 
  * Is there a pagecache struct page at the given (mapping, offset) tuple?
  * If yes, increment its refcount and return it; if no, return NULL.
  */
-struct page * find_get_page(struct address_space *mapping, unsigned long offset)
+struct page *find_get_page(struct address_space *mapping, unsigned long offset)
 {
 	struct page *page;
 
 	read_lock_irq(&mapping->tree_lock);
 	page = radix_tree_lookup(&mapping->page_tree, offset);
-	if (page)
-		page_cache_get(page);
-	read_unlock_irq(&mapping->tree_lock);
-	return page;
+	return get_unreplicated_page(mapping, offset, page);
 }
 EXPORT_SYMBOL(find_get_page);
 
@@ -620,26 +617,16 @@ struct page *find_lock_page(struct addre
 {
 	struct page *page;
 
-	read_lock_irq(&mapping->tree_lock);
 repeat:
-	page = radix_tree_lookup(&mapping->page_tree, offset);
+	page = find_get_page(mapping, offset);
 	if (page) {
-		page_cache_get(page);
-		if (TestSetPageLocked(page)) {
-			read_unlock_irq(&mapping->tree_lock);
-			__lock_page(page);
-			read_lock_irq(&mapping->tree_lock);
-
-			/* Has the page been truncated while we slept? */
-			if (unlikely(page->mapping != mapping ||
-				     page->index != offset)) {
-				unlock_page(page);
-				page_cache_release(page);
-				goto repeat;
-			}
+		lock_page(page);
+		if (unlikely(page->mapping != mapping)) {
+			unlock_page(page);
+			page_cache_release(page);
+			goto repeat;
 		}
 	}
-	read_unlock_irq(&mapping->tree_lock);
 	return page;
 }
 EXPORT_SYMBOL(find_lock_page);
@@ -707,15 +694,12 @@ EXPORT_SYMBOL(find_or_create_page);
 unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 			    unsigned int nr_pages, struct page **pages)
 {
-	unsigned int i;
 	unsigned int ret;
 
 	read_lock_irq(&mapping->tree_lock);
 	ret = radix_tree_gang_lookup(&mapping->page_tree,
 				(void **)pages, start, nr_pages);
-	for (i = 0; i < ret; i++)
-		page_cache_get(pages[i]);
-	read_unlock_irq(&mapping->tree_lock);
+	get_unreplicated_pages(mapping, pages, ret);
 	return ret;
 }
 
@@ -743,11 +727,9 @@ unsigned find_get_pages_contig(struct ad
 	for (i = 0; i < ret; i++) {
 		if (pages[i]->mapping == NULL || pages[i]->index != index)
 			break;
-
-		page_cache_get(pages[i]);
-		index++;
 	}
-	read_unlock_irq(&mapping->tree_lock);
+
+	get_unreplicated_pages(mapping, pages, i);
 	return i;
 }
 
@@ -765,17 +747,18 @@ unsigned find_get_pages_contig(struct ad
 unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 			int tag, unsigned int nr_pages, struct page **pages)
 {
-	unsigned int i;
 	unsigned int ret;
 
 	read_lock_irq(&mapping->tree_lock);
+	/*
+	 * Don't need to check for replicated pages, because dirty
+	 * and writeback pages should never be replicated.
+	 */
 	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
 				(void **)pages, *index, nr_pages, tag);
-	for (i = 0; i < ret; i++)
-		page_cache_get(pages[i]);
 	if (ret)
 		*index = pages[ret - 1]->index + 1;
-	read_unlock_irq(&mapping->tree_lock);
+	get_unreplicated_pages(mapping, pages, ret);
 	return ret;
 }
 
@@ -907,7 +890,7 @@ void do_generic_mapping_read(struct addr
 					index, last_index - index);
 
 find_page:
-		page = find_get_page(mapping, index);
+		page = find_get_page_readonly(mapping, index);
 		if (unlikely(page == NULL)) {
 			handle_ra_miss(mapping, &ra, index);
 			goto no_cached_page;
@@ -1007,24 +990,22 @@ readpage:
 		 * part of the page is not copied back to userspace (unless
 		 * another truncate extends the file - this is desired though).
 		 */
+		page_cache_release(page);
+
 		isize = i_size_read(inode);
 		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
-		if (unlikely(!isize || index > end_index)) {
-			page_cache_release(page);
+		if (unlikely(!isize || index > end_index))
 			goto out;
-		}
 
 		/* nr is the maximum number of bytes to copy from this page */
 		nr = PAGE_CACHE_SIZE;
 		if (index == end_index) {
 			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
-			if (nr <= offset) {
-				page_cache_release(page);
+			if (nr <= offset)
 				goto out;
-			}
 		}
 		nr = nr - offset;
-		goto page_ok;
+		goto find_page;
 
 readpage_error:
 		/* UHHUH! A synchronous read error occurred. Report it */
@@ -1351,7 +1332,7 @@ retry_all:
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_get_page(mapping, pgoff);
+	page = find_get_page_readonly(mapping, pgoff);
 	if (!page) {
 		unsigned long ra_pages;
 
@@ -1400,7 +1381,6 @@ retry_find:
 	if (!PageUptodate(page))
 		goto page_not_uptodate;
 
-success:
 	/*
 	 * Found the page and have a reference on it.
 	 */
@@ -1446,30 +1426,6 @@ page_not_uptodate:
 		majmin = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
 	}
-	lock_page(page);
-
-	/* Did it get unhashed while we waited for it? */
-	if (!page->mapping) {
-		unlock_page(page);
-		page_cache_release(page);
-		goto retry_all;
-	}
-
-	/* Did somebody else get it up-to-date? */
-	if (PageUptodate(page)) {
-		unlock_page(page);
-		goto success;
-	}
-
-	error = mapping->a_ops->readpage(file, page);
-	if (!error) {
-		wait_on_page_locked(page);
-		if (PageUptodate(page))
-			goto success;
-	} else if (error == AOP_TRUNCATED_PAGE) {
-		page_cache_release(page);
-		goto retry_find;
-	}
 
 	/*
 	 * Umm, take care of errors if the page isn't up-to-date.
@@ -1479,24 +1435,27 @@ page_not_uptodate:
 	 */
 	lock_page(page);
 
-	/* Somebody truncated the page on us? */
+	/* Did it get unhashed while we waited for it? */
 	if (!page->mapping) {
 		unlock_page(page);
 		page_cache_release(page);
 		goto retry_all;
 	}
 
-	/* Somebody else successfully read it in? */
+	/* Did somebody else get it up-to-date? */
 	if (PageUptodate(page)) {
 		unlock_page(page);
-		goto success;
+		page_cache_release(page);
+		goto retry_all;
 	}
-	ClearPageError(page);
+
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
-			goto success;
+		if (PageUptodate(page)) {
+			page_cache_release(page);
+			goto retry_find;
+		}
 	} else if (error == AOP_TRUNCATED_PAGE) {
 		page_cache_release(page);
 		goto retry_find;
Index: linux-2.6/mm/internal.h
===================================================================
--- linux-2.6.orig/mm/internal.h
+++ linux-2.6/mm/internal.h
@@ -12,6 +12,7 @@
 #define __MM_INTERNAL_H
 
 #include <linux/mm.h>
+#include <linux/pagemap.h>
 
 static inline void set_page_count(struct page *page, int v)
 {
@@ -37,4 +38,69 @@ static inline void __put_page(struct pag
 extern void fastcall __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
+#ifdef CONFIG_REPLICATION
+/*
+ * Pagecache replication
+ */
+static inline int pcache_replicated(struct address_space *mapping, unsigned long offset)
+{
+	return radix_tree_tag_get(&mapping->page_tree, offset,
+					PAGECACHE_TAG_REPLICATED);
+}
+
+extern int reclaim_replicated_page(struct address_space *mapping,
+		struct page *page);
+extern struct page *get_unreplicated_page(struct address_space *mapping,
+				unsigned long offset, struct page *page);
+extern void get_unreplicated_pages(struct address_space *mapping,
+				struct page **pages, int nr);
+extern struct page *find_get_page_readonly(struct address_space *mapping,
+						unsigned long offset);
+struct page *get_unreplicated_page_fault(struct page *page);
+#else
+
+static inline int pcache_replicated(struct address_space *mapping, unsigned long offset)
+{
+	return 0;
+}
+
+static inline int reclaim_replicated_page(struct address_space *mapping,
+		struct page *page)
+{
+	BUG();
+	return 0;
+}
+
+static inline struct page *get_unreplicated_page(struct address_space *mapping,
+				unsigned long offset, struct page *page)
+{
+	if (page)
+		page_cache_get(page);
+	read_unlock_irq(&mapping->tree_lock);
+	return page;
+}
+
+static inline void get_unreplicated_pages(struct address_space *mapping,
+				struct page **pages, int nr)
+{
+	int i;
+	for (i = 0; i < nr; i++)
+		page_cache_get(pages[i]);
+	read_unlock_irq(&mapping->tree_lock);
+}
+
+static inline struct page *find_get_page_readonly(struct address_space *mapping,
+						unsigned long offset)
+{
+	return find_get_page(mapping, offset);
+}
+
+static inline struct page *get_unreplicated_page_fault(struct page *page)
+{
+	return page;
+}
+
+#endif
+
+
 #endif
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -390,6 +390,7 @@ int remove_mapping(struct address_space 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
+again:
 	write_lock_irq(&mapping->tree_lock);
 	/*
 	 * The non racy check for a busy page.
@@ -431,7 +432,12 @@ int remove_mapping(struct address_space 
 		return 1;
 	}
 
-	__remove_from_page_cache(page);
+	/* XXX: could optimise with a page bit */
+	if (pcache_replicated(mapping, page->index)) {
+		if (reclaim_replicated_page(mapping, page))
+			goto again;
+	} else
+		__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);
 	__put_page(page);
 	return 1;
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -1005,6 +1005,12 @@ extern void show_mem(void);
 extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
 
+#ifdef CONFIG_REPLICATION
+extern void replication_init(void);
+#else
+static inline void replication_init(void) {}
+#endif
+
 #ifdef CONFIG_NUMA
 extern void setup_per_cpu_pageset(void);
 #else
Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c
+++ linux-2.6/init/main.c
@@ -583,6 +583,7 @@ asmlinkage void __init start_kernel(void
 	kmem_cache_init();
 	setup_per_cpu_pageset();
 	numa_policy_init();
+	replication_init();
 	if (late_time_init)
 		late_time_init();
 	calibrate_delay();
Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h
+++ linux-2.6/include/linux/mmzone.h
@@ -51,6 +51,9 @@ enum zone_stat_item {
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
+#ifdef CONFIG_REPLICATION
+	NR_REPL_PAGES,
+#endif
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,	/* used for pagetables */
Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c
+++ linux-2.6/mm/vmstat.c
@@ -457,6 +457,9 @@ static const char * const vmstat_text[] 
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
+#ifdef CONFIG_REPL
+	"nr_repl_pages",
+#endif
 	"nr_slab_reclaimable",
 	"nr_slab_unreclaimable",
 	"nr_page_table_pages",
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -534,7 +534,6 @@ out:
 }
 EXPORT_SYMBOL(radix_tree_tag_clear);
 
-#ifndef __KERNEL__	/* Only the test harness uses this at present */
 /**
  * radix_tree_tag_get - get a tag on a radix tree node
  * @root:		radix tree root
@@ -596,7 +595,6 @@ int radix_tree_tag_get(struct radix_tree
 	}
 }
 EXPORT_SYMBOL(radix_tree_tag_get);
-#endif
 
 static unsigned int
 __lookup(struct radix_tree_node *slot, void **results, unsigned long index,
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig
+++ linux-2.6/mm/Kconfig
@@ -152,6 +152,17 @@ config MIGRATION
 	  example on NUMA systems to put pages nearer to the processors accessing
 	  the page.
 
+#
+# support for NUMA pagecache replication
+#
+config REPLICATION
+	bool "Pagecache replication"
+	def_bool n
+	depends on NUMA
+	help
+	  Enables NUMA pagecache page replication
+
+
 config RESOURCES_64BIT
 	bool "64 bit Memory and IO resources (EXPERIMENTAL)" if (!64BIT && EXPERIMENTAL)
 	default 64BIT
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile
+++ linux-2.6/mm/Makefile
@@ -29,3 +29,4 @@ obj-$(CONFIG_MEMORY_HOTPLUG) += memory_h
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
+obj-$(CONFIG_REPLICATION) += replication.o
Index: linux-2.6/mm/replication.c
===================================================================
--- /dev/null
+++ linux-2.6/mm/replication.c
@@ -0,0 +1,472 @@
+/*
+ *	linux/mm/replication.c
+ *
+ * NUMA pagecache replication
+ *
+ * Copyright (C) 2007  Nick Piggin, SuSE Labs
+ */
+#include <linux/init.h>
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/swap.h>
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+#include <linux/page-flags.h>
+#include <linux/pagevec.h>
+#include <linux/gfp.h>
+#include <linux/slab.h>
+#include <linux/radix-tree.h>
+#include <linux/spinlock.h>
+
+#include "internal.h"
+
+
+static struct kmem_cache *pcache_desc_cachep;
+
+void __init replication_init(void)
+{
+	pcache_desc_cachep = kmem_cache_create("pcache_desc",
+					sizeof(struct pcache_desc),
+					0, SLAB_PANIC, NULL, NULL);
+}
+
+static struct pcache_desc *alloc_pcache_desc(void)
+{
+	struct pcache_desc *ret;
+
+	/* NOIO because find_get_page_readonly may be called in the IO path */
+	ret = kmem_cache_alloc(pcache_desc_cachep, GFP_NOIO);
+	if (ret) {
+		memset(ret, 0, sizeof(struct pcache_desc));
+		INIT_RADIX_TREE(&ret->page_tree, GFP_NOIO);
+	}
+	return ret;
+}
+
+static void free_pcache_desc(struct pcache_desc *pcd)
+{
+	kmem_cache_free(pcache_desc_cachep, pcd);
+}
+
+static void release_pcache_desc(struct pcache_desc *pcd)
+{
+	int i;
+
+	page_cache_get(pcd->master);
+	for_each_node_mask(i, pcd->nodes_present) {
+		struct page *page;
+
+		page = radix_tree_delete(&pcd->page_tree, i);
+		BUG_ON(!page);
+		if (page != pcd->master) {
+			BUG_ON(PageDirty(page));
+			BUG_ON(!PageUptodate(page));
+			dec_zone_page_state(page, NR_REPL_PAGES);
+		}
+		page_cache_release(page);
+	}
+	free_pcache_desc(pcd);
+}
+
+#define PCACHE_DESC_BIT	2 /* 1 is used internally by the radix-tree */
+
+static inline int is_pcache_desc(void *ptr)
+{
+	if ((unsigned long)ptr & PCACHE_DESC_BIT)
+		return 1;
+	return 0;
+}
+
+static inline struct pcache_desc *ptr_to_pcache_desc(void *ptr)
+{
+	BUG_ON(!is_pcache_desc(ptr));
+	return (struct pcache_desc *)((unsigned long)ptr & ~PCACHE_DESC_BIT);
+}
+
+static inline void *pcache_desc_to_ptr(struct pcache_desc *pcd)
+{
+	BUG_ON(is_pcache_desc(pcd));
+	return (void *)((unsigned long)pcd | PCACHE_DESC_BIT);
+}
+
+/*
+ * Must be called with the page locked and tree_lock held to give a non-racy
+ * answer.
+ */
+static int should_replicate_pcache(struct page *page, struct address_space *mapping, unsigned long offset, int nid)
+{
+	if (unlikely(PageSwapCache(page)))
+		return 0;
+
+	if (nid == page_to_nid(page))
+		return 0;
+
+	if (page_count(page) != 2 + page_mapcount(page))
+		return 0;
+	smp_rmb();
+	if (!PageUptodate(page) || PageDirty(page) ||
+			PageWriteback(page) || PagePrivate(page))
+		return 0;
+
+	return 1;
+}
+
+/*
+ * Try to convert pagecache coordinate (mapping, offset) (with page residing)
+ * into a replicated pagecache.
+ *
+ * Returns 1 if we leave with a successfully converted pagecache. Otherwise 0.
+ * (note, that return value is racy, so it is a hint only)
+ */
+static int try_to_replicate_pcache(struct page *page, struct address_space *mapping, unsigned long offset)
+{
+	int page_node;
+	void **pslot;
+	struct pcache_desc *pcd;
+	int ret = 0;
+
+	lock_page(page);
+	if (unlikely(!page->mapping))
+		goto out;
+
+	pcd = alloc_pcache_desc();
+	if (!pcd)
+		goto out;
+
+	page_node = page_to_nid(page);
+	pcd->master = page;
+	node_set(page_node, pcd->nodes_present);
+	if (radix_tree_insert(&pcd->page_tree, page_node, page))
+		goto out_pcd;
+
+	write_lock_irq(&mapping->tree_lock);
+
+	/* The non-racy check */
+	if (unlikely(!should_replicate_pcache(page, mapping, offset,
+							numa_node_id())))
+		goto out_lock;
+
+	pslot = radix_tree_lookup_slot(&mapping->page_tree, offset);
+
+	/* Already been replicated? Return yes! */
+	if (unlikely(is_pcache_desc(radix_tree_deref_slot(pslot)))) {
+		free_pcache_desc(pcd);
+		ret = 1;
+		goto out_lock;
+	}
+
+	radix_tree_replace_slot(pslot, pcache_desc_to_ptr(pcd));
+
+	radix_tree_tag_set(&mapping->page_tree, offset,
+					PAGECACHE_TAG_REPLICATED);
+	ret = 1;
+
+out_lock:
+	write_unlock_irq(&mapping->tree_lock);
+out_pcd:
+	if (ret == 0)
+		free_pcache_desc(pcd);
+out:
+	unlock_page(page);
+	return ret;
+}
+
+/*
+ * Called with tree_lock held for write, and (mapping, offset) guaranteed to be
+ * replicated. Drops tree_lock.
+ */
+static void __unreplicate_pcache(struct address_space *mapping, unsigned long offset)
+{
+	void **pslot;
+	struct pcache_desc *pcd;
+	struct page *page;
+
+	pslot = radix_tree_lookup_slot(&mapping->page_tree, offset);
+
+	/* Gone? Success */
+	if (unlikely(!pslot)) {
+		write_unlock_irq(&mapping->tree_lock);
+		return;
+	}
+
+	/* Already been un-replicated? Success */
+	if (unlikely(!is_pcache_desc(radix_tree_deref_slot(pslot)))) {
+		write_unlock_irq(&mapping->tree_lock);
+		return;
+	}
+
+	pcd = ptr_to_pcache_desc(radix_tree_deref_slot(pslot));
+
+	page = pcd->master;
+	BUG_ON(PageDirty(page));
+	BUG_ON(!PageUptodate(page));
+
+	radix_tree_replace_slot(pslot, page);
+	radix_tree_tag_clear(&mapping->page_tree, offset,
+					PAGECACHE_TAG_REPLICATED);
+
+	write_unlock_irq(&mapping->tree_lock);
+
+	unmap_mapping_range(mapping, (loff_t)offset<<PAGE_CACHE_SHIFT,
+					PAGE_CACHE_SIZE, 0);
+	release_pcache_desc(pcd);
+}
+
+/*
+ * Collapse pagecache coordinate (mapping, offset) into a non-replicated
+ * state. Must not fail.
+ */
+static void unreplicate_pcache(struct address_space *mapping, unsigned long offset)
+{
+	write_lock_irq(&mapping->tree_lock);
+	__unreplicate_pcache(mapping, offset);
+}
+
+/*
+ * Insert a newly replicated page into (mapping, offset) at node nid.
+ * Called without tree_lock. May not be successful.
+ */
+static void insert_replicated_page(struct page *page, struct address_space *mapping, unsigned long offset, int nid)
+{
+	void **pslot;
+	struct pcache_desc *pcd;
+
+	write_lock_irq(&mapping->tree_lock);
+	pslot = radix_tree_lookup_slot(&mapping->page_tree, offset);
+
+	/* Truncated? */
+	if (unlikely(!pslot))
+		goto failed;
+
+	/* Not replicated? */
+	if (unlikely(!is_pcache_desc(radix_tree_deref_slot(pslot))))
+		goto failed;
+
+	pcd = ptr_to_pcache_desc(radix_tree_deref_slot(pslot));
+
+	if (unlikely(node_isset(nid, pcd->nodes_present)))
+		goto failed;
+
+	if (radix_tree_insert(&pcd->page_tree, nid, page))
+		goto failed;
+
+	page_cache_get(page); /* pagecache ref */
+	node_set(nid, pcd->nodes_present);
+	__inc_zone_page_state(page, NR_REPL_PAGES);
+	write_unlock_irq(&mapping->tree_lock);
+
+	lru_cache_add(page);
+
+	return;
+
+failed:
+	write_unlock_irq(&mapping->tree_lock);
+}
+
+/*
+ * Removes a replicated (not master) page. Called with tree_lock held for write
+ */
+static void __remove_replicated_page(struct pcache_desc *pcd, struct page *page,
+			struct address_space *mapping, unsigned long offset)
+{
+	int nid = page_to_nid(page);
+	BUG_ON(page == pcd->master);
+	/* XXX: page->mapping = NULL; ? */
+	BUG_ON(!node_isset(nid, pcd->nodes_present));
+	BUG_ON(radix_tree_delete(&pcd->page_tree, nid) != page);
+	node_clear(nid, pcd->nodes_present);
+	__dec_zone_page_state(page, NR_REPL_PAGES);
+}
+
+/*
+ * Reclaim a replicated page. Called with tree_lock held for write.
+ * Drops tree_lock and returns 1 and the caller should retry. Otherwise
+ * retains the tree_lock and returns 0 if successful.
+ */
+int reclaim_replicated_page(struct address_space *mapping, struct page *page)
+{
+	struct pcache_desc *pcd;
+	pcd = radix_tree_lookup(&mapping->page_tree, page->index);
+	if (page == pcd->master) {
+		__unreplicate_pcache(mapping, page->index);
+		return 1;
+	} else {
+		__remove_replicated_page(pcd, page, mapping, page->index);
+		return 0;
+	}
+}
+
+/*
+ * Try to create a replica of page at the given nid.
+ * Called without any locks held. page has its refcount elevated.
+ * Returns either a newly replicated page with an elevated refcount,
+ * (in which case the old page refcount is dropped), or the old page
+ * with its refcount still elevated. This way we are guaranteed to get
+ * back SOME valid page.
+ */
+static struct page *try_to_create_replica(struct address_space *mapping,
+			unsigned long offset, struct page *page, int nid)
+{
+	struct page *repl_page;
+
+	repl_page = alloc_pages_node(nid, mapping_gfp_mask(mapping) |
+					  __GFP_THISNODE | __GFP_NORETRY, 0);
+	if (!repl_page)
+		return page; /* failed alloc, just return the master */
+
+	copy_highpage(repl_page, page);
+	flush_dcache_page(repl_page);
+	page->mapping = mapping;
+	page->index = offset;
+	SetPageUptodate(repl_page); /* XXX: can use nonatomic */
+
+	page_cache_release(page);
+	insert_replicated_page(repl_page, mapping, offset, nid);
+
+	/* doesn't matter if we didn't insert repl_page, it is still uptodate */
+	return repl_page;
+}
+
+/**
+ * find_get_page - find and get a page reference
+ * @mapping: the address_space to search
+ * @offset: the page index
+ *
+ * Is there a pagecache struct page at the given (mapping, offset) tuple?
+ * If yes, increment its refcount and return it; if no, return NULL.
+ */
+struct page *find_get_page_readonly(struct address_space *mapping,
+						unsigned long offset)
+{
+	int nid;
+	struct page *page;
+
+retry:
+	read_lock_irq(&mapping->tree_lock);
+	nid = numa_node_id();
+	page = radix_tree_lookup(&mapping->page_tree, offset);
+	if (is_pcache_desc(page)) {
+		struct pcache_desc *pcd;
+		pcd = ptr_to_pcache_desc(page);
+		if (!node_isset(nid, pcd->nodes_present)) {
+			page = pcd->master;
+			page_cache_get(page);
+			read_unlock_irq(&mapping->tree_lock);
+
+			page = try_to_create_replica(mapping, offset, page, nid);
+		} else {
+			page = radix_tree_lookup(&pcd->page_tree, nid);
+			page_cache_get(page);
+			read_unlock_irq(&mapping->tree_lock);
+		}
+		BUG_ON(!page);
+		return page;
+
+	} else if (page) {
+		page_cache_get(page);
+
+		if (should_replicate_pcache(page, mapping, offset, nid)) {
+			read_unlock_irq(&mapping->tree_lock);
+			if (try_to_replicate_pcache(page, mapping, offset)) {
+				page_cache_release(page);
+				goto retry;
+			}
+			return page;
+		}
+	}
+	read_unlock_irq(&mapping->tree_lock);
+	return page;
+}
+
+/*
+ * Takes a page at the given (mapping, offset), and returns an unreplicated
+ * page with elevated refcount.
+ *
+ * Called with tree_lock held for read, drops tree_lock.
+ */
+struct page *get_unreplicated_page(struct address_space *mapping,
+				unsigned long offset, struct page *page)
+{
+	if (page) {
+		if (is_pcache_desc(page)) {
+			struct pcache_desc *pcd;
+			pcd = ptr_to_pcache_desc(page);
+			page = pcd->master;
+			page_cache_get(page);
+			read_unlock_irq(&mapping->tree_lock);
+			unreplicate_pcache(mapping, offset);
+
+			return page;
+		}
+
+		page_cache_get(page);
+	}
+	read_unlock_irq(&mapping->tree_lock);
+	return page;
+}
+
+void get_unreplicated_pages(struct address_space *mapping, struct page **pages,
+					int nr)
+{
+	unsigned long offsets[PAGEVEC_SIZE];
+	int i, replicas;
+
+	/*
+	 * XXX: really need to prevent this at the find_get_pages API
+	 */
+	BUG_ON(nr > PAGEVEC_SIZE);
+
+	replicas = 0;
+	for (i = 0; i < nr; i++) {
+		struct page *page = pages[i];
+
+		if (is_pcache_desc(page)) {
+			struct pcache_desc *pcd;
+			pcd = ptr_to_pcache_desc(page);
+			page = pcd->master;
+			offsets[replicas++] = page->index;
+			pages[i] = page;
+		}
+
+		page_cache_get(page);
+	}
+	read_unlock_irq(&mapping->tree_lock);
+
+	for (i = 0; i < replicas; i++)
+		unreplicate_pcache(mapping, offsets[i]);
+}
+
+/*
+ * Collapse a possible page replication. The page is held unreplicated by
+ * the elevated refcount on the passed-in page.
+ */
+struct page *get_unreplicated_page_fault(struct page *page)
+{
+	struct address_space *mapping;
+	struct page *master;
+	pgoff_t offset;
+
+	/* could be broken vs truncate? but at least truncate will remove pte */
+	offset = page->index;
+	mapping = page->mapping;
+	if (!mapping)
+		return page;
+
+	/*
+	 * Take the page lock in order to ensure that we're synchronised
+	 * against another task doing clear_page_dirty_for_io()
+	 */
+	master = find_lock_page(mapping, offset);
+	if (master) {
+		/*
+		 * Dirty the page to prevent the replication from being
+		 * set up again.
+		 */
+		set_page_dirty(master);
+		unlock_page(master);
+		page_cache_release(page);
+	}
+
+	return master;
+}
+
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -60,6 +60,8 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 
+#include "internal.h"
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
@@ -1528,11 +1530,10 @@ static int do_wp_page(struct mm_struct *
 			page_cache_get(old_page);
 			pte_unmap_unlock(page_table, ptl);
 
+			old_page = get_unreplicated_page_fault(old_page);
 			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0)
 				goto unwritable_page;
 
-			page_cache_release(old_page);
-
 			/*
 			 * Since we dropped the lock we need to revalidate
 			 * the PTE as someone else may have changed it.  If
@@ -1541,9 +1542,11 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
+			page_cache_release(old_page);
 			if (!pte_same(*page_table, orig_pte))
 				goto unlock;
 		}
+
 		dirty_page = old_page;
 		get_page(dirty_page);
 		reuse = 1;
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -857,7 +857,12 @@ int clear_page_dirty_for_io(struct page 
 {
 	struct address_space *mapping = page_mapping(page);
 
+	BUG_ON(!PageLocked(page));
+#ifndef CONFIG_REPLICATION
 	if (mapping && mapping_cap_account_dirty(mapping)) {
+#else
+	if (mapping) {
+#endif
 		/*
 		 * Yes, Virginia, this is indeed insane.
 		 *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
