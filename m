Date: Thu, 14 Oct 2004 16:22:40 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] Migration cache
Message-ID: <20041014192240.GA6899@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi MM fellows,

So as I've said before in my opinion moving pages to the swapcache 
to migrate them is unnacceptable for several reasons. Not to mention 
live memory defragmentation.

So the following patch, on top of the v2.6 -memoryhotplug tree, 
creates a migration cache - which is basically a swapcache without 
using the swap map - it instead uses a on-memory idr structure.

For that we decrease SWP_TYPE_SHIFT from 5 to 4, and use that now-free
bit to indicate pte's which point to pages on the migration cache.

It still needs more testing, but it successfully migrates a zone 
while "fillmem" runs on it, on an SMP box.

Need more testing for integration into -mhp, its being done.

I think it needs to be able to transform "migration cache pages" 
(which still exist until all pte's referencing a page fault-in)
into "swapcache pages" by going through the reserve mapping and 
transforming the "migration pte's" into "swapcache pte's" (with 
allocated swap space).

As soon as we have this working and stable we can go for 
"nonblocking" version of mmigrate.c work for defragmentation.

Comments are very welcome 

Be warned, it contains debug printk's.

diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/include/linux/mm.h linux-2.6.9-rc2-mm4.build/include/linux/mm.h
--- linux-2.6.9-rc2-mm4.mhp.orig/include/linux/mm.h	2004-10-14 17:22:28.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/include/linux/mm.h	2004-10-14 17:44:00.402867808 -0300
@@ -458,12 +458,15 @@
 #define PAGE_MAPPING_ANON	1
 
 extern struct address_space swapper_space;
+extern struct address_space migration_space;
 static inline struct address_space *page_mapping(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
 
 	if (unlikely(PageSwapCache(page)))
 		mapping = &swapper_space;
+	else if (unlikely(PageMigration(page)))
+		mapping = &migration_space;
 	else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
 		mapping = NULL;
 	return mapping;
@@ -480,7 +483,7 @@
  */
 static inline pgoff_t page_index(struct page *page)
 {
-	if (unlikely(PageSwapCache(page)))
+	if (unlikely(PageSwapCache(page)) || unlikely(PageMigration(page)))
 		return page->private;
 	return page->index;
 }
diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/include/linux/page-flags.h linux-2.6.9-rc2-mm4.build/include/linux/page-flags.h
--- linux-2.6.9-rc2-mm4.mhp.orig/include/linux/page-flags.h	2004-10-14 17:22:26.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/include/linux/page-flags.h	2004-10-14 17:44:00.043922376 -0300
@@ -83,6 +83,7 @@
  * -- daveh
  */
 #define PG_capture		19	/* Remove page for memory hotplug */
+#define PG_migration		20	/* Remove page for memory hotplug */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -339,6 +340,10 @@
 #define SetPageUnderCapture(page)	set_bit(PG_capture, &(page)->flags)
 #define ClearPageUnderCapture(page)	clear_bit(PG_capture, &(page)->flags)
 
+#define PageMigration(page)	test_bit(PG_migration, &(page)->flags)
+#define SetPageMigration(page)	set_bit(PG_migration, &(page)->flags)
+#define ClearPageMigration(page)	clear_bit(PG_migration, &(page)->flags)
+
 static inline void set_page_under_capture(struct page *page)
 {
 	SetPageUnderCapture(page);
diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/include/linux/swap.h linux-2.6.9-rc2-mm4.build/include/linux/swap.h
--- linux-2.6.9-rc2-mm4.mhp.orig/include/linux/swap.h	2004-10-14 17:22:28.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/include/linux/swap.h	2004-10-14 17:44:00.449860664 -0300
@@ -27,7 +27,7 @@
  * on 32-bit-pgoff_t architectures.  And that assumes that the architecture packs
  * the type/offset into the pte as 5/27 as well.
  */
-#define MAX_SWAPFILES_SHIFT	5
+#define MAX_SWAPFILES_SHIFT	4
 #define MAX_SWAPFILES		(1 << MAX_SWAPFILES_SHIFT)
 
 /*
diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/include/linux/swapops.h linux-2.6.9-rc2-mm4.build/include/linux/swapops.h
--- linux-2.6.9-rc2-mm4.mhp.orig/include/linux/swapops.h	2004-10-14 17:22:26.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/include/linux/swapops.h	2004-10-14 17:44:00.022925568 -0300
@@ -10,7 +10,7 @@
  * swp_entry_t's are *never* stored anywhere in their arch-dependent format.
  */
 #define SWP_TYPE_SHIFT(e)	(sizeof(e.val) * 8 - MAX_SWAPFILES_SHIFT)
-#define SWP_OFFSET_MASK(e)	((1UL << SWP_TYPE_SHIFT(e)) - 1)
+#define SWP_OFFSET_MASK(e)	((1UL << (SWP_TYPE_SHIFT(e)-1))  - 1)
 
 /*
  * Store a type+offset into a swp_entry_t in an arch-independent format
@@ -19,7 +19,7 @@
 {
 	swp_entry_t ret;
 
-	ret.val = (type << SWP_TYPE_SHIFT(ret)) |
+	ret.val = type << SWP_TYPE_SHIFT(ret) |
 			(offset & SWP_OFFSET_MASK(ret));
 	return ret;
 }
@@ -30,8 +30,12 @@
  */
 static inline unsigned swp_type(swp_entry_t entry)
 {
-	return (entry.val >> SWP_TYPE_SHIFT(entry)) &
-			((1 << MAX_SWAPFILES_SHIFT) - 1);
+	return ((entry.val >> SWP_TYPE_SHIFT(entry)));
+}
+
+static inline unsigned migration_type(swp_entry_t entry)
+{
+	return 1;
 }
 
 /*
@@ -68,3 +72,26 @@
 	BUG_ON(pte_file(__swp_entry_to_pte(arch_entry)));
 	return __swp_entry_to_pte(arch_entry);
 }
+
+static inline int pte_is_migration(pte_t pte)
+{
+	unsigned long swp_type;
+	swp_entry_t arch_entry;
+
+	arch_entry = __pte_to_swp_entry(pte);
+
+	swp_type = __swp_type(arch_entry);
+
+	if (swp_type & 1)
+		return 1;
+	else 
+		return 0;
+}
+
+static inline pte_t migration_entry_to_pte(swp_entry_t entry)
+{
+	swp_entry_t arch_entry;
+	
+	arch_entry = __swp_entry(migration_type(entry), swp_offset(entry));
+	return __swp_entry_to_pte(arch_entry);
+}
diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/mm/memory.c linux-2.6.9-rc2-mm4.build/mm/memory.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/memory.c	2004-10-14 17:21:52.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/memory.c	2004-10-14 17:43:06.703031424 -0300
@@ -456,8 +456,13 @@
 		 */
 		if (unlikely(details))
 			continue;
-		if (!pte_file(pte))
-			free_swap_and_cache(pte_to_swp_entry(pte));
+		if (!pte_file(pte)) {
+			swp_entry_t swp_entry = pte_to_swp_entry(pte);
+			if (pte_is_migration(pte)) {
+				migration_remove_entry(swp_entry);
+			} else
+				free_swap_and_cache(swp_entry);
+		}
 		pte_clear(ptep);
 	}
 	pte_unmap(ptep-1);
@@ -1408,6 +1413,9 @@
 	pte_unmap(page_table);
 	spin_unlock(&mm->page_table_lock);
 again:
+	if (pte_is_migration(orig_pte)) {
+		page = lookup_migration_cache(entry.val & SWP_OFFSET_MASK(entry));
+	} else {
 	page = lookup_swap_cache(entry);
 	if (!page) {
  		swapin_readahead(entry, address, vma);
@@ -1433,7 +1441,6 @@
 		inc_page_state(pgmajfault);
 		grab_swap_token();
 	}
-
 	mark_page_accessed(page);
 	lock_page(page);
 	if (!PageSwapCache(page)) {
@@ -1442,6 +1449,13 @@
 		page_cache_release(page);
 		goto again;
 	}
+	}
+
+
+	if (pte_is_migration(orig_pte)) {
+		mark_page_accessed(page);
+		lock_page(page);
+	}
 
 	/*
 	 * Back out if somebody else faulted in this pte while we
@@ -1459,10 +1473,14 @@
 	}
 
 	/* The page isn't present yet, go ahead with the fault. */
-		
-	swap_free(entry);
-	if (vm_swap_full())
-		remove_exclusive_swap_page(page);
+
+	if (!pte_is_migration(orig_pte)) {
+		swap_free(entry);
+		if (vm_swap_full())
+			remove_exclusive_swap_page(page);
+	} else {
+		migration_remove_reference(page);
+	}
 
 	mm->rss++;
 	pte = mk_pte(page, vma->vm_page_prot);
diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/mm/mmigrate.c linux-2.6.9-rc2-mm4.build/mm/mmigrate.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/mmigrate.c	2004-10-14 17:21:52.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/mmigrate.c	2004-10-14 17:43:06.621043888 -0300
@@ -1,4 +1,4 @@
-/*
+ /*
  *  linux/mm/mmigrate.c
  *
  *  Support of memory hotplug
@@ -21,6 +21,9 @@
 #include <linux/rmap.h>
 #include <linux/mmigrate.h>
 #include <linux/delay.h>
+#include <linux/idr.h>
+#include <linux/page-flags.h>
+#include <linux/swapops.h>
 
 /*
  * The concept of memory migration is to replace a target page with
@@ -35,9 +38,174 @@
  * hugetlbpages can be handled in the same way.
  */
 
+int migr_writepage(struct page *page, struct writeback_control *wbc) 
+{
+	return WRITEPAGE_ACTIVATE;
+}
+
+struct counter {
+	int i;
+	int magic;
+};
+
+struct idr migration_idr;
+
+static struct address_space_operations migration_aops = {
+        .writepage      = migr_writepage,
+        .sync_page      = NULL,
+        .set_page_dirty = __set_page_dirty_nobuffers,
+};
+
+static struct backing_dev_info migration_backing_dev_info = {
+        .memory_backed  = 1,    /* Does not contribute to dirty memory */
+        .unplug_io_fn   = NULL,
+};
+
+struct address_space migration_space = {
+        .page_tree      = RADIX_TREE_INIT(GFP_ATOMIC),
+        .tree_lock      = RW_LOCK_UNLOCKED,
+        .a_ops          = &migration_aops,
+        .flags          = GFP_HIGHUSER,
+        .i_mmap_nonlinear = LIST_HEAD_INIT(migration_space.i_mmap_nonlinear),
+        .backing_dev_info = &migration_backing_dev_info,
+};
+
+int init_migration_cache(void) 
+{
+	idr_init(&migration_idr);
+
+	printk(KERN_INFO "Initializating migration cache!\n");
+
+	return 0;
+}
+
+__initcall(init_migration_cache);
+
+struct page *lookup_migration_cache(int id) 
+{ 
+	return find_get_page(&migration_space, id);
+}
+
+void migration_duplicate(swp_entry_t entry)
+{
+	int offset;
+	struct counter *cnt;
+
+	offset = swp_offset(entry);
+
+
+	cnt = idr_find(&migration_idr, offset);
+
+	if (printk_ratelimit()) {
+		printk(KERN_ERR "%s: cnt=%x offset:%x\n", __FUNCTION__, cnt, offset);
+		printk(KERN_ERR "%s: magic:%x\n", __FUNCTION__, cnt->magic);
+	}
+
+	cnt->i = cnt->i + 1;
+
+}
+
+void remove_from_migration_cache(struct page *page, int id)
+{
+	write_lock_irq(&migration_space.tree_lock);
+        idr_remove(&migration_idr, id);
+	radix_tree_delete(&migration_space.page_tree, id);
+	ClearPageMigration(page);
+	write_unlock_irq(&migration_space.tree_lock);
+}
+
+int migration_remove_entry(swp_entry_t entry)
+{
+	struct page *page;
+	
+	page = find_trylock_page(&migration_space, entry.val);
+
+
+	if (printk_ratelimit())
+		printk(KERN_ERR "remove_from_migration_cache!!\n");
+
+
+	if (page) {
+		migration_remove_reference(page);
+		unlock_page(page);
+		page_cache_release(page);
+	}
+
+}
+
+int migration_remove_reference(struct page *page)
+{
+	struct counter *c;
+
+	c = idr_find(&migration_idr, page->private);
+
+	if (printk_ratelimit())
+		printk(KERN_ERR "%s: magic:%x\n", __FUNCTION__, c->magic);
+
+	if (!c->i)
+		BUG();
+
+	c->i--;
+
+	if (!c->i) {
+		remove_from_migration_cache(page, page->private);
+		kfree(c);
+		if (printk_ratelimit())
+			printk(KERN_ERR "remove_from_migration_cache!!\n");
+	}
+		
+}
+
+int add_to_migration_cache(struct page *page, int gfp_mask) 
+{
+	int error, offset;
+	struct counter *counter;
+
+	BUG_ON(PageSwapCache(page));
+	BUG_ON(PagePrivate(page));
+	BUG_ON(PageMigration(page));
+
+        if (idr_pre_get(&migration_idr, GFP_ATOMIC) == 0)
+                return -ENOMEM;
+
+	error = radix_tree_preload(gfp_mask);
+
+	counter = kmalloc(sizeof(struct counter), GFP_KERNEL);
+
+	counter->i = 0;
+	counter->magic = 0xdeadbeef;
+
+	if (!error) {
+		write_lock_irq(&migration_space.tree_lock);
+	        error = idr_get_new_above(&migration_idr, counter, 1, &offset);
+
+		if (error < 0)
+			BUG();
+
+		error = radix_tree_insert(&migration_space.page_tree, offset,
+							page);
+
+		if (!error) {
+			page_cache_get(page);
+			SetPageLocked(page);
+			page->private = offset;
+//			page->mapping = &migration_space;
+			SetPageMigration(page);
+		}
+		write_unlock_irq(&migration_space.tree_lock);
+                radix_tree_preload_end();
+
+	}
+
+	return error;
+}
 
 /*
  * Try to writeback a dirty page to free its buffers.
+struct address_space migration_address;
+
+
+	printk(KERN_ERR "migration_idr: %d\n", id);
  */
 static int
 writeback_and_free_buffers(struct page *page)
@@ -83,6 +251,9 @@
 	if  (PageSwapCache(page)) {
 		SetPageSwapCache(newpage);
 		newpage->private = page->private;
+	} else if (PageMigration(page)) {
+		SetPageMigration(newpage);
+		newpage->private = page->private;
 	} else
 		newpage->mapping = page->mapping;
 
@@ -119,7 +290,8 @@
 	if (PageWriteback(page))
 		return -EAGAIN;
 	/* The page might have been truncated */
-	truncated = !PageSwapCache(newpage) && page_mapping(page) == NULL;
+	truncated = !PageSwapCache(newpage) && !PageMigration(newpage) && 
+		page_mapping(page) == NULL;
 	if (page_count(page) + truncated <= freeable_page_count)
 		return truncated ? -ENOENT : 0;
 	return -EAGAIN;
@@ -399,11 +571,15 @@
 	 * Put the page in a radix tree if it isn't in the tree yet.
 	 */
 #ifdef CONFIG_SWAP
-	if (PageAnon(page) && !PageSwapCache(page))
-		if (!add_to_swap(page, GFP_KERNEL)) {
+	if (PageAnon(page) && !PageSwapCache(page) && !PageMigration(page))
+		if (!add_to_migration_cache(page, GFP_KERNEL)) {
 			unlock_page(page);
 			return ERR_PTR(-ENOSPC);
 		}
+/*		if (!add_to_swap(page, GFP_KERNEL)) {
+			unlock_page(page);
+			return ERR_PTR(-ENOSPC);
+		} */
 #endif /* CONFIG_SWAP */
 	if ((mapping = page_mapping(page)) == NULL) {
 		/* truncation is in progress */
@@ -420,7 +596,7 @@
 		return ERR_PTR(-ENOMEM);
 	}
 
-	if (mapping->a_ops->migrate_page)
+	if (mapping->a_ops && mapping->a_ops->migrate_page)
 		ret = mapping->a_ops->migrate_page(page, newpage);
 	else
 		ret = generic_migrate_page(page, newpage, migrate_page_common);
@@ -454,6 +630,8 @@
 		.may_writepage	= 0,
 	};
 
+	printk(KERN_ERR "try to migrate pages!\n");
+
 	current->flags |= PF_KSWAPD;    /*  It's fake */
 	list_for_each_entry_safe(page, page2, page_list, lru) {
 		/*
diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/mm/rmap.c linux-2.6.9-rc2-mm4.build/mm/rmap.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/rmap.c	2004-10-14 17:21:52.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/rmap.c	2004-10-14 17:43:06.658038264 -0300
@@ -641,22 +646,36 @@
 	if (pte_dirty(pteval))
 		set_page_dirty(page);
 
-	if (PageAnon(page)) {
-		swp_entry_t entry = { .val = page->private };
-		/*
-		 * Store the swap location in the pte.
-		 * See handle_pte_fault() ...
-		 */
-		BUG_ON(!PageSwapCache(page));
-		swap_duplicate(entry);
-		if (list_empty(&mm->mmlist)) {
-			spin_lock(&mmlist_lock);
-			list_add(&mm->mmlist, &init_mm.mmlist);
-			spin_unlock(&mmlist_lock);
+		if (PageAnon(page)) {
+			swp_entry_t entry = { .val = page->private };
+			/*
+			 * Store the swap location in the pte.
+			 * See handle_pte_fault() ...
+			 */
+	//		BUG_ON(!PageSwapCache(page));
+			if (PageSwapCache(page)) {
+				swap_duplicate(entry);
+				if (list_empty(&mm->mmlist)) {
+					spin_lock(&mmlist_lock);
+					list_add(&mm->mmlist, &init_mm.mmlist);
+					spin_unlock(&mmlist_lock);
+				}
+				set_pte(pte, swp_entry_to_pte(entry));
+				BUG_ON(pte_file(*pte));
+			} else if (PageMigration(page)) {
+				// page cache get to reference pte,
+				// remove from migration cache
+				// on zero-users at fault path
+				migration_duplicate(entry);
+				if (list_empty(&mm->mmlist)) {
+					spin_lock(&mmlist_lock);
+					list_add(&mm->mmlist, &init_mm.mmlist);
+					spin_unlock(&mmlist_lock);
+				}
+				set_pte(pte, migration_entry_to_pte(entry));
+				BUG_ON(pte_file(*pte));
+			}
 		}
-		set_pte(pte, swp_entry_to_pte(entry));
-		BUG_ON(pte_file(*pte));
-	}
 
 	mm->rss--;
 	page_remove_rmap(page);
diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c linux-2.6.9-rc2-mm4.build/mm/vmscan.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c	2004-10-14 17:21:52.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/vmscan.c	2004-10-14 17:43:06.426073528 -0300
@@ -354,7 +354,7 @@
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
+		if (PageAnon(page) && !PageSwapCache(page) && !PageMigration(page)) {
 			if (!add_to_swap(page, GFP_ATOMIC))
 				goto activate_locked;
 		}




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
