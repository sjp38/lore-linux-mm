Subject: PATCH: Cleanup of the Swap Cache
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 07 May 2000 19:40:40 +0200
Message-ID: <ytt1z3ew95z.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi everybody

   This patch does:

        - This patch applies in top of the other two sent by my to the
          list. (lock_kernel.diff and shm_lock.diff). You can get all
          from:
              http://carpanta.dc.fi.udc.es/~quintela/kernel/
          All the patches are against 2.3.99-pre7-6


        - Documents in DookBook format all the functions in
          mm/swap_state.c.  It makes explicit the assumptions about
          the locks that should be held/drop in each function.

        - In general all the swap_cache functions now expect to have
          the argument pages locked and will return the result pages
          locked as well.  The exceptions are marked.

        - Now we export only one function delete_from_swap_cache*
          The name of the function is: delete_from_swap_cache,
          it takes as argument a locked page, and after delete the
          page from the Swap Cache it unlocks the page.  With this
          change in semantics, we can export one only function instead
          of the old functions:
                - __delete_from_swap_cache (no lock at all)
                - delete_from_swap_cache_nolock makes some checks and
                  call the previous one, it expects the page to be
                  locked.
                - delete_from_swap_cache, it expects an unlocked page,
                  do the locking and call the previous function.

        - It changes all the callers accordingly to reflect the new
          semantics.

        - Now all the calls to read_swap_cache_async are asynchronous, if you
          need to make it synchronous, it is needed to do a
          wait_on_page (see the code in read_swap_cache). 


        - rw_swap_page* this two functions become also always called
          asynchronously, If the caller need to wait in the page it
          need to call wait_on_page.

        - Almost all the callers of rw_swap_page* and read_swap_cache*
          are called asynchronously, then the change in interface make
          sense.  

        - Changed lookup_swap_cache to return a locked page instead of
          an unlocked one.  Changing all the callers accordingly.
          The only problems is in read_swap_cache_async, that it
          returns an unlocked page and now we need to unlock it.  I
          think that read_swap_cache, when called synchronously, should
          return a locked page if that page is in the cache.  For
          doping that change I need to change the swapin_readahead
          code, and I prefer to here some comments before doing more
          changes.

        - This patch also remove an unneeded call to
          replace_with_highmem in ipc/shm.c.  The code call
          replace_with_highmem, but never use again the returned page.

Comments?

If people like the patch (or like the idea, I can make changes form
comments), I will continue the documentation of the functions/cleanup
of the interfaces.  I would prefer to know the opinion of the rest of
the people before doing more changes.

Thanks in advance for any suggestions and for your time.

Later, Juan.

        
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/Documentation/DocBook/Makefile testing/Documentation/DocBook/Makefile
--- testing2/Documentation/DocBook/Makefile	Thu Apr 13 18:25:44 2000
+++ testing/Documentation/DocBook/Makefile	Sun May  7 00:23:29 2000
@@ -50,6 +50,7 @@
 		$(TOPDIR)/drivers/sound/sound_core.c \
 		$(TOPDIR)/drivers/sound/sound_firmware.c \
 		$(TOPDIR)/drivers/net/wan/syncppp.c \
+		$(TOPDIR)/mm/swap_state.c \
 		$(TOPDIR)/drivers/net/wan/z85230.c \
 		$(TOPDIR)/kernel/pm.c \
 		$(TOPDIR)/kernel/ksyms.c \
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/Documentation/DocBook/kernel-api.tmpl testing/Documentation/DocBook/kernel-api.tmpl
--- testing2/Documentation/DocBook/kernel-api.tmpl	Mon Apr  3 00:38:53 2000
+++ testing/Documentation/DocBook/kernel-api.tmpl	Sun May  7 00:28:16 2000
@@ -74,6 +74,13 @@
      </sect1>
   </chapter>
 
+  <chapter id="mm">
+     <title>The Linux MM</title>
+     <sect1><title>The Swap Cache</title>
+!Imm/swap_state.c
+     </sect1>
+  </chapter>
+
   <chapter id="modload">
      <title>Module Loading</title>
 !Ekernel/kmod.c
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/arch/m68k/atari/stram.c testing/arch/m68k/atari/stram.c
--- testing2/arch/m68k/atari/stram.c	Wed Feb 16 19:56:44 2000
+++ testing/arch/m68k/atari/stram.c	Sat May  6 06:18:15 2000
@@ -943,8 +943,10 @@
 				shm_unuse(entry, page);
 				/* Now get rid of the extra reference to
 				   the temporary page we've been using. */
-				if (PageSwapCache(page_map))
+				if (PageSwapCache(page_map)) {
+					lock_page(page_map);
 					delete_from_swap_cache(page_map);
+                }
 				__free_page(page_map);
 	#ifdef DO_PROC
 				stat_swap_force++;
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/include/linux/swap.h testing/include/linux/swap.h
--- testing2/include/linux/swap.h	Fri May  5 23:58:56 2000
+++ testing/include/linux/swap.h	Sat May  6 06:28:47 2000
@@ -90,25 +90,25 @@
 extern int swap_out(unsigned int gfp_mask, int priority);
 
 /* linux/mm/page_io.c */
-extern void rw_swap_page(int, struct page *, int);
-extern void rw_swap_page_nolock(int, swp_entry_t, char *, int);
+extern void rw_swap_page(int, struct page *);
+extern void rw_swap_page_nolock(int, swp_entry_t, struct page *);
+
 
 /* linux/mm/page_alloc.c */
 
+
 /* linux/mm/swap_state.c */
 extern void show_swap_cache_info(void);
 extern void add_to_swap_cache(struct page *, swp_entry_t);
 extern int swap_check_entry(unsigned long);
 extern struct page * lookup_swap_cache(swp_entry_t);
-extern struct page * read_swap_cache_async(swp_entry_t, int);
-#define read_swap_cache(entry) read_swap_cache_async(entry, 1);
+extern struct page * read_swap_cache_async(swp_entry_t);
+struct page * read_swap_cache(swp_entry_t entry);
 
 /*
  * Make these inline later once they are working properly.
  */
-extern void __delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache(struct page *page);
-extern void delete_from_swap_cache_nolock(struct page *page);
 extern void free_page_and_swap_cache(struct page *page);
 
 /* linux/mm/swapfile.c */
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/ipc/shm.c testing/ipc/shm.c
--- testing2/ipc/shm.c	Sun May  7 00:17:27 2000
+++ testing/ipc/shm.c	Sat May  6 06:13:16 2000
@@ -1379,14 +1379,13 @@
 			if (!page) {
 				lock_kernel();
 				swapin_readahead(entry);
-				page = read_swap_cache_async(entry, 0);
+				page = read_swap_cache_async(entry);
 				unlock_kernel();
 				if (!page)
 					goto oom;
-                                wait_on_page(page);
+                                lock_page(page);
 			}
 			delete_from_swap_cache(page);
-			page = replace_with_highmem(page);
 			swap_free(entry);
 			if ((shp != shm_lock(shp->id)) && (shp->id != zero_id))
 				BUG();
@@ -1463,7 +1462,7 @@
 static void shm_swap_postop(struct page *page)
 {
 	lock_kernel();
-	rw_swap_page(WRITE, page, 0);
+	rw_swap_page(WRITE, page);
 	unlock_kernel();
 	__free_page(page);
 }
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/mm/filemap.c testing/mm/filemap.c
--- testing2/mm/filemap.c	Fri May  5 23:58:56 2000
+++ testing/mm/filemap.c	Sat May  6 05:47:46 2000
@@ -327,8 +327,8 @@
 		 */
 		if (PageSwapCache(page)) {
 			spin_unlock(&pagecache_lock);
-			__delete_from_swap_cache(page);
-			goto made_inode_progress;
+			delete_from_swap_cache(page);
+			goto made_swap_progress;
 		}	
 
 		/* is it a page-cache page? */
@@ -365,6 +365,7 @@
 	page_cache_release(page);
 made_buffer_progress:
 	UnlockPage(page);
+made_swap_progress:
 	put_page(page);
 	ret = 1;
 	spin_lock(&pagemap_lru_lock);
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/mm/memory.c testing/mm/memory.c
--- testing2/mm/memory.c	Sun May  7 00:17:27 2000
+++ testing/mm/memory.c	Sat May  6 06:14:02 2000
@@ -847,8 +847,7 @@
 			UnlockPage(old_page);
 			break;
 		}
-		delete_from_swap_cache_nolock(old_page);
-		UnlockPage(old_page);
+		delete_from_swap_cache(old_page);
 		/* FallThrough */
 	case 1:
 		flush_cache_page(vma, address);
@@ -1020,7 +1019,7 @@
 			break;
 		}
 		/* Ok, do the async read-ahead now */
-		new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);
+		new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset));
 		if (new_page != NULL)
 			__free_page(new_page);
 		swap_free(SWP_ENTRY(SWP_TYPE(entry), offset));
@@ -1038,11 +1037,11 @@
 	if (!page) {
 		lock_kernel();
 		swapin_readahead(entry);
-		page = read_swap_cache_async(entry, 0);
+		page = read_swap_cache_async(entry);
 		unlock_kernel();
 		if (!page)
 			return -1;
-                wait_on_page(page);
+                lock_page(page);
 		flush_page_to_ram(page);
 		flush_icache_page(vma, page);
 	}
@@ -1056,11 +1055,9 @@
 	 * Must lock page before transferring our swap count to already
 	 * obtained page count.
 	 */
-	lock_page(page);
 	swap_free(entry);
 	if (write_access && !is_page_shared(page)) {
-		delete_from_swap_cache_nolock(page);
-		UnlockPage(page);
+		delete_from_swap_cache(page);
 		page = replace_with_highmem(page);
 		pte = mk_pte(page, vma->vm_page_prot);
 		pte = pte_mkwrite(pte_mkdirty(pte));
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/mm/page_io.c testing/mm/page_io.c
--- testing2/mm/page_io.c	Fri May  5 23:58:56 2000
+++ testing/mm/page_io.c	Sat May  6 06:14:37 2000
@@ -33,7 +33,7 @@
  * that shared pages stay shared while being swapped.
  */
 
-static int rw_swap_page_base(int rw, swp_entry_t entry, struct page *page, int wait)
+static int rw_swap_page_base(int rw, swp_entry_t entry, struct page *page)
 {
 	unsigned long offset;
 	int zones[PAGE_SIZE/512];
@@ -41,6 +41,7 @@
 	kdev_t dev = 0;
 	int block_size;
 	struct inode *swapf = 0;
+        int wait = 0;
 
 	/* Don't allow too many pending pages in flight.. */
 	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
@@ -103,7 +104,7 @@
  *  - it's marked as being swap-cache
  *  - it's associated with the swap inode
  */
-void rw_swap_page(int rw, struct page *page, int wait)
+ void rw_swap_page(int rw, struct page *page)
 {
 	swp_entry_t entry;
 
@@ -115,7 +116,7 @@
 		PAGE_BUG(page);
 	if (page->mapping != &swapper_space)
 		PAGE_BUG(page);
-	if (!rw_swap_page_base(rw, entry, page, wait))
+	if (!rw_swap_page_base(rw, entry, page))
 		UnlockPage(page);
 }
 
@@ -124,10 +125,8 @@
  * Therefore we can't use it.  Later when we can remove the need for the
  * lock map and we can reduce the number of functions exported.
  */
-void rw_swap_page_nolock(int rw, swp_entry_t entry, char *buf, int wait)
+void rw_swap_page_nolock(int rw, swp_entry_t entry, struct page *page)
 {
-	struct page *page = mem_map + MAP_NR(buf);
-	
 	if (!PageLocked(page))
 		PAGE_BUG(page);
 	if (PageSwapCache(page))
@@ -136,7 +135,8 @@
 		PAGE_BUG(page);
 	/* needs sync_page to wait I/O completation */
 	page->mapping = &swapper_space;
-	if (!rw_swap_page_base(rw, entry, page, wait))
+	if (!rw_swap_page_base(rw, entry, page))
 		UnlockPage(page);
 	page->mapping = NULL;
+        wait_on_page(page);
 }
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/mm/swap_state.c testing/mm/swap_state.c
--- testing2/mm/swap_state.c	Fri May  5 23:58:56 2000
+++ testing/mm/swap_state.c	Sat May  6 23:36:02 2000
@@ -45,6 +45,15 @@
 }
 #endif
 
+/**
+ * add_to_swap_cache - adds a page to the swap cache
+ * @page: page to add
+ * @entry: swap entry of the page
+ *
+ * This function will add a page to the swap cache.  The initial state
+ * of the page is referenced and uptodate.
+ */
+
 void add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
 	unsigned long flags;
@@ -80,7 +89,7 @@
  * This must be called only on pages that have
  * been verified to be in the swap cache.
  */
-void __delete_from_swap_cache(struct page *page)
+static inline void __delete_from_swap_cache(struct page *page)
 {
 	swp_entry_t entry;
 
@@ -93,11 +102,15 @@
 	swap_free(entry);
 }
 
-/*
+/** 
+ * delete_from_swap_cache - Removes a page from the swap cache
+ * @page: the page should be locked and in the swap cache
+ * 
  * This will never put the page into the free list, the caller has
- * a reference on the page.
+ * a reference on the page. 
  */
-void delete_from_swap_cache_nolock(struct page *page)
+
+void delete_from_swap_cache(struct page *page)
 {
 	if (!PageLocked(page))
 		BUG();
@@ -106,25 +119,19 @@
 		lru_cache_del(page);
 
 	__delete_from_swap_cache(page);
+        UnlockPage(page);
 	page_cache_release(page);
 }
 
-/*
- * This must be called only on pages that have
- * been verified to be in the swap cache and locked.
- */
-void delete_from_swap_cache(struct page *page)
-{
-	lock_page(page);
-	delete_from_swap_cache_nolock(page);
-	UnlockPage(page);
-}
-
-/* 
+/**
+ * free_page_and_swap_cache - delete a page from the Swap Cache
+ * @page: a non-locked page to free
+ * 
  * Perform a free_page(), also freeing any swap cache associated with
- * this page if it is the last user of the page. Can not do a lock_page,
+ * this page if it is the last user of the page. Can not do a lock_page(),
  * as we are holding the page_table_lock spinlock.
  */
+
 void free_page_and_swap_cache(struct page *page)
 {
 	/* 
@@ -132,19 +139,20 @@
 	 */
 	if (PageSwapCache(page) && !TryLockPage(page)) {
 		if (!is_page_shared(page)) {
-			delete_from_swap_cache_nolock(page);
-		}
-		UnlockPage(page);
+			delete_from_swap_cache(page);
+		} else
+                        UnlockPage(page);
 	}
 	__free_page(page);
 }
 
 
-/*
- * Lookup a swap entry in the swap cache. A found page will be returned
- * unlocked and with its refcount incremented - we rely on the kernel
- * lock getting page table operations atomic even if we drop the page
- * lock before returning.
+/**
+ * lookup_swap_cache - Lookup a swap entry in the swap cache.
+ * @entry: swap entry to search
+ *
+ * A found page will be returned locked and with the refcount
+ * incremented.
  */
 
 struct page * lookup_swap_cache(swp_entry_t entry)
@@ -180,18 +188,19 @@
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
 
-/* 
+/**
+ * read_swap_cache_async - Make sure a page is in physical memory
+ * @entry: entry of the page to read
+ *
  * Locate a page of swap in physical memory, reserving swap cache space
  * and reading the disk if it is not already cached.  If wait==0, we are
  * only doing readahead, so don't worry if the page is already locked.
@@ -200,7 +209,7 @@
  * the swap entry is no longer in use.
  */
 
-struct page * read_swap_cache_async(swp_entry_t entry, int wait)
+struct page * read_swap_cache_async(swp_entry_t entry)
 {
 	struct page *found_page = 0, *new_page;
 	unsigned long new_page_addr;
@@ -233,7 +242,7 @@
 	 */
 	lock_page(new_page);
 	add_to_swap_cache(new_page, entry);
-	rw_swap_page(READ, new_page, wait);
+	rw_swap_page(READ, new_page);
 	return new_page;
 
 out_free_page:
@@ -241,5 +250,21 @@
 out_free_swap:
 	swap_free(entry);
 out:
+        UnlockPage(found_page); // JJ FIXME
 	return found_page;
+}
+
+/**
+ * read_swap_cache - Make sure that one page is in physical memory
+ * @entry: entry to the page to be read
+ *
+ * This function is a wrapper to read_swap_cache_async() and waits for the
+ * page to be ready
+ */
+
+struct page * read_swap_cache(swp_entry_t entry)
+{
+        struct page * page = read_swap_cache_async(entry);
+        wait_on_page(page);
+        return page;
 }
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/mm/swapfile.c testing/mm/swapfile.c
--- testing2/mm/swapfile.c	Fri May  5 23:58:56 2000
+++ testing/mm/swapfile.c	Sat May  6 06:15:29 2000
@@ -375,8 +375,10 @@
 		shm_unuse(entry, page);
 		/* Now get rid of the extra reference to the temporary
                    page we've been using. */
-		if (PageSwapCache(page))
+		if (PageSwapCache(page)) {
+                        lock_page(page);
 			delete_from_swap_cache(page);
+                }
 		__free_page(page);
 		/*
 		 * Check for and clear any overflowed swap map counts.
@@ -548,6 +550,7 @@
 	struct swap_info_struct * p;
 	struct nameidata nd;
 	struct inode * swap_inode;
+        struct page * page;
 	unsigned int type;
 	int i, j, prev;
 	int error;
@@ -653,9 +656,9 @@
 		error = -ENOMEM;
 		goto bad_swap;
 	}
-
-	lock_page(mem_map + MAP_NR(swap_header));
-	rw_swap_page_nolock(READ, SWP_ENTRY(type,0), (char *) swap_header, 1);
+        page = mem_map + MAP_NR(swap_header);
+	lock_page(page);
+	rw_swap_page_nolock(READ, SWP_ENTRY(type,0), page);
 
 	if (!memcmp("SWAP-SPACE",swap_header->magic.magic,10))
 		swap_header_version = 1;
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS testing2/mm/vmscan.c testing/mm/vmscan.c
--- testing2/mm/vmscan.c	Fri May  5 23:58:56 2000
+++ testing/mm/vmscan.c	Sat May  6 20:09:34 2000
@@ -179,7 +179,7 @@
 	vmlist_access_unlock(vma->vm_mm);
 
 	/* OK, do a physical asynchronous write to swap.  */
-	rw_swap_page(WRITE, page, 0);
+	rw_swap_page(WRITE, page);
 
 out_free_success:
 	__free_page(page);


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
