Date: Thu, 28 Oct 2004 14:05:20 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache, updated
Message-ID: <20041028160520.GB7562@logos.cnet>
References: <20041026092535.GE24462@logos.cnet> <20041026.230110.21315175.taka@valinux.co.jp> <20041026122419.GD27014@logos.cnet> <20041027.224837.118287069.taka@valinux.co.jp> <20041028151928.GA7562@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041028151928.GA7562@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 28, 2004 at 01:19:28PM -0200, Marcelo Tosatti wrote:
> On Wed, Oct 27, 2004 at 10:48:37PM +0900, Hirokazu Takahashi wrote:
> > Hi,
> > 
> > > > BTW, I wonder how the migration code avoid to choose some pages
> > > > on LRU, which may have count == 0. This may happen the pages
> > > > are going to be removed. We have to care about it.
> > > 
> > > AFAICS its already done by __steal_page_from_lru(), which is used
> > > by grab_capturing_pages():
> > 	:
> > > Pages with reference count zero will be not be moved to the page
> > > list, and truncated pages seem to be handled nicely later on the
> > > migration codepath.
> > 
> > Ok, I see no problem about this with the current implementation.
> > 
> > 
> > BTW, now I'm just wondering migration_duplicate() should be
> > called from copy_page_range(), since page-migration and fork()
> > may work at the same time.
> > 
> > What do you think about this?
> 
> Yep thats probably what caused your failures.
> 
> I'll prepare a new patch.

Here it is - with the copy_page_range() fix as you pointed out,
plus sys_swapon() fix as suggested by Hiroyuki.

I've also added a BUG() in case of swap_free() failure, so we 
get a backtrace.

Can you please test this - thanks.

diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/include/linux/mm.h linux-2.6.9-rc2-mm4.build/include/linux/mm.h
--- linux-2.6.9-rc2-mm4.mhp.orig/include/linux/mm.h	2004-10-05 15:09:38.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/include/linux/mm.h	2004-10-25 18:42:37.000000000 -0200
@@ -251,6 +251,24 @@ extern int capture_page_range(unsigned l
  * files which need it (119 of them)
  */
 #include <linux/page-flags.h>
+#include <linux/swap.h>
+#include <linux/swapops.h> 
+
+static inline int PageMigration(struct page *page)
+{
+        swp_entry_t entry;
+
+        if (!PageSwapCache(page))
+                return 0;
+
+        entry.val = page->private;
+
+        if (swp_type(entry) != MIGRATION_TYPE)
+                return 0;
+
+        return 1;
+}
+
 
 /*
  * Methods to modify the page usage count.
@@ -458,11 +476,14 @@ void page_address_init(void);
 #define PAGE_MAPPING_ANON	1
 
 extern struct address_space swapper_space;
+extern struct address_space migration_space;
 static inline struct address_space *page_mapping(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
 
-	if (unlikely(PageSwapCache(page)))
+	if (unlikely(PageMigration(page)))
+		mapping = &migration_space;
+	else if (unlikely(PageSwapCache(page)))
 		mapping = &swapper_space;
 	else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
 		mapping = NULL;
diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/include/linux/swap.h linux-2.6.9-rc2-mm4.build/include/linux/swap.h
--- linux-2.6.9-rc2-mm4.mhp.orig/include/linux/swap.h	2004-10-05 15:09:39.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/include/linux/swap.h	2004-10-25 20:42:27.000000000 -0200
@@ -253,6 +253,7 @@ extern sector_t map_swap_page(struct swa
 extern struct swap_info_struct *get_swap_info_struct(unsigned);
 extern int can_share_swap_page(struct page *);
 extern int remove_exclusive_swap_page(struct page *);
+extern int migration_remove_entry(swp_entry_t);
 struct backing_dev_info;
 
 extern struct swap_list_t swap_list;
@@ -321,6 +322,21 @@ static inline swp_entry_t get_swap_page(
 #define grab_swap_token()  do { } while(0)
 #define has_swap_token(x) 0
 
+static inline int PageMigration(struct page *page)
+{
+        swp_entry_t entry;
+
+        if (!PageSwapCache(page))
+                return 0;
+
+        entry.val = page->private;
+
+        if (swp_type(entry) != MIGRATION_TYPE)
+                return 0;
+
+        return 1;
+}
+
 #endif /* CONFIG_SWAP */
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/include/linux/swapops.h linux-2.6.9-rc2-mm4.build/include/linux/swapops.h
--- linux-2.6.9-rc2-mm4.mhp.orig/include/linux/swapops.h	2004-10-05 15:09:35.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/include/linux/swapops.h	2004-10-24 12:15:07.000000000 -0200
@@ -10,7 +10,9 @@
  * swp_entry_t's are *never* stored anywhere in their arch-dependent format.
  */
 #define SWP_TYPE_SHIFT(e)	(sizeof(e.val) * 8 - MAX_SWAPFILES_SHIFT)
-#define SWP_OFFSET_MASK(e)	((1UL << SWP_TYPE_SHIFT(e)) - 1)
+#define SWP_OFFSET_MASK(e)	((1UL << (SWP_TYPE_SHIFT(e))) - 1)
+
+#define MIGRATION_TYPE  (MAX_SWAPFILES - 1)
 
 /*
  * Store a type+offset into a swp_entry_t in an arch-independent format
@@ -30,8 +32,7 @@ static inline swp_entry_t swp_entry(unsi
  */
 static inline unsigned swp_type(swp_entry_t entry)
 {
-	return (entry.val >> SWP_TYPE_SHIFT(entry)) &
-			((1 << MAX_SWAPFILES_SHIFT) - 1);
+	return ((entry.val >> SWP_TYPE_SHIFT(entry)));
 }
 
 /*
@@ -68,3 +69,24 @@ static inline pte_t swp_entry_to_pte(swp
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
+	return swp_type == MIGRATION_TYPE;
+}
+
+static inline pte_t migration_entry_to_pte(swp_entry_t entry)
+{
+	swp_entry_t arch_entry;
+	
+	arch_entry = __swp_entry(MIGRATION_TYPE, swp_offset(entry));
+	return __swp_entry_to_pte(arch_entry);
+}
+
diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/fremap.c linux-2.6.9-rc2-mm4.build/mm/fremap.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/fremap.c	2004-10-05 15:08:23.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/fremap.c	2004-10-25 20:44:05.000000000 -0200
@@ -11,7 +11,6 @@
 #include <linux/file.h>
 #include <linux/mman.h>
 #include <linux/pagemap.h>
-#include <linux/swapops.h>
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
@@ -43,8 +42,14 @@ static inline void zap_pte(struct mm_str
 			}
 		}
 	} else {
-		if (!pte_file(pte))
-			free_swap_and_cache(pte_to_swp_entry(pte));
+		if (!pte_file(pte)) {
+			swp_entry_t swp_entry = pte_to_swp_entry(pte);
+			if (pte_is_migration(pte)) { 
+				migration_remove_entry(swp_entry);
+			} else {
+				free_swap_and_cache(swp_entry);
+			}
+		}
 		pte_clear(ptep);
 	}
 }
diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/memory.c linux-2.6.9-rc2-mm4.build/mm/memory.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/memory.c	2004-10-05 15:08:23.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/memory.c	2004-10-28 15:06:59.000000000 -0200
@@ -53,7 +53,6 @@
 #include <asm/tlbflush.h>
 #include <asm/pgtable.h>
 
-#include <linux/swapops.h>
 #include <linux/elf.h>
 
 #ifndef CONFIG_DISCONTIGMEM
@@ -290,7 +289,13 @@ skip_copy_pte_range:
 				/* pte contains position in swap, so copy. */
 				if (!pte_present(pte)) {
 					if (!pte_file(pte)) {
-						swap_duplicate(pte_to_swp_entry(pte));
+						swp_entry_t entry;
+						entry = pte_to_swp_entry(pte);
+						if (pte_is_migration(pte)) 
+							migration_duplicate(entry);
+						else
+							swap_duplicate(entry);
+						
 						if (list_empty(&dst->mmlist)) {
 							spin_lock(&mmlist_lock);
 							list_add(&dst->mmlist,
@@ -456,8 +461,13 @@ static void zap_pte_range(struct mmu_gat
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
@@ -1408,6 +1418,9 @@ static int do_swap_page(struct mm_struct
 	pte_unmap(page_table);
 	spin_unlock(&mm->page_table_lock);
 again:
+	if (pte_is_migration(orig_pte)) {
+		page = lookup_migration_cache(entry.val);
+	} else {
 	page = lookup_swap_cache(entry);
 	if (!page) {
  		swapin_readahead(entry, address, vma);
@@ -1433,15 +1446,22 @@ again:
 		inc_page_state(pgmajfault);
 		grab_swap_token();
 	}
-
 	mark_page_accessed(page);
 	lock_page(page);
 	if (!PageSwapCache(page)) {
+		/* hiro: add !PageMigration(page) here */
 		/* page-migration has occured */
 		unlock_page(page);
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
@@ -1459,10 +1479,14 @@ again:
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
diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/mmigrate.c linux-2.6.9-rc2-mm4.build/mm/mmigrate.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/mmigrate.c	2004-10-05 15:08:23.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/mmigrate.c	2004-10-28 15:03:44.000000000 -0200
@@ -1,4 +1,4 @@
-/*
+ /*
  *  linux/mm/mmigrate.c
  *
  *  Support of memory hotplug
@@ -21,6 +21,8 @@
 #include <linux/rmap.h>
 #include <linux/mmigrate.h>
 #include <linux/delay.h>
+#include <linux/idr.h>
+#include <linux/page-flags.h>
 
 /*
  * The concept of memory migration is to replace a target page with
@@ -35,6 +37,161 @@
  * hugetlbpages can be handled in the same way.
  */
 
+struct counter {
+	int i;
+};
+
+struct idr migration_idr;
+
+static struct address_space_operations migration_aops = {
+        .writepage      = NULL,
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
+	read_lock_irq(&migration_space.tree_lock);
+
+	cnt = idr_find(&migration_idr, swp_offset(entry));
+	cnt->i = cnt->i + 1;
+
+	read_unlock_irq(&migration_space.tree_lock);
+}
+
+void remove_from_migration_cache(struct page *page, int id)
+{
+	write_lock_irq(&migration_space.tree_lock);
+        idr_remove(&migration_idr, id);
+	radix_tree_delete(&migration_space.page_tree, id);
+	ClearPageSwapCache(page);
+	page->private = NULL;
+	write_unlock_irq(&migration_space.tree_lock);
+}
+
+// FIXME: if the page is locked will it be correctly removed from migr cache?
+// check races
+
+int migration_remove_entry(swp_entry_t entry)
+{
+	struct page *page;
+	
+	page = find_get_page(&migration_space, entry.val);
+
+	if (!page)
+		BUG();
+
+	lock_page(page);	
+
+	migration_remove_reference(page);
+
+	unlock_page(page);
+
+	page_cache_release(page);
+}
+
+int migration_remove_reference(struct page *page)
+{
+	struct counter *c;
+	swp_entry_t entry;
+
+	entry.val = page->private;
+
+	read_lock_irq(&migration_space.tree_lock);
+
+	c = idr_find(&migration_idr, swp_offset(entry));
+
+	read_unlock_irq(&migration_space.tree_lock);
+
+	if (!c->i)
+		BUG();
+
+	c->i--;
+
+	if (!c->i) {
+		remove_from_migration_cache(page, page->private);
+		kfree(c);
+		page_cache_release(page);
+	}
+}
+
+int add_to_migration_cache(struct page *page, int gfp_mask) 
+{
+	int error, offset;
+	struct counter *counter;
+	swp_entry_t entry;
+
+	BUG_ON(PageSwapCache(page));
+
+	BUG_ON(PagePrivate(page));
+
+        if (idr_pre_get(&migration_idr, GFP_ATOMIC) == 0)
+                return -ENOMEM;
+
+	counter = kmalloc(sizeof(struct counter), GFP_KERNEL);
+
+	if (!counter)
+		return -ENOMEM;
+
+	error = radix_tree_preload(gfp_mask);
+
+	counter->i = 0;
+
+	if (!error) {
+		write_lock_irq(&migration_space.tree_lock);
+	        error = idr_get_new_above(&migration_idr, counter, 1, &offset);
+
+		if (error < 0)
+			BUG();
+
+		entry = swp_entry(MIGRATION_TYPE, offset);
+
+		error = radix_tree_insert(&migration_space.page_tree, entry.val,
+							page);
+		if (!error) {
+			page_cache_get(page);
+			SetPageLocked(page);
+			page->private = entry.val;
+			SetPageSwapCache(page);
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
@@ -119,9 +276,11 @@ page_migratable(struct page *page, struc
 	if (PageWriteback(page))
 		return -EAGAIN;
 	/* The page might have been truncated */
-	truncated = !PageSwapCache(newpage) && page_mapping(page) == NULL;
-	if (page_count(page) + truncated <= freeable_page_count)
+	truncated = !PageSwapCache(newpage) &&
+		page_mapping(page) == NULL;
+	if (page_count(page) + truncated <= freeable_page_count) 
 		return truncated ? -ENOENT : 0;
+
 	return -EAGAIN;
 }
 
@@ -144,7 +303,7 @@ migrate_page_common(struct page *page, s
 		case -ENOENT:
 			copy_highpage(newpage, page);
 			return ret;
-		case -EBUSY:
+		case -EBUSY: 
 			return ret;
 		case -EAGAIN:
 			writeback_and_free_buffers(page);
@@ -317,6 +476,7 @@ generic_migrate_page(struct page *page, 
 	switch (ret) {
 	default:
 		/* The page is busy. Try it later. */
+		BUG();
 		goto out_busy;
 	case -ENOENT:
 		/* The file the page belongs to has been truncated. */
@@ -400,10 +560,14 @@ migrate_onepage(struct page *page)
 	 */
 #ifdef CONFIG_SWAP
 	if (PageAnon(page) && !PageSwapCache(page))
-		if (!add_to_swap(page, GFP_KERNEL)) {
+		if (add_to_migration_cache(page, GFP_KERNEL)) {
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
@@ -420,8 +584,9 @@ migrate_onepage(struct page *page)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	if (mapping->a_ops->migrate_page)
+	if (mapping->a_ops && mapping->a_ops->migrate_page) {
 		ret = mapping->a_ops->migrate_page(page, newpage);
+	}
 	else
 		ret = generic_migrate_page(page, newpage, migrate_page_common);
 	if (ret) {
@@ -454,6 +619,8 @@ int try_to_migrate_pages(struct list_hea
 		.may_writepage	= 0,
 	};
 
+	printk(KERN_ERR "try to migrate pages!\n");
+
 	current->flags |= PF_KSWAPD;    /*  It's fake */
 	list_for_each_entry_safe(page, page2, page_list, lru) {
 		/*
diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/page_io.c linux-2.6.9-rc2-mm4.build/mm/page_io.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/page_io.c	2004-10-05 15:08:23.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/page_io.c	2004-10-24 12:23:55.000000000 -0200
@@ -15,7 +15,6 @@
 #include <linux/pagemap.h>
 #include <linux/swap.h>
 #include <linux/bio.h>
-#include <linux/swapops.h>
 #include <linux/writeback.h>
 #include <asm/pgtable.h>
 
diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/rmap.c linux-2.6.9-rc2-mm4.build/mm/rmap.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/rmap.c	2004-10-05 15:08:23.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/rmap.c	2004-10-25 17:31:43.000000000 -0200
@@ -49,7 +49,7 @@
 #include <linux/sched.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
-#include <linux/swapops.h>
+//#include <linux/swapops.h>
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/rmap.h>
@@ -641,22 +646,36 @@ static int try_to_unmap_one(struct page 
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
+			if (PageSwapCache(page) && !PageMigration(page)) {
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
diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/shmem.c linux-2.6.9-rc2-mm4.build/mm/shmem.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/shmem.c	2004-10-05 15:08:23.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/shmem.c	2004-10-24 12:24:20.000000000 -0200
@@ -42,7 +42,6 @@
 #include <linux/vfs.h>
 #include <linux/blkdev.h>
 #include <linux/security.h>
-#include <linux/swapops.h>
 #include <linux/mempolicy.h>
 #include <linux/namei.h>
 #include <linux/xattr.h>
diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/swapfile.c linux-2.6.9-rc2-mm4.build/mm/swapfile.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/swapfile.c	2004-10-05 15:08:23.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/swapfile.c	2004-10-28 15:09:49.000000000 -0200
@@ -29,7 +29,6 @@
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
-#include <linux/swapops.h>
 
 spinlock_t swaplock = SPIN_LOCK_UNLOCKED;
 unsigned int nr_swapfiles;
@@ -230,6 +229,7 @@ bad_device:
 	printk(KERN_ERR "swap_free: %s%08lx\n", Unused_file, entry.val);
 	goto out;
 bad_nofile:
+	BUG();
 	printk(KERN_ERR "swap_free: %s%08lx\n", Bad_file, entry.val);
 out:
 	return NULL;
@@ -1369,6 +1370,13 @@ asmlinkage long sys_swapon(const char __
 		swap_list_unlock();
 		goto out;
 	}
+
+	/* MIGRATION_TYPE is reserved for migration pages */
+	if (type >= MIGRATION_TYPE) {
+		swap_list_unlock();
+		goto out;
+	}
+
 	if (type >= nr_swapfiles)
 		nr_swapfiles = type+1;
 	INIT_LIST_HEAD(&p->extent_list);
diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c linux-2.6.9-rc2-mm4.build/mm/vmscan.c
--- linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c	2004-10-05 15:08:23.000000000 -0300
+++ linux-2.6.9-rc2-mm4.build/mm/vmscan.c	2004-10-25 19:15:56.000000000 -0200
@@ -38,8 +38,6 @@
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
 
-#include <linux/swapops.h>
-
 /*
  * The list of shrinker callbacks used by to apply pressure to
  * ageable caches.
@@ -459,7 +457,9 @@ int shrink_list(struct list_head *page_l
 		}
 
 #ifdef CONFIG_SWAP
-		if (PageSwapCache(page)) {
+		// FIXME: allow relocation of migrate cache pages 
+		// into real swap pages for swapout.
+		if (PageSwapCache(page) && !PageMigration(page)) {
 			swp_entry_t swap = { .val = page->private };
 			__delete_from_swap_cache(page);
 			write_unlock_irq(&mapping->tree_lock);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
