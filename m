Date: Fri, 7 Apr 2000 12:45:13 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004061802080.6583-100000@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.21.0004071205300.737-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Apr 2000, Ben LaHaise wrote:

>First off, it doesn't verify that all of the bits which should be clear in
>a swap entry actually are -- eg bit 0 (present) can and is getting
>set.  It would have to rebuild and compare the swap entry produced by
>SWP_ENTRY(type,offset) to be 100% sure that it is a valid swap entry.

That shouldn't be a problem. What we cares is to return a _valid_ swap
entry from acquire_swap_entry, if that wasn't a cached-swap-entry that
were a minor problem (not a stability issue at least).

However I agree the current design is not very clean and not very strict
and it's too silent. So now I make sure that the swap-entry bitflag is set
only on good page->index.

>Heheh, okay I've moved it there.  Just in case I've also added a
>BUG() check in free_pages_okay to make sure there aren't any other places
>that have been missed.

That's certainly a good idea, I did that too indeed :).

I'm working on that and right now I am stuck fixing up SMP/non-SMP races
and bugs in the VM that I found while checking the swap entry stuff.
However the swap entry stuff in my current tree should be fixed now.

This is a snapshot of my tree so that we can stay in sync. I guess the
below stuff it's ready for inclusion but if you don't agree with something
let me know of course, thanks. It seems to work stable here. I included
also some early fix (the non intrusive ones). One for a SMP race fix for
swapoff/get_swap_page, an SMP race in the vmlist access lock during
swapoff, do_wp_page that have to know the swap cache can have reference
count 3 and not being shared, and the highmem page replacement should
cache also the swap-entry bitflag (I just do a copy of all the flags to be
faster). It doesn't need to copy the mapping pointer since it's always
null and the new_page have it null too.

It's against 2.3.99-pre4-4.

diff -urN ref/mm/filemap.c swap-entry-1/mm/filemap.c
--- ref/mm/filemap.c	Thu Apr  6 01:00:51 2000
+++ swap-entry-1/mm/filemap.c	Fri Apr  7 04:44:27 2000
@@ -300,6 +300,8 @@
 		if (PageSwapCache(page)) {
 			spin_unlock(&pagecache_lock);
 			__delete_from_swap_cache(page);
+			/* the page is local to us now */
+			page->flags &= ~(1UL << PG_swap_entry);
 			goto made_inode_progress;
 		}	
 
diff -urN ref/mm/highmem.c swap-entry-1/mm/highmem.c
--- ref/mm/highmem.c	Mon Apr  3 03:21:59 2000
+++ swap-entry-1/mm/highmem.c	Fri Apr  7 03:48:46 2000
@@ -75,7 +75,7 @@
 
 	/* Preserve the caching of the swap_entry. */
 	highpage->index = page->index;
-	highpage->mapping = page->mapping;
+	highpage->flags = page->flags;
 
 	/*
 	 * We can just forget the old page since 
diff -urN ref/mm/memory.c swap-entry-1/mm/memory.c
--- ref/mm/memory.c	Fri Apr  7 12:17:24 2000
+++ swap-entry-1/mm/memory.c	Fri Apr  7 12:26:53 2000
@@ -838,6 +838,7 @@
 	 */
 	switch (page_count(old_page)) {
 	case 2:
+	case 3:
 		/*
 		 * Lock the page so that no one can look it up from
 		 * the swap cache, grab a reference and start using it.
@@ -880,7 +881,19 @@
 		new_page = old_page;
 	}
 	spin_unlock(&tsk->mm->page_table_lock);
-	__free_page(new_page);
+	/*
+	 * We're releasing a page, it can be an anonymous
+	 * page as well. Since we don't hold any lock (except
+	 * the mmap_sem semaphore) the other user of the anonymous
+	 * page may have released it from under us and now we
+	 * could be the only owner of the page, thus put_page_testzero() can
+	 * return 1, and we have to clear the swap-entry
+	 * bitflag in such case.
+	 */
+	if (put_page_testzero(new_page)) {
+		new_page->flags &= ~(1UL << PG_swap_entry);
+		__free_pages_ok(new_page, 0);
+	}
 	return 1;
 
 bad_wp_page:
diff -urN ref/mm/page_alloc.c swap-entry-1/mm/page_alloc.c
--- ref/mm/page_alloc.c	Thu Apr  6 01:00:52 2000
+++ swap-entry-1/mm/page_alloc.c	Thu Apr  6 05:05:59 2000
@@ -110,6 +110,8 @@
 		BUG();
 	if (PageDecrAfter(page))
 		BUG();
+	if (PageSwapEntry(page))
+		BUG();
 
 	zone = page->zone;
 
diff -urN ref/mm/swap_state.c swap-entry-1/mm/swap_state.c
--- ref/mm/swap_state.c	Thu Apr  6 01:00:52 2000
+++ swap-entry-1/mm/swap_state.c	Fri Apr  7 12:29:00 2000
@@ -126,9 +126,14 @@
 		UnlockPage(page);
 	}
 
-	ClearPageSwapEntry(page);
-
-	__free_page(page);
+	/*
+	 * Only the last unmap have to lose the swap entry
+	 * information that we have cached into page->index.
+	 */
+	if (put_page_testzero(page)) {
+		page->flags &= ~(1UL << PG_swap_entry);
+		__free_pages_ok(page, 0);
+	}
 }
 
 
@@ -151,7 +156,7 @@
 		 * Right now the pagecache is 32-bit only.  But it's a 32 bit index. =)
 		 */
 repeat:
-		found = find_lock_page(&swapper_space, entry.val);
+		found = find_get_page(&swapper_space, entry.val);
 		if (!found)
 			return 0;
 		/*
@@ -163,7 +168,6 @@
 		 * is enough to check whether the page is still in the scache.
 		 */
 		if (!PageSwapCache(found)) {
-			UnlockPage(found);
 			__free_page(found);
 			goto repeat;
 		}
@@ -172,13 +176,11 @@
 #ifdef SWAP_CACHE_INFO
 		swap_cache_find_success++;
 #endif
-		UnlockPage(found);
 		return found;
 	}
 
 out_bad:
 	printk (KERN_ERR "VM: Found a non-swapper swap page!\n");
-	UnlockPage(found);
 	__free_page(found);
 	return 0;
 }
diff -urN ref/mm/swapfile.c swap-entry-1/mm/swapfile.c
--- ref/mm/swapfile.c	Thu Apr  6 01:00:52 2000
+++ swap-entry-1/mm/swapfile.c	Fri Apr  7 12:35:59 2000
@@ -212,22 +212,22 @@
 
 	/* We have the old entry in the page offset still */
 	if (!page->index)
-		goto new_swap_entry;
+		goto null_swap_entry;
 	entry.val = page->index;
 	type = SWP_TYPE(entry);
 	if (type >= nr_swapfiles)
-		goto new_swap_entry;
+		goto bad_nofile;
+	swap_list_lock();
 	p = type + swap_info;
 	if ((p->flags & SWP_WRITEOK) != SWP_WRITEOK)
-		goto new_swap_entry;
+		goto unlock_list;
 	offset = SWP_OFFSET(entry);
 	if (offset >= p->max)
-		goto new_swap_entry;
+		goto bad_offset;
 	/* Has it been re-used for something else? */
-	swap_list_lock();
 	swap_device_lock(p);
 	if (p->swap_map[offset])
-		goto unlock_new_swap_entry;
+		goto unlock;
 
 	/* We're cool, we can just use the old one */
 	p->swap_map[offset] = 1;
@@ -236,11 +236,24 @@
 	swap_list_unlock();
 	return entry;
 
-unlock_new_swap_entry:
+unlock:
 	swap_device_unlock(p);
+unlock_list:
 	swap_list_unlock();
+clear_swap_entry:
+	ClearPageSwapEntry(page);
 new_swap_entry:
 	return get_swap_page();
+
+null_swap_entry:
+	printk(KERN_WARNING __FUNCTION__ " null swap entry\n");
+	goto clear_swap_entry;
+bad_nofile:
+	printk(KERN_WARNING __FUNCTION__ " nonexistent swap file\n");
+	goto clear_swap_entry;
+bad_offset:
+	printk(KERN_WARNING __FUNCTION__ " bad offset\n");
+	goto unlock_list;
 }
 
 /*
@@ -263,8 +276,11 @@
 		/* If this entry is swap-cached, then page must already
                    hold the right address for any copies in physical
                    memory */
-		if (pte_page(pte) != page)
+		if (pte_page(pte) != page) {
+			if (page->index == entry.val)
+				ClearPageSwapEntry(page);
 			return;
+		}
 		/* We will be removing the swap cache in a moment, so... */
 		set_pte(dir, pte_mkdirty(pte));
 		return;
@@ -358,10 +374,20 @@
 	 */
 	if (!mm)
 		return;
+	/*
+	 * Avoid the vmas to go away from under us
+	 * and also avoids the task to play with
+	 * pagetables while we're running. If the
+	 * vmlist_modify_lock wouldn't acquire the
+	 * mm->page_table_lock spinlock we should
+	 * acquire it by hand.
+	 */
+	vmlist_access_lock(mm);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		pgd_t * pgd = pgd_offset(mm, vma->vm_start);
 		unuse_vma(vma, pgd, entry, page);
 	}
+	vmlist_access_unlock(mm);
 	return;
 }
 
@@ -418,8 +444,10 @@
 		shm_unuse(entry, page);
 		/* Now get rid of the extra reference to the temporary
                    page we've been using. */
-		if (PageSwapCache(page))
+		if (PageSwapCache(page)) {
 			delete_from_swap_cache(page);
+			ClearPageSwapEntry(page);
+		}
 		__free_page(page);
 		/*
 		 * Check for and clear any overflowed swap map counts.
@@ -488,8 +516,8 @@
 		swap_list.next = swap_list.head;
 	}
 	nr_swap_pages -= p->pages;
-	swap_list_unlock();
 	p->flags = SWP_USED;
+	swap_list_unlock();
 	err = try_to_unuse(type);
 	if (err) {
 		/* re-insert swap space back into swap_list */

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
