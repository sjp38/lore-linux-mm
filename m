Subject: PATCH: Cleanup of use of PG_* page bits (take 2)
References: <yttd7n2kzu0.fsf@vexeta.dc.fi.udc.es>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "04 May 2000 19:08:39 +0200"
Date: 05 May 2000 21:36:46 +0200
Message-ID: <ytt7ld84wmp.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi
        this second version of the patch:
1 - it compiles (a typo in the previous one)
2 - it substitutes all the direct manipulations of PG_* by macros.  It
        only touches fs/* and mm/* not the drivers directories.

Comments?

Later, Juan.

diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-4/fs/buffer.c testing/fs/buffer.c
--- pre7-4/fs/buffer.c	Thu May  4 11:02:17 2000
+++ testing/fs/buffer.c	Thu May  4 19:12:46 2000
@@ -789,7 +789,7 @@
 	/*
 	 * Run the hooks that have to be done when a page I/O has completed.
 	 */
-	if (test_and_clear_bit(PG_decr_after, &page->flags))
+	if (PageTestandClearDecrAfter(page))
 		atomic_dec(&nr_async_pages);
 
 	UnlockPage(page);
@@ -1957,7 +1957,7 @@
 
 	if (!PageLocked(page))
 		panic("brw_page: page not locked for I/O");
-//	clear_bit(PG_error, &page->flags);
+//	ClearPageError(page);
 	/*
 	 * We pretty much rely on the page lock for this, because
 	 * create_page_buffers() might sleep.
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-4/fs/nfs/write.c testing/fs/nfs/write.c
--- pre7-4/fs/nfs/write.c	Wed Apr 26 17:49:00 2000
+++ testing/fs/nfs/write.c	Thu May  4 19:17:08 2000
@@ -1048,7 +1048,7 @@
         dprintk("NFS:      nfs_updatepage returns %d (isize %Ld)\n",
                                                 status, (long long)inode->i_size);
 	if (status < 0)
-		clear_bit(PG_uptodate, &page->flags);
+		ClearPageUptodate(page);
 	return status;
 }
 
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-4/fs/smbfs/file.c testing/fs/smbfs/file.c
--- pre7-4/fs/smbfs/file.c	Wed Apr 26 02:28:56 2000
+++ testing/fs/smbfs/file.c	Thu May  4 19:12:46 2000
@@ -56,7 +56,7 @@
 
 	/* We can't replace this with ClearPageError. why? is it a problem? 
 	   fs/buffer.c:brw_page does the same. */
-	/* clear_bit(PG_error, &page->flags); */
+	/* ClearPageError(page); */
 
 #ifdef SMBFS_DEBUG_VERBOSE
 printk("smb_readpage_sync: file %s/%s, count=%d@%ld, rsize=%d\n",
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-4/include/linux/fs.h testing/include/linux/fs.h
--- pre7-4/include/linux/fs.h	Thu May  4 11:02:18 2000
+++ testing/include/linux/fs.h	Thu May  4 19:13:53 2000
@@ -251,7 +251,7 @@
 
 extern void set_bh_page(struct buffer_head *bh, struct page *page, unsigned long offset);
 
-#define touch_buffer(bh)	set_bit(PG_referenced, &bh->b_page->flags)
+#define touch_buffer(bh)	SetPageReferenced(bh->b_page)
 
 
 #include <linux/pipe_fs_i.h>
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-4/include/linux/mm.h testing/include/linux/mm.h
--- pre7-4/include/linux/mm.h	Thu May  4 11:02:18 2000
+++ testing/include/linux/mm.h	Thu May  4 19:13:53 2000
@@ -196,7 +196,11 @@
 #define SetPageError(page)	set_bit(PG_error, &(page)->flags)
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)
 #define PageReferenced(page)	test_bit(PG_referenced, &(page)->flags)
+#define SetPageReferenced(page)	set_bit(PG_referenced, &(page)->flags)
+#define PageTestandClearReferenced(page)	test_and_clear_bit(PG_referenced, &(page)->flags)
 #define PageDecrAfter(page)	test_bit(PG_decr_after, &(page)->flags)
+#define SetPageDecrAfter(page)	set_bit(PG_decr_after, &(page)->flags)
+#define PageTestandClearDecrAfter(page)	test_and_clear_bit(PG_decr_after, &(page)->flags)
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define PageSwapCache(page)	test_bit(PG_swap_cache, &(page)->flags)
 #define PageReserved(page)	test_bit(PG_reserved, &(page)->flags)
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-4/mm/filemap.c testing/mm/filemap.c
--- pre7-4/mm/filemap.c	Thu May  4 11:02:18 2000
+++ testing/mm/filemap.c	Thu May  4 19:12:46 2000
@@ -266,7 +266,7 @@
 		 * &young to make sure that we won't try to free it the next
 		 * time */
 		dispose = &young;
-		if (test_and_clear_bit(PG_referenced, &page->flags))
+		if (PageTestandClearReferenced(page))
 			goto dispose_continue;
 
 		if (p_zone->free_pages > p_zone->pages_high)
@@ -394,7 +394,7 @@
 		if (page->index == offset)
 			break;
 	}
-	set_bit(PG_referenced, &page->flags);
+	SetPageReferenced(page);
 not_found:
 	return page;
 }
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-4/mm/page_io.c testing/mm/page_io.c
--- pre7-4/mm/page_io.c	Thu May  4 11:02:18 2000
+++ testing/mm/page_io.c	Thu May  4 19:12:46 2000
@@ -74,7 +74,7 @@
 		return 0;
 	}
  	if (!wait) {
- 		set_bit(PG_decr_after, &page->flags);
+ 		SetPageDecrAfter(page);
  		atomic_inc(&nr_async_pages);
  	}
 
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-4/mm/vmscan.c testing/mm/vmscan.c
--- pre7-4/mm/vmscan.c	Thu May  4 11:02:18 2000
+++ testing/mm/vmscan.c	Thu May  4 19:12:46 2000
@@ -56,7 +56,7 @@
 		 * tables to the global page map.
 		 */
 		set_pte(page_table, pte_mkold(pte));
-		set_bit(PG_referenced, &page->flags);
+                SetPageReferenced(page);
 		goto out_failed;
 	}
 



-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
