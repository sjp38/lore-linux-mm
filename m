From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004112325.QAA34028@google.engr.sgi.com>
Subject: [PATCH] swapdeletion race fixes
Date: Tue, 11 Apr 2000 16:25:33 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andrea@suse.de, bcrl@redhat.com, riel@nl.linux.org
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a list of swap cache/devicedeletion races/problems I see in the 
pre4-5 code.

1. While forking, a parent might copy a swap handle into the child, but we
might entirely miss scanning the child because he is not on the process list
(kernel_lock is not enough, forking code might sleep).

2. Similarly, during exit, we might miss scanning a process because he has
unlinked his vma chain (kernel_lock is not enough, exit code might sleep).

3. do_swap_page() might return failure even when swapoff has replaced a
swaphandle with a in-memory page.

4. shm might delete a page from the swapcache at the same time swapoff
does the same, there needs to be some synchronization between the two.

5. do_wp_page/free_page_and_swap_cache races with swapdeletion doing 
page deletion from swap cache. Hmm, not quite ... Andrea, this is one 
reason why we need the pagelocking in lookup_swap_cache even if you 
fix shrink_mmap, ie the read_swap_cache in try_to_unuse() will wait
for the page to get unlocked.

6. Readahead swapin races with swap space deletion from two different
sources: shm and anonymous pages.

There's probably a few more, feel free to point those out to me.

Here's how the patch works. 

Basically, we first need to agree that swapoff (in theory) can grab
mmap_sem, and that page_table_lock/vmlist_lock was designed to protect
against kswapd. Grabbing mmap_sem eliminates 1, 2, 3, 5 and 6 anonymous.

We create a new list of mm structs in the system. This list is used by
swapoff to scan all the mm/pagetables. We also have a routine to establish
a hold and release a mm, so that once we drop the mm list lock, the mm 
does not vanish under us. Swapoff "crabs" this list, grabbing an mm at
a time, scanning it, then grabbing the next one before releasing the
old one. All the complexity is confined to the swapoff path. 

Why do I think this is a good long term solution? MM lists are bound to
become more important. For example, kswapd should actually use mmlists
too, else it misses scanning forked (possibly large) children being 
created. Also, the mmlist protection might be used to fix the set_pagedir
races with new mm's being created.

Patch testing has been done on pre4-5 by running constant swapoff's to
one of three swap devices, on a 4 cpu 24Mb system running make -j4 on
the kernel source. 

Once we decide whether this patch is a candidate for inclusion, I can
take a look at the shm/swapdevice deletion races. Also, I would like to
integrate in parts of Andrea's previous patch. Btw, my email response
over the next week or so will be lousy (travelling), if anyone feels
like fixing parts of this patch or updating it, feel free, and send the
new version to me. 

Kanoj


--- Documentation/vm/locking	Sat Apr  8 14:55:14 2000
+++ Documentation/vm/locking	Sat Apr  8 15:34:01 2000
@@ -126,7 +126,8 @@
 page it located is still in the swapcache, or shrink_mmap deleted it.
 (This race is due to the fact that shrink_mmap looks at the page ref
 count with pagecache_lock, but then drops pagecache_lock before deleting
-the page from the scache).
+the page from the scache). Swapoff code also takes a page off from the
+scache, even if the page is "shared".
 
 do_wp_page and do_swap_page have MP races in them while trying to figure
 out whether a page is "shared", by looking at the page_count + swap_count.
@@ -134,5 +135,114 @@
 calling is_page_shared (else processes might switch their swap_count refs
 to the page count refs, after the page count ref has been snapshotted).
 
-Swap device deletion code currently breaks all the scache assumptions,
-since it grabs neither mmap_sem nor page_table_lock.
+Note that the rules for deleting a shm page from the swap cache is
+a little different: shm_nopage deletes the page from the swapcache
+after reading it in. This only races with swapoff(), which might have
+a reference on the page. 
+
+Rules: 
+1. If you have mmap_sem, and have verified that there is a swaphandle
+in your pte, you can do most things with the swapcache, except deleting a
+"shared" page from it.
+2. If you are just checking whether a page pointed to from your pte is
+in the swap cache and doing things with it, you must hold page lock to
+guarantee the page stays in the scache (eg free_page_and_swap_cache).
+This is because swapoff might be running and trying to scache delete
+the page.
+3. Swapoff races with shm and free_page_and_swap_cache/do_wp_page, which 
+it interlocks with page_lock. Races with page fault handling, munmap etc
+are handled with mmap_sem.
+
+Special note on PageSwapCache: Most code that checks for the PG_swap_cache
+bit and takes some action are race prone. These code should hold page_lock
+to guard either page_count+swap_count, or the changing of the PageSwapCache
+bit and whether the page stays in the scache after the PageSwapCache check
+or not. Eg, is_page_shared/do_swap_page/do_wp_page holds it to protect
+swap_count+page_count. shm_nopage/try_to_unuse, do_wp_page/try_to_unuse and
+free_page_and_swap_cache/try_to_unuse hold it to protect either one of the
+pair taking the page off the scache without the other's knowledge.
+shrink_mmap is guaranteed not to race with swapoff, because it works only
+on pages that it can guarantee swapoff has not acquired a reference to, and
+holding the page_lock guarantees that swapoff can not get a reference unless
+shrink_mmap is done. The page count checking also interlocks out shm_nopage,
+do_wp_page and free_page_and_swap_cache. The page_lock interacts with
+do_swap_page to determine who gets to delete the page from the scache.
+The only code that currently does not hold page_lock while checking
+PageSwapCache is try_to_swap_out(): this code is not executed for shm pages,
+lock_kernel ensures that swapoff does not take the page out of the scache,
+vmlist_lock aka page_table_lock ensures that the victim process is not doing
+free_page_and_swap_cache or do_wp_page and taking the page out of the scache.
+
+
+mmlist locking
+--------------
+All the active mm's on the system are linked up in the mmlist. The
+list is protected by the mmlist lock, a spinning lock. 
+
+The mmlist is used currently for two purposes. Firstly, it is used 
+to provide set_pgdir() a way to visit all page directories on the
+system. All page directory allocation, freeing and set_pgdir() 
+updates are done with the mmlist lock held. Additionally, if the
+arch code wants to cache unused page directories, the mmlist lock
+can be used to provide locking while set_pgdir() is traversing the
+list of active page directories. For example, the i386 uses the
+mmlist lock to provide caching. Other architectures might want to 
+use a spinlock to guard page directory allocation, freeing and 
+set_pgdir() updates. The kernel_lock is not held in these cases in
+2.3. In such arch code, the page directory list spin lock should 
+nest with the mmlist lock. Since page directories are freed up 
+from the scheduler code sometimes, the mmlist lock can not be a
+sleeping lock (without modifying the scheduler code), and must be
+a spinning lock.
+
+The mmlist is also used to provide appropriate support to swapoff.
+
+swapoff locking
+---------------
+The mmlist is used to provide protection to swapoff(), so that
+it can visit all active mm's in the system, to rip out references
+to swap handles being deleted. This includes mm's that are being
+created via fork (but the child process is still not on the active
+task list), and also that are being torn down via exit_mmap. kernel_lock
+is not sufficient in these two cases because both fork and exit can 
+sleep. Also munmap is called without kernel_lock.
+
+The swapoff code visits all the mm's on the active list. It grabs 
+references to the mm's on which it can guarantee that the mm 
+destruction code is not advanced enough to ignore this hold. For
+this, it uses mark_nonholdable. Note that currently the MM_GONE
+flag is updated and checked with kernel_lock protection, but can 
+be enhanced to be done with vmlist_lock protection.
+
+Swapoff then visits each mm that it has an existential guarantee
+on, grabbing the mmap_sem. This single threads swapoff against
+concurrent swap handle access via page faults, exitting, mmaping,
+munmapping, and forking, all of which grab or release references
+on swap handles. Swapoff is already protected against vmscan by
+virtue of kernel_lock. To make sure that swapoff gets to visit 
+child mm's that are being created, all new mm's are put on the list
+at the tail. Thus, it is guaranteed that swapoff either visits the
+parent and cleans up the swap references first, or the parent runs, 
+creates the child mm, putting it after its own mm, so that swapoff
+can inspect the child after inspecting the parent.
+
+Note that sync/async swapins that happen from page faulting is
+serialized against swapoff by virtue of the fact that swapoff
+holds the mmap_sem, and swapins put the page into the swapcache
+after locking it, so that swapoff() will wait for the swapin to
+complete and the page lock to be relesed before its read_swap_cache()
+will return.
+
+To prevent races in the swapoff code turning off references to the
+swap handles, and other code re-establishing references, all readaheads
+are stopped on swap devices being deleted. Also, the page stealing
+code is not allowed to grab a reference on handles that are being 
+deleted.
+
+swapoff() also races with shm_nopage(), which deletes pages from the
+swap cache after it has read in the contents. So, while swapoff is
+releasing its reference on the page, it takes care not to re-delete
+the page from the swapcache if shm code has already done that. One
+race that has still not been fixed is shm_nopage trying to page in
+the swaphandle, when swapoff has already paged it in. We need a 
+sleeping lock in the shm code to handle this.
--- arch/m68k/atari/stram.c	Sat Apr  8 14:55:16 2000
+++ arch/m68k/atari/stram.c	Sat Apr  8 15:34:01 2000
@@ -794,20 +794,20 @@
 	}
 }
 
-static void unswap_process(struct mm_struct * mm, unsigned long entry, 
+static void unswap_mm(struct mm_struct * mm, unsigned long entry, 
 			   unsigned long page /* , int isswap */)
 {
 	struct vm_area_struct* vma;
 
 	/*
-	 * Go through process' page directory.
+	 * Go through mm's page directory.
 	 */
-	if (!mm)
-		return;
+	down(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		pgd_t * pgd = pgd_offset(mm, vma->vm_start);
 		unswap_vma(vma, pgd, entry, page /* , isswap */);
 	}
+	up(&mm->mmap_sem);
 }
 
 
@@ -906,9 +906,9 @@
 static int unswap_by_read(unsigned short *map, unsigned long max,
 			  unsigned long start, unsigned long n_pages)
 {
-	struct task_struct *p;
 	unsigned long entry, page;
 	unsigned long i;
+	struct mm_struct *curmm, *prevmm;
 	struct page *page_map;
 
 	DPRINTK( "unswapping %lu..%lu by reading in\n",
@@ -935,16 +935,30 @@
 			page_map = read_swap_cache(entry);
 			if (page_map) {
 				page = page_address(page_map);
-				read_lock(&tasklist_lock);
-				for_each_task(p)
-					unswap_process(p->mm, entry, page
-						       /* , 0 */);
-				read_unlock(&tasklist_lock);
 				shm_unuse(entry, page);
+				mmlist_access_lock();
+				prevmm = &init_mm;
+				curmm = list_entry(prevmm->mmlist.next, struct mm_struct, mmlist);
+				lock_kernel(); /* for hold_mm */
+				while (curmm != &init_mm) {
+					if (hold_mm(curmm)) {
+						mmlist_access_unlock();
+						if (prevmm != &init_mm) release_mm(prevmm);
+						unswap_mm(curmm, entry, page);
+						prevmm = curmm;
+						mmlist_access_lock();
+					}
+					curmm = list_entry(curmm->mmlist.next, struct mm_struct, mmlist);
+				}
+				unlock_kernel();
+				mmlist_access_unlock();
+				if (prevmm != &init_mm) release_mm(prevmm);
 				/* Now get rid of the extra reference to
 				   the temporary page we've been using. */
+				lock_page(page_map);
 				if (PageSwapCache(page_map))
-					delete_from_swap_cache(page_map);
+					delete_from_swap_cache_nolock(page_map);
+				UnlockPage(page_map);
 				__free_page(page_map);
 	#ifdef DO_PROC
 				stat_swap_force++;
--- include/linux/mm.h	Mon Apr 10 19:33:41 2000
+++ include/linux/mm.h	Tue Apr 11 13:13:29 2000
@@ -541,6 +541,23 @@
 #define vmlist_modify_lock(mm)		vmlist_access_lock(mm)
 #define vmlist_modify_unlock(mm)	vmlist_access_unlock(mm)
 
+extern spinlock_t mm_lock;
+#define mmlist_access_lock()		spin_lock(&mm_lock)
+#define mmlist_access_unlock()		spin_unlock(&mm_lock)
+#define mmlist_modify_lock()		mmlist_access_lock()
+#define mmlist_modify_unlock()		mmlist_access_unlock()
+
+/*
+ * The foll few macros depend on kernel_lock but can be converted to
+ * use vmlist_lock. hold_mm returns 1 if it can guarantee existance
+ * of the mm till caller does release_mm.
+ */
+#define	MM_GONE		1
+#define mark_nonholdable(mm)		(mm)->def_flags |= MM_GONE;
+#define hold_mm(mm)			(((mm)->def_flags & MM_GONE) ? 0 : \
+						((atomic_inc(&(mm)->mm_count)), 1))
+#define release_mm(mm)			mmdrop(mm)
+
 #endif /* __KERNEL__ */
 
 #endif
--- include/linux/sched.h	Mon Apr 10 19:33:41 2000
+++ include/linux/sched.h	Tue Apr 11 13:13:29 2000
@@ -219,6 +219,7 @@
 	unsigned long cpu_vm_mask;
 	unsigned long swap_cnt;	/* number of pages to swap on next pass */
 	unsigned long swap_address;
+	struct list_head mmlist;		/* active mm list */
 	/*
 	 * This is an architecture-specific pointer: the portable
 	 * part of Linux does not know about any segments.
@@ -237,7 +238,8 @@
 		0, 0, 0, 				\
 		0, 0, 0, 0,				\
 		0, 0, 0,				\
-		0, 0, 0, 0, NULL }
+		0, 0, 0, 0, 				\
+		LIST_HEAD_INIT(init_mm.mmlist), NULL }
 
 struct signal_struct {
 	atomic_t		count;
--- kernel/fork.c	Sat Apr  8 14:58:44 2000
+++ kernel/fork.c	Tue Apr 11 12:39:31 2000
@@ -33,6 +33,7 @@
 
 /* SLAB cache for mm_struct's. */
 kmem_cache_t *mm_cachep;
+spinlock_t mm_lock = SPIN_LOCK_UNLOCKED;
 
 /* SLAB cache for files structs */
 kmem_cache_t *files_cachep; 
@@ -307,8 +308,12 @@
 		init_MUTEX(&mm->mmap_sem);
 		mm->page_table_lock = SPIN_LOCK_UNLOCKED;
 		mm->pgd = pgd_alloc();
-		if (mm->pgd)
+		if (mm->pgd) {
+			mmlist_modify_lock();
+			list_add_tail(&mm->mmlist, &init_mm.mmlist);
+			mmlist_modify_unlock();
 			return mm;
+		}
 		kmem_cache_free(mm_cachep, mm);
 	}
 	return NULL;
@@ -322,8 +327,11 @@
 inline void __mmdrop(struct mm_struct *mm)
 {
 	if (mm == &init_mm) BUG();
+	mmlist_modify_lock();
 	pgd_free(mm->pgd);
 	destroy_context(mm);
+	list_del(&mm->mmlist);
+	mmlist_modify_unlock();
 	kmem_cache_free(mm_cachep, mm);
 }
 
--- mm/mmap.c	Sat Apr  8 14:56:06 2000
+++ mm/mmap.c	Sat Apr  8 15:34:01 2000
@@ -835,6 +835,7 @@
 
 	release_segments(mm);
 	mpnt = mm->mmap;
+	down(&mm->mmap_sem);
 	vmlist_modify_lock(mm);
 	mm->mmap = mm->mmap_avl = mm->mmap_cache = NULL;
 	vmlist_modify_unlock(mm);
@@ -861,6 +862,13 @@
 		kmem_cache_free(vm_area_cachep, mpnt);
 		mpnt = next;
 	}
+
+	/*
+	 * Execing mm's are still holdable.
+	 */
+	if (atomic_read(&mm->mm_users) == 0)
+		mark_nonholdable(mm);
+	up(&mm->mmap_sem);
 
 	/* This is just debugging */
 	if (mm->map_count)
--- mm/swapfile.c	Sat Apr  8 14:58:44 2000
+++ mm/swapfile.c	Tue Apr 11 12:48:13 2000
@@ -3,6 +3,7 @@
  *
  *  Copyright (C) 1991, 1992, 1993, 1994  Linus Torvalds
  *  Swap reorganised 29.12.95, Stephen Tweedie
+ *  Swapoff race fixes + MPsafe swap counts Dec 1999, Kanoj Sarcar, SGI
  */
 
 #include <linux/malloc.h>
@@ -207,6 +208,20 @@
 	unsigned long offset, type;
 	swp_entry_t entry;
 
+ 	if (PageSwapCache(page)) {
+ 		/*
+ 		 * If swap device deletion is in progress, refuse to
+ 		 * grab anymore references on the handles.
+ 		 */
+ 		entry.val = page->index;
+ 		p = swap_info + SWP_TYPE(entry);
+ 		if ((p->flags & SWP_WRITEOK) != SWP_WRITEOK) {
+ 			entry.val = 0;
+ 			return entry;
+ 		}
+ 		swap_duplicate(entry);
+ 		return entry;
+ 	}
 	if (!PageSwapEntry(page))
 		goto new_swap_entry;
 
@@ -244,9 +259,6 @@
 }
 
 /*
- * The swap entry has been read in advance, and we return 1 to indicate
- * that the page has been used or is no longer needed.
- *
  * Always set the resulting pte to be nowrite (the same as COW pages
  * after one process has exited).  We don't know just how many PTEs will
  * share this swap entry, so be cautious and let do_wp_page work out
@@ -348,20 +360,20 @@
 	} while (start && (start < end));
 }
 
-static void unuse_process(struct mm_struct * mm,
+static void unuse_mm(struct mm_struct * mm,
 			swp_entry_t entry, struct page* page)
 {
 	struct vm_area_struct* vma;
 
 	/*
-	 * Go through process' page directory.
+	 * Go through mm's page directory.
 	 */
-	if (!mm)
-		return;
+	down(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		pgd_t * pgd = pgd_offset(mm, vma->vm_start);
 		unuse_vma(vma, pgd, entry, page);
 	}
+	up(&mm->mmap_sem);
 	return;
 }
 
@@ -373,7 +385,7 @@
 static int try_to_unuse(unsigned int type)
 {
 	struct swap_info_struct * si = &swap_info[type];
-	struct task_struct *p;
+	struct mm_struct *curmm, *prevmm;
 	struct page *page;
 	swp_entry_t entry;
 	int i;
@@ -411,15 +423,35 @@
 			swap_free(entry);
   			return -ENOMEM;
 		}
-		read_lock(&tasklist_lock);
-		for_each_task(p)
-			unuse_process(p->mm, entry, page);
-		read_unlock(&tasklist_lock);
+
 		shm_unuse(entry, page);
+		prevmm = &init_mm;
+		mmlist_access_lock();
+		curmm = list_entry(prevmm->mmlist.next, struct mm_struct,
+					mmlist);
+		while (curmm != &init_mm) {
+			if (hold_mm(curmm)) {
+				mmlist_access_unlock();
+				if (prevmm != &init_mm) release_mm(prevmm);
+				unuse_mm(curmm, entry, page);
+				prevmm = curmm;
+				mmlist_access_lock();
+			}
+			curmm = list_entry(curmm->mmlist.next,
+						struct mm_struct, mmlist);
+		}
+		mmlist_access_unlock();
+		if (prevmm != &init_mm) release_mm(prevmm);
+		/*
+		 * Lock the page to protect against scache deletion from
+		 * free_page_and_swap_cache, do_wp_page and shm code.
+		 */
+		lock_page(page);	/* Isn't page already locked? */
+		if (PageSwapCache(page))
+			delete_from_swap_cache_nolock(page);
+		UnlockPage(page);
 		/* Now get rid of the extra reference to the temporary
                    page we've been using. */
-		if (PageSwapCache(page))
-			delete_from_swap_cache(page);
 		__free_page(page);
 		/*
 		 * Check for and clear any overflowed swap map counts.
@@ -488,8 +520,10 @@
 		swap_list.next = swap_list.head;
 	}
 	nr_swap_pages -= p->pages;
-	swap_list_unlock();
+	swap_device_lock(p);
 	p->flags = SWP_USED;
+	swap_device_unlock(p);
+	swap_list_unlock();
 	err = try_to_unuse(type);
 	if (err) {
 		/* re-insert swap space back into swap_list */
@@ -1000,7 +1034,12 @@
 	toff = *offset = (*offset >> page_cluster) << page_cluster;
 
 	swap_device_lock(swapdev);
-	do {
+	/*
+	 * If swap deletion is in progress, prevent readaheads to
+	 * reduce races.
+	 */
+	if ((swapdev->flags & SWP_WRITEOK) == SWP_WRITEOK) {
+	   do {
 		/* Don't read-ahead past the end of the swap area */
 		if (toff >= swapdev->max)
 			break;
@@ -1012,7 +1051,8 @@
 		swapdev->swap_map[toff]++;
 		toff++;
 		ret++;
-	} while (--i);
+	   } while (--i);
+	}
 	swap_device_unlock(swapdev);
 	return ret;
 }
--- mm/vmscan.c	Sat Apr  8 14:58:44 2000
+++ mm/vmscan.c	Sat Apr  8 15:34:01 2000
@@ -71,8 +71,9 @@
 	 * memory, and we should just continue our scan.
 	 */
 	if (PageSwapCache(page)) {
-		entry.val = page->index;
-		swap_duplicate(entry);
+		entry = acquire_swap_entry(page);
+		if (!entry.val)
+			goto out_failed;
 		set_pte(page_table, swp_entry_to_pte(entry));
 drop_pte:
 		vma->vm_mm->rss--;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
