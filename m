Subject: [PATCH]: fixing swapon memory leak against 2.4.0-test10-pre1
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 10 Oct 2000 05:22:06 +0200
Message-ID: <yttn1gde5y9.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus
   I just resend this patch (the first time I forgot to put the
   [PATCH] field).  It fixes a leak in swapon reported by marcelo
   quite time ago.

Later, Juan.

>>>>> "marcelo" == Marcelo de Paula Bezerra <mosca@roadnet.com.br> writes:

Hi
        sorry for the delay (this problem has been posted some
        time^Wmonths ago).

marcelo> I have noticed what looks like a kernel memory leak in swapoff/swapon
marcelo> if you continualy do:
marcelo> swapoff -a;swapon -a;free you will see the used memory grow without any
marcelo> change in buffers and cached and it never gets back to original levels.

marcelo> Could one of the VM hackers look at this to confirm the leak?

Yes, It is an space leak in sys_swapon, the patch included should fix
it and does some cleanups.  Until now we have an space leak of one
page each time that we called sys_swapon.

This patch does:
- removes rw paramenter in creat_page_buffers function, as it is not
  used.
- removes the rw_swap_page_nolock enterely (as it don't make any sense
  at all anymore).  We pass to use the rw_swap_page() function, as we
  can use the normal interface from it only use.
- Small micro-optimization in the test and clear of the swap cache
  page bit.
- we lock (as previously) and now also unlock the page used to read
  the first block of the swap partition.  We use the normal swap cache
  functions now, which lets us use the normal API.  Until now we
  _forgot_ to Unlock the page and we call free_page, what was not
  enough (as the counter was not 1 at that point).
- Change sys_swapon to use alloc_page instead of __get_free_page() as
  we need the page argument anyway.

Any comments bug reports, ... are wellcome.

Later, Juan.

PD: Linus, please apply.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/fs/buffer.c working/fs/buffer.c
--- base/fs/buffer.c	Tue Oct  3 18:51:58 2000
+++ working/fs/buffer.c	Wed Oct  4 18:43:02 2000
@@ -1246,7 +1246,7 @@
 	goto try_again;
 }
 
-static int create_page_buffers(int rw, struct page *page, kdev_t dev, int b[], int size)
+static int create_page_buffers(struct page *page, kdev_t dev, int b[], int size)
 {
 	struct buffer_head *head, *bh, *tail;
 	int block;
@@ -2092,7 +2092,7 @@
 	 */
 	fresh = 0;
 	if (!page->buffers) {
-		create_page_buffers(rw, page, dev, b, size);
+		create_page_buffers(page, dev, b, size);
 		fresh = 1;
 	}
 	if (!page->buffers)
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/include/linux/swap.h working/include/linux/swap.h
--- base/include/linux/swap.h	Wed Oct  4 18:02:45 2000
+++ working/include/linux/swap.h	Fri Oct  6 01:07:44 2000
@@ -114,7 +114,6 @@
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, struct page *, int);
-extern void rw_swap_page_nolock(int, swp_entry_t, char *, int);
 
 /* linux/mm/page_alloc.c */
 
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/page_io.c working/mm/page_io.c
--- base/mm/page_io.c	Tue Oct  3 18:52:02 2000
+++ working/mm/page_io.c	Fri Oct  6 00:42:53 2000
@@ -119,25 +119,3 @@
 	if (!rw_swap_page_base(rw, entry, page, wait))
 		UnlockPage(page);
 }
-
-/*
- * The swap lock map insists that pages be in the page cache!
- * Therefore we can't use it.  Later when we can remove the need for the
- * lock map and we can reduce the number of functions exported.
- */
-void rw_swap_page_nolock(int rw, swp_entry_t entry, char *buf, int wait)
-{
-	struct page *page = virt_to_page(buf);
-	
-	if (!PageLocked(page))
-		PAGE_BUG(page);
-	if (PageSwapCache(page))
-		PAGE_BUG(page);
-	if (page->mapping)
-		PAGE_BUG(page);
-	/* needs sync_page to wait I/O completation */
-	page->mapping = &swapper_space;
-	if (!rw_swap_page_base(rw, entry, page, wait))
-		UnlockPage(page);
-	page->mapping = NULL;
-}
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/swap_state.c working/mm/swap_state.c
--- base/mm/swap_state.c	Tue Oct  3 18:52:02 2000
+++ working/mm/swap_state.c	Thu Oct  5 01:07:35 2000
@@ -69,10 +69,9 @@
 
 	if (mapping != &swapper_space)
 		BUG();
-	if (!PageSwapCache(page) || !PageLocked(page))
+	if (!PageTestandClearSwapCache(page) || !PageLocked(page))
 		PAGE_BUG(page);
 
-	PageClearSwapCache(page);
 	__remove_inode_page(page);
 }
 
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/swapfile.c working/mm/swapfile.c
--- base/mm/swapfile.c	Tue Aug  8 06:01:36 2000
+++ working/mm/swapfile.c	Fri Oct  6 01:14:31 2000
@@ -552,6 +552,7 @@
 	int error;
 	static int least_priority = 0;
 	union swap_header *swap_header = 0;
+	struct page *page = NULL;
 	int swap_header_version;
 	int nr_good_pages = 0;
 	unsigned long maxpages;
@@ -638,15 +639,16 @@
 	} else
 		goto bad_swap;
 
-	swap_header = (void *) __get_free_page(GFP_USER);
-	if (!swap_header) {
+	page = alloc_page(GFP_USER);
+	if (!page) {
 		printk("Unable to start swapping: out of memory :-)\n");
 		error = -ENOMEM;
 		goto bad_swap;
 	}
-
-	lock_page(virt_to_page(swap_header));
-	rw_swap_page_nolock(READ, SWP_ENTRY(type,0), (char *) swap_header, 1);
+	lock_page(page);
+	swap_header = page_address(page);
+	add_to_swap_cache(page, SWP_ENTRY(type,0));
+	rw_swap_page(READ, page, 1);
 
 	if (!memcmp("SWAP-SPACE",swap_header->magic.magic,10))
 		swap_header_version = 1;
@@ -785,8 +787,11 @@
 		++least_priority;
 	path_release(&nd);
 out:
-	if (swap_header)
-		free_page((long) swap_header);
+	if (page) {
+		delete_from_swap_cache(page);
+		UnlockPage(page);
+		put_page(page);
+	}
 	unlock_kernel();
 	return error;
 }

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
