Received: from luxury.wat.veritas.com([10.10.185.122]) (29365 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m15XVd7-0002ymC@megami.veritas.com>
	for <linux-mm@kvack.org>; Thu, 16 Aug 2001 15:28:45 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #4 built 1999-Aug-24)
Date: Thu, 16 Aug 2001 23:30:11 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] more swapoff fixes 
In-Reply-To: <020901c1251a$e9386850$bef7020a@mammon>
Message-ID: <Pine.LNX.4.21.0108162211120.1086-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Linton <jlinton@interactivesi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jeremy and list,

Below is my patch of further bugfixes and speedups to swapoff,
based on 2.4.9.  For now it's an all-in-one patch: one of these
days when Linus gets back I'll cut it into little pieces, with
justification for each of those pieces.  Like most of VM, I think
it's very much a "Linus" thing rather than an "Alan" thing,
so I won't be pressing for inclusion in -ac.

I'm mostly happy with it, but there's one issue outstanding: need
to make sure we scan child _after_ parent if caught in dup_mmap().
I'll come back to that when I'm fresher: I've kept your "repeat
until empty", so I believe it's safe unless SWAP_MAP_MAX.

Please would someone explain to me how the SWAP_MAP_MAX case
can arise, I confess I don't get it.  I see how a shared file
page only needs 256 processes mapping in 256 places to overflow
an unsigned short; but I don't see how we get there with swap pages.
It does govern the approach quite strictly, and I found the current
algorithm much better suited to its constraints than I'd originally
supposed: no radical departure, sorry, even the BKL is still needed
(probably quite easy to eliminate, but more a 2.5 thing).

The most serious bugfix, I believe, is to the "dirty" handling.
try_to_unuse() used to remove page from pagecache after the loop
filling in ptes, but at some point it's been moved before the loop.
I prefer it before the loop, because that keeps try_to_swap_out()
from duping the entry while we're unduping it; but try_to_swap_out()
was discarding a non-swapcache page if its pte was not dirty.  So
if a swapcache page was already faulted in read-only, and swap_out()
reached it after freed from swapcache, before unuse_pte() got there,
your data would be wiped - or have I misunderstood?  (I should say
that the races I found were all long-standing, no problems from
Jeremy's 2.4.8 version.)

Faster? please decide for yourself.
Review and testing very welcome!
Thanks,
Hugh

--- linux-2.4.9/include/linux/pagemap.h	Wed Aug 15 22:21:21 2001
+++ linux-swapoff/include/linux/pagemap.h	Thu Aug 16 22:06:26 2001
@@ -81,11 +81,6 @@
 #define find_lock_page(mapping, index) \
 	__find_lock_page(mapping, index, page_hash(mapping, index))
 
-extern struct page * __find_get_swapcache_page (struct address_space * mapping,
-				unsigned long index, struct page **hash);
-#define find_get_swapcache_page(mapping, index) \
-	__find_get_swapcache_page(mapping, index, page_hash(mapping, index))
-
 extern void __add_page_to_hash_queue(struct page * page, struct page **p);
 
 extern void add_to_page_cache(struct page * page, struct address_space *mapping, unsigned long index);
--- linux-2.4.9/kernel/fork.c	Wed Jul 18 02:23:28 2001
+++ linux-swapoff/kernel/fork.c	Thu Aug 16 22:06:26 2001
@@ -8,7 +8,7 @@
  *  'fork.c' contains the help-routines for the 'fork' system call
  * (see also entry.S and others).
  * Fork is rather simple, once you get the hang of it, but the memory
- * management can be a bitch. See 'mm/memory.c': 'copy_page_tables()'
+ * management can be a bitch. See 'mm/memory.c': 'copy_page_range()'
  */
 
 #include <linux/config.h>
@@ -134,9 +134,22 @@
 	mm->mmap_avl = NULL;
 	mm->mmap_cache = NULL;
 	mm->map_count = 0;
+	mm->rss = 0;
 	mm->cpu_vm_mask = 0;
 	mm->swap_address = 0;
 	pprev = &mm->mmap;
+
+	/*
+	 * Add it to the mmlist after the parent.
+	 * Doing it this way means that we can order the list,
+	 * and fork() won't mess up the ordering significantly.
+	 * Add it first so that swapoff can see any swap entries.
+	 */
+	spin_lock(&mmlist_lock);
+	list_add(&mm->mmlist, &current->mm->mmlist);
+	mmlist_nr++;
+	spin_unlock(&mmlist_lock);
+
 	for (mpnt = current->mm->mmap ; mpnt ; mpnt = mpnt->vm_next) {
 		struct file *file;
 
@@ -149,7 +162,6 @@
 		*tmp = *mpnt;
 		tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_mm = mm;
-		mm->map_count++;
 		tmp->vm_next = NULL;
 		file = tmp->vm_file;
 		if (file) {
@@ -168,17 +180,19 @@
 			spin_unlock(&inode->i_mapping->i_shared_lock);
 		}
 
-		/* Copy the pages, but defer checking for errors */
-		retval = copy_page_range(mm, current->mm, tmp);
-		if (!retval && tmp->vm_ops && tmp->vm_ops->open)
-			tmp->vm_ops->open(tmp);
-
 		/*
-		 * Link in the new vma even if an error occurred,
-		 * so that exit_mmap() can clean up the mess.
+		 * Link in the new vma and copy the page table entries:
+		 * link in first so that swapoff can see swap entries.
 		 */
+		spin_lock(&mm->page_table_lock);
 		*pprev = tmp;
 		pprev = &tmp->vm_next;
+		mm->map_count++;
+		retval = copy_page_range(mm, current->mm, tmp);
+		spin_unlock(&mm->page_table_lock);
+
+		if (tmp->vm_ops && tmp->vm_ops->open)
+			tmp->vm_ops->open(tmp);
 
 		if (retval)
 			goto fail_nomem;
@@ -319,18 +333,6 @@
 	down_write(&oldmm->mmap_sem);
 	retval = dup_mmap(mm);
 	up_write(&oldmm->mmap_sem);
-
-	/*
-	 * Add it to the mmlist after the parent.
-	 *
-	 * Doing it this way means that we can order
-	 * the list, and fork() won't mess up the
-	 * ordering significantly.
-	 */
-	spin_lock(&mmlist_lock);
-	list_add(&mm->mmlist, &oldmm->mmlist);
-	mmlist_nr++;
-	spin_unlock(&mmlist_lock);
 
 	if (retval)
 		goto free_pt;
--- linux-2.4.9/mm/filemap.c	Thu Aug 16 19:12:07 2001
+++ linux-swapoff/mm/filemap.c	Thu Aug 16 22:06:26 2001
@@ -682,34 +682,6 @@
 }
 
 /*
- * Find a swapcache page (and get a reference) or return NULL.
- * The SwapCache check is protected by the pagecache lock.
- */
-struct page * __find_get_swapcache_page(struct address_space *mapping,
-			      unsigned long offset, struct page **hash)
-{
-	struct page *page;
-
-	/*
-	 * We need the LRU lock to protect against page_launder().
-	 */
-
-	spin_lock(&pagecache_lock);
-	page = __find_page_nolock(mapping, offset, *hash);
-	if (page) {
-		spin_lock(&pagemap_lru_lock);
-		if (PageSwapCache(page)) 
-			page_cache_get(page);
-		else
-			page = NULL;
-		spin_unlock(&pagemap_lru_lock);
-	}
-	spin_unlock(&pagecache_lock);
-
-	return page;
-}
-
-/*
  * Same as the above, but lock the page too, verifying that
  * it's still valid once we own it.
  */
--- linux-2.4.9/mm/memory.c	Tue Aug 14 00:16:41 2001
+++ linux-swapoff/mm/memory.c	Thu Aug 16 22:06:26 2001
@@ -148,6 +148,9 @@
  *
  * 08Jan98 Merged into one routine from several inline routines to reduce
  *         variable count and make things faster. -jj
+ *
+ * dst->page_table_lock is held on entry and exit,
+ * but may be dropped within pmd_alloc() and pte_alloc().
  */
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma)
@@ -159,8 +162,7 @@
 
 	src_pgd = pgd_offset(src, address)-1;
 	dst_pgd = pgd_offset(dst, address)-1;
-	
-	spin_lock(&dst->page_table_lock);		
+
 	for (;;) {
 		pmd_t * src_pmd, * dst_pmd;
 
@@ -234,6 +236,7 @@
 					pte = pte_mkclean(pte);
 				pte = pte_mkold(pte);
 				get_page(ptepage);
+				dst->rss++;
 
 cont_copy_pte_range:		set_pte(dst_pte, pte);
 cont_copy_pte_range_noset:	address += PAGE_SIZE;
@@ -251,11 +254,8 @@
 out_unlock:
 	spin_unlock(&src->page_table_lock);
 out:
-	spin_unlock(&dst->page_table_lock);
 	return 0;
-
 nomem:
-	spin_unlock(&dst->page_table_lock);
 	return -ENOMEM;
 }
 
@@ -1080,15 +1080,13 @@
 		/* Don't block on I/O for read-ahead */
 		if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster
 				* (1 << page_cluster)) {
-			while (i++ < num)
-				swap_free(SWP_ENTRY(SWP_TYPE(entry), offset++));
 			break;
 		}
 		/* Ok, do the async read-ahead now */
 		new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset));
-		if (new_page != NULL)
-			page_cache_release(new_page);
-		swap_free(SWP_ENTRY(SWP_TYPE(entry), offset));
+		if (new_page == NULL)
+			break;
+		page_cache_release(new_page);
 	}
 	return;
 }
--- linux-2.4.9/mm/swap_state.c	Wed Jul 18 23:18:15 2001
+++ linux-swapoff/mm/swap_state.c	Thu Aug 16 22:06:26 2001
@@ -29,7 +29,7 @@
 	if (swap_count(page) > 1)
 		goto in_use;
 
-	/* We could remove it here, but page_launder will do it anyway */
+	delete_from_swap_cache_nolock(page);
 	UnlockPage(page);
 	return 0;
 
@@ -79,40 +79,35 @@
 		BUG();
 	if (page->mapping)
 		BUG();
-	flags = page->flags & ~((1 << PG_error) | (1 << PG_arch_1));
+
+	/* clear PG_dirty so a subsequent set_page_dirty takes effect */
+	flags = page->flags & ~((1 << PG_error) | (1 << PG_dirty) | (1 << PG_arch_1));
 	page->flags = flags | (1 << PG_uptodate);
 	page->age = PAGE_AGE_START;
 	add_to_page_cache_locked(page, &swapper_space, entry.val);
 }
 
-static inline void remove_from_swap_cache(struct page *page)
-{
-	struct address_space *mapping = page->mapping;
-
-	if (mapping != &swapper_space)
-		BUG();
-	if (!PageSwapCache(page) || !PageLocked(page))
-		PAGE_BUG(page);
-
-	PageClearSwapCache(page);
-	ClearPageDirty(page);
-	__remove_inode_page(page);
-}
-
 /*
  * This must be called only on pages that have
  * been verified to be in the swap cache.
  */
 void __delete_from_swap_cache(struct page *page)
 {
+	struct address_space *mapping = page->mapping;
 	swp_entry_t entry;
 
-	entry.val = page->index;
-
 #ifdef SWAP_CACHE_INFO
 	swap_cache_del_total++;
 #endif
-	remove_from_swap_cache(page);
+	if (mapping != &swapper_space)
+		BUG();
+	if (!PageSwapCache(page) || !PageLocked(page))
+		BUG();
+
+	entry.val = page->index;
+	PageClearSwapCache(page);
+	ClearPageDirty(page);
+	__remove_inode_page(page);
 	swap_free(entry);
 }
 
@@ -129,7 +124,6 @@
 		lru_cache_del(page);
 
 	spin_lock(&pagecache_lock);
-	ClearPageDirty(page);
 	__delete_from_swap_cache(page);
 	spin_unlock(&pagecache_lock);
 	page_cache_release(page);
@@ -169,14 +163,12 @@
 	page_cache_release(page);
 }
 
-
 /*
  * Lookup a swap entry in the swap cache. A found page will be returned
  * unlocked and with its refcount incremented - we rely on the kernel
  * lock getting page table operations atomic even if we drop the page
  * lock before returning.
  */
-
 struct page * lookup_swap_cache(swp_entry_t entry)
 {
 	struct page *found;
@@ -184,22 +176,20 @@
 #ifdef SWAP_CACHE_INFO
 	swap_cache_find_total++;
 #endif
-	while (1) {
-		/*
-		 * Right now the pagecache is 32-bit only.  But it's a 32 bit index. =)
-		 */
-		found = find_get_swapcache_page(&swapper_space, entry.val);
-		if (!found)
-			return 0;
-		if (!PageSwapCache(found))
-			BUG();
-		if (found->mapping != &swapper_space)
-			BUG();
+	found = find_get_page(&swapper_space, entry.val);
+	if (!found)
+		return 0;
+	/*
+	 * If SMP, it is unsafe to assert PageSwapCache and mapping
+	 * here: nothing prevents swapoff from deleting this page from
+	 * the swap cache at this moment.  find_lock_page would prevent
+	 * that, but no need to change: we _have_ got the right page
+	 * (but would not recognize it as an exclusive swap page later).
+	 */
 #ifdef SWAP_CACHE_INFO
-		swap_cache_find_success++;
+	swap_cache_find_success++;
 #endif
-		return found;
-	}
+	return found;
 }
 
 /* 
@@ -210,33 +200,41 @@
  * A failure return means that either the page allocation failed or that
  * the swap entry is no longer in use.
  */
-
 struct page * read_swap_cache_async(swp_entry_t entry)
 {
-	struct page *found_page = 0, *new_page;
+	struct page *found_page, *new_page;
+	struct page **hash;
 	
 	/*
-	 * Make sure the swap entry is still in use.
-	 */
-	if (!swap_duplicate(entry))	/* Account for the swap cache */
-		goto out;
-	/*
-	 * Look for the page in the swap cache.
+	 * Look for the page in the swap cache.  Since we normally call
+	 * this only after lookup_swap_cache() failed, re-calling that
+	 * would confuse the statistics: use __find_get_page() directly.
 	 */
-	found_page = lookup_swap_cache(entry);
+	hash = page_hash(&swapper_space, entry.val);
+	found_page = __find_get_page(&swapper_space, entry.val, hash);
 	if (found_page)
-		goto out_free_swap;
+		goto out;
 
 	new_page = alloc_page(GFP_HIGHUSER);
 	if (!new_page)
-		goto out_free_swap;	/* Out of memory */
+		goto out;		/* Out of memory */
 
 	/*
 	 * Check the swap cache again, in case we stalled above.
+	 * The BKL is guarding against races between this check
+	 * and where the new page is added to the swap cache below.
 	 */
-	found_page = lookup_swap_cache(entry);
+	found_page = __find_get_page(&swapper_space, entry.val, hash);
 	if (found_page)
 		goto out_free_page;
+
+	/*
+	 * Make sure the swap entry is still in use.  It could have gone
+	 * while caller waited for BKL, or while allocating a page.
+	 */
+	if (!swap_duplicate(entry))	/* Account for the swap cache */
+		goto out_free_page;
+
 	/* 
 	 * Add it to the swap cache and read its contents.
 	 */
@@ -248,8 +246,6 @@
 
 out_free_page:
 	page_cache_release(new_page);
-out_free_swap:
-	swap_free(entry);
 out:
 	return found_page;
 }
--- linux-2.4.9/mm/swapfile.c	Sat Aug 11 02:02:42 2001
+++ linux-swapoff/mm/swapfile.c	Thu Aug 16 22:06:26 2001
@@ -229,33 +229,23 @@
  * share this swap entry, so be cautious and let do_wp_page work out
  * what to do if a write is requested later.
  */
-/* tasklist_lock and vma->vm_mm->page_table_lock are held */
+/* BKL, mmlist_lock and vma->vm_mm->page_table_lock are held */
 static inline void unuse_pte(struct vm_area_struct * vma, unsigned long address,
 	pte_t *dir, swp_entry_t entry, struct page* page)
 {
 	pte_t pte = *dir;
 
-	if (pte_none(pte))
+	if (pte_none(pte) || pte_present(pte))
 		return;
-	if (pte_present(pte)) {
-		/* If this entry is swap-cached, then page must already
-                   hold the right address for any copies in physical
-                   memory */
-		if (pte_page(pte) != page)
-			return;
-		/* We will be removing the swap cache in a moment, so... */
-		ptep_mkdirty(dir);
-		return;
-	}
 	if (pte_to_swp_entry(pte).val != entry.val)
 		return;
-	set_pte(dir, pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
-	swap_free(entry);
 	get_page(page);
+	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
+	swap_free(entry);
 	++vma->vm_mm->rss;
 }
 
-/* tasklist_lock and vma->vm_mm->page_table_lock are held */
+/* BKL, mmlist_lock and vma->vm_mm->page_table_lock are held */
 static inline void unuse_pmd(struct vm_area_struct * vma, pmd_t *dir,
 	unsigned long address, unsigned long size, unsigned long offset,
 	swp_entry_t entry, struct page* page)
@@ -283,7 +273,7 @@
 	} while (address && (address < end));
 }
 
-/* tasklist_lock and vma->vm_mm->page_table_lock are held */
+/* BKL, mmlist_lock and vma->vm_mm->page_table_lock are held */
 static inline void unuse_pgd(struct vm_area_struct * vma, pgd_t *dir,
 	unsigned long address, unsigned long size,
 	swp_entry_t entry, struct page* page)
@@ -314,7 +304,7 @@
 	} while (address && (address < end));
 }
 
-/* tasklist_lock and vma->vm_mm->page_table_lock are held */
+/* BKL, mmlist_lock and vma->vm_mm->page_table_lock are held */
 static void unuse_vma(struct vm_area_struct * vma, pgd_t *pgdir,
 			swp_entry_t entry, struct page* page)
 {
@@ -337,8 +327,6 @@
 	/*
 	 * Go through process' page directory.
 	 */
-	if (!mm)
-		return;
 	spin_lock(&mm->page_table_lock);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		pgd_t * pgd = pgd_offset(mm, vma->vm_start);
@@ -348,54 +336,34 @@
 	return;
 }
 
-/*
- * this is called when we find a page in the swap list
- * all the locks have been dropped at this point which
- * isn't a problem because we rescan the swap map
- * and we _don't_ clear the refrence count if for 
- * some reason it isn't 0
- */
-   
-static inline int free_found_swap_entry(unsigned int type, int i)
+static int find_next_to_unuse(struct swap_info_struct *si, int prev)
 {
-	struct task_struct *p;
-	struct page *page;
-	swp_entry_t entry;
+	int i = prev;
+	int count;
 
-	entry = SWP_ENTRY(type, i);
-
-	/* 
-	 * Get a page for the entry, using the existing swap
-	 * cache page if there is one.  Otherwise, get a clean
-	 * page and read the swap into it. 
-	 */
-	page = read_swap_cache_async(entry);
-	if (!page) {
-		swap_free(entry);
-		return -ENOMEM;
+	swap_device_lock(si);
+	for (;;) {
+		if (++i >= si->max) {
+			i = 0;
+			break;
+		}
+		count = si->swap_map[i];
+		if (count && count != SWAP_MAP_BAD) {
+			/*
+			 * Prevent swaphandle from being completely
+			 * unused by swap_free while we are trying
+			 * to read in the page - this prevents warning
+			 * messages from rw_swap_page_base.
+			 */
+			if (count != SWAP_MAP_MAX)
+				si->swap_map[i] = count + 1;
+			break;
+		}
 	}
-	lock_page(page);
-	if (PageSwapCache(page))
-		delete_from_swap_cache_nolock(page);
-	UnlockPage(page);
-	read_lock(&tasklist_lock);
-	for_each_task(p)
-		unuse_process(p->mm, entry, page);
-	read_unlock(&tasklist_lock);
-	shmem_unuse(entry, page);
-	/* 
-	 * Now get rid of the extra reference to the temporary
-	 * page we've been using. 
-	 */
-	page_cache_release(page);
-	/*
-	 * Check for and clear any overflowed swap map counts.
-	 */
-	swap_free(entry);
-	return 0;
+	swap_device_unlock(si);
+	return i;
 }
 
-
 /*
  * We completely avoid races by reading each swap page in advance,
  * and then search for the process using it.  All the necessary
@@ -404,80 +372,161 @@
 static int try_to_unuse(unsigned int type)
 {
 	struct swap_info_struct * si = &swap_info[type];
-	int ret, foundpage;
+	struct mm_struct *last_mm;
+	struct page *page;
+	struct page *nextpage = NULL;	/* keep compiler quiet */
+	unsigned short *swap_map;
+	swp_entry_t entry;
+	int i, next = 0;
+	int retval = 0;
 
-	do {
-		int i;
+	/*
+	 * When searching mms for an entry, a plausible strategy is
+	 * to start at the last mm we freed the preceding entry from
+	 * (though actually we don't observe whether we or another
+	 * freed the entry).  Initialize this last_mm with a hold.
+	 */
+	last_mm = &init_mm;
+	atomic_inc(&init_mm.mm_users);
+
+	for (;;) {
+		if (!next) {
+			/*
+			 * Start a fresh sweep of the swap_map.  We're
+			 * done when no entry found in a single sweep.
+			 */
+			next = find_next_to_unuse(si, 0);
+			if (!next)
+				break;
+			entry = SWP_ENTRY(type, next);
+			nextpage = read_swap_cache_async(entry);
+			if (!nextpage) {
+				swap_free(entry);
+				retval = -ENOMEM;
+				break;
+			}
+		}
 
 		/*
-		 * The algorithm is inefficient but seldomly used
-		 *
-		 * Find a swap page in use and read it in.
+		 * Set page to nextpage, with readahead
+		 * to a new nextpage in the background.
 		 */
-		foundpage = 0;
-		swap_device_lock(si);
-		for (i = 1; i < si->max ; i++) {
-			int count = si->swap_map[i];
-			if (!count || count == SWAP_MAP_BAD)
-				continue;
+		i = next;
+		page = nextpage;
+		next = find_next_to_unuse(si, next);
+		if (next) {
+			entry = SWP_ENTRY(type, next);
+			nextpage = read_swap_cache_async(entry);
+			if (!nextpage) {
+				swap_free(entry);
+				swap_free(SWP_ENTRY(type, i));
+				page_cache_release(page);
+				retval = -ENOMEM;
+				break;
+			}
+		}
 
-			/*
-			 * Prevent swaphandle from being completely
-			 * unused by swap_free while we are trying
-			 * to read in the page - this prevents warning
-			 * messages from rw_swap_page_base.
-			 */
-			foundpage = 1;
-			if (count != SWAP_MAP_MAX)
-				si->swap_map[i] = count + 1;
+		/*
+		 * Don't hold on to last_mm if it looks like exiting.
+		 * Can mmput ever block? if so, then we cannot risk
+		 * it between deleting the page from the swap cache,
+		 * and completing the search through mms (and cannot
+		 * use it to avoid the long hold on mmlist_lock there).
+		 */
+		if (atomic_read(&last_mm->mm_users) == 1) {
+			mmput(last_mm);
+			last_mm = &init_mm;
+			atomic_inc(&init_mm.mm_users);
+		}
 
-			swap_device_unlock(si);
-			ret = free_found_swap_entry(type,i);
-			if (ret)
-				return ret;
+		/*
+		 * While next swap entry is read into the swap cache
+		 * asynchronously (if it was not already present), wait
+		 * for and lock page.  Remove it from the swap cache so
+		 * try_to_swap_out won't bump swap count.  Mark it dirty
+		 * so try_to_swap_out will preserve it without us having
+		 * to mark any present ptes as dirty: so we can skip
+		 * searching processes once swap count has all gone.
+		 */
+		lock_page(page);
+		if (PageSwapCache(page))
+			delete_from_swap_cache_nolock(page);
+		SetPageDirty(page);
+		UnlockPage(page);
+		flush_page_to_ram(page);
 
-			/*
-			 * we pick up the swap_list_lock() to guard the nr_swap_pages,
-			 * si->swap_map[] should only be changed if it is SWAP_MAP_MAX
-			 * otherwise ugly stuff can happen with other people who are in
-			 * the middle of a swap operation to this device. This kind of
-			 * operation can sometimes be detected with the undead swap 
-			 * check. Don't worry about these 'undead' entries for now
-			 * they will be caught the next time though the top loop.
-			 * Do worry, about the weak locking that allows this to happen
-			 * because if it happens to a page that is SWAP_MAP_MAX
-			 * then bad stuff can happen.
-			 */
+		/*
+		 * Remove all references to entry (without blocking).
+		 */
+		entry = SWP_ENTRY(type, i);
+		swap_map = &si->swap_map[i];
+		swap_free(entry);
+		if (*swap_map) {
+			if (last_mm == &init_mm)
+				shmem_unuse(entry, page);
+			else
+				unuse_process(last_mm, entry, page);
+		}
+		if (*swap_map) {
+			struct mm_struct *mm = last_mm;
+			struct list_head *p = &mm->mmlist;
+
+			spin_lock(&mmlist_lock);
+			while (*swap_map && (p = p->next) != &last_mm->mmlist) {
+				mm = list_entry(p, struct mm_struct, mmlist);
+				if (mm == &init_mm)
+					shmem_unuse(entry, page);
+				else
+					unuse_process(mm, entry, page);
+			}
+			atomic_inc(&mm->mm_users);
+			spin_unlock(&mmlist_lock);
+			mmput(last_mm);
+			last_mm = mm;
+		}
+		page_cache_release(page);
+
+		/*
+		 * There's could still be an outstanding reference:
+		 * if we checked the child before the parent while
+		 * fork was in dup_mmap; or if mmput has taken the mm
+		 * off mmlist, but exit_mmap has not yet completed.
+		 * Until that's fixed, loop back and recheck at the end:
+		 * we are done once none found in a single locked sweep.
+		 * That handles the normal case; but if SWAP_MAP_MAX we
+		 * only _hope_ we got them all in one, and reset anyway.
+		 */
+		if (*swap_map == SWAP_MAP_MAX) {
 			swap_list_lock();
 			swap_device_lock(si);
-			if (si->swap_map[i] > 0) {
-				/* normally this would just kill the swap page if
-				 * it still existed, it appears though that the locks 
-				 * are a little fuzzy
-				 */
-				if (si->swap_map[i] != SWAP_MAP_MAX) {
-					printk("VM: Undead swap entry %08lx\n", 
-					       SWP_ENTRY(type, i).val);
-				} else {
-					nr_swap_pages++;
-					si->swap_map[i] = 0;
-				}
-			}
+			*swap_map = 0;
+			nr_swap_pages++;
 			swap_device_unlock(si);
 			swap_list_unlock();
-
+		}
+		if (*swap_map) {
 			/*
-			 * This lock stuff is ulgy!
-			 * Make sure that we aren't completely killing
-			 * interactive performance.
+			 * Useful message while testing, but we know
+			 * this can happen, so should be removed soon.
 			 */
-			if (current->need_resched)
-				schedule();
-			swap_device_lock(si); 
+			printk("VM: Undead swap entry %08lx\n", entry.val);
 		}
-		swap_device_unlock(si);
-	} while (foundpage);
-	return 0;
+
+		/*
+		 * Make sure that we aren't completely killing
+		 * interactive performance.  Interruptible check on
+		 * signal_pending() would be nice, but changes the spec?
+		 */
+		if (current->need_resched)
+			schedule();
+		else {
+			unlock_kernel();
+			lock_kernel();
+		}
+	}
+
+	mmput(last_mm);
+	return retval;
 }
 
 asmlinkage long sys_swapoff(const char * specialfile)
@@ -557,6 +606,7 @@
 	nd.mnt = p->swap_vfsmnt;
 	p->swap_vfsmnt = NULL;
 	p->swap_device = 0;
+	p->max = 0;
 	vfree(p->swap_map);
 	p->swap_map = NULL;
 	p->flags = 0;
@@ -637,7 +687,7 @@
 	union swap_header *swap_header = 0;
 	int swap_header_version;
 	int nr_good_pages = 0;
-	unsigned long maxpages;
+	unsigned long maxpages = 1;
 	int swapfilesize;
 	struct block_device *bdev = NULL;
 	
@@ -752,17 +802,17 @@
 				if (!p->lowest_bit)
 					p->lowest_bit = i;
 				p->highest_bit = i;
-				p->max = i+1;
+				maxpages = i+1;
 				j++;
 			}
 		}
 		nr_good_pages = j;
-		p->swap_map = vmalloc(p->max * sizeof(short));
+		p->swap_map = vmalloc(maxpages * sizeof(short));
 		if (!p->swap_map) {
 			error = -ENOMEM;		
 			goto bad_swap;
 		}
-		for (i = 1 ; i < p->max ; i++) {
+		for (i = 1 ; i < maxpages ; i++) {
 			if (test_bit(i,(char *) swap_header))
 				p->swap_map[i] = 0;
 			else
@@ -783,24 +833,22 @@
 
 		p->lowest_bit  = 1;
 		p->highest_bit = swap_header->info.last_page - 1;
-		p->max	       = swap_header->info.last_page;
-
-		maxpages = SWP_OFFSET(SWP_ENTRY(0,~0UL));
-		if (p->max >= maxpages)
-			p->max = maxpages-1;
+		maxpages = SWP_OFFSET(SWP_ENTRY(0,~0UL)) - 1;
+		if (maxpages > swap_header->info.last_page)
+			maxpages = swap_header->info.last_page;
 
 		error = -EINVAL;
 		if (swap_header->info.nr_badpages > MAX_SWAP_BADPAGES)
 			goto bad_swap;
 		
 		/* OK, set up the swap map and apply the bad block list */
-		if (!(p->swap_map = vmalloc (p->max * sizeof(short)))) {
+		if (!(p->swap_map = vmalloc(maxpages * sizeof(short)))) {
 			error = -ENOMEM;
 			goto bad_swap;
 		}
 
 		error = 0;
-		memset(p->swap_map, 0, p->max * sizeof(short));
+		memset(p->swap_map, 0, maxpages * sizeof(short));
 		for (i=0; i<swap_header->info.nr_badpages; i++) {
 			int page = swap_header->info.badpages[i];
 			if (page <= 0 || page >= swap_header->info.last_page)
@@ -815,7 +863,7 @@
 			goto bad_swap;
 	}
 	
-	if (swapfilesize && p->max > swapfilesize) {
+	if (swapfilesize && maxpages > swapfilesize) {
 		printk(KERN_WARNING
 		       "Swap area shorter than signature indicates\n");
 		error = -EINVAL;
@@ -827,6 +875,7 @@
 		goto bad_swap;
 	}
 	p->swap_map[0] = SWAP_MAP_BAD;
+	p->max = maxpages;
 	p->flags = SWP_WRITEOK;
 	p->pages = nr_good_pages;
 	swap_list_lock();
@@ -856,6 +905,7 @@
 	if (bdev)
 		blkdev_put(bdev, BDEV_SWAP);
 bad_swap_2:
+	p->max = 0;
 	if (p->swap_map)
 		vfree(p->swap_map);
 	nd.mnt = p->swap_vfsmnt;
@@ -947,10 +997,12 @@
 	printk("Bad swap file entry %08lx\n", entry.val);
 	goto out;
 bad_offset:
-	printk("Bad swap offset entry %08lx\n", entry.val);
+	/* Don't report: can happen in read_swap_cache_async after swapoff */
+	/* printk("Bad swap offset entry %08lx\n", entry.val); */
 	goto out;
 bad_unused:
-	printk("Unused swap offset entry in swap_dup %08lx\n", entry.val);
+	/* Don't report: can happen in read_swap_cache_async after sleeping */
+	/* printk("Unused swap offset entry in swap_dup %08lx\n", entry.val); */
 	goto out;
 }
 
@@ -1037,8 +1089,8 @@
 }
 
 /*
- * Kernel_lock protects against swap device deletion. Grab an extra
- * reference on the swaphandle so that it dos not become unused.
+ * Kernel_lock protects against swap device deletion. Don't grab an extra
+ * reference on the swaphandle, it doesn't matter if it becomes unused.
  */
 int valid_swaphandles(swp_entry_t entry, unsigned long *offset)
 {
@@ -1059,7 +1111,6 @@
 			break;
 		if (swapdev->swap_map[toff] == SWAP_MAP_BAD)
 			break;
-		swapdev->swap_map[toff]++;
 		toff++;
 		ret++;
 	} while (--i);
--- linux-2.4.9/mm/vmscan.c	Wed Aug 15 10:37:07 2001
+++ linux-swapoff/mm/vmscan.c	Thu Aug 16 22:06:26 2001
@@ -111,6 +111,7 @@
 	 * is needed on CPUs which update the accessed and dirty
 	 * bits in hardware.
 	 */
+	flush_cache_page(vma, address);
 	pte = ptep_get_and_clear(page_table);
 	flush_tlb_page(vma, address);
 
@@ -148,20 +149,13 @@
 	 * Basically, this just makes it possible for us to do
 	 * some real work in the future in "refill_inactive()".
 	 */
-	flush_cache_page(vma, address);
-	if (!pte_dirty(pte))
-		goto drop_pte;
-
-	/*
-	 * Ok, it's really dirty. That means that
-	 * we should either create a new swap cache
-	 * entry for it, or we should write it back
-	 * to its own backing store.
-	 */
 	if (page->mapping) {
-		set_page_dirty(page);
+		if (pte_dirty(pte))
+			set_page_dirty(page);
 		goto drop_pte;
 	}
+	if (!pte_dirty(pte) && !PageDirty(page))
+		goto drop_pte;
 
 	/*
 	 * This is a dirty, swappable page.  First of all,
@@ -539,8 +533,12 @@
 		 * last copy..
 		 */
 		if (PageDirty(page)) {
-			int (*writepage)(struct page *) = page->mapping->a_ops->writepage;
+			int (*writepage)(struct page *);
 
+			/* Can a page get here without page->mapping? */
+			if (!page->mapping)
+				goto page_active;
+			writepage = page->mapping->a_ops->writepage;
 			if (!writepage)
 				goto page_active;
 
@@ -779,7 +777,7 @@
 {
 	pg_data_t *pgdat;
 	unsigned int global_target = freepages.high + inactive_target;
-	unsigned int global_incative = 0;
+	unsigned int global_inactive = 0;
 
 	pgdat = pgdat_list;
 	do {
@@ -799,13 +797,13 @@
 			if (inactive < zone->pages_high)
 				return 1;
 
-			global_incative += inactive;
+			global_inactive += inactive;
 		}
 		pgdat = pgdat->node_next;
 	} while (pgdat);
 
 	/* Global shortage? */
-	return global_incative < global_target;
+	return global_inactive < global_target;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
