From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911190518.VAA92180@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm26-2.3.28 Fix MP raciness with swapcache
Date: Thu, 18 Nov 1999 21:18:26 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Linus,

This patch tries to fix multiple problems relating to SMP raciness
in code dealing with the swapcache. I prepend a little explanation
before the patches here.

1. In try_to_swap_out(), we must put the page being swapped into 
the swapcache before updating the pte with the swap entry, else
the process might quickly do a page fault, execute do_swap_page(),
and read garbage from the swap entry. Putting the page in the
swap cache ensures that do_swap_page() will wait for the swapout
to happen, before reclaiming the page from the swapcache or reading
it back in.

2. The sparc code missed some locking against the page stealing code.

3. lookup_swap_cache() can race with shrink_mmap() deleting a page from
the swapcache (ie as soon as shrink_mmap drops pagecache_lock before
doing __delete_from_swap_cache, a lookup_swap_cache can grab a reference
on the page in the swap cache, then shrink_mmap() unlocks the page, and
lookup_swap_cache locks the page, erroneously assuming the page is still
in the scache). This same race is present in lookup_swap_cache() with
try_to_unuse:delete_from_swap_cache(). To be sure, lookup_swap_cache() 
has to make sure the page is in the swapcache, else re search the cache.

4. free_page_and_swap_cache() is called with spinlock page_table_lock
held, and tries to do a lock_page, which might put it to sleep. This 
should really be a TryLock.

5. The rest of the changes are to handle raciness in deleting pages from 
the swapcache. Basically, the logic in do_wp_page and do_swap_page to 
decide whether a page can be removed from the scache is racy.
In effect, this code reads the page count, then the swap count, to decide
whether the page is "shared": unfortunately, other processes can shift 
their references from the swap count to the page count during this
computation. Ie, there is no atomic picture of the page count + swap count.
The patch makes this computation atomic by protecting this with the page
lock. Here's an example of how do_wp_page is racy (a similar example
can be applied to do_swap_page), I don't _think_ there is anything 
preventing this.

A        switch (page_count(old_page)) {
B        case 2:
C                if (!PageSwapCache(old_page))
D                        break;
E                if (swap_count(old_page) != 1)
F                        break;
H                delete_from_swap_cache(old_page);

T1 and T2 sharing a page P (count 2, T1 + T2). T1 is at B.
T2 forks T3, page count on P is 3.
kswapd steals from T3, page count on P is 3 (T1 + T2 + swapcache), P's
        swap count is 2 (T3 + swapcache)
T1 executes C, moves on to E.
T3 exits, page count on P is 3, P's swap count is 1 (swapcache)
T1 goes ahead and steals the page for itself, T2 is still using it.

Please let me know if the fixes look good. If so, I would like to move
on to fixing the swap space deletion code, it is quite racy too.

Thanks.

Kanoj

--- /usr/tmp/p_rdiff_a002VG/locking	Thu Nov 18 20:48:11 1999
+++ Documentation/vm/locking	Thu Nov 18 19:36:49 1999
@@ -75,8 +75,12 @@
 The vmlist lock nests with the inode i_shared_lock and the kmem cache
 c_spinlock spinlocks. This is okay, since code that holds i_shared_lock 
 never asks for memory, and the kmem code asks for pages after dropping
-c_spinlock.
+c_spinlock. The vmlist lock also nests with pagecache_lock and 
+pagemap_lru_lock spinlocks, and no code asks for memory with these locks
+held.
 
+The vmlist lock is grabbed while holding the kernel_lock spinning monitor.
+
 The vmlist lock can be a sleeping or spin lock. In either case, care
 must be taken that it is not held on entry to the driver methods, since
 those methods might sleep or ask for memory, causing deadlocks.
@@ -85,3 +89,49 @@
 which is also the spinlock that page stealers use to protect changes to
 the victim process' ptes. Thus we have a reduction in the total number
 of locks. 
+
+Swap cache locking
+------------------
+Pages are added into the swap cache with kernel_lock held, to make sure
+that multiple pages are not being added (and hence lost) by associating
+all of them with the same swaphandle.
+
+Pages are deleted from the swapcache with the page locked. Pages are
+guaranteed not to be removed from the scache if the page is "shared":
+ie, other processes hold reference on the page or the associated swap
+handle. The only code that breaks this rule is swap cache deletion, other
+code has to carefully work around this.
+
+When a page is being deleted from the swap cache, the order of events is:
+        1A. Page is locked.
+        2A. Page is deleted from lru cache (shrink_mmap can not find it).
+        3A. Page flags is updated to clear PG_swap_cache.
+        4A. Page is removed from swap cache.
+When a page is being looked up in the swap cache, the order of events is:
+        1B. Page is searched in the swap cache.
+        2B. Page is locked.
+        3B. Page flags is checked for PG_swap_cache.
+When a page is reclaimed by shrink_mmap, the order of events is:
+        1C. Page is removed from the lru cache.
+        2C. Page is locked or put back into a list and forgotten.
+        3C. Page is verified to have only references from swapcache.
+        4C. Page is deleted from swap cache.
+        4C. Page is freed.
+
+The rules are:
+1. The page must be removed from the swapcache while it is locked. This
+includes clearing the PG_swap_cache and taking it out from the swap Q.
+2. lookup_swap_cache looks up a page in the swap Q, and returns it locked.
+The page can not be deleted from the swap Q till the page lock is released.
+3. Synchronous read swap cache returns a locked page in the swap cache,
+which can not be deleted till the lock is dropped.
+4. Whenever a new page is added into the swapcache for a specific swap
+handle, the kernel_lock is held to ensure that more than one page is not
+added in corresponding to a single handle.
+5. If a page is in the swapcache, and there is a reference on either the
+page or the swaphandle from a process/kernel, the page is guaranteed to
+stay in the swapcache (except swap cache deletion code).
+6. If a swap cache page is locked, that means that someone is either
+doing swapin/swapout to the page, or wants to grab a reference to the
+page or delete it from the swapcache.
+
--- /usr/tmp/p_rdiff_a002VY/generic.c	Thu Nov 18 20:48:37 1999
+++ arch/sparc/mm/generic.c	Thu Nov 18 19:41:18 1999
@@ -91,7 +91,9 @@
 		pte_t * pte = pte_alloc(pmd, address);
 		if (!pte)
 			return -ENOMEM;
+		spin_lock(&current->mm->page_table_lock);
 		io_remap_pte_range(pte, address, end - address, address + offset, prot, space);
+		spin_unlock(&current->mm->page_table_lock);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address < end);
--- /usr/tmp/p_rdiff_a002Vf/generic.c	Thu Nov 18 20:48:44 1999
+++ arch/sparc64/mm/generic.c	Thu Nov 18 19:42:38 1999
@@ -127,7 +127,9 @@
 		pte_t * pte = pte_alloc(pmd, address);
 		if (!pte)
 			return -ENOMEM;
+		spin_lock(&current->mm->page_table_lock);
 		io_remap_pte_range(pte, address, end - address, address + offset, prot, space);
+		spin_unlock(&current->mm->page_table_lock);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address < end);
--- /usr/tmp/p_rdiff_a002Vo/memory.c	Thu Nov 18 20:48:53 1999
+++ mm/memory.c	Thu Nov 18 14:44:27 1999
@@ -790,10 +790,19 @@
 	 */
 	switch (page_count(old_page)) {
 	case 2:
-		if (!PageSwapCache(old_page))
+		/*
+		 * Lock the page so that no one can look it up from
+		 * the swap cache, grab a reference and start using it.
+		 * Page first verified to be in the swap cache, and 
+		 * our ref count on it defines it as a shared page, so 
+		 * it is guaranteed to stay in the swap cache.
+		 */
+		if (!PageSwapCache(old_page) || TryLockPage(old_page))
 			break;
-		if (swap_count(old_page) != 1)
+		if (is_page_shared(old_page)) {
+			UnlockPage(old_page);
 			break;
+		}
 		delete_from_swap_cache(old_page);
 		/* FallThrough */
 	case 1:
@@ -1009,7 +1018,8 @@
 		page = replace_with_highmem(page);
 		pte = mk_pte(page, vma->vm_page_prot);
 		pte = pte_mkwrite(pte_mkdirty(pte));
-	}
+	} else
+		UnlockPage(page);
 	set_pte(page_table, pte);
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
--- /usr/tmp/p_rdiff_a002Vy/swap_state.c	Thu Nov 18 20:49:01 1999
+++ mm/swap_state.c	Thu Nov 18 14:44:18 1999
@@ -160,6 +160,9 @@
 {
 	swp_entry_t entry;
 
+	if (!PageLocked(page))
+		PAGE_BUG(page);
+
 	entry.val = page->index;
 
 #ifdef SWAP_CACHE_INFO
@@ -185,8 +188,6 @@
  */
 void delete_from_swap_cache(struct page *page)
 {
-	lock_page(page);
-
 	delete_from_swap_cache_nolock(page);
 
 	UnlockPage(page);
@@ -201,14 +202,15 @@
 void free_page_and_swap_cache(struct page *page)
 {
 	/* 
-	 * If we are the only user, then free up the swap cache. 
+	 * If we are the only user, then try to free up the swap cache. 
 	 */
-	lock_page(page);
-	if (PageSwapCache(page) && !is_page_shared(page)) {
-		delete_from_swap_cache_nolock(page);
-		page_cache_release(page);
+	if (PageSwapCache(page) && !TryLockPage(page)) {
+		if (!is_page_shared(page)) {
+			delete_from_swap_cache_nolock(page);
+			page_cache_release(page);
+		}
+		UnlockPage(page);
 	}
-	UnlockPage(page);
 	
 	clear_bit(PG_swap_entry, &page->flags);
 
@@ -234,15 +236,28 @@
 		/*
 		 * Right now the pagecache is 32-bit only.  But it's a 32 bit index. =)
 		 */
+repeat:
 		found = find_lock_page(&swapper_space, entry.val);
 		if (!found)
 			return 0;
-		if (found->mapping != &swapper_space || !PageSwapCache(found))
+		/*
+		 * Though the "found" page was in the swap cache an instant
+		 * earlier, it might have been removed by do_swap_page etc. 
+		 * Re search ... Since find_lock_page grabs a reference on
+		 * the page, it can not be reused for anything else, namely
+		 * it can not be associated with another swaphandle, so it
+		 * is enough to check whether the page is still in the scache.
+		 */
+		if (!PageSwapCache(found)) {
+			UnlockPage(found);
+			__free_page(found);
+			goto repeat;
+		}
+		if (found->mapping != &swapper_space)
 			goto out_bad;
 #ifdef SWAP_CACHE_INFO
 		swap_cache_find_success++;
 #endif
-		UnlockPage(found);
 		return found;
 	}
 
@@ -295,6 +310,15 @@
 	 */
 	add_to_swap_cache(new_page, entry);
 	rw_swap_page(READ, new_page, wait);
+	if (wait) {
+		/*
+		 * Our swap/page ref count implies the page can not go
+		 * out of the swapcache. Except for swap deletion - in
+		 * which case, the caller has to check whether it wants
+		 * to use this page at all, freeing it up if not.
+		 */
+		lock_page(new_page);
+	}
 	return new_page;
 
 out_free_page:
@@ -302,5 +326,6 @@
 out_free_swap:
 	swap_free(entry);
 out:
+	if (!wait) UnlockPage(found_page);
 	return found_page;
 }
--- /usr/tmp/p_rdiff_a002W7/vmscan.c	Thu Nov 18 20:49:09 1999
+++ mm/vmscan.c	Thu Nov 18 14:44:11 1999
@@ -158,15 +158,15 @@
 	if (!(page = prepare_highmem_swapout(page)))
 		goto out_swap_free;
 
-	vma->vm_mm->rss--;
-	set_pte(page_table, swp_entry_to_pte(entry));
-	vmlist_access_unlock(vma->vm_mm);
-
-	flush_tlb_page(vma, address);
 	swap_duplicate(entry);	/* One for the process, one for the swap cache */
 
 	/* This will also lock the page */
 	add_to_swap_cache(page, entry);
+	/* Put the swap entry into the pte after the page is in swapcache */
+	vma->vm_mm->rss--;
+	set_pte(page_table, swp_entry_to_pte(entry));
+	flush_tlb_page(vma, address);
+	vmlist_access_unlock(vma->vm_mm);
 
 	/* OK, do a physical asynchronous write to swap.  */
 	rw_swap_page(WRITE, page, 0);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
