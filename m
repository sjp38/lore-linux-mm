Date: Tue, 26 Oct 2004 22:45:50 +0900 (JST)
Message-Id: <20041026.224550.109999656.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041026092011.GD24462@logos.cnet>
References: <20041025213923.GD23133@logos.cnet>
	<20041026.153731.38067476.taka@valinux.co.jp>
	<20041026092011.GD24462@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi,

> > The previous code will cause deadlock, as the page is already locked.
> 
> Actually this one is fine - the page is not locked (its locked
> by the SwapCache pte path - not migration path)
> 
> if (pte_is_migration(pte)) 
> 	lookup_migration_cache
> else 
> 	old lookup swap cache
> 	lock_page
> 
> if (pte_is_migration(pte))
> 	mark_page_accessed
> 	lock_page

Oh, I understand.

> Can you please try the tests with the following updated patch
> 
> Works for me

It didn't work without one fix.

+void remove_from_migration_cache(struct page *page, int id)
+{
+	write_lock_irq(&migration_space.tree_lock);
+        idr_remove(&migration_idr, id);
+	radix_tree_delete(&migration_space.page_tree, id);
+	ClearPageSwapCache(page);
+	page->private = NULL;
+	write_unlock_irq(&migration_space.tree_lock);
+}

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

page_cache_release(page) should be invoked here, as the count for
the migration cache must be decreased.
With this fix, your migration cache started to work very fine!

+	}
+		
+}



The attached patch is what I ported your patch to the latest version
and I fixed the bug.


diff -puN include/linux/mm.h~migration_cache_marcelo include/linux/mm.h
--- linux-2.6.9-rc4/include/linux/mm.h~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/include/linux/mm.h	Tue Oct 26 21:08:31 2004
@@ -250,6 +250,24 @@ struct page {
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
@@ -457,11 +475,14 @@ void page_address_init(void);
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
diff -puN include/linux/swap.h~migration_cache_marcelo include/linux/swap.h
--- linux-2.6.9-rc4/include/linux/swap.h~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/include/linux/swap.h	Tue Oct 26 21:09:47 2004
@@ -257,6 +257,7 @@ static inline int remove_exclusive_swap_
 {
 	return __remove_exclusive_swap_page(p, 0);
 }
+extern int migration_remove_entry(swp_entry_t);
 struct backing_dev_info;
 
 extern struct swap_list_t swap_list;
@@ -330,6 +331,21 @@ static inline swp_entry_t get_swap_page(
 #define put_swap_token(x) do { } while(0)
 #define grab_swap_token()  do { } while(0)
 #define has_swap_token(x) 0
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
 
 #endif /* CONFIG_SWAP */
 #endif /* __KERNEL__*/
diff -puN include/linux/swapops.h~migration_cache_marcelo include/linux/swapops.h
--- linux-2.6.9-rc4/include/linux/swapops.h~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/include/linux/swapops.h	Tue Oct 26 21:08:31 2004
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
@@ -67,3 +69,24 @@ static inline pte_t swp_entry_to_pte(swp
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
diff -puN mm/fremap.c~migration_cache_marcelo mm/fremap.c
--- linux-2.6.9-rc4/mm/fremap.c~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/mm/fremap.c	Tue Oct 26 21:08:31 2004
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
diff -puN mm/memory.c~migration_cache_marcelo mm/memory.c
--- linux-2.6.9-rc4/mm/memory.c~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/mm/memory.c	Tue Oct 26 21:08:31 2004
@@ -53,7 +53,6 @@
 #include <asm/tlbflush.h>
 #include <asm/pgtable.h>
 
-#include <linux/swapops.h>
 #include <linux/elf.h>
 
 #ifndef CONFIG_DISCONTIGMEM
@@ -456,8 +455,13 @@ static void zap_pte_range(struct mmu_gat
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
@@ -1533,6 +1537,9 @@ static int do_swap_page(struct mm_struct
 	pte_unmap(page_table);
 	spin_unlock(&mm->page_table_lock);
 again:
+	if (pte_is_migration(orig_pte)) {
+		page = lookup_migration_cache(entry.val);
+	} else {
 	page = lookup_swap_cache(entry);
 	if (!page) {
  		swapin_readahead(entry, address, vma);
@@ -1558,15 +1565,22 @@ again:
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
@@ -1584,10 +1598,14 @@ again:
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
diff -puN mm/mmigrate.c~migration_cache_marcelo mm/mmigrate.c
--- linux-2.6.9-rc4/mm/mmigrate.c~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/mm/mmigrate.c	Tue Oct 26 22:19:59 2004
@@ -21,6 +21,8 @@
 #include <linux/rmap.h>
 #include <linux/mmigrate.h>
 #include <linux/delay.h>
+#include <linux/idr.h>
+#include <linux/page-flags.h>
 
 /*
  * The concept of memory migration is to replace a target page with
@@ -35,6 +37,162 @@
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
+		
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
@@ -121,9 +279,11 @@ page_migratable(struct page *page, struc
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
 
@@ -367,11 +527,6 @@ generic_migrate_page(struct page *page, 
 
 	/* map the newpage where the old page have been mapped. */
 	touch_unmapped_address(&vlist);
-	if (PageSwapCache(newpage)) {
-		lock_page(newpage);
-		__remove_exclusive_swap_page(newpage, 1);
-		unlock_page(newpage);
-	}
 
 	page->mapping = NULL;
 	unlock_page(page);
@@ -383,11 +538,6 @@ out_busy:
 	/* Roll back all operations. */
 	rewind_page(page, newpage);
 	touch_unmapped_address(&vlist);
-	if (PageSwapCache(page)) {
-		lock_page(page);
-		__remove_exclusive_swap_page(page, 1);
-		unlock_page(page);
-	}
 	return ret;
 
 out_removing:
@@ -416,10 +566,14 @@ migrate_onepage(struct page *page)
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
@@ -438,8 +592,9 @@ migrate_onepage(struct page *page)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	if (mapping->a_ops->migrate_page)
+	if (mapping->a_ops && mapping->a_ops->migrate_page) {
 		ret = mapping->a_ops->migrate_page(page, newpage);
+	}
 	else
 		ret = generic_migrate_page(page, newpage, migrate_page_common);
 	if (ret) {
diff -puN mm/page_io.c~migration_cache_marcelo mm/page_io.c
--- linux-2.6.9-rc4/mm/page_io.c~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/mm/page_io.c	Tue Oct 26 21:08:31 2004
@@ -15,7 +15,6 @@
 #include <linux/pagemap.h>
 #include <linux/swap.h>
 #include <linux/bio.h>
-#include <linux/swapops.h>
 #include <linux/writeback.h>
 #include <asm/pgtable.h>
 
diff -puN mm/rmap.c~migration_cache_marcelo mm/rmap.c
--- linux-2.6.9-rc4/mm/rmap.c~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/mm/rmap.c	Tue Oct 26 21:08:31 2004
@@ -50,7 +50,7 @@
 #include <linux/hugetlb.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
-#include <linux/swapops.h>
+//#include <linux/swapops.h>
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/rmap.h>
@@ -644,22 +644,36 @@ static int try_to_unmap_one(struct page 
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
diff -puN mm/shmem.c~migration_cache_marcelo mm/shmem.c
--- linux-2.6.9-rc4/mm/shmem.c~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/mm/shmem.c	Tue Oct 26 21:08:31 2004
@@ -42,7 +42,6 @@
 #include <linux/vfs.h>
 #include <linux/blkdev.h>
 #include <linux/security.h>
-#include <linux/swapops.h>
 #include <linux/mempolicy.h>
 #include <linux/namei.h>
 #include <linux/xattr.h>
diff -puN mm/swapfile.c~migration_cache_marcelo mm/swapfile.c
--- linux-2.6.9-rc4/mm/swapfile.c~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/mm/swapfile.c	Tue Oct 26 21:08:31 2004
@@ -33,7 +33,6 @@
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
-#include <linux/swapops.h>
 
 spinlock_t swaplock = SPIN_LOCK_UNLOCKED;
 unsigned int nr_swapfiles;
diff -puN mm/vmscan.c~migration_cache_marcelo mm/vmscan.c
--- linux-2.6.9-rc4/mm/vmscan.c~migration_cache_marcelo	Tue Oct 26 21:08:31 2004
+++ linux-2.6.9-rc4-taka/mm/vmscan.c	Tue Oct 26 21:08:31 2004
@@ -39,8 +39,6 @@
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
 
-#include <linux/swapops.h>
-
 /*
  * The list of shrinker callbacks used by to apply pressure to
  * ageable caches.
@@ -460,7 +458,9 @@ int shrink_list(struct list_head *page_l
 		}
 
 #ifdef CONFIG_SWAP
-		if (PageSwapCache(page)) {
+		// FIXME: allow relocation of migrate cache pages 
+		// into real swap pages for swapout.
+		if (PageSwapCache(page) && !PageMigration(page)) {
 			swp_entry_t swap = { .val = page->private };
 			__delete_from_swap_cache(page);
 			write_unlock_irq(&mapping->tree_lock);
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
