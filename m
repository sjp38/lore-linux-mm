Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <Pine.LNX.4.10.10005111519590.819-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Thu, 11 May 2000 15:22:15 -0700 (PDT)"
Date: 12 May 2000 03:01:19 +0200
Message-ID: <yttbt2c8tuo.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

Hi

linus> What we _could_ do is to just for clarity have

linus> 	#define page_cache_get()	get_page()

linus> and then pair up every "page_cache_get()" with "page_cache_release()".
linus> Which makes sense to me. So if you feel strongly about this issue..

You ask for it, here is the patch. Noted that I have changed all the
get_page/put_page/__free_page that I have find to the equivalents in
the page_cache_get/page_cache_release/page_cache_release.

There are two points where I am not sure about the thing to do:

- In shm.c it calls alloc_pages, I have substituted it for page_cache,
  due to the fact that shm use the page_cache, if somebody changes
  the page_cache, it needs to change the shm code acordingly.

- In buffers.c it calls alloc_page, but it calls it with a different
  mask, then I have left the alloc_pages, call. But I have put the
  get/put operations as page_cache_* operations, due to the fact that
  they use the page_cache.

Once that we are here, what are the *semantic* difference between
page_cache_release and page_cache_free?

Any comment?

Later, Juan.

diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7/fs/buffer.c testing2/fs/buffer.c
--- pre7/fs/buffer.c	Fri May 12 01:11:40 2000
+++ testing2/fs/buffer.c	Fri May 12 02:44:30 2000
@@ -1264,7 +1264,7 @@
 		set_bit(BH_Mapped, &bh->b_state);
 	}
 	tail->b_this_page = head;
-	get_page(page);
+	page_cache_get(page);
 	page->buffers = head;
 	return 0;
 }
@@ -1351,7 +1351,7 @@
 	} while (bh);
 	tail->b_this_page = head;
 	page->buffers = head;
-	get_page(page);
+	page_cache_get(page);
 }
 
 static void unmap_underlying_metadata(struct buffer_head * bh)
@@ -2106,7 +2106,7 @@
 	return 1;
 
 no_buffer_head:
-	__free_page(page);
+	page_cache_release(page);
 out:
 	return 0;
 }
@@ -2190,7 +2190,7 @@
 
 	/* And free the page */
 	page->buffers = NULL;
-	__free_page(page);
+	page_cache_release(page);
 	spin_unlock(&free_list[index].lock);
 	write_unlock(&hash_table_lock);
 	spin_unlock(&lru_list_lock);
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7/fs/nfs/write.c testing2/fs/nfs/write.c
--- pre7/fs/nfs/write.c	Fri May 12 01:11:41 2000
+++ testing2/fs/nfs/write.c	Fri May 12 01:56:29 2000
@@ -528,7 +528,7 @@
 	 * long write-back delay. This will be adjusted in
 	 * update_nfs_request below if the region is not locked. */
 	req->wb_page    = page;
-	get_page(page);
+	page_cache_get(page);
 	req->wb_offset  = offset;
 	req->wb_bytes   = count;
 	req->wb_dentry  = dget(dentry);
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7/include/linux/pagemap.h testing2/include/linux/pagemap.h
--- pre7/include/linux/pagemap.h	Fri May 12 01:11:42 2000
+++ testing2/include/linux/pagemap.h	Fri May 12 01:45:46 2000
@@ -28,6 +28,7 @@
 #define PAGE_CACHE_MASK		PAGE_MASK
 #define PAGE_CACHE_ALIGN(addr)	(((addr)+PAGE_CACHE_SIZE-1)&PAGE_CACHE_MASK)
 
+#define page_cache_get(x)	get_page(x);
 #define page_cache_alloc()	alloc_pages(GFP_HIGHUSER, 0)
 #define page_cache_free(x)	__free_page(x)
 #define page_cache_release(x)	__free_page(x)
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7/ipc/shm.c testing2/ipc/shm.c
--- pre7/ipc/shm.c	Fri May 12 01:11:43 2000
+++ testing2/ipc/shm.c	Fri May 12 02:35:59 2000
@@ -1348,7 +1348,7 @@
 		   could potentially fault on our pte under us */
 		if (pte_none(pte)) {
 			shm_unlock(shp->id);
-			page = alloc_page(GFP_HIGHUSER);
+			page = page_cache_alloc();
 			if (!page)
 				goto oom;
 			clear_user_highpage(page, address);
@@ -1380,7 +1380,7 @@
 	}
 
 	/* pte_val(pte) == SHM_ENTRY (shp, idx) */
-	get_page(pte_page(pte));
+	page_cache_get(pte_page(pte));
 	return pte_page(pte);
 
 oom:
@@ -1448,7 +1448,7 @@
 	lock_kernel();
 	rw_swap_page(WRITE, page, 0);
 	unlock_kernel();
-	__free_page(page);
+	page_cache_release(page);
 }
 
 static int shm_swap_preop(swp_entry_t *swap_entry)
@@ -1537,7 +1537,7 @@
 
 	pte = pte_mkdirty(mk_pte(page, PAGE_SHARED));
 	SHM_ENTRY(shp, idx) = pte;
-	get_page(page);
+	page_cache_get(page);
 	shm_rss++;
 
 	shm_swp--;
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7/mm/filemap.c testing2/mm/filemap.c
--- pre7/mm/filemap.c	Fri May 12 01:11:43 2000
+++ testing2/mm/filemap.c	Fri May 12 02:00:07 2000
@@ -145,7 +145,7 @@
 
 		if (head->next!=head) {
 			page = list_entry(head->next, struct page, list);
-			get_page(page);
+			page_cache_get(page);
 			spin_unlock(&pagemap_lru_lock);
 			spin_unlock(&pagecache_lock);
 			/* We need to block */
@@ -187,13 +187,13 @@
 		/* page wholly truncated - free it */
 		if (offset >= start) {
 			if (TryLockPage(page)) {
-				get_page(page);
+				page_cache_get(page);
 				spin_unlock(&pagecache_lock);
 				wait_on_page(page);
 				page_cache_release(page);
 				goto repeat;
 			}
-			get_page(page);
+			page_cache_get(page);
 			spin_unlock(&pagecache_lock);
 
 			if (!page->buffers || block_flushpage(page, 0))
@@ -237,7 +237,7 @@
 			spin_unlock(&pagecache_lock);
 			goto repeat;
 		}
-		get_page(page);
+		page_cache_get(page);
 		spin_unlock(&pagecache_lock);
 
 		memclear_highpage_flush(page, partial, PAGE_CACHE_SIZE-partial);
@@ -252,9 +252,9 @@
 		 */
 		UnlockPage(page);
 		page_cache_release(page);
-		get_page(page);
+		page_page_get(page);
 		wait_on_page(page);
-		put_page(page);
+		page_cache_release(page);
 		goto repeat;
 	}
 	spin_unlock(&pagecache_lock);
@@ -312,7 +312,7 @@
 		spin_unlock(&pagemap_lru_lock);
 
 		/* avoid freeing the page while it's locked */
-		get_page(page);
+		page_cache_get(page);
 
 		/*
 		 * Is it a buffer page? Try to clean it up regardless
@@ -376,7 +376,7 @@
 unlock_continue:
 		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
-		put_page(page);
+		page_cache_release(page);
 dispose_continue:
 		list_add(page_lru, dispose);
 	}
@@ -386,7 +386,7 @@
 	page_cache_release(page);
 made_buffer_progress:
 	UnlockPage(page);
-	put_page(page);
+	page_cache_release(page);
 	ret = 1;
 	spin_lock(&pagemap_lru_lock);
 	/* nr_lru_pages needs the spinlock */
@@ -474,7 +474,7 @@
 		if (page->index < start)
 			continue;
 
-		get_page(page);
+		page_cache_get(page);
 		spin_unlock(&pagecache_lock);
 		lock_page(page);
 
@@ -516,7 +516,7 @@
 	if (!PageLocked(page))
 		BUG();
 
-	get_page(page);
+	page_cache_get(page);
 	spin_lock(&pagecache_lock);
 	page->index = index;
 	add_page_to_inode_queue(mapping, page);
@@ -541,7 +541,7 @@
 
 	flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_dirty));
 	page->flags = flags | (1 << PG_locked) | (1 << PG_referenced);
-	get_page(page);
+	page_cache_get(page);
 	page->index = offset;
 	add_page_to_inode_queue(mapping, page);
 	__add_page_to_hash_queue(page, hash);
@@ -683,7 +683,7 @@
 	spin_lock(&pagecache_lock);
 	page = __find_page_nolock(mapping, offset, *hash);
 	if (page)
-		get_page(page);
+		page_cache_get(page);
 	spin_unlock(&pagecache_lock);
 
 	/* Found the page, sleep if locked. */
@@ -733,7 +733,7 @@
 	spin_lock(&pagecache_lock);
 	page = __find_page_nolock(mapping, offset, *hash);
 	if (page)
-		get_page(page);
+		page_cache_get(page);
 	spin_unlock(&pagecache_lock);
 
 	/* Found the page, sleep if locked. */
@@ -1091,7 +1091,7 @@
 		if (!page)
 			goto no_cached_page;
 found_page:
-		get_page(page);
+		page_cache_get(page);
 		spin_unlock(&pagecache_lock);
 
 		if (!Page_Uptodate(page))
@@ -1594,7 +1594,7 @@
 		set_pte(ptep, pte_mkclean(pte));
 		flush_tlb_page(vma, address);
 		page = pte_page(pte);
-		get_page(page);
+		page_cache_get(page);
 	} else {
 		if (pte_none(pte))
 			return 0;
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7/mm/memory.c testing2/mm/memory.c
--- pre7/mm/memory.c	Fri May 12 01:11:43 2000
+++ testing2/mm/memory.c	Fri May 12 02:30:44 2000
@@ -861,7 +861,7 @@
 	 * Ok, we need to copy. Oh, well..
 	 */
 	spin_unlock(&mm->page_table_lock);
-	new_page = alloc_page(GFP_HIGHUSER);
+	new_page = page_cache_alloc();
 	if (!new_page)
 		return -1;
 	spin_lock(&mm->page_table_lock);
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7/mm/swap_state.c testing2/mm/swap_state.c
--- pre7/mm/swap_state.c	Fri May 12 01:11:43 2000
+++ testing2/mm/swap_state.c	Fri May 12 02:23:47 2000
@@ -136,7 +136,7 @@
 		}
 		UnlockPage(page);
 	}
-	__free_page(page);
+	put_page_release(page);
 }
 
 
@@ -172,7 +172,7 @@
 		 */
 		if (!PageSwapCache(found)) {
 			UnlockPage(found);
-			__free_page(found);
+			page_cache_release(found);
 			goto repeat;
 		}
 		if (found->mapping != &swapper_space)
@@ -187,7 +187,7 @@
 out_bad:
 	printk (KERN_ERR "VM: Found a non-swapper swap page!\n");
 	UnlockPage(found);
-	__free_page(found);
+	page_cache_release(found);
 	return 0;
 }
 
@@ -237,7 +237,7 @@
 	return new_page;
 
 out_free_page:
-	__free_page(new_page);
+	page_cache_release(new_page);
 out_free_swap:
 	swap_free(entry);
 out:





-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
