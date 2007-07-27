Date: Fri, 27 Jul 2007 10:42:52 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] 2.6.23-rc1 mm: NUMA replicated pagecache
Message-ID: <20070727084252.GA9347@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Joachim Deguara <joachim.deguara@amd.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi,

Just got a bit of time to take another look at the replicated pagecache
patch. The nopage vs invalidate race and clear_page_dirty_for_io fixes
gives me more confidence in the locking now; the new ->fault API makes
MAP_SHARED write faults much more efficient; and a few bugs were found
and fixed.

More stats were added: *repl* in /proc/vmstat. Survives some kbuilding
tests...

--

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
(inode,offset) key will have a special bit set in its radix-tree entry,
which tells us the entry points to a descriptor rather than a page.

This descriptor (struct pcache_desc) has another radix-tree which is keyed by
node. The pagecache gains an (optional) 3rd dimension!

Pagecache lookups which are not explicitly denoted as being read-only are
treaded as writes, and they collapse the replication before proceeding.
Writes into pagetables are caught by using the same mechanism as dirty page
throttling uses, and also collapse the replication.

After collapsing a replication, all process page tables are unmapped, so that
any processes mapping discarded pages will refault in the correct one.

/proc/vmstat has nr_repl_pages, which is the number of _additional_ pages
replicated, beyond the first.

Status:
- Lee showed that ~10s (1%) user time was cut off a kernel compile benchmark
  on his 4 node 16-way box.

Todo:
- find_get_page locking semantics are slightly changed. This doesn't appear
  to be a problem but I need to have a more thorough look.
- Would like to be able to control replication via userspace, and maybe
  even internally to the kernel.
- Ideally, reclaim might reclaim replicated pages preferentially, however
  I aim to be _minimally_ intrusive, and this conflicts with that.
- More correctness testing.
- Eventually, have to look at playing nicely with migration.
- radix-tree nodes start using up a large amount of memory. Try to improve.
  (eg. different data structure, smaller tree, or don't load master immediately).

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
 
@@ -80,4 +82,10 @@ struct page {
 #endif /* WANT_PAGE_VIRTUAL */
 };
 
+struct pcache_desc {
+	struct page *master;
+	nodemask_t nodes_present;
+	struct radix_tree_root page_tree;
+};
+
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -593,16 +593,13 @@ void fastcall __lock_page_nosync(struct 
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
 
@@ -621,26 +618,16 @@ struct page *find_lock_page(struct addre
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
@@ -709,15 +696,12 @@ EXPORT_SYMBOL(find_or_create_page);
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
 
@@ -745,11 +729,9 @@ unsigned find_get_pages_contig(struct ad
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
 EXPORT_SYMBOL(find_get_pages_contig);
@@ -768,17 +750,18 @@ EXPORT_SYMBOL(find_get_pages_contig);
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
 EXPORT_SYMBOL(find_get_pages_tag);
@@ -892,7 +875,7 @@ void do_generic_mapping_read(struct addr
 
 		cond_resched();
 find_page:
-		page = find_get_page(mapping, index);
+		page = find_get_page_readonly(mapping, index);
 		if (!page) {
 			page_cache_sync_readahead(mapping,
 					&ra, filp,
@@ -1021,7 +1004,8 @@ readpage:
 			unlock_page(page);
 		}
 
-		goto page_ok;
+		page_cache_release(page);
+		goto find_page;
 
 readpage_error:
 		/* UHHUH! A synchronous read error occurred. Report it */
@@ -1306,6 +1290,14 @@ static int fastcall page_cache_read(stru
 
 #define MMAP_LOTSAMISS  (100)
 
+static struct page *find_lock_page_write(struct address_space *mapping, pgoff_t index, int write)
+{
+	if (write)
+		return find_lock_page(mapping, index);
+	else
+		return find_lock_page_readonly(mapping, index);
+}
+
 /**
  * filemap_fault - read in file data for page fault handling
  * @vma:	vma in which the fault was taken
@@ -1342,7 +1334,7 @@ int filemap_fault(struct vm_area_struct 
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_lock_page(mapping, vmf->pgoff);
+	page = find_lock_page_write(mapping, vmf->pgoff, vmf->flags & FAULT_FLAG_WRITE);
 	/*
 	 * For sequential accesses, we use the generic readahead logic.
 	 */
@@ -1350,7 +1342,7 @@ retry_find:
 		if (!page) {
 			page_cache_sync_readahead(mapping, ra, file,
 							   vmf->pgoff, 1);
-			page = find_lock_page(mapping, vmf->pgoff);
+			page = find_lock_page_write(mapping, vmf->pgoff, vmf->flags & FAULT_FLAG_WRITE);
 			if (!page)
 				goto no_cached_page;
 		}
@@ -1389,7 +1381,7 @@ retry_find:
 				start = vmf->pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_lock_page(mapping, vmf->pgoff);
+		page = find_lock_page_write(mapping, vmf->pgoff, vmf->flags & FAULT_FLAG_WRITE);
 		if (!page)
 			goto no_cached_page;
 	}
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
@@ -37,4 +38,62 @@ static inline void __put_page(struct pag
 extern void fastcall __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
+#ifdef CONFIG_REPLICATION
+extern int reclaim_replicated_page(struct address_space *mapping,
+		struct page *page);
+extern struct page *get_unreplicated_page(struct address_space *mapping,
+				unsigned long offset, struct page *page);
+extern void get_unreplicated_pages(struct address_space *mapping,
+				struct page **pages, int nr);
+extern struct page *find_get_page_readonly(struct address_space *mapping,
+						unsigned long offset);
+extern struct page *find_lock_page_readonly(struct address_space *mapping,
+						unsigned long offset);
+int page_write_fault_retry(struct page *page);
+#else
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
+static inline struct page *find_lock_page_readonly(struct address_space *mapping,
+						unsigned long offset)
+{
+	return find_lock_page(mapping, offset);
+}
+
+static inline int page_write_fault_retry(struct page *page)
+{
+	return 0;
+}
+
+#endif
+
 #endif
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -368,6 +368,7 @@ int remove_mapping(struct address_space 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
+again:
 	write_lock_irq(&mapping->tree_lock);
 	/*
 	 * The non racy check for a busy page.
@@ -409,7 +410,11 @@ int remove_mapping(struct address_space 
 		return 1;
 	}
 
-	__remove_from_page_cache(page);
+	if (PageReplicated(page)) {
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
@@ -1047,6 +1047,12 @@ extern void show_mem(void);
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
@@ -615,6 +615,7 @@ asmlinkage void __init start_kernel(void
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
@@ -63,6 +63,9 @@ enum zone_stat_item {
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
+#ifdef CONFIG_REPLICATION
+	NR_REPL_PAGES,
+#endif
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
 	/* Second 128 byte cacheline */
Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c
+++ linux-2.6/mm/vmstat.c
@@ -482,6 +482,9 @@ static const char * const vmstat_text[] 
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
+#ifdef CONFIG_REPLICATION
+	"nr_repl_pages",
+#endif
 	"nr_dirty",
 	"nr_writeback",
 	"nr_slab_reclaimable",
@@ -515,6 +518,11 @@ static const char * const vmstat_text[] 
 	"pgfault",
 	"pgmajfault",
 
+#ifdef CONFIG_REPLICATION
+	"pgreplicated",
+	"pgreplicazap",
+#endif
+
 	TEXTS_FOR_ZONES("pgrefill")
 	TEXTS_FOR_ZONES("pgsteal")
 	TEXTS_FOR_ZONES("pgscan_kswapd")
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
@@ -29,4 +29,4 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-
+obj-$(CONFIG_REPLICATION) += replication.o
Index: linux-2.6/mm/replication.c
===================================================================
--- /dev/null
+++ linux-2.6/mm/replication.c
@@ -0,0 +1,609 @@
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
+static struct kmem_cache *pcache_desc_cachep __read_mostly;
+
+void __init replication_init(void)
+{
+	pcache_desc_cachep = kmem_cache_create("pcache_desc",
+			sizeof(struct pcache_desc), 0, SLAB_PANIC, NULL);
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
+		/* XXX: should use non-atomic preloads */
+		INIT_RADIX_TREE(&ret->page_tree, GFP_ATOMIC);
+	}
+	return ret;
+}
+
+static void free_pcache_desc(struct pcache_desc *pcd)
+{
+	kmem_cache_free(pcache_desc_cachep, pcd);
+}
+
+/*
+ * Free the struct pcache_desc, and all slaves. The pagecache refcount is
+ * retained for the master (because presumably we're collapsing the replication.
+ *
+ * Returns 1 if any of the slaves had a non-zero mapcount (in which case, we'll
+ * have to unmap them), otherwise returns 0.
+ */
+static int release_pcache_desc(struct pcache_desc *pcd)
+{
+	int ret = 0;
+	int i;
+
+	for_each_node_mask(i, pcd->nodes_present) {
+		struct page *page;
+
+		page = radix_tree_delete(&pcd->page_tree, i);
+		BUG_ON(!page);
+		if (page != pcd->master) {
+			BUG_ON(PageDirty(page));
+			BUG_ON(!PageUptodate(page));
+			BUG_ON(!PageReplicated(page));
+			BUG_ON(PagePrivate(page));
+			ClearPageReplicated(page);
+			count_vm_event(PGREPLICAZAP);
+			page->mapping = NULL;
+			dec_zone_page_state(page, NR_REPL_PAGES);
+
+			if (page_mapped(page))
+				ret = 1; /* tell caller to unmap the ptes */
+
+			page_cache_release(page);
+		}
+	}
+	{
+		void *ptr;
+		BUG_ON(radix_tree_gang_lookup(&pcd->page_tree, &ptr, 0, 1) != 0);
+	}
+	free_pcache_desc(pcd);
+
+	return ret;
+}
+
+#define PCACHE_DESC_BIT	2 /* 1 is used internally by the radix-tree */
+
+static inline int __is_pcache_desc(void *ptr)
+{
+	if ((unsigned long)ptr & PCACHE_DESC_BIT)
+		return 1;
+	return 0;
+}
+
+static inline int is_pcache_desc(void *ptr)
+{
+	/* debugging */
+	if ((unsigned long)ptr & PCACHE_DESC_BIT) {
+		struct pcache_desc *pcd;
+		pcd = (struct pcache_desc *)((unsigned long)ptr & ~PCACHE_DESC_BIT);
+		BUG_ON(!PageReplicated(pcd->master));
+	} else {
+		struct page *page = ptr;
+		BUG_ON(PageReplicated(page));
+	}
+	return __is_pcache_desc(ptr);
+}
+
+static inline struct pcache_desc *ptr_to_pcache_desc(void *ptr)
+{
+	BUG_ON(!__is_pcache_desc(ptr));
+	return (struct pcache_desc *)((unsigned long)ptr & ~PCACHE_DESC_BIT);
+}
+
+static inline void *pcache_desc_to_ptr(struct pcache_desc *pcd)
+{
+	BUG_ON(__is_pcache_desc(pcd));
+	return (void *)((unsigned long)pcd | PCACHE_DESC_BIT);
+}
+
+/*
+ * Must be called with the page locked and tree_lock held to give a non-racy
+ * answer.
+ */
+static int should_replicate_pcache(struct page *page, struct address_space *mapping, unsigned long offset, int nid)
+{
+	umode_t mode;
+
+	if (unlikely(PageSwapCache(page)))
+		return 0;
+
+	if (nid == page_to_nid(page))
+		return 0;
+
+	if (page_count(page) != 2 + page_mapcount(page))
+		return 0;
+	smp_rmb();
+	if (!PageUptodate(page) || PageDirty(page) || PageWriteback(page))
+		return 0;
+
+	if (!PagePrivate(page))
+		return 1;
+
+	mode = mapping->host->i_mode;
+	if (S_ISREG(mode) || S_ISBLK(mode))
+		return 1;
+
+	return 0;
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
+	/* Already been replicated? Return yes! */
+	if (PageReplicated(page)) {
+		ret = 1;
+		goto out;
+	}
+
+	pcd = alloc_pcache_desc();
+	if (!pcd)
+		goto out;
+
+	page_node = page_to_nid(page);
+	if (radix_tree_insert(&pcd->page_tree, page_node, page))
+		goto out_pcd;
+	pcd->master = page;
+	node_set(page_node, pcd->nodes_present);
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
+	/*
+	 * The page is being held in pagecache and kept unreplicated because
+	 * it is locked. The following bugchecks.
+	 */
+	BUG_ON(!pslot);
+	BUG_ON(PageReplicated(page));
+	BUG_ON(page != radix_tree_deref_slot(pslot));
+	BUG_ON(is_pcache_desc(radix_tree_deref_slot(pslot)));
+	SetPageReplicated(page);
+	radix_tree_replace_slot(pslot, pcache_desc_to_ptr(pcd));
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
+static void __unreplicate_pcache(struct address_space *mapping, unsigned long offset, void **pslot)
+{
+	struct pcache_desc *pcd;
+	struct page *page;
+
+	pcd = ptr_to_pcache_desc(radix_tree_deref_slot(pslot));
+
+	page = pcd->master;
+	BUG_ON(PageDirty(page));
+	BUG_ON(!PageUptodate(page));
+	BUG_ON(!PageReplicated(page));
+	ClearPageReplicated(page);
+
+	radix_tree_replace_slot(pslot, page);
+
+	write_unlock_irq(&mapping->tree_lock);
+
+	/*
+	 * XXX: this actually changes all the find_get_pages APIs, so
+	 * we might want to just coax unmap_mapping_range into not
+	 * sleeping instead.
+	 */
+	might_sleep();
+
+	if (release_pcache_desc(pcd)) {
+		/* release_pcache_desc saw some mapped slaves */
+		unmap_mapping_range(mapping, (loff_t)offset<<PAGE_CACHE_SHIFT,
+					PAGE_CACHE_SIZE, 0);
+	}
+}
+
+/*
+ * Collapse pagecache coordinate (mapping, offset) into a non-replicated
+ * state. Must not fail.
+ */
+static void unreplicate_pcache(struct address_space *mapping, unsigned long offset, int locked)
+{
+	void **pslot;
+
+	if (!locked)
+		write_lock_irq(&mapping->tree_lock);
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
+	__unreplicate_pcache(mapping, offset, pslot);
+}
+
+/*
+ * Insert a newly replicated page into (mapping, offset) at node nid.
+ * Called without tree_lock. May not be successful.
+ *
+ * Returns 1 on success, otherwise 0.
+ */
+static int insert_replicated_page(struct page *page, struct address_space *mapping, unsigned long offset, int nid)
+{
+	void **pslot;
+	struct pcache_desc *pcd;
+
+	BUG_ON(PageReplicated(page));
+	BUG_ON(!PageUptodate(page));
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
+	node_set(nid, pcd->nodes_present);
+	count_vm_event(PGREPLICATED);
+	SetPageReplicated(page); /* XXX: could rework to use non-atomic */
+
+	page->mapping = mapping;
+	page->index = offset;
+
+	page_cache_get(page); /* pagecache ref */
+	__inc_zone_page_state(page, NR_REPL_PAGES);
+	write_unlock_irq(&mapping->tree_lock);
+
+	lru_cache_add(page);
+
+	return 1;
+
+failed:
+	write_unlock_irq(&mapping->tree_lock);
+	return 0;
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
+	BUG_ON(!node_isset(nid, pcd->nodes_present));
+	BUG_ON(radix_tree_delete(&pcd->page_tree, nid) != page);
+	node_clear(nid, pcd->nodes_present);
+	BUG_ON(!PageReplicated(page));
+	ClearPageReplicated(page);
+	count_vm_event(PGREPLICAZAP);
+	page->mapping = NULL;
+	__dec_zone_page_state(page, NR_REPL_PAGES);
+}
+
+/*
+ * Reclaim a replicated page. Called with tree_lock held for write and the
+ * page locked.
+ * Drops tree_lock and returns 1 and the caller should retry. Otherwise
+ * retains the tree_lock and returns 0 if successful.
+ */
+int reclaim_replicated_page(struct address_space *mapping, struct page *page)
+{
+	void **pslot;
+	struct pcache_desc *pcd;
+	unsigned long offset = page->index;
+
+	BUG_ON(PagePrivate(page));
+	BUG_ON(!PageReplicated(page));
+	pslot = radix_tree_lookup_slot(&mapping->page_tree, offset);
+	pcd = ptr_to_pcache_desc(radix_tree_deref_slot(pslot));
+	if (page == pcd->master) {
+		if (nodes_weight(pcd->nodes_present) == 1) {
+			__unreplicate_pcache(mapping, offset, pslot);
+			return 1;
+		} else {
+			/* promote one of the slaves to master */
+			struct page *new_master;
+			int nid, new_nid;
+
+			nid = page_to_nid(page);
+			new_nid = next_node(nid, pcd->nodes_present);
+			if (new_nid == MAX_NUMNODES)
+				new_nid = first_node(pcd->nodes_present);
+			BUG_ON(new_nid == nid);
+			new_master = radix_tree_lookup(&pcd->page_tree, new_nid);
+			BUG_ON(!new_master);
+			BUG_ON(new_master == page);
+
+			if (PageError(page))
+				SetPageError(new_master);
+			if (PageChecked(page))
+				SetPageChecked(new_master);
+			if (PageMappedToDisk(page))
+				SetPageMappedToDisk(new_master);
+
+			pcd->master = new_master;
+			/* now fall through and remove the old master */
+		}
+	}
+	__remove_replicated_page(pcd, page, mapping, offset);
+	return 0;
+}
+
+/*
+ * Try to create a replica of page at the given nid.
+ * Called without any locks held. page has its refcount elevated.
+ * Returns the newly replicated page with an elevated refcount on
+ * success, or NULL on failure.
+ */
+static struct page *try_to_create_replica(struct address_space *mapping,
+			unsigned long offset, struct page *page, int nid)
+{
+	struct page *repl_page;
+
+	repl_page = alloc_pages_node(nid, mapping_gfp_mask(mapping) |
+					  __GFP_THISNODE | __GFP_NORETRY, 0);
+	if (!repl_page)
+		return NULL;
+
+	copy_highpage(repl_page, page);
+	flush_dcache_page(repl_page);
+	SetPageUptodate(repl_page); /* XXX: can use nonatomic */
+
+	if (!insert_replicated_page(repl_page, mapping, offset, nid)) {
+		page_cache_release(repl_page);
+		return NULL;
+	}
+
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
+	if (!page)
+		goto out;
+
+	if (is_pcache_desc(page)) {
+		struct pcache_desc *pcd;
+		pcd = ptr_to_pcache_desc(page);
+		if (!node_isset(nid, pcd->nodes_present)) {
+			int src_nid;
+			struct page *new_page;
+
+			src_nid = next_node(nid, pcd->nodes_present);
+			if (src_nid == MAX_NUMNODES)
+				src_nid = first_node(pcd->nodes_present);
+			page = radix_tree_lookup(&pcd->page_tree, src_nid);
+			BUG_ON(!page);
+			page_cache_get(page);
+			read_unlock_irq(&mapping->tree_lock);
+
+			new_page = try_to_create_replica(mapping, offset, page, nid);
+			if (new_page) {
+				page_cache_release(page);
+				page = new_page;
+			}
+		} else {
+			page = radix_tree_lookup(&pcd->page_tree, nid);
+			page_cache_get(page);
+			read_unlock_irq(&mapping->tree_lock);
+		}
+		BUG_ON(!page);
+		return page;
+
+	}
+
+	page_cache_get(page);
+
+	if (should_replicate_pcache(page, mapping, offset, nid)) {
+		read_unlock_irq(&mapping->tree_lock);
+		if (try_to_replicate_pcache(page, mapping, offset)) {
+			page_cache_release(page);
+			goto retry;
+		}
+		return page;
+	}
+
+out:
+	read_unlock_irq(&mapping->tree_lock);
+	return page;
+}
+
+struct page *find_lock_page_readonly(struct address_space *mapping,
+						unsigned long offset)
+{
+	struct page *page;
+
+again:
+	page = find_get_page_readonly(mapping, offset);
+	if (page) {
+		lock_page(page);
+		if (page->mapping)
+			return page;
+		unlock_page(page);
+		goto again;
+	}
+	return NULL;
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
+
+			pcd = ptr_to_pcache_desc(page);
+			page = pcd->master;
+			page_cache_get(page);
+			read_unlock_irq(&mapping->tree_lock);
+
+			unreplicate_pcache(mapping, offset, 0);
+
+			return page;
+		}
+
+		page_cache_get(page);
+	}
+	read_unlock_irq(&mapping->tree_lock);
+	might_sleep();
+
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
+	might_sleep();
+
+	for (i = 0; i < replicas; i++)
+		unreplicate_pcache(mapping, offsets[i], 0);
+}
+
+/*
+ * Collapse a possible page replication. The page is held unreplicated by
+ * the elevated refcount on the passed-in page.
+ */
+int page_write_fault_retry(struct page *page)
+{
+	struct address_space *mapping;
+	pgoff_t offset;
+
+	if (!PageReplicated(page)) {
+		/* The elevated page refcount will hold off replication */
+		return 0;
+	}
+
+	/* Truncate would remove pte and get noticed by caller anyway... */
+	mapping = page->mapping;
+	if (!mapping)
+		return 1;
+
+	write_lock_irq(&mapping->tree_lock);
+	if (page->mapping != mapping) {
+		write_unlock_irq(&mapping->tree_lock);
+		return 1;
+	}
+
+	offset = page->index;
+	unreplicate_pcache(mapping, offset, 1);
+
+	return 1;
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
@@ -1661,7 +1663,10 @@ static int do_wp_page(struct mm_struct *
 		 * read-only shared pages can get COWed by
 		 * get_user_pages(.write=1, .force=1).
 		 */
-		if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
+#ifndef CONFIG_REPLICATION
+		if (vma->vm_ops && vma->vm_ops->page_mkwrite)
+#endif
+		{
 			/*
 			 * Notify the address space that the page is about to
 			 * become writable so that it can prohibit this or wait
@@ -1673,6 +1678,18 @@ static int do_wp_page(struct mm_struct *
 			page_cache_get(old_page);
 			pte_unmap_unlock(page_table, ptl);
 
+			/*
+			 * XXX: this could just be run under ptl and unmap
+			 * just the single pte and let the replication collapse
+			 * get done by the next page fault.
+			 */
+			if (page_write_fault_retry(old_page)) {
+				page_cache_release(old_page);
+				return 0;
+			}
+#ifdef CONFIG_REPLICATION
+			if (vma->vm_ops && vma->vm_ops->page_mkwrite)
+#endif
 			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0)
 				goto unwritable_page;
 
@@ -1688,8 +1705,14 @@ static int do_wp_page(struct mm_struct *
 			if (!pte_same(*page_table, orig_pte))
 				goto unlock;
 		}
+
 		dirty_page = old_page;
-		get_page(dirty_page);
+		/*
+	 	 * This extra ref also holds off replication after the mapcount
+		 * is elevated, until after the page is set dirty and the ref
+		 * dropped. Similarly for __do_fault.
+		 */
+		page_cache_get(dirty_page);
 		reuse = 1;
 	}
 
@@ -1775,7 +1798,7 @@ unlock:
 		 */
 		wait_on_page_locked(dirty_page);
 		set_page_dirty_balance(dirty_page);
-		put_page(dirty_page);
+		page_cache_release(dirty_page);
 	}
 	return ret;
 oom:
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -921,7 +921,12 @@ int clear_page_dirty_for_io(struct page 
 	BUG_ON(!PageLocked(page));
 
 	ClearPageReclaim(page);
+
+#ifndef CONFIG_REPLICATION
 	if (mapping && mapping_cap_account_dirty(mapping)) {
+#else
+	if (mapping) {
+#endif
 		/*
 		 * Yes, Virginia, this is indeed insane.
 		 *
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -90,6 +90,8 @@
 #define PG_reclaim		17	/* To be reclaimed asap */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_replicated		20	/* Page is replicated pagecache */
+
 /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
 #define PG_readahead		PG_reclaim /* Reminder to do async read-ahead */
 
@@ -144,8 +146,8 @@ static inline void SetPageUptodate(struc
 #define ClearPageUptodate(page)	clear_bit(PG_uptodate, &(page)->flags)
 
 #define PageDirty(page)		test_bit(PG_dirty, &(page)->flags)
-#define SetPageDirty(page)	set_bit(PG_dirty, &(page)->flags)
-#define TestSetPageDirty(page)	test_and_set_bit(PG_dirty, &(page)->flags)
+#define SetPageDirty(page)	do { BUG_ON(PageReplicated(page)); set_bit(PG_dirty, &(page)->flags); } while (0)
+#define TestSetPageDirty(page)	({ BUG_ON(PageReplicated(page)); test_and_set_bit(PG_dirty, &(page)->flags); })
 #define ClearPageDirty(page)	clear_bit(PG_dirty, &(page)->flags)
 #define __ClearPageDirty(page)	__clear_bit(PG_dirty, &(page)->flags)
 #define TestClearPageDirty(page) test_and_clear_bit(PG_dirty, &(page)->flags)
@@ -194,15 +196,23 @@ static inline void SetPageUptodate(struc
  * risky: they bypass page accounting.
  */
 #define PageWriteback(page)	test_bit(PG_writeback, &(page)->flags)
-#define TestSetPageWriteback(page) test_and_set_bit(PG_writeback,	\
-							&(page)->flags)
-#define TestClearPageWriteback(page) test_and_clear_bit(PG_writeback,	\
-							&(page)->flags)
+#define TestSetPageWriteback(page) ({ BUG_ON(PageReplicated(page)); test_and_set_bit(PG_writeback, &(page)->flags); })
+#define TestClearPageWriteback(page) \
+		test_and_clear_bit(PG_writeback, &(page)->flags)
 
 #define PageBuddy(page)		test_bit(PG_buddy, &(page)->flags)
 #define __SetPageBuddy(page)	__set_bit(PG_buddy, &(page)->flags)
 #define __ClearPageBuddy(page)	__clear_bit(PG_buddy, &(page)->flags)
 
+#ifdef CONFIG_REPLICATION
+#define PageReplicated(page)	test_bit(PG_replicated, &(page)->flags)
+#define __SetPageReplicated(page) do { BUG_ON(PageDirty(page) || PageWriteback(page)); __set_bit(PG_replicated, &(page)->flags); } while (0)
+#define SetPageReplicated(page)	do { BUG_ON(PageDirty(page) || PageWriteback(page)); set_bit(PG_replicated, &(page)->flags); } while (0)
+#define ClearPageReplicated(page) clear_bit(PG_replicated, &(page)->flags)
+#else
+#define PageReplicated(page)	0
+#endif
+
 #define PageMappedToDisk(page)	test_bit(PG_mappedtodisk, &(page)->flags)
 #define SetPageMappedToDisk(page) set_bit(PG_mappedtodisk, &(page)->flags)
 #define ClearPageMappedToDisk(page) clear_bit(PG_mappedtodisk, &(page)->flags)
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -215,7 +215,8 @@ static void bad_page(struct page *page)
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
-			1 << PG_buddy );
+			1 << PG_buddy |
+			1 << PG_replicated );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -451,7 +452,8 @@ static inline int free_pages_check(struc
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_replicated))))
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
@@ -600,7 +602,8 @@ static int prep_new_page(struct page *pa
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_replicated ))))
 		bad_page(page);
 
 	/*
Index: linux-2.6/include/linux/vmstat.h
===================================================================
--- linux-2.6.orig/include/linux/vmstat.h
+++ linux-2.6/include/linux/vmstat.h
@@ -31,6 +31,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		FOR_ALL_ZONES(PGALLOC),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
+		PGREPLICATED, PGREPLICAZAP,
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL),
 		FOR_ALL_ZONES(PGSCAN_KSWAPD),
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -96,6 +96,17 @@ unsigned find_get_pages_contig(struct ad
 unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 			int tag, unsigned int nr_pages, struct page **pages);
 
+static inline int probe_page(struct address_space *mapping, pgoff_t pgoff)
+{
+	int ret;
+
+	rcu_read_lock();
+	ret = !!radix_tree_lookup(&mapping->page_tree, pgoff);
+	rcu_read_unlock();
+
+	return ret;
+}
+
 /*
  * Returns locked page at given index in given cache, creating it if needed.
  */
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -1221,17 +1221,13 @@ repeat:
 			goto repeat;
 		}
 	} else if (sgp == SGP_READ && !filepage) {
+		int page;
+
 		shmem_swp_unmap(entry);
-		filepage = find_get_page(mapping, idx);
-		if (filepage &&
-		    (!PageUptodate(filepage) || TestSetPageLocked(filepage))) {
-			spin_unlock(&info->lock);
-			wait_on_page_locked(filepage);
-			page_cache_release(filepage);
-			filepage = NULL;
-			goto repeat;
-		}
+		page = probe_page(mapping, idx);
 		spin_unlock(&info->lock);
+		if (page)
+			goto repeat;
 	} else {
 		shmem_swp_unmap(entry);
 		sbinfo = SHMEM_SB(inode->i_sb);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
