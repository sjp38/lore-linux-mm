Date: Wed, 22 Dec 1999 00:58:47 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: [patch] mmap<->write deadlock fix, plus bug in block_write_zero_range
Message-ID: <Pine.LNX.3.96.991222003426.18406A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's the fix I've got for the mmap/write deadlock.  I don't like it, but
the only other fixes I can think of are just as bad, or horrendously
complex.  Note that the first patch to fs/buffer.c fixes a serious problem
in block_write_zero_range: a partial write to a page that is not already
cached on a file on a file system with more than two blocks per page could
result in a stack scribble -- eeek!

The patch to filemap.c changes filemap_nopage to use __find_page_nolock
rather than __find_get_page which waits for the page to become unlocked
before returning (maybe __find_get_page was meant to check PageUptodate?),
since filemap_nopage checks PageUptodate before proceeding -- which is
consistent with do_generic_file_read.

		-ben


diff -ur clean/2.3.34-2/fs/buffer.c 2.3.34-2/fs/buffer.c
--- clean/2.3.34-2/fs/buffer.c	Thu Dec  9 16:10:18 1999
+++ 2.3.34-2/fs/buffer.c	Wed Dec 22 00:46:18 1999
@@ -1386,7 +1386,7 @@
 	unsigned long block;
 	int err = 0, partial = 0, need_balance_dirty = 0;
 	unsigned blocksize, bbits;
-	struct buffer_head *bh, *head, *wait[2], **wait_bh=wait;
+	struct buffer_head *bh, *head, *wait[PAGE_CACHE_SIZE / 512], **wait_bh=wait;
 	char *kaddr = (char *)kmap(page);
 
 	blocksize = inode->i_sb->s_blocksize;
diff -ur clean/2.3.34-2/include/linux/sched.h 2.3.34-2/include/linux/sched.h
--- clean/2.3.34-2/include/linux/sched.h	Mon Dec 20 18:53:12 1999
+++ 2.3.34-2/include/linux/sched.h	Wed Dec 22 00:02:06 1999
@@ -349,6 +349,7 @@
 
 /* memory management info */
 	struct mm_struct *mm, *active_mm;
+	struct page *write_locked_page;		/* currently locked page for mmap<->write deadlock test */
 
 /* signal handlers */
 	spinlock_t sigmask_lock;	/* Protects signal and blocked */
@@ -426,7 +427,7 @@
 /* thread */	INIT_THREAD, \
 /* fs */	&init_fs, \
 /* files */	&init_files, \
-/* mm */	NULL, &init_mm, \
+/* mm */	NULL, &init_mm, NULL, \
 /* signals */	SPIN_LOCK_UNLOCKED, &init_signals, {{0}}, {{0}}, NULL, &init_task.sigqueue, 0, 0, \
 /* exec cts */	0,0, \
 /* exit_sem */	__MUTEX_INITIALIZER(name.exit_sem),	\
diff -ur clean/2.3.34-2/mm/filemap.c 2.3.34-2/mm/filemap.c
--- clean/2.3.34-2/mm/filemap.c	Mon Dec 20 14:20:06 1999
+++ 2.3.34-2/mm/filemap.c	Wed Dec 22 00:21:12 1999
@@ -1325,7 +1325,12 @@
 	 */
 	hash = page_hash(&inode->i_data, pgoff);
 retry_find:
-	page = __find_get_page(&inode->i_data, pgoff, hash);
+	spin_lock(&pagecache_lock);
+	page = __find_page_nolock(&inode->i_data, pgoff, *hash);
+	if (page)
+		get_page(page);
+	spin_unlock(&pagecache_lock);
+
 	if (!page)
 		goto no_cached_page;
 
@@ -1388,6 +1393,9 @@
 	return NULL;
 
 page_not_uptodate:
+	if (current->write_locked_page == page)
+		return NOPAGE_SIGBUS;
+
 	lock_page(page);
 	if (Page_Uptodate(page)) {
 		UnlockPage(page);
@@ -1917,6 +1925,9 @@
 			PAGE_BUG(page);
 		}
 
+		/* Detect the deadlock */
+		current->write_locked_page = page;
+
 		status = write_one_page(file, page, offset, bytes, buf);
 
 		if (status >= 0) {
@@ -1928,6 +1939,7 @@
 				inode->i_size = pos;
 		}
 		/* Mark it unlocked again and drop the page.. */
+		current->write_locked_page = NULL;
 		UnlockPage(page);
 		page_cache_release(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
