Date: Sun, 10 Sep 2000 21:41:50 -0400
From: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Subject: [PATCH] Page aging for 2.4.0-test8
Message-ID: <20000910214150.A30532@acs.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds page aging similar to what was in 2.0.  The patch
is quite straight forward but I've had one lockup that I have
been unable to reproduce.  I don't know if the lockup was caused
by my patch or was a test8 bug.

This patch is supposed to improve interactive performance,
especially during heavy IO.  The page referenced bit has been
removed and is replaced by an integer page age (can someone
explain how to cache align this?).  Newly mapped pages get an age
of 2 (younger pages have higher ages).  Whenever a page is
referenced the age is increased, up to a maximum of 5.  Each time
a page is examined in the shrink_mmap loop its age is decreased.
Pages with ages greater than zero are not paged out.

The idea is that during heavy IO, pages used only once for IO
will have an age of 2.  Hopefully the X server, your MP3 player
and other useful goodies have pages with ages greater than 2 and
will not be paged out.

Interactive performance during Bonnie tests seems to be quite
good (although stock test8 is not bad either).  I think there
still may be an issue with elevator starvation.  Has there been
any more work on this front?  The discussion seems to have died
out.

-- 
Neil Schemenauer <nas@arctrix.com> http://www.enme.ucalgary.ca/~nascheme/

diff -ur linux-2.4/Makefile linux-age/Makefile
--- linux-2.4/Makefile	Sun Sep 10 10:15:27 2000
+++ linux-age/Makefile	Sun Sep 10 15:06:14 2000
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 4
 SUBLEVEL = 0
-EXTRAVERSION = -test8
+EXTRAVERSION = -test8-age
 
 KERNELRELEASE=$(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)
 
diff -ur linux-2.4/fs/buffer.c linux-age/fs/buffer.c
--- linux-2.4/fs/buffer.c	Sun Sep 10 10:15:53 2000
+++ linux-age/fs/buffer.c	Sun Sep 10 11:45:04 2000
@@ -2182,7 +2182,7 @@
 	spin_unlock(&free_list[isize].lock);
 
 	page->buffers = bh;
-	page->flags &= ~(1 << PG_referenced);
+	page->age = 0;
 	lru_cache_add(page);
 	atomic_inc(&buffermem_pages);
 	return 1;
diff -ur linux-2.4/include/linux/fs.h linux-age/include/linux/fs.h
--- linux-2.4/include/linux/fs.h	Sun Sep 10 10:16:08 2000
+++ linux-age/include/linux/fs.h	Sun Sep 10 11:49:39 2000
@@ -260,7 +260,7 @@
 
 extern void set_bh_page(struct buffer_head *bh, struct page *page, unsigned long offset);
 
-#define touch_buffer(bh)	SetPageReferenced(bh->b_page)
+#define touch_buffer(bh)	PageTouch(bh->b_page)
 
 
 #include <linux/pipe_fs_i.h>
diff -ur linux-2.4/include/linux/mm.h linux-age/include/linux/mm.h
--- linux-2.4/include/linux/mm.h	Sun Sep 10 10:16:09 2000
+++ linux-age/include/linux/mm.h	Sun Sep 10 14:33:52 2000
@@ -154,8 +154,15 @@
 	struct buffer_head * buffers;
 	void *virtual; /* non-NULL if kmapped */
 	struct zone_struct *zone;
+	int age;
 } mem_map_t;
 
+#define PG_AGE_INITIAL  2 /* age for pages when mapped */
+#define PG_AGE_YOUNG    5 /* age for pages recently used */
+
+#define PageAgeInit(p)  (p->age = PG_AGE_INITIAL)
+#define PageTouch(p)    if (p->age < PG_AGE_YOUNG) p->age++;
+
 #define get_page(p)		atomic_inc(&(p)->count)
 #define put_page(p)		__free_page(p)
 #define put_page_testzero(p) 	atomic_dec_and_test(&(p)->count)
@@ -165,7 +172,7 @@
 /* Page flag bit values */
 #define PG_locked		 0
 #define PG_error		 1
-#define PG_referenced		 2
+#define PG_unused_00		 2
 #define PG_uptodate		 3
 #define PG_dirty		 4
 #define PG_decr_after		 5
@@ -197,9 +204,6 @@
 #define PageError(page)		test_bit(PG_error, &(page)->flags)
 #define SetPageError(page)	set_bit(PG_error, &(page)->flags)
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)
-#define PageReferenced(page)	test_bit(PG_referenced, &(page)->flags)
-#define SetPageReferenced(page)	set_bit(PG_referenced, &(page)->flags)
-#define PageTestandClearReferenced(page)	test_and_clear_bit(PG_referenced, &(page)->flags)
 #define PageDecrAfter(page)	test_bit(PG_decr_after, &(page)->flags)
 #define SetPageDecrAfter(page)	set_bit(PG_decr_after, &(page)->flags)
 #define PageTestandClearDecrAfter(page)	test_and_clear_bit(PG_decr_after, &(page)->flags)
@@ -293,9 +297,9 @@
  * When a read completes, the page becomes uptodate, unless a disk I/O
  * error happened.
  *
- * For choosing which pages to swap out, inode pages carry a
- * PG_referenced bit, which is set any time the system accesses
- * that page through the (inode,offset) hash table.
+ * For choosing which pages to swap out, inode pages carry a page age
+ * which is increased (up to PG_AGE_YOUNG) any time the system
+ * accesses that page through the (inode,offset) hash table.
  *
  * PG_skip is used on sparc/sparc64 architectures to "skip" certain
  * parts of the address space.
diff -ur linux-2.4/mm/filemap.c linux-age/mm/filemap.c
--- linux-2.4/mm/filemap.c	Sun Sep 10 10:16:14 2000
+++ linux-age/mm/filemap.c	Sun Sep 10 14:35:22 2000
@@ -255,8 +255,10 @@
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
-		if (PageTestandClearReferenced(page))
+		if (page->age > 0) {
+			page->age--;
 			goto dispose_continue;
+		}
 
 		count--;
 		/*
@@ -384,7 +386,7 @@
 		if (page->index == offset)
 			break;
 	}
-	SetPageReferenced(page);
+	PageTouch(page);
 not_found:
 	return page;
 }
@@ -508,8 +510,9 @@
 	if (PageLocked(page))
 		BUG();
 
-	flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_dirty) | (1 << PG_referenced));
+	flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_dirty));
 	page->flags = flags | (1 << PG_locked);
+	PageAgeInit(page);
 	page_cache_get(page);
 	page->index = offset;
 	add_page_to_inode_queue(mapping, page);
diff -ur linux-2.4/mm/page_alloc.c linux-age/mm/page_alloc.c
--- linux-2.4/mm/page_alloc.c	Sun Sep 10 10:16:15 2000
+++ linux-age/mm/page_alloc.c	Sun Sep 10 14:36:39 2000
@@ -97,6 +97,8 @@
 	if (PageDirty(page))
 		BUG();
 
+	PageAgeInit(page);
+
 	zone = page->zone;
 
 	mask = (~0UL) << order;
@@ -598,6 +600,7 @@
 	for (p = lmem_map; p < lmem_map + totalpages; p++) {
 		set_page_count(p, 0);
 		SetPageReserved(p);
+		PageAgeInit(p);
 		init_waitqueue_head(&p->wait);
 		memlist_init(&p->list);
 	}
diff -ur linux-2.4/mm/swap_state.c linux-age/mm/swap_state.c
--- linux-2.4/mm/swap_state.c	Sun Sep 10 10:14:02 2000
+++ linux-age/mm/swap_state.c	Sun Sep 10 14:36:58 2000
@@ -58,8 +58,9 @@
 		BUG();
 	if (page->mapping)
 		BUG();
-	flags = page->flags & ~((1 << PG_error) | (1 << PG_dirty) | (1 << PG_referenced));
+	flags = page->flags & ~((1 << PG_error) | (1 << PG_dirty));
 	page->flags = flags | (1 << PG_uptodate);
+	PageAgeInit(page);
 	add_to_page_cache_locked(page, &swapper_space, entry.val);
 }
 
diff -ur linux-2.4/mm/vmscan.c linux-age/mm/vmscan.c
--- linux-2.4/mm/vmscan.c	Sun Sep 10 10:16:15 2000
+++ linux-age/mm/vmscan.c	Sun Sep 10 14:36:16 2000
@@ -58,7 +58,7 @@
 		 * tables to the global page map.
 		 */
 		set_pte(page_table, pte_mkold(pte));
-                SetPageReferenced(page);
+		PageTouch(page);
 		goto out_failed;
 	}
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
