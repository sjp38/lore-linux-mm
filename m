Date: Wed, 08 Dec 2004 22:23:07 +0900 (JST)
Message-Id: <20041208.222307.64517559.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041201202101.GB5459@dmt.cyclades>
References: <20041123121447.GE4524@logos.cnet>
	<20041124.192156.73388074.taka@valinux.co.jp>
	<20041201202101.GB5459@dmt.cyclades>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi Marcelo,

Sorry for the delayed reply.

> > > > I've been testing the memory migration code with your patch.
> > > > I found problems and I think the attached patch would
> > > > fix some of them.
> > > > 
> > > > One of the problems is a race condition between add_to_migration_cache()
> > > > and try_to_unmap(). Some pages in the migration cache cannot
> > > > be removed with the current implementation. Please suppose
> > > > a process space might be removed between them. In this case
> > > > no one can remove pages the process had from the migration cache,
> > > > because they can be removed only when the pagetables pointed
> > > > the pages.
> > > 
> > > I guess I dont fully understand you Hirokazu.
> > > 
> > > unmap_vmas function (called by exit_mmap) calls zap_pte_range, 
> > > and that does:
> > > 
> > >                         if (pte_is_migration(pte)) {
> > >                                 migration_remove_entry(swp_entry);
> > >                         } else
> > >                                 free_swap_and_cache(swp_entry);
> > > 
> > > migration_remove_entry should decrease the IDR counter, and 
> > > remove the migration cache page on zero reference.
> > > 
> > > Am I missing something?
> > 
> > That's true only if the pte points a migration entry.
> > However, the pte may not point it when zap_pte_range() is called
> > in some case.
> > 
> > Please suppose the following flow.
> > Any process may exit or munmap during memory migration
> > before calling set_pte(migration entry). This will
> > keep some unreferenced pages in the migration cache.
> > No one can remove these pages.
> > 
> >   <start page migration>                  <Process A>
> >         |                                      |
> >         |                                      |
> >         |                                      |
> >  add_to_migration_cache()                      |
> >     insert a page of Process A  ----------->   |
> >     in the migration cache.                    |
> >         |                                      |
> >         |                               zap_pte_range()
> >         |                   X <------------ migration_remove_entry()
> >         |                      the pte associated with the page doesn't
> >         |                      point any migration entries.
> 
> OK, I see it, its the "normal" anonymous pte which will be removed at
> this point.
> 
> >         |
> >         |
> >  try_to_unmap() -----------------------> X
> >      migration_duplicate()       no pte mapping the page can be found.
> >      set_pte(migration entry)
> >         |
> >         |
> >  migrate_fn()
> >         |
> >         |
> >     <finish>
> >          the page still remains in the migration cache.
> > 	 the page may be referred by no process.
> > 
> > 
> > > I assume you are seeing this problems in practice?
> > 
> > Yes, it often happens without the patch.
> > 
> > > Sorry for the delay, been busy with other things.
> > 
> > No problem. Everyone knows you're doing hard work!

> > > > Therefore, I made pages removed from the migration cache
> > > > at the end of generic_migrate_page() if they remain in the cache.
> 
> OK, removing migration pages at end of generic_migrate_page() should 
> avoid the leak - that part of your patch is fine to me!
> 
> > > > The another is a fork() related problem. If fork() has occurred
> > > > during page migrationa, the previous work may not go well.
> > > > pages may not be removed from the migration cache.
> 
> Can you please expand on that one? I assume it works fine because 
> copy_page_range() duplicates the migration page reference (and the 
> migration pte), meaning that on exit (zap_pte_range) the migration
> pages should be removed through migration_remove_entry(). 

Yes, that's true.

> I dont see the problem - please correct me.

However, once the page is moved into the migration cache,
no one can make it swapped out. This problem may be solved
by your approach described below.

> > > > So I made the swapcode ignore pages in the migration cache.
> > > > However, as you know this is just a workaround and not a correct
> > > > way to fix it.
> 
> What this has to do with fork()? I can't understand.

fork() may leave some pages in the migration cache with my
latest implementation, though the memory migration code
tries to remove them from the migration cache by forcible
pagefault in touch_unmapped_address().

However, touch_unmapped_address() doesn't know that the
migration page has been duplicated.

> Your patch is correct here also - we can't reclaim migration cache 
> pages.
> 
> +	if (PageMigration(page)) {
> +		write_unlock_irq(&mapping->tree_lock);
> +		goto keep_locked;
> +	}
> 
> An enhancement would be to force pagefault of all pte's
> mapping to a migration cache page on shrink_list.  
>
> similar to rmap.c's try_to_unmap_anon() but intented to create the pte 
> instead of unmapping it

If it works as we expect, this code can be called at the end of
generic_migrate_page() I guess.

>         anon_vma = page_lock_anon_vma(page);
> 
>         list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
> 		ret = try_to_faultin(page, vma);
> 
> And try_to_faultin() calling handle_mm_fault()...
> 
> Is that what you mean?
> 
> Anyways, does the migration cache survive your stress testing now 
> with these changes ? 

Sure.

> I've coded the beginning of skeleton for the nonblocking version of migrate_onepage().
> 
> Can you generate a new migration cache patch on top of linux-2.6.10-rc1-mm2-mhp2 
> with your fixes ?

I ported your patch and my fixes on the top of linux-2.6.10-rc1-mm5-mhp1.


Thanks,
Hirokazu Takahashi.


---

Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>
---

 linux-2.6.10-rc1-mm5-taka/include/linux/mm.h      |   23 ++
 linux-2.6.10-rc1-mm5-taka/include/linux/swap.h    |   16 +
 linux-2.6.10-rc1-mm5-taka/include/linux/swapops.h |   25 ++
 linux-2.6.10-rc1-mm5-taka/mm/fremap.c             |   11 -
 linux-2.6.10-rc1-mm5-taka/mm/memory.c             |   50 ++++-
 linux-2.6.10-rc1-mm5-taka/mm/mmigrate.c           |  192 +++++++++++++++++++++-
 linux-2.6.10-rc1-mm5-taka/mm/page_io.c            |    1 
 linux-2.6.10-rc1-mm5-taka/mm/rmap.c               |   32 ++-
 linux-2.6.10-rc1-mm5-taka/mm/shmem.c              |    1 
 linux-2.6.10-rc1-mm5-taka/mm/swapfile.c           |    9 -
 linux-2.6.10-rc1-mm5-taka/mm/vmscan.c             |    6 
 11 files changed, 331 insertions, 35 deletions

diff -puN include/linux/mm.h~migration_cache_marcelo5 include/linux/mm.h
--- linux-2.6.10-rc1-mm5/include/linux/mm.h~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/include/linux/mm.h	Wed Dec  8 08:26:10 2004
@@ -286,6 +286,24 @@ extern int capture_page_range(unsigned l
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
@@ -493,11 +511,14 @@ void page_address_init(void);
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
diff -puN include/linux/swap.h~migration_cache_marcelo5 include/linux/swap.h
--- linux-2.6.10-rc1-mm5/include/linux/swap.h~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/include/linux/swap.h	Wed Dec  8 08:26:10 2004
@@ -258,6 +258,7 @@ static inline int remove_exclusive_swap_
 {
 	return __remove_exclusive_swap_page(p, 0);
 }
+extern int migration_remove_entry(swp_entry_t);
 struct backing_dev_info;
 
 extern struct swap_list_t swap_list;
@@ -331,6 +332,21 @@ static inline swp_entry_t get_swap_page(
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
diff -puN include/linux/swapops.h~migration_cache_marcelo5 include/linux/swapops.h
--- linux-2.6.10-rc1-mm5/include/linux/swapops.h~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/include/linux/swapops.h	Wed Dec  8 08:26:10 2004
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
diff -puN mm/fremap.c~migration_cache_marcelo5 mm/fremap.c
--- linux-2.6.10-rc1-mm5/mm/fremap.c~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/mm/fremap.c	Wed Dec  8 08:26:10 2004
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
diff -puN mm/memory.c~migration_cache_marcelo5 mm/memory.c
--- linux-2.6.10-rc1-mm5/mm/memory.c~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/mm/memory.c	Wed Dec  8 08:36:41 2004
@@ -56,7 +56,6 @@
 #include <asm/tlbflush.h>
 #include <asm/pgtable.h>
 
-#include <linux/swapops.h>
 #include <linux/elf.h>
 
 #ifndef CONFIG_DISCONTIGMEM
@@ -264,7 +263,10 @@ copy_swap_pte(struct mm_struct *dst_mm, 
 {
 	if (pte_file(pte))
 		return;
-	swap_duplicate(pte_to_swp_entry(pte));
+	if (pte_is_migration(pte)) 
+		migration_duplicate(pte_to_swp_entry(pte));
+	else
+		swap_duplicate(pte_to_swp_entry(pte));
 	if (list_empty(&dst_mm->mmlist)) {
 		spin_lock(&mmlist_lock);
 		list_add(&dst_mm->mmlist, &src_mm->mmlist);
@@ -537,8 +539,13 @@ static void zap_pte_range(struct mmu_gat
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
@@ -1739,6 +1746,20 @@ static int do_swap_page(struct mm_struct
 	pte_unmap(page_table);
 	spin_unlock(&mm->page_table_lock);
 again:
+	if (pte_is_migration(orig_pte)) {
+		page = lookup_migration_cache(entry.val);
+		if (!page) { 
+			spin_lock(&mm->page_table_lock);
+			page_table = pte_offset_map(pmd, address);
+			if (likely(pte_same(*page_table, orig_pte)))
+				ret = VM_FAULT_OOM;
+			else
+				ret = VM_FAULT_MINOR;
+			pte_unmap(page_table);
+			spin_unlock(&mm->page_table_lock);
+			goto out;
+		}
+	} else {
 	page = lookup_swap_cache(entry);
 	if (!page) {
  		swapin_readahead(entry, address, vma);
@@ -1764,15 +1785,22 @@ again:
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
@@ -1790,10 +1818,14 @@ again:
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
+		migration_remove_reference(page, 1);
+	}
 
 	mm->rss++;
 	acct_update_integrals();
diff -puN mm/mmigrate.c~migration_cache_marcelo5 mm/mmigrate.c
--- linux-2.6.10-rc1-mm5/mm/mmigrate.c~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/mm/mmigrate.c	Wed Dec  8 08:36:41 2004
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
@@ -35,6 +37,169 @@
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
+	migration_remove_reference(page, 1);
+
+	unlock_page(page);
+
+	page_cache_release(page);
+}
+
+int migration_remove_reference(struct page *page, int dec)
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
+	BUG_ON(c->i < dec);
+
+	c->i -= dec;
+
+	if (!c->i) {
+		remove_from_migration_cache(page, page->private);
+		kfree(c);
+		page_cache_release(page);
+	}
+}
+
+int detach_from_migration_cache(struct page *page)
+{
+	lock_page(page);	
+	migration_remove_reference(page, 0);
+	unlock_page(page);
+
+	return 0;
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
@@ -121,9 +286,11 @@ page_migratable(struct page *page, struc
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
 
@@ -365,7 +532,9 @@ generic_migrate_page(struct page *page, 
 
 	/* map the newpage where the old page have been mapped. */
 	touch_unmapped_address(&vlist);
-	if (PageSwapCache(newpage)) {
+	if (PageMigration(newpage))
+		detach_from_migration_cache(newpage);
+	else if (PageSwapCache(newpage)) {
 		lock_page(newpage);
 		__remove_exclusive_swap_page(newpage, 1);
 		unlock_page(newpage);
@@ -381,7 +550,9 @@ out_busy:
 	/* Roll back all operations. */
 	unwind_page(page, newpage);
 	touch_unmapped_address(&vlist);
-	if (PageSwapCache(page)) {
+	if (PageMigration(page))
+		detach_from_migration_cache(page);
+	else if (PageSwapCache(page)) {
 		lock_page(page);
 		__remove_exclusive_swap_page(page, 1);
 		unlock_page(page);
@@ -394,6 +565,8 @@ out_removing:
 		BUG();
 	unlock_page(page);
 	unlock_page(newpage);
+	if (PageMigration(page))
+		detach_from_migration_cache(page);
 	return ret;
 }
 
@@ -415,10 +588,14 @@ migrate_onepage(struct page *page)
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
@@ -437,8 +614,9 @@ migrate_onepage(struct page *page)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	if (mapping->a_ops->migrate_page)
+	if (mapping->a_ops && mapping->a_ops->migrate_page) {
 		ret = mapping->a_ops->migrate_page(page, newpage);
+	}
 	else
 		ret = generic_migrate_page(page, newpage, migrate_page_common);
 	if (ret) {
diff -puN mm/page_io.c~migration_cache_marcelo5 mm/page_io.c
--- linux-2.6.10-rc1-mm5/mm/page_io.c~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/mm/page_io.c	Wed Dec  8 08:26:10 2004
@@ -15,7 +15,6 @@
 #include <linux/pagemap.h>
 #include <linux/swap.h>
 #include <linux/bio.h>
-#include <linux/swapops.h>
 #include <linux/writeback.h>
 #include <asm/pgtable.h>
 
diff -puN mm/rmap.c~migration_cache_marcelo5 mm/rmap.c
--- linux-2.6.10-rc1-mm5/mm/rmap.c~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/mm/rmap.c	Wed Dec  8 08:26:10 2004
@@ -49,7 +49,7 @@
 #include <linux/sched.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
-#include <linux/swapops.h>
+//#include <linux/swapops.h>
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/acct.h>
@@ -655,15 +655,29 @@ static int try_to_unmap_one(struct page 
 		 * Store the swap location in the pte.
 		 * See handle_pte_fault() ...
 		 */
-		BUG_ON(!PageSwapCache(page));
-		swap_duplicate(entry);
-		if (list_empty(&mm->mmlist)) {
-			spin_lock(&mmlist_lock);
-			list_add(&mm->mmlist, &init_mm.mmlist);
-			spin_unlock(&mmlist_lock);
+		//BUG_ON(!PageSwapCache(page));
+		if (PageSwapCache(page) && !PageMigration(page)) {
+			swap_duplicate(entry);
+			if (list_empty(&mm->mmlist)) {
+				spin_lock(&mmlist_lock);
+				list_add(&mm->mmlist, &init_mm.mmlist);
+				spin_unlock(&mmlist_lock);
+			}
+			set_pte(pte, swp_entry_to_pte(entry));
+			BUG_ON(pte_file(*pte));
+		} else if (PageMigration(page)) {
+			// page cache get to reference pte,
+			// remove from migration cache
+			// on zero-users at fault path
+			migration_duplicate(entry);
+			if (list_empty(&mm->mmlist)) {
+				spin_lock(&mmlist_lock);
+				list_add(&mm->mmlist, &init_mm.mmlist);
+				spin_unlock(&mmlist_lock);
+			}
+			set_pte(pte, migration_entry_to_pte(entry));
+			BUG_ON(pte_file(*pte));
 		}
-		set_pte(pte, swp_entry_to_pte(entry));
-		BUG_ON(pte_file(*pte));
 		mm->anon_rss--;
 	}
 
diff -puN mm/shmem.c~migration_cache_marcelo5 mm/shmem.c
--- linux-2.6.10-rc1-mm5/mm/shmem.c~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/mm/shmem.c	Wed Dec  8 08:26:10 2004
@@ -42,7 +42,6 @@
 #include <linux/vfs.h>
 #include <linux/blkdev.h>
 #include <linux/security.h>
-#include <linux/swapops.h>
 #include <linux/mempolicy.h>
 #include <linux/namei.h>
 #include <linux/xattr.h>
diff -puN mm/swapfile.c~migration_cache_marcelo5 mm/swapfile.c
--- linux-2.6.10-rc1-mm5/mm/swapfile.c~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/mm/swapfile.c	Wed Dec  8 08:26:10 2004
@@ -34,7 +34,6 @@
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
-#include <linux/swapops.h>
 
 spinlock_t swaplock = SPIN_LOCK_UNLOCKED;
 unsigned int nr_swapfiles;
@@ -235,6 +234,7 @@ bad_device:
 	printk(KERN_ERR "swap_free: %s%08lx\n", Unused_file, entry.val);
 	goto out;
 bad_nofile:
+	BUG();
 	printk(KERN_ERR "swap_free: %s%08lx\n", Bad_file, entry.val);
 out:
 	return NULL;
@@ -1409,6 +1409,13 @@ asmlinkage long sys_swapon(const char __
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
diff -puN mm/vmscan.c~migration_cache_marcelo5 mm/vmscan.c
--- linux-2.6.10-rc1-mm5/mm/vmscan.c~migration_cache_marcelo5	Wed Dec  8 08:26:10 2004
+++ linux-2.6.10-rc1-mm5-taka/mm/vmscan.c	Wed Dec  8 08:36:41 2004
@@ -38,8 +38,6 @@
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
 
-#include <linux/swapops.h>
-
 /*
  * The list of shrinker callbacks used by to apply pressure to
  * ageable caches.
@@ -458,6 +456,10 @@ int shrink_list(struct list_head *page_l
 			goto keep_locked;
 		}
 
+		if (PageMigration(page)) {
+			write_unlock_irq(&mapping->tree_lock);
+			goto keep_locked;
+		}
 #ifdef CONFIG_SWAP
 		if (PageSwapCache(page)) {
 			swp_entry_t swap = { .val = page->private };
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
