Date: Sat, 8 Apr 2000 19:39:15 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004081520410.559-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0004081924010.317-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2000, Andrea Arcangeli wrote:

>I've a patch for this too now. Are you using read_swap_cache from any

Here is my approch. I tried to explain the subtle thoughts in the
comments. It's against 2.3.99-pre4-4 + swap-entry fix previously posted on
the list in mail with Message-ID:
<Pine.LNX.4.21.0004071205300.737-100000@alpha.random>. It seems stable
here.

The only minor weird thing I noticed so far after the swapoff+swapin
stress testing is this:

	[..]
	Swap cache: add 107029, delete 105331, find 34046/62876
	[..]
	0 pages swap cached
	[..]

but that's explained by the fact the stat infomation aren't increased with
atomic_inc() (if we really want perfect stat info we should split the
counter in a per-CPU counter and sum all the per-CPU counters to get the
info)

diff -urN swap-entry-1/include/linux/pagemap.h swap-entry-2/include/linux/pagemap.h
--- swap-entry-1/include/linux/pagemap.h	Fri Apr  7 18:16:10 2000
+++ swap-entry-2/include/linux/pagemap.h	Sat Apr  8 19:16:28 2000
@@ -80,6 +80,9 @@
 extern void __add_page_to_hash_queue(struct page * page, struct page **p);
 
 extern void add_to_page_cache(struct page * page, struct address_space *mapping, unsigned long index);
+extern int __add_to_page_cache_unique(struct page *, struct address_space *, unsigned long, struct page **);
+#define add_to_page_cache_unique(page, mapping, index) \
+		__add_to_page_cache_unique(page, mapping, index, page_hash(mapping, index))
 
 extern inline void add_page_to_hash_queue(struct page * page, struct inode * inode, unsigned long index)
 {
diff -urN swap-entry-1/include/linux/swap.h swap-entry-2/include/linux/swap.h
--- swap-entry-1/include/linux/swap.h	Fri Apr  7 02:00:28 2000
+++ swap-entry-2/include/linux/swap.h	Sat Apr  8 18:08:37 2000
@@ -95,15 +95,17 @@
 
 /* linux/mm/swap_state.c */
 extern void show_swap_cache_info(void);
-extern void add_to_swap_cache(struct page *, swp_entry_t);
+extern int add_to_swap_cache_unique(struct page *, swp_entry_t);
 extern int swap_check_entry(unsigned long);
-extern struct page * lookup_swap_cache(swp_entry_t);
+extern struct page * find_get_swap_cache(swp_entry_t);
+extern struct page * find_lock_swap_cache(swp_entry_t);
 extern struct page * read_swap_cache_async(swp_entry_t, int);
 #define read_swap_cache(entry) read_swap_cache_async(entry, 1);
 
 /*
  * Make these inline later once they are working properly.
  */
+extern void unlink_from_swap_cache(struct page *);
 extern void __delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache_nolock(struct page *page);
diff -urN swap-entry-1/ipc/shm.c swap-entry-2/ipc/shm.c
--- swap-entry-1/ipc/shm.c	Fri Apr  7 18:11:37 2000
+++ swap-entry-2/ipc/shm.c	Sat Apr  8 04:15:20 2000
@@ -1334,7 +1334,7 @@
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
 			shm_unlock(shp->id);
-			page = lookup_swap_cache(entry);
+			page = find_get_swap_cache(entry);
 			if (!page) {
 				lock_kernel();
 				swapin_readahead(entry);
@@ -1416,7 +1416,8 @@
 	   reading a not yet uptodate block from disk.
 	   NOTE: we just accounted the swap space reference for this
 	   swap cache page at __get_swap_page() time. */
-	add_to_swap_cache(*outpage = page_map, swap_entry);
+	if (add_to_swap_cache_unique(*outpage = page_map, swap_entry))
+		BUG();
 	return OKAY;
 }
 
diff -urN swap-entry-1/mm/filemap.c swap-entry-2/mm/filemap.c
--- swap-entry-1/mm/filemap.c	Fri Apr  7 18:27:22 2000
+++ swap-entry-2/mm/filemap.c	Sat Apr  8 04:46:04 2000
@@ -488,7 +488,7 @@
 	spin_unlock(&pagecache_lock);
 }
 
-static int add_to_page_cache_unique(struct page * page,
+int __add_to_page_cache_unique(struct page * page,
 	struct address_space *mapping, unsigned long offset,
 	struct page **hash)
 {
@@ -529,7 +529,7 @@
 	if (!page)
 		return -ENOMEM;
 
-	if (!add_to_page_cache_unique(page, mapping, offset, hash)) {
+	if (!__add_to_page_cache_unique(page, mapping, offset, hash)) {
 		int error = mapping->a_ops->readpage(file->f_dentry, page);
 		page_cache_release(page);
 		return error;
@@ -2291,7 +2291,7 @@
 				return ERR_PTR(-ENOMEM);
 		}
 		page = cached_page;
-		if (add_to_page_cache_unique(page, mapping, index, hash))
+		if (__add_to_page_cache_unique(page, mapping, index, hash))
 			goto repeat;
 		cached_page = NULL;
 		err = filler(data, page);
@@ -2318,7 +2318,7 @@
 				return NULL;
 		}
 		page = *cached_page;
-		if (add_to_page_cache_unique(page, mapping, index, hash))
+		if (__add_to_page_cache_unique(page, mapping, index, hash))
 			goto repeat;
 		*cached_page = NULL;
 	}
diff -urN swap-entry-1/mm/memory.c swap-entry-2/mm/memory.c
--- swap-entry-1/mm/memory.c	Fri Apr  7 18:27:22 2000
+++ swap-entry-2/mm/memory.c	Sat Apr  8 19:08:16 2000
@@ -217,7 +217,8 @@
 				if (pte_none(pte))
 					goto cont_copy_pte_range;
 				if (!pte_present(pte)) {
-					swap_duplicate(pte_to_swp_entry(pte));
+					if (!swap_duplicate(pte_to_swp_entry(pte)))
+						BUG();
 					set_pte(dst_pte, pte);
 					goto cont_copy_pte_range;
 				}
@@ -1019,47 +1020,120 @@
 void swapin_readahead(swp_entry_t entry)
 {
 	int i, num;
-	struct page *new_page;
+	struct page * page = NULL;
 	unsigned long offset;
+	swp_entry_t __entry;
 
 	/*
 	 * Get the number of handles we should do readahead io to. Also,
 	 * grab temporary references on them, releasing them as io completes.
+	 *
+	 * At this point we only know the swap device can't go away from under
+	 * us because of the caller locking.
+	 *
+	 * Ugly: we're serializing with swapoff using the big kernel lock.
 	 */
 	num = valid_swaphandles(entry, &offset);
 	for (i = 0; i < num; offset++, i++) {
 		/* Don't block on I/O for read-ahead */
-		if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster) {
-			while (i++ < num)
-				swap_free(SWP_ENTRY(SWP_TYPE(entry), offset++));
+		if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster)
 			break;
-		}
 		/* Ok, do the async read-ahead now */
-		new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);
-		if (new_page != NULL)
-			__free_page(new_page);
-		swap_free(SWP_ENTRY(SWP_TYPE(entry), offset));
+		if (!page) {
+			page = alloc_page(GFP_USER);
+			if (!page)
+				return;
+		}
+		__entry = SWP_ENTRY(SWP_TYPE(entry), offset);
+		if (add_to_swap_cache_unique(page, __entry))
+			continue;
+		if (!swap_duplicate(__entry)) {
+			swap_free(__entry);
+			unlink_from_swap_cache(page);
+			UnlockPage(page);
+			continue;
+		}
+		rw_swap_page(READ, page, 0);
+		__free_page(page);
+		page = NULL;
 	}
+	if (page)
+		__free_page(page);
 	return;
 }
 
+#define pte_changed(page_table, entry) \
+	(pte_val(*page_table) != pte_val(swp_entry_to_pte(entry)))
+
+/* This is lock-land */
 static int do_swap_page(struct task_struct * tsk,
 	struct vm_area_struct * vma, unsigned long address,
 	pte_t * page_table, swp_entry_t entry, int write_access)
 {
-	struct page *page = lookup_swap_cache(entry);
+	struct page *page;
 	pte_t pte;
+	spinlock_t * page_table_lock = &vma->vm_mm->page_table_lock;
 
+	/*
+	 * find_lock_swap_cache() can return a non swap cache page
+	 * (because find_lock_page() acquires the lock after
+	 * dropping the page_cache_lock).
+	 * We handle the coherency with unmap_process later
+	 * while checking if the pagetable is changed from
+	 * under us. If the pagetable isn't changed from
+	 * under us then `page' is a swap cache page.
+	 */
+ repeat:
+	page = find_lock_swap_cache(entry);
 	if (!page) {
+		page = alloc_page(GFP_USER);
+		if (!page)
+			return -1;
+
+		if (add_to_swap_cache_unique(page, entry)) {
+			__free_page(page);
+			goto repeat;
+		}
+
+		spin_lock(page_table_lock);
+		/*
+		 * If the pte is changed and we added the page to
+		 * the swap cache successfully it means the entry
+		 * is gone away and also the swap device is
+		 * potentially gone away.
+		 */
+		if (pte_changed(page_table, entry))
+			goto unlink;
+		spin_unlock(page_table_lock);
+
+		/*
+		 * Account the swap cache reference on the swap
+		 * side. We have the swap entry locked via
+		 * swap cache locking protocol described below.
+		 * If the entry gone away it means something
+		 * gone badly wrong...
+		 */
+		if (!swap_duplicate(entry))
+			BUG();
+
+		/*
+		 * At this point we know unuse_process() have
+		 * not yet processed this pte and we also hold
+		 * the lock on the page so unuse_process() will
+		 * wait for us to finish the I/O. This way we are
+		 * sure to do I/O from a still SWP_USED swap device
+		 * and that the swap device won't go away while
+		 * we're waiting I/O completation.
+		 */
 		lock_kernel();
 		swapin_readahead(entry);
-		page = read_swap_cache(entry);
+		rw_swap_page(READ, page, 1);
 		unlock_kernel();
-		if (!page)
-			return -1;
 
 		flush_page_to_ram(page);
 		flush_icache_page(vma, page);
+
+		lock_page(page);
 	}
 
 	vma->vm_mm->rss++;
@@ -1067,6 +1141,10 @@
 
 	pte = mk_pte(page, vma->vm_page_prot);
 
+	spin_lock(page_table_lock);
+	if (pte_changed(page_table, entry))
+		goto unlock;
+
 	SetPageSwapEntry(page);
 
 	/*
@@ -1074,7 +1152,6 @@
 	 * Must lock page before transferring our swap count to already
 	 * obtained page count.
 	 */
-	lock_page(page);
 	swap_free(entry);
 	if (write_access && !is_page_shared(page)) {
 		delete_from_swap_cache_nolock(page);
@@ -1086,10 +1163,31 @@
 		UnlockPage(page);
 
 	set_pte(page_table, pte);
+	spin_unlock(page_table_lock);
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
 	return 1;
+
+ unlink:
+	spin_unlock(page_table_lock);
+	unlink_from_swap_cache(page);
+	UnlockPage(page);
+	__free_page(page);
+	return 1;
+
+ unlock:
+	/*
+	 * If the page is still in the swap cache it
+	 * will be swapoff that will remove it from there
+	 * later.
+	 */
+	spin_unlock(page_table_lock);
+	UnlockPage(page);
+	__free_page(page);
+	return 1;
 }
+
+#undef pte_changed
 
 /*
  * This only needs the MM semaphore
diff -urN swap-entry-1/mm/page_io.c swap-entry-2/mm/page_io.c
--- swap-entry-1/mm/page_io.c	Wed Dec  8 00:05:28 1999
+++ swap-entry-2/mm/page_io.c	Sat Apr  8 02:49:51 2000
@@ -128,8 +128,9 @@
 {
 	struct page *page = mem_map + MAP_NR(buf);
 	
-	if (!PageLocked(page))
+	if (PageLocked(page))
 		PAGE_BUG(page);
+	lock_page(page);
 	if (PageSwapCache(page))
 		PAGE_BUG(page);
 	if (!rw_swap_page_base(rw, entry, page, wait))
diff -urN swap-entry-1/mm/swap_state.c swap-entry-2/mm/swap_state.c
--- swap-entry-1/mm/swap_state.c	Fri Apr  7 18:27:22 2000
+++ swap-entry-2/mm/swap_state.c	Sat Apr  8 17:29:46 2000
@@ -40,16 +40,19 @@
 }
 #endif
 
-void add_to_swap_cache(struct page *page, swp_entry_t entry)
+int add_to_swap_cache_unique(struct page * page, swp_entry_t entry)
 {
+	int ret;
+
 #ifdef SWAP_CACHE_INFO
 	swap_cache_add_total++;
 #endif
-	if (PageTestandSetSwapCache(page))
-		BUG();
 	if (page->mapping)
 		BUG();
-	add_to_page_cache(page, &swapper_space, entry.val);
+	ret = add_to_page_cache_unique(page, &swapper_space, entry.val);
+	if (!ret && PageTestandSetSwapCache(page))
+		BUG();
+	return ret;
 }
 
 static inline void remove_from_swap_cache(struct page *page)
@@ -65,6 +68,16 @@
 	remove_inode_page(page);
 }
 
+void unlink_from_swap_cache(struct page * page)
+{
+#ifdef SWAP_CACHE_INFO
+	swap_cache_del_total++;
+#endif
+	lru_cache_del(page);
+	remove_from_swap_cache(page);
+	__free_page(page);
+}
+
 /*
  * This must be called only on pages that have
  * been verified to be in the swap cache.
@@ -95,7 +108,7 @@
 		lru_cache_del(page);
 
 	__delete_from_swap_cache(page);
-	page_cache_release(page);
+	__free_page(page);
 }
 
 /*
@@ -144,45 +157,53 @@
  * lock before returning.
  */
 
-struct page * lookup_swap_cache(swp_entry_t entry)
+struct page * find_get_swap_cache(swp_entry_t entry)
 {
 	struct page *found;
 
 #ifdef SWAP_CACHE_INFO
 	swap_cache_find_total++;
 #endif
-	while (1) {
-		/*
-		 * Right now the pagecache is 32-bit only.  But it's a 32 bit index. =)
-		 */
-repeat:
-		found = find_get_page(&swapper_space, entry.val);
-		if (!found)
-			return 0;
-		/*
-		 * Though the "found" page was in the swap cache an instant
-		 * earlier, it might have been removed by shrink_mmap etc.
-		 * Re search ... Since find_lock_page grabs a reference on
-		 * the page, it can not be reused for anything else, namely
-		 * it can not be associated with another swaphandle, so it
-		 * is enough to check whether the page is still in the scache.
-		 */
-		if (!PageSwapCache(found)) {
-			__free_page(found);
-			goto repeat;
-		}
-		if (found->mapping != &swapper_space)
-			goto out_bad;
+
+	found = find_get_page(&swapper_space, entry.val);
+	if (!found)
+		return NULL;
+	if (found->mapping != &swapper_space)
+		goto out_bad;
 #ifdef SWAP_CACHE_INFO
-		swap_cache_find_success++;
+	swap_cache_find_success++;
 #endif
-		return found;
-	}
+	return found;
 
 out_bad:
 	printk (KERN_ERR "VM: Found a non-swapper swap page!\n");
 	__free_page(found);
-	return 0;
+	return NULL;
+}
+
+struct page * find_lock_swap_cache(swp_entry_t entry)
+{
+	struct page *found;
+
+#ifdef SWAP_CACHE_INFO
+	swap_cache_find_total++;
+#endif
+
+	found = find_lock_page(&swapper_space, entry.val);
+	if (!found)
+		return NULL;
+	if (found->mapping != &swapper_space)
+		goto out_bad;
+#ifdef SWAP_CACHE_INFO
+	swap_cache_find_success++;
+#endif
+	return found;
+
+out_bad:
+	printk (KERN_ERR "VM: Found a non-swapper locked swap page!\n");
+	UnlockPage(found);
+	__free_page(found);
+	return NULL;
 }
 
 /* 
@@ -192,47 +213,40 @@
  *
  * A failure return means that either the page allocation failed or that
  * the swap entry is no longer in use.
+ * WARNING: only swapoff can use this function.
  */
 
 struct page * read_swap_cache_async(swp_entry_t entry, int wait)
 {
 	struct page *found_page = 0, *new_page;
-	unsigned long new_page_addr;
-	
-	/*
-	 * Make sure the swap entry is still in use.
-	 */
-	if (!swap_duplicate(entry))	/* Account for the swap cache */
-		goto out;
+
 	/*
 	 * Look for the page in the swap cache.
 	 */
-	found_page = lookup_swap_cache(entry);
+	found_page = find_get_swap_cache(entry);
 	if (found_page)
-		goto out_free_swap;
+		goto out;
 
-	new_page_addr = __get_free_page(GFP_USER);
-	if (!new_page_addr)
-		goto out_free_swap;	/* Out of memory */
-	new_page = mem_map + MAP_NR(new_page_addr);
+	new_page = alloc_page(GFP_USER);
+	if (!new_page)
+		goto out;	/* Out of memory */
 
-	/*
-	 * Check the swap cache again, in case we stalled above.
-	 */
-	found_page = lookup_swap_cache(entry);
-	if (found_page)
-		goto out_free_page;
 	/* 
 	 * Add it to the swap cache and read its contents.
 	 */
-	add_to_swap_cache(new_page, entry);
+	while (add_to_swap_cache_unique(new_page, entry)) {
+		found_page = find_get_swap_cache(entry);
+		if (found_page)
+			goto out_free_page;
+	}
+
+	swap_duplicate(entry);
+
 	rw_swap_page(READ, new_page, wait);
 	return new_page;
 
 out_free_page:
 	__free_page(new_page);
-out_free_swap:
-	swap_free(entry);
 out:
 	return found_page;
 }
diff -urN swap-entry-1/mm/swapfile.c swap-entry-2/mm/swapfile.c
--- swap-entry-1/mm/swapfile.c	Fri Apr  7 18:27:22 2000
+++ swap-entry-2/mm/swapfile.c	Sat Apr  8 19:02:20 2000
@@ -437,17 +437,38 @@
 			swap_free(entry);
   			return -ENOMEM;
 		}
+
+		lock_page(page);
+		/*
+		 * Only swapout can drop referenced pages from
+		 * the swap cache.
+		 */
+		if (!PageSwapCache(page))
+			BUG();
+		/*
+		 * Do a fast check to see if it's an orphaned swap cache
+		 * entry to learn if we really need to slowly browse the ptes.
+		 */
+		if (!is_page_shared(page))
+			goto orphaned;
+		UnlockPage(page);
+
 		read_lock(&tasklist_lock);
 		for_each_task(p)
 			unuse_process(p->mm, entry, page);
 		read_unlock(&tasklist_lock);
 		shm_unuse(entry, page);
+
+		lock_page(page);
 		/* Now get rid of the extra reference to the temporary
                    page we've been using. */
-		if (PageSwapCache(page)) {
-			delete_from_swap_cache(page);
-			ClearPageSwapEntry(page);
-		}
+		if (!PageSwapCache(page))
+			BUG();
+	orphaned:
+		delete_from_swap_cache_nolock(page);
+		ClearPageSwapEntry(page);
+
+		UnlockPage(page);
 		__free_page(page);
 		/*
 		 * Check for and clear any overflowed swap map counts.
@@ -710,7 +731,6 @@
 		goto bad_swap;
 	}
 
-	lock_page(mem_map + MAP_NR(swap_header));
 	rw_swap_page_nolock(READ, SWP_ENTRY(type,0), (char *) swap_header, 1);
 
 	if (!memcmp("SWAP-SPACE",swap_header->magic.magic,10))
@@ -902,22 +922,19 @@
 	offset = SWP_OFFSET(entry);
 	if (offset >= p->max)
 		goto bad_offset;
-	if (!p->swap_map[offset])
-		goto bad_unused;
 	/*
 	 * Entry is valid, so increment the map count.
 	 */
 	swap_device_lock(p);
 	if (p->swap_map[offset] < SWAP_MAP_MAX)
-		p->swap_map[offset]++;
+		result = p->swap_map[offset]++;
 	else {
 		static int overflow = 0;
 		if (overflow++ < 5)
 			printk("VM: swap entry overflow\n");
-		p->swap_map[offset] = SWAP_MAP_MAX;
+		result = p->swap_map[offset] = SWAP_MAP_MAX;
 	}
 	swap_device_unlock(p);
-	result = 1;
 out:
 	return result;
 
@@ -927,9 +944,6 @@
 bad_offset:
 	printk("Bad swap offset entry %08lx\n", entry.val);
 	goto out;
-bad_unused:
-	printk("Unused swap offset entry in swap_dup %08lx\n", entry.val);
-	goto out;
 }
 
 /*
@@ -1027,20 +1041,22 @@
 	*offset = SWP_OFFSET(entry);
 	toff = *offset = (*offset >> page_cluster) << page_cluster;
 
+	if ((swapdev->flags & SWP_WRITEOK) != SWP_WRITEOK)
+		goto out;
 	swap_device_lock(swapdev);
 	do {
 		/* Don't read-ahead past the end of the swap area */
 		if (toff >= swapdev->max)
 			break;
-		/* Don't read in bad or busy pages */
+		/* Don't read in bad or empty pages */
 		if (!swapdev->swap_map[toff])
 			break;
 		if (swapdev->swap_map[toff] == SWAP_MAP_BAD)
 			break;
-		swapdev->swap_map[toff]++;
 		toff++;
 		ret++;
 	} while (--i);
 	swap_device_unlock(swapdev);
+ out:
 	return ret;
 }
diff -urN swap-entry-1/mm/vmscan.c swap-entry-2/mm/vmscan.c
--- swap-entry-1/mm/vmscan.c	Thu Apr  6 01:00:52 2000
+++ swap-entry-2/mm/vmscan.c	Sat Apr  8 17:38:10 2000
@@ -72,7 +72,8 @@
 	 */
 	if (PageSwapCache(page)) {
 		entry.val = page->index;
-		swap_duplicate(entry);
+		if (!swap_duplicate(entry))
+			BUG();
 		set_pte(page_table, swp_entry_to_pte(entry));
 drop_pte:
 		vma->vm_mm->rss--;
@@ -157,10 +158,12 @@
 	if (!(page = prepare_highmem_swapout(page)))
 		goto out_swap_free;
 
-	swap_duplicate(entry);	/* One for the process, one for the swap cache */
-
+	if (!swap_duplicate(entry))	/* One for the process, one for the swap cache */
+		BUG();
 	/* This will also lock the page */
-	add_to_swap_cache(page, entry);
+	if (add_to_swap_cache_unique(page, entry))
+		BUG();
+
 	/* Put the swap entry into the pte after the page is in swapcache */
 	vma->vm_mm->rss--;
 	set_pte(page_table, swp_entry_to_pte(entry));


I have not looked into the shm_unuse part yet but I guess it needs fixing
too (however shm compiles and it should keep working as before at least).

Comments are welcome. Thanks.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
